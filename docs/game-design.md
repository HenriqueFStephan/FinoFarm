# FinoFarm game design

Status: Milestones 0–6 are on `main`. This build adds the rest of the charter as a first playable pass: a world map with region tradeoffs, a two-choice research fork, wages and one experience gain, a packing bench that consumes the workshop's output, generated tones, and a Linux desktop export script. Meshes stay a first pass. The full vision is [the charter](charter.md). This document is the design the current build implements.

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
| `wrap_bundle` | 1 Fiber Bundle | 1 Packed Textile | 3 |

One tick is one simulated second. Splitting that second across frames does not change the result. The farm scene runs the bundle and cord recipes on the workshop, and `wrap_bundle` on a second bench that shares the same inventory. Both fiber recipes spend a full harvest. `wrap_bundle` spends one Fiber Bundle, so the supply chain is harvest, then loom, then packing. `pack_textile` stays in the catalog because it also needs Seal Wax, which the player does not produce. It is not a loom priority and it is not the packing-bench recipe.

Verdant Fiber on the placed plot uses the same clock. `ResourceCatalog.growth` sets 4 visual stages (row, sprout, leaf, ready), 2 ticks each, yield 2, grade common. The grade is assigned by that table. Nothing in the plot computes a grow recipe.

The intro order `intro_bundle` pays 180 for one Fiber Bundle. The lane order `lane_cord` pays 240 for one Fiber Cord. The crate order `packed_crate` pays 220 for one Packed Textile and stays hidden until the packing line is owned. The barn loft costs 400. The richest starting purse is Tropical Valley at 360, so the loft is unaffordable until the intro order pays. Innovation Plains starts at 240 and can afford it after the same payment (20 left). The shuttle rack costs 160 and shortens the next loom job by one tick. It is purchased only after the loft. Research is a fork, not a line: the loom rule costs 120 and the packing line costs 100. Buying one does not grant the other. Neither requires the loft. Both are sold only after Mara's lesson. A new farm still starts with 4 Verdant Fiber so the save has a real stack. That stack is not a harvest. One harvest is 2, and each of the two fiber goods spends 2. One Fiber Bundle is one packing job.

## What this build lets the player do

Launch Godot. The main menu sits on a 3D farm. New Game asks for a name and one of the four regions, writes a schema-1 save, and opens that farm. My Farms lists every save. Continue is available once a save exists.

- Pan, zoom, and orbit the same three-quarter camera.
- See a small valley, a dirt loop, one barn, three grove trees, an open workshop shed, and a farmhand whose walk clip plays while they move. The trees, the shed, the plot stake, and the ground are a first stylized pass. The fiber plot still changes shape at row, sprout, leaf, and ready.
- Place, move, and remove one plot marker on the grid. Placing it starts Verdant Fiber. Clicking the barn selects it. Clicking the workshop shed opens the bundle job.
- The HUD shows the farm name, region, funds, inventory, and a short prompt from Mara, the advisor voice. Mara is text on the HUD. She is not a new character model.
- Harvest the ready plot, bundle two fibers, deliver the trail-stall order, and buy the barn loft. The tutorial blocks those buttons until the matching step. After the loft, the prompt says the loop is done.
- After that lesson, open Crew. Two candidates are listed with the six ratings. Hire one and assign them to the workshop. The next bundle is shorter when their attribute total is higher. The hired person stands at the shed and plays a work clip while the loom runs.
- After that lesson, the workshop can also twist a Fiber Cord from the same Verdant Fiber. The order board shows both the trail stall and the lane counter. Delivering one does not deliver the other. The inventory line names both goods. The shuttle rack is a second building purchase. It appears on the shed and shortens the next job.
- After that lesson, buy the loom rule for 120, the packing line for 100, or both. They are separate purchases. The workshop card then shows a Fiber Bundle priority and a Fiber Cord priority. When the plot is ready and a worker is assigned, the loom starts the chosen good. The player does not click Start for that job. A job that is already running keeps its recipe. Without the loom rule, and during Mara's lesson, the player still starts the loom by hand.
- After the packing line is owned, a packing bench appears. It takes one Fiber Bundle and makes one Packed Textile. The crate order then appears on the board. A second character, the packing clerk, walks from the yard to that bench when someone is assigned there.
- Open World map from the farm. It lists all four regions with their economy and play style, and marks the farm you are on. It does not move the save to another region.
- After the lesson, hired wages are charged every 10 simulated seconds. Hire itself is still free. The charge cannot drive funds below zero. The first loom or packing job a hired person finishes raises that person's Efficiency by 1, once.
- A short generated tone plays on a successful harvest, when a loom job starts, and when an order pays. The files are labeled generated tones, not recorded sound design.

