# FinoFarm architecture

## Audit of `main` before this project

Commit `1d862f4` on `main` contained only:

- `README.md`, which said gameplay had not started
- `.cursor/environment.json`
- `.cursor/install.sh`

There was no Godot project, no scene, no asset, and no design doc in the repo. That tree cannot run a stylized 3D game. It can install the tools a Godot game needs. Those bootstrap files stay. This document describes the project added on top of them.

The repo hosts a Godot 4 game: it imports, the menu loads a farm, and simulation code runs without a renderer. Saves, region data, one barn model, one rigged character, one textile loop (grow, bundle, sell, buy a loft), and a two-person crew are in. It still cannot host the commercial game. The terrain, crop, workshop, and loft are still placeholders. The loom worker reuses the farmhand mesh.

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
scripts/camera/farm_camera.gd
scripts/characters/farmhand.gd
scripts/characters/workshop_worker.gd
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
tests/run_scene_checks.gd
tools/validate.sh
tools/capture_farm.gd
tools/blender/barn.py
tools/blender/farmhand.py
assets/models/barn.glb
assets/models/farmhand.glb
assets/shaders/placeholder_terrain.gdshader
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

Renaming these is an interface change. Update `tests/run_scene_checks.gd` and [interface contracts](interface-contracts.md) in the same commit.

## Persistence

`FarmLibrary` stores one JSON file per farm under `user://saves`, schema 1. The menu writes a farm, sets it active, and the farm scene loads that id. Direct launches with no active save stay in memory and do not create a file. See the save section of [interface contracts](interface-contracts.md).

## Performance

No budget has been measured. The first scene is one subdivided plane, a handful of primitives, and one directional shadow. That is not a stress test. Do not add occlusion systems or LOD for it. Do measure before replacing the terrain with a large imported mesh.

## Agents

Project skills live in `.cursor/skills/`. Task ownership lives in [the backlog](backlog.md). Read both before editing a system someone else has claimed.
