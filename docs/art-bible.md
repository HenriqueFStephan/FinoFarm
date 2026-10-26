# FinoFarm art bible

Status: block-out palette and rules. No mesh in the first scene is approved final art.

## Target

Cozy stylized 3D. Rounded forms, readable silhouettes, soft light, one material language. FarmVille 2 is a reference for approachability, not a style to copy.

Agricultural buildings should feel rustic and warm. Technology buildings, when they exist, should feel clean and slightly teal. The two families must still look like the same game.

Do not mix photoreal characters with cartoon sets, unrelated low-poly packs, or mismatched texture sizes. Do not present a primitive as a finished asset.

## Block-out palette

These hex values are the materials on the first scene. Final textures stay in this family. They are not texture-approved.

| Role | Hex | Use on the first scene |
| --- | --- | --- |
| Grass light | `#4D7A3D` | Terrain shader `grass_a` |
| Grass shadow | `#295224` | Terrain shader `grass_b` |
| Path | `#855E33` | Dirt loop painted in the terrain shader |
| Barn wall | `#EDE0C4` | Placeholder barn walls |
| Barn base | `#735737` | Placeholder slab |
| Roof | `#8C4636` | Placeholder roof |
| Door | `#6B4228` | Placeholder door |
| Window | `#8FB7C9` | Placeholder window, muted teal accent |
| Trunk | `#6E4A2C` | Placeholder trees |
| Canopy | `#2F8A45` | Placeholder trees |
| Shirt | `#F3E6C8` | Placeholder walker torso |
| Pants | `#C67A2E` | Placeholder walker hips and legs |
| Skin | `#E8C2A0` | Placeholder walker head and arms |
| Sky | `#518CD9` | Procedural sky top |
| Hint text | `#FAF5E6` | Camera hint |

Interface surfaces, when UI arrives, use warm cream panels (`#F3E6C8` range) and amber for rewards. Do not invent a second palette for the menu.

## Placeholders in the first scene

Every mesh below is a Godot primitive or a shader on a plane. There is no Blender source, no texture set, and no approved silhouette. Label them placeholders in reviews, issues, and the asset registry.

| Node | What it actually is |
| --- | --- |
| `PlaceholderTerrain` | Subdivided plane. Shader fakes hills at the edges and a square dirt loop. The center is flat so the walker does not sink. |
| `PlaceholderBarn` | Boxes for slab, walls, door, and window. `PrismMesh` for the roof. |
| `PlaceholderTreeA`, `PlaceholderTreeB`, `PlaceholderTreeC` | Cylinder trunk, sphere canopy. |
| `PlaceholderWalker` | Boxes and a sphere. Limb swing is `sin(distance)` in `placeholder_walker.gd`. It is not a skeleton or an exported clip. |

A captured frame of this scene is a block-out check. It is not art approval. Task FF-8 is a GPU review of the same scene. Tasks FF-18 and FF-19 replace the barn and the walker.

## Future character target

When a real character is modeled, aim for a large readable head, consistent proportions, a role-readable outfit, and clips for idle, walk, carry, celebrate, rest, and equipment interaction. The block-out walker does not meet that target. Its only job is to walk in the engine so later clips have a scene to land in.

Scale in the first scene is `1.25` on `PlaceholderWalker` so the block-out reads at the default camera distance. Do not treat that scale as the final proportion guide.

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
