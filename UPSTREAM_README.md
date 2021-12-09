![license](https://img.shields.io/badge/license-MIT-blue) [![pre-commit](https://img.shields.io/badge/pre--commit-enabled-yellow?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit) [![conventional-commits](https://img.shields.io/badge/conventional%20commits-1.0.0-yellow)](https://www.conventionalcommits.org/en/v1.0.0/) [![black](https://img.shields.io/badge/code%20style-black-000000)](https://github.com/psf/black) [![mypy](https://img.shields.io/badge/mypy-checked-brightgreen)](http://mypy-lang.org/) [![pylint](https://img.shields.io/badge/pylint-required%2010.0-brightgreen)](http://pylint.org/) [![pytest](https://img.shields.io/badge/pytest-enabled-brightgreen)](https://github.com/pytest-dev/pytest) [![coverage](https://img.shields.io/badge/coverage-required%20100%25-brightgreen)](https://github.com/nedbat/coveragepy) [![tox](https://img.shields.io/badge/tox-3.9,%203.10-brightgreen)](https://github.com/tox-dev/tox)

# Python Package Template

This repository is intended to be a base template, a cookiecutter for a new Python package project while keeping [PEP518](https://www.python.org/dev/peps/pep-0518/) in mind. Because it’s hosted on Github it already utilizes a few [Github Actions](https://docs.github.com/en/actions) that enforce repository-side checks for continuous integration and that implement a semantic release setup. And while this package is a starting point for a Python project with good engineering practices, it’s intended to be improved and added to in various ways — see the [Wiki](https://github.com/jenstroeger/python-package-template/wiki) for more suggestions.

## Features

The badges above give you an idea of what this project template provides. It’s work in progress, and I try to enable as much engineering goodness as is possible and is sensibly bearable using [git hooks](https://git-scm.com/docs/githooks) (see [below](#git-hooks)) and Github Actions.

### Typing

The package requires a minimum of [Python 3.9](https://www.python.org/downloads/release/python-390/) and supports [Python 3.10](https://www.python.org/downloads/release/python-3100/). All code requires comprehensive [typing](https://docs.python.org/3/library/typing.html). The [mypy](http://mypy-lang.org/) static type checker is invoked by a git hook and through a Github Action to enforce continuous type checks. Make sure to add type hints to your code or to use [stub files](https://mypy.readthedocs.io/en/stable/stubs.html) for types, to ensure that users of your package can `import` and type-check your code (see also [PEP 561](https://www.python.org/dev/peps/pep-0561/)).

### Quality Assurance

A number of git hooks are invoked before and after a commit, and before push. These hooks are all managed by the [pre-commit](https://pre-commit.com/) tool and enforce a number of [software quality assurance](https://en.wikipedia.org/wiki/Software_quality_assurance) measures (see [below](#git-hooks)).

### Unit testing

Comprehensive unit testing is enabled using [tox](https://github.com/tox-dev/tox), and [pytest](https://pytest.org/) combined with [Hypothesis](https://hypothesis.works/) (to generate test payloads and strategies), and test code coverage is measured using [coverage](https://github.com/nedbat/coveragepy) (see [below](#testing)).

### Documentation

Documentation is important, and [Sphinx](https://www.sphinx-doc.org/en/master/) is set up already to produce standard documentation for the package, assuming that code contains [docstrings with reStructuredText](https://www.python.org/dev/peps/pep-0287/) (see [below](#documentation)).

### Versioning and publishing

Automatic package versioning and tagging, publishing to [PyPI](https://pypi.org/), and [Changelog](https://en.wikipedia.org/wiki/Changelog) generation are enabled using Github Actions (see [below](#versioning-publishing-and-changelog)).

### Dependency Analysis

[Dependabot](https://docs.github.com/en/code-security/supply-chain-security/keeping-your-dependencies-updated-automatically/about-dependabot-version-updates) is enabled to scan the dependencies and automatically create pull requests when an updated version is available.

### Standalone

In addition to being an importable standard Python package, the package is also set up to be used as a runnable and standalone package using Python’s [-m](https://docs.python.org/3/using/cmdline.html#cmdoption-m) command-line option.

## How to use this repository

If you’d like to contribute to the project template, please open an issue for discussion or submit a pull request.

If you’d like to start your own Python project from scratch, you can either copy the content of this repository into your new project folder or fork this repository. Either way, consider making the following adjustments to your copy:

- Change the `LICENSE.md` file and the license badge according to your needs, replace the [symbolic link](https://en.wikipedia.org/wiki/Symbolic_link) `README.md` with an actual README file, and similarly replace the symbolic link `CHANGELOG.md` with an actual CHANGELOG file which contains a single line:

  ```markdown
  <!--next-version-placeholder-->
  ```

- Install [pre-commit](https://pre-commit.com/) and set it up for your new package repository to ensure that all git hooks are active:

  ```bash
  pre-commit install
  pre-commit install --hook-type commit-msg
  pre-commit install --hook-type pre-push
  ```

- Rename the `src/package/` folder to whatever your own package’s name will be, and adjust the Github Actions in `.github/workflows/`, `setup.py`, `pyproject.toml`, `pre-commit-config.yaml` and the unit tests accordingly.

- Adjust the content of the `setup.py` file according to your needs, and make sure to fill in the project URL, maintainer and author information too. Don’t forget to reset the package’s version number in `src/package/__init__.py`.

- If you import packages that do not provide type hints into your new repository, then `mypy` needs to be configured accordingly: add these packages to the `mypy.ini` file using the [`ignore-missing-imports`](https://mypy.readthedocs.io/en/stable/config_file.html#confval-ignore_missing_imports) option.

- If you’d like to publish your package to PyPI then set the `upload_to_pypi` variable in the `pyproject.toml` file to `true`.

To develop your new package, create a [virtual environment](https://docs.python.org/3/tutorial/venv.html) and install its `dev`,  `test` and `docs` dependencies:
```bash
python3.10 -m venv .
source ./bin/activate
pip install --upgrade pip
pip install --editable .[dev,test,docs]
```

With that in place, you’re ready to build your own package.

## Git hooks

Using the pre-commit tool and its `.pre-commit-config.yaml` configuration, the following git hooks are active in this repository:

- When committing code, a number of [pre-commit hooks](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks#_committing_workflow_hooks) ensure that your code is formatted according to [PEP 8](https://www.python.org/dev/peps/pep-0008/) using the [`black`](https://github.com/psf/black) tool, and they’ll invoke [`flake8`](https://github.com/PyCQA/flake8) (and various plugins), [`pylint`](https://github.com/PyCQA/pylint) and [`mypy`](https://github.com/python/mypy) to check for lint and correct types. There are more checks, but those two are the important ones. You can adjust the settings for these tools in one of the `pyproject.toml` or `tox.ini` or `pylintrc` or `mypy.ini` configuration files.
- The [commit message hook](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks#_committing_workflow_hooks) enforces [conventional commit messages](https://www.conventionalcommits.org/) and that, in turn, enables a _semantic release_ of this package on the Github side: upon merging changes into the `master` branch, the [semantic release action](https://github.com/relekang/python-semantic-release) produces a [changelog](https://en.wikipedia.org/wiki/Changelog) and computes the next version of this package and publishes a release — all based on the commit messages.
- Using a [pre-push hook](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks#_other_client_hooks) this package is also set up to run [`pytest`](https://github.com/pytest-dev/pytest); in addition, the [`coverage`](https://github.com/nedbat/coveragepy) plugin makes sure that _all_ of your package’s code is covered by tests and [Hypothesis](https://hypothesis.works/) is already installed to help with generating test payloads.

## Testing

As mentioned above, this repository is set up to use [tox](https://github.com/tox-dev/tox) and [pytest](https://pytest.org/) either standalone or as a pre-push git hook. Tests are stored in the `tests/` folder, and you can run them manually like so:
```bash
tox
```
which runs all tests in both Python 3.9 and Python 3.10 environments:

```
...
_____________________________ summary _____________________________
  py39: commands succeeded
  py310: commands succeeded
  congratulations :)
```

For more options, see the [tox command-line flags](https://tox.wiki/en/latest/config.html#tox) and the [pytest command-line flags](https://docs.pytest.org/en/6.2.x/reference.html#command-line-flags). Also note that pytest includes [doctest](https://docs.python.org/3/library/doctest.html), which means that module and function [docstrings](https://www.python.org/dev/peps/pep-0257/#what-is-a-docstring) may contain test code that executes as part of the unit tests.

Test code coverage is already tracked using [coverage](https://github.com/nedbat/coveragepy) and the [pytest-cov](https://github.com/pytest-dev/pytest-cov) plugin for pytest. Code coverage is tracked automatically when running tox; in addition, the plugin can be explicitly invoked with the following command line:
```bash
pytest --cov package tests
```
and measures how much code in the `src/package/` folder is covered by tests:
```
============================= test session starts =============================
platform darwin -- Python 3.10.0, pytest-6.2.5, py-1.10.0, pluggy-1.0.0 -- ...
cachedir: .pytest_cache
hypothesis profile 'default' -> database=DirectoryBasedExampleDatabase('/.../.hypothesis/examples')
rootdir: /.../python-package-template, configfile: pyproject.toml, testpaths: tests
plugins: hypothesis-6.24.2, cov-3.0.0
collected 1 item  

tests/test_something.py::test_something PASSED                           [100%]

---------- coverage: platform darwin, python 3.10.0-final-0 -----------
Name                   Stmts   Miss  Cover   Missing
----------------------------------------------------
package/__init__.py        1      0   100%
package/something.py       4      0   100%
----------------------------------------------------
TOTAL                      5      0   100%

Required test coverage of 100.0% reached. Total coverage: 100.00%

============================== 1 passed in 0.07s ==============================
```
Note that code that’s not covered by tests is listed under the `Missing` column.

Hypothesis is a package that implements [property based testing](https://en.wikipedia.org/wiki/QuickCheck) and that provides payload generation for your tests based on strategy descriptions ([more](https://hypothesis.works/#what-is-hypothesis)). Using its [pytest plugin](https://hypothesis.readthedocs.io/en/latest/details.html#the-hypothesis-pytest-plugin) Hypothesis is ready to be used for this package.

## Documentation

As mentioned above, all package code should make use of [Python docstrings](https://www.python.org/dev/peps/pep-0257/) in [reStructured text format](https://www.python.org/dev/peps/pep-0287/). Using these docstrings and the documentation template in the `docs/source/` folder, you can then generate proper documentation in different formats using the [Sphinx](https://github.com/sphinx-doc/sphinx/) tool:

```bash
cd docs
make html
```

This example generates documentation in HTML, which can then be found here:

```bash
open _build/html/index.html
```

## Versioning, publishing and changelog

To enable automation for versioning, package publishing, and changelog generation it is important to use meaningful [conventional commit messages](https://www.conventionalcommits.org/)! This package template already has a [semantic release Github Action](https://github.com/relekang/python-semantic-release) enabled which is set up to take care of all three of these aspects — every time changes are merged into the `master` branch.

For more configuration options, please refer to the `tool.semantic_release` section in the `pyproject.toml` file, and read the [semantic release documentation](https://python-semantic-release.readthedocs.io/en/latest/).

You can also install and run the tool manually, for example:

```bash
pip install python-semantic-release
semantic-release changelog
semantic-release version
```

Use the `--verbosity=DEBUG` command-line argument for more details.
