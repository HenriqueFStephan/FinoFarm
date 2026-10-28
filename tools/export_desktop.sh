#!/usr/bin/env bash
# Export a Linux desktop build of FinoFarm. Downloads the official 4.7.2 templates when they are missing.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${root}"

if ! command -v godot >/dev/null 2>&1; then
  echo "godot is not on PATH. Run: bash .cursor/install.sh" >&2
  exit 127
fi

version_line="$(godot --version)"
echo "godot ${version_line}"

template_dir="${XDG_DATA_HOME:-${HOME}/.local/share}/godot/export_templates/4.7.2.stable"
template_url="https://github.com/godotengine/godot/releases/download/4.7.2-stable/Godot_v4.7.2-stable_export_templates.tpz"
template_sha="f298490b8d44d934be425a5a65a51bf15f422428b229a06a6e11d9ffea248011"
marker="${template_dir}/linux_release.x86_64"

if [[ ! -f "${marker}" ]]; then
  work="$(mktemp -d)"
  trap 'rm -rf "${work}"' EXIT
  echo "download export templates"
  curl -fsSL -o "${work}/templates.tpz" "${template_url}"
  echo "${template_sha}  ${work}/templates.tpz" | sha256sum -c -
  mkdir -p "${template_dir}"
  unzip -q -o "${work}/templates.tpz" -d "${work}/unpacked"
  cp -a "${work}/unpacked/templates/." "${template_dir}/"
  rm -rf "${work}"
  trap - EXIT
fi

if [[ ! -f "${marker}" ]]; then
  echo "linux export template is missing from ${template_dir}" >&2
  exit 1
fi

out="${root}/builds/linux"
mkdir -p "${out}"
rm -f "${out}/FinoFarm.x86_64" "${out}/FinoFarm.x86_64.console"

echo "export Linux"
godot --headless --path . --export-release "Linux" "${out}/FinoFarm.x86_64"
test -x "${out}/FinoFarm.x86_64"
echo "exported ${out}/FinoFarm.x86_64"
