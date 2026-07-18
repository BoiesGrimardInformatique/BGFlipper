# Construire et flasher BGFlipper OS

## Prérequis

| Besoin | Détail |
|---|---|
| OS | Linux, macOS, ou Windows (WSL2 recommandé) |
| Outils | `git`, `python3`, `bash`, `make` (les scripts n'utilisent que `find`/`cp`) |
| Espace disque | ~2 Go (clone du firmware + toolchain ARM téléchargée par `fbt`) |
| Réseau | Nécessaire au 1er build (clone + toolchain) |
| Matériel | Un Flipper Zero (pour flasher). On peut **compiler sans**. |

> `fbt` télécharge lui-même la toolchain ARM au premier lancement.
> **Ne lancez pas** `arm-none-eabi` / `pip install` à la main.

## Démarrage rapide

```bash
# 1. Récupérer le firmware officiel épinglé (une seule fois)
make setup            # ≈ scripts/setup.sh — clone upstream/ @ 1.4.3

# 2. Construire le firmware complet BGFlipper OS
make build            # applique l'overlay puis lance fbt

# 3a. Flasher le firmware complet sur le Flipper (USB, qFlipper fermé)
make flash

# 3b. …ou juste tester notre app sur le Flipper, sans reflasher le firmware
make run APP=bgflipper_splash
```

## Détail des étapes

### `make setup`
Clone `flipperzero-firmware` au tag **1.4.3** (commit épinglé dans
`firmware.pin`) dans `./upstream/`, avec les sous-modules. `upstream/` est
ignoré par git : il est reconstruit à la demande, jamais versionné.

### `make build`
1. (si besoin) exécute `setup` ;
2. exécute `apply-overlay.sh` :
   - vérifie que les fichiers upstream recouverts n'ont pas dérivé (md5) ;
   - copie `overlay/` sur `upstream/` ;
   - copie `applications/` dans `upstream/applications_user/` ;
3. lance `./fbt` dans `upstream/` (toolchain téléchargée au 1er run).

Sortie : `upstream/dist/f7-C/` contient les artefacts
(`flipper-z-f7-full-*.dfu`, `*.tgz`, updater, etc.).

### `make flash`
Exécute `./fbt flash_usb_full` : envoie le firmware **et** synchronise les
ressources (dont les FAP construits) sur la carte SD. Le Flipper redémarre
sous BGFlipper OS.

> **Important :** fermez **qFlipper** avant de flasher — il monopolise le port
> série. Le bootloader DFU s'active tout seul via `flash_usb_full`.

### `make run APP=<nom>`
`./fbt launch APPSRC=applications_user/<nom>` : compile le FAP, l'envoie et le
lance immédiatement sur le Flipper connecté. **La boucle de dev la plus rapide**
— pas de reflash complet.

## Vérifier le branding

Après flash :
- **CLI** : branchez-vous au shell série (`./fbt cli`, ou un terminal série à
  230400 bauds) → la bannière « BGFlipper OS » s'affiche.
- **Réglages → About** et **CLI `info`** → l'origine du firmware indique
  `BGFlipper` (au lieu de `Official`).
- **Apps → BGFlipper → BGFlipper OS** → notre écran splash.

## Changer de version de firmware upstream

1. Éditez `firmware.pin` (`FIRMWARE_TAG` + `FIRMWARE_COMMIT`).
2. `rm -rf upstream && make setup`.
3. `make build` — si un fichier recouvert a changé, `apply-overlay.sh`
   **s'arrête** et vous indique lequel reporter. Après report :
   `make update-hashes` pour réenregistrer les empreintes.

## Dépannage

| Symptôme | Piste |
|---|---|
| `upstream/ introuvable` | Lancez `make setup`. |
| Flash qui ne trouve pas le Flipper | Fermez qFlipper ; vérifiez le câble/port USB (données, pas juste charge). |
| `DIVERGENCE : … a changé côté upstream` | Un overlay de remplacement est obsolète pour cette version — voir ci-dessus. |
| 1er build très long | Normal : téléchargement de la toolchain ARM (plusieurs centaines de Mo). |
