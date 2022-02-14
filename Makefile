#! /usr/bin/env make -f
# This Makefile assumes an activated Python virtual environment.

# Get the current version of this Python package.
PACKAGE_VERSION=$(shell python -c 'import package; print(package.__version__)')

# Make sure that Python's virtual environment is activated, and
# all tools are available.
ifndef VIRTUAL_ENV
  $(error Please activate the Python virtual environment)
endif

.PHONY:	all
all:	build

build:	dist
dist:	bdist_wheel sdist
bdist_wheel: dist/package-$(PACKAGE_VERSION)-py3-none-any.whl
dist/package-$(PACKAGE_VERSION)-py3-none-any.whl:
		python setup.py bdist_wheel
sdist:	dist/package-${PACKAGE_VERSION}.tar.gz
dist/package-$(PACKAGE_VERSION).tar.gz:
		python setup.py sdist

.PHONY:	quick-check check
quick-check:
		pre-commit run pylint --all-files
		pre-commit run mypy --all-files
check:
		pre-commit run --all-files

.PHONY: test
test:
		pre-commit run pytest --hook-stage push

.PHONY: docs
docs:	docs/_build/html/index.html
docs/_build/html/index.html:
		$(MAKE) -C docs/ html

.PHONY:	clean
clean:
		rm -fr .hypothesis .coverage .mypy_cache .pytest_cache
		rm -fr build/* dist/* docs/_build

.PHONY: nuke
nuke: clean
		find src/ -name __pycache__ -exec rm -fr {} +
		pre-commit clean
