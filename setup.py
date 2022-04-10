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
    url="https://project.url/",
    author="Author",
    author_email="author@email",
    maintainer="Maintainer",
    maintainer_email="maintainer@email",
    license=LICENSE,
    # https://pypi.org/classifiers/
    classifiers=[
        "Development Status :: 1 - Planning",
        "Intended Audience :: Developers",
        "Natural Language :: English",
        "License :: OSI Approved :: MIT License",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "Programming Language :: Python :: 3 :: Only",
        "Programming Language :: Python :: Implementation :: CPython",
    ],
    python_requires=">=3.9",
    keywords="",
    project_urls={
        "Homepage": "https://foo.bar/",
    },
    packages=setuptools.find_packages(where="src"),
    package_dir={"": "src"},
    package_data={
        "package": ["py.typed"],
    },
    include_package_data=True,
    install_requires=[],
    extras_require={
        "hooks": [
            "pre-commit>=2.13.0,<=2.18.1",
        ],
        "test": [
            "hypothesis>=6.21.0,<=6.41.0",
            "pytest>=6.2.4,<7.0.0",
            "pytest-cov==3.0.0",
        ],
        "dev": [
            "bandit>=1.7.1,<=1.7.4",
            "flake8==4.0.1",
            "flake8-builtins==1.5.3",
            "flake8-docstrings==1.6.0",
            "flake8-rst-docstrings>=0.2.3,<=0.2.5",
            "hashin==0.17.0",
            "hypothesis>=6.21.0,<=6.41.0",
            "mypy>=0.921,<=0.942",
            "pep8-naming==0.12.1",
            "pylint>=2.9.3,<=2.13.5",
            "types-setuptools>=57.4.7,<=57.4.13",
        ],
        "docs": [
            "sphinx>=4.1.2,<=4.5.0",
        ],
    },
    entry_points={"console_scripts": ["something = package.__main__:main"]},
    options={},
    platforms="",
    zip_safe=False,
)
