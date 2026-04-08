"""The Something module provides some things and functions."""

# Copyright (c) 2021-2026 CODEOWNERS
# This code is licensed under MIT license, see LICENSE.md for details.


class Something:
    """The Something class provides some things."""

    @staticmethod
    def do_something(value: bool = False) -> bool:
        """Return true, always.

        Test this function in your local terminal, too, for example:

        .. code: pycon

            >>> s = Something()
            >>> s.do_something(False)
            True
            >>> s.do_something(value=True)
            True

        """
        return value or True
