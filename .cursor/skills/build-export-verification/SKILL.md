---
name: build-export-verification
description: Verify the FinoFarm Godot project imports, tests, and exports. Use when changing CI, export presets, or the engine pin.
---

# Build and export verification

Milestone 0 verification is headless import plus tests. A desktop or HTML5 export preset does not exist yet. Do not report a shippable build.

## Steps

1. Confirm the engine before testing:

```bash
godot --version
```

Expect a `4.7.2.stable` string. If `godot` is missing, run `bash .cursor/install.sh`. Do not download a different Godot over the pin.

2. Run the project check:

```bash
bash tools/validate.sh
```

That is import, `--check-only` on every script under `scripts/`, `tests/`, and `tools/`, then simulation tests and the scene load.

3. CI is `.github/workflows/validate.yml`. It installs runtime libraries, runs `.cursor/install.sh`, and runs `tools/validate.sh`. Keep those calls. Do not replace them with a Python syntax check.

4. For a visible frame, use the capture command in the visual-regression skill. Headless import does not prove the frame.

5. HTML5 is task FF-7. When that task starts: install the official 4.7.2 export templates, add an export preset that uses the Compatibility renderer, run `godot --headless --path . --export-release "Web" /tmp/finofarm-web/index.html`, and record the full output. A missing template is a failed check, not a success.

6. Desktop export is Milestone 7. Do not add a half-configured preset just to make the editor show a menu.

## Example

A green `validate.sh` on Godot `4.7.2.stable.official.ed1daf0bf` is the Milestone 0 build evidence. Pair it with the PNG path if you also captured the scene.

## Constraints

- `.cursor/install.sh` verifies the Godot zip with SHA-512 and Blender with SHA-256. Do not weaken those checks.
- The workflow may spend a long time on the Blender download because the install script is the single pin. That is acceptable. Do not fork a second installer that can drift.
- Do not force-push `main` or tag a release from a feature task.
- Audio device errors on CI images are not export failures.

## Validation

```bash
godot --version
bash tools/validate.sh
```

Both must succeed on the branch you are certifying. For FF-7, the export command's exit code is part of the result, pass or fail, and the log is the artifact.
