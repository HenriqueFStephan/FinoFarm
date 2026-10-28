"""Build the textile shed and the moving loom parts.

Project-authored meshes. The shed matches the barn: cream walls, wood posts,
a clay roof. The open sides face the default isometric camera. The beam and
the shuttle are separate glTF files so Godot can spin and slide them.
First stylized pass, not approved final art.

Blender -Y is Godot +Z after the Y-up export. The camera sits on Godot +X/+Z,
so those sides stay open.
"""

import sys
from pathlib import Path

import bpy


OUT_SHED = Path("/workspace/assets/models/workshop.glb")
OUT_BEAM = Path("/workspace/assets/models/loom_beam.glb")
OUT_SHUTTLE = Path("/workspace/assets/models/loom_shuttle.glb")
PREVIEW = Path("/tmp/finofarm-workshop.png")


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
    size = path.stat().st_size
    tris = triangle_count()
    print(f"triangles {tris}")
    print(f"exported {path} ({size} bytes)")
    if size < 400 or tris < 12:
        print(f"export looks empty: {path}", file=sys.stderr)
        sys.exit(1)
    return tris


def build_shed(wall, base, roof, trim, window):
    # Floor. Top sits just above the ground.
    box("ShedFloor", (0.0, 0.0, 0.05), (2.7, 2.2, 0.1), base, bevel=0.02)
    # Posts. Tops meet the roof. Open sides are Blender +X and -Y.
    post_h = 1.22
    for x in (-1.15, 1.15):
        for y in (-0.92, 0.92):
            box(
                f"ShedPost_{x:.2f}_{y:.2f}",
                (x, y, post_h / 2.0),
                (0.16, 0.16, post_h),
                trim,
                bevel=0.025,
            )
    # Back wall, Godot -Z. Far wall, Godot -X. Both read from the open corner.
    box("ShedBackWall", (0.0, 0.82, 0.58), (2.15, 0.14, 1.05), wall, bevel=0.03)
    box("ShedSideWall", (-1.02, -0.02, 0.58), (0.14, 1.7, 1.05), wall, bevel=0.03)
    box("ShedWindowFrame", (-1.12, -0.02, 0.72), (0.08, 0.46, 0.36), trim)
    box("ShedWindowPane", (-1.16, -0.02, 0.72), (0.04, 0.28, 0.2), window)
    # Low sill on the open front so the shed still has a base without hiding the loom.
    box("ShedSill", (0.15, -0.9, 0.2), (2.05, 0.12, 0.28), wall, bevel=0.02)
    # Loom frame, static. The spinning beam is a separate file.
    box("LoomPostL", (-0.32, -0.18, 0.58), (0.08, 0.08, 0.92), trim, bevel=0.012)
    box("LoomPostR", (0.42, -0.18, 0.58), (0.08, 0.08, 0.92), trim, bevel=0.012)
    box("LoomTop", (0.05, -0.18, 1.02), (0.86, 0.08, 0.08), trim, bevel=0.012)
    box("LoomRail", (0.05, -0.32, 0.5), (0.78, 0.06, 0.06), trim, bevel=0.01)
    # Roof slab. Top is about 1.47 so the shuttle rack still sits on it.
    box("ShedRoof", (0.02, -0.02, 1.34), (3.05, 2.5, 0.22), roof, bevel=0.05)
    box("ShedRidge", (0.02, -0.02, 1.5), (0.14, 2.35, 0.1), trim, bevel=0.015)


def preview_shed():
    bpy.ops.object.camera_add(location=(3.6, -4.2, 2.4))
    camera = bpy.context.active_object
    camera.name = "PreviewCamera"
    direction = __import__("mathutils").Vector((0.0, 0.0, 0.8)) - camera.location
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


def build_beam(wood, amber):
    bpy.ops.mesh.primitive_cylinder_add(
        vertices=12,
        radius=0.045,
        depth=0.68,
        location=(0.34, 0.0, 0.0),
        rotation=(0.0, 1.5708, 0.0),
    )
    beam = bpy.context.active_object
    beam.name = "LoomBeam"
    beam.data.materials.append(wood)
    shade_smooth(beam)
    bpy.ops.mesh.primitive_uv_sphere_add(segments=12, ring_count=8, radius=0.07, location=(0.68, 0.0, 0.0))
    knob = bpy.context.active_object
    knob.name = "LoomKnob"
    knob.data.materials.append(amber)
    shade_smooth(knob)
    activate(beam)
    knob.select_set(True)
    bpy.ops.object.join()
    beam = bpy.context.active_object
    beam.name = "LoomBeam"
    bpy.context.scene.cursor.location = (0.0, 0.0, 0.0)
    bpy.ops.object.origin_set(type="ORIGIN_CURSOR")


def build_shuttle(wood, amber):
    box("ShuttleBody", (0.0, 0.0, 0.0), (0.3, 0.11, 0.08), amber, bevel=0.015)
    box("ShuttleTipL", (-0.16, 0.0, 0.0), (0.08, 0.05, 0.045), wood, bevel=0.01)
    box("ShuttleTipR", (0.16, 0.0, 0.0), (0.08, 0.05, 0.045), wood, bevel=0.01)
    for obj in list(bpy.data.objects):
        if obj.type == "MESH":
            shade_smooth(obj)


def fresh():
    bpy.ops.wm.read_factory_settings(use_empty=True)


def main():
    fresh()
    wall = material("ShedWall", "#EDE0C4", 0.82)
    base = material("ShedBase", "#735737", 0.9)
    roof = material("ShedRoof", "#8C4636", 0.78)
    trim = material("ShedTrim", "#6E4A2C", 0.84)
    window = material("ShedWindow", "#8FB7C9", 0.25)
    build_shed(wall, base, roof, trim, window)
    preview_shed()
    OUT_SHED.parent.mkdir(parents=True, exist_ok=True)
    if OUT_SHED.exists():
        OUT_SHED.unlink()
    shed_tris = export_glb(OUT_SHED)

    fresh()
    wood = material("LoomWood", "#6E4A2C", 0.8)
    amber = material("LoomAmber", "#C67A2E", 0.62)
    build_beam(wood, amber)
    if OUT_BEAM.exists():
        OUT_BEAM.unlink()
    beam_tris = export_glb(OUT_BEAM)

    fresh()
    wood = material("ShuttleWood", "#6E4A2C", 0.8)
    amber = material("ShuttleAmber", "#C67A2E", 0.62)
    build_shuttle(wood, amber)
    if OUT_SHUTTLE.exists():
        OUT_SHUTTLE.unlink()
    shuttle_tris = export_glb(OUT_SHUTTLE)
    print(f"summary shed {shed_tris} beam {beam_tris} shuttle {shuttle_tris}")


if __name__ == "__main__":
    main()
