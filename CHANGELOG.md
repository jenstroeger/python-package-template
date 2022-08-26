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
