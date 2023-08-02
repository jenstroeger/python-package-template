"""Test the Package itself using its external interface as in integration into a larger run context."""

# Copyright (c) 2021-2026 CODEOWNERS
# This code is licensed under MIT license, see LICENSE.md for details.

import subprocess

import pytest


@pytest.mark.integration
def test_package() -> None:
    """Test the Something command."""
    # For testing we disable this warning here:
    # https://docs.astral.sh/ruff/rules/start-process-with-partial-path/
    completed = subprocess.run(["something"], check=True, shell=False)  # noqa: S607
    assert completed.returncode == 0
