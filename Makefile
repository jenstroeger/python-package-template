#! /usr/bin/env make -f

# This variable contains the first goal that matches any of the listed goals
# here, else it contains an empty string. The net effect is to filter out
# whether this current run of `make` requires a Python virtual environment.
NEED_VENV := $(or \
  $(findstring all,$(MAKECMDGOALS)), \
  $(findstring quick-check,$(MAKECMDGOALS)), \
  $(findstring check,$(MAKECMDGOALS)), \
  $(findstring test,$(MAKECMDGOALS)), \
  $(findstring dist,$(MAKECMDGOALS)), \
  $(findstring bdist-wheel,$(MAKECMDGOALS)), \
  $(findstring sdist,$(MAKECMDGOALS)), \
  $(findstring docs,$(MAKECMDGOALS)) \
)
ifeq (,$(NEED_VENV))
  # None of the current goals requires a virtual environment.
else
  ifeq ($(wildcard .venv),)
    $(error No Python environment found, use `make setup` first)
  else
    PACKAGE_VERSION=$(shell .venv/bin/python -c 'import package; print(package.__version__)')
  endif
endif

.PHONY: setup
setup:
	if [[ -z "${PYTHON}" ]]; then \
	  python3.10 -m venv --upgrade-deps .venv; \
	else \
	  ${PYTHON} -m venv --upgrade-deps .venv; \
	fi
	. .venv/bin/activate && \
	pip install --upgrade pip && \
	pip install --editable .[hooks,dev,test,docs]
	. .venv/bin/activate && \
	pre-commit install && \
	pre-commit install --hook-type commit-msg && \
	pre-commit install --hook-type pre-push

.PHONY: all
all: check test dist docs

.PHONY: quick-check check
quick-check:
	. .venv/bin/activate && \
	pre-commit run pylint --all-files && \
	pre-commit run mypy --all-files
check:
	. .venv/bin/activate && \
	pre-commit run --all-files

.PHONY: test
test:
	. .venv/bin/activate && \
	pre-commit run pytest --hook-stage push

.PHONY: dist bdist-wheel sdist
dist: bdist-wheel sdist
bdist-wheel: .venv/dist/package-$(PACKAGE_VERSION)-py3-none-any.whl
.venv/dist/package-$(PACKAGE_VERSION)-py3-none-any.whl:
	. .venv/bin/activate && \
	python setup.py bdist_wheel --dist-dir .venv/dist/ --bdist-dir .venv/build
sdist: .venv/dist/package-$(PACKAGE_VERSION).tar.gz
.venv/dist/package-$(PACKAGE_VERSION).tar.gz:
	. .venv/bin/activate && \
	python setup.py sdist --dist-dir .venv/dist/

.PHONY: docs
docs: docs/_build/html/index.html
docs/_build/html/index.html:
	. .venv/bin/activate && \
	$(MAKE) -C docs/ html

.PHONY: dist-clean clean
dist-clean:
	rm -fr .venv/build/* .venv/dist/*
clean: dist-clean
	rm -fr .hypothesis .coverage .mypy_cache .pytest_cache
	rm -fr docs/_build

.PHONY: nuke-caches nuke
nuke-caches: clean
	find src/ -name __pycache__ -exec rm -fr {} +
	find tests/ -name __pycache__ -exec rm -fr {} +
	if [[ -f .venv/bin/pre-commit ]]; then . .venv/bin/activate && pre-commit clean; fi
nuke: nuke-caches
	if [[ -f .venv/bin/pre-commit ]]; then . .venv/bin/activate && pre-commit uninstall; fi
	rm -fr src/package.egg-info
	rm -fr .venv
