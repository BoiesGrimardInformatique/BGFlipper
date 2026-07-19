#!/usr/bin/env bash
#
# build.sh — construit BGFlipper OS :
#   - clone le firmware si nécessaire (setup.sh) ;
#   - applique l'overlay (apply-overlay.sh) ;
#   - lance le build via fbt (qui télécharge la toolchain ARM au 1er run).
#
# Le firmware résultant se trouve dans upstream/dist/.
#
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

[[ -d "$ROOT/upstream/.git" ]] || "$ROOT/scripts/setup.sh"
"$ROOT/scripts/apply-overlay.sh"

echo "==> Build du firmware (fbt)..."
cd "$ROOT/upstream"

# `./fbt` bootstrappe la toolchain ARM au premier appel. Cible par défaut =
# firmware complet + apps utilisateur. On construit aussi explicitement notre FAP.
./fbt "$@"

echo
echo "==> Build terminé."

# Le suffixe du dossier dist (f7-C, f7-D, …) dépend de la variante de build
# (release/debug/compact). On l'affiche dynamiquement plutôt que de le coder en
# dur, pour ne jamais annoncer un chemin faux.
dist_dir="$(find "$ROOT/upstream/dist" -maxdepth 1 -type d -name 'f7-*' 2>/dev/null | sort | head -n1 || true)"
if [[ -n "$dist_dir" ]]; then
    echo "    Firmware        : ${dist_dir#"$ROOT"/}/  (flipper-z-f7-*.dfu / .bin)"
else
    echo "    Firmware        : upstream/dist/f7-*/  (flipper-z-f7-*.dfu / .bin)"
fi
echo "    Pour flasher    : scripts/flash.sh"
echo "    Pour tester 1 app : make run APP=bgflipper_splash"
