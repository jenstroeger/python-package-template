This project follows the [semantic versioning](https://packaging.python.org/en/latest/discussions/versioning/#semantic-versioning-vs-calendar-versioning) and [pre-release versioning](https://packaging.python.org/en/latest/discussions/versioning/) schemes recommended by the Python Packaging Authority [here](https://packaging.python.org/en/latest/specifications/version-specifiers/).

## v2.13.0 (2024-05-14)

### Feat

- add support for Python 3.12 (#632)

## v2.12.1 (2024-01-23)

### Fix

- **deps-dev**: revert artifact download and upload GitHub Actions to v3 (#686)

## v2.12.0 (2024-01-20)

### Feat

- **ci**: switch from building the SLSA provenance generator to using the pre-built version to improve runtime performance (#667)
- require pylint v3 and add a slew of optional plugins (#658)
- run doctest as part of running tests, which collects doctests from both the package’s doc strings and the package documentation (#637)
- add perflint to find performance anti-patterns (#675)

### Fix

- **ci**: workflow that syncs a repository with this template had multiple problems on patch generation and pushing; also, it can now be triggered via Github UI (#670)
- always fail tests when runtime warnings were raised (#668)
- change git hook to check for large files on commit, instead of push (#664)

## v2.11.0 (2023-11-22)

### Feat

- improve, clean up, and stricten the mypy configuration (#641)
- treat Sphinx docs warnings as errors (#648)
- enable Python’s “Development Mode” when running tests to enable resource tracking and add more warnings (#643)
- add flake8-logging plugin to ensure module-level logging is being used correctly (#640)

## v2.10.1 (2023-09-02)

### Fix

- **ci**: improve automatic template synchronization (#537)

### Refactor

- **docs**: switch to sphinx-markdown-builder package (#585)

## v2.10.0 (2023-07-22)

### Feat

- **ci**: use a Github Repository Variable `DISABLE_PIP_AUDIT` to control running `pip-audit` in CI (#551)

### Fix

- **test**: fail pytest if an unraisable/unhandled thread exception was detected during the execution of a test (#576)
- **deps**: temporarily pin typing-extensions deps, to avoid breaking the sphinxnotes-markdown-builder package (#552)

## v2.9.0 (2023-05-21)

### Feat

- **ci**: add a Rebase Branch workflow to rebase staging on top of main after a package was published (#536)
- add actionlint hook and fix current errors (#505)
- add flake8-pyi plugin to check .pyi files (if any) (#512)
- add CODEOWNERS file to the repository (#511)

### Fix

- make Black, Flake8, Sphinx play nice together by tweaking a few Flake8 settings (#479)
- **ci**: add docs/source/ folder to the excludes of the Sync Upstream workflow (#482)
- **ci**: ensure correct epoch for packaged files to enable reproducible builds (#487)
- **test**: make pytest a little more verbose when tests fail (#495)

## v2.8.0 (2023-02-20)

### Feat

- add a workflow to create sync PRs (#444)
- add flake8-print plugin to the flake8 git pre-commit hook (#473)

### Fix

- **docs**: update OSSF Scorecard URL (#468)
- **ci**: update isort to latest fix because of PyCQA/isort/issues/2077 (#455)
- update project URLs in the package metadata

### Refactor

- **test**: configure warnings for pytest through pyproject.toml only (#436)

## v2.7.0 (2022-12-28)

### Feat

- add workflow to publish code documentation to the Github Wiki upon package releases (#396)

### Fix

- **ci**: don’t fail bump job if there are no commits to bump (#428)
- line-length checks are now a bit more tolerant using Bugbear only (#410)

## v2.6.0 (2022-12-01)

### Feat

- add .gitattributes file (#407)

## v2.5.0 (2022-11-30)

### Feat

- add more default settings for VSCode (#388)
- automatically merge Dependabot PRs on approval (#390)

### Fix

- **ci**: make Release Notification a reusable workflow to avoid artifact race (#398)
- determine package version gracefully, even for a deactivated venv (#387)
- **ci**: update deprecated SLSA provenance generator, again (#394)
- incorrect folder name for pytest (#376)
- don’t nuke an activated virtual environment (#367)

## v2.4.2 (2022-10-29)

### Fix

- **ci**: as of v2 Scorecard requires extra permissions (#366)

## v2.4.1 (2022-10-28)

### Fix

- **ci**: trigger PR actions for all target branches (#357)
- **ci**: fix actionlint warnings (#348)
- run pytest hook on unstaged files (#347)
- determine an activated venv correctly when running make (#346)
- exit Makefile gracefully if an inactive venv was found (#345)
- **ci**: use GITHUB_OUTPUT instead of deprecated set-output (#358)
- **ci**: change deprecated SLSA attestation-name to provenance-name (#359)
- **ci**: update pytest to drop dependency on vulnerable py package (#354)
- don’t build the package again if a PR was only edited (#336)
- the ‘upgrade-quiet’ Makefile goal now works with BSD date command too (#335)
- a Makefile’s SHELL variable is not an executable shebang (#329)
- use simple expansion consistently for all Makefile variables (#328)
- explicitly specify flake8 configuration for git hooks (#327)
- **docs**: update README with correct CHANGELOG setup instructions (#320)

### Refactor

- **ci**: allow release when provenance generation fails (#342)

## v2.4.0 (2022-09-08)

### Feat

- add git-audit support when building the package artifacts (#307)

### Fix

- **ci**: fix triggering event for the Release Notification action (#317)
- remove trailing CR-LF from package spec when building requirements (#316)
- remove requirements.txt when cleaning the distribution artifacts (#314)
- ensure that config files are passed explicitly to pytest and coverage (#312)

## v2.3.3 (2022-09-01)

### Fix

- **ci**: fix release workflow (#305)

## v2.3.2 (2022-09-01)

### Fix

- fix Makefile’s check for goals that require a virtual environment (#299)

### Refactor

- **ci**: improve the release workflow (#303)

## v2.3.1 (2022-08-26)

### Fix

- **ci**: separate artifacts for release and debugging (#297) (#298)

## v2.3.0 (2022-08-26)

### Feat

- persist requirements.txt as a build artifact (#284)
- always create a reproducible build with `make dist` (#272)

### Fix

- **ci**: allow PR Action to check commits across branches of forks (#287)
- disable noise when freezing the current venv (#273)
- enable CI on release bump commit (#269)

### Refactor

- **ci**: remove write permissions from build.yaml (#291)

## v2.2.0 (2022-07-31)

### Feat

- generate SLSA level 3 provenance for release artifacts (#259)

### Fix

- create empty pip.conf file inside a new virtual environment (#264)

### Refactor

- **ci**: use commitizen tool for pull request action (#263)

## v2.1.0 (2022-07-12)

### Feat

- use Bash as the shell to execute Makefile recipes (#256)
- warn if generated builds are not reproducible (#253)
- move private file .upgraded into .venv/ folder (#248)

### Fix

- default goal for make should be to build the entire package (#257)
- remove shebang comment from Makefile which isn’t actually runable (#252)

## v2.0.0 (2022-07-06)

### Feat

- replace the Makefile’s quick-check goal with check-code (#239)
- add pytest-env and pytest-custom-exit-code plugin support (#243)

### Fix

- flit doesn’t support MANIFEST.in, fix sdist accordingly (#244)

## v1.6.1 (2022-06-26)

### Fix

- add explicit settings path to isort in pre-commit configuration (#233)

## v1.6.0 (2022-06-24)

### Feat

- consolidate sdist and wheel into a single build target (#229)

### Fix

- **ci**: run all Actions except the Release job on the release commit (#230)

## v1.5.1 (2022-06-21)

### Fix

- bump min pytest version according to the "test" dependencies (#220)
- don’t pin Black to a particular Python version (#217)

### Refactor

- **ci**: refactor and address security issues in workflows (#211)

## v1.5.0 (2022-06-20)

### Feat

- move package specification, tool configs to pyproject.toml (#208)

### Fix

- **ci**: Release Action needs to use flit, too
- **ci**: use dedicated RELEASE_TOKEN for Release Action job (#219)
- **ci**: enable Release Action for private, protected branches (#209)

## v1.4.1 (2022-05-19)

### Fix

- add missing phony target to Makefile (#200)

## v1.4.0 (2022-05-17)

### Feat

- add scorecards analysis workflow (#105)

### Fix

- on Windows, pip needs to run as a module (#194)

## v1.3.2 (2022-05-06)

### Fix

- fix "make dist" failing on latest version of Ubuntu (#190)

## v1.3.1 (2022-05-05)

### Fix

- pass pylint configuration to pylint explicitly (#188)
- correctly depend on and ignore .upgraded Makefile helper file (#187)

## v1.3.0 (2022-04-10)

### Feat

- add Makefile to enable the “Scripted Build” rule for SLSA Level 1 (#74)

## v1.2.0 (2022-01-19)

### Feat

- enable CodeQL security analyzer (#92)
- generate a command-line tool when installing this package (#89)

### Fix

- change .yml to .yaml in documentation (#101)
- remove exclude option from mypy.ini (#98)

## v1.1.2 (2021-12-09)

### Fix

- add type marker to enable mypy’s use of this typed package (#55)

## v1.1.1 (2021-11-17)

### Fix

- git hook configuration didn’t match package paths anymore (#39)

## v1.1.0 (2021-10-13)

### Feat

- add dependency analysis for automatic version updates (#3)

## v1.0.0 (2021-09-29)

### Feat

- Initial version of the Python package template
