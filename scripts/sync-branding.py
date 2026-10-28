#!/usr/bin/env python3
"""Copy the author, credits and repository from branding.json into Cargo.toml and every
package.json, which can't read it themselves.

Run with --check to only report stale files (exits 1 if any).
"""

import json
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
BRANDING = json.loads((ROOT / "branding.json").read_text())
AUTHORS = [BRANDING["author"], *BRANDING["credits"]]


def sync_cargo_toml(text: str) -> str:
    authors = "".join(f"\n    {json.dumps(author)}," for author in AUTHORS)
    text = re.sub(
        r"(?ms)^(\[workspace\.package\]\n.*?^authors = \[).*?^\]",
        rf"\g<1>{authors}\n]",
        text,
        count=1,
    )
    return re.sub(
        r"(?ms)^(\[workspace\.package\]\n.*?^homepage = ).*?$",
        lambda m: m.group(1) + json.dumps(BRANDING["repository"]),
        text,
        count=1,
    )


def sync_package_json(text: str) -> str:
    package = json.loads(text)
    fields = {
        "author": BRANDING["author"],
        "contributors": BRANDING["credits"],
        "repository": BRANDING["repository"],
    }
    synced = {}
    for key, value in package.items():
        # Missing fields go just before "repository", where the others already sit
        if key == "repository":
            synced.update(fields)
        if key not in fields:
            synced[key] = value
    return json.dumps(synced, indent=2, ensure_ascii=False) + "\n"


def main() -> int:
    check = "--check" in sys.argv[1:]
    targets = [(ROOT / "Cargo.toml", sync_cargo_toml)]
    for path in sorted(
        [
            ROOT / "package.json",
            ROOT / "proto" / "package.json",
            *ROOT.glob("packages/*/package.json"),
        ]
    ):
        targets.append((path, sync_package_json))

    stale = []
    for path, sync in targets:
        text = path.read_text()
        synced = sync(text)
        if synced != text:
            stale.append(path.relative_to(ROOT))
            if not check:
                path.write_text(synced)

    if check and stale:
        print("Out of sync with branding.json (run: make branding):", file=sys.stderr)
        for path in stale:
            print(f"  {path}", file=sys.stderr)
        return 1
    for path in stale:
        print(f"Updated {path}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
