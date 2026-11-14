# PLC patterns examples

Complete TwinCAT 3 projects for [mccluretc.github.io](https://mccluretc.github.io), a guide to object-oriented programming, SOLID and design patterns in IEC 61131-3 Structured Text.

The pages on the site show the code that matters for each lesson. This repository holds the whole projects that code comes from, so you can open them in TwinCAT, build them and run them. The listings on the site are generated from the files here, at a tagged release, so what you read has compiled.

## Projects

| Folder | What it is | Page |
|---|---|---|
| [BottleFiller](MachineExamples/BottleFiller) | A small machine built as a module tree: a machine module with a simple state machine, a filling station and a transfer station, five devices, each real or simulated, and tests. | [A bottle filler built as a module tree](https://mccluretc.github.io/MachineExamples/module-tree/) |

Each project has its own document in its `Documentation` folder: libraries, structure, simulation switches, and how to run it.

`MachineExamples` is one TwinCAT solution; each machine is a PLC project in it, in its own folder.

## Running a project

1. Open `MachineExamples` in TwinCAT 3 (build 4026 or later), or add a PLC project to a solution of your own.
2. Check the libraries in the Library Manager, build, and activate on a target or the local PC. A PC with the TwinCAT runtime trial license runs every simulated device.
3. Read the project document for what to do next.

None of this code is ready for a real machine as it stands. Link and check the I/O, check every timeout against the real devices, and keep safety functions in the safety controller.

## Listings

`listings/<PlcProject>/` holds one `.st` file per object of that PLC project, and `index.json` maps each object to its source file. The script finds the PLC projects by their `.plcproj` files. They are generated; never edit them by hand.

After changing a project:

```
python tools/export_listings.py
```

and commit the changed listings with the change. The `Listings up to date` workflow fails if they're out of date.

## Releases

The site pins a release tag (`v0.1.0`, ...). A change here reaches the site only when a new tag is made and the site's `tools/examples.json` is moved to it.
