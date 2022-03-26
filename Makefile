#! /usr/bin/env make -f

# This variable contains the first goal that matches any of the listed goals
# here, else it contains an empty string. The net effect is to filter out
# whether this current run of `make` requires a Python virtual environment.
NEED_VENV := $(or \
  $(findstring setup,$(MAKECMDGOALS)), \
  $(findstring upgrade,$(MAKECMDGOALS)), \
  $(findstring requirements,$(MAKECMDGOALS)), \
  $(findstring all,$(MAKECMDGOALS)), \
  $(findstring quick-check,$(MAKECMDGOALS)), \
  $(findstring check,$(MAKECMDGOALS)), \
  $(findstring test,$(MAKECMDGOALS)), \
  $(findstring dist,$(MAKECMDGOALS)), \
  $(findstring bdist-wheel,$(MAKECMDGOALS)), \
  $(findstring sdist,$(MAKECMDGOALS)), \
  $(findstring docs,$(MAKECMDGOALS)) \
)
ifeq ($(NEED_VENV),)
  # None of the current goals requires a virtual environment.
else
  ifeq ($(origin VIRTUAL_ENV),undefined)
    $(warning No Python virtual environment found, proceeding anyway)
  else
    PACKAGE_VERSION=$(shell python -c 'import package; print(package.__version__)')
  endif
endif

# Create a virtual environment, either for Python3.10 (default) or using
# the Python interpreter specified in the PYTHON environment variable.
.PHONY: venv
venv:
	if [ ! -z "${VIRTUAL_ENV}" ]; then \
	  echo "Found an activated Python virtual environment, exiting" && exit 1; \
	fi
	if [ -z "${PYTHON}" ]; then \
	  echo "Creating virtual envirnoment in .venv/ for python3.10" \
	  python3.10 -m venv --upgrade-deps .venv; \
	else \
	  echo "Creating virtual envirnoment in .venv/ for ${PYTHON}" \
	  ${PYTHON} -m venv --upgrade-deps .venv; \
	fi

# Set up a newly created virtual environment.
.PHONY: setup
setup: upgrade
	pre-commit install
	pre-commit install --hook-type commit-msg
	pre-commit install --hook-type pre-push

# Install or upgrade an existing virtual environment based on the
# package dependencies declared in setup.py.
.PHONY: upgrade
upgrade:
	pip install --upgrade pip
	pip install --editable .[hooks,dev,test,docs]

# Generate a requirements.txt file containing version and integrity
# hashes for all packages currently installed in the virtual environment.
.PHONY: requirements
requirements: requirements.txt
requirements.txt:
	echo "" > requirements.txt
	# See also: https://github.com/peterbe/hashin/issues/139
	for p in `pip list --format freeze`; do hashin --verbose $$p; done

# Check, test, and build artifacts for this package.
.PHONY: all
all: check test dist docs

# Run some or all checks over the package code base.
.PHONY: quick-check check
quick-check:
	pre-commit run pylint --all-files
	pre-commit run mypy --all-files
check:
	pre-commit run --all-files

# Run all unit tests.
.PHONY: test
test:
	pre-commit run pytest --hook-stage push

# Build a source distribution package and a binary wheel distribution artifact.
.PHONY: dist bdist-wheel sdist
dist: bdist-wheel sdist
bdist-wheel: $(VIRTUAL_ENV)/dist/package-$(PACKAGE_VERSION)-py3-none-any.whl
$(VIRTUAL_ENV)/dist/package-$(PACKAGE_VERSION)-py3-none-any.whl:
	python setup.py bdist_wheel --dist-dir $(VIRTUAL_ENV)/dist/ --bdist-dir $(VIRTUAL_ENV)/build
sdist: $(VIRTUAL_ENV)/dist/package-$(PACKAGE_VERSION).tar.gz
$(VIRTUAL_ENV)/dist/package-$(PACKAGE_VERSION).tar.gz:
	python setup.py sdist --dist-dir $(VIRTUAL_ENV)/dist/

# Build the HTML documentation from the package's source.
.PHONY: docs
docs: docs/_build/html/index.html
docs/_build/html/index.html:
	$(MAKE) -C docs/ html

# Clean test caches and remove build artifacts.
.PHONY: dist-clean clean
dist-clean:
	rm -fr $(VIRTUAL_ENV)/build/* $(VIRTUAL_ENV)/dist/*
clean: dist-clean
	rm -fr .hypothesis .coverage .mypy_cache .pytest_cache
	rm -fr docs/_build

# Remove code caches, or the entire virtual environment.
.PHONY: nuke-caches nuke
nuke-caches: clean
	find src/ -name __pycache__ -exec rm -fr {} +
	find tests/ -name __pycache__ -exec rm -fr {} +
nuke: nuke-caches
	if [ ! -z "${VIRTUAL_ENV}" ]; then echo "Nuking activated virtual environment!"; fi
	rm -fr src/package.egg-info
	rm -fr $(VIRTUAL_ENV)
	rm -fr requirements.txt
