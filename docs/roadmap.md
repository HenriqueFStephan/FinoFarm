# FinoFarm roadmap

The charter's milestone list, with current status. Dates are not estimates. Status says what is in the repo.

| Milestone | Acceptance, short | Status |
| --- | --- | --- |
| 0 Foundation | The real engine project launches, architecture is documented, agents can take tasks without colliding. | In review on this branch. Scene, docs, skills, backlog, and `tools/validate.sh` are in the tree. Follow-ups: FF-7, FF-8, FF-9. |
| 1 First playable farm | Create a farm and explore a visually coherent 3D place. | In review on `cursor/milestone-1-playable-farm-e77b`. This branch stacks on it. Tasks FF-11 through FF-20. |
| 2 Economic loop | Produce, sell, and upgrade once, with a tutorial. | In review on `cursor/milestone-2-economy-loop-3aa2`. Tasks FF-21 through FF-27. One Verdant Fiber plot, the bundle workshop, one order, and the barn loft. `pack_textile` is still catalog-only. |
| 3 Employees | Assignments change outcomes, and workers are visible. | In review on this branch. Tasks FF-28 through FF-32. Two candidates, hire and assign on schema 1, bundle time follows the attribute total, and a work clip plays at the loom. The path walker is still not an employee. |
| 4 Production expansion | Real choices about chains and buildings. | In review on this branch. Tasks FF-33 through FF-37. Fiber Cord competes with Fiber Bundle for one harvest, the lane order pays 240, and the shuttle rack shortens the next job. |
| 5 Automation | The player's job shifts from doing tasks to directing them. | Not started. |
| 6 Content and polish | Consistent presentation and medium-term goals. | Not started. |
| 7 Release candidate | A desktop build that has survived save, regression, and performance checks, ready for store review. | Not started. No export preset exists. |

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
