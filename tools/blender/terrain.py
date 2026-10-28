"""Build a small valley ground and export assets/models/terrain.glb.

Project-authored mesh. A flat yard holds the barn pad, the square dirt path,
and the plot grid. Rounded hills rise outside that yard. First terrain pass,
not approved final art. Materials use the art-bible grass and path swatches.
"""

import math
import sys
from pathlib import Path

import bmesh
import bpy


OUT = Path("/workspace/assets/models/terrain.glb")

SIZE = 52.0
SEGMENTS = 128
YARD = 9.15
PATH_MIN = 5.40
PATH_MAX = 7.00
# Meters from the square yard to full hill weight. Long enough that the bank
# is one slope, not a stack of faces.
LIP = 7.5


def srgb_channel(value):
    # Blender writes the Principled socket straight into glTF baseColorFactor.
    # Godot treats that factor as linear, so the bible hex has to be decoded here.
    if value <= 0.04045:
        return value / 12.92
    return ((value + 0.055) / 1.055) ** 2.4


def srgb_rgba(hex_value):
    value = hex_value.lstrip("#")
    channels = [int(value[i : i + 2], 16) / 255.0 for i in (0, 2, 4)]
    return tuple(srgb_channel(channel) for channel in channels) + (1.0,)


# Art bible: grass light #4D7A3D, grass shadow #295224, path #855E33.
GRASS_A = srgb_rgba("#4D7A3D")
GRASS_B = srgb_rgba("#295224")
PATH = srgb_rgba("#855E33")

MOUNDS = (
    (-16.5, -14.0, 11.0, 3.1),
    (1.5, -20.0, 9.5, 2.6),
    (18.0, -9.0, 8.0, 1.7),
    (17.0, 14.0, 9.0, 2.4),
    (-7.5, 18.5, 9.0, 2.3),
    (-20.0, 4.5, 10.0, 2.9),
)


def smoothstep(edge0, edge1, value):
    if value <= edge0:
        return 0.0
    if value >= edge1:
        return 1.0
    span = (value - edge0) / (edge1 - edge0)
    return span * span * (3.0 - 2.0 * span)


def mound(gx, gz, cx, cz, radius, amplitude):
    distance = math.hypot(gx - cx, gz - cz) / radius
    if distance >= 1.0:
        return 0.0
    falloff = 1.0 - distance
    return amplitude * falloff * falloff * (3.0 - 2.0 * falloff)


def outside_square(gx, gz):
    """Distance outside the flat yard. Zero inside. Corners are quarter circles."""
    dx = max(abs(gx) - YARD, 0.0)
    dz = max(abs(gz) - YARD, 0.0)
    return math.hypot(dx, dz)


def height_godot(gx, gz):
    yard = max(abs(gx), abs(gz))
    if yard <= YARD:
        return 0.0
    # Smoothstep has zero slope where it meets the yard, then climbs one bank.
    eased = smoothstep(0.0, LIP, outside_square(gx, gz))
    bank = eased * 1.45
    hills = 0.0
    for cx, cz, radius, amplitude in MOUNDS:
        hills += mound(gx, gz, cx, cz, radius, amplitude)
    # No cutouts. A shelf around a trunk reads as a hole in the bank.
    return bank + hills * eased * 0.62


def grass_tint(height):
    """Smooth darkening toward the shadow swatch. No face boundary."""
    mix = smoothstep(0.2, 2.8, height)
    return (
        1.0 + (GRASS_B[0] / GRASS_A[0] - 1.0) * mix,
        1.0 + (GRASS_B[1] / GRASS_A[1] - 1.0) * mix,
        1.0 + (GRASS_B[2] / GRASS_A[2] - 1.0) * mix,
        1.0,
    )


def material(name, color, use_vertex_color=False):
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    nodes = mat.node_tree.nodes
    links = mat.node_tree.links
    bsdf = nodes.get("Principled BSDF")
    if "Base Color" in bsdf.inputs:
        bsdf.inputs["Base Color"].default_value = color
    if "Roughness" in bsdf.inputs:
        bsdf.inputs["Roughness"].default_value = 0.94
    if "Coat Weight" in bsdf.inputs:
        bsdf.inputs["Coat Weight"].default_value = 0.0
    if use_vertex_color and "Base Color" in bsdf.inputs:
        paint = nodes.new("ShaderNodeVertexColor")
        paint.layer_name = "Color"
        # Multiply keeps the bible grass on the yard and darkens it on the slope.
        product = nodes.new("ShaderNodeMix")
        product.data_type = "RGBA"
        product.blend_type = "MULTIPLY"
        product.inputs["Factor"].default_value = 1.0
        plain = nodes.new("ShaderNodeRGB")
        plain.outputs[0].default_value = color
        links.new(paint.outputs["Color"], product.inputs["A"])
        links.new(plain.outputs["Color"], product.inputs["B"])
        links.new(product.outputs["Result"], bsdf.inputs["Base Color"])
    return mat


