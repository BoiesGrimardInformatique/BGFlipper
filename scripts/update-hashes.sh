#!/usr/bin/env bash
#
# update-hashes.sh — régénère overlay/UPSTREAM_HASHES.txt.
#
# Auto-découverte : parcourt overlay/ et, pour chaque fichier qui EXISTE aussi
# dans le firmware upstream (= un overlay de "remplacement"), enregistre le md5
# de la version PRISTINE de l'upstream (lue via git, jamais notre copie déjà
# appliquée). Les fichiers d'overlay qui n'existent pas dans l'upstream (hooks
# comme fbt_options_local.py, README, ce fichier de hachages) sont ignorés :
# ils ne recouvrent rien, donc rien à suivre.
#
# Résultat : ajouter/retirer un overlay de remplacement ne demande plus de
# toucher au Makefile — il suffit de relancer `make update-hashes`.
#
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

UPSTREAM_DIR="$ROOT/upstream"
OVERLAY_DIR="$ROOT/overlay"
HASHES="$OVERLAY_DIR/UPSTREAM_HASHES.txt"

if [[ ! -d "$UPSTREAM_DIR/.git" ]]; then
    echo "!!  upstream/ introuvable. Lancez d'abord : scripts/setup.sh"
    exit 1
fi

tmp="$(mktemp)"
{
    echo "# Empreintes md5 des fichiers upstream (firmware $(git -C "$UPSTREAM_DIR" describe --tags --always 2>/dev/null || echo '?')) que"
    echo "# nos overlays de type \"remplacement\" recouvrent. Utilisé par"
    echo "# scripts/apply-overlay.sh pour détecter une divergence lors d'un"
    echo "# changement de version. Régénéré par 'make update-hashes'."
    echo "#"
    echo "# Format : <md5>  <chemin relatif à upstream/>"
} > "$tmp"

count=0
while IFS= read -r -d '' src; do
    rel="${src#"$OVERLAY_DIR"/}"

    # On ne suit que les fichiers qui existent réellement dans l'upstream
    # (donc de vrais remplacements). git cat-file échoue proprement sinon.
    if git -C "$UPSTREAM_DIR" cat-file -e "HEAD:$rel" 2>/dev/null; then
        md5="$(git -C "$UPSTREAM_DIR" show "HEAD:$rel" | md5sum | cut -d' ' -f1)"
        printf '%s  %s\n' "$md5" "$rel" >> "$tmp"
        echo "    suivi : $rel ($md5)"
        count=$((count + 1))
    fi
done < <(find "$OVERLAY_DIR" -type f \
    ! -name 'README.md' ! -name 'UPSTREAM_HASHES.txt' -print0)

mv "$tmp" "$HASHES"
echo "==> $HASHES régénéré ($count fichier(s) de remplacement suivi(s))."
