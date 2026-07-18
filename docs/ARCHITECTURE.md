# Architecture — comment fonctionne un « OS » Flipper Zero

Comprendre l'existant avant de le personnaliser. Ce document résume le matériel
et la pile logicielle du Flipper Zero, puis explique où BGFlipper OS s'insère.

## 1. Le matériel

| Élément | Détail |
|---|---|
| MCU principal | **STM32WB55RG** — ARM Cortex-M4 @ 64 MHz (applicatif) |
| Cœur radio | Cortex-M0+ dédié, exécute la pile **BLE** (firmware « copro » fourni par ST, binaire fermé) |
| Mémoire | 1 Mo Flash, 256 Ko RAM |
| Écran | Monochrome **128 × 64** px (ST7565) |
| Entrées | 5 directions + OK, bouton Back |
| Radios / capteurs | Sub-GHz (CC1101), NFC (ST25R3916), 125 kHz RFID, Infrarouge, iButton/1-Wire, GPIO |
| Stockage | Carte microSD (ressources, apps `.fap`, dumps) |

Le fait que le cœur radio BLE soit un binaire ST séparé est important : **réécrire
un OS de zéro** signifierait conserver ce blob mais tout reconstruire autour
(HAL, drivers, ordonnanceur). C'est pourquoi BGFlipper part du firmware officiel.

## 2. La pile logicielle officielle

```
┌───────────────────────────────────────────────┐
│  Applications  (Sub-GHz, NFC, RFID, Jeux, ...)  │  <- vos apps aussi (FAP)
├───────────────────────────────────────────────┤
│  Services  (gui, notification, storage, cli,    │
│             desktop, loader, input, dialogs...)  │
├───────────────────────────────────────────────┤
│  Furi   (Flipper Universal Registry Impl.)      │  <- « userspace » maison
│  records, message queues, threads, pubsub, log  │
├───────────────────────────────────────────────┤
│  FreeRTOS   (ordonnanceur préemptif, tâches)    │
├───────────────────────────────────────────────┤
│  Furi HAL   (abstraction matérielle Flipper)    │
├───────────────────────────────────────────────┤
│  STM32 HAL / CMSIS   +   copro BLE (ST)         │
└───────────────────────────────────────────────┘
```

### Furi — le cœur applicatif
« Furi » est la couche que Flipper a bâtie au-dessus de FreeRTOS. Concepts clés :

- **Records** : un registre de services partagés. `furi_record_open(RECORD_GUI)`
  récupère le service GUI ; `furi_record_close(...)` le relâche. C'est le
  mécanisme d'injection de dépendances du système.
- **Message queues** : `FuriMessageQueue` — communication inter-tâches (ex. la
  file d'évènements d'entrée dans notre app splash).
- **Threads / Timers / Mutex / PubSub** : primitives de concurrence.
- **Furi log** : `FURI_LOG_I/W/E(TAG, ...)` — visible via le CLI.

### Services
Ce sont des tâches FreeRTOS de longue durée exposées comme records :
`gui`, `input`, `notification` (LED/vibreur/son), `storage` (SD),
`loader` (lance les apps), `desktop` (écran d'accueil + animations dolphin),
`cli` (shell série), `dialogs`, etc.

### Applications
Deux natures :
- **Intégrées (built-in)** : compilées dans le `.bin` du firmware, listées dans
  `FIRMWARE_APPS` (voir `fbt_options.py`).
- **Externes (FAP — Flipper Application Package)** : compilées séparément en
  `.fap`, chargées depuis la carte SD par le `loader`. **C'est le format
  recommandé** pour vos apps — pas besoin de recompiler tout le firmware.
  → `bgflipper_splash` est un FAP.

## 3. Le build system : `fbt` (et `ufbt`)

`fbt` (Flipper Build Tool, un wrapper SCons) gère tout :
- télécharge la **toolchain ARM** au premier lancement (aucune install manuelle) ;
- compile firmware, apps, ressources ;
- flashe en USB (`flash_usb_full`) ou via sonde ;
- `./fbt launch APPSRC=<app>` compile + envoie + lance **une** app (boucle de dev).

`ufbt` est une variante « micro » pour développer une app isolée sans cloner
tout le firmware — pratique une fois le SDK stable.

Personnalisation propre et supportée : le fichier **`fbt_options_local.py`**
(à la racine du firmware) est exécuté par `fbt_options.py` s'il existe, et peut
redéfinir n'importe quelle variable **sans modifier de fichier upstream**.

## 4. Où s'insère BGFlipper OS

BGFlipper OS **n'est pas un fork brut** (on ne recopie pas les ~centaines de Mo
du firmware dans ce dépôt). C'est une **couche d'overlay** :

```
BGFlipper (ce dépôt, léger)          upstream/ (cloné, ignoré par git)
├── overlay/            ──apply──►    firmware officiel 1.4.3
│   ├── fbt_options_local.py               + FIRMWARE_ORIGIN = BGFlipper
│   └── applications/services/cli/…        + bannière CLI rebrandée
├── applications/       ──apply──►    upstream/applications_user/
│   └── bgflipper_splash/                  (notre FAP)
└── scripts/            pilotent setup / overlay / build / flash
```

Avantages vs fork brut :
- **Maintenable** : monter en version = changer `firmware.pin`, re-tester les
  overlays (le script détecte les divergences via md5).
- **Lisible** : le dépôt ne contient QUE nos changements, faciles à relire.
- **Réversible** : `rm -rf upstream` et on repart du firmware pur.

Voir `docs/CUSTOMIZATION.md` pour les points d'extension, et `docs/ROADMAP.md`
pour la suite (animations, logo de boot, apps).
