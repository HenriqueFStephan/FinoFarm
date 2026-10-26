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
7. `godot --headless --path . -s res://tests/run_economy_tests.gd`
8. `godot --headless --path . -s res://tests/run_staff_tests.gd`
9. `godot --headless --path . -s res://tests/run_priority_tests.gd`
10. `godot --headless --path . -s res://tests/run_automation_tests.gd`
11. `godot --headless --path . -s res://tests/run_scene_checks.gd`

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

## What the economy tests cover

`tests/run_economy_tests.gd` also extends `SceneTree` and does not load the farm scene.

- Growth timing comes from the catalog. The plot is not ready one tick early. Extra ticks do not raise the yield.
- A failed harvest leaves inventory alone.
- Six seconds in one step and twelve half-seconds leave the same plot stage.
- A missing Fiber Bundle does not pay. A paid order does not pay twice.
- 399 funds cannot buy the loft. 400 can, and a second buy does not charge again.
- Tropical Valley cannot afford the loft before the sale. Innovation Plains can afford it after one order.
- `FarmLoop` walks place, grow, harvest, bundle, deliver, and buy, and ends on the done step.
- Plot, order, and upgrade state round-trip. A schema-1 dict without those keys still loads. Stage `9` is rejected.

## What the staff tests cover

`tests/run_staff_tests.gd` does not load the farm scene.

- Two candidates expose the six ratings, each from 1 to 10. Editing a returned copy does not change the catalog.
- Attribute totals change `bundle_fiber` duration. An empty assignee keeps the catalog's 4 ticks.
- Alex and Bram, run for the shorter of their two durations, do not share an inventory snapshot. One has a bundle and the other does not.
- The tick before completion does not grant the bundle. One call of the full duration and twice as many half-second steps match.
- Unknown hires, a second hire, and assigning someone who is not hired leave the roster alone.
- Switching the assignee does not change ticks already on the loom. Hiring does not change funds.
- Hired ids and the workshop assignee round-trip. A file without `staff` loads empty. Unknown ids, duplicates, and an assignee who was not hired are rejected.
- Mara's eight prompt strings are unchanged.

## What the priority tests cover

`tests/run_priority_tests.gd` does not load the farm scene.

- `twist_cord` spends the same Verdant Fiber harvest as `bundle_fiber`. The yield is smaller than the sum of the two input amounts.
- `lane_cord` pays 240. `intro_bundle` still pays 180.
- After one harvest is turned into a bundle, the cord order does not pay and the cord recipe does not start. The reverse is also true.
- The inventory line names Fiber Bundle and Fiber Cord, including zero.
- The shuttle rack costs 160, refuses 159, does not edit a running job, and shortens the next job by one tick.
- Alex and Bram still finish a bundle on different ticks. The cord uses the same attribute rule.
- The cord and the rack stay locked until Mara's lesson is done. Schema stays `1`. A save that only stored the intro order loads the cord order as open.

## What the automation tests cover

`tests/run_automation_tests.gd` does not load the farm scene.

- `loom_rule` costs 120. A purse of 119 does not unlock it. A second buy does not charge again. The buy is refused during Mara's lesson.
- A Fiber Bundle priority starts `bundle_fiber`. A Fiber Cord priority starts `twist_cord`. Both require the unlock, a ready plot, and an assigned worker.
- Changing priority while a job is running leaves that recipe and its remaining ticks. After the job finishes, the next ready plot follows the new priority.
- Without the unlock, the player still harvests and starts by hand. With nobody assigned, the rule does not harvest.
- Forcing the unlock during the lesson does not start the loom. The harvest and the bundle button still advance Mara's steps.
- Alex's automatic bundle still finishes before Bram's. One automatic harvest still cannot pay both orders.
- A schema-1 file with no `research` key loads locked. Schema stays `1`.

## What the scene checks cover

`tests/run_scene_checks.gd` loads scenes after the tree is up (`call_deferred`, because `_initialize` runs too early).

- Main scene path is the menu.
- The farm has placeholder terrain, an imported barn mesh, three imported trees, the farmhand, and the camera.
- The workshop shed, loom beam, shuttle, and plot marker are imported glTF files. Row, sprout, leaf, and ready on the fiber plot stay distinct.
- The farmhand has a skeleton. `walk` and `idle` exist. `advance(1.0)` moves about `1.7` units and leaves `walk` playing.
- The HUD name, region, and funds come from a save written in the test.
- A saved marker appears on its cell. The player can move it, remove it, and a barn cell selects the barn instead.
- Zoom clamps, orbit distance holds, and yaw-0 pan matches the contract.
- The menu exposes Continue, My Farms, New Game, Settings, Credits, and Exit. Continue starts disabled. Two created farms show as cards. Region markers render the catalog fields.
- The workshop, crop, and loft nodes exist. The loft starts hidden. The crop mesh follows the stage name. The loom does not move while idle and does move while operating.
- `play_intro_cycle` on that farm changes funds by `+180 - 400`, shows the loft, and leaves the order delivered.
- Crew is hidden on the opening step. After the lesson, hiring Alex and assigning them shows `WorkshopWorker`, and starting the loom plays `work`.
- `ResearchButton` is hidden during the lesson. After the lesson it is shown, the purchase hides it, and the priority buttons appear. Setting a cord priority does not replace the bundle already on the loom.

`tests/run_region_tests.gd`, `tests/run_save_load_tests.gd`, and `tests/run_placement_tests.gd` do not instance a 3D scene. The save tests use a throwaway `user://` directory.

This does not move the mouse. Input is covered because the mouse handlers call the same methods. A frame capture is still required when the picture changes.

## Visual checks

```bash
godot --path . --display-driver x11 --rendering-driver opengl3 \
  -s res://tools/capture_farm.gd -- --output=/tmp/finofarm-first-farm.png
```

On this cloud VM the working display was `:1` and the driver fell back to llvmpipe. Audio to ALSA fails here and Godot switches to the dummy driver. That warning is not a scene failure.

The capture proves the scene draws. It does not approve art. Compare the image to `docs/art-bible.md`. A first stylized pass stays labeled that way. Placeholder meshes stay labeled placeholders.

There is no image-diff harness yet. FF-8 is the first human or GPU review. Add pixel diffs only after a frame is worth locking.

## Not covered yet

- Export templates and HTML5 (FF-7).
- Mouse-drag orbit in a window. The math is tested; a desktop pass should still drag once.
- Performance numbers.
- `tools/blender/export_probe.py` still only writes a throwaway cube to `/tmp`. The barn, farmhand, tree, workshop, and plot-marker generators are the project assets.

## Definition of done

Use the charter's list. For this repo, a task is done when the acceptance commands in its backlog row have been run on the branch, the docs that name the feature match the code, and placeholders are still called placeholders.
