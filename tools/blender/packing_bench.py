"""Build the packing bench and its crate.

The bench is a low counter with a teal awning. It is not the workshop shed.
The crate is a separate glTF so the game can bob it while a wrap is running.
First stylized pass, not final art.
"""

import sys
from pathlib import Path

import bpy


OUT_BENCH = Path("/workspace/assets/models/packing_bench.glb")
OUT_CRATE = Path("/workspace/assets/models/packing_crate.glb")


def hex_rgba(value):
    value = value.lstrip("#")
    return (
        int(value[0:2], 16) / 255.0,
        int(value[2:4], 16) / 255.0,
        int(value[4:6], 16) / 255.0,
        1.0,
    )


def material(name, color, roughness=0.78):
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


def box(name, location, size, mat, bevel=0.0):
    bpy.ops.object.select_all(action="DESELECT")
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=location)
    obj = bpy.context.active_object
    obj.name = name
    obj.scale = size
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    if bevel > 0.0:
        mod = obj.modifiers.new("Bevel", "BEVEL")
        mod.width = bevel
        mod.segments = 1
        mod.limit_method = "ANGLE"
        bpy.ops.object.modifier_apply(modifier="Bevel")
    obj.data.materials.append(mat)
    return obj


def join(parts, name):
    bpy.ops.object.select_all(action="DESELECT")
    for part in parts:
        part.select_set(True)
    bpy.context.view_layer.objects.active = parts[0]
    bpy.ops.object.join()
    body = bpy.context.active_object
    body.name = name
    return body


def triangle_count():
    total = 0
    depsgraph = bpy.context.evaluated_depsgraph_get()
    for obj in bpy.context.scene.objects:
        if obj.type != "MESH":
            continue
        mesh = obj.evaluated_get(depsgraph).to_mesh()
        mesh.calc_loop_triangles()
        total += len(mesh.loop_triangles)
        obj.evaluated_get(depsgraph).to_mesh_clear()
    return total


def export(path):
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


def main():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    cream = material("Counter", "#EDE0C4")
    wood = material("Wood", "#735737")
    roof = material("Awning", "#8FB7C9", 0.55)
    post = material("Post", "#6E4A2C")
    crate_mat = material("Crate", "#855E33", 0.84)
    parts = [
        box("Top", (0, 0, 0.78), (2.4, 1.15, 0.12), cream, 0.02),
        box("Front", (0, 0.42, 0.48), (2.2, 0.08, 0.48), cream, 0.015),
        box("Leg.L", (-1.0, -0.4, 0.36), (0.12, 0.12, 0.72), wood),
        box("Leg.R", (1.0, -0.4, 0.36), (0.12, 0.12, 0.72), wood),
        box("Leg.FL", (-1.0, 0.4, 0.36), (0.12, 0.12, 0.72), wood),
        box("Leg.FR", (1.0, 0.4, 0.36), (0.12, 0.12, 0.72), wood),
        box("Awning", (0, 0.05, 1.35), (2.7, 1.45, 0.08), roof, 0.02),
        box("Post.L", (-1.15, -0.55, 1.05), (0.1, 0.1, 0.7), post),
        box("Post.R", (1.15, -0.55, 1.05), (0.1, 0.1, 0.7), post),
        box("Stripe", (0, 0.48, 0.62), (1.4, 0.04, 0.08), roof),
    ]
    join(parts, "PackingBench")
    bench_tris = triangle_count()
    OUT_BENCH.parent.mkdir(parents=True, exist_ok=True)
    if OUT_BENCH.exists():
        OUT_BENCH.unlink()
    export(OUT_BENCH)
    print(f"bench triangles {bench_tris}")
    print(f"exported {OUT_BENCH} ({OUT_BENCH.stat().st_size} bytes)")

    bpy.ops.wm.read_factory_settings(use_empty=True)
    crate_mat = material("Crate", "#855E33", 0.84)
    band = material("Band", "#EDE0C4", 0.7)
    crate_parts = [
        box("CrateBody", (0, 0, 0.16), (0.46, 0.36, 0.32), crate_mat, 0.015),
        box("Band", (0, 0, 0.16), (0.48, 0.08, 0.08), band),
    ]
    join(crate_parts, "PackingCrate")
    crate_tris = triangle_count()
    if OUT_CRATE.exists():
        OUT_CRATE.unlink()
    export(OUT_CRATE)
    print(f"crate triangles {crate_tris}")
    print(f"exported {OUT_CRATE} ({OUT_CRATE.stat().st_size} bytes)")


if __name__ == "__main__":
    main()
