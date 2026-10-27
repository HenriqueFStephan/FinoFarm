# FinoFarm art bible

Status: cozy stylized direction. The barn, the farmhand, the grove trees, the workshop shed, the plot marker, and the valley ground are in-engine models. They are a first stylized pass, not approved final art. The fiber plot, the selection ring, the barn loft, and the shuttle rack are still placeholders. The person at the loom is a second instance of the farmhand mesh, not a new character.

## Target

Cozy stylized 3D. Rounded forms, readable silhouettes, soft light, one material language. FarmVille 2 is a reference for approachability, not a style to copy.

Agricultural buildings should feel rustic and warm. Technology buildings, when they exist, should feel clean and slightly teal. The two families must still look like the same game.

Do not mix photoreal characters with cartoon sets, unrelated low-poly packs, or mismatched texture sizes. Do not present a primitive as a finished asset.

## Block-out palette

These hex values are the materials on the first scene. Final textures stay in this family. They are not texture-approved.

| Role | Hex | Use on the first scene |
| --- | --- | --- |
| Grass light | `#4D7A3D` | Valley floor and lower slopes |
| Grass shadow | `#295224` | Higher hills on the valley mesh |
| Path | `#855E33` | Square dirt loop on the valley mesh |
| Barn wall | `#EDE0C4` | Placeholder barn walls |
| Barn base | `#735737` | Placeholder slab |
| Roof | `#8C4636` | Placeholder roof |
| Door | `#6B4228` | Placeholder door |
| Window | `#8FB7C9` | Placeholder window, muted teal accent |
| Trunk | `#6E4A2C` | Grove trees and the plot stake |
| Canopy | `#2F8A45` | Grove trees |
| Shirt | `#F3E6C8` | Placeholder walker torso |
| Pants | `#C67A2E` | Placeholder walker hips and legs |
| Skin | `#E8C2A0` | Placeholder walker head and arms |
| Sky | `#518CD9` | Procedural sky top |
| Hint text | `#FAF5E6` | Camera hint |

Interface surfaces, when UI arrives, use warm cream panels (`#F3E6C8` range) and amber for rewards. Do not invent a second palette for the menu.

## In the farm scene

| Node | What it actually is | Status |
| --- | --- | --- |
| `PlaceholderTerrain` | glTF from `tools/blender/terrain.py`. Flat yard, the same square dirt loop, and a continuous bank of rounded hills outside the plot grid. The barn pad stays at ground height. | in-engine, first terrain pass |
| `Barn` | glTF from `tools/blender/barn.py`. Gable roof, doors, windows, cupola. Flat colors from this palette. No textures. | in-engine, not accepted final art |
| `PlaceholderTreeA`, `PlaceholderTreeB`, `PlaceholderTreeC` | One glTF from `tools/blender/tree.py`, three times, with different scale and yaw. Tapered trunk and a lumpy canopy. | in-engine, first stylized pass |
| `Farmhand` | glTF from `tools/blender/farmhand.py`. One skin, `idle`, `walk`, and `work` clips. The model child is scaled `1.55` so the figure reads at the default camera. | in-engine, not accepted final art |
| `WorkshopWorker` | The same glTF, instanced again in front of the shed. `work` plays while the loom job is busy. A name label sits above the figure. | in-engine, not accepted final art |
| `PlaceholderPlotMarker`, `PlaceholderPlotHover` | glTF from `tools/blender/plot_marker.py`. A tapered stake and a pennant, offset to the plot rim. | in-engine, first stylized pass |
| `PlaceholderSelectionRing` | Flat cylinder shown when the barn is selected. | placeholder |
| `PlaceholderCrop` | Disc, nub, stem, sphere, and an amber tuft. Swapped to match the plot stage. | placeholder |
| `PlaceholderWorkshop` | Shed glTF from `tools/blender/workshop.py`, plus a separate beam and shuttle. The beam spins only while the workshop job is busy. | in-engine, first stylized pass |
| `PlaceholderBarnLoft` | A box room, a box roof, and a teal window, shown after the loft is bought. | placeholder |
| `PlaceholderShuttleRack` | A wood rail and two amber boxes on the shed roof, shown after the shuttle rack is bought. | placeholder |

Do not describe the ring, crop, loft, or shuttle rack as finished art. Do not describe the barn, the farmhand, the grove trees, the workshop shed, the plot marker, the valley ground, or the workshop worker as approved final assets. The trees, the shed, the marker, and the ground are the first stylized pass. The worker is the farmhand mesh again, not a portrait of Alex or Bram. `work` is an in-place arm pass while the loom job is busy. Carry, celebrate, and rest clips are not in this build. The old box walker and its sine-wave swing are gone. The old cylinder trees, box shed, and box flag are gone. The old flat terrain plane and its edge shader are gone. The loom spin is a presentation of the busy flag, not a finished machine animation.

## Camera readability

Default view is three-quarter, focus on the barn, pitch clamped so the player keeps the ground. Characters and doors must stay readable at distance 15 to 20. The block-out is only a rough check of that idea.

## Pipeline

1. Model in Blender 5.2.3 (pinned by `.cursor/install.sh`) or build an approved procedural mesh.
2. Export glTF binary (`.glb`) with Y-up, applied scale, and no unused cameras.
3. Put the file under `assets/models/<id>.glb`. Git LFS tracks `*.glb`.
4. Import through Godot. A file on disk is not in-game until a scene instances it.
5. Add a row to [the asset registry](asset-registry.md) before calling the asset usable.
6. Capture the scene with `tools/capture_farm.gd` and compare it to this bible.

Reject anything that breaks the palette or the silhouette rules, even if the file imports.

## Lighting block-out

One warm directional sun (`energy` 0.9, color `#FFF5E0`) plus a low green-gray ambient (energy 0.28). Filmic tonemap, exposure 1.0. Shadows are on. These numbers are for the placeholder scene so colors survive the Compatibility renderer. Revisit them when real materials exist. Do not crank the sun back up to hide flat albedo; the previous pass clipped the grass to white.
