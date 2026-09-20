# Migration validation

Validated offline during the repository split:

- All 290 original source/report paths still resolve through the workspace.
- Six filtered histories retain author, date, and messages; each component includes an original-to-filtered commit map.
- All committed compatibility links are relative, with no missing targets.
- Standalone CLI help/import checks pass for all six components.
- A fresh workspace snapshot recursively clones all pinned components and dependencies from GitHub, stays clean, and passes compatibility-link and CLI-import checks.
- Density and Sony patch regressions pass both in the workspace and standalone.
- 83 Python tests pass across patch emulation, updater guards, recovery, Mac protocols, mode service, receiver, and artifact-path resolution. One additional Carlinkit real-image test is skipped because its optional firmware cache is absent.
- The native mirroring receiver builds successfully, and its CTest capture-boundary check passes.
- `git diff --cached --check` passes.

These checks cover repository integration and offline behavior. They do not
change the hardware validation status recorded in the component guides.
