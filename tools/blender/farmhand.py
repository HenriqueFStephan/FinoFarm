"""Build the FinoFarm farmhand and export assets/models/farmhand.glb.

Project-original mesh, armature, and in-place idle/walk clips. Not a placeholder.
"""

import math
import sys
from pathlib import Path

import bpy
from mathutils import Vector


OUT = Path("/workspace/assets/models/farmhand.glb")
PREVIEW = Path("/tmp/finofarm-farmhand-walk.png")

LIMBS = [
    "Hips",
    "Spine",
    "Chest",
    "Head",
    "UpLeg.L",
    "Leg.L",
    "Foot.L",
    "UpLeg.R",
    "Leg.R",
    "Foot.R",
    "Arm.L",
    "ForeArm.L",
    "Arm.R",
    "ForeArm.R",
]


def hex_rgba(value, alpha=1.0):
    value = value.lstrip("#")
    return (
        int(value[0:2], 16) / 255.0,
        int(value[2:4], 16) / 255.0,
        int(value[4:6], 16) / 255.0,
        alpha,
    )


def set_input(node, name, value):
    if name in node.inputs:
        node.inputs[name].default_value = value


def material(name, color, roughness=0.72):
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
    set_input(bsdf, "Base Color", hex_rgba(color))
    set_input(bsdf, "Roughness", roughness)
    set_input(bsdf, "Coat Weight", 0.0)
    set_input(bsdf, "Specular IOR Level", 0.3)
    return mat


def add_bone(armature, name, head, tail, parent):
    bone = armature.edit_bones.new(name)
    bone.head = Vector(head)
    bone.tail = Vector(tail)
    bone.use_connect = False
    if parent is not None:
        bone.parent = armature.edit_bones[parent]
    direction = (bone.tail - bone.head).normalized()
    roll = Vector((0.0, 1.0, 0.0))
    if abs(direction.dot(roll)) > 0.85:
        roll = Vector((0.0, 0.0, 1.0))
    bone.align_roll(roll)
    return bone


def build_armature():
    arm_data = bpy.data.armatures.new("Armature")
    arm_obj = bpy.data.objects.new("Armature", arm_data)
    bpy.context.collection.objects.link(arm_obj)
    bpy.context.view_layer.objects.active = arm_obj
    bpy.ops.object.mode_set(mode="EDIT")
    add_bone(arm_data, "Root", (0, 0, 0.02), (0, 0, 0.16), None)
    add_bone(arm_data, "Hips", (0, 0, 0.78), (0, 0, 0.92), "Root")
    add_bone(arm_data, "Spine", (0, 0, 0.92), (0, 0, 1.14), "Hips")
    add_bone(arm_data, "Chest", (0, 0, 1.14), (0, 0, 1.34), "Spine")
    add_bone(arm_data, "Neck", (0, 0, 1.34), (0, 0, 1.46), "Chest")
    add_bone(arm_data, "Head", (0, 0, 1.46), (0, 0, 1.84), "Neck")
    add_bone(arm_data, "Arm.L", (-0.18, 0.02, 1.28), (-0.46, 0.04, 1.02), "Chest")
    add_bone(arm_data, "ForeArm.L", (-0.46, 0.04, 1.02), (-0.68, 0.08, 0.82), "Arm.L")
    add_bone(arm_data, "Arm.R", (0.18, 0.02, 1.28), (0.46, 0.04, 1.02), "Chest")
    add_bone(arm_data, "ForeArm.R", (0.46, 0.04, 1.02), (0.68, 0.08, 0.82), "Arm.R")
    add_bone(arm_data, "UpLeg.L", (-0.12, 0.0, 0.76), (-0.13, 0.02, 0.40), "Hips")
    add_bone(arm_data, "Leg.L", (-0.13, 0.02, 0.40), (-0.12, 0.0, 0.08), "UpLeg.L")
    add_bone(arm_data, "Foot.L", (-0.12, 0.0, 0.08), (-0.12, 0.18, 0.04), "Leg.L")
    add_bone(arm_data, "UpLeg.R", (0.12, 0.0, 0.76), (0.13, 0.02, 0.40), "Hips")
    add_bone(arm_data, "Leg.R", (0.13, 0.02, 0.40), (0.12, 0.0, 0.08), "UpLeg.R")
    add_bone(arm_data, "Foot.R", (0.12, 0.0, 0.08), (0.12, 0.18, 0.04), "Leg.R")
    bpy.ops.object.mode_set(mode="OBJECT")
    return arm_obj


def assign_group(obj, bone_name):
    group = obj.vertex_groups.new(name=bone_name)
    group.add(list(range(len(obj.data.vertices))), 1.0, "REPLACE")


def smooth(obj):
    for poly in obj.data.polygons:
        poly.use_smooth = True


