#! /usr/bin/env make -f

# If we set up the Python virtual environment initially then make sure that
# the variable 'PYTHON' is available, either its default or passed in by the
# user. Any other goal requires the Python virtual environment.
ifeq ($(MAKECMDGOALS),setup)
  ifndef PYTHON
    PYTHON=python3.10
    $(info No Python version specified, defaulting to $(PYTHON))
  endif
else
  ifeq ("$(wildcard .venv)","")
    $(error No Python environment found, use `make setup` first)
  else
    PACKAGE_VERSION=$(shell .venv/bin/python -c 'import package; print(package.__version__)')
  endif
endif

.PHONY: setup
setup:
	$(PYTHON) -m venv --upgrade-deps .venv
	. .venv/bin/activate && pip install --upgrade pip && pip install --editable .[hooks,dev,test,docs]
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

.PHONY: dist bdist_wheel sdist
dist: bdist_wheel sdist
bdist_wheel: .venv/dist/package-$(PACKAGE_VERSION)-py3-none-any.whl
.venv/dist/package-$(PACKAGE_VERSION)-py3-none-any.whl:
	. .venv/bin/activate && \
	python setup.py bdist_wheel --dist-dir .venv/dist/ --bdist-dir .venv/build
sdist: .venv/dist/package-$(PACKAGE_VERSION).tar.gz
.venv/dist/package-$(PACKAGE_VERSION).tar.gz:
	. .venv/bin/activate && \
	python setup.py sdist --dist-dir .venv/dist/

.PHONY: dist-clean clean
dist-clean:
	rm -fr .venv/build/* .venv/dist/*
clean: dist-clean
	rm -fr .hypothesis .coverage .mypy_cache .pytest_cache
	rm -fr docs/_build

.PHONY: docs
docs: docs/_build/html/index.html
docs/_build/html/index.html:
	. .venv/bin/activate && \
	$(MAKE) -C docs/ html

.PHONY: nuke-caches nuke
nuke-caches: clean
	find src/ -name __pycache__ -exec rm -fr {} +
	find tests/ -name __pycache__ -exec rm -fr {} +
	. .venv/bin/activate && pre-commit clean
nuke: nuke-caches
	. .venv/bin/activate && pre-commit uninstall
	rm -fr src/package.egg-info
	rm -fr .venv
