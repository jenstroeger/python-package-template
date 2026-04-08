"""Test the performance of various package parts, or the package as a whole."""

# Copyright (c) 2021-2026 CODEOWNERS
# This code is licensed under MIT license, see LICENSE.md for details.

import pytest
from pytest_benchmark.fixture import BenchmarkFixture

from package.something import Something


@pytest.mark.performance
def test_something(benchmark: BenchmarkFixture) -> None:
    """Test performance of the function."""
    benchmark.pedantic(Something.do_something, iterations=10, rounds=100)  # type: ignore[no-untyped-call]
