"""Test configuration and other goodness."""

# Copyright (c) 2021-2026 CODEOWNERS
# This code is licensed under MIT license, see LICENSE.md for details.

import os

import hypothesis

# Configure Hypothesis. For Github CI we derandomize to prevent nondeterministic tests
# because we don't want publishing to fail randomly. However, targeted fuzzing should
# use its own profile and randomize.
hypothesis.settings.register_profile("default", max_examples=500, derandomize=False)
hypothesis.settings.register_profile("github", max_examples=100, derandomize=True)
hypothesis.settings.register_profile("fuzz", max_examples=10000, derandomize=False)
hypothesis.settings.load_profile(os.getenv("HYPOTHESIS_PROFILE", "default"))
