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

### `Farmhand` (`Node3D`, `scripts/characters/farmhand.gd`)

- `advance(delta_seconds)` moves along the square loop at speed `1.7`.
- `_process` calls `advance`. Tests call `advance(1.0)` and expect about `1.7` units of travel.
- While speed is positive the imported `walk` clip plays. `advance(0)` or a non-positive delta plays `idle`.
- The glTF skin moves the limbs. There is no sine-wave pose beside the clip.
- `animation_player()` returns the imported `AnimationPlayer`.

### `PlotGrid`

- `CELL` is `2`. Cells clamp to `-4..4`.
- `snap_cell(world_x, world_z)` rounds to the nearest cell. `cell_center` is `(x * 2, 0, z * 2)`.
- Cells with `abs(x) <= 1` and `abs(z) <= 1` are `blocked` (the barn pad).
- One marker. `place_at` sets it, `move_to` requires one, `remove` clears it.
- `ground_hit(origin, direction)` intersects the y=0 plane. Upward rays miss.
- `to_save()` is `{}` or `{x, z}`.

### `FarmHud`

- `bind(game)` sets the name, the region display name, and `Funds <n>` from the save.
- It does not keep its own copy of the numbers.

## Scene nodes

The main scene is `res://scenes/menu/main_menu.tscn`. The playable farm is `res://scenes/farm/first_farm.tscn` and instances `scenes/farm/farm_stage.tscn`.

Tests require `Stage/PlaceholderTerrain` (shader material), `Stage/Barn` (imported mesh), `Stage/PlaceholderTreeA`, `Stage/Farmhand` (skeleton, `idle`, `walk`), `Stage/FarmCamera`, `PlaceholderPlotMarker`, and `Hud`. `PlaceholderBarn` and `PlaceholderWalker` are gone.

The menu has `ContinueButton`, `MyFarmsButton`, `NewGameButton`, `SettingsButton`, `CreditsButton`, and `ExitButton` over the same stage.

## Save schema 1

`SaveGame.SCHEMA` is `1`. `from_dict` returns `{ok, error, game}`. A missing schema, schema `0`, or any schema other than `1` returns `game: null` and does not apply the other fields.

Keys:

- `schema`
- `farm_id`
- `farm_name`
- `region_id`
- `funds`
- `level` (new farms are `1`)
- `playtime_seconds`
- `last_saved_unix`
- `inventory` (`FarmInventory.snapshot()` keys, `resource#grade`)
- `workshop` (`recipe_id`, `ticks_remaining`, `locked_grade`)
- `camera` (`focus` as three numbers, `yaw`, `pitch`, `distance`)
- `tutorial_step`
- `marker` (`{}` or `{x, z}`)

`create_new` requires a non-empty name of at most 32 characters and a catalog region. Starting funds are `RegionCatalog.PURSE - property_cost` (purse `500`, untuned). The file also stores 4 common Verdant Fiber so the inventory snapshot is real. That stack is not a grow recipe.

`FarmLibrary` writes `user://saves/<farm_id>.json` plus `index.json` (`order`, `active_id`). Tests pass a different `root_path`. `write` makes that farm active.

## Region rows

`RegionCatalog` is data. Fields: `id`, `display_name`, `climate_label`, `season_amplitude`, `property_cost`, `upkeep_modifier`, `infrastructure_difficulty`, `opportunity`, `challenge`, `starting_funds`, `map_x`, `map_y`. No latitude, soil, statute, or cultivation fields.

Ids: `northern_homestead`, `tropical_valley`, `innovation_plains`, `golden_fields`. Numbers are untuned gameplay tuning. `map_x` and `map_y` are layout fractions for the menu, not geography.
