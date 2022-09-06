
# Use bash as the shell when executing a rule's recipe. For more details:
# https://www.gnu.org/software/make/manual/html_node/Choosing-the-Shell.html
# https://stackoverflow.com/questions/10376206/what-is-the-preferred-bash-shebang
SHELL := /usr/bin/env bash

# This variable contains the first goal that matches any of the listed goals
# here, else it contains an empty string. The net effect is to filter out
# whether this current run of `make` requires a Python virtual environment
# by checking if any of the given goals requires a virtual environment (all
# except the 'venv' and the various 'clean' and 'nuke' goals do). Note that
# checking for 'upgrade' and 'check' goals includes all of their variations.
NEED_VENV := $(or \
  $(findstring all,$(MAKECMDGOALS)), \
  $(findstring setup,$(MAKECMDGOALS)), \
  $(findstring upgrade,$(MAKECMDGOALS)), \
  $(findstring sbom,$(MAKECMDGOALS)), \
  $(findstring requirements,$(MAKECMDGOALS)), \
  $(findstring check,$(MAKECMDGOALS)), \
  $(findstring test,$(MAKECMDGOALS)), \
  $(findstring dist,$(MAKECMDGOALS)), \
  $(findstring docs,$(MAKECMDGOALS)), \
  $(findstring prune,$(MAKECMDGOALS)), \
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

# The SOURCE_DATE_EPOCH environment variable allows the `flit` tool to
# reproducibly build packages: https://flit.pypa.io/en/latest/reproducible.html
# If that variable doesn't exist, then set it here to the current epoch.
ifeq ($(origin SOURCE_DATE_EPOCH),undefined)
  SOURCE_DATE_EPOCH := $(shell date +%s)
endif

# Check, test, and build artifacts for this package.
.PHONY: all
all: check test dist docs

# Create a virtual environment, either for Python3.10 (default) or using
# the Python interpreter specified in the PYTHON environment variable. Also
# create an empty pip.conf file to ensure that `pip config` modifies this
# venv only, unless told otherwise. For more background, see:
# https://github.com/jenstroeger/python-package-template/issues/262
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
	touch .venv/pip.conf

# Set up a newly created virtual environment. Note: pre-commit uses the
# venv's Python interpreter, so if you've created multiple venvs then
# pre-commit's git hooks run against the most recently set up venv.
# The build.yaml GitHub Actions workflow expects dist directory to exist.
# So we create the dist dir if it doesn't exist in the setup target.
# See https://packaging.python.org/en/latest/tutorials/packaging-projects/#generating-distribution-archives.
.PHONY: setup
setup: force-upgrade
	pre-commit install
	mkdir -p dist

# Install or upgrade an existing virtual environment based on the
# package dependencies declared in pyproject.toml.
.PHONY: upgrade force-upgrade
upgrade: .venv/upgraded-on
.venv/upgraded-on: pyproject.toml
	python -m pip install --upgrade pip
	python -m pip install --upgrade wheel
	python -m pip install --upgrade --upgrade-strategy eager --editable .[actions,dev,docs,hooks,test]
	$(MAKE) upgrade-quiet
force-upgrade:
	rm -f .venv/upgraded-on
	$(MAKE) upgrade
upgrade-quiet:
	echo "Automatically generated by Python Package Makefile on `date --rfc-3339=seconds`." > .venv/upgraded-on

# Generate a Software Bill of Materials (SBOM).
.PHONY: sbom
sbom: requirements
	cyclonedx-bom --force --requirements --format json --output dist/package-$(PACKAGE_VERSION)-sbom.json

# Generate a requirements.txt file containing version and integrity hashes for all
# packages currently installed in the virtual environment. There's no easy way to
# do this, see also: https://github.com/pypa/pip/issues/4732
#
# If using a private package index, make sure that it implements the JSON API:
# https://warehouse.pypa.io/api-reference/json.html
#
# We also want to make sure that this package itself is added to the requirements.txt
# file, and if possible even with proper hashes.
.PHONY: requirements
requirements: requirements.txt
requirements.txt: pyproject.toml
	echo -n "" > requirements.txt
	for pkg in `python -m pip freeze --local --disable-pip-version-check --exclude-editable`; do \
	  echo -n $$pkg >> requirements.txt; \
	  echo "Fetching package metadata for requirement '$$pkg'"; \
	  [[ $$pkg =~ (.*)==(.*) ]] && curl -s https://pypi.org/pypi/$${BASH_REMATCH[1]}/$${BASH_REMATCH[2]}/json | python -c "import json, sys; print(''.join(f''' \\\\\n    --hash=sha256:{pkg['digests']['sha256']}''' for pkg in json.load(sys.stdin)['urls']));" >> requirements.txt; \
	done
	echo -e -n "package==$(PACKAGE_VERSION)" >> requirements.txt
	if [ -f dist/package-$(PACKAGE_VERSION).tar.gz ]; then \
	  echo -e -n " \\\\\n    `python -m pip hash --algorithm sha256 dist/package-$(PACKAGE_VERSION).tar.gz | grep '^\-\-hash'`" >> requirements.txt; \
	fi
	if [ -f dist/package-$(PACKAGE_VERSION)-py3-none-any.whl ]; then \
	  echo -e -n " \\\\\n    `python -m pip hash --algorithm sha256 dist/package-$(PACKAGE_VERSION)-py3-none-any.whl | grep '^\-\-hash'`" >> requirements.txt; \
	fi
	echo "" >> requirements.txt
	cp requirements.txt dist/package-$(PACKAGE_VERSION)-requirements.txt

# Audit the installed packages. We disable the --require-hashes option because some packages
# (e.g. alabaster==0.7.12) seem to miss hashes for some platforms (e.g. Windows).
.PHONY: audit
audit: requirements
	if ! $$(python -c "import pip_audit" &> /dev/null); then \
	  echo "No package pip_audit installed, upgrade your environment!" && exit 1; \
	fi;
	python -m pip_audit --requirement requirements.txt --skip-editable --desc on --fix --dry-run

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
dist: dist/package-$(PACKAGE_VERSION)-py3-none-any.whl dist/package-$(PACKAGE_VERSION).tar.gz dist/package-$(PACKAGE_VERSION)-docs-html.zip dist/package-$(PACKAGE_VERSION)-build-epoch.txt
dist/package-$(PACKAGE_VERSION)-py3-none-any.whl: check test
	flit build --setup-py --format wheel
dist/package-$(PACKAGE_VERSION).tar.gz: check test
	flit build --setup-py --format sdist
dist/package-$(PACKAGE_VERSION)-docs-html.zip: docs
	python -m zipfile -c dist/package-$(PACKAGE_VERSION)-docs-html.zip docs/_build/html
dist/package-$(PACKAGE_VERSION)-build-epoch.txt:
	echo $(SOURCE_DATE_EPOCH) > dist/package-$(PACKAGE_VERSION)-build-epoch.txt

# Build the HTML documentation from the package's source.
.PHONY: docs
docs: docs/_build/html/index.html
docs/_build/html/index.html: check test
	$(MAKE) -C docs/ html

# Prune the packages currently installed in the virtual environment down to the required
# packages only. Pruning works in a roundabout way, where we first generate the wheels for
# all installed packages into the build/wheelhouse/ folder. Next we wipe all packages and
# then reinstall them from the wheels while disabling the PyPI index server. Thus we ensure
# that the same package versions are reinstalled. Use with care!
.PHONY: prune
prune:
	mkdir -p build/
	python -m pip freeze --local --disable-pip-version-check --exclude-editable > build/prune-requirements.txt
	python -m pip wheel --wheel-dir build/wheelhouse/ --requirement build/prune-requirements.txt
	python -m pip wheel --wheel-dir build/wheelhouse/ .
	python -m pip uninstall --yes --requirement build/prune-requirements.txt
	python -m pip install --no-index --find-links=build/wheelhouse/ --editable .
	rm -fr build/

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
	  rm -fr .venv; \
	fi
	rm -f requirements.txt
