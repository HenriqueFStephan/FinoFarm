# FinoFarm game design

Status: Milestone 2 loop is in this branch. The full vision is [the charter](charter.md). This document is the design that current and next tasks implement against.

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

One tick is one simulated second. Splitting that second across frames does not change the result. The farm scene runs the bundle recipe through `SimStepper`. `pack_textile` stays in the catalog for a later chain. It is not on the order board yet.

Verdant Fiber on the placed plot uses the same clock. `ResourceCatalog.growth` sets 4 visual stages (row, sprout, leaf, ready), 2 ticks each, yield 2, grade common. The grade is assigned by that table. Nothing in the plot computes a grow recipe.

The intro order `intro_bundle` pays 180 for one Fiber Bundle. The barn loft costs 400. The richest starting purse is Tropical Valley at 360, so the loft is unaffordable until that order pays. Innovation Plains starts at 240 and can afford it after the same payment (20 left).

## What this build lets the player do

Launch Godot. The main menu sits on a 3D farm. New Game asks for a name and one of the four regions, writes a schema-1 save, and opens that farm. My Farms lists every save. Continue is available once a save exists.

- Pan, zoom, and orbit the same three-quarter camera.
- See terrain, a dirt loop, one barn, three trees, and a farmhand whose walk clip plays while they move.
- Place, move, and remove one plot marker on the grid. Placing it starts Verdant Fiber. Clicking the barn selects it. Clicking the workshop shed opens the bundle job.
- The HUD shows the farm name, region, funds, inventory, and a short prompt from Mara, the advisor voice. Mara is text on the HUD. She is not a new character model.
- Harvest the ready plot, bundle two fibers, deliver the trail-stall order, and buy the barn loft. The tutorial blocks those buttons until the matching step. After the loft, the prompt says the loop is done.

Hiring and `pack_textile` are still later. See [the vertical slice](vertical-slice-m1.md) for what Milestone 1 added. The Milestone 2 scene is the one that runs the workshop.

## Camera

The camera orbits a focus point. Pitch stays between about 20° and 66° so the view stays a farm game and not a free flyer. Distance stays between 8 and 32. Keyboard and mouse are both first-class so the scene is usable without a middle mouse button. The contract is `scripts/camera/farm_camera.gd`.

## Target loop

Plan, operate, produce, fulfill an order, earn, improve, expand, automate.

The Milestone 2 tutorial is the part of that sequence this build can play: place a plot, wait out the fiber timer, harvest, bundle, deliver, and buy the loft. Hiring and job assignment stay Milestone 3. Do not treat the walking farmhand as an employee.

## Characters

Workers will have Efficiency, Technical Skill, Creativity, Organization, Social Skill, and Adaptability, each from 1 to 10, plus traits. Alex Morgan in the charter is an example, not a character who exists in the scene.

The figure in the first scene is an unnamed block-out. They walk. They have no stats, no job, and no authored animation clip.

## Regions

Later data, not this build. The charter's four starting sketches (Northern Homestead, Tropical Valley, Innovation Plains, Golden Fields) are balancing sketches. Implement them as rows in a catalog (task FF-11), not as hard-coded scene logic.

## Out of scope until a later milestone

Wages, hiring, research, audio, weather, `pack_textile` on the board, and final models. The menu, saves, placement, inventory line, one order, and the bundle workshop are in.
