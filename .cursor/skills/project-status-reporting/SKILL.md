---
name: project-status-reporting
description: Write a FinoFarm milestone or task status report from commands that were actually run. Use when closing a milestone, opening a PR, or handing status to the product director.
---

# Project status reporting

Reports describe verified state. A compile is not a finished feature. A placeholder mesh is not final art.

## Steps

1. Read `docs/backlog.md` and `docs/roadmap.md` before writing status, and update the rows you finished.
2. Run the acceptance command in the task row. Paste the command and the exit result. If you did not run it, say it was not run.
3. List player-visible behavior in one paragraph, then list what is still placeholder by the names in `docs/art-bible.md`.
4. Link captures by path. Do not claim a screenshot that is not on disk.
5. Note the Godot version from `godot --version`, not from memory of the install script.
6. State the next milestone and the task ids that block it.
7. Put durable design changes in `docs/`, not only in the report. The charter copy in `docs/charter.md` stays the vision; do not silently rewrite it.

## Example

A Milestone 0 report includes: audit of `main`, engine version string, `bash tools/validate.sh` result, simulation `12 passed, 0 failed`, scene check line, capture path, and an explicit list that the barn, trees, terrain shader, and walker are placeholders.

## Constraints

- Do not mark a backlog row `done` while its acceptance command fails.
- Do not report HTML5 as working. That is FF-7 and it has not been run unless the report shows the export command.
- Keep the report short enough that a person can see the gap. Link the docs instead of pasting them.

## Validation

```bash
godot --version
bash tools/validate.sh
```

The report's version string and test counts must match that output from the same checkout.
