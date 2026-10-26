"""Build the FinoFarm barn and export assets/models/barn.glb.

Project-original mesh. Gable roof, door, windows, and cupola. Not a primitive stand-in.
The door faces Blender -Y, which is +Z after the glTF Y-up export.
"""

import math
import sys
from pathlib import Path

import bmesh
import bpy


OUT = Path("/workspace/assets/models/barn.glb")
PREVIEW = Path("/tmp/finofarm-barn.png")

WIDTH = 5.2
DEPTH = 4.2
PLINTH_H = 0.36
WALL_H = 2.35
ROOF_RISE = 1.45


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


def box(name, location, size, mat, rotation=(0.0, 0.0, 0.0), bevel=0.0):
    bpy.ops.object.select_all(action="DESELECT")
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=location)
    obj = bpy.context.active_object
    obj.name = name
    obj.scale = size
    obj.rotation_euler = rotation
    bpy.ops.object.transform_apply(location=False, rotation=True, scale=True)
    if bevel > 0.0:
        mod = obj.modifiers.new("Bevel", "BEVEL")
        mod.width = bevel
        mod.segments = 2
        mod.limit_method = "ANGLE"
        bpy.ops.object.modifier_apply(modifier="Bevel")
    obj.data.materials.append(mat)
    return obj


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


def build_roof(mat):
    half_x = WIDTH / 2.0 + 0.38
    half_y = DEPTH / 2.0 + 0.28
    z0 = PLINTH_H + WALL_H - 0.05

    def builder(bm):
        verts = [
            bm.verts.new((-half_x, -half_y, z0)),
            bm.verts.new((half_x, -half_y, z0)),
            bm.verts.new((half_x, half_y, z0)),
            bm.verts.new((-half_x, half_y, z0)),
            bm.verts.new((0.0, -half_y, z0 + ROOF_RISE)),
            bm.verts.new((0.0, half_y, z0 + ROOF_RISE)),
        ]
        bm.verts.ensure_lookup_table()

        def face(indices):
            bm.faces.new([bm.verts[index] for index in indices])

        face((0, 3, 5, 4))
        face((1, 4, 5, 2))
        face((0, 4, 1))
        face((3, 2, 5))

    obj = mesh_object("BarnRoof", builder, mat)
    bpy.context.view_layer.objects.active = obj
    solid = obj.modifiers.new("Solidify", "SOLIDIFY")
    solid.thickness = 0.1
    solid.offset = 1.0
    bpy.ops.object.modifier_apply(modifier="Solidify")
    return obj


def build_gable(name, y, mat):
    half_x = WIDTH / 2.0 - 0.08
    z0 = PLINTH_H + WALL_H - 0.02

    def builder(bm):
        v0 = bm.verts.new((-half_x, y, z0))
        v1 = bm.verts.new((half_x, y, z0))
        v2 = bm.verts.new((0.0, y, z0 + ROOF_RISE - 0.08))
        bm.faces.new((v0, v1, v2))

    return mesh_object(name, builder, mat)


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


