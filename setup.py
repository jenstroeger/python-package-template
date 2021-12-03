"""Setup for this package."""

import ast
import os
import typing

import setuptools

here = os.path.abspath(os.path.dirname(__file__))
src = os.path.join(here, "src")

with open(os.path.join(here, "README.md"), encoding="utf-8") as fh:
    README = fh.read()
with open(os.path.join(here, "LICENSE.md"), encoding="utf-8") as fh:
    LICENSE = fh.read()
with open(os.path.join(src, "package", "__init__.py"), encoding="utf-8") as fh:
    module = ast.parse(next(filter(lambda line: line.startswith("__version__"), fh)))
    assign = typing.cast(ast.Assign, module.body[0])
    # See also: https://github.com/relekang/python-semantic-release/issues/388
    VERSION = typing.cast(ast.Constant, assign.value).s

# https://packaging.python.org/guides/distributing-packages-using-setuptools/#setup-args
# https://docs.python.org/3/distutils/apiref.html#distutils.core.setup
setuptools.setup(
    name="package",
    version=VERSION,
    description="",
    long_description=README,
    long_description_content_type="text/markdown",
    url="",
    author="",
    author_email="",
    # maintainer=
    # maintainer_email=
    license=LICENSE,
    # https://pypi.org/classifiers/
    classifiers=[
        "Development Status :: 1 - Planning",
        "License :: OSI Approved :: MIT License",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
    ],
    keywords="",
    project_urls={
        "Homepage": "https://foo.bar/",
    },
    package_dir={"": "src"},
    packages=setuptools.find_packages(where="src"),
    python_requires=">=3.9",
    include_package_data=True,
    install_requires=[],
    extras_require={
        "test": ["hypothesis==6.30.0", "pytest==6.2.5", "pytest-cov==3.0.0"],
        "dev": [
            "flake8==4.0.1",
            "flake8-builtins==1.5.3",
            "flake8-docstrings==1.6.0",
            "flake8-rst-docstrings==0.2.3",
            "mypy==0.910",
            "pep8-naming==0.12.1",
            "pre-commit==2.15.0",
            "pylint==2.11.1",
            "python-semantic-release==7.19.2",
            "tox==3.24.4",
        ],
        "docs": ["sphinx==4.3.0"],
    },
    package_data={
        "package": ["py.typed"],
    },
    options={},
    platforms="",
    zip_safe=False,
)
