---
name: character-rigging-animation-export
description: Rig a FinoFarm character in Blender and export idle and walk clips to Godot. Use when replacing the placeholder walker or adding an animation.
---

# Character rigging and animation export

`PlaceholderWalker` is boxes plus a sine swing. It is not a rig. Task FF-19 replaces it. Do not describe the sine swing as an animation clip.

## Steps

1. Read the character section of `docs/art-bible.md`. Proportions must read from the farm camera at distance 15–20.
2. Build the mesh and an armature in Blender. Name the armature `Armature`. Rest pose is a standing character on the ground, facing -Z in Blender so Godot's forward matches `look_at`.
3. Author clips named exactly `idle` and `walk`. Walk is an in-place cycle. Root motion stays off. The game script moves the body, the clip moves the limbs.
4. Export one `.glb` with the skin and both clips. Record skeleton and clip names in the asset registry.
5. Import in Godot. The character scene should show an `AnimationPlayer` with `idle` and `walk`.
6. Replace `PlaceholderWalker` with an instance of that scene. Drive `walk` from distance traveled and `idle` when speed is zero. Remove the sine-wave pose so two systems do not fight.
7. Keep `advance(delta)` as the movement API, either on the new script or as a wrapper, so `tests/run_scene_checks.gd` can still request one second of walking.

## Example

A failed export is a mesh with no skin, or a walk clip that slides the root. Godot will import it and the character will still skate. Check the `AnimationPlayer` list before deleting the placeholder.

## Constraints

- Godot 4 glTF importer, Compatibility renderer. Do not require a custom engine build.
- No photoreal human in the cartoon farm.
- Do not add carry, celebrate, rest, or work clips until walk and idle loop cleanly. The bible lists them as the later set.
- The placeholder script's `SPEED` of `1.7` is block-out speed, not a promise. If the clip's stride looks wrong, change speed in the character scene and update the scene check's expected distance.

## Validation

```bash
blender --background --python tools/blender/your_character.py
godot --headless --path . --import --quit
godot --headless --path . --check-only -s res://scripts/characters/your_walker.gd
bash tools/validate.sh
```

Load the character scene in the editor or a capture and confirm the legs cycle while the node moves. A still frame of a T-pose is not a walk.
