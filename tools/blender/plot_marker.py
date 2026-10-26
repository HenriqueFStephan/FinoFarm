"""Build a plot stake and export assets/models/plot_marker.glb.

Project-authored mesh. The stake sits on the rim of the fiber plot so the
growth stages stay visible in the middle. First stylized pass, not final art.
The scene root stays at the cell center, on the ground.
"""

import sys
from pathlib import Path

import bmesh
import bpy


OUT = Path("/workspace/assets/models/plot_marker.glb")
PREVIEW = Path("/tmp/finofarm-plot-marker.png")

# Rim of the soil disc. Blender -Y becomes Godot +Z.
STAKE_X = 0.5
STAKE_Y = -0.44


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


def mesh_object(name, builder, mat):
    mesh = bpy.data.meshes.new(name)
    bm = bmesh.new()
    builder(bm)
    bmesh.ops.recalc_face_normals(bm, faces=list(bm.faces))
    bm.to_mesh(mesh)
    bm.free()
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(obj)
    obj.data.materials.append(mat)
    return obj


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


def build_stake(mat):
    bpy.ops.mesh.primitive_cylinder_add(
        vertices=12,
        radius=0.055,
        depth=0.92,
        location=(STAKE_X, STAKE_Y, 0.46),
    )
    stake = bpy.context.active_object
    stake.name = "MarkerStake"
    # Vertices are local to the stake. The object location carries the rim offset.
    for vert in stake.data.vertices:
        if vert.co.z > 0.22:
            vert.co.x *= 0.62
            vert.co.y *= 0.62
        elif vert.co.z < -0.34:
            vert.co.x *= 1.35
            vert.co.y *= 1.35
    stake.data.materials.append(mat)
    shade_smooth(stake)
    return stake


def build_finial(mat):
    bpy.ops.mesh.primitive_uv_sphere_add(
        segments=12,
        ring_count=8,
        radius=0.055,
        location=(STAKE_X, STAKE_Y, 0.96),
    )
    finial = bpy.context.active_object
    finial.name = "MarkerFinial"
    finial.scale = (1.0, 1.0, 0.85)
    bpy.ops.object.transform_apply(location=False, rotation=True, scale=True)
    finial.data.materials.append(mat)
    shade_smooth(finial)
    return finial


def build_flag(mat):
    anchor_x = STAKE_X + 0.02
    anchor_z = 0.8

    def builder(bm):
        # Vertical pennant in the Blender XZ plane, flying away from the plot.
        verts = [
            bm.verts.new((anchor_x, STAKE_Y, anchor_z)),
            bm.verts.new((anchor_x + 0.34, STAKE_Y, anchor_z + 0.02)),
            bm.verts.new((anchor_x + 0.28, STAKE_Y + 0.015, anchor_z - 0.12)),
            bm.verts.new((anchor_x + 0.02, STAKE_Y, anchor_z - 0.11)),
        ]
        bm.faces.new(verts)

    flag = mesh_object("MarkerFlag", builder, mat)
    activate(flag)
    solid = flag.modifiers.new("Solidify", "SOLIDIFY")
    solid.thickness = 0.018
    solid.offset = 0.0
    bpy.ops.object.modifier_apply(modifier="Solidify")
    shade_smooth(flag)
    return flag


def preview():
    bpy.ops.object.camera_add(location=(1.8, -1.6, 1.1))
    camera = bpy.context.active_object
    camera.name = "PreviewCamera"
    direction = __import__("mathutils").Vector((0.4, -0.2, 0.45)) - camera.location
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
    wood = material("MarkerWood", "#6E4A2C", 0.88)
    cream = material("MarkerFinial", "#EDE0C4", 0.72)
    amber = material("MarkerFlag", "#C67A2E", 0.68)
    build_stake(wood)
    build_finial(cream)
    build_flag(amber)
    preview()
    tris = triangle_count()
    OUT.parent.mkdir(parents=True, exist_ok=True)
    if OUT.exists():
        OUT.unlink()
    export_glb(OUT)
    size = OUT.stat().st_size
    print(f"triangles {tris}")
    print(f"exported {OUT} ({size} bytes)")
    if size < 400 or tris < 20:
        print("marker export looks empty", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
