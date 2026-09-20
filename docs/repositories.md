# Repository ownership and dependencies

`smartbox-re` is the integration workspace. Component source and reports live
in six separate repositories under `components/`; the workspace commits their
exact Git revisions. Git calls this a superproject.

```text
tools
├── density → tools
├── sony-audio → tools
├── mac-usb → tools
├── emulation → tools
└── mirroring → tools, density, emulation
```

Shared firmware inventory/hash helpers, the pinned stock executable identity,
H.264 inspection, and the Swift video preview belong to tools. Emulation owns
the toolchain setup. Mirroring owns the mode service. Sony audio has no density
dependency. Mirroring's Mac USB bench instructions refer to the separate Mac
USB repository; use this workspace for experiments that combine both projects.

Each dependency is pinned under the component's `deps/`. Script and source
symlinks expose required dependency files at the paths used by existing tools.
There are no machine-specific URLs or absolute symlinks in Git. Recursive
clones are required, and the development filesystem must support symlinks.

## Paths and local artifacts

The root `scripts/`, `reports/`, and `experiments/` are compatibility views,
not additional source copies. `.smartbox-workspace` tells Python scripts to
share the root firmware and snapshot directories. Run commands from the root;
some older analysis tools accept paths relative to the current directory.

In standalone clones, shared script links resolve artifacts relative to the
consumer, not the dependency checkout. Standalone emulation supports stock
probes; its optional `--mode-tests` runs from mirroring or this workspace,
where the mode-service source, tests, and build artifacts are available.

Existing ignored firmware archives and snapshots were not moved or published.
Fresh clones must download/extract stock firmware before firmware-based tests.

## Update a dependency

In the consuming component, fetch the dependency, check out the desired commit,
run the relevant checks, and commit the `deps/<name>` pointer. Publish that
component commit, then update the corresponding `components/<name>` pointer
in this workspace. Avoid `git submodule update --remote` for routine checkout:
it selects remote tips instead of reproducing committed revisions.

Changes made through a compatibility symlink belong to the linked repository.
Use `git -C components/<name> status` to see and commit them. Workspace `git diff`
shows component revisions, not an inline diff of their files.

## History

Component histories were filtered from smartbox-re at
`93aa9c567824e18f575ed5c41f855d617d687b50` (see each component's MIGRATION.md for the full source revision).
Author/date/messages were retained; filtered commit IDs differ. The complete
original history remains in smartbox-re. No existing branch was rewritten.
