#!/usr/bin/env bash
#
# flash.sh — flashe BGFlipper OS sur un Flipper Zero connecté en USB.
#
# Prérequis :
#   - Flipper connecté en USB, qFlipper FERMÉ (il monopolise le port série) ;
#   - build déjà effectué (sinon lancez scripts/build.sh).
#
# `flash_usb_full` envoie le firmware ET synchronise les ressources (dont les
# FAP construits, dont bgflipper_splash) sur la carte SD.
#
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ ! -d "$ROOT/upstream/.git" ]]; then
    echo "!!  upstream/ introuvable. Lancez d'abord : scripts/build.sh"
    exit 1
fi

# On réapplique l'overlay au cas où des fichiers auraient changé depuis le build.
"$ROOT/scripts/apply-overlay.sh"

cd "$ROOT/upstream"
echo "==> Flash USB complet (firmware + ressources)..."
./fbt flash_usb_full

echo "==> Flash terminé. Le Flipper va redémarrer sous BGFlipper OS."
