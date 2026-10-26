# Asset registry

Stub. Add a row before a new source file is used in a scene. Status `placeholder` means it is not final art, even if it is on screen.

No third-party model, texture, audio, or font is imported. Everything below was authored in this repo as engine primitives or a shader.

| Id | Scene node | Source | Export | Author | License | Materials | Polys | Animation | Scenes | Status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `terrain.placeholder` | `PlaceholderTerrain` | `assets/shaders/placeholder_terrain.gdshader` on a 48×48 subdivided `PlaneMesh` | n/a | in-engine shader | project original | shader albedo, no textures | generated | none | `first_farm.tscn` | placeholder |
| `barn.placeholder` | `PlaceholderBarn` | boxes and one `PrismMesh` inside the scene | n/a | in-engine primitives | project original | flat `StandardMaterial3D` | primitive | none | `first_farm.tscn` | placeholder |
| `tree.placeholder` | `PlaceholderTreeA/B/C` | cylinder and sphere in the scene | n/a | in-engine primitives | project original | flat colors | primitive | none | `first_farm.tscn` | placeholder |
| `walker.placeholder` | `PlaceholderWalker` | boxes, sphere, scale 1.25 | n/a | in-engine primitives | project original | flat colors | primitive | procedural limb swing in `placeholder_walker.gd`, not a clip | `first_farm.tscn` | placeholder |
| `icon.game` | project icon | `icon.svg` | svg | in-repo vector | project original | flat fills | n/a | none | project settings | block-out icon, not marketing art |

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
