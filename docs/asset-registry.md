# Asset registry

Stub. Add a row before a new source file is used in a scene. Status `placeholder` means it is not final art, even if it is on screen.

No third-party model, texture, audio, or font is imported. The barn and the farmhand were generated in Blender for this project. Terrain, trees, the plot marker, and the selection ring are still engine primitives or a shader.

| Id | Scene node | Source | Export | Author | License | Materials | Polys | Animation | Scenes | Status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `terrain.placeholder` | `PlaceholderTerrain` | `assets/shaders/placeholder_terrain.gdshader` on a 48×48 subdivided `PlaneMesh` | n/a | in-engine shader | project original | shader albedo, no textures | generated | none | `farm_stage.tscn` | placeholder |
| `building.barn.v1` | `Barn` | `tools/blender/barn.py` | `assets/models/barn.glb` | Blender script in this repo | project original, commercial use allowed | flat principled colors, no textures | 1294 tris | none | `scenes/buildings/barn.tscn` | in-engine |
| `tree.placeholder` | `PlaceholderTreeA/B/C` | cylinder and sphere in the scene | n/a | in-engine primitives | project original | flat colors | primitive | none | `farm_stage.tscn` | placeholder |
| `character.farmhand.v1` | `Farmhand` | `tools/blender/farmhand.py` | `assets/models/farmhand.glb` | Blender script in this repo | project original, commercial use allowed | flat principled colors, no textures | 10340 tris | skeleton `Armature`, clips `idle` and `walk`, in-place | `scenes/characters/farmhand.tscn` | in-engine |
| `marker.placeholder` | `PlaceholderPlotMarker` | cylinder and box in `scenes/props/plot_marker.tscn` | n/a | in-engine primitives | project original | flat colors | primitive | none | `first_farm.tscn` | placeholder |
| `icon.game` | project icon | `icon.svg` | svg | in-repo vector | project original | flat fills | n/a | none | project settings | block-out icon, not marketing art |

External source URL for both glTF files: none. The box barn and the sine-wave walker are no longer instanced. `in-engine` means Godot imports the glTF and a scene instances it. It does not mean art-director acceptance.

Polygon counts are omitted for primitives because Godot generates them and they are not an art budget.

## Required fields for the next real asset

- Unique id (`building.barn.v1`, not a file name alone).
- Source file path (`.blend` or the generator script).
- Export path (`.glb` under `assets/models/`).
- Author or generator.
- External URL if any, else `none`.
- License and whether commercial use is allowed.
- Materials and textures.
- Triangle count from the export.
- Skeleton and animation dependencies, or `none`.
- Scenes that instance it.
- Status: `draft`, `in-engine`, `accepted`, or `rejected`. `placeholder` stays reserved for stand-ins.

Git LFS is configured for `glb`, `png`, `blend`, and audio. Do not commit those as plain git blobs. The icon is SVG and stays in git.

## Validation

`godot --headless --path . --import --quit` must succeed after the file is added. Then open the scene that instances it and capture a frame. A `.glb` that only exists on disk is `draft`, not `in-engine`.
