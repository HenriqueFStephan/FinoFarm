# FinoFarm architecture

## Audit of `main` before this project

Commit `1d862f4` on `main` contained only:

- `README.md`, which said gameplay had not started
- `.cursor/environment.json`
- `.cursor/install.sh`

There was no Godot project, no scene, no asset, and no design doc in the repo. That tree cannot run a stylized 3D game. It can install the tools a Godot game needs. Those bootstrap files stay. This document describes the project added on top of them.

After this change, the repo can host a Godot 4 game: it imports, the main scene loads, and simulation code runs without a renderer. It still cannot host the commercial game. There is no save system, no content pipeline beyond primitives, and no UI flow.

## ADR-001 — Godot 4.7 standard, Compatibility renderer

Decision: Godot 4.7.2 stable, official Linux editor, GDScript, renderer `gl_compatibility`.

Why: the charter asks for Godot 4 unless something else is proven better. Nothing else is in the repo. The standard build matches `.cursor/install.sh` (not the .NET build). Compatibility keeps a path to HTML5 later. Forward+ looks stronger on a desktop GPU and drops that path. Desktop play is the priority, and this scene already runs on desktop GL, including llvmpipe.

Consequences: use Godot 4 shader and scene syntax. Do not add C# project files. Do not switch the renderer without a new ADR and a captured comparison. Web export templates are not installed; that check is task FF-7, not a claim that HTML5 already works.

Verified engine string from this environment: `4.7.2.stable.official.ed1daf0bf`.

## ADR-002 — Simulation does not need a scene

Decision: economy code is `RefCounted` types under `scripts/simulation/`. Tests in `tests/run_simulation_tests.gd` never instance the farm.

Why: the charter requires timers and rewards to be testable without rendering, and to be stable if a frame is long or short.

Consequences: presentation code may call `SimStepper.step(delta_seconds)`. It must not reimplement durations or grade rules. The first farm scene does not call the stepper yet. That is intentional. Milestone 0's playable promise is the camera and the walker. Wiring a hidden workshop into the scene would look like a feature that is not on screen.

Tick length is 1000 ms inside `SimClock`. `advance` rounds seconds to milliseconds. Negative time does nothing. A workshop that receives extra ticks after a job finishes does not start another job by itself.

## Layout

```
project.godot
scenes/farm/first_farm.tscn
scripts/camera/farm_camera.gd
scripts/characters/placeholder_walker.gd
scripts/simulation/
tests/run_simulation_tests.gd
tests/run_scene_checks.gd
tools/validate.sh
tools/capture_farm.gd
assets/shaders/placeholder_terrain.gdshader
```

Main scene is `res://scenes/farm/first_farm.tscn`. Import cache (`.godot/`) is gitignored. `*.uid` and `icon.svg.import` are committed so Godot keeps resource ids.

Autoloads: none. Add one only when two systems need a shared object and a direct reference is awkward. Do not add an autoload for the workshop ahead of the screen that uses it.

## Scene contract

`FirstFarm` children that other tasks may rely on:

- `PlaceholderTerrain`
- `PlaceholderBarn` with `Walls`, `Roof`, `Door`
- `PlaceholderWalker` (script `advance(delta)`)
- `FarmCamera` (script `orbit`, `zoom_by`, `pan_keys`, `pan_screen`)
- `Hud/Hint` for the control line

Renaming these is an interface change. Update `tests/run_scene_checks.gd` and [interface contracts](interface-contracts.md) in the same commit.

## Persistence

Not implemented. Milestone 1 task FF-12 adds schema version 1. Until that lands, do not write save files from experimental scripts.

## Performance

No budget has been measured. The first scene is one subdivided plane, a handful of primitives, and one directional shadow. That is not a stress test. Do not add occlusion systems or LOD for it. Do measure before replacing the terrain with a large imported mesh.

## Agents

Project skills live in `.cursor/skills/`. Task ownership lives in [the backlog](backlog.md). Read both before editing a system someone else has claimed.
