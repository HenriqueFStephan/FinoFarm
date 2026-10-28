"""Build the packing clerk and export assets/models/packing_clerk.glb.

A second character, not a recolor of the farmhand. Shorter and wider, with a
cap, an apron, and a crate held in front. First stylized pass, not final art.
The walk, idle, and work clips are in-place. The game script moves the body.
"""

import sys
from pathlib import Path

import bpy

sys.path.insert(0, str(Path(__file__).resolve().parent))
import farmhand


OUT = Path("/workspace/assets/models/packing_clerk.glb")


def build_armature():
    arm_data = bpy.data.armatures.new("Armature")
    arm_obj = bpy.data.objects.new("Armature", arm_data)
    bpy.context.collection.objects.link(arm_obj)
    bpy.context.view_layer.objects.active = arm_obj
    bpy.ops.object.mode_set(mode="EDIT")
    add = farmhand.add_bone
    add(arm_data, "Root", (0, 0, 0.02), (0, 0, 0.12), None)
    add(arm_data, "Hips", (0, 0, 0.56), (0, 0, 0.68), "Root")
    add(arm_data, "Spine", (0, 0, 0.68), (0, 0, 0.84), "Hips")
    add(arm_data, "Chest", (0, 0, 0.84), (0, 0, 1.00), "Spine")
    add(arm_data, "Neck", (0, 0, 1.00), (0, 0, 1.08), "Chest")
    add(arm_data, "Head", (0, 0, 1.08), (0, 0, 1.36), "Neck")
    add(arm_data, "Arm.L", (-0.22, 0.08, 0.96), (-0.34, 0.22, 0.78), "Chest")
    add(arm_data, "ForeArm.L", (-0.34, 0.22, 0.78), (-0.18, 0.32, 0.70), "Arm.L")
    add(arm_data, "Arm.R", (0.22, 0.08, 0.96), (0.34, 0.22, 0.78), "Chest")
    add(arm_data, "ForeArm.R", (0.34, 0.22, 0.78), (0.18, 0.32, 0.70), "Arm.R")
    add(arm_data, "UpLeg.L", (-0.14, 0.0, 0.54), (-0.15, 0.02, 0.28), "Hips")
    add(arm_data, "Leg.L", (-0.15, 0.02, 0.28), (-0.14, 0.0, 0.06), "UpLeg.L")
    add(arm_data, "Foot.L", (-0.14, 0.0, 0.06), (-0.14, 0.16, 0.03), "Leg.L")
    add(arm_data, "UpLeg.R", (0.14, 0.0, 0.54), (0.15, 0.02, 0.28), "Hips")
    add(arm_data, "Leg.R", (0.15, 0.02, 0.28), (0.14, 0.0, 0.06), "UpLeg.R")
    add(arm_data, "Foot.R", (0.14, 0.0, 0.06), (0.14, 0.16, 0.03), "Leg.R")
    bpy.ops.object.mode_set(mode="OBJECT")
    return arm_obj


