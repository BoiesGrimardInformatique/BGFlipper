# bgflipper_splash

Application externe (FAP) de démonstration pour **BGFlipper OS**.

Elle affiche une bannière `BGFlipper OS`, l'origine du firmware (`FIRMWARE_ORIGIN`)
et la version de base, avec un petit retour LED sur la touche `OK`.

## Rôle dans le projet

Ce FAP sert de brique de départ pour développer vos propres applications, et
de test rapide pour vérifier que la chaîne de build fonctionne :

```bash
# Depuis la racine du dépôt, après `make setup`
make run APP=bgflipper_splash
# équivaut à : cd upstream && ./fbt launch APPSRC=applications_user/bgflipper_splash
```

`./fbt launch` compile le FAP, l'envoie sur le Flipper connecté en USB et le
lance immédiatement — c'est la boucle de dev la plus rapide.

## Structure

| Fichier             | Rôle                                                        |
|---------------------|-------------------------------------------------------------|
| `application.fam`   | Manifeste de l'app (id, point d'entrée, catégorie, mémoire) |
| `bgflipper_splash.c`| Code source (ViewPort + Canvas + file d'évènements)         |

## API utilisée

Écrite pour l'API du firmware **1.4.3** :

- `gui/gui.h`, `input/input.h` — affichage plein écran et entrées clavier
- `furi_hal_version.h` (via `furi_hal.h`) — version et origine du firmware
- `notification/notification_messages.h` — retour LED (`sequence_blink_cyan_10`)

Voir `docs/CUSTOMIZATION.md` pour ajouter d'autres apps.
