#! /usr/bin/env make -f

# This variable contains the first goal that matches any of the listed goals
# here, else it contains an empty string. The net effect is to filter out
# whether this current run of `make` requires a Python virtual environment.
NEED_VENV := $(or \
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
    $(error No Python virtual environment found, please activate one or use `make setup`)
  else
    PACKAGE_VERSION=$(shell python -c 'import package; print(package.__version__)')
  endif
endif

.PHONY: setup
setup:
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
	. .venv/bin/activate && \
	pip install --upgrade pip && \
	pip install --editable .[hooks,dev,test,docs]
	. .venv/bin/activate && \
	pre-commit install && \
	pre-commit install --hook-type commit-msg && \
	pre-commit install --hook-type pre-push

.PHONY: upgrade
upgrade:
	pip install --upgrade pip
	pip install --editable .[hooks,dev,test,docs]
	rm -fr requirements.txt && $(MAKE) requirements

.PHONY: requirements
requirements: requirements.txt
requirements.txt:
	echo "" > requirements.txt
	# See also: https://github.com/peterbe/hashin/issues/139
	for p in `pip list --format freeze`; do hashin --verbose $$p; done

.PHONY: all
all: check test dist docs

.PHONY: quick-check check
quick-check:
	pre-commit run pylint --all-files
	pre-commit run mypy --all-files
check:
	pre-commit run --all-files

.PHONY: test
test:
	pre-commit run pytest --hook-stage push

.PHONY: dist bdist-wheel sdist
dist: bdist-wheel sdist
bdist-wheel: $(VIRTUAL_ENV)/dist/package-$(PACKAGE_VERSION)-py3-none-any.whl
$(VIRTUAL_ENV)/dist/package-$(PACKAGE_VERSION)-py3-none-any.whl:
	python setup.py bdist_wheel --dist-dir $(VIRTUAL_ENV)/dist/ --bdist-dir $(VIRTUAL_ENV)/build
sdist: $(VIRTUAL_ENV)/dist/package-$(PACKAGE_VERSION).tar.gz
$(VIRTUAL_ENV)/dist/package-$(PACKAGE_VERSION).tar.gz:
	python setup.py sdist --dist-dir $(VIRTUAL_ENV)/dist/

.PHONY: docs
docs: docs/_build/html/index.html
docs/_build/html/index.html:
	$(MAKE) -C docs/ html

.PHONY: dist-clean clean
dist-clean:
	rm -fr $(VIRTUAL_ENV)/build/* $(VIRTUAL_ENV)/dist/*
clean: dist-clean
	rm -fr .hypothesis .coverage .mypy_cache .pytest_cache
	rm -fr docs/_build

.PHONY: nuke-caches nuke
nuke-caches: clean
	find src/ -name __pycache__ -exec rm -fr {} +
	find tests/ -name __pycache__ -exec rm -fr {} +
nuke: nuke-caches
	if [ ! -z "${VIRTUAL_ENV}" ]; then echo "Nuking activated virtual environment!"; fi
	rm -fr src/package.egg-info
	rm -fr $(VIRTUAL_ENV)
