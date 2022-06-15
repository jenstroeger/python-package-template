![license](https://img.shields.io/badge/license-MIT-blue) [![pre-commit](https://img.shields.io/badge/pre--commit-enabled-yellow?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit) [![conventional-commits](https://img.shields.io/badge/conventional%20commits-1.0.0-yellow)](https://www.conventionalcommits.org/en/v1.0.0/) [![black](https://img.shields.io/badge/code%20style-black-000000)](https://github.com/psf/black) [![mypy](https://img.shields.io/badge/mypy-checked-brightgreen)](http://mypy-lang.org/) [![pylint](https://img.shields.io/badge/pylint-required%2010.0-brightgreen)](http://pylint.org/) [![pytest](https://img.shields.io/badge/pytest-enabled-brightgreen)](https://github.com/pytest-dev/pytest) [![coverage](https://img.shields.io/badge/coverage-required%20100%25-brightgreen)](https://github.com/nedbat/coveragepy) [![hypothesis](https://img.shields.io/badge/hypothesis-tested-brightgreen.svg)](https://hypothesis.readthedocs.io/)

# Python Package Template

This repository is intended to be a base template, a cookiecutter for a new Python package project while keeping [PEP518](https://www.python.org/dev/peps/pep-0518/) in mind. Because it’s hosted on Github it already utilizes a few [Github Actions](https://docs.github.com/en/actions) that enforce repository-side checks for continuous integration and that implement a semantic release setup. And while this package is a starting point for a Python project with good engineering practices, it’s intended to be improved and added to in various ways — see the [Wiki](https://github.com/jenstroeger/python-package-template/wiki) for more suggestions.

## Table of Contents

[Features](#features)  
&emsp;[Typing](#typing)  
&emsp;[Quality assurance](#quality-assurance)  
&emsp;[Unit testing](#unit-testing)  
&emsp;[Documentation](#documentation)  
&emsp;[Versioning and publishing](#versioning-and-publishing)  
&emsp;[Dependency analysis](#dependency-analysis)  
&emsp;[Security analysis](#security-analysis)  
&emsp;[Package or application?](#package-or-application)  
[How to use this repository](#how-to-use-this-repository)  
[Updating dependent packages](#updating-dependent-packages)  
[Git hooks](#git-hooks)  
[Testing](#testing)  
[Generating documentation](#generating-documentation)  
[Versioning, publishing and changelog](#versioning-publishing-and-changelog)  
[Cleaning up](#cleaning-up)  
[Frequently asked questions](#frequently-asked-questions)  

## Features

The badges above give you an idea of what this project template provides. It’s work in progress, and I try to enable as much engineering goodness as is possible and is sensibly bearable using [git hooks](https://git-scm.com/docs/githooks) (see [below](#git-hooks)) and Github Actions.

### Typing

The package requires a minimum of [Python 3.9](https://www.python.org/downloads/release/python-390/) and supports [Python 3.10](https://www.python.org/downloads/release/python-3100/) as well as [Python 3.11](https://www.python.org/downloads/release/python-3110a6/). All code requires comprehensive [typing](https://docs.python.org/3/library/typing.html). The [mypy](http://mypy-lang.org/) static type checker is invoked by a git hook and through a Github Action to enforce continuous type checks. Make sure to add type hints to your code or to use [stub files](https://mypy.readthedocs.io/en/stable/stubs.html) for types, to ensure that users of your package can `import` and type-check your code (see also [PEP 561](https://www.python.org/dev/peps/pep-0561/)).

### Quality assurance

A number of git hooks are invoked before and after a commit, and before push. These hooks are all managed by the [pre-commit](https://pre-commit.com/) tool and enforce a number of [software quality assurance](https://en.wikipedia.org/wiki/Software_quality_assurance) measures (see [below](#git-hooks)).

### Unit testing

Comprehensive unit testing is enabled using [pytest](https://pytest.org/) combined with [Hypothesis](https://hypothesis.works/) (to generate test payloads and strategies), and test code coverage is measured using [coverage](https://github.com/nedbat/coveragepy) (see [below](#testing)).

### Documentation

Documentation is important, and [Sphinx](https://www.sphinx-doc.org/en/master/) is set up already to produce standard documentation for the package, assuming that code contains [docstrings with reStructuredText](https://www.python.org/dev/peps/pep-0287/) (see [below](#documentation)).

### Versioning and publishing

Automatic package versioning and tagging, publishing to [PyPI](https://pypi.org/), and [Changelog](https://en.wikipedia.org/wiki/Changelog) generation are enabled using Github Actions. Furthermore, an optional [Release Notification](https://github.com/jenstroeger/python-package-template/tree/main/.github/workflows/release-notifications.yaml) Action allows Github to push an update notification to a [Slack bot](https://api.slack.com/bot-users) of your choice. For setup instructions, please see [below](#versioning-publishing-and-changelog).

### Dependency analysis

[Dependabot](https://docs.github.com/en/code-security/supply-chain-security/keeping-your-dependencies-updated-automatically/about-dependabot-version-updates) is enabled to scan the dependencies and automatically create pull requests when an updated version is available.

### Security analysis

[CodeQL](https://codeql.github.com/) is enabled to scan the Python code for security vulnerabilities. You can adjust the GitHub Actions workflow at `.github/workflows/codeql-analysis.yaml` and the configuration file at `.github/codeql/codeql-config.yaml` to add more languages, change the default paths, scan schedule, and queries.

[OSSF Security Scorecards](https://github.com/ossf/scorecard) is enabled as a GitHub Actions workflow to give the consumers information about the supply-chain security posture of this project, assigning a score of 0–10. We upload the results as a SARIF (Static Analysis Results Interchange Format) artifact after each run and the results can be found at the Security tab of this GitHub project. We also allow publishing the data at [OpenSSF](https://metrics.openssf.org/). We use this data to continuously improve the security posture of this project. Note that this configuration supports the ``main`` (default) branch and requires the repository to be public and not forked.

### Package or application?

A _shared package_ or library is intended to be imported by another package or application; an _application_ is a self-contained, standalone, runnable package. Unfortunately, Python’s packaging ecosystem is mostly focused on packaging shared packages (libraries), and packaging Python applications is not as well-supported ([discussion](https://discuss.python.org/t/help-packaging-optional-application-features-using-extras/14074/7)). This template, however, supports both scenarios.

**Shared package**: this template works out of the box as a shared package. Direct dependencies on other packages are declared in `pyproject.toml` (see the [`dependencies`](https://flit.pypa.io/en/latest/pyproject_toml.html#dependencies) field) and should allow for as wide a version range as possible to ensure that this package and its dependencies can be installed by and coexist with other packages and applications without version conflicts.

**Application**: the [`__main__.py`](https://docs.python.org/3/library/__main__.html#main-py-in-python-packages) file ensures an entry point to run this package as a standalone application using Python’s [-m](https://docs.python.org/3/using/cmdline.html#cmdoption-m) command-line option. A wrapper script named `something` is also generated as an [entry point into this package](https://flit.pypa.io/en/latest/pyproject_toml.html#scripts-section) by `make setup` or `make upgrade`. In addition to specifying directly dependent packages and their version ranges in `pyproject.toml`, an application should _pin_ its entire environment using the [`requirements.txt`](https://pip.pypa.io/en/latest/user_guide/#requirements-files). Use the `make requirements` command to generate that file if you’re building an application.

In the future, the generated `requirements.txt` file with its integrity hash for every dependent package will become an important provenance material to provide transparency in the packaging process (see also [SBOM + SLSA](https://slsa.dev/blog/2022/05/slsa-sbom)).

## How to use this repository

If you’d like to contribute to the project template, please open an issue for discussion or submit a pull request.

If you’d like to start your own Python project from scratch, you can either copy the content of this repository into your new project folder or fork this repository. Either way, consider making the following adjustments to your local copy:

- Change the `LICENSE.md` file and the license badge according to your needs, replace the [symbolic link](https://en.wikipedia.org/wiki/Symbolic_link) `README.md` with an actual README file, likewise replace the symbolic link `SECURITY.md` with a SECURITY file adjusted to your needs (more details [here](https://docs.github.com/en/code-security/getting-started/adding-a-security-policy-to-your-repository)), and lastly replace the symbolic link `CHANGELOG.md` with an actual CHANGELOG file which contains a single line:

  ```markdown
  <!--next-version-placeholder-->
  ```

- Rename the `src/package/` folder to whatever your own package’s name will be, adjust the Github Actions in `.github/workflows/`, and review the `Makefile`, `pyproject.toml`, `pre-commit-config.yaml` files as well as the unit tests accordingly. **Note**: by default all Actions run on three different host types (Linux, MacOS, and Windows) whose [rates vary widely](https://docs.github.com/en/billing/managing-billing-for-github-actions/about-billing-for-github-actions#minute-multipliers), so make sure that you disable or budget accordingly if you’re in a private repository!

- Adjust the content of the `pyproject.toml` file according to your needs, and make sure to fill in the project URL, maintainer and author information too. Don’t forget to reset the package’s version number in `src/package/__init__.py`.

- If you import packages that do not provide type hints into your new repository, then `mypy` needs to be configured accordingly: add these packages to the `pyproject.toml` file using the [`ignore_missing_imports`](https://mypy.readthedocs.io/en/stable/config_file.html#confval-ignore_missing_imports) option.

- If you’d like to publish your package to PyPI then set the `upload_to_pypi` variable in the `pyproject.toml` file to `true`.

- Adjust the Dependabot settings in `.github/dependabot.yaml` to your desired target branch that you’d like to have monitored by Dependabot.

To develop your new package, first create a [virtual environment](https://docs.python.org/3/tutorial/venv.html) by either using the [Makefile](https://www.gnu.org/software/make/manual/make.html#toc-An-Introduction-to-Makefiles):

```bash
make venv  # Create a new virtual environment in .venv folder using Python 3.10.
```

or for a specific version of Python:

```bash
PYTHON=python3.9 make venv  # Same virtual environment for a different Python version.
```

or manually:

```bash
python3.11 -m venv .venv  # Or use .venv310 for more than one local virtual environments.
```

When working with this Makefile _it is important to always [activate the virtual environment](https://docs.python.org/3/library/venv.html)_ because some of the [git hooks](#git-hooks) (see below) depend on that:

```bash
. .venv/bin/activate  # Where . is a bash shortcut for the source command.
```

Finally, set up the new package with all of its extras and initialize the local git hooks:

```bash
make setup
```

With that in place, you’re ready to build your own package!

## Updating dependent packages

It’s likely that during development you’ll add or update dependent packages in the `pyproject.toml` file, which requires an update to the virtual environment:

```bash
make upgrade
```

## Git hooks

Using the pre-commit tool and its `.pre-commit-config.yaml` configuration, the following git hooks are active in this repository:

- When committing code, a number of [pre-commit hooks](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks#_committing_workflow_hooks) ensure that your code is formatted according to [PEP 8](https://www.python.org/dev/peps/pep-0008/) using the [`black`](https://github.com/psf/black) tool, and they’ll invoke [`flake8`](https://github.com/PyCQA/flake8) (and various plugins), [`pylint`](https://github.com/PyCQA/pylint) and [`mypy`](https://github.com/python/mypy) to check for lint and correct types. There are more checks, but those two are the important ones. You can adjust the settings for these tools in the `pyproject.toml` or `.flake8` configuration files.
- The [commit message hook](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks#_committing_workflow_hooks) enforces [conventional commit messages](https://www.conventionalcommits.org/) and that, in turn, enables a _semantic release_ of this package on the Github side: upon merging changes into the `main` branch, the [semantic release action](https://github.com/relekang/python-semantic-release) produces a [changelog](https://en.wikipedia.org/wiki/Changelog) and computes the next version of this package and publishes a release — all based on the commit messages.
- Using a [pre-push hook](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks#_other_client_hooks) this package is also set up to run [`pytest`](https://github.com/pytest-dev/pytest); in addition, the [`coverage`](https://github.com/nedbat/coveragepy) plugin makes sure that _all_ of your package’s code is covered by tests and [Hypothesis](https://hypothesis.works/) is already installed to help with generating test payloads.

You can also run these hooks manually, which comes in very handy during daily development tasks. For example

```bash
make quick-check
```

runs `pylint` and `mypy` only, whereas

```bash
make check
```

runs _all_ installed git hooks over your code.

## Testing

As mentioned above, this repository is set up to use [pytest](https://pytest.org/) either standalone or as a pre-push git hook. Tests are stored in the `tests/` folder, and you can run them manually like so:
```bash
make test
```
which runs all tests in both your local Python virtual environment. For more options, see the [pytest command-line flags](https://docs.pytest.org/en/6.2.x/reference.html#command-line-flags). Also note that pytest includes [doctest](https://docs.python.org/3/library/doctest.html), which means that module and function [docstrings](https://www.python.org/dev/peps/pep-0257/#what-is-a-docstring) may contain test code that executes as part of the unit tests.

Test code coverage is already tracked using [coverage](https://github.com/nedbat/coveragepy) and the [pytest-cov](https://github.com/pytest-dev/pytest-cov) plugin for pytest, and it measures how much code in the `src/package/` folder is covered by tests:
```
Run unit tests...........................................................Passed
- hook id: pytest
- duration: 0.48s

============================= test session starts ==============================
platform darwin -- Python 3.10.2, pytest-6.2.5, py-1.11.0, pluggy-1.0.0 -- /.../python-package-template/.venv/bin/python3.10
cachedir: .pytest_cache
hypothesis profile 'default' -> database=DirectoryBasedExampleDatabase('/.../python-package-template/.hypothesis/examples')
rootdir: /.../python-package-template, configfile: pyproject.toml, testpaths: tests
plugins: hypothesis-6.41.0, cov-3.0.0
collected 1 item  

tests/test_something.py::test_something PASSED                           [100%]

---------- coverage: platform darwin, python 3.10.2-final-0 ----------
Name                       Stmts   Miss  Cover   Missing
--------------------------------------------------------
src/package/__init__.py        1      0   100%
src/package/something.py       4      0   100%
--------------------------------------------------------
TOTAL                          5      0   100%

Required test coverage of 100.0% reached. Total coverage: 100.00%

============================== 1 passed in 0.16s ===============================
```
Note that code that’s not covered by tests is listed under the `Missing` column. The net effect of enforcing 100% code coverage is that every new major and minor feature, every code change, and every fix are being tested (keeping in mind that _code coverage_ does not correlate with _test quality_).

Hypothesis is a package that implements [property based testing](https://en.wikipedia.org/wiki/QuickCheck) and that provides payload generation for your tests based on strategy descriptions ([more](https://hypothesis.works/#what-is-hypothesis)). Using its [pytest plugin](https://hypothesis.readthedocs.io/en/latest/details.html#the-hypothesis-pytest-plugin) Hypothesis is ready to be used for this package.

## Generating documentation

As mentioned above, all package code should make use of [Python docstrings](https://www.python.org/dev/peps/pep-0257/) in [reStructured text format](https://www.python.org/dev/peps/pep-0287/). Using these docstrings and the documentation template in the `docs/source/` folder, you can then generate proper documentation in different formats using the [Sphinx](https://github.com/sphinx-doc/sphinx/) tool:

```bash
make docs
```

This example generates documentation in HTML, which can then be found here:

```bash
open docs/_build/html/index.html
```

## Versioning, publishing and changelog

To enable automation for versioning, package publishing, and changelog generation it is important to use meaningful [conventional commit messages](https://www.conventionalcommits.org/)! This package template already has a [semantic release Github Action](https://github.com/relekang/python-semantic-release) enabled which is set up to take care of all three of these aspects — every time changes are merged into the `main` branch.

For more configuration options, please refer to the `tool.semantic_release` section in the `pyproject.toml` file, and read the [semantic release documentation](https://python-semantic-release.readthedocs.io/en/latest/).

You can also install and run the tool manually and locally, for example:

```bash
pip install python-semantic-release
semantic-release changelog
semantic-release version
```

Use the `--verbosity=DEBUG` command-line argument for more details.

If you’d like to receive Slack notifications whenever a new release is published, follow the comments in the [Release Notification](https://github.com/jenstroeger/python-package-template/tree/main/.github/workflows/release-notifications.yaml) Action and set up a Slack bot by following [the instructions here](https://github.com/slackapi/slack-github-action#setup-2).

In order to build a distribution of your package locally instead of publishing it through the Github Action, you can simply call:

```bash
make dist
```

This builds a source package and a binary distribution, and stores the files in your local `dist/` folder.

## Cleaning up

On occasion it’s useful (and perhaps necessary) to clean up stale files, caches that tools like `mypy` leave behind, or even to nuke the complete virtual environment:

- **Remove distribution artifacts**: `make dist-clean`
- In addition, **remove tool caches and documentation**: `make clean`
- In addition, **remove Python code caches and git hooks**: `make nuke-caches`
- In addition and to **reset everything**, to restore a clean package to start over fresh: `make nuke`

Please be careful when nuking your environment, and make sure you know what you’re doing.

## Frequently asked questions

- **Question**: Why don’t you use tools like [tox](https://github.com/tox-dev/tox) or [nox](https://github.com/theacodes/nox) to orchestrate testing?  
  **Answer**: We’ve removed `tox` based on a discussion in [issue #100](https://github.com/jenstroeger/python-package-template/issues/100) and [PR #102](https://github.com/jenstroeger/python-package-template/pull/102). In short: we want to run tests inside the development venv using `pytest`, and run more tests using an extensive test matrix using Github Actions.
