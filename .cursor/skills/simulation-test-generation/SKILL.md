---
name: simulation-test-generation
description: Add headless FinoFarm simulation tests that do not render. Use when adding a timer, inventory rule, recipe, grade, or save-independent game rule.
---

# Simulation test generation

`tests/run_simulation_tests.gd` is the pattern. It extends `SceneTree`, never calls `load` on a `.tscn`, and exits non-zero when a check returns a reason string.

## Steps

1. Add a `_check("snake_case_name", _your_case)` line in `_initialize`.
2. Write `_your_case() -> String`. Return `""` on success and a short reason on failure. Do not `assert` and continue; the runner needs the reason.
3. Build state with `FarmInventory.new()`, `Workshop.new`, `SimClock.new`, and `SimStepper.new`. Use `ResourceCatalog.recipe` for durations so a silent catalog edit fails the catalog test and the behavior test.
4. Cover the failure path that must not mutate state, the exact tick the job completes, and one off-by-one tick before that.
5. If time is involved, assert two different slices (one call versus many) land on the same `snapshot()`, `tick_index`, and `remainder_ms`.
6. Keep resource ids inside the catalog. Do not invent a real-world crop name to make a test more specific.

## Example

`_no_repeat` starts one bundle job, calls `tick(100)`, and requires the output amount to stay `1`. Copy that shape for any new job queue.

## Constraints

- Do not instance `first_farm.tscn` here. Scene behavior belongs in `tests/run_scene_checks.gd`.
- `class_name` types are registered after `godot --headless --path . --import --quit`. `tools/validate.sh` imports first. A lone test run on a fresh clone still works once `.godot/` exists; the script always imports.
- Godot 4 `Array` from a catalog dictionary is a copy only if `recipe()` duplicated it. Mutate the copy in a test and confirm the next `recipe()` call is unchanged if you add that case.

## Validation

```bash
godot --headless --path . -s res://tests/run_simulation_tests.gd
bash tools/validate.sh
```

Expected tail of the simulation process: `N passed, 0 failed` and exit code 0. Any `not ok` line is a failure even if a later bug hides the exit code. The script uses `quit(1)` when `_failed > 0`.
