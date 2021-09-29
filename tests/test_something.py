"""Test the Something module. Add more tests here, as needed."""

from hypothesis import given, strategies

from package.something import Something


@given(strategies.booleans())
def test_something(boolean: bool) -> None:
    """Test something here."""
    assert Something.do_something(boolean) is True
