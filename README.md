# SmartBox HW501 workspace

This repository brings the SmartBox HW501 firmware research and modifications
together as **six pinned Git submodules**. Each component has its own repository,
history, documentation, and development cycle.

> This project is coordinated by Kacper Serewiś and was written with GPT-6-Astra.

| Directory | Repository | Scope |
|---|---|---|
| [tools](components/tools) | [smartbox-tools](https://github.com/kacper-serewis/smartbox-tools) | Stock HW501 firmware downloads, comparison, binary analysis, device inspection, guarded updates, and shared firmware helpers. |
| [density](components/density) | [smartbox-density](https://github.com/kacper-serewis/smartbox-density) | Guarded HW501 v131 CarPlay display-density patches and the recorded Corsa display experiments. |
| [sony-audio](components/sony-audio) | [smartbox-sony-audio](https://github.com/kacper-serewis/smartbox-sony-audio) | Experimental Sony XAV-AX1005DB audio negotiation patch and Carlinkit firmware comparison evidence. |
| [mac-usb](components/mac-usb) | [smartbox-mac-usb](https://github.com/kacper-serewis/smartbox-mac-usb) | macOS USB gadget access, iAP2 authentication and session probes, and the local CarPlay head-unit preview. |
| [emulation](components/emulation) | [smartbox-emulation](https://github.com/kacper-serewis/smartbox-emulation) | Pinned RV32 toolchains, QEMU/Andes containers, and bounded stock HW501 application probes. |
| [mirroring](components/mirroring) | [smartbox-mirroring](https://github.com/kacper-serewis/smartbox-mirroring) | AirPlay screen capture, dongle mirroring bridge, mode selector, and guarded bench/build/update tooling. |

## Get the workspace

```sh
git clone --recurse-submodules https://github.com/kacper-serewis/smartbox-re.git
cd smartbox-re
```

For an existing checkout, after pulling the workspace change:

```sh
git submodule update --init --recursive
```

Use `--recursive`: components also pin shared tools and build dependencies.
Each component can alternatively be cloned on its own with `--recurse-submodules`.

## Run tools

The original `scripts/`, `experiments/`, and `reports/` paths are compatibility
symlinks to their owning components. Existing commands and research links still
work. Edit the files in `components/`; commit changes in their owning repository.
Run commands from this workspace root to use one firmware cache:

```sh
python3 -m venv .venv
.venv/bin/python -m pip install -r scripts/requirements-analysis.txt
.venv/bin/python scripts/download_firmwares.py --help
.venv/bin/python scripts/build_display_firmware.py --help
.venv/bin/python scripts/build_sony_firmware.py --help
.venv/bin/python scripts/capture_mirroring.py --help
```

Mac head-unit tooling also needs `scripts/requirements-mac-headunit.txt`.
Read each component's guide for native build requirements and device operations.
Ignored `firmwares/`, `device-snapshots/`, and `.venv/` stay local. Existing caches
can stay in place. Python scripts recognize `.smartbox-workspace` and use the
parent directories, including when invoked through a component path.
In a standalone checkout, artifacts live in that component instead.

## Working across repositories

Submodules start at the pinned commit, usually with a detached HEAD. Create a
branch before making changes. For example:

```sh
git -C components/density switch -c my-density-change
# Edit and test the density component.
git -C components/density add scripts reports
git -C components/density commit -m "Describe the density change"
git -C components/density push -u origin my-density-change
git add components/density
git commit -m "Update density component"
```

Push component commits before publishing the parent pointer. To consume updated
workspace pins after a pull, run `git submodule update --init --recursive`.
Use `git submodule status --recursive` to inspect all revisions. Dependency
updates are explicit: a top-level tools update does not automatically update
the tools revision inside each component. See [the repository guide](docs/repositories.md).

## Research and firmware status

Targets **HW501** only. Density125/150 were tested on one physical setup;
density137.5's display result remains unverified. Sony audio has offline
validation only. The previously built mirroring image is **withdrawn: do not
install it**; corrected source still needs a new image and hardware validation.

The [research overview](docs/research-overview.md) retains the detailed status,
hardware limitations, firmware inventory, and reproduction instructions.
