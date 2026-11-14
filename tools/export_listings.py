"""Export each TwinCAT object in this repository as a Structured Text listing.

The documentation site (mccluretc.github.io) shows code as plain listings:
a function block's declaration, then each method and property in turn, the
way it reads in the TwinCAT editor. This script writes those listings from
the TwinCAT XML files, so the site always shows code that compiled.

For every PLC project in the repository (every .plcproj, wherever the
TwinCAT solution keeps it), it finds every .TcPOU, .TcIO, .TcDUT and .TcGVL
file in that project's folder and writes:

    listings/<PlcProject>/<ObjectName>.st   one listing per object
    listings/<PlcProject>/index.json        object name -> source file path

<PlcProject> is the .plcproj file's name, e.g. BottleFiller.

Run from the repository root:

    python tools/export_listings.py            write the listings
    python tools/export_listings.py --check    fail if any listing is out of date

Needs only the Python standard library.
"""

import glob
import json
import os
import sys
import xml.etree.ElementTree as ET

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
KINDS = (".TcPOU", ".TcIO", ".TcDUT", ".TcGVL")
SKIP_DIRS = {"listings", "tools", ".github", ".git", ".vs", "_Boot", "_CompileInfo", "_Deployment", "_Libraries"}


def text(el):
    return (el.text or "").replace("\r\n", "\n").rstrip("\n") if el is not None else ""


def lines(s):
    return s.split("\n") if s else []


def accessor(name, el):
    """GET:/SET: in the site's style: on one line when the body is one line."""
    if el is None:
        return []
    decl = text(el.find("Declaration")).strip()
    body = lines(text(el.find("Implementation/ST")))
    has_locals = decl not in ("", "VAR\nEND_VAR")
    if len(body) == 1 and not has_locals:
        return [f"{name}: {body[0]}"]
    out = [f"{name}:"]
    if has_locals:
        out += lines(decl)
    return out + body


def member(el, in_interface):
    decl = lines(text(el.find("Declaration")))
    if el.tag == "Method":
        if in_interface:
            # an empty VAR_INPUT pair says nothing in a listing
            return [d for d in decl if d.strip() not in ("VAR_INPUT", "END_VAR")] \
                if decl[1:] == ["VAR_INPUT", "END_VAR"] else decl
        return decl + lines(text(el.find("Implementation/ST")))
    # Property: its declaration line, plus any attribute pragmas above it
    if in_interface:
        kinds = [k for k in ("Get", "Set") if el.find(k) is not None]
        if kinds and decl:
            decl = decl[:-1] + [decl[-1] + "   // " + " and ".join(k.upper() for k in kinds)]
        return decl
    return decl + accessor("GET", el.find("Get")) + accessor("SET", el.find("Set"))


def listing(path):
    root = ET.parse(path).getroot()
    obj = root[0]
    name = obj.get("Name")
    out = lines(text(obj.find("Declaration")))
    if obj.tag == "POU":
        body = lines(text(obj.find("Implementation/ST")))
        if body:
            out += [""] + body
    members = [m for m in obj if m.tag in ("Method", "Property")]
    for m in members:
        out += [""] + member(m, obj.tag == "Itf")
    return name, "\n".join(out).rstrip() + "\n"


def skipped(path):
    return bool(set(os.path.relpath(path, ROOT).split(os.sep)) & SKIP_DIRS)


def projects():
    """Each PLC project: its name and the folder its .plcproj is in."""
    found = glob.glob(os.path.join(ROOT, "**", "*.plcproj"), recursive=True)
    for plcproj in sorted(p for p in found if not skipped(p)):
        yield os.path.splitext(os.path.basename(plcproj))[0], os.path.dirname(plcproj)


def export(check):
    stale = []
    for proj, full in projects():
        files = []
        for kind in KINDS:
            files += glob.glob(os.path.join(full, "**", "*" + kind), recursive=True)
        files = [f for f in files if not skipped(f)]
        if not files:
            continue
        out_dir = os.path.join(ROOT, "listings", proj)
        index, wanted = {}, {}
        for f in sorted(files):
            name, body = listing(f)
            index[name] = os.path.relpath(f, ROOT).replace(os.sep, "/")
            wanted[os.path.join(out_dir, name + ".st")] = body
        wanted[os.path.join(out_dir, "index.json")] = json.dumps(index, indent=2, sort_keys=True) + "\n"
        existing = set(glob.glob(os.path.join(out_dir, "*")))
        for path, body in wanted.items():
            old = open(path, encoding="utf-8").read() if os.path.exists(path) else None
            if old != body:
                stale.append(path)
                if not check:
                    os.makedirs(out_dir, exist_ok=True)
                    with open(path, "w", encoding="utf-8", newline="\n") as fh:
                        fh.write(body)
        for path in existing - set(wanted):
            stale.append(path)
            if not check:
                os.remove(path)
        print(f"{proj}: {len(files)} objects")
    if check and stale:
        print("Out of date; run python tools/export_listings.py and commit:")
        for p in stale:
            print("  " + os.path.relpath(p, ROOT))
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(export("--check" in sys.argv))
