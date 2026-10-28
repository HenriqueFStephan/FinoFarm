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

## Milestone 3

No new GitHub issues. These rows are the claim.

| Id | Issue | Title | Owner | Status | Depends on | Acceptance |
| --- | --- | --- | --- | --- | --- | --- |
| FF-28 | — | Six-attribute recruitment list | `bc-826286b1-5907-533a-9ac4-a9cb0f775a86` | in_review | FF-26 | `tests/run_staff_tests.gd` lists Alex Morgan and Bram Holt. Each of the six ratings is from 1 to 10. |
| FF-29 | — | Hire into schema 1 | `bc-826286b1-5907-533a-9ac4-a9cb0f775a86` | in_review | FF-12, FF-28 | A file without `staff` still loads. Hired ids round-trip. Unknown ids and duplicates are rejected. Schema stays `1`. |
| FF-30 | — | Workshop assignment changes bundle time | `bc-826286b1-5907-533a-9ac4-a9cb0f775a86` | in_review | FF-23, FF-28 | Two different assignments do not share an inventory snapshot at the shorter duration. An unassigned bench keeps the catalog's 4 ticks. |
| FF-31 | — | Worker visible at the loom | `bc-826286b1-5907-533a-9ac4-a9cb0f775a86` | in_review | FF-19, FF-30 | The scene check hides `WorkshopWorker` until assign, then plays `work` while the job is busy. The mesh is the farmhand again, not finished art. |
| FF-32 | — | Crew panel after Mara's lesson | `bc-826286b1-5907-533a-9ac4-a9cb0f775a86` | in_review | FF-26, FF-29 | Mara's prompt strings stay put. The crew button is hidden on the place step and shown after done. |

GitHub issues #2 through #14 stay the Milestone 0 and 1 issues. Milestone 3 does not add another issue for the same work.

## Milestone 4

No new GitHub issues. These rows are the claim.

| Id | Issue | Title | Owner | Status | Depends on | Acceptance |
| --- | --- | --- | --- | --- | --- | --- |
| FF-33 | — | Fiber Cord competes for Verdant Fiber | `bc-a2d85e29-8871-5ee1-9ab2-e3bf95968b2b` | in_review | FF-21, FF-23 | `tests/run_priority_tests.gd` shows `twist_cord` spends the same harvest amount as `bundle_fiber`. |
| FF-34 | — | Lane order pays a different amount | `bc-a2d85e29-8871-5ee1-9ab2-e3bf95968b2b` | in_review | FF-24, FF-33 | `lane_cord` pays 240. `intro_bundle` still pays 180. A missing save key loads the new order as open. Schema stays `1`. |
| FF-35 | — | One harvest cannot fill both orders | `bc-a2d85e29-8871-5ee1-9ab2-e3bf95968b2b` | in_review | FF-33, FF-34 | Turning one harvest into either good leaves the other order unpaid and the other recipe short of inputs. |
| FF-36 | — | Inventory shows both goods | `bc-a2d85e29-8871-5ee1-9ab2-e3bf95968b2b` | in_review | FF-22, FF-33 | `inventory_line()` names Fiber Bundle and Fiber Cord, including a zero count. |
| FF-37 | — | Shuttle rack changes loom speed | `bc-a2d85e29-8871-5ee1-9ab2-e3bf95968b2b` | in_review | FF-25, FF-30 | The rack costs 160, does not change a running job, and the next job is one tick faster. Alex and Bram still differ. The mesh starts hidden. |

GitHub issues #2 through #14 stay the Milestone 0 and 1 issues. Milestone 4 does not add another issue for the same work.

## Milestone 5

No new GitHub issues. These rows are the claim. This slice is the loom rule, not the rest of the charter's research tree.

| Id | Issue | Title | Owner | Status | Depends on | Acceptance |
| --- | --- | --- | --- | --- | --- | --- |
| FF-38 | — | Loom rule is paid in currency | `bc-40e75aa3-97f6-5ff0-ad36-fe4865111928` | in_review | FF-26 | `tests/run_automation_tests.gd` shows `loom_rule` costs 120. 119 does not buy it. A second buy does not charge again. The purchase is refused during Mara's lesson. |
| FF-39 | — | Priority starts the matching recipe | `bc-40e75aa3-97f6-5ff0-ad36-fe4865111928` | in_review | FF-30, FF-33, FF-38 | With the rule owned, a ready plot, and a worker assigned, Fiber Bundle priority starts `bundle_fiber` and Fiber Cord priority starts `twist_cord`. |
| FF-40 | — | A running job is not replaced | `bc-40e75aa3-97f6-5ff0-ad36-fe4865111928` | in_review | FF-39 | Changing priority while the loom is busy keeps the recipe and the remaining ticks. The next ready plot uses the new priority. |
| FF-41 | — | Locked bench and Mara's lesson stay manual | `bc-40e75aa3-97f6-5ff0-ad36-fe4865111928` | in_review | FF-26, FF-38 | Without the unlock, and during the lesson, a ready plot and an assigned worker do not start the loom. Alex and Bram still differ. One harvest still cannot fill both orders. |
| FF-42 | — | Priority control on the workshop card | `bc-40e75aa3-97f6-5ff0-ad36-fe4865111928` | in_review | FF-39 | The scene check hides `ResearchButton` during the lesson, shows the priority buttons only after the purchase, and a cord priority does not replace Alex's running bundle. |