def build_body(materials):
    parts = []
    skin = materials["skin"]
    vest = materials["vest"]
    apron = materials["apron"]
    pants = materials["pants"]
    cap = materials["cap"]
    boots = materials["boots"]
    eyes = materials["eyes"]
    crate = materials["crate"]
    parts.append(farmhand.add_sphere("Head", (0, 0.04, 1.20), (0.26, 0.25, 0.24), skin, "Head"))
    parts.append(farmhand.add_sphere("Cap", (0, 0.02, 1.36), (0.28, 0.26, 0.12), cap, "Head"))
    parts.append(farmhand.add_cube("Brim", (0, 0.16, 1.30), (0.46, 0.28, 0.04), cap, "Head", 0.01))
    parts.append(farmhand.add_sphere("Nose", (0, 0.26, 1.16), (0.04, 0.05, 0.035), skin, "Head"))
    parts.append(farmhand.add_sphere("Eye.L", (-0.09, 0.22, 1.24), (0.04, 0.035, 0.045), eyes, "Head"))
    parts.append(farmhand.add_sphere("Eye.R", (0.09, 0.22, 1.24), (0.04, 0.035, 0.045), eyes, "Head"))
    parts.append(farmhand.add_cube("Vest", (0, 0.02, 0.90), (0.62, 0.38, 0.36), vest, "Chest", 0.05))
    parts.append(farmhand.add_cube("Apron", (0, 0.20, 0.78), (0.40, 0.06, 0.42), apron, "Spine", 0.02))
    parts.append(farmhand.add_cube("Trousers", (0, 0.0, 0.60), (0.50, 0.34, 0.22), pants, "Hips", 0.04))
    parts.append(farmhand.add_cube("Crate", (0, 0.34, 0.78), (0.28, 0.22, 0.22), crate, "Chest", 0.02))
    parts.append(farmhand.add_limb("UpperArm.L", (-0.22, 0.08, 0.96), (-0.34, 0.22, 0.78), 0.08, vest, "Arm.L"))
    parts.append(farmhand.add_limb("LowerArm.L", (-0.34, 0.22, 0.78), (-0.18, 0.32, 0.70), 0.065, skin, "ForeArm.L"))
    parts.append(farmhand.add_sphere("Hand.L", (-0.16, 0.34, 0.68), (0.05, 0.045, 0.05), skin, "ForeArm.L"))
    parts.append(farmhand.add_limb("UpperArm.R", (0.22, 0.08, 0.96), (0.34, 0.22, 0.78), 0.08, vest, "Arm.R"))
    parts.append(farmhand.add_limb("LowerArm.R", (0.34, 0.22, 0.78), (0.18, 0.32, 0.70), 0.065, skin, "ForeArm.R"))
    parts.append(farmhand.add_sphere("Hand.R", (0.16, 0.34, 0.68), (0.05, 0.045, 0.05), skin, "ForeArm.R"))
    parts.append(farmhand.add_limb("Thigh.L", (-0.14, 0.0, 0.54), (-0.15, 0.02, 0.28), 0.11, pants, "UpLeg.L"))
    parts.append(farmhand.add_limb("Shin.L", (-0.15, 0.02, 0.28), (-0.14, 0.0, 0.06), 0.085, pants, "Leg.L"))
    parts.append(farmhand.add_sphere("Boot.L", (-0.14, 0.07, 0.05), (0.09, 0.13, 0.06), boots, "Foot.L"))
    parts.append(farmhand.add_limb("Thigh.R", (0.14, 0.0, 0.54), (0.15, 0.02, 0.28), 0.11, pants, "UpLeg.R"))
    parts.append(farmhand.add_limb("Shin.R", (0.15, 0.02, 0.28), (0.14, 0.0, 0.06), 0.085, pants, "Leg.R"))
    parts.append(farmhand.add_sphere("Boot.R", (0.14, 0.07, 0.05), (0.09, 0.13, 0.06), boots, "Foot.R"))
    bpy.ops.object.select_all(action="DESELECT")
    for part in parts:
        part.select_set(True)
    bpy.context.view_layer.objects.active = parts[0]
    bpy.ops.object.join()
    body = bpy.context.active_object
    body.name = "PackingClerkBody"
    return body


def main():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    scene = bpy.context.scene
    scene.render.fps = 24
    scene.frame_start = 1
    scene.frame_end = 48
    arm_obj = build_armature()
    materials = {
        "skin": farmhand.material("Skin", "#E8C2A0", 0.68),
        "vest": farmhand.material("Vest", "#8FB7C9", 0.62),
        "apron": farmhand.material("Apron", "#F3E6C8", 0.74),
        "pants": farmhand.material("Pants", "#735737", 0.8),
        "cap": farmhand.material("Cap", "#6B4228", 0.78),
        "boots": farmhand.material("Boots", "#4A3428", 0.82),
        "eyes": farmhand.material("Eyes", "#2C261F", 0.35),
        "crate": farmhand.material("Crate", "#855E33", 0.84),
    }
    body = build_body(materials)
    farmhand.bind(body, arm_obj)
    farmhand.author_clips(arm_obj)
    farmhand.remove_preview()
    tris = farmhand.triangle_count()
    farmhand.OUT = OUT
    OUT.parent.mkdir(parents=True, exist_ok=True)
    if OUT.exists():
        OUT.unlink()
    farmhand.export_glb()
    data = OUT.read_bytes()
    print(f"triangles {tris}")
    print(f"exported {OUT} ({len(data)} bytes)")
    if b"walk" not in data or b"idle" not in data or b"work" not in data:
        print("animation names missing from glb", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
