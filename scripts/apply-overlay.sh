#!/usr/bin/env bash
#
# apply-overlay.sh — applique la couche de personnalisation BGFlipper sur le
# firmware cloné dans ./upstream :
#   1) vérifie que les fichiers upstream visés n'ont pas dérivé (md5) ;
#   2) copie overlay/  -> upstream/            (fichiers de remplacement) ;
#   3) copie applications/ -> upstream/applications_user/ (nos apps FAP).
#
# Portable : n'utilise que find / cp / mkdir / md5sum (pas de rsync).
#
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

UPSTREAM_DIR="$ROOT/upstream"

if [[ ! -d "$UPSTREAM_DIR/.git" ]]; then
    echo "!!  upstream/ introuvable. Lancez d'abord : scripts/setup.sh"
    exit 1
fi

# copy_tree <srcroot> <destroot> [find-filtres...] : copie récursivement les
# fichiers de srcroot vers destroot en préservant l'arborescence relative.
copy_tree() {
    local srcroot="$1" destroot="$2"
    shift 2
    find "$srcroot" -type f "$@" -print0 | while IFS= read -r -d '' src; do
        local rel="${src#"$srcroot"/}"
        local dest="$destroot/$rel"
        mkdir -p "$(dirname "$dest")"
        cp "$src" "$dest"
    done
}

# --- 1) Détection de divergence sur les fichiers remplacés -------------------
HASHES="$ROOT/overlay/UPSTREAM_HASHES.txt"
if [[ -f "$HASHES" ]]; then
    # Idempotence : on restaure d'abord les fichiers upstream *suivis* à leur
    # version d'origine (git). Sans ça, un 2e passage relirait notre propre
    # overlay déjà copié et le prendrait à tort pour une divergence upstream.
    # Après restauration, le md5 reflète la vraie version du firmware cloné :
    # une VRAIE dérive (montée de version) reste donc bien détectée.
    echo "==> Restauration des fichiers upstream suivis (idempotence)..."
    while read -r expected relpath; do
        [[ "$expected" =~ ^#.*$ || -z "$expected" ]] && continue
        git -C "$UPSTREAM_DIR" checkout -- "$relpath" 2>/dev/null \
            || echo "!!  $relpath : restauration git impossible (non suivi ?)."
    done < "$HASHES"

    echo "==> Vérification des empreintes upstream..."
    drift=0
    while read -r expected relpath; do
        [[ "$expected" =~ ^#.*$ || -z "$expected" ]] && continue
        target="$UPSTREAM_DIR/$relpath"
        if [[ ! -f "$target" ]]; then
            echo "!!  $relpath : absent de l'upstream (le fichier a-t-il été déplacé ?)"
            drift=1
            continue
        fi
        actual="$(md5sum "$target" | cut -d' ' -f1)"
        if [[ "$actual" != "$expected" ]]; then
            echo "!!  DIVERGENCE : $relpath a changé côté upstream."
            echo "    attendu=$expected  obtenu=$actual"
            echo "    -> Reportez vos modifications sur la nouvelle version, puis"
            echo "       mettez à jour overlay/UPSTREAM_HASHES.txt (make update-hashes)."
            drift=1
        fi
    done < "$HASHES"

    if [[ "$drift" -ne 0 ]]; then
        if [[ "${APPLY_FORCE:-0}" == "1" ]]; then
            echo "==> APPLY_FORCE=1 : on continue malgré la divergence."
        else
            echo "!!  Arrêt : divergence détectée. (Forcer : APPLY_FORCE=1 scripts/apply-overlay.sh)"
            exit 2
        fi
    fi
fi

# --- 2) Copie des fichiers d'overlay -----------------------------------------
echo "==> Application de overlay/ sur upstream/"
copy_tree "$ROOT/overlay" "$UPSTREAM_DIR" ! -name 'README.md' ! -name 'UPSTREAM_HASHES.txt'

# --- 3) Copie de nos applications --------------------------------------------
echo "==> Copie des apps BGFlipper dans upstream/applications_user/"
mkdir -p "$UPSTREAM_DIR/applications_user"
copy_tree "$ROOT/applications" "$UPSTREAM_DIR/applications_user" ! -name 'README.md'

echo "==> Overlay appliqué."
