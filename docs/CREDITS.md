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

⚖️ Les outils **dual-use** (édition/écriture de cartes NFC/RFID, deauth WiFi, mousejacker,
sniff nRF, marauder) sont destinés à un usage **autorisé** (pentest, recherche) sous la
responsabilité de l'opérateur. Plusieurs nécessitent un **module matériel externe**
(ESP32/ESP8266, nRF24) pour fonctionner.

## Non importé (et pourquoi)

- **Keeloq (`keeloq_mfcodes`)** : la liste étendue de fabricants d'Unleashed est un keystore
  **chiffré** ; le plan recommande de ne pas remplacer le keystore officiel (risque de
  compatibilité). Le fichier utilisateur public d'Unleashed ne contient que des clés d'exemple.
  → différé, en attente d'une source plaintext fiable.

## Note réglementaire (déverrouillage Sub-GHz TX — Palier 2, à venir)

BGFlipper OS pourra activer l'émission Sub-GHz sur l'ensemble des bandes que le matériel
CC1101 peut accorder. **L'émission hors des fréquences autorisées dans votre pays est
réglementée** : son usage relève de la seule responsabilité de l'opérateur. Voir aussi les
notes légales de `docs/ROADMAP.md`.

## Licence

BGFlipper OS est distribué sous **GPLv3**, comme les sources dont il dérive. Toute
redistribution doit fournir les sources correspondantes.
