# BGFlipper OS - surcharges locales de configuration du build (fbt).
#
# Ce fichier est copié à la racine de `upstream/` par scripts/apply-overlay.sh.
# Le firmware officiel prévoit ce hook : à la fin de fbt_options.py, si
# `fbt_options_local.py` existe, il est exécuté et peut redéfinir n'importe
# quelle variable de configuration SANS modifier les fichiers upstream.
#
# Voir docs/CUSTOMIZATION.md pour la liste des réglages disponibles.

# Origine du firmware : s'affiche dans l'app "About", dans le CLI (`info`),
# via `version_get_firmware_origin()` et dans notre app bgflipper_splash.
# Toute valeur != "Official" marque le firmware comme non officiel.
FIRMWARE_ORIGIN = "BGFlipper"

# Décommentez pour activer les optimisations "taille" par défaut (firmware
# plus compact, utile si vous ajoutez beaucoup d'apps intégrées) :
# FIRMWARE_APP_SET = "default"
