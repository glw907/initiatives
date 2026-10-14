#!/usr/bin/env python3
"""Answer gh calls from the JSON file named by INVENTORY_GH_FIXTURE, keyed by the joined args."""
import json
import os
import sys

fix = json.load(open(os.environ["INVENTORY_GH_FIXTURE"]))
e = fix.get(" ".join(sys.argv[1:]))
if e is None:
    sys.stderr.write("GraphQL: Could not resolve to a Repository\n")
    sys.exit(1)
sys.stdout.write(e if isinstance(e, str) else json.dumps(e))
