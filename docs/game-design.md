# FinoFarm game design

Status: Milestone 0. The full vision is [the charter](charter.md). This document is the design that current and next tasks implement against.

## Player fantasy

The player starts with a small farm, builds a fictional agricultural business, hires a team, and shifts from hands-on work to planning. References (FarmVille 2, Pot Farm, Fallout Shelter, management games) are tone and structure only. FinoFarm needs its own characters, buildings, interface, and numbers.

## Pillars

1. The farm is a place you move through, not a page of buttons.
2. The economy is an interconnected fiction: inputs, timers, grades, recipes, orders, and cash.
3. Workers have attributes that change outcomes.
4. Automation is progression, from manual work to delegation to facility rules.
5. Starting regions change the business problem, as gameplay data, not as real geography or agronomy.

## Abstraction rule

Fictional goods only. A recipe is a resource id, an amount, a tick duration, and a grade rule. Grades are `common` (1), `fine` (2), and `select` (3). Output grade is the minimum input grade.

Do not add realistic cultivation steps, extraction, dosages, or real-world controlled-substance methods. Do not name real strains, solvents, or grow procedures in data or UI.

The first recipes are a textile chain, defined in `scripts/simulation/catalog.gd`:

| Recipe | Inputs | Output | Ticks |
| --- | --- | --- | --- |
| `bundle_fiber` | 2 Verdant Fiber | 1 Fiber Bundle | 4 |
| `pack_textile` | 1 Fiber Bundle + 1 Seal Wax | 1 Packed Textile | 3 |

One tick is one simulated second. Splitting that second across frames does not change the result. The farm scene does not run this workshop yet. Milestone 2 puts it on screen. Tests cover it now.

## What this build lets the player do

Launch Godot. The main menu sits on a 3D farm. New Game asks for a name and one of the four regions, writes a schema-1 save, and opens that farm. My Farms lists every save. Continue is available once a save exists.

- Pan, zoom, and orbit the same three-quarter camera.
- See terrain, a dirt loop, one barn, three trees, and a farmhand whose walk clip plays while they move.
- Place, move, and remove one plot marker on the grid. Clicking the barn selects it.
- The HUD shows the farm name, region, and funds from the save.

Hiring, orders, and the workshop screen are still later milestones. See [the vertical slice](vertical-slice-m1.md). The workshop classes stay headless.

## Camera

The camera orbits a focus point. Pitch stays between about 20° and 66° so the view stays a farm game and not a free flyer. Distance stays between 8 and 32. Keyboard and mouse are both first-class so the scene is usable without a middle mouse button. The contract is `scripts/camera/farm_camera.gd`.

## Target loop

Plan, operate, produce, fulfill an order, earn, improve, expand, automate.

The early-game teaching sequence in the charter (inherit a farm, restore a field, finish one production cycle, deliver an order, hire, upgrade) is the Milestone 2 tutorial. Milestone 1 only has to reach a farm you created and can look around, with save/load and a real character. Do not pretend the walking placeholder completes that loop.

## Characters

Workers will have Efficiency, Technical Skill, Creativity, Organization, Social Skill, and Adaptability, each from 1 to 10, plus traits. Alex Morgan in the charter is an example, not a character who exists in the scene.

The figure in the first scene is an unnamed block-out. They walk. They have no stats, no job, and no authored animation clip.

## Regions

Later data, not this build. The charter's four starting sketches (Northern Homestead, Tropical Valley, Innovation Plains, Golden Fields) are balancing sketches. Implement them as rows in a catalog (task FF-11), not as hard-coded scene logic.

## Out of scope until a later milestone

Main menu, saves, placement, inventory UI, orders, wages, research, audio, weather, and final models.
