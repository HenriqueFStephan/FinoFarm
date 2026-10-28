"""Build a cozy grove tree and export assets/models/tree.glb.

Project-authored mesh. Rounded trunk and a lumpy canopy, palette colors from
docs/art-bible.md. First stylized pass, not approved final art.
"""

import sys
from pathlib import Path

import bpy


OUT = Path("/workspace/assets/models/tree.glb")
PREVIEW = Path("/tmp/finofarm-tree.png")


def hex_rgba(value):
    value = value.lstrip("#")
    return (
        int(value[0:2], 16) / 255.0,
        int(value[2:4], 16) / 255.0,
        int(value[4:6], 16) / 255.0,
        1.0,
    )


def material(name, color, roughness=0.8):
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
    if "Base Color" in bsdf.inputs:
        bsdf.inputs["Base Color"].default_value = hex_rgba(color)
    if "Roughness" in bsdf.inputs:
        bsdf.inputs["Roughness"].default_value = roughness
    if "Coat Weight" in bsdf.inputs:
        bsdf.inputs["Coat Weight"].default_value = 0.0
    return mat


def activate(obj):
    bpy.ops.object.select_all(action="DESELECT")
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj


def shade_smooth(obj):
    activate(obj)
    bpy.ops.object.shade_smooth()


def triangle_count():
    total = 0
    depsgraph = bpy.context.evaluated_depsgraph_get()
    for obj in bpy.data.objects:
        if obj.type != "MESH" or obj.name.startswith("Preview"):
            continue
        mesh = obj.evaluated_get(depsgraph).to_mesh()
        mesh.calc_loop_triangles()
        total += len(mesh.loop_triangles)
        obj.evaluated_get(depsgraph).to_mesh_clear()
    return total


def export_glb(path):
    operator = bpy.ops.export_scene.gltf
    props = set(operator.get_rna_type().properties.keys())
    kwargs = {
        "filepath": str(path),
        "export_format": "GLB",
        "export_yup": True,
        "export_apply": True,
        "export_animations": False,
        "export_skins": False,
        "export_lights": False,
        "export_cameras": False,
    }
    filtered = {key: value for key, value in kwargs.items() if key == "filepath" or key in props}
    operator(**filtered)


def build_trunk(mat):
    bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=0.16, depth=1.22, location=(0.0, 0.0, 0.61))
    trunk = bpy.context.active_object
    trunk.name = "TreeTrunk"
    for vert in trunk.data.vertices:
        if vert.co.z > 0.28:
            vert.co.x *= 0.62
            vert.co.y *= 0.62
        elif vert.co.z < -0.42:
            vert.co.x *= 1.45
            vert.co.y *= 1.45
        vert.co.x += (vert.co.z + 0.61) * 0.035
    trunk.data.materials.append(mat)
    shade_smooth(trunk)
    bpy.ops.mesh.primitive_uv_sphere_add(segments=12, ring_count=8, radius=0.11, location=(0.1, 0.02, 0.72))
    knot = bpy.context.active_object
    knot.name = "TreeKnot"
    knot.scale = (1.1, 0.7, 0.7)
    bpy.ops.object.transform_apply(location=False, rotation=True, scale=True)
    knot.data.materials.append(mat)
    shade_smooth(knot)
    return trunk


def build_canopy(mat):
    clumps = [
        ((0.02, 0.04, 1.78), 0.64),
        ((0.4, 0.16, 1.98), 0.4),
        ((-0.38, -0.06, 1.88), 0.42),
        ((0.06, -0.36, 1.66), 0.36),
        ((-0.14, 0.32, 2.08), 0.34),
        ((0.16, 0.0, 2.28), 0.3),
        ((-0.22, -0.18, 2.12), 0.28),
    ]
    parts = []
    for index, (location, radius) in enumerate(clumps):
        bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=radius, location=location)
        part = bpy.context.active_object
        part.name = f"CanopyClump{index}"
        part.data.materials.append(mat)
        parts.append(part)
    activate(parts[0])
    for part in parts:
        part.select_set(True)
    bpy.ops.object.join()
    canopy = bpy.context.active_object
    canopy.name = "Canopy"
    remesh = canopy.modifiers.new("Remesh", "REMESH")
    remesh.mode = "VOXEL"
    remesh.voxel_size = 0.09
    remesh.use_smooth_shade = True
    bpy.ops.object.modifier_apply(modifier="Remesh")
    smooth = canopy.modifiers.new("Smooth", "SMOOTH")
    smooth.factor = 0.45
    smooth.iterations = 3
    bpy.ops.object.modifier_apply(modifier="Smooth")
    shade_smooth(canopy)
    return canopy


def preview():
    bpy.ops.object.camera_add(location=(3.4, -4.6, 2.2))
    camera = bpy.context.active_object
    camera.name = "PreviewCamera"
    direction = __import__("mathutils").Vector((0.0, 0.0, 1.3)) - camera.location
    camera.rotation_euler = direction.to_track_quat("-Z", "Y").to_euler()
    bpy.context.scene.camera = camera
    try:
        bpy.context.scene.render.engine = "BLENDER_WORKBENCH"
        bpy.context.scene.render.resolution_x = 640
        bpy.context.scene.render.resolution_y = 480
        bpy.context.scene.render.filepath = str(PREVIEW)
        bpy.ops.render.render(write_still=True)
        print(f"preview {PREVIEW}")
    except Exception as exc:
        print(f"preview skipped: {exc}")
    bpy.data.objects.remove(camera, do_unlink=True)


def main():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    trunk_mat = material("TreeTrunk", "#6E4A2C", 0.9)
    canopy_mat = material("TreeCanopy", "#2F8A45", 0.84)
    build_trunk(trunk_mat)
    build_canopy(canopy_mat)
    preview()
    tris = triangle_count()
    OUT.parent.mkdir(parents=True, exist_ok=True)
    if OUT.exists():
        OUT.unlink()
    export_glb(OUT)
    size = OUT.stat().st_size
    print(f"triangles {tris}")
    print(f"exported {OUT} ({size} bytes)")
    if size < 1000 or tris < 80:
        print("tree export looks empty", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
