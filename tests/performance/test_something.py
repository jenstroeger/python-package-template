"""Test the performance of various package parts, or the package as a while."""

import pytest
from pytest_benchmark.fixture import BenchmarkFixture

from package.something import Something


@pytest.mark.performance
def test_something(benchmark: BenchmarkFixture) -> None:
    """Test performance of the function."""
    benchmark.pedantic(Something.do_something, iterations=10, rounds=100)  # type: ignore[no-untyped-call]
