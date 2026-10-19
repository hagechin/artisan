"""Copy installed Python distributions' published license files into a build."""

from __future__ import annotations

import csv
import importlib.metadata as metadata
import re
import shutil
import sys
from pathlib import Path

destination = Path(sys.argv[1])
destination.mkdir(parents=True, exist_ok=True)
rows = []
for dist in sorted(metadata.distributions(), key=lambda item: (item.metadata.get("Name") or "").lower()):
    name = dist.metadata.get("Name", "unknown")
    slug = re.sub(r"[^A-Za-z0-9._-]+", "_", f"{name}-{dist.version}")
    license_value = dist.metadata.get("License-Expression", "") or dist.metadata.get("License", "")
    license_value = license_value.splitlines()[0] if license_value else ""
    copied = []
    for file in dist.files or []:
        path = str(file)
        if ".dist-info/" not in path or not re.search(r"(^|/)(license|licence|copying|notice|authors)", path, re.I):
            continue
        source = Path(dist.locate_file(file))
        if not source.is_file() or source.stat().st_size > 2_000_000:
            continue
        relative = Path(path.split(".dist-info/", 1)[1])
        target = destination / slug / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(source, target)
        copied.append(str(target.relative_to(destination)))
    rows.append((name, dist.version, license_value, "; ".join(copied)))
with (destination / "INVENTORY.csv").open("w", newline="", encoding="utf-8") as stream:
    writer = csv.writer(stream)
    writer.writerow(("Package", "Version", "Metadata license", "Collected license files"))
    writer.writerows(rows)
(destination / "README.md").write_text(
    "# Python dependency notices\n\nCollected from the installed x86_64 build environment. "
    "The inventory must be compared with the final packaged binaries before release.\n",
    encoding="utf-8",
)
