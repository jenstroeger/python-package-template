#! /usr/bin/env make -f
# This Makefile assumes an activated Python virtual environment.

# Make sure that Python's virtual environment is activated, and
# all tools are available.
ifndef VIRTUAL_ENV
  $(error Please activate the Python virtual environment)
endif

.PHONY:	all
all:	dist

dist:	dist/.dist
dist/.dist:
		python setup.py bdist
		python setup.py sdist
		touch dist/.dist

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
		cd docs && make html && cd ..

.PHONY:	clean
clean:
		rm -fr .hypothesis .coverage .mypy_cache .pytest_cache
		rm -fr dist/*.tar.gz dist/.dist docs/_build
		find src/ -name "__pycache__" -exec -fr {} +
		pre-commit clean
