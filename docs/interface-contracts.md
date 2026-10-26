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
- `try_start` takes an optional `duration_ticks`. Values below 1 keep the catalog duration. `FarmLoop` passes `WorkerPace.bundle_ticks` for that argument. The output amount stays the recipe amount.

### `SimClock` and `SimStepper`

- `SimClock.advance(seconds)` returns how many whole 1-second ticks elapsed.
- Callers may split time however they want. `4.0` once and `0.5` eight times are the same tick count.
- Negative or zero time returns `0` and does not move the clock.
- `SimStepper.step(seconds)` advances the clock and ticks the workshop that many times.
- If `plot` is set, the same ticks also advance that `CropPlot`. A stepper with no plot does not touch growth.
- The farm scene's `FarmLoop.advance` calls `SimStepper.step`. It does not keep a second production timer.

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

### `CropPlot`

- One plot, resource `verdant_fiber`. `plant` sets stage `0` and `ticks_remaining` from `ResourceCatalog.growth`.
- Stages are `0` row, `1` sprout, `2` leaf, `3` ready. `stage_label` returns those words.
- `ticks_per_stage` is `2`. Ready is `(stage_count - 1) * ticks_per_stage` ticks after planting (6).
- The tick before that is not ready. Ticks after ready do not change the yield.
- `harvest` adds `yield_amount` `2` at the catalog grade (`common`) and clears the plot. `not_ready` does not change inventory.
- This is a visual stage timer. It is not a cultivation model.

### `OrderBoard`

- One order, `intro_bundle`: 1 `fiber_bundle`, reward `180`.
- `try_fulfill` spends the lowest grade that covers the amount.
- Failure codes: `unknown_order`, `missing_goods`, `already_done`. Funds and inventory stay as they were.
- Success returns the new fund total and sets status `done`. A second call does not pay again.

### `UpgradeShop`

- `barn_loft` costs `400`.
- `try_purchase` failure codes: `unknown_upgrade`, `short_funds`, `already_owned`. Funds stay put.
- Success subtracts the cost and sets owned.

### `TutorialTrack` and `FarmLoop`

- Steps: `0` place, `1` grow, `2` harvest, `3` workshop, `4` wait for the bundle, `5` order, `6` loft, `7` done.
- `FarmLoop` is what the farm scene calls. Harvest, bundle, deliver, and buy return `tutorial` until that step, and after `done` they stay available.
- Removing the plot during grow or harvest rewinds to place.
- `inventory_line()` is the HUD text.
- Hiring is not a tutorial step. `hire_worker` and `assign_workshop` are available to the simulation at any step. The crew button stays hidden until step `done`.

### `StaffCatalog`, `StaffRoster`, and `WorkerPace`

- Candidates: `alex_morgan` (total 33) and `bram_holt` (total 23).
- Attributes, each an integer from 1 to 10: `efficiency`, `technical`, `creativity`, `organization`, `social`, `adaptability`.
- `WorkerPace.bundle_ticks` is the rule. Empty worker: catalog duration for `bundle_fiber` (4). Otherwise `max(1, catalog_duration - floor(attribute_total / 12))`.
- Alex's total finishes a bundle in 2 ticks. Bram's finishes in 3. The output amount stays 1.
- A running job keeps the ticks it started with. Reassigning does not edit it.
- `hire` failure codes: `unknown_worker`, `already_hired`. `assign_workshop` failure codes: `unknown_worker`, `not_hired`. Failures do not change the roster.
- Listed `wage` is not subtracted from funds.

### `FarmHud`

- `bind(game)` sets the name, the region display name, and `Funds <n>` from the save.
- `refresh(game, loop, barn_selected)` also sets the inventory line, Mara's prompt, and the last economy event from `FarmLoop`.
- It does not keep its own copy of the numbers.
- `CrewButton` is hidden until the tutorial step is `done`. The crew card reads names, ratings, and bundle ticks from `StaffCatalog` and `WorkerPace`.

## Scene nodes

The main scene is `res://scenes/menu/main_menu.tscn`. The playable farm is `res://scenes/farm/first_farm.tscn` and instances `scenes/farm/farm_stage.tscn`.

Tests require `Stage/PlaceholderTerrain` (shader material), `Stage/Barn` (imported mesh), `Stage/PlaceholderTreeA`, `Stage/Farmhand` (skeleton, `idle`, `walk`), `Stage/FarmCamera`, `PlaceholderPlotMarker`, `PlaceholderCrop`, `PlaceholderWorkshop`, `PlaceholderBarnLoft`, `WorkshopWorker` (`work` clip), and `Hud`. `PlaceholderBarn` and `PlaceholderWalker` are gone.

`PlaceholderWorkshop` sits at `WorkshopRig.WORLD_POSITION` `(6.4, 0, 2.8)`. `advance(delta, false)` does not spin the loom. `advance(delta, true)` does. The scene sets `operating` from `Workshop.is_busy()`.

`WorkshopWorker` stands in front of that shed. It is hidden until someone is assigned. While the loom is busy it plays the imported `work` clip. While assigned and idle it plays `idle`. `WorkerName` is that person's name. The mesh is the same farmhand glTF, not a second character. The path `Farmhand` is still not an employee.

`PlaceholderBarnLoft` starts hidden. It is shown when `barn_loft` is owned. The mesh is a placeholder.

`PlaceholderCrop` follows the marker. `show_stage` hides it when the name is `empty`, and shows the ready tuft only for `ready`.

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
- `plot` (`planted`, `resource_id`, `stage`, `ticks_remaining`, `grade`). Missing or `{}` means not planted.
- `orders` (`intro_bundle` is `open` or `done`). Missing or `{}` means the intro order is open.
- `upgrades` (bool flags, currently `barn_loft`). Missing or `{}` means nothing is owned.
- `staff` (`hired` is an array of catalog ids, `workshop` is `""` or one of those ids). Missing or `{}` means nobody is hired and the bench is unassigned.

A plot stage outside `0..3`, a bad grade, an unknown order id, a non-bool upgrade value, an unknown worker id, a duplicate hire, or a workshop id that was not hired is rejected. Schema `2` is still rejected. Old schema-1 files that omit `plot`, `orders`, `upgrades`, or `staff` still load.

`create_new` requires a non-empty name of at most 32 characters and a catalog region. Starting funds are `RegionCatalog.PURSE - property_cost` (purse `500`, untuned). The file also stores 4 common Verdant Fiber so the inventory snapshot is real. That stack is not a grow recipe.

`FarmLibrary` writes `user://saves/<farm_id>.json` plus `index.json` (`order`, `active_id`). Tests pass a different `root_path`. `write` makes that farm active.

## Region rows

`RegionCatalog` is data. Fields: `id`, `display_name`, `climate_label`, `season_amplitude`, `property_cost`, `upkeep_modifier`, `infrastructure_difficulty`, `opportunity`, `challenge`, `starting_funds`, `map_x`, `map_y`. No latitude, soil, statute, or cultivation fields.

Ids: `northern_homestead`, `tropical_valley`, `innovation_plains`, `golden_fields`. Numbers are untuned gameplay tuning. `map_x` and `map_y` are layout fractions for the menu, not geography.
