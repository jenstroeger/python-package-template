"""The Something module provides some things and functions."""


class Something:
    """The Something class provides some things."""

    @staticmethod
    def do_something(value: bool = False) -> str:
        """Return true, always."""
        return value or True
