#!/usr/bin/env bash
# Idempotent, non-interactive cloud-agent bootstrap.
# Tools land on /usr/local/bin so login shells find them without rc files.
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

GODOT_VERSION="4.7.2-stable"
GODOT_URL="https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}/Godot_v${GODOT_VERSION}_linux.x86_64.zip"
GODOT_SHA512="9aa00f7a605200940bce3027a567b782f49bd8e940dd06ae9e987bd65aee1b1467edd56ed84fcdcbdd44354bf613bdbb4e5d2913e925850368e150c59ed54c65"
GODOT_BIN_NAME="Godot_v${GODOT_VERSION}_linux.x86_64"

# Official Linux x86_64 build current on 26 October 2026 (Blender 5.2.3 LTS).
BLENDER_VERSION="5.2.3"
BLENDER_URL="https://download.blender.org/release/Blender5.2/blender-${BLENDER_VERSION}-linux-x64.tar.xz"
BLENDER_SHA256="78486c018b4443efe5e75ab54c290ed8c15abafd249b862c2c9ce2530a918eec"
BLENDER_ROOT="/opt/blender-${BLENDER_VERSION}-linux-x64"

workdir=""
cleanup() {
  if [[ -n "${workdir}" && -d "${workdir}" ]]; then
    rm -rf "${workdir}"
  fi
}
trap cleanup EXIT

ensure_packages() {
  local pkg
  local missing=()
  for pkg in ca-certificates curl unzip xz-utils git-lfs; do
    if ! dpkg-query -W -f='${Status}' "${pkg}" 2>/dev/null | grep -q 'install ok installed'; then
      missing+=("${pkg}")
    fi
  done
  if ((${#missing[@]} > 0)); then
    sudo apt-get update
    sudo apt-get install -y --no-install-recommends "${missing[@]}"
  fi
}

godot_current() {
  [[ -x /usr/local/bin/godot ]] || return 1
  local ver
  ver="$(/usr/local/bin/godot --version 2>/dev/null || true)"
  [[ "${ver}" == 4.7.2.stable* ]]
}

blender_current() {
  [[ -x /usr/local/bin/blender && -x "${BLENDER_ROOT}/blender-launcher" ]] || return 1
  local line
  line="$(/usr/local/bin/blender --version 2>/dev/null | sed -n '1p' || true)"
  [[ "${line}" == "Blender ${BLENDER_VERSION}"* ]]
}

install_godot() {
  if godot_current; then
    echo "Godot ${GODOT_VERSION} already installed"
    return 0
  fi

  workdir="$(mktemp -d)"
  local archive="${workdir}/godot.zip"
  curl -fL --retry 5 --retry-delay 2 --retry-all-errors \
    -o "${archive}" "${GODOT_URL}"
  printf '%s  %s\n' "${GODOT_SHA512}" "${archive}" | sha512sum -c -
  unzip -q "${archive}" -d "${workdir}"
  [[ -f "${workdir}/${GODOT_BIN_NAME}" ]]
  sudo install -m 0755 "${workdir}/${GODOT_BIN_NAME}" /usr/local/bin/godot
  rm -rf "${workdir}"
  workdir=""

  godot_current
  echo "Installed $(/usr/local/bin/godot --version)"
}

install_blender() {
  if blender_current; then
    echo "Blender ${BLENDER_VERSION} already installed"
    return 0
  fi

  workdir="$(mktemp -d)"
  local archive="${workdir}/blender.tar.xz"
  curl -fL --retry 5 --retry-delay 2 --retry-all-errors \
    -o "${archive}" "${BLENDER_URL}"
  printf '%s  %s\n' "${BLENDER_SHA256}" "${archive}" | sha256sum -c -
  sudo mkdir -p /opt
  sudo tar -xJf "${archive}" -C /opt
  sudo ln -sfn "${BLENDER_ROOT}/blender-launcher" /usr/local/bin/blender
  rm -rf "${workdir}"
  workdir=""

  blender_current
  echo "Installed $(/usr/local/bin/blender --version | sed -n '1p')"
}

enable_git_lfs() {
  git lfs install
  git lfs version
}

ensure_packages
install_godot
install_blender
enable_git_lfs
