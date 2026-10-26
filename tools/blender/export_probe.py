"""Throwaway check that Blender can export a glTF. Does not write into the repo."""

import sys
from pathlib import Path

import bpy

out = Path("/tmp/finofarm-blender-probe.glb")
if out.exists():
    out.unlink()

bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.mesh.primitive_cube_add(size=1.0)
bpy.ops.export_scene.gltf(filepath=str(out), export_format="GLB")

if not out.exists() or out.stat().st_size < 100:
    print("probe failed", file=sys.stderr)
    sys.exit(1)

print(f"exported {out} ({out.stat().st_size} bytes)")
