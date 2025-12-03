"""Test the Package itself using its external interface as in integration into a larger run context."""

# https://bandit.readthedocs.io/en/latest/blacklists/blacklist_imports.html#b404-import-subprocess
import subprocess  # nosec B404

import pytest


@pytest.mark.integration
def test_package() -> None:
    """Test the Something command."""
    # For testing we disable this warning here:
    # https://bandit.readthedocs.io/en/latest/plugins/b603_subprocess_without_shell_equals_true.html
    # https://bandit.readthedocs.io/en/latest/plugins/b607_start_process_with_partial_path.html
    completed = subprocess.run(["something"], check=True, shell=False)  # nosec B603, B607
    assert completed.returncode == 0
