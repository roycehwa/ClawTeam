#!/usr/bin/env python3
"""
ClawTeam entry point - runs directly from source
"""
import sys
import os

# Ensure the clawteam-src directory is in path
CLAWTEAM_ROOT = "/root/.openclaw/workspace/clawteam-src"
if CLAWTEAM_ROOT not in sys.path:
    sys.path.insert(0, CLAWTEAM_ROOT)

# Now import and run
from cli.commands import app

if __name__ == "__main__":
    app()
