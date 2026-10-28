# FinoFarm roadmap

The charter's milestone list, with current status. Dates are not estimates. Status says what is in the repo.

| Milestone | Acceptance, short | Status |
| --- | --- | --- |
| 0 Foundation | The real engine project launches, architecture is documented, agents can take tasks without colliding. | On `main`. Follow-ups stay open: FF-7, FF-8, FF-9. |
| 1 First playable farm | Create a farm and explore a visually coherent 3D place. | On `main`. Tasks FF-11 through FF-20. |
| 2 Economic loop | Produce, sell, and upgrade once, with a tutorial. | On `main`. Tasks FF-21 through FF-27. |
| 3 Employees | Assignments change outcomes, and workers are visible. | On `main`. Tasks FF-28 through FF-32. The path walker is still not an employee. |
| 4 Production expansion | Real choices about chains and buildings. | On `main`. Tasks FF-33 through FF-37. |
| 5 Automation | The player's job shifts from doing tasks to directing them. | On `main`. Tasks FF-38 through FF-42. The loom rule is one branch of a two-choice research fork. |
| 6 Content and polish | Consistent presentation and medium-term goals. | On `main` for the first mesh pass, tasks FF-43 through FF-46. This branch adds the packing bench, the packing clerk, and generated tones. Accessibility is still later. |
| Charter remainder | World map tradeoffs, a research fork, wages, one experience gain, a second production building, sound cues, and a desktop export script. | On this branch. Tasks FF-47 through FF-54. First-pass assets, not a store candidate. |
| 7 Release candidate | A desktop build that has survived save, regression, and performance checks, ready for store review. | Not started as a store candidate. `bash tools/export_desktop.sh` writes a Linux binary. HTML5 is still FF-7. No performance budget has been measured. |

## Milestone 0 done in this branch

- Audit of `main` (bootstrap only). Bootstrap files kept.
- Godot 4.7.2 standard confirmed by running it.
- Godot project, main scene, headless import, scene checks, simulation tests, CI workflow.
- Design, art, architecture, roadmap, registry, interfaces, testing strategy, Milestone 1 slice.
- Eleven project skills.
- In-repo backlog and ownership rules.

## Still open after Milestone 0

- FF-7: install web-export templates and record what HTML5 can and cannot do. Do not claim browser play works before that command succeeds.
- FF-8: review the farm frame on a GPU desktop against the art bible. The llvmpipe capture is evidence the scene renders, not a sign-off.
- FF-9: a person with repo admin rights turns on branch protection so `Validate` is required. Agents do not change that setting from a feature branch.

## Delegation

Safe to hand to a cloud agent once this branch is merged, because the files and commands exist:

- FF-11 region catalog, if it stays data plus tests and does not rewrite the scene.
- FF-12 save/load, behind the contract in `docs/interface-contracts.md`.
- FF-7 export notes, if the agent can download official export templates.

Needs a visual check, so prefer an environment with a display:

- FF-8, FF-18, FF-19, FF-13 (the menu has to look like a game, not only compile).

Do not run two agents on FF-18 and a second barn. One owner per task id.
