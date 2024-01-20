.. Package documentation master file, created by
   sphinx-quickstart on Thu Sep  2 09:41:50 2021.
   You can adapt this file completely to your liking, but it should at least
   contain the root ``toctree`` directive.

Package package
===============

.. toctree::
   :maxdepth: 4
   :caption: Contents:

.. autosummary::
   :toctree: generated

Something
=========

The ``Something`` module contains a useful class which allows you to do something
like the following:

.. code: pycon

    >>> from package import something
    >>> s = something.Something()
    >>> s.do_something()
    True
    >>> s.do_something(False)  # doctest: +SKIP
    False  # This value would fail the test.

.. automodule:: package
   :members:

Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`
