---
name: blender-procedural-modeling
description: Model FinoFarm props with Blender 5.2 Python and export glTF. Use when creating a mesh, a building block-out, or a procedural asset.
---

# Blender procedural modeling

Blender 5.2.3 is installed by `.cursor/install.sh` at `/usr/local/bin/blender`. The game does not load `.blend` files. Godot loads exported `.glb`.

## Steps

1. Read `docs/art-bible.md` and pick colors from the block-out palette. A model that ignores the palette is rejected even if it exports.
2. Put the generator in `tools/blender/<asset_id>.py`. Keep the `.blend` only if someone needs to hand-edit it, and then Git LFS tracks it.
3. Start from factory settings, build the mesh, apply scale, set the origin at the ground contact.
4. Export glTF binary, Y-up, into `assets/models/<asset_id>.glb`.
5. Add the registry row before the scene instances the file. Status stays `draft` until Godot imports it, then `in-engine`.
6. Instance the glTF in its own `.tscn`. Swap that scene in for the placeholder node. Delete the primitive only in that same change, so the game is never missing the building.

## Example

`tools/blender/export_probe.py` builds a cube and writes `/tmp/finofarm-blender-probe.glb`. Copy that shape for a real asset, change the output path into `assets/models/`, and do not commit the probe cube.

```bash
blender --background --python tools/blender/export_probe.py
```

## Constraints

- No downloads of random addons or executable scripts.
- Do not export a primitive cube and register it as a finished barn. FF-18 requires a model that matches the bible.
- Commercial-use license must be recorded. Project-original meshes say `project original`.
- `.glb` is Git LFS. `git lfs status` should list the file as an LFS object before commit.

## Validation

```bash
blender --version
blender --background --python tools/blender/your_asset.py
godot --headless --path . --import --quit
bash tools/validate.sh
```

Then capture the farm frame and confirm the new mesh, not the old primitive, is in the picture.
