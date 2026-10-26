---
name: godot-scene-construction
description: Build or edit a FinoFarm Godot 4 scene, camera, character, or level mesh. Use when changing a .tscn, the main scene, or in-engine block-out geometry.
---

# Godot scene construction

The game is a Godot 4.7 GDScript project. The main scene is `res://scenes/farm/first_farm.tscn`. Do not replace it with an HTML page or a menu that has no 3D world.

## Steps

1. Read `docs/art-bible.md`, `docs/interface-contracts.md`, and `docs/backlog.md`. If the task id is claimed by someone else, stop.
2. Keep the Compatibility renderer in `project.godot` unless an ADR says otherwise.
3. Put scenes in `scenes/<domain>/`. Instance child scenes instead of pasting a second barn into `first_farm.tscn`.
4. New temporary meshes use a `Placeholder` node name and a `placeholder` row in `docs/asset-registry.md`. Say that in the art bible if the mesh is visible.
5. Camera changes go through `FarmCamera.orbit`, `zoom_by`, `pan_keys`, and `pan_screen`. Do not add a second camera script.
6. Walker motion for the block-out goes through `PlaceholderWalker.advance`. A real character replaces that node under task FF-19.
7. Update `tests/run_scene_checks.gd` when a required node name changes.

## Example

A new prop is `scenes/props/crate.tscn` instanced under `FirstFarm`. The registry row says `placeholder` until a glTF replaces the box. The scene check asserts the instance exists only if gameplay depends on it.

## Constraints

- Godot 4.7 scene format (`format=3`). `BoxMesh` uses `size`, not Godot 3 `extents`.
- Headless `_initialize` runs before nodes are in the tree. Scene checks must `call_deferred` before reading `global_position`.
- Do not commit `.godot/`. Do commit new `*.uid` files Godot writes beside scripts.
- Shadows and a bright sun clip flat colors on the Compatibility renderer. Follow the lighting numbers in the art bible.

## Validation

```bash
bash tools/validate.sh
godot --path . --display-driver x11 --rendering-driver opengl3 \
  -s res://tools/capture_farm.gd -- --output=/tmp/finofarm-first-farm.png
```

`validate.sh` must exit 0. Open the png and compare it to the art bible before describing the scene as finished art.
