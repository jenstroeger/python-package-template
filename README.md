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
[Synchronizing with this template repo](#synchronizing-with-this-template-repo)  
[Versioning, publishing and changelog](#versioning-publishing-and-changelog)  
[Build integrity using SLSA framework](#build-integrity-using-slsa-framework)  
[Cleaning up](#cleaning-up)  
[Frequently asked questions](#frequently-asked-questions)  

## Features

The badges above give you an idea of what this project template provides. It’s work in progress, and I try to enable as much engineering goodness as is possible and is sensibly bearable using [git hooks](https://git-scm.com/docs/githooks) (see [below](#git-hooks)) and Github Actions.

### Typing

The package requires a minimum of [Python 3.10](https://www.python.org/downloads/release/python-31014/), and it supports [Python 3.11](https://www.python.org/downloads/release/python-3118/) and [Python 3.12](https://www.python.org/downloads/release/python-3121/) (default). All code requires comprehensive [typing](https://docs.python.org/3/library/typing.html). The [mypy](http://mypy-lang.org/) static type checker and the [flake8-pyi](https://github.com/PyCQA/flake8-pyi) plugin are invoked by git hooks and through a Github Action to enforce continuous type checks on Python source and [stub files](https://peps.python.org/pep-0484/#stub-files). Make sure to add type hints to your code or to use [stub files](https://mypy.readthedocs.io/en/stable/stubs.html) for types, to ensure that users of your package can `import` and type-check your code (see also [PEP 561](https://www.python.org/dev/peps/pep-0561/)).

### Quality assurance

A number of git hooks are invoked before and after a commit, and before push. These hooks are all managed by the [pre-commit](https://pre-commit.com/) tool and enforce a number of [software quality assurance](https://en.wikipedia.org/wiki/Software_quality_assurance) measures (see [below](#git-hooks)).

### Unit testing

Comprehensive unit testing is enabled using [pytest](https://pytest.org/) combined with [doctest](https://docs.python.org/3/library/doctest.html) and [Hypothesis](https://hypothesis.works/) (to support [property-based testing](https://en.wikipedia.org/wiki/Software_testing#Property_testing)), and both code and branch coverage are measured using [coverage](https://github.com/nedbat/coveragepy) (see [below](#testing)).

### Documentation

Documentation is important, and [Sphinx](https://www.sphinx-doc.org/en/master/) is already set up to produce standard documentation in HTML and Markdown formats for the package, assuming that code contains [docstrings with reStructuredText](https://www.python.org/dev/peps/pep-0287/); the generated Markdown documentation can also optionally be pushed to the repository’s Github Wiki (see [below](#generating-documentation)).

### Versioning and publishing

Automatic package versioning and tagging, publishing to [PyPI](https://pypi.org/), and [Changelog](https://en.wikipedia.org/wiki/Changelog) generation are enabled using Github Actions. Furthermore, an optional [Release Notification](https://github.com/jenstroeger/python-package-template/tree/main/.github/workflows/release-notifications.yaml) Action allows Github to push an update notification to a [Slack bot](https://api.slack.com/bot-users) of your choice. For setup instructions, please see [below](#versioning-publishing-and-changelog).

### Dependency analysis

[Dependabot](https://docs.github.com/en/code-security/supply-chain-security/keeping-your-dependencies-updated-automatically/about-dependabot-version-updates) is enabled to scan the dependencies and automatically create pull requests when an updated version is available.

### Security analysis

[CodeQL](https://codeql.github.com/) is enabled to scan the Python code for security vulnerabilities. You can adjust the GitHub Actions workflow at `.github/workflows/codeql-analysis.yaml` and the configuration file at `.github/codeql/codeql-config.yaml` to add more languages, change the default paths, scan schedule, and queries.

[OSSF Security Scorecards](https://github.com/ossf/scorecard) is enabled as a GitHub Actions workflow to give the consumers information about the supply-chain security posture of this project, assigning a score of 0–10. We upload the results as a SARIF (Static Analysis Results Interchange Format) artifact after each run and the results can be found at the Security tab of this GitHub project. We also allow publishing the data at [OpenSSF](https://metrics.openssf.org/). We use this data to continuously improve the security posture of this project. Note that this configuration supports the ``main`` (default) branch and requires the repository to be public and not forked.

[pip-audit](https://github.com/pypa/pip-audit) is part of the default Python virtual environment, and can be used to check all installed packages for documented [CVE](https://www.cve.org/) by querying the [Python Packaging Advisory Database](https://github.com/pypa/advisory-database). The `_build.yaml` workflow always runs a package audit before the artifacts are being built. In automated production environments it _may_, on rare occasions, be necessary to suspend package auditing in which case  you can [add a repository variable](https://docs.github.com/en/actions/learn-github-actions/variables#creating-configuration-variables-for-a-repository) `DISABLE_PIP_AUDIT` with value `true` to your repository to explicitly disable running pip-audit.

### Package or application?

A _shared package_ or library is intended to be imported by another package or application; an _application_ is a self-contained, standalone, runnable package. Unfortunately, Python’s packaging ecosystem is mostly focused on packaging shared packages (libraries), and packaging Python applications is not as well-supported ([discussion](https://discuss.python.org/t/help-packaging-optional-application-features-using-extras/14074/7)). This template, however, supports both scenarios.

**Shared package**: this template works out of the box as a shared package. Direct dependencies on other packages are declared in `pyproject.toml` (see the [`dependencies`](https://flit.pypa.io/en/latest/pyproject_toml.html#dependencies) field) and should allow for as wide a version range as possible to ensure that this package and its dependencies can be installed by and coexist with other packages and applications without version conflicts.

**Application**: the [`__main__.py`](https://docs.python.org/3/library/__main__.html#main-py-in-python-packages) file ensures an entry point to run this package as a standalone application using Python’s [-m](https://docs.python.org/3/using/cmdline.html#cmdoption-m) command-line option. A wrapper script named `something` is also generated as an [entry point into this package](https://flit.pypa.io/en/latest/pyproject_toml.html#scripts-section) by `make setup` or `make upgrade`. In addition to specifying directly dependent packages and their version ranges in `pyproject.toml`, an application should _pin_ its entire environment using the [`requirements.txt`](https://pip.pypa.io/en/latest/user_guide/#requirements-files). Use the `make requirements` command to generate that file if you’re building an application.

The generated `requirements.txt` file with its integrity hash for every dependent package is used to generate a [Software Bill of Materials (SBOM)](https://www.cisa.gov/sbom) in [CycloneDX format](https://cyclonedx.org/). This is an important provenance material to provide transparency in the packaging process (see also [SBOM + SLSA](https://slsa.dev/blog/2022/05/slsa-sbom)). That `requirements.txt` file, in addition to the SBOM, is also stored as a build artifact for every package release.

## How to use this repository

If you’d like to contribute to the project template, please open an issue for discussion or submit a pull request.

If you’d like to start your own Python project from scratch, you can either copy the content of this repository into your new project folder or fork this repository. Either way, consider making the following adjustments to your local copy:

- Change the `LICENSE.md` file and the license badge according to your needs, and adjust the `SECURITY.md` file to your needs (more details [here](https://docs.github.com/en/code-security/getting-started/adding-a-security-policy-to-your-repository)). Remove all content from the `CHANGELOG.md` file.

- Rename the `src/package/` folder to whatever your own package’s name will be, adjust the Github Actions in `.github/workflows/`, and review the `Makefile`, `pyproject.toml`, `.pre-commit-config.yaml` files as well as the unit tests accordingly. **Note**: by default all Actions run on three different host types (Linux, MacOS, and Windows) whose [rates vary widely](https://docs.github.com/en/billing/managing-billing-for-github-actions/about-billing-for-github-actions#minute-multipliers), so make sure that you disable or budget accordingly if you’re in a private repository!

- Adjust the content of the `pyproject.toml` file according to your needs, and make sure to fill in the project URL, maintainer and author information too. Don’t forget to reset the package’s version number in `src/package/__init__.py`.

- If you import packages that do not provide type hints into your new repository, then `mypy` needs to be configured accordingly: add these packages to the `pyproject.toml` file using the [`ignore_missing_imports`](https://mypy.readthedocs.io/en/stable/config_file.html#confval-ignore_missing_imports) option.

- If you’d like to publish your package to PyPI then uncomment the code in the [`release.yaml`](https://github.com/jenstroeger/python-package-template/blob/main/.github/workflows/release.yaml) Action, and add the appropriate environment variables.

- Adjust the Dependabot settings in `.github/dependabot.yaml` to your desired target branch that you’d like to have monitored by Dependabot.

- Create the following [Personal Access Tokens](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) (PAT) with certain [scopes](https://docs.github.com/en/developers/apps/building-oauth-apps/scopes-for-oauth-apps#available-scopes) for your Github user account and then [create secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets#creating-encrypted-secrets-for-a-repository) for the new Github repository whose values are these new PATs:
  - one PAT with `workflow` and `repo` scope (including _all_ of the `repo` permissions) for the secret named `REPO_ACCESS_TOKEN`; this secret is used by the [Release Action](https://github.com/jenstroeger/python-package-template/blob/main/.github/workflows/release.yaml) to push the release commit and attach assets to the generated [Github release](https://github.com/jenstroeger/python-package-template/releases).
  - one PAT with `public_repo`, `read:discussion`, `read:org`, and `read:repo_hook` scopes ([detailed docs](https://github.com/ossf/scorecard-action#authentication-with-pat-optional)) for the secret named `SCORECARD_READ_TOKEN`; this secret is used by the [Scorecard Action](https://github.com/jenstroeger/python-package-template/blob/main/.github/workflows/scorecards-analysis.yaml) to analyze the code and add its results to your repository.
  - one PAT with `repo` scope for the secret named `DEPENDABOT_AUTOMERGE_TOKEN`; this secret is used by the [Dependabot Automerge Action](https://github.com/jenstroeger/python-package-template/blob/main/.github/workflows/dependabot-automerge.yaml) to comment on Dependabot PRs.
- Create a Wiki and a first empty Wiki page for your new repository. Using the [Wiki Documentation](https://github.com/jenstroeger/python-package-template/blob/main/.github/workflows/_wiki-documentation.yaml) Action the repository’s Wiki will be automatically updated as part of publishing a new release.

To develop your new package, first create a [virtual environment](https://docs.python.org/3/tutorial/venv.html) by either using the [Makefile](https://www.gnu.org/software/make/manual/make.html#toc-An-Introduction-to-Makefiles):

```bash
make venv  # Create a new virtual environment in .venv folder using Python 3.10.
```

or for a specific version of Python:

```bash
PYTHON=python3.10 make venv  # Same virtual environment for a different Python version.
```

or manually:

```bash
python3.12 -m venv .venv  # Or use .venv312 for more than one local virtual environments.
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
- The [commit message hook](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks#_committing_workflow_hooks) enforces [conventional commit messages](https://www.conventionalcommits.org/) and that, in turn, enables a _semantic release_ of this package on the Github side: upon merging changes into the `main` branch, the [release action](https://github.com/jenstroeger/python-package-template/blob/main/.github/workflows/release.yaml) uses the [Commitizen tool](https://commitizen-tools.github.io/commitizen/) to produce a [changelog](https://en.wikipedia.org/wiki/Changelog) and it computes the next version of this package and publishes a release — all based on the commit messages of a release.
- Using a [pre-push hook](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks#_other_client_hooks) this package is also set up to run [`pytest`](https://github.com/pytest-dev/pytest); in addition, the [`coverage`](https://github.com/nedbat/coveragepy) plugin makes sure that _all_ of your package’s code is covered by tests and [Hypothesis](https://hypothesis.works/) is already installed to help with generating test payloads.
- The [`actionlint`](https://github.com/Mateusz-Grzelinski/actionlint-py) hook is set up to lint GitHub Actions workflows. If [`shellcheck`](https://github.com/koalaman/shellcheck) is installed on the system, `actionlint` runs `shellcheck` to lint the `run` steps in GitHub Actions. Note that `shellcheck` is available on [Ubuntu GitHub Actions runners](https://github.com/actions/runner-images/blob/main/images/linux/Ubuntu2204-Readme.md) by default.

You can also run these hooks manually, which comes in very handy during daily development tasks. For example

```bash
make check-code
```

runs all the code checks (i.e. `bandit`, `flake8`, `pylint`, `mypy`, `actionlint`), whereas

```bash
make check
```

runs _all_ installed git hooks over your code. For more control over the code checks, the Makefile also implements the `check-bandit`, `check-flake8`, `check-lint`, `check-mypy`, and `check-actionlint` goals.

## Testing

As mentioned above, this repository is set up to use [pytest](https://pytest.org/) either standalone or as a pre-push git hook. Tests are stored in the `tests/` folder, and you can run them manually like so:
```bash
make test
```
which runs all tests in both your local Python virtual environment. For more options, see the [pytest command-line flags](https://docs.pytest.org/en/7.4.x/reference/reference.html#command-line-flags). Also note that pytest includes [doctest](https://docs.python.org/3/library/doctest.html), which means that module and function [docstrings](https://www.python.org/dev/peps/pep-0257/#what-is-a-docstring), as well as the documentation, may contain test code that executes as part of the unit tests.

Both statement and branch coverage are being tracked using [coverage](https://github.com/nedbat/coveragepy) and the [pytest-cov](https://github.com/pytest-dev/pytest-cov) plugin for pytest, and it measures how much code in the `src/package/` folder is covered by tests:
```
Run unit tests...........................................................Passed
- hook id: pytest
- duration: 0.6s

============================= test session starts ==============================
platform darwin -- Python 3.11.7, pytest-7.4.4, pluggy-1.3.0 -- /path/to/python-package-template/.venv/bin/python
cachedir: .pytest_cache
hypothesis profile 'default-with-verbose-verbosity-with-explain-phase' -> max_examples=500, verbosity=Verbosity.verbose, phases=(Phase.explicit, Phase.reuse, Phase.generate, Phase.target, Phase.shrink, Phase.explain), database=DirectoryBasedExampleDatabase('/path/to/python-package-template/.hypothesis/examples')
rootdir: /path/to/python-package-template
configfile: pyproject.toml
plugins: custom-exit-code-0.3.0, cov-4.1.0, doctestplus-1.1.0, hypothesis-6.90.0, env-1.1.1
collected 3 items

src/package/something.py::package.something.Something.do_something PASSED [ 33%]
tests/test_something.py::test_something PASSED                            [ 66%]
docs/source/index.rst::index.rst PASSED                                   [100%]

---------- coverage: platform darwin, python 3.11.7-final-0 ----------
Name                       Stmts   Miss Branch BrPart  Cover   Missing
----------------------------------------------------------------------
src/package/__init__.py        1      0      0      0   100%
src/package/something.py       4      0      2      0   100%
----------------------------------------------------------------------
TOTAL                          5      0      2      0   100%

Required test coverage of 100.0% reached. Total coverage: 100.00%
============================ Hypothesis Statistics =============================

tests/test_something.py::test_something:

  - during reuse phase (0.00 seconds):
    - Typical runtimes: < 1ms, of which < 1ms in data generation
    - 1 passing examples, 0 failing examples, 0 invalid examples

  - during generate phase (0.00 seconds):
    - Typical runtimes: < 1ms, of which < 1ms in data generation
    - 1 passing examples, 0 failing examples, 0 invalid examples

  - Stopped because nothing left to do

============================== 3 passed in 0.05s ===============================
```
Note that code that’s not covered by tests is listed under the `Missing` column, and branches not taken too. The net effect of enforcing 100% code and branch coverage is that every new major and minor feature, every code change, and every fix are being tested (keeping in mind that high _coverage_ does not imply comprehensive, meaningful _test data_).

Hypothesis is a package that implements [property based testing](https://en.wikipedia.org/wiki/Software_testing#Property_testing) and that provides payload generation for your tests based on strategy descriptions ([more](https://hypothesis.works/#what-is-hypothesis)). Using its [pytest plugin](https://hypothesis.readthedocs.io/en/latest/details.html#the-hypothesis-pytest-plugin) Hypothesis is ready to be used for this package.

## Generating documentation

As mentioned above, all package code should make use of [Python docstrings](https://www.python.org/dev/peps/pep-0257/) in [reStructured text format](https://www.python.org/dev/peps/pep-0287/). Using these docstrings and the documentation template in the `docs/source/` folder, you can then generate proper documentation in different formats using the [Sphinx](https://github.com/sphinx-doc/sphinx/) tool:

```bash
make docs
```

This example generates documentation in HTML, which can then be found here:

```bash
open docs/_build/html/index.html
```

In addition to the default HTML, Sphinx also generates Markdown documentation compatible with [Github Wiki](https://docs.github.com/en/communities/documenting-your-project-with-wikis), and the [Wiki Documentation](https://github.com/jenstroeger/python-package-template/blob/main/.github/workflows/_wiki-documentation.yaml) Action automatically updates the project repository’s Wiki.

## Synchronizing with this template repo

The [sync-with-upstream.yaml](https://github.com/jenstroeger/python-package-template/blob/main/.github/workflows/sync-with-upstream.yaml) GitHub Acions workflow checks this template repo daily and automatically creates a pull request in the downstream repo if there is a new release. Make sure to set up the GitHub username and email address in this workflow accordingly.

## Versioning, publishing and changelog

To enable automation for [semantic versioning](https://semver.org/), package publishing, and changelog generation it is important to use meaningful [conventional commit messages](https://www.conventionalcommits.org/)! This package template already has a built-in semantic release support enabled which is set up to take care of all three of these aspects — every time changes are pushed to the `main` branch.

With every package release, a new `bump:` commit is pushed to the `main` branch and tagged with the package’s new version. In addition, the `staging` branch (which this repository uses to stage merged pull requests into for the next release) is rebased on top of the updated `main` branch automatically, so that subsequent pull requests can be merged while keeping a [linear history](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches#require-linear-history).

If you’d like to receive Slack notifications whenever a new release is published, follow the comments in the [Release Notification](https://github.com/jenstroeger/python-package-template/tree/main/.github/workflows/_release-notifications.yaml) Action and set up a Slack bot by following [the instructions here](https://github.com/slackapi/slack-github-action#setup-2).

In order to build a distribution of your package locally instead of publishing it through the Github Actions workflow, you can simply call:

```bash
make dist
```

This builds a source package and a binary distribution, and stores the files in your local `dist/` folder.

You can also generate a changelog and bump the version manually and locally using commitizen (already installed as a dev dependency), for example:

```bash
cz changelog
cz bump
```

## Build integrity using SLSA framework

The build process in this repository follows the requirements in the [SLSA framework](https://slsa.dev/) to be compliant at level 3. An important aspect of SLSA to improve the supply chain security posture is to generate a verifiable provenance for the build pipeline. Such a provenance can be used to verify the builder and let the consumers check the materials and configurations used while building an artifact. In this repository we use the [generic provenance generator reusable workflow](https://github.com/slsa-framework/slsa-github-generator) to generate a provenance that can attest to the following artifacts in every release:

- Binary dist (wheel)
- Source dist (tarball)
- SBOM (CycloneDx format)
- HTML and Markdown Docs
- A [UNIX epoch](https://en.wikipedia.org/wiki/Unix_time) timestamp file of the build time for [reproducible builds](https://reproducible-builds.org/)

To verify the artifact using the provenance follow the instructions in the [SLSA verifier](https://github.com/slsa-framework/slsa-verifier) project to install the verifier tool. After downloading the artifacts and provenance, verify each artifact individually, e.g.,:

```bash
slsa-verifier -artifact-path  ~/Downloads/package-2.2.0.tar.gz -provenance attestation.intoto.jsonl -source github.com/jenstroeger/python-package-template
```
Which should pass and provide the verification details.

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
