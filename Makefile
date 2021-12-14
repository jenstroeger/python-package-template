#! /usr/bin/env make -f
# This Makefile assumes an activated Python virtual environment.

.PHONY:	all
all:	dist

dist:	dist/.dist
dist/.dist:
		python setup.py bdist
		python setup.py sdist
		touch dist/.dist

.PHONY:	check
check:
		pylint src/ tests/
		mypy src/ tests/
		tox

.PHONY:	clean
clean:
		rm -fr dist/*.tar.gz dist/.dist
