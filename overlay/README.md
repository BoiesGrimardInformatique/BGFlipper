# overlay/ — couche de personnalisation BGFlipper OS

Ce dossier contient les fichiers qui **remplacent ou complètent** ceux du
firmware officiel. `scripts/apply-overlay.sh` recopie l'arborescence d'`overlay/`
par-dessus celle d'`upstream/`, en respectant exactement les mêmes chemins.

> **Règle d'or :** un fichier placé ici à `overlay/<chemin>` écrase
> `upstream/<chemin>`. L'arborescence doit donc être un miroir de celle du
> firmware.

## Contenu actuel

| Fichier d'overlay | Cible dans upstream | Effet |
|---|---|---|
| `fbt_options_local.py` | `upstream/fbt_options_local.py` | Définit `FIRMWARE_ORIGIN = "BGFlipper"` (hook officiel, ne modifie aucun fichier upstream) |
| `applications/services/cli/cli_main_shell.c` | idem | Bannière CLI rebrandée « BGFlipper OS » |

## Détection de divergence (drift)

Les fichiers d'overlay qui **remplacent** un fichier upstream (comme
`cli_main_shell.c`) sont fragiles : si l'upstream modifie le fichier dans une
future version, notre copie devient obsolète. Les empreintes attendues sont
listées dans `overlay/UPSTREAM_HASHES.txt` et `apply-overlay.sh` compare
automatiquement — il **s'arrête avec un avertissement** si un fichier upstream
a changé, pour que vous puissiez reporter vos modifications sur la nouvelle
version.

> Privilégiez toujours les hooks non intrusifs (comme `fbt_options_local.py`)
> plutôt que le remplacement de fichiers, quand c'est possible.
