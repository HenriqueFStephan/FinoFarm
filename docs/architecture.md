# FinoFarm architecture

## Audit of `main` before this project

Commit `1d862f4` on `main` contained only:

- `README.md`, which said gameplay had not started
- `.cursor/environment.json`
- `.cursor/install.sh`

There was no Godot project, no scene, no asset, and no design doc in the repo. That tree cannot run a stylized 3D game. It can install the tools a Godot game needs. Those bootstrap files stay. This document describes the project added on top of them.

The repo hosts a Godot 4 game: it imports, the menu loads a farm, and simulation code runs without a renderer. Saves, region data, one barn model, one rigged farmhand, a packing clerk, one textile loop (grow, bundle, pack, sell, buy a loft), a two-person crew, a second fiber good, a shuttle-rack speed upgrade, a loom rule, and a packing line are in. The grove trees, the workshop shed, the plot marker, the valley ground, the packing bench, and the clerk are a first stylized pass. It still cannot host the commercial game. The crop, loft, and shuttle rack are still placeholders. The loom worker reuses the farmhand mesh. The loom rule is a priority. The packing line is a second building whose input is a Fiber Bundle.

## ADR-001 — Godot 4.7 standard, Compatibility renderer

Decision: Godot 4.7.2 stable, official Linux editor, GDScript, renderer `gl_compatibility`.

Why: the charter asks for Godot 4 unless something else is proven better. Nothing else is in the repo. The standard build matches `.cursor/install.sh` (not the .NET build). Compatibility keeps a path to HTML5 later. Forward+ looks stronger on a desktop GPU and drops that path. Desktop play is the priority, and this scene already runs on desktop GL, including llvmpipe.

Consequences: use Godot 4 shader and scene syntax. Do not add C# project files. Do not switch the renderer without a new ADR and a captured comparison. Web export templates are not installed; that check is task FF-7, not a claim that HTML5 already works.

Verified engine string from this environment: `4.7.2.stable.official.ed1daf0bf`.

## ADR-002 — Simulation does not need a scene

Decision: economy code is `RefCounted` types under `scripts/simulation/`. Tests in `tests/run_simulation_tests.gd` never instance the farm.

Why: the charter requires timers and rewards to be testable without rendering, and to be stable if a frame is long or short.

Consequences: presentation code calls `SimStepper.step(delta_seconds)` from `FarmLoop`. It must not reimplement durations or grade rules. The loom spin reads `Workshop.is_busy()` and does not advance the job.

Tick length is 1000 ms inside `SimClock`. `advance` rounds seconds to milliseconds. Negative time does nothing. A workshop that receives extra ticks after a job finishes does not start another job by itself.

## Layout

```
project.godot
scenes/menu/main_menu.tscn
scenes/farm/first_farm.tscn
scenes/farm/farm_stage.tscn
scenes/buildings/barn.tscn
scenes/characters/farmhand.tscn
scenes/characters/workshop_worker.tscn
scenes/characters/packing_clerk.tscn
scenes/buildings/packing_bench.tscn
scripts/camera/farm_camera.gd
scripts/characters/farmhand.gd
scripts/characters/workshop_worker.gd
scripts/characters/packing_clerk.gd
scripts/farm/farm_session.gd
scripts/presentation/
scripts/ui/
scripts/simulation/
tests/run_simulation_tests.gd
tests/run_region_tests.gd
tests/run_save_load_tests.gd
tests/run_placement_tests.gd
tests/run_economy_tests.gd
tests/run_staff_tests.gd
tests/run_priority_tests.gd
tests/run_automation_tests.gd
tests/run_supply_tests.gd
tests/run_scene_checks.gd
tools/validate.sh
tools/export_desktop.sh
tools/capture_farm.gd
tools/blender/barn.py
tools/blender/farmhand.py
tools/blender/tree.py
tools/blender/workshop.py
tools/blender/plot_marker.py
tools/blender/terrain.py
tools/blender/packing_bench.py
tools/blender/packing_clerk.py
tools/generate_tones.py
assets/models/barn.glb
assets/models/farmhand.glb
assets/models/tree.glb
assets/models/workshop.glb
assets/models/loom_beam.glb
assets/models/loom_shuttle.glb
assets/models/plot_marker.glb
assets/models/terrain.glb
assets/models/packing_bench.glb
assets/models/packing_crate.glb
assets/models/packing_clerk.glb
assets/audio/harvest_tone.wav
assets/audio/loom_tone.wav
assets/audio/delivery_tone.wav
export_presets.cfg
```

Main scene is `res://scenes/menu/main_menu.tscn`. The playable farm is still `first_farm.tscn`. Import cache (`.godot/`) is gitignored. `*.uid` and `*.import` files are committed so Godot keeps resource ids. `*.glb` is Git LFS.

Autoloads: none. Add one only when two systems need a shared object and a direct reference is awkward. Do not add an autoload for the workshop ahead of the screen that uses it.

## Scene contract

`FirstFarm` instances `FarmStage`. Nodes other tasks may rely on:

- `Stage/PlaceholderTerrain`
- `Stage/Barn` (glTF instance, not a primitive)
- `Stage/Farmhand` (script `advance(delta)`, clips `idle` and `walk`)
- `Stage/FarmCamera` (script `orbit`, `zoom_by`, `pan_keys`, `pan_screen`)
- `Hud` labels bound from the save
- `PlaceholderPlotMarker`
- `WorkshopWorker` (hidden until a hire is assigned; `work` clip while the loom is busy)
- `PlaceholderShuttleRack` (hidden until `shuttle_rack` is owned)
- `PackingBench` (hidden until `pack_line` is owned)
- `PackingClerk` (hidden until a packing assignment; walks to the bench)
- `CuePlayer` (generated tones for harvest, loom start, and delivery)

Renaming these is an interface change. Update `tests/run_scene_checks.gd` and [interface contracts](interface-contracts.md) in the same commit.

## Persistence

`FarmLibrary` stores one JSON file per farm under `user://saves`, schema 1. The menu writes a farm, sets it active, and the farm scene loads that id. Direct launches with no active save stay in memory and do not create a file. See the save section of [interface contracts](interface-contracts.md).

## Performance

No budget has been measured. The ground is one imported valley mesh of 32768 triangles, plus the barn, the grove, and a handful of primitives, with one directional shadow. That is not a stress test. Do not add occlusion systems or a second terrain LOD for it.

## Agents

Project skills live in `.cursor/skills/`. Task ownership lives in [the backlog](backlog.md). Read both before editing a system someone else has claimed.