def finish_mesh(obj, material_slot, bone_name):
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    smooth(obj)
    obj.data.materials.append(material_slot)
    assign_group(obj, bone_name)
    return obj


def add_sphere(name, location, scale, material_slot, bone_name):
    bpy.ops.object.select_all(action="DESELECT")
    bpy.ops.mesh.primitive_uv_sphere_add(
        segments=24, ring_count=16, radius=1.0, location=location
    )
    obj = bpy.context.active_object
    obj.name = name
    obj.scale = scale
    return finish_mesh(obj, material_slot, bone_name)


def add_cube(name, location, scale, material_slot, bone_name, bevel=0.0):
    bpy.ops.object.select_all(action="DESELECT")
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=location)
    obj = bpy.context.active_object
    obj.name = name
    obj.scale = scale
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    if bevel > 0.0:
        mod = obj.modifiers.new("Bevel", "BEVEL")
        mod.width = bevel
        mod.segments = 2
        mod.limit_method = "ANGLE"
        bpy.ops.object.modifier_apply(modifier="Bevel")
    return finish_mesh(obj, material_slot, bone_name)


def add_limb(name, head, tail, radius, material_slot, bone_name):
    start = Vector(head)
    end = Vector(tail)
    mid = (start + end) / 2.0
    direction = end - start
    length = max(direction.length, 0.05)
    bpy.ops.object.select_all(action="DESELECT")
    bpy.ops.mesh.primitive_uv_sphere_add(segments=16, ring_count=12, radius=1.0, location=mid)
    obj = bpy.context.active_object
    obj.name = name
    obj.scale = (radius, radius, length * 0.62)
    obj.rotation_mode = "QUATERNION"
    obj.rotation_quaternion = direction.normalized().to_track_quat("Z", "Y")
    return finish_mesh(obj, material_slot, bone_name)


def build_body(materials):
    parts = []
    skin = materials["skin"]
    shirt = materials["shirt"]
    pants = materials["pants"]
    hair = materials["hair"]
    boots = materials["boots"]
    scarf = materials["scarf"]
    eyes = materials["eyes"]
    satchel = materials["satchel"]
    parts.append(add_sphere("Head", (0, 0.02, 1.62), (0.30, 0.28, 0.30), skin, "Head"))
    parts.append(add_sphere("Hair", (0, -0.02, 1.82), (0.32, 0.30, 0.18), hair, "Head"))
    parts.append(add_sphere("Nose", (0, 0.30, 1.58), (0.045, 0.055, 0.04), skin, "Head"))
    parts.append(add_sphere("Eye.L", (-0.10, 0.24, 1.68), (0.045, 0.04, 0.05), eyes, "Head"))
    parts.append(add_sphere("Eye.R", (0.10, 0.24, 1.68), (0.045, 0.04, 0.05), eyes, "Head"))
    parts.append(add_cube("Tunic", (0, 0.02, 1.16), (0.48, 0.32, 0.42), shirt, "Chest", 0.06))
    parts.append(add_cube("Trousers", (0, 0.0, 0.84), (0.40, 0.28, 0.28), pants, "Hips", 0.05))
    parts.append(add_cube("Scarf", (0, 0.16, 1.32), (0.22, 0.10, 0.08), scarf, "Neck", 0.02))
    parts.append(add_sphere("Satchel", (0.22, -0.08, 0.98), (0.10, 0.08, 0.12), satchel, "Chest"))
    parts.append(add_limb("UpperArm.L", (-0.18, 0.02, 1.28), (-0.46, 0.04, 1.02), 0.075, shirt, "Arm.L"))
    parts.append(add_limb("LowerArm.L", (-0.46, 0.04, 1.02), (-0.68, 0.08, 0.82), 0.06, skin, "ForeArm.L"))
    parts.append(add_sphere("Hand.L", (-0.70, 0.09, 0.80), (0.055, 0.05, 0.06), skin, "ForeArm.L"))
    parts.append(add_limb("UpperArm.R", (0.18, 0.02, 1.28), (0.46, 0.04, 1.02), 0.075, shirt, "Arm.R"))
    parts.append(add_limb("LowerArm.R", (0.46, 0.04, 1.02), (0.68, 0.08, 0.82), 0.06, skin, "ForeArm.R"))
    parts.append(add_sphere("Hand.R", (0.70, 0.09, 0.80), (0.055, 0.05, 0.06), skin, "ForeArm.R"))
    parts.append(add_limb("Thigh.L", (-0.12, 0.0, 0.76), (-0.13, 0.02, 0.40), 0.105, pants, "UpLeg.L"))
    parts.append(add_limb("Shin.L", (-0.13, 0.02, 0.40), (-0.12, 0.0, 0.08), 0.08, pants, "Leg.L"))
    parts.append(add_sphere("Boot.L", (-0.12, 0.08, 0.06), (0.09, 0.14, 0.07), boots, "Foot.L"))
    parts.append(add_limb("Thigh.R", (0.12, 0.0, 0.76), (0.13, 0.02, 0.40), 0.105, pants, "UpLeg.R"))
    parts.append(add_limb("Shin.R", (0.13, 0.02, 0.40), (0.12, 0.0, 0.08), 0.08, pants, "Leg.R"))
    parts.append(add_sphere("Boot.R", (0.12, 0.08, 0.06), (0.09, 0.14, 0.07), boots, "Foot.R"))
    bpy.ops.object.select_all(action="DESELECT")
    for part in parts:
        part.select_set(True)
    bpy.context.view_layer.objects.active = parts[0]
    bpy.ops.object.join()
    body = bpy.context.active_object
    body.name = "FarmhandBody"
    return body


