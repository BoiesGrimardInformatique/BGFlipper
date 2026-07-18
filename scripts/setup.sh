#!/usr/bin/env bash
#
# setup.sh — clone le firmware Flipper Zero officiel au tag épinglé dans
# ./upstream, avec ses sous-modules. À exécuter une seule fois (ou après
# un changement de version dans firmware.pin).
#
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

# shellcheck disable=SC1091
source ./firmware.pin

UPSTREAM_DIR="$ROOT/upstream"

if [[ -d "$UPSTREAM_DIR/.git" ]]; then
    echo "==> upstream/ existe déjà."
    current="$(git -C "$UPSTREAM_DIR" describe --tags --exact-match 2>/dev/null || echo '?')"
    echo "    Version actuelle : $current (attendue : $FIRMWARE_TAG)"
    echo "    Pour repartir de zéro : rm -rf upstream && scripts/setup.sh"
    exit 0
fi

echo "==> Clonage de $FIRMWARE_REPO @ $FIRMWARE_TAG"
echo "    (téléchargement volumineux : firmware + sous-modules, plusieurs centaines de Mo)"

git clone --branch "$FIRMWARE_TAG" --depth 1 --recurse-submodules --shallow-submodules \
    "$FIRMWARE_REPO" "$UPSTREAM_DIR"

# Vérification du commit épinglé (sécurité anti-dérive de tag).
got="$(git -C "$UPSTREAM_DIR" rev-parse HEAD)"
if [[ "$got" != "$FIRMWARE_COMMIT" ]]; then
    echo "!!  ATTENTION : le commit obtenu ($got) diffère du commit épinglé"
    echo "!!  ($FIRMWARE_COMMIT). Le tag $FIRMWARE_TAG a peut-être été déplacé."
    echo "!!  Vérifiez avant de continuer."
fi

echo "==> Terminé. Lancez maintenant : scripts/build.sh"
