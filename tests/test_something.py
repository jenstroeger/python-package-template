"""Test the Something module. Add more tests here, as needed."""

from hypothesis import given, strategies
from pytest_cases import parametrize

from package.something import Something


@given(strategies.booleans())
def test_something_hypothesis(boolean: bool) -> None:
    """Test something here using Hypothesis."""
    assert Something.do_something(boolean) is True


@parametrize("boolean", [True, False])
def test_something_cases(boolean: bool) -> None:
    """Test something here using Cases."""
    assert Something.do_something(boolean) is True
