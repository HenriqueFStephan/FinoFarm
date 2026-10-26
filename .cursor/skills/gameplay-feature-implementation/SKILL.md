---
name: gameplay-feature-implementation
description: Implement a FinoFarm gameplay feature across simulation and scenes. Use when adding player-facing rules, UI that changes state, or a new resource flow.
---

# Gameplay feature implementation

Rules live in `scripts/simulation/` or a new sibling folder of `RefCounted` types. Scenes display those rules. A scene-only timer is a bug.

## Steps

1. Claim the task id in `docs/backlog.md` using the ownership rules.
2. Read `docs/game-design.md` and `docs/interface-contracts.md`. If the feature needs a new public method, edit the contract first.
3. Write the failing headless test before the feature, in `tests/run_simulation_tests.gd` or a new `tests/run_<feature>_tests.gd` that does not load a 3D scene.
4. Implement the rule. Fictional resources, tick durations, grades, and recipes only. No real cultivation, extraction, dosage, or controlled-substance method.
5. Call the rule from the scene or UI. Do not copy the formula into GDScript on a node.
6. If the player can see it, add the minimum feedback (motion, a number from the save, a highlight). A button that changes nothing is not the feature.
7. Update the design doc only where the shipped behavior differs from the written rule.

## Example

The workshop already returns `missing_inputs` without consuming stacks. A future crafting button must show that string's meaning in the UI and must call `Workshop.try_start`. It must not subtract inventory itself.

## Constraints

- Milestone 1 does not include the order loop. Milestone 2 is that loop: `FarmLoop`, the fiber plot, the bundle workshop, `intro_bundle`, and the barn loft. Do not add a second order board beside it.
- One owner per task. Placement (FF-17) and the barn model (FF-18) do not edit the same scene nodes.
- Keep `bash tools/validate.sh` green. Wire a new test runner into that script or it will not run in CI.

## Validation

```bash
godot --headless --path . -s res://tests/run_simulation_tests.gd
bash tools/validate.sh
```

The feature's new assertions must print `ok` in that output. A scene that compiles while the test fails is not done.
