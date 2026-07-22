# Crédits & attributions

BGFlipper OS dérive du firmware officiel **flipperzero-firmware** (Flipper Devices Inc.,
GPLv3) et intègre des **données** (dictionnaires, presets, listes) provenant de firmwares
communautaires, eux aussi sous **GPLv3**. Conformément à la GPLv3, ces sources sont créditées
ci-dessous avec leur version épinglée.

## Données importées

| Donnée | Fichier BGFlipper | Source | Version épinglée |
|---|---|---|---|
| Presets de modulation Sub-GHz (FM95, FM15k, Pagers) | `overlay/…/subghz/assets/setting_user` | [DarkFlippers/unleashed-firmware](https://github.com/DarkFlippers/unleashed-firmware) | `unlshd-089` |
| Clés MF Classic supplémentaires (+2195) | `overlay/…/nfc/assets/mf_classic_dict_user.nfc` | DarkFlippers/unleashed-firmware | `unlshd-089` |
| Clés MF Ultralight-C supplémentaires | `overlay/…/nfc/assets/mf_ultralight_c_dict_user.nfc` | DarkFlippers/unleashed-firmware | `unlshd-089` |

Les clés déjà présentes dans les dictionnaires système officiels ont été exclues (delta
uniquement). Aucune clé n'a été inventée : tout provient des dépôts ci-dessus, tels quels.

## Apps pré-installées (Palier 4)

Les applications embarquées par défaut (dossier `applications/`) proviennent de la
collection communautaire **[xMasterX/all-the-plugins](https://github.com/xMasterX/all-the-plugins)**
(`base_pack/`), **GPLv3**, commit épinglé `1066d17ad1e8fbf75cea5c6612d79ba539ec8a33`.
Chaque app conserve son manifeste `application.fam` (auteurs crédités dans `fap_author`).
Toutes compilent proprement contre l'API 1.4.3.

BGFlipper OS est un **outil professionnel** : **aucun jeu** n'est embarqué, uniquement
des outils. Suite retenue (20) :
- **Électronique/hardware** : uart_terminal, flipper_i2ctools, hc_sr04, unitemp,
  signal_generator, gps_nmea_uart, spi_mem_manager
- **RF / analyse** : spectrum_analyzer, radio_scanner, protoview, weather_station, pocsag_pager
- **NFC / RFID** : mfc_editor, nfc_magic, nfc_rfid_detector, picopass
- **Sécurité offensive (dual-use)** : wifi_marauder_companion, esp8266_deauth, mousejacker, nrfsniff
- **Sécurité — ajout complémentaire** : ble_spam, wifi_scanner, subbrute, multi_fuzzer,
  sentry_safe, rolling_flaws

### Adaptations à l'API 1.4.3 (modifications GPLv3 signalées)

Certains outils, écrits pour un firmware plus récent, ont été **adaptés** pour compiler
contre l'officiel 1.4.3 (chaque modification est commentée `// BGFlipper OS:` dans le code) :
- `wifi_scanner` : `canvas_current_font_width()` (absent) → `canvas_string_width(canvas, "0")`.
- `ble_spam` : police `FontBatteryPercent` (absente) → `FontSecondary` ; `variable_item_list_get()`
  (absent) → pointeur d'item stocké dans le `Ctx`.
- `subbrute` : retrait de l'include/appel `custom_btn` (extension SubGHz propre à Unleashed) ;
  `FontBatteryPercent` → `FontSecondary`.

⚖️ Les outils **dual-use** (édition/écriture de cartes NFC/RFID, deauth WiFi, mousejacker,
sniff nRF, marauder, BLE spam, brute-force SubGHz, ouverture de coffres Sentry) sont destinés
à un usage **autorisé** (pentest, recherche) sous la responsabilité de l'opérateur. Plusieurs
nécessitent un **module matériel externe** (ESP32/ESP8266, nRF24) pour fonctionner.

## Retrait du mascot « dauphin » (outil professionnel)

BGFlipper OS est un outil pro **sans mascot ni élément ludique**. Le dauphin apparaissait
via **11 sources distinctes**, toutes neutralisées (assets remplacés par le logo BG, ou
patchs de code marqués `// BGFlipper OS:`) :

- **Animations idle** externes *et* internes (`assets/dolphin/external|internal/manifest.txt`
  → logo seul). L'astuce clé : les animations **internes** sont toujours ajoutées au pool
  d'idle par `animation_storage.c`, donc le seul manifeste externe ne suffit pas.
- **Fallback `L1_Tv`** : `animation_manager.c` `HARDCODED_ANIMATION_NAME` → `BGFlipperLogo`.
- **Popup de level-up** : `dolphin.c` `level_up_is_pending = false` (le compteur XP survit
  en interne, sans surface visible).
- **Passeport** : `desktop_scene_main.c` bouton central → menu Apps ; app `passport` retirée
  du build (`settings/application.fam`).
- **Popups de confirmation** (`I_Dolphin*`, `I_RFIDDolphin*`, `I_NFC_dolphin_emulation`,
  `I_WarningDolphin*`, `I_iButtonDolphinVerySuccess`) : PNG remplacés par le logo → tous les
  écrans save/read/delete/success affichent le logo, **sans éditer les ~30 scènes**.
- **Icône GameMode** : PNG vidé (indicateur invisible).
- **Slideshow post-update** (`assets/slideshow/update_default/` → `splash.bin`) et
  **first_start** : frames → logo.
- **Animations « blocking »** (`assets/dolphin/blocking/L0_*` : SD ok/bad, no-db, url, mail)
  → logo.
- **Bug updater** : `update_task_worker_backup.c` — `storage_common_copy` n'écrase pas une
  destination existante, donc un ancien slideshow dauphin sur `/int/.slideshow` persistait ;
  on ajoute un `storage_simply_remove` avant la copie.

## Non importé (et pourquoi)

- **Keeloq (`keeloq_mfcodes`)** : la liste étendue de fabricants d'Unleashed est un keystore
  **chiffré** ; le plan recommande de ne pas remplacer le keystore officiel (risque de
  compatibilité). Le fichier utilisateur public d'Unleashed ne contient que des clés d'exemple.
  → différé, en attente d'une source plaintext fiable.

## Protocoles portés (Palier 3)

Base de comparaison : diff du registre 1.4.3 (`lib/subghz/protocols/protocol_items.c`,
`lib/lfrfid/protocols/lfrfid_protocols.c`) contre **DarkFlippers/unleashed-firmware**
`unlshd-089` (GPLv3). La grande majorité des protocoles Unleashed/RogueMaster est déjà
présente en 1.4.3 (51 Sub-GHz, 24 LFRFID) — seuls les protocoles réellement absents ont
été portés, en nouveaux fichiers `lib/subghz/protocols/<nom>.c/.h` (auto-compilés, non
suivis en md5) + entrées ajoutées aux registres `protocol_items.{c,h}` /
`lfrfid_protocols.{c,h}` (fichiers suivis, cf. `overlay/UPSTREAM_HASHES.txt`).

**Sub-GHz (9 nouveaux protocoles)**, source `unlshd-089` :
- Statiques/simples : `allstar_firefly`, `elplast`, `honeywell`, `keyfinder`, `nord_ice`,
  `treadmill37`. Adaptation : le champ global `subghz_block_generic_global.endless_tx`
  d'Unleashed n'existe pas en 1.4.3 ; le test conditionnel autour de `encoder.repeat--`
  a été remplacé par la décrémentation inconditionnelle (comportement 1.4.3 standard).
  `honeywell` : retrait du flag `SubGhzProtocolFlag_Sensors` (catégorie absente en 1.4.3).
- Code tournant (rolling code) : `beninca_arc`, `ditec_gol4`, `jarolift`. Ces trois
  protocoles dépendent d'infrastructure Unleashed absente en 1.4.3, portée avec eux :
  - `lib/subghz/blocks/custom_btn.{c,h}` — bouton personnalisé, porté tel quel
    (self-contained).
  - `SubGhzBlockGenericGlobal` (`lib/subghz/blocks/generic.h`) — struct globale
    (compteur/bouton override, `endless_tx`) + 2 accesseurs, ajoutée par overlay.
  - `SubGhzBlockGeneric` étendu de 3 champs (`data_2`, `cnt_2`, `seed`) requis par ces
    protocoles à code tournant.
  - `lib/subghz/protocols/aes_common.{c,h}` — AES logiciel autonome, porté tel quel
    (`jarolift`).
  - `furi_hal_subghz_get_rolling_counter_mult()` — nouvelle fonction HAL publique
    (retourne `1`, comportement neutre en 1.4.3) ; nécessite la finalisation du SDK
    (`targets/f7/api_symbols.csv`, version `87.2`, suivi en md5).
  - `KEELOQ_LEARNING_NORMAL_JAROLIFT` (valeur `11`) ajouté à `keeloq_common.h`, sans
    collision avec les valeurs 1.4.3 (0–7).

**LFRFID (1 nouveau protocole)**, source `unlshd-089` :
- `indala224` (`LFRFIDProtocolIndala224`) — implémente `ProtocolBase`, ajouté au registre
  avant `LFRFIDProtocolMax`.

Les protocoles NFC restent **hors-scope** (report délibéré) : chaque protocole NFC
nécessite une pile poller/listener/device complète + intégration UI sur 4-5 registres,
avec un risque de crash trop élevé pour un simple port de données.

## Note réglementaire (déverrouillage Sub-GHz TX — Palier 2, à venir)

BGFlipper OS pourra activer l'émission Sub-GHz sur l'ensemble des bandes que le matériel
CC1101 peut accorder. **L'émission hors des fréquences autorisées dans votre pays est
réglementée** : son usage relève de la seule responsabilité de l'opérateur. Voir aussi les
notes légales de `docs/ROADMAP.md`.

## Licence

BGFlipper OS est distribué sous **GPLv3**, comme les sources dont il dérive. Toute
redistribution doit fournir les sources correspondantes.
