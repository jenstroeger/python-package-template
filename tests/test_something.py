"""Test the Something module. Add more tests here, as needed."""

import faker
from hypothesis import given, strategies
from pytest_cases import parametrize_with_cases

from package.something import Something


@given(strategies.booleans())
def test_something_hypothesis(boolean: bool) -> None:
    """Test something here using Hypothesis."""
    assert Something.do_something(boolean) is True


def _case_boolean() -> bool:
    fake = faker.Faker()
    return fake.pybool()


@parametrize_with_cases("boolean", cases=_case_boolean)
def test_something_cases(boolean: bool) -> None:
    """Test something here using Cases and Faker."""
    assert Something.do_something(boolean) is True
