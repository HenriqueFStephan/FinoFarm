---
name: cloud-agent-task-handoffs
description: Write a FinoFarm handoff another agent can execute. Use when delegating a backlog task, splitting work, or pausing without a finished branch.
---

# Cloud-agent task handoffs

A handoff is a claim that the work is specified, not that it is running. Say which of those is true.

## Steps

1. Pick a task id from `docs/backlog.md` whose dependencies are `done` or already in the branch the agent will use.
2. Confirm the row is `queued`. Set it to `claimed` with the target agent id, or leave it `queued` and write "not claimed" in the handoff. Do not claim it in two places.
3. Give the agent its own branch name. Do not tell two agents to commit to the same branch.
4. Include every field below. Omit nothing by saying "see the charter".
5. If you cannot launch the agent, store the handoff and say it was not started.

## Required fields

- Task id and title.
- Target agent role (gameplay, art, character, UI, test, build).
- Objective in one paragraph.
- Context docs to read first (`docs/art-bible.md`, `docs/interface-contracts.md`, and the task's section of `docs/vertical-slice-m1.md` when it is Milestone 1).
- Branch to create, based on current `main` or the named parent branch.
- Input files.
- Dependencies and what is already in the tree.
- Output files.
- Acceptance criteria copied from the backlog row.
- Verification commands, usually `bash tools/validate.sh` plus a capture or a new test script.
- Integration: which scene instances the result, and who owns `first_farm.tscn`.

## Example

FF-11 handoff: edit only a new `scripts/simulation/regions.gd` and `tests/run_region_tests.gd`. Do not open `first_farm.tscn`. Acceptance is a headless test that reads four region ids and refuses a real-world soil or legal field. Verification:

```bash
godot --headless --path . -s res://tests/run_region_tests.gd
bash tools/validate.sh
```

Wire the new test into `tools/validate.sh` in the same change.

## Constraints

- Cloud agents can run Godot headless and Blender background mode in this environment after `bash .cursor/install.sh`. They need a display for `tools/capture_farm.gd`.
- Do not hand off FF-9. Branch protection is a human admin action.
- Do not ask an agent to implement realistic cultivation. The abstraction rule in `docs/game-design.md` applies to every handoff.
- Parallelize FF-18 and FF-19 only if each writes its own scene file and the integration step is a third, explicit task.

## Validation

The handoff is valid when another person can run the verification commands without asking a question that the handoff should have answered. After the agent finishes, the parent runs those commands again on the branch. A handoff is not a passing test.
