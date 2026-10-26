---
name: asset-import-validation
description: Import a FinoFarm asset into Godot and record it in the asset registry. Use when adding a glTF, texture, audio file, or shader.
---

# Asset import validation

A file in the repo is not an in-game asset until Godot imports it and a scene loads it.

## Steps

1. Confirm the license. If the file is third-party, the registry needs the URL and commercial-use terms. Reject unclear licenses.
2. Refuse executable downloads, prebuilt plugins from untrusted URLs, and `.exe` or `.dll` beside art.
3. Put the export under `assets/`. Git LFS patterns in `.gitattributes` cover `glb`, `png`, `jpg`, `blend`, `wav`, `ogg`, and `mp3`.
4. Run the import command below. Fix the first import error before adding more files.
5. Instance the asset in a scene. `tests/run_scene_checks.gd` or a new check should fail if that instance is missing, when gameplay depends on it.
6. Fill every column in `docs/asset-registry.md`. Status `draft` means exported only. `in-engine` means a scene instances it. `placeholder` is only for intentional stand-ins.
7. Capture a frame if the asset is visible.

## Example

`icon.svg` is imported as `icon.svg.import`. The registry row `icon.game` is a block-out icon, not marketing art. Follow that honesty for every row.

## Constraints

- Do not commit `.godot/` imported caches. Do commit `.import` sidecars and `.uid` files.
- Do not set registry status to `accepted` without a capture compared to `docs/art-bible.md`.
- Textures should be power-of-two when they are atlases. The first scene has no textures. Do not add a random 4K photo to a primitive.

## Validation

```bash
git lfs status
godot --headless --path . --import --quit
bash tools/validate.sh
```

Import must exit 0. If Godot prints an unsupported glTF feature, fix the export. Do not silence it by skipping the scene.
