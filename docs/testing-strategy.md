# Testing strategy

A check counts only after it has been run. `tools/validate.sh` is the Milestone 0 bar. GitHub Actions runs that script on push and pull request (`.github/workflows/validate.yml`).

## Command

```bash
bash .cursor/install.sh   # once per machine, if godot is missing
bash tools/validate.sh
```

The script prints `godot <version>`, then:

1. `godot --headless --path . --import --quit`
2. `godot --headless --path . --check-only -s res://<each gameplay script>`
3. `godot --headless --path . -s res://tests/run_simulation_tests.gd`
4. `godot --headless --path . -s res://tests/run_region_tests.gd`
5. `godot --headless --path . -s res://tests/run_save_load_tests.gd`
6. `godot --headless --path . -s res://tests/run_placement_tests.gd`
7. `godot --headless --path . -s res://tests/run_scene_checks.gd`

Exit code is the Godot exit code. `set -e` stops on the first failure.

## What the simulation tests cover

`tests/run_simulation_tests.gd` extends `SceneTree` only so Godot can run it headless. It does not load `first_farm.tscn` or read a viewport.

- Grades, labels, and minimum grade.
- Inventory stacks separated by grade, and rejection of bad input.
- Catalog ids and durations stay on the fictional textile recipes.
- Workshop failure does not consume inputs.
- A job completes on its duration, keeps a single grade, and uses the lower grade when inputs differ.
- A busy workshop does not consume twice.
- Extra ticks do not repeat a finished job.
- The clock is independent of how time is sliced, including a negative delta.
- Two steppers, one fed `4.0` seconds and one fed eight `0.5` second steps, match.

## What the scene checks cover

`tests/run_scene_checks.gd` loads scenes after the tree is up (`call_deferred`, because `_initialize` runs too early).

- Main scene path is the menu.
- The farm has placeholder terrain, an imported barn mesh, a tree, the farmhand, and the camera.
- The farmhand has a skeleton. `walk` and `idle` exist. `advance(1.0)` moves about `1.7` units and leaves `walk` playing.
- The HUD name, region, and funds come from a save written in the test.
- A saved marker appears on its cell. The player can move it, remove it, and a barn cell selects the barn instead.
- Zoom clamps, orbit distance holds, and yaw-0 pan matches the contract.
- The menu exposes Continue, My Farms, New Game, Settings, Credits, and Exit. Continue starts disabled. Two created farms show as cards. Region markers render the catalog fields.

`tests/run_region_tests.gd`, `tests/run_save_load_tests.gd`, and `tests/run_placement_tests.gd` do not instance a 3D scene. The save tests use a throwaway `user://` directory.

This does not move the mouse. Input is covered because the mouse handlers call the same methods. A frame capture is still required when the picture changes.

## Visual checks

```bash
godot --path . --display-driver x11 --rendering-driver opengl3 \
  -s res://tools/capture_farm.gd -- --output=/tmp/finofarm-first-farm.png
```

On this cloud VM the working display was `:1` and the driver fell back to llvmpipe. Audio to ALSA fails here and Godot switches to the dummy driver. That warning is not a scene failure.

The capture proves the scene draws. It does not approve art. Compare the image to `docs/art-bible.md`. Placeholder meshes stay labeled placeholders.

There is no image-diff harness yet. FF-8 is the first human or GPU review. Add pixel diffs only after a frame is worth locking.

## Not covered yet

- Export templates and HTML5 (FF-7).
- Mouse-drag orbit in a window. The math is tested; a desktop pass should still drag once.
- Performance numbers.
- `tools/blender/export_probe.py` still only writes a throwaway cube to `/tmp`. The barn and farmhand generators are the project assets.

## Definition of done

Use the charter's list. For this repo, a task is done when the acceptance commands in its backlog row have been run on the branch, the docs that name the feature match the code, and placeholders are still called placeholders.