def bind(body, arm_obj):
    body.parent = arm_obj
    modifier = body.modifiers.new("Armature", "ARMATURE")
    modifier.object = arm_obj


def ensure_action(arm_obj, name):
    arm_obj.animation_data_create()
    action = bpy.data.actions.new(name)
    arm_obj.animation_data.action = action
    slot = None
    if hasattr(action, "slots"):
        slot = action.slots.new(arm_obj.id_type, name)
        if hasattr(arm_obj.animation_data, "action_slot"):
            arm_obj.animation_data.action_slot = slot
    return action, slot


def key_pose(arm_obj, frame, rotations, hip_bob):
    full = {name: (0.0, 0.0, 0.0) for name in LIMBS}
    full.update(rotations)
    for bone_name, angles in full.items():
        pose_bone = arm_obj.pose.bones[bone_name]
        pose_bone.rotation_mode = "XYZ"
        pose_bone.rotation_euler = tuple(math.radians(axis) for axis in angles)
        pose_bone.keyframe_insert(data_path="rotation_euler", frame=frame)
    hips = arm_obj.pose.bones["Hips"]
    hips.location = (0.0, hip_bob, 0.0)
    hips.keyframe_insert(data_path="location", frame=frame)


def stash(arm_obj, action, slot, track_name):
    anim = arm_obj.animation_data
    track = anim.nla_tracks.new()
    track.name = track_name
    strip = track.strips.new(track_name, 1, action)
    strip.name = track_name
    if slot is not None and hasattr(strip, "action_slot"):
        strip.action_slot = slot
    anim.action = None


def author_clips(arm_obj):
    bpy.context.view_layer.objects.active = arm_obj
    bpy.ops.object.mode_set(mode="POSE")
    contact = {
        "UpLeg.L": (-32, 0, 0),
        "UpLeg.R": (30, 0, 0),
        "Leg.L": (18, 0, 0),
        "Leg.R": (12, 0, 0),
        "Foot.L": (14, 0, 0),
        "Foot.R": (-10, 0, 0),
        "Arm.L": (28, 0, 4),
        "Arm.R": (-26, 0, -4),
        "ForeArm.L": (24, 0, 0),
        "ForeArm.R": (20, 0, 0),
        "Spine": (0, 6, 0),
        "Chest": (3, 0, 0),
        "Head": (-4, 0, 0),
        "Hips": (0, -4, 0),
    }
    passing = {
        "UpLeg.L": (10, 0, 0),
        "UpLeg.R": (-8, 0, 0),
        "Leg.L": (64, 0, 0),
        "Leg.R": (20, 0, 0),
        "Foot.L": (-12, 0, 0),
        "Foot.R": (8, 0, 0),
        "Arm.L": (-8, 0, 4),
        "Arm.R": (10, 0, -4),
        "ForeArm.L": (30, 0, 0),
        "ForeArm.R": (22, 0, 0),
        "Spine": (0, 0, 0),
        "Hips": (0, 4, 0),
    }
    opposite = {
        "UpLeg.L": (30, 0, 0),
        "UpLeg.R": (-32, 0, 0),
        "Leg.L": (12, 0, 0),
        "Leg.R": (18, 0, 0),
        "Foot.L": (-10, 0, 0),
        "Foot.R": (14, 0, 0),
        "Arm.L": (-26, 0, 4),
        "Arm.R": (28, 0, -4),
        "ForeArm.L": (20, 0, 0),
        "ForeArm.R": (24, 0, 0),
        "Spine": (0, -6, 0),
        "Chest": (3, 0, 0),
        "Head": (-4, 0, 0),
        "Hips": (0, 4, 0),
    }
    passing_back = {
        "UpLeg.L": (-8, 0, 0),
        "UpLeg.R": (10, 0, 0),
        "Leg.L": (20, 0, 0),
        "Leg.R": (64, 0, 0),
        "Foot.L": (8, 0, 0),
        "Foot.R": (-12, 0, 0),
        "Arm.L": (10, 0, 4),
        "Arm.R": (-8, 0, -4),
        "ForeArm.L": (22, 0, 0),
        "ForeArm.R": (30, 0, 0),
        "Spine": (0, 0, 0),
        "Hips": (0, -4, 0),
    }
    walk, walk_slot = ensure_action(arm_obj, "walk")
    key_pose(arm_obj, 1, contact, 0.0)
    key_pose(arm_obj, 7, passing, 0.045)
    key_pose(arm_obj, 13, opposite, 0.0)
    key_pose(arm_obj, 19, passing_back, 0.045)
    key_pose(arm_obj, 25, contact, 0.0)
    preview()
    stash(arm_obj, walk, walk_slot, "walk")

    idle, idle_slot = ensure_action(arm_obj, "idle")
    breath = {
        "Chest": (4, 0, 0),
        "Head": (-3, 0, 0),
        "ForeArm.L": (14, 0, 0),
        "ForeArm.R": (14, 0, 0),
    }
    key_pose(arm_obj, 1, {}, 0.0)
    key_pose(arm_obj, 24, breath, 0.02)
    key_pose(arm_obj, 48, {}, 0.0)
    stash(arm_obj, idle, idle_slot, "idle")
    bpy.ops.pose.select_all(action="SELECT")
    bpy.ops.pose.transforms_clear()
    bpy.ops.object.mode_set(mode="OBJECT")


