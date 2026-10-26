# Interface contracts

Stable boundaries for Milestone 0. Change them in the same commit as the callers and the tests.

## Simulation

Scripts are `class_name` types under `scripts/simulation/`. They extend `RefCounted`. They do not reference nodes.

### `GradeScale`

- Valid grades: `1` common, `2` fine, `3` select.
- `minimum(grades)` is the lowest grade in the list.
- `label(grade)` returns `common`, `fine`, `select`, or `invalid`.

### `ResourceCatalog`

- `resources()` keys: `verdant_fiber`, `seal_wax`, `fiber_bundle`, `packed_textile`.
- `recipe(id)` returns a deep copy, or `{}` if unknown.
- Recipes today: `bundle_fiber` (4 ticks), `pack_textile` (3 ticks).
- Adding a recipe means editing the catalog and a test. Do not hard-code durations in UI code.

### `FarmInventory`

- Stacks are resource id plus grade. Grades do not merge.
- `add` returns false for amount `<= 0`, an invalid grade, or an unknown id.
- `remove` returns false when the stack is short. It does not clamp.
- `snapshot()` is the equality check for tests.

### `Workshop`

- `try_start(recipe_id, grades_by_input)` returns `""` on success.
- Failure codes: `unknown_recipe`, `missing_grade`, `bad_grade`, `missing_inputs`, `busy`.
- A failed start does not change the inventory.
- Inputs are consumed at start. Output is granted on the tick that hits zero.
- `tick(n)` finishes at most the current job. Extra ticks do not queue another craft.
- Output grade is `GradeScale.minimum` of the consumed grades.

### `SimClock` and `SimStepper`

- `SimClock.advance(seconds)` returns how many whole 1-second ticks elapsed.
- Callers may split time however they want. `4.0` once and `0.5` eight times are the same tick count.
- Negative or zero time returns `0` and does not move the clock.
- `SimStepper.step(seconds)` advances the clock and ticks the workshop that many times.
- The farm scene does not own a stepper yet. The first UI that shows production must use `SimStepper`, not its own timer.

## Presentation

### `FarmCamera` (`Camera3D`)

- `orbit(yaw_delta, pitch_delta)`
- `zoom_by(delta_distance)` clamped to 8..32
- `pan_keys(dir, delta)` where `dir.x` is right and `dir.z` is forward on the ground plane, in the camera's yaw
- `pan_screen(dx, dy)` grab-pan
- `focus`, `yaw`, `pitch`, `distance` are the state tests assert

Input already wired: right mouse or Q/E orbit, R/F pitch, middle mouse or WASD/arrows pan, wheel or +/- zoom.

At yaw `0`, forward pan moves focus toward -Z and right pan moves focus toward +X.

### `PlaceholderWalker` (`Node3D`)

- `advance(delta_seconds)` moves along the square loop at speed `1.7` and updates the limb pose.
- `_process` calls `advance`. Tests call `advance(1.0)` and expect about `1.7` units of travel.
- This script is the placeholder locomotion. A real character replaces the node, it does not grow a second movement system beside it.

## Scene nodes

See [architecture](architecture.md). Tests require `PlaceholderTerrain`, `PlaceholderBarn/Walls`, `PlaceholderBarn/Roof`, `PlaceholderBarn/Door`, `PlaceholderTreeA`, `PlaceholderWalker` with `LegL` and `LegR`, and `FarmCamera`. The terrain material must be a `ShaderMaterial`.

## Save schema (not implemented)

Task FF-12. Version field `schema` integer, starting at `1`. Proposed top-level keys, so UI work does not invent a second shape:

- `schema`
- `farm_id`
- `farm_name`
- `region_id`
- `funds`
- `inventory` (same stacking rule as `FarmInventory.snapshot`)
- `workshop` (`recipe_id`, `ticks_remaining`, `locked_grade`)
- `camera` (`focus`, `yaw`, `pitch`, `distance`)
- `tutorial_step`

No writer exists. Do not add `user://` saves until FF-12 and its round-trip test are in `tools/validate.sh`.

## Region rows (not implemented)

Task FF-11. A region is data: `id`, display name, climate label, season amplitude, property cost, upkeep modifier, infrastructure difficulty, opportunity text, challenge text. No latitude, soil chemistry, or legal rules. The four charter sketches are the first rows, with made-up gameplay numbers, clearly marked as untuned.
