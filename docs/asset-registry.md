# Asset registry

Stub. Add a row before a new source file is used in a scene. Status `placeholder` means it is not final art, even if it is on screen.

No third-party model, texture, audio, or font is imported. The barn, the farmhand, the grove trees, the workshop shed, the loom beam, the shuttle, and the plot marker were generated in Blender for this project. Terrain, the selection ring, the fiber plot, the barn loft, and the shuttle rack are still engine primitives or a shader. The new meshes are a first stylized pass. `in-engine` is not art-director acceptance.

| Id | Scene node | Source | Export | Author | License | Materials | Polys | Animation | Scenes | Status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `terrain.placeholder` | `PlaceholderTerrain` | `assets/shaders/placeholder_terrain.gdshader` on a 48×48 subdivided `PlaneMesh` | n/a | in-engine shader | project original | shader albedo, no textures | generated | none | `farm_stage.tscn` | placeholder |
| `building.barn.v1` | `Barn` | `tools/blender/barn.py` | `assets/models/barn.glb` | Blender script in this repo | project original, commercial use allowed | flat principled colors, no textures | 1294 tris | none | `scenes/buildings/barn.tscn` | in-engine |
| `prop.tree.v1` | `PlaceholderTreeA/B/C` | `tools/blender/tree.py` | `assets/models/tree.glb` | Blender script in this repo | original, project-authored | flat principled colors, no textures | 2416 tris | none | `scenes/props/tree.tscn` in `farm_stage.tscn` | in-engine |
| `character.farmhand.v1` | `Farmhand`, `WorkshopWorker` | `tools/blender/farmhand.py` | `assets/models/farmhand.glb` | Blender script in this repo | project original, commercial use allowed | flat principled colors, no textures | 10340 tris | skeleton `Armature`, clips `idle`, `walk`, and `work`, in-place | `scenes/characters/farmhand.tscn`, `scenes/characters/workshop_worker.tscn` | in-engine |
| `prop.plot_marker.v1` | `PlaceholderPlotMarker` | `tools/blender/plot_marker.py` | `assets/models/plot_marker.glb` | Blender script in this repo | original, project-authored | flat principled colors, no textures | 224 tris | none | `scenes/props/plot_marker.tscn` | in-engine |
| `crop.placeholder` | `PlaceholderCrop` | primitives in `scenes/props/placeholder_crop.tscn` | n/a | in-engine primitives | project original | flat colors | primitive | stage swap, no clip | `first_farm.tscn` | placeholder |
| `building.workshop.v1` | `PlaceholderWorkshop` | `tools/blender/workshop.py` | `assets/models/workshop.glb` | Blender script in this repo | original, project-authored | flat principled colors, no textures | 1536 tris | none on the shed | `scenes/buildings/placeholder_workshop.tscn` | in-engine |
| `prop.loom_beam.v1` | `LoomArm` | `tools/blender/workshop.py` | `assets/models/loom_beam.glb` | Blender script in this repo | original, project-authored | flat principled colors, no textures | 212 tris | scripted spin while the job is busy | `scenes/buildings/placeholder_workshop.tscn` | in-engine |
| `prop.loom_shuttle.v1` | `Shuttle` | `tools/blender/workshop.py` | `assets/models/loom_shuttle.glb` | Blender script in this repo | original, project-authored | flat principled colors, no textures | 324 tris | scripted slide while the job is busy | `scenes/buildings/placeholder_workshop.tscn` | in-engine |
| `loft.placeholder` | `PlaceholderBarnLoft` | boxes in `scenes/buildings/placeholder_loft.tscn` | n/a | in-engine primitives | project original | flat colors | primitive | none | `first_farm.tscn` | placeholder |
| `shuttle.placeholder` | `PlaceholderShuttleRack` | boxes in `scenes/buildings/placeholder_shuttle_rack.tscn` | n/a | in-engine primitives | project original | flat colors | primitive | none | `first_farm.tscn` | placeholder |
| `icon.game` | project icon | `icon.svg` | svg | in-repo vector | project original | flat fills | n/a | none | project settings | block-out icon, not marketing art |

External source URL for every glTF file: none. The box barn, the sine-wave walker, the cylinder trees, the box shed, and the box flag are no longer instanced. `in-engine` means Godot imports the glTF and a scene instances it. It does not mean art-director acceptance. Commercial use of the project-authored meshes is allowed because this project made them.

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
