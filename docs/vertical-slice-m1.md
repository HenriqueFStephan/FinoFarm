# Milestone 1 vertical slice

The player can start a game and stand in a farm that already looks like one place. This slice is the target. The Milestone 0 scene is the ground under it, not the slice itself.

## Player path

1. Launch the game. A 3D main menu is in front of a living farm view, not a flat panel on a blank color. Actions: Continue, My Farms, New Game, Settings, Credits, Exit. Settings and Credits may be short screens. Continue is disabled when no save exists.
2. New Game asks for a farm name and then opens the world map.
3. The map shows four region markers from data: Northern Homestead, Tropical Valley, Innovation Plains, Golden Fields. Choosing one shows climate label, season amplitude, property cost, upkeep, infrastructure difficulty, one opportunity, and one challenge. Numbers are gameplay tuning, not geographic claims.
4. Confirming the region creates save schema 1 and loads the farm.
5. The player can pan, zoom, and orbit, select the barn, and place one plot marker on a grid. The plot marker is a game object, not a growing guide.
6. The farm has one building and one character that are modeled and animated to the art bible, replacing `PlaceholderBarn` and `PlaceholderWalker`. If a replacement is late, the slice is not done. Do not ship the primitives as the "modeled" requirement.
7. A small HUD shows the farm name, region, and funds from the save.
8. My Farms lists save cards: name, region, level (level 1 is enough), funds, playtime, last saved. A thumbnail can be a capture of the farm. Multiple farms must load independently.
9. Quit and relaunch. Continue returns to the same farm, camera state included.

## In this slice

- Menu, selector, creation, map, one farm, camera, one grid placement, one real building, one rigged walker with a walk clip, basic HUD, save/load.
- Region and recipe data stay abstract.

## Out of this slice

- The production-to-order loop, tutorial dialogue, hiring, wages, and research. Those are Milestone 2 and 3. The workshop classes may be called to put starting fiber in the save, but the player does not run a crafting UI yet.
- Browser export.
- More than one building model.

## Acceptance

- `bash tools/validate.sh` passes, including new save tests wired into that script.
- A person can play the path above in Godot on the desktop.
- A capture of the farm shows the new building and character, and the art bible status for those two ids is `in-engine` or better, not `placeholder`.
- Two saves do not overwrite each other. A test creates both and reloads them.

## Task map

| Order | Id | Depends on |
| --- | --- | --- |
| Region rows | FF-11 | Milestone 0 docs |
| Save schema and tests | FF-12 | FF-11 for `region_id` values, simulation snapshot shape |
| Main menu scene | FF-13 | Milestone 0 scene as the backdrop or a duplicate of its world |
| Farm selector | FF-14 | FF-12, FF-13 |
| New farm form | FF-15 | FF-11, FF-12, FF-13 |
| World map | FF-16 | FF-11, FF-15 |
| Grid placement | FF-17 | Farm scene, camera contract |
| Replace barn | FF-18 | Art bible, asset registry |
| Replace walker | FF-19 | Art bible, asset registry |
| HUD | FF-20 | FF-12 so funds come from the save |

FF-17, FF-18, and FF-19 can proceed beside the menu once their interfaces are unchanged. FF-18 and FF-19 must not both edit `first_farm.tscn` without agreeing who owns the scene file. Prefer instancing `scenes/buildings/barn.tscn` and `scenes/characters/walker.tscn` so the scene file stays a layout.

## Gap from Milestone 0

Today the player is dropped into one unsaved scene. The building and walker are primitives. There is no menu, map, placement, or HUD beyond a control hint. Calling that Milestone 1 would fail the acceptance condition in the charter.
