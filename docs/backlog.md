# FinoFarm backlog

Source of truth for task ids when GitHub is unavailable. If an issue exists, its body links here and the row's Issue column links back. Do not keep a second list in a chat.

Prefix `FF` matches the project task ids.

## Ownership

1. Read this file and the open `FF-*` issues before editing the repo.
2. A task has one owner. The owner is the agent or person named in the issue and in this table.
3. Claim a `queued` task by setting the row to `claimed`, putting your agent id in Owner, and commenting on the issue, before you create a branch for it. If you cannot edit the issue, the table change is the claim.
4. Do not open a second implementation branch for a task that is `claimed` or `in_progress`.
5. If two tasks need the same scene or resource, land the interface in `docs/interface-contracts.md` first, then build on opposite sides of it.
6. The product director can reassign. A coordinator may reassign a claim that has no commit and no issue comment from the owner.
7. Move a task to `done` only after the acceptance command has been run and the result is in the pull request.
8. Parallel experiments need an explicit request. They use different task ids.

Status values: `queued`, `claimed`, `in_progress`, `in_review`, `blocked`, `done`.

## Milestone 0

| Id | Issue | Title | Owner | Status | Depends on | Acceptance |
| --- | --- | --- | --- | --- | --- | --- |
| FF-3 | [PR #1](https://github.com/HenriqueFStephan/FinoFarm/pull/1) | Godot project, first farm scene, docs, skills, validation | `bc-33ae2792-3a45-50a2-ae00-e2e1dc389991` | in_review | environment bootstrap on `main` | `bash tools/validate.sh` exits 0. Main scene is the farm. Placeholders are labeled in `docs/art-bible.md`. |
| FF-7 | [#2](https://github.com/HenriqueFStephan/FinoFarm/issues/2) | Record HTML5 export constraints | unassigned | queued | FF-3 | Official export templates installed. One headless export attempt logged, including the error if templates or the Compatibility renderer block it. No claim of a playable browser build without a successful export. |
| FF-8 | [#3](https://github.com/HenriqueFStephan/FinoFarm/issues/3) | GPU review of the first farm frame | unassigned | queued | FF-3 | A desktop GPU capture compared to the art bible. Result is accept as block-out or a defect list. Does not reclassify primitives as final art. |
| FF-9 | [#4](https://github.com/HenriqueFStephan/FinoFarm/issues/4) | Require the Validate workflow on `main` | product director | queued | FF-3 merged and Actions green | Branch protection requires `Validate`. Agents do not flip this setting themselves. |

## Milestone 1

| Id | Issue | Title | Owner | Status | Depends on | Acceptance |
| --- | --- | --- | --- | --- | --- | --- |
| FF-11 | [#5](https://github.com/HenriqueFStephan/FinoFarm/issues/5) | Region catalog | `bc-8c016ab1-953f-5404-9ef6-5a48e500e77b` | in_review | FF-3 | Four regions load from data. A test reads costs and labels without a scene. Copy stays fictional. |
| FF-12 | [#6](https://github.com/HenriqueFStephan/FinoFarm/issues/6) | Save schema v1 and round-trip tests | `bc-8c016ab1-953f-5404-9ef6-5a48e500e77b` | in_review | FF-11 | `tests/run_save_load_tests.gd` is wired into `tools/validate.sh`. Two farms reload without mixing. Schema field is `1`. |
| FF-13 | [#7](https://github.com/HenriqueFStephan/FinoFarm/issues/7) | 3D main menu | `bc-8c016ab1-953f-5404-9ef6-5a48e500e77b` | in_review | FF-3 | Menu scene shows Continue, My Farms, New Game, Settings, Credits, Exit over a 3D farm view. Headless scene check loads it. |
| FF-14 | [#8](https://github.com/HenriqueFStephan/FinoFarm/issues/8) | Farm selector cards | `bc-8c016ab1-953f-5404-9ef6-5a48e500e77b` | in_review | FF-12, FF-13 | Cards show name, region, level, funds, playtime, last save. At least two saves can be opened. |
| FF-15 | [#9](https://github.com/HenriqueFStephan/FinoFarm/issues/9) | New farm creation | `bc-8c016ab1-953f-5404-9ef6-5a48e500e77b` | in_review | FF-11, FF-12, FF-13 | Name and region are required. Confirm writes a schema-1 save. |
| FF-16 | [#10](https://github.com/HenriqueFStephan/FinoFarm/issues/10) | World map and region choice | `bc-8c016ab1-953f-5404-9ef6-5a48e500e77b` | in_review | FF-11, FF-15 | Map markers come from the catalog. Selection shows the contract fields and returns the chosen id. |
| FF-17 | [#11](https://github.com/HenriqueFStephan/FinoFarm/issues/11) | Grid placement of one marker | `bc-8c016ab1-953f-5404-9ef6-5a48e500e77b` | in_review | FF-3 camera contract | Player places, moves, and removes one marker on a grid in the farm scene. A headless test checks the snap math without a screenshot. |
| FF-18 | [#12](https://github.com/HenriqueFStephan/FinoFarm/issues/12) | Modeled barn | `bc-8c016ab1-953f-5404-9ef6-5a48e500e77b` | in_review | FF-3 art bible | `barn` registry row is not `placeholder`. Scene instances a glTF. A capture shows it in the farm. |
| FF-19 | [#13](https://github.com/HenriqueFStephan/FinoFarm/issues/13) | Rigged walking character | `bc-8c016ab1-953f-5404-9ef6-5a48e500e77b` | in_review | FF-3 art bible | Registry row is not `placeholder`. An imported walk clip plays while the character moves. The procedural sine swing is gone. |
| FF-20 | [#14](https://github.com/HenriqueFStephan/FinoFarm/issues/14) | Basic farm HUD | `bc-8c016ab1-953f-5404-9ef6-5a48e500e77b` | in_review | FF-12 | HUD shows farm name, region, and funds from the save, not a hard-coded number that ignores the file. |

## Milestone 2

No new GitHub issues. These rows are the claim. `gh issue comment` is not required for them.

| Id | Issue | Title | Owner | Status | Depends on | Acceptance |
| --- | --- | --- | --- | --- | --- | --- |
| FF-21 | — | Verdant Fiber growth on the placed plot | `bc-a268dd57-bf1b-5371-92d3-52cfc3253aa2` | in_review | FF-17 | `tests/run_economy_tests.gd` checks the tick the plot becomes ready, and that an early harvest does not change inventory. The farm scene shows row, sprout, leaf, and ready meshes. |
| FF-22 | — | Inventory on the farm HUD | `bc-a268dd57-bf1b-5371-92d3-52cfc3253aa2` | in_review | FF-12, FF-20 | The HUD line is built from `FarmInventory`, including grade. |
| FF-23 | — | Textile workshop with a loom animation | `bc-a268dd57-bf1b-5371-92d3-52cfc3253aa2` | in_review | FF-3, FF-21 | The scene starts `bundle_fiber` through `SimStepper`. The loom arm moves while the job is busy and stays still when it is idle. |
| FF-24 | — | Order board and currency | `bc-a268dd57-bf1b-5371-92d3-52cfc3253aa2` | in_review | FF-23 | Delivering `intro_bundle` adds 180 funds once. Missing goods do not pay or consume. |
| FF-25 | — | Barn loft purchase | `bc-a268dd57-bf1b-5371-92d3-52cfc3253aa2` | in_review | FF-24 | Cost is 400. Tropical Valley (richest start) cannot buy before the sale. The loft mesh is hidden until the purchase. It is a placeholder. |
| FF-26 | — | Guided tutorial for one full cycle | `bc-a268dd57-bf1b-5371-92d3-52cfc3253aa2` | in_review | FF-21, FF-23, FF-24, FF-25 | `FarmLoop` reaches tutorial step done only after place, grow, harvest, bundle, deliver, and buy. |
| FF-27 | — | Save the loop on schema 1 | `bc-a268dd57-bf1b-5371-92d3-52cfc3253aa2` | in_review | FF-12 | A file without `plot`, `orders`, and `upgrades` still loads. A plot stage outside 0..3 is rejected. Schema `2` is still rejected. |

GitHub issues #2 through #14 were opened for Milestone 0 and 1. This file remains the ownership record. Claim a row here before coding. Milestone 2 is claimed in the table above and does not have duplicate issues.

## Dependency sketch

```
FF-3
  ├─ FF-7, FF-8, FF-9
  ├─ FF-11 ─ FF-12 ─ FF-14
  │    │        └─ FF-15 ─ FF-16
  │    └─ FF-20
  ├─ FF-13 ─ FF-14
  │    └─ FF-15
  ├─ FF-17 ─ FF-21 ─ FF-23 ─ FF-24 ─ FF-25
  │              └─ FF-26
  ├─ FF-18
  └─ FF-19
```

FF-22 hangs off FF-12 and FF-20. FF-27 hangs off FF-12. FF-26 needs the four player steps, not a new scene of its own.

FF-18 and FF-19 are independent of the menu. They still share `first_farm.tscn` unless they instance child scenes. Child scenes are the default.

## Environment

| Id | Where it should run |
| --- | --- |
| FF-3 | Cloud or local. Needs Godot. A display is only for the capture. |
| FF-7 | Cloud, with network access to official Godot templates. |
| FF-8, FF-13, FF-18, FF-19 | Prefer a display. Headless import is necessary and not sufficient. |
| FF-11, FF-12, FF-17 math, FF-21 through FF-27 rules | Cloud. Economy tests must not require rendering. The cycle screenshot needs a display. |
| FF-9 | Human admin on GitHub. |
