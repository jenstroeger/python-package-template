
# Use bash as the shell when executing a rule's recipe. For more details:
# https://www.gnu.org/software/make/manual/html_node/Choosing-the-Shell.html
# https://stackoverflow.com/questions/10376206/what-is-the-preferred-bash-shebang
SHELL := /usr/bin/env bash

# This variable contains the first goal that matches any of the listed goals
# here, else it contains an empty string. The net effect is to filter out
# whether this current run of `make` requires a Python virtual environment.
NEED_VENV := $(or \
  $(findstring setup,$(MAKECMDGOALS)), \
  $(findstring upgrade-quiet,$(MAKECMDGOALS)), \
  $(findstring upgrade,$(MAKECMDGOALS)), \
  $(findstring requirements,$(MAKECMDGOALS)), \
  $(findstring all,$(MAKECMDGOALS)), \
  $(findstring quick-check,$(MAKECMDGOALS)), \
  $(findstring check,$(MAKECMDGOALS)), \
  $(findstring test,$(MAKECMDGOALS)), \
  $(findstring dist,$(MAKECMDGOALS)), \
  $(findstring docs,$(MAKECMDGOALS)) \
)
ifeq ($(NEED_VENV),)
  # None of the current goals requires a virtual environment.
else
  ifeq ($(origin VIRTUAL_ENV),undefined)
    $(warning No Python virtual environment found, proceeding anyway)
  else
    ifeq ($(wildcard .venv/upgraded-on),)
      $(warning Python virtual environment not yet set up, proceeding anyway)
    endif
  endif
endif

# If the project configuration file has been updated (package deps or
# otherwise) then warn the user and suggest resolving the conflict.
ifeq ($(shell test pyproject.toml -nt .venv/upgraded-on; echo $$?),0)
  $(warning pyproject.toml was updated, consider `make upgrade` if your packages have changed)
  $(warning If this is not correct then run `make upgrade-quiet`)
endif

# Check, test, and build artifacts for this package.
.PHONY: all
all: check test dist docs

# Create a virtual environment, either for Python3.10 (default) or using
# the Python interpreter specified in the PYTHON environment variable.
.PHONY: venv
venv:
	if [ ! -z "${VIRTUAL_ENV}" ]; then \
	  echo "Found an activated Python virtual environment, exiting" && exit 1; \
	fi
	if [ -z "${PYTHON}" ]; then \
	  echo "Creating virtual envirnoment in .venv/ for python3.10"; \
	  python3.10 -m venv --upgrade-deps .venv; \
	else \
	  echo "Creating virtual envirnoment in .venv/ for ${PYTHON}"; \
	  ${PYTHON} -m venv --upgrade-deps .venv; \
	fi

# Set up a newly created virtual environment. Note: pre-commit uses the
# venv's Python interpreter, so if you've created multiple venvs then
# pre-commit's git hooks run against the most recently set up venv.
.PHONY: setup
setup: force-upgrade
	pre-commit install
	pre-commit install --hook-type commit-msg
	pre-commit install --hook-type pre-push

# Install or upgrade an existing virtual environment based on the
# package dependencies declared in pyproject.toml.
.PHONY: upgrade force-upgrade
upgrade: .venv/upgraded-on
.venv/upgraded-on: pyproject.toml
	python -m pip install --upgrade pip
	python -m pip install --upgrade wheel
	python -m pip install --upgrade --upgrade-strategy eager --editable .[hooks,dev,test,docs]
	$(MAKE) upgrade-quiet
force-upgrade:
	rm -f .venv/upgraded-on
	$(MAKE) upgrade
upgrade-quiet:
	echo "Automatically generated by Python Package Makefile on `date --rfc-3339=seconds`." > .venv/upgraded-on

# Generate a requirements.txt file containing version and integrity
# hashes for all packages currently installed in the virtual environment.
.PHONY: requirements
requirements: requirements.txt
requirements.txt: pyproject.toml
	echo "" > requirements.txt
	# See also: https://github.com/peterbe/hashin/issues/139
	for pkg in `python -m pip list --format freeze`; do hashin --verbose $$pkg; done

# Run some or all checks over the package code base.
.PHONY: check check-code check-bandit check-flake8 check-lint check-mypy
check-code: check-bandit check-flake8 check-lint check-mypy
check-bandit:
	pre-commit run bandit --all-files
check-flake8:
	pre-commit run flake8 --all-files
check-lint:
	pre-commit run pylint --all-files
check-mypy:
	pre-commit run mypy --all-files
check:
	pre-commit run --all-files

# Run all unit tests.
.PHONY: test
test:
	pre-commit run pytest --hook-stage push

# Build a source distribution package and a binary wheel distribution artifact.
# When building these artifacts, we need the environment variable SOURCE_DATE_EPOCH
# set to the build date/epoch. For more details, see: https://flit.pypa.io/en/latest/reproducible.html
.PHONY: dist
ifeq ($(wildcard .venv/upgraded-on),)
  PACKAGE_VERSION=unknown
else
  PACKAGE_VERSION=$(shell python -c 'import package; print(package.__version__)')
endif
dist: dist/package-$(PACKAGE_VERSION)-py3-none-any.whl dist/package-$(PACKAGE_VERSION).tar.gz
dist/package-$(PACKAGE_VERSION)-py3-none-any.whl: check test
	if [ -z "${SOURCE_DATE_EPOCH}" ]; then \
	  echo "SOURCE_DATE_EPOCH variable not specified, building non-reproducible wheel"; \
	fi
	flit build --setup-py --format wheel
dist/package-$(PACKAGE_VERSION).tar.gz: check test
	if [ -z "${SOURCE_DATE_EPOCH}" ]; then \
	  echo "SOURCE_DATE_EPOCH variable not specified, building non-reproducible sdist"; \
	fi
	flit build --setup-py --format sdist

# Build the HTML documentation from the package's source.
.PHONY: docs
docs: docs/_build/html/index.html
docs/_build/html/index.html: check test
	$(MAKE) -C docs/ html

# Clean test caches and remove build artifacts.
.PHONY: dist-clean clean
dist-clean:
	rm -fr dist/*
clean: dist-clean
	rm -fr .coverage .hypothesis/ .mypy_cache/ .pytest_cache/
	rm -fr docs/_build/

# Remove code caches, or the entire virtual environment.
.PHONY: nuke-caches nuke
nuke-caches: clean
	find src/ -name __pycache__ -exec rm -fr {} +
	find tests/ -name __pycache__ -exec rm -fr {} +
nuke: nuke-caches
	if [ ! -z "${VIRTUAL_ENV}" ]; then \
	  echo "Deactivating and nuking virtual environment!"; \
	  deactivate; \
	  rm -fr $(VIRTUAL_ENV); \
	fi
	rm -f requirements.txt
