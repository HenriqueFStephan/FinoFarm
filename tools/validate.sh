#!/usr/bin/env bash
# Headless Godot checks for FinoFarm. Run from anywhere.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${root}"

if ! command -v godot >/dev/null 2>&1; then
  echo "godot is not on PATH. Run: bash .cursor/install.sh" >&2
  exit 127
fi

echo "godot $(godot --version)"

echo "import"
godot --headless --path . --import --quit

echo "check-only"
while IFS= read -r script; do
  godot --headless --path . --check-only -s "res://${script}"
done < <(find scripts tests tools -name '*.gd' | sort)

echo "simulation"
godot --headless --path . -s res://tests/run_simulation_tests.gd

echo "regions"
godot --headless --path . -s res://tests/run_region_tests.gd

echo "save"
godot --headless --path . -s res://tests/run_save_load_tests.gd

echo "placement"
godot --headless --path . -s res://tests/run_placement_tests.gd

echo "economy"
godot --headless --path . -s res://tests/run_economy_tests.gd

echo "staff"
godot --headless --path . -s res://tests/run_staff_tests.gd

echo "priority"
godot --headless --path . -s res://tests/run_priority_tests.gd

echo "scene"
godot --headless --path . -s res://tests/run_scene_checks.gd

echo "validate: ok"