def export_glb():
    operator = bpy.ops.export_scene.gltf
    props = set(operator.get_rna_type().properties.keys())
    kwargs = {
        "filepath": str(OUT),
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


def main():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    wall = material("BarnWall", "#EDE0C4", 0.82)
    base = material("BarnBase", "#735737", 0.9)
    roof = material("BarnRoof", "#8C4636", 0.78)
    door = material("BarnDoor", "#6B4228", 0.7)
    trim = material("BarnTrim", "#6E4A2C", 0.8)
    window = material("BarnWindow", "#8FB7C9", 0.22)

    wall_z = PLINTH_H + WALL_H / 2.0
    front = -DEPTH / 2.0
    box("BarnPlinth", (0, 0, PLINTH_H / 2.0), (WIDTH + 0.45, DEPTH + 0.4, PLINTH_H), base, bevel=0.03)
    box("BarnSideL", (-WIDTH / 2.0 + 0.16, 0.05, wall_z), (0.28, DEPTH - 0.2, WALL_H), wall, bevel=0.02)
    box("BarnSideR", (WIDTH / 2.0 - 0.16, 0.05, wall_z), (0.28, DEPTH - 0.2, WALL_H), wall, bevel=0.02)
    box("BarnBack", (0, DEPTH / 2.0 - 0.16, wall_z), (WIDTH - 0.2, 0.28, WALL_H), wall, bevel=0.02)
    box("BarnFrontL", (-1.45, front + 0.16, wall_z), (WIDTH / 2.0 - 1.05, 0.28, WALL_H), wall, bevel=0.02)
    box("BarnFrontR", (1.45, front + 0.16, wall_z), (WIDTH / 2.0 - 1.05, 0.28, WALL_H), wall, bevel=0.02)
    box(
        "BarnLintel",
        (0, front + 0.16, PLINTH_H + WALL_H - 0.28),
        (1.7, 0.28, 0.56),
        wall,
        bevel=0.02,
    )
    build_gable("BarnGableFront", front + 0.18, wall)
    build_gable("BarnGableBack", DEPTH / 2.0 - 0.18, wall)
    build_roof(roof)
    box("BarnRidge", (0, 0.05, PLINTH_H + WALL_H + ROOF_RISE + 0.02), (0.18, DEPTH + 0.7, 0.12), trim)
    for x in (-WIDTH / 2.0 - 0.02, WIDTH / 2.0 + 0.02):
        for y in (front - 0.02, DEPTH / 2.0 + 0.02):
            box(
                f"BarnPost_{x:.1f}_{y:.1f}",
                (x, y, PLINTH_H + WALL_H / 2.0),
                (0.16, 0.16, WALL_H + 0.15),
                trim,
            )
    box("BarnDoorL", (-0.36, front - 0.02, PLINTH_H + 0.95), (0.62, 0.08, 1.85), door, bevel=0.015)
    box("BarnDoorR", (0.36, front - 0.02, PLINTH_H + 0.95), (0.62, 0.08, 1.85), door, bevel=0.015)
    brace_z = PLINTH_H + 1.05
    box("BarnBraceA", (-0.36, front - 0.08, brace_z), (0.72, 0.03, 0.08), trim, rotation=(0, math.radians(52), 0))
    box("BarnBraceB", (-0.36, front - 0.08, brace_z), (0.72, 0.03, 0.08), trim, rotation=(0, math.radians(-52), 0))
    box("BarnBraceC", (0.36, front - 0.08, brace_z), (0.72, 0.03, 0.08), trim, rotation=(0, math.radians(52), 0))
    box("BarnBraceD", (0.36, front - 0.08, brace_z), (0.72, 0.03, 0.08), trim, rotation=(0, math.radians(-52), 0))
    box("BarnLoft", (0, front - 0.02, PLINTH_H + WALL_H + 0.55), (0.7, 0.08, 0.55), door)
    for side, x in (("L", -WIDTH / 2.0 - 0.02), ("R", WIDTH / 2.0 + 0.02)):
        sign = -1 if x < 0 else 1
        box(f"BarnWindowFrame{side}", (x, 0.15, PLINTH_H + 1.45), (0.1, 0.78, 0.62), trim)
        box(
            f"BarnWindowPane{side}",
            (x + sign * 0.04, 0.15, PLINTH_H + 1.45),
            (0.04, 0.52, 0.38),
            window,
        )
    cupola_z = PLINTH_H + WALL_H + ROOF_RISE + 0.28
    box("BarnCupola", (0, 0.05, cupola_z), (0.55, 0.55, 0.46), wall, bevel=0.02)
    box("BarnCupolaRoof", (0, 0.05, cupola_z + 0.32), (0.78, 0.78, 0.16), roof)
    box("BarnCupolaCap", (0, 0.05, cupola_z + 0.46), (0.12, 0.12, 0.22), trim)

    bpy.ops.object.camera_add(location=(6.2, -8.4, 3.4))
    camera = bpy.context.active_object
    camera.name = "PreviewCamera"
    direction = __import__("mathutils").Vector((0.0, 0.0, 1.6)) - camera.location
    camera.rotation_euler = direction.to_track_quat("-Z", "Y").to_euler()
    bpy.context.scene.camera = camera
    try:
        bpy.context.scene.render.engine = "BLENDER_WORKBENCH"
        bpy.context.scene.render.resolution_x = 800
        bpy.context.scene.render.resolution_y = 600
        bpy.context.scene.render.filepath = str(PREVIEW)
        bpy.ops.render.render(write_still=True)
        print(f"preview {PREVIEW}")
    except Exception as exc:
        print(f"preview skipped: {exc}")
    bpy.data.objects.remove(camera, do_unlink=True)

    tris = triangle_count()
    OUT.parent.mkdir(parents=True, exist_ok=True)
    if OUT.exists():
        OUT.unlink()
    export_glb()
    size = OUT.stat().st_size
    print(f"triangles {tris}")
    print(f"exported {OUT} ({size} bytes)")
    if size < 1000:
        print("glb too small", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
