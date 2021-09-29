"""The main entry point into this package when run as a script."""

# For more details, see also
# https://docs.python.org/3/library/runpy.html
# https://docs.python.org/3/reference/import.html#special-considerations-for-main

import os
import sys

from .something import Something

if __name__ == "__main__":
    _ = Something.do_something()
    sys.exit(os.EX_OK)
