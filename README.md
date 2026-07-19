# BGFlipper OS

[![build](https://github.com/BoiesGrimardInformatique/BGFlipper/actions/workflows/build.yml/badge.svg)](https://github.com/BoiesGrimardInformatique/BGFlipper/actions/workflows/build.yml)

> Mon firmware personnalisé (« OS ») pour le **Flipper Zero**, construit comme
> une couche d'overlay au-dessus du firmware officiel open-source.

BGFlipper OS n'est pas un fork brut de plusieurs centaines de Mo : ce dépôt ne
contient **que les personnalisations**. Un jeu de scripts récupère le firmware
officiel épinglé, applique notre couche par-dessus, puis compile et flashe.
C'est l'approche utilisée (dans l'esprit) par les firmwares communautaires
(Unleashed, RogueMaster, Momentum), en plus léger et plus maintenable.

- 🎯 **Base** : `flipperzero-firmware` **1.4.3** (STM32WB55, FreeRTOS + Furi)
- 🧩 **Personnalisations** : origine `BGFlipper`, bannière CLI rebrandée, une app maison
- ♻️ **Maintenable** : montée de version = changer un pin + re-tester les overlays
- 📜 **Licence** : GPLv3 (comme l'upstream)

## Démarrage rapide

```bash
make setup                    # clone le firmware officiel épinglé (1x, volumineux)
make build                    # applique l'overlay + compile (toolchain auto)
make flash                    # flashe firmware + ressources sur le Flipper (USB)
# ou, pour juste tester notre app sans reflasher :
make run APP=bgflipper_splash
```

Prérequis : `git`, `python3`, `bash`, `make`, ~2 Go de disque, et un
Flipper Zero pour flasher (la compilation seule ne nécessite pas le matériel).
Détails et dépannage → **[docs/BUILD.md](docs/BUILD.md)**.

> ⚠️ Le premier `make build` télécharge la toolchain ARM via `fbt` (plusieurs
> centaines de Mo). N'installez rien d'ARM à la main.

## Ce que BGFlipper OS change

| Personnalisation | Fichier | Type | Visible où |
|---|---|---|---|
| Origine du firmware = `BGFlipper` | `overlay/fbt_options_local.py` | hook (non intrusif) | About, CLI `info`, app splash |
| Bannière CLI « BGFlipper OS » | `overlay/applications/services/cli/cli_main_shell.c` | remplacement | shell série au démarrage |
| App carte d'identité | `applications/bgflipper_splash/` | FAP | menu Apps → BGFlipper |

## Structure du dépôt

```
BGFlipper/
├── README.md                 ← vous êtes ici
├── LICENSE                   ← GPLv3 (imposée par l'upstream)
├── VERSION                   ← version de BGFlipper OS
├── firmware.pin              ← tag + commit du firmware officiel de base
├── Makefile                  ← raccourcis : setup / build / flash / run
├── .github/workflows/        ← CI : lint + build firmware/FAP à chaque push
├── scripts/                  ← setup, apply-overlay, build, flash, update-hashes
├── overlay/                  ← fichiers qui recouvrent le firmware officiel
│   ├── fbt_options_local.py         (branding non intrusif)
│   ├── applications/services/cli/…  (bannière CLI)
│   └── UPSTREAM_HASHES.txt          (détection de divergence md5)
├── applications/             ← nos apps FAP
│   └── bgflipper_splash/
├── docs/                     ← ARCHITECTURE, BUILD, CUSTOMIZATION, ROADMAP
└── upstream/                 ← firmware officiel cloné (ignoré par git)
```

## Comment ça marche (en bref)

`scripts/apply-overlay.sh` recopie `overlay/` par-dessus `upstream/` (mêmes
chemins) et nos apps dans `upstream/applications_user/`, après avoir vérifié via
md5 qu'aucun fichier upstream recouvert n'a dérivé. On privilégie les **hooks
non intrusifs** (comme `fbt_options_local.py`) aux **remplacements de fichiers**,
plus fragiles. Détails → **[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)**.

## Documentation

| Doc | Contenu |
|---|---|
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Matériel, pile Furi/FreeRTOS, où s'insère BGFlipper |
| [docs/BUILD.md](docs/BUILD.md) | Construire, flasher, changer de version, dépannage |
| [docs/CUSTOMIZATION.md](docs/CUSTOMIZATION.md) | Ajouter apps, branding, points d'extension |
| [docs/ROADMAP.md](docs/ROADMAP.md) | Étapes suivantes (visuel, apps, CI) |

## Statut

**Phase 0 — Fondations** : structure, branding, première app et docs en place.
La CI (GitHub Actions) construit désormais firmware + FAP à chaque push. La
validation sur **matériel réel** (flash) reste la prochaine étape — voir la
feuille de route. Contributions et idées bienvenues.

## Licence & mentions légales

BGFlipper OS est distribué sous **GPLv3** (voir [LICENSE](LICENSE)), comme le
firmware officiel dont il dérive. Le cœur radio BLE reste un binaire ST
redistribué tel quel. Les fonctions radio (Sub-GHz, NFC, RFID, IR) sont soumises
à la réglementation de votre pays : utilisez BGFlipper OS de façon responsable et
légale.

Flipper Zero est une marque de Flipper Devices Inc. Ce projet est un firmware
communautaire **non officiel**, sans affiliation.