def preview():
    try:
        scene = bpy.context.scene
        scene.frame_set(7)
        scene.render.engine = "BLENDER_WORKBENCH"
        scene.render.resolution_x = 640
        scene.render.resolution_y = 480
        scene.render.filepath = str(PREVIEW)
        bpy.ops.render.render(write_still=True)
        print(f"preview {PREVIEW}")
    except Exception as exc:
        print(f"preview skipped: {exc}")


def add_preview_camera():
    bpy.ops.object.camera_add(location=(1.55, 2.5, 1.25))
    camera = bpy.context.active_object
    camera.name = "PreviewCamera"
    direction = Vector((0.0, 0.05, 0.95)) - camera.location
    camera.rotation_euler = direction.to_track_quat("-Z", "Y").to_euler()
    bpy.context.scene.camera = camera
    bpy.ops.object.light_add(type="SUN", location=(1.5, -2.0, 4.0))
    bpy.context.active_object.name = "PreviewSun"
    bpy.ops.mesh.primitive_plane_add(size=6, location=(0, 0, 0))
    bpy.context.active_object.name = "PreviewGround"


def remove_preview():
    for obj in list(bpy.data.objects):
        if obj.type in {"CAMERA", "LIGHT"} or obj.name.startswith("Preview"):
            bpy.data.objects.remove(obj, do_unlink=True)


def export_glb():
    operator = bpy.ops.export_scene.gltf
    props = set(operator.get_rna_type().properties.keys())
    kwargs = {
        "filepath": str(OUT),
        "export_format": "GLB",
        "export_yup": True,
        "export_apply": True,
        "export_animations": True,
        "export_animation_mode": "NLA_TRACKS",
        "export_skins": True,
        "export_morph": False,
        "export_lights": False,
        "export_cameras": False,
    }
    filtered = {key: value for key, value in kwargs.items() if key == "filepath" or key in props}
    print("gltf export keys", sorted(filtered.keys()))
    operator(**filtered)


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


def main():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    scene = bpy.context.scene
    scene.render.fps = 24
    scene.frame_start = 1
    scene.frame_end = 48
    arm_obj = build_armature()
    materials = {
        "skin": material("Skin", "#E8C2A0", 0.68),
        "shirt": material("Shirt", "#F3E6C8", 0.74),
        "pants": material("Pants", "#C67A2E", 0.78),
        "hair": material("Hair", "#6E4A2C", 0.8),
        "boots": material("Boots", "#4A3428", 0.82),
        "scarf": material("Scarf", "#8FB7C9", 0.55),
        "eyes": material("Eyes", "#2C261F", 0.35),
        "satchel": material("Satchel", "#6B4228", 0.8),
    }
    body = build_body(materials)
    bind(body, arm_obj)
    add_preview_camera()
    author_clips(arm_obj)
    remove_preview()
    tris = triangle_count()
    OUT.parent.mkdir(parents=True, exist_ok=True)
    if OUT.exists():
        OUT.unlink()
    export_glb()
    data = OUT.read_bytes()
    print(f"triangles {tris}")
    print(f"exported {OUT} ({len(data)} bytes)")
    if b"walk" not in data or b"idle" not in data:
        print("animation names missing from glb", file=sys.stderr)
        sys.exit(1)
    if len(data) < 1000:
        print("glb too small", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