GitHub issues #2 through #14 stay the Milestone 0 and 1 issues. Milestone 5 does not add another issue for the same work.

## Milestone 6

No new GitHub issues. These rows are the claim. This slice is a first stylized pass on the trees, the workshop shed, the plot marker, and the valley ground. It does not add an economy system.

| Id | Issue | Title | Owner | Status | Depends on | Acceptance |
| --- | --- | --- | --- | --- | --- | --- |
| FF-43 | — | Stylized grove trees | `bc-6e5046c9-b9df-5ac0-8fbd-49a344d81aef` | in_review | FF-18 | Three trees instance one glTF. The scene check rejects a primitive trunk. `bash tools/validate.sh` exits 0. |
| FF-44 | — | Stylized workshop shed | `bc-6e5046c9-b9df-5ac0-8fbd-49a344d81aef` | in_review | FF-23 | The shed, the loom beam, and the shuttle are glTF. The arm stays still while idle and moves while the job is busy. |
| FF-45 | — | Stylized plot marker | `bc-6e5046c9-b9df-5ac0-8fbd-49a344d81aef` | in_review | FF-17, FF-21 | The stake is a glTF on the plot rim. Row, sprout, leaf, and ready stay visible on the plot. |
| FF-46 | — | First valley terrain pass | `bc-7d529529-1899-5c58-a4bf-d8cc4513a545` | in_review | FF-43 | The ground is a glTF valley. The yard and the barn pad stay flat, the dirt path stays visible, and a hill rises outside the grid. The scene check rejects the edge shader. `bash tools/validate.sh` exits 0. |

GitHub issues #2 through #14 stay the Milestone 0 and 1 issues. Milestone 6 does not add another issue for the same work.

## Charter remainder

No new GitHub issues. These rows are the claim. This slice is the rest of the charter as one playable pass. It does not replace Milestones 0–6 or the valley terrain.

| Id | Issue | Title | Owner | Status | Depends on | Acceptance |
| --- | --- | --- | --- | --- | --- | --- |
| FF-47 | — | World map shows four region tradeoffs | `bc-0e205dd6-2dfc-5aab-8ef3-33f2bcb31cae` | done | FF-16 | `tests/run_region_tests.gd` requires `economy_profile` and `play_style`. The menu and the farm world map print both. The map does not change `region_id`. |
| FF-48 | — | Research fork: loom rule and packing line | `bc-0e205dd6-2dfc-5aab-8ef3-33f2bcb31cae` | done | FF-38 | `tests/run_supply_tests.gd` shows buying one does not grant the other. Costs stay 120 and 100. The packing line is refused during Mara's lesson. |
| FF-49 | — | Wages charged on an interval | `bc-0e205dd6-2dfc-5aab-8ef3-33f2bcb31cae` | done | FF-28 | The same suite charges hired wages every 10 ticks after the lesson and does not charge on hire. Funds do not go below zero. |
| FF-50 | — | One experience gain | `bc-0e205dd6-2dfc-5aab-8ef3-33f2bcb31cae` | done | FF-30 | The same suite raises Bram's Efficiency once and shortens the next bundle. A second finish does not add another point. |
| FF-51 | — | Packing bench uses a Fiber Bundle | `bc-0e205dd6-2dfc-5aab-8ef3-33f2bcb31cae` | done | FF-23, FF-48 | `wrap_bundle` consumes one Fiber Bundle. One harvest cannot skip the bench. `packed_crate` pays 220 only after the unlock. |
| FF-52 | — | Packing clerk walks to the bench | `bc-0e205dd6-2dfc-5aab-8ef3-33f2bcb31cae` | done | FF-19, FF-51 | The scene check requires a glTF that is not `farmhand.glb`, a `walk` clip, and about `1.7` units of movement on `advance(1)`. |
| FF-53 | — | Generated tones for harvest, loom, and delivery | `bc-0e205dd6-2dfc-5aab-8ef3-33f2bcb31cae` | done | FF-24 | The scene check loads the three waves on `CuePlayer`. Each file is a generated sine from `tools/generate_tones.py`. |
| FF-54 | — | Linux desktop export script | `bc-0e205dd6-2dfc-5aab-8ef3-33f2bcb31cae` | done | FF-3 | `bash tools/export_desktop.sh` writes `builds/linux/FinoFarm.x86_64`. The README names that command. HTML5 stays FF-7. |

`bash tools/validate.sh` is the acceptance command for the set. It exits 0 with the supply suite at `7 passed, 0 failed` and `scene checks passed`.

FF-18 and FF-19 are independent of the menu. They still share `first_farm.tscn` unless they instance child scenes. Child scenes are the default.

## Environment

| Id | Where it should run |
| --- | --- |
| FF-3 | Cloud or local. Needs Godot. A display is only for the capture. |
| FF-7 | Cloud, with network access to official Godot templates. |
| FF-8, FF-13, FF-18, FF-19 | Prefer a display. Headless import is necessary and not sufficient. |
| FF-11, FF-12, FF-17 math, FF-21 through FF-42 rules | Cloud. Staff, economy, priority, and automation tests must not require rendering. The order-board and priority-control screenshots need a display. |
| FF-43, FF-44, FF-45, FF-46 | Cloud with Blender and a display. The scene check does not need a GPU. The farm frame does. |
| FF-47 through FF-54 | Cloud. Supply tests must not require rendering. The chain frame and the desktop export need Godot. The export needs the official Linux template. |
| FF-9 | Human admin on GitHub. |