def on_path(gx, gz, height):
    yard = max(abs(gx), abs(gz))
    return PATH_MIN <= yard <= PATH_MAX and height < 0.05


def build_mesh():
    mesh = bpy.data.meshes.new("ValleyGround")
    bm = bmesh.new()
    grid = []
    step = SIZE / SEGMENTS
    origin = -SIZE / 2.0
    for iz in range(SEGMENTS + 1):
        row = []
        blender_y = origin + step * iz
        for ix in range(SEGMENTS + 1):
            blender_x = origin + step * ix
            godot_x = blender_x
            godot_z = -blender_y
            row.append(bm.verts.new((blender_x, blender_y, height_godot(godot_x, godot_z))))
        grid.append(row)
    bm.verts.ensure_lookup_table()
    for iz in range(SEGMENTS):
        for ix in range(SEGMENTS):
            face = bm.faces.new((grid[iz][ix], grid[iz][ix + 1], grid[iz + 1][ix + 1], grid[iz + 1][ix]))
            face.smooth = True
    bm.faces.ensure_lookup_table()
    bm.normal_update()
    if bm.faces[0].normal.z < 0.0:
        bmesh.ops.reverse_faces(bm, faces=list(bm.faces))
        bm.normal_update()
    color_layer = bm.loops.layers.color.new("Color")
    for face in bm.faces:
        center = face.calc_center_median()
        path_face = on_path(center.x, -center.y, center.z)
        face.material_index = 1 if path_face else 0
        for loop in face.loops:
            if path_face:
                loop[color_layer] = (1.0, 1.0, 1.0, 1.0)
            else:
                loop[color_layer] = grass_tint(loop.vert.co.z)
    bm.to_mesh(mesh)
    bm.free()
    obj = bpy.data.objects.new("ValleyGround", mesh)
    bpy.context.collection.objects.link(obj)
    obj.data.materials.append(material("ValleyGrass", GRASS_A, use_vertex_color=True))
    obj.data.materials.append(material("ValleyPath", PATH))
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    bpy.ops.object.shade_smooth()
    return obj


def triangle_count():
    total = 0
    depsgraph = bpy.context.evaluated_depsgraph_get()
    for obj in bpy.data.objects:
        if obj.type != "MESH":
            continue
        evaluated = obj.evaluated_get(depsgraph).to_mesh()
        evaluated.calc_loop_triangles()
        total += len(evaluated.loop_triangles)
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


def check_shape():
    samples = {
        "pad": ((0.0, 0.0), 0.0),
        "path": ((6.2, 2.4), 0.0),
        "plot edge": ((8.6, 0.2), 0.0),
        "plot corner": ((8.0, 8.0), 0.0),
        "bank": ((10.3, 0.4), 0.4),
        "tree ground": ((11.5, -5.0), 0.7),
        "rise": ((13.4, 0.2), 0.55),
        "hill": ((-16.5, -14.0), 1.5),
    }
    for name, (point, limit) in samples.items():
        height = height_godot(point[0], point[1])
        print(f"sample {name} height {height:.3f}")
        if name in ("hill", "rise"):
            if height < limit:
                print(f"{name} is too low", file=sys.stderr)
                return False
        elif height > limit:
            print(f"{name} is not flat", file=sys.stderr)
            return False
    return True


def main():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    if not check_shape():
        sys.exit(1)
    build_mesh()
    tris = triangle_count()
    OUT.parent.mkdir(parents=True, exist_ok=True)
    if OUT.exists():
        OUT.unlink()
    export_glb(OUT)
    size = OUT.stat().st_size
    print(f"triangles {tris}")
    print(f"exported {OUT} ({size} bytes)")
    if size < 1000 or tris < 1000:
        print("terrain export looks empty", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