`pack_textile` still needs Seal Wax and stays off the board. See [the vertical slice](vertical-slice-m1.md) for what Milestone 1 added, and [the core loop](flows/core-loop.md) for the path through this build.

## Camera

The camera orbits a focus point. Pitch stays between about 20° and 66° so the view stays a farm game and not a free flyer. Distance stays between 8 and 32. Keyboard and mouse are both first-class so the scene is usable without a middle mouse button. The contract is `scripts/camera/farm_camera.gd`.

## Target loop

Plan, operate, produce, fulfill an order, earn, improve, expand, automate.

The Milestone 2 tutorial is still the opening of that sequence: place a plot, wait out the fiber timer, harvest, bundle, deliver, and buy the loft. Mara's lines and step order are unchanged. Crew, the cord, the lane order, the shuttle rack, both research purchases, the packing bench, and wage charges open after that lesson. The lesson itself stays a hand start. The walking farmhand on the path is still not an employee. The packing clerk is.

## Characters

Workers have Efficiency, Technical Skill, Creativity, Organization, Social Skill, and Adaptability, each from 1 to 10.

The recruitment list has two people:

| Id | Role | Total | Bundle ticks |
| --- | --- | --- | --- |
| `alex_morgan` | Junior Technician | 33 | 2 |
| `bram_holt` | Yard Hand | 23 | 3 |

Alex uses the charter's example ratings: 6, 8, 4, 5, 3, 7. Bram is lower on the bench and higher with people. The pace rule is `max(1, catalog_duration - floor(total / 12))`. Nobody assigned keeps the catalog's 4 ticks, so the lesson does not speed up by itself. The bundle still outputs 1. A job that has already started keeps its ticks if the player switches the assignee.

The figure who walks the path is still not an employee. The person at the loom is a second instance of that same mesh, with the hired name above them. The `work` clip plays only while the workshop job is busy.

The packing clerk is a different mesh: shorter, with a cap, a teal vest, a cream apron, and a small crate. It is not a recolor of the farmhand. When someone is assigned to packing, the clerk walks from the yard to the bench and plays `work` while that job is busy. The same hired person can be assigned to the loom and to packing. Those are two stations, not two hires.

Listed wages are 18 for Alex and 12 for Bram. `FarmLoop.charge_wages` adds them every `StaffRoster.WAGE_INTERVAL` ticks (10) after the lesson. `FarmLoop.advance` does not charge, so a test that only advances the clock does not lose funds. A short purse pays what it can and stops at zero.

Experience is one gain. The first completed loom or packing job after the lesson, while that person is still assigned, adds 1 Efficiency, capped at 10. The catalog row does not change. Bram's total goes from 23 to 24, so the next bundle drops from 3 ticks to 2. Alex's total goes from 33 to 34 and the bundle stays at 2 ticks. A job already in progress keeps its ticks.

## Out of scope for this build

Training beyond that single Efficiency point, and traits that rewrite a rating, are later. `pack_textile` stays off the board and is not a loom priority. Weather and final models are later. The shuttle rack changes speed only. It does not add a second loom. The loom rule does not replace a job that has already started. The world map does not relocate a save. HTML5 export is still FF-7.

## Regions

The four starting regions are catalog rows (task FF-11), not hard-coded scene logic. They are balancing sketches, not geography. Each row also has `economy_profile` and `play_style`. The new-farm card and the in-farm world map both print those lines.

| Region | Play style | Economy |
| --- | --- | --- |
| Northern Homestead | Keep work indoors and budget for upkeep. | Steady indoor contracts, higher building upkeep. |
| Tropical Valley | Plan around short seasons and outdoor delays. | More event contracts, uneven outdoor timing. |
| Innovation Plains | Buy research before you spread out. | Expensive plots, faster access to research. |
| Golden Fields | Aim at premium orders and watch dry-season costs. | Premium select-grade orders, higher dry-season costs. |

Those sentences are the tradeoff the player reads. They do not change growth math, soil, or a real crop. Starting funds are still the purse minus the property cost.
