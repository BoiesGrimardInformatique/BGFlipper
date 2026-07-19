# Feuille de route — BGFlipper OS

Approche : **firmware personnalisé** (overlay sur le firmware officiel), pour
obtenir rapidement un OS flashable et le faire évoluer sans repartir de zéro.

## ✅ Phase 0 — Fondations (état actuel)

- [x] Structure de dépôt « overlay » (léger, ne versionne pas le firmware).
- [x] Épinglage du firmware officiel (`firmware.pin` → 1.4.3).
- [x] Scripts `setup` / `apply-overlay` / `build` / `flash` + `Makefile`.
- [x] Branding non intrusif : `FIRMWARE_ORIGIN = "BGFlipper"`.
- [x] Branding CLI : bannière « BGFlipper OS » (overlay + suivi de divergence md5).
- [x] Première app FAP : `bgflipper_splash` (carte d'identité + LED).
- [x] Documentation : architecture, build, personnalisation.

## 🔜 Phase 1 — Valider la chaîne sur matériel

- [ ] `make setup && make build` sur une vraie machine (télécharge la toolchain).
- [ ] `make flash` sur un Flipper Zero réel.
- [ ] Vérifier : bannière CLI, origine `BGFlipper` dans About, app splash.
- [ ] Corriger les éventuels ajustements d'API si vous montez au-delà de 1.4.3.

## 🎨 Phase 2 — Identité visuelle

- [ ] Logo de démarrage personnalisé (`assets/slideshow/`).
- [ ] Animation « dolphin » d'accueil aux couleurs BGFlipper (`assets/dolphin/`).
- [ ] Icône et catégorie dédiées dans le menu Apps.
- [ ] Écran « About » rebrandé (overlay `applications/settings/about/about.c`).

## 🧰 Phase 3 — Contenu et apps

- [ ] Sélection d'apps intégrées par défaut (`FIRMWARE_APPS` via le hook).
- [ ] 1–2 apps utilitaires maison (au-delà du splash).
- [ ] Éventuels assets Sub-GHz / IR pré-embarqués (dans le respect des lois locales).

## 🔁 Phase 4 — Industrialisation

- [x] CI (GitHub Actions) : build du firmware + des FAP à chaque push, avec
      lint (shellcheck) et archivage des artefacts — `.github/workflows/build.yml`.
- [ ] Publication de « releases » (`.dfu` / `.tgz`) prêtes à flasher via qFlipper.
- [x] Procédure documentée de montée de version upstream (report des overlays,
      `make update-hashes` auto-découvre les fichiers de remplacement).
- [ ] Versionnage sémantique de BGFlipper OS (`VERSION`).

## ⚖️ Notes légales & sécurité

- Le firmware officiel est **GPLv3** : BGFlipper OS l'est aussi (voir `LICENSE`).
  Toute redistribution doit fournir les sources correspondantes.
- La pile radio BLE (« copro ») reste un binaire ST redistribué tel quel.
- Les fonctions radio (Sub-GHz, NFC, RFID) sont soumises à la **réglementation
  locale** (fréquences, usages). N'embarquez pas de contenu illégal dans votre
  région.

## Idées « plus loin »

- Support d'autres cibles matérielles si elles apparaissent (`targets/`).
- Intégration `ufbt` pour un SDK d'apps distribuable indépendamment.
- Catalogue d'apps BGFlipper installables depuis la SD.
