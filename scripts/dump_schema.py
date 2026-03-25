#!/usr/bin/env python3
"""Dump the current AppDatabase schema and regenerate migration test helpers.

Run from anywhere in the repo — the script finds the database package automatically.
"""

import subprocess
import sys
from pathlib import Path


def main():
    db_pkg = Path(__file__).resolve().parent.parent / "packages" / "database"

    if not db_pkg.is_dir():
        print(f"Error: database package not found at {db_pkg}", file=sys.stderr)
        sys.exit(1)

    commands = [
        ["dart", "run", "drift_dev", "schema", "dump",
         "lib/app_database.dart", "drift_schemas/"],
        ["dart", "run", "drift_dev", "schema", "generate",
         "drift_schemas/", "test/generated_migrations/"],
    ]

    for cmd in commands:
        print(f"=> {' '.join(cmd)}")
        result = subprocess.run(cmd, cwd=db_pkg, shell=(sys.platform == "win32"))
        if result.returncode != 0:
            sys.exit(result.returncode)

    print("Done. Remember to update schema_verification_test.dart.")


if __name__ == "__main__":
    main()
