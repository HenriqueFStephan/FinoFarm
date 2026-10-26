# FinoFarm game design

Status: Milestone 4 adds a production choice on top of the Milestone 3 crew. The full vision is [the charter](charter.md). This document is the design that current and next tasks implement against.

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
| `twist_cord` | 2 Verdant Fiber | 1 Fiber Cord | 5 |
| `pack_textile` | 1 Fiber Bundle + 1 Seal Wax | 1 Packed Textile | 3 |

One tick is one simulated second. Splitting that second across frames does not change the result. The farm scene runs the bundle and cord recipes through `SimStepper`. Both fiber recipes spend a full harvest. `pack_textile` stays in the catalog for a later chain. It is not on the order board yet.

Verdant Fiber on the placed plot uses the same clock. `ResourceCatalog.growth` sets 4 visual stages (row, sprout, leaf, ready), 2 ticks each, yield 2, grade common. The grade is assigned by that table. Nothing in the plot computes a grow recipe.

The intro order `intro_bundle` pays 180 for one Fiber Bundle. The lane order `lane_cord` pays 240 for one Fiber Cord. The barn loft costs 400. The richest starting purse is Tropical Valley at 360, so the loft is unaffordable until the intro order pays. Innovation Plains starts at 240 and can afford it after the same payment (20 left). The shuttle rack costs 160 and shortens the next loom job by one tick. It is purchased only after the loft. A new farm still starts with 4 Verdant Fiber so the save has a real stack. That stack is not a harvest. One harvest is 2, and each of the two goods spends 2.

## What this build lets the player do

Launch Godot. The main menu sits on a 3D farm. New Game asks for a name and one of the four regions, writes a schema-1 save, and opens that farm. My Farms lists every save. Continue is available once a save exists.

- Pan, zoom, and orbit the same three-quarter camera.
- See terrain, a dirt loop, one barn, three trees, and a farmhand whose walk clip plays while they move.
- Place, move, and remove one plot marker on the grid. Placing it starts Verdant Fiber. Clicking the barn selects it. Clicking the workshop shed opens the bundle job.
- The HUD shows the farm name, region, funds, inventory, and a short prompt from Mara, the advisor voice. Mara is text on the HUD. She is not a new character model.
- Harvest the ready plot, bundle two fibers, deliver the trail-stall order, and buy the barn loft. The tutorial blocks those buttons until the matching step. After the loft, the prompt says the loop is done.
- After that lesson, open Crew. Two candidates are listed with the six ratings. Hire one and assign them to the workshop. The next bundle is shorter when their attribute total is higher. The hired person stands at the shed and plays a work clip while the loom runs.
- After that lesson, the workshop can also twist a Fiber Cord from the same Verdant Fiber. The order board shows both the trail stall and the lane counter. Delivering one does not deliver the other. The inventory line names both goods. The shuttle rack is a second building purchase. It appears on the shed and shortens the next job.

`pack_textile` is still later. See [the vertical slice](vertical-slice-m1.md) for what Milestone 1 added. Wages are listed and not charged. Training and experience are not in this build.

## Camera

The camera orbits a focus point. Pitch stays between about 20° and 66° so the view stays a farm game and not a free flyer. Distance stays between 8 and 32. Keyboard and mouse are both first-class so the scene is usable without a middle mouse button. The contract is `scripts/camera/farm_camera.gd`.

## Target loop

Plan, operate, produce, fulfill an order, earn, improve, expand, automate.

The Milestone 2 tutorial is the part of that sequence this build can play: place a plot, wait out the fiber timer, harvest, bundle, deliver, and buy the loft. Mara's lines and step order are unchanged. Crew opens after that lesson. The cord, the lane order, and the shuttle rack open after that lesson too. Do not treat the walking farmhand as an employee.

## Characters

Workers have Efficiency, Technical Skill, Creativity, Organization, Social Skill, and Adaptability, each from 1 to 10.

The recruitment list has two people:

| Id | Role | Total | Bundle ticks |
| --- | --- | --- | --- |
| `alex_morgan` | Junior Technician | 33 | 2 |
| `bram_holt` | Yard Hand | 23 | 3 |

Alex uses the charter's example ratings: 6, 8, 4, 5, 3, 7. Bram is lower on the bench and higher with people. The pace rule is `max(1, catalog_duration - floor(total / 12))`. Nobody assigned keeps the catalog's 4 ticks, so the lesson does not speed up by itself. The bundle still outputs 1. A job that has already started keeps its ticks if the player switches the assignee.

The figure who walks the path is still not an employee. The person at the loom is a second instance of that same mesh, with the hired name above them. The `work` clip plays only while the workshop job is busy.

## Out of scope for this build

Wages are shown and not deducted. Experience, training, and traits that change ratings are later. `pack_textile` stays off the board. Research, audio, weather, and final models are later. The shuttle rack changes speed only. It does not add a second loom.

## Regions

The four starting regions are catalog rows (task FF-11), not hard-coded scene logic. They are balancing sketches, not geography.
