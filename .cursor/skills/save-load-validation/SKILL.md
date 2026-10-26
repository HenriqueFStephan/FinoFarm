---
name: save-load-validation
description: Add or extend FinoFarm save and load tests. Use when implementing persistence, schema version, or multiple farms. The harness is not in the repo until task FF-12.
---

# Save and load validation

No save file is written today. The shape is reserved in `docs/interface-contracts.md` under "Save schema (not implemented)". Task FF-12 adds the code and the test. Do not start a second save format.

## Steps

1. Claim FF-12, or the task that depends on it, in `docs/backlog.md`.
2. Add `scripts/simulation/save_game.gd` (or a sibling) as `RefCounted` with `to_dict()` and `from_dict()`. Include `schema: 1`.
3. Round-trip `FarmInventory.snapshot()`, workshop job fields, camera numbers, `farm_id`, `farm_name`, and `region_id`.
4. Create `tests/run_save_load_tests.gd` extending `SceneTree`. Do not load `first_farm.tscn`.
5. Cases to include on the first version:
   - A saved dict loaded back compares equal.
   - Two farms saved in a row do not share inventory.
   - `schema` missing or `0` returns an error and does not apply partial data.
   - Unknown future schema (`2`) returns an error instead of guessing.
6. Add this line to `tools/validate.sh` after the simulation test:

```bash
godot --headless --path . -s res://tests/run_save_load_tests.gd
```

7. Only then may UI code call the save API. The HUD (FF-20) reads funds from the loaded dict.

## Example skeleton

```gdscript
extends SceneTree

func _initialize() -> void:
    var game = SaveGame.new()
    game.farm_name = "North Plot"
    game.funds = 40
    var copy = SaveGame.from_dict(game.to_dict())
    if copy.funds != 40 or copy.schema != 1:
        push_error("round trip")
        quit(1)
        return
    print("save checks passed")
    quit(0)
```

Replace the field names with the ones you actually shipped, and add the two-farm case. A single happy path is not FF-12.

## Constraints

- Paths under `user://` are for the game. Tests should round-trip dictionaries, and may use a temp file. Do not write into the repo.
- Do not store real-world agricultural instructions in the save. Region ids are catalog keys.
- Migration code starts when schema 2 exists. Until then, unknown schemas fail.

## Validation

```bash
godot --headless --path . -s res://tests/run_save_load_tests.gd
bash tools/validate.sh
```

Both exit 0. If the second command does not run the save script, the wiring step was skipped.
