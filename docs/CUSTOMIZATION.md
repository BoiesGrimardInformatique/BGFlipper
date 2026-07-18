# Personnaliser BGFlipper OS

Deux familles de personnalisation, par ordre de préférence :

1. **Hooks non intrusifs** — on ne touche à aucun fichier upstream. Robuste aux
   montées de version. À privilégier.
2. **Overlays de remplacement** — on remplace un fichier upstream entier. Plus
   puissant mais fragile : à re-vérifier à chaque changement de version (le
   script détecte la divergence via md5).

---

## 1. Identité du firmware — `overlay/fbt_options_local.py` (hook)

Le firmware exécute `fbt_options_local.py` s'il existe, à la fin de
`fbt_options.py`. On y redéfinit des variables **sans modifier l'upstream** :

```python
FIRMWARE_ORIGIN = "BGFlipper"     # visible dans About / CLI info / notre splash
```

Autres variables utiles (voir `upstream/fbt_options.py`) :

| Variable | Effet |
|---|---|
| `FIRMWARE_ORIGIN` | Chaîne d'origine (toute valeur ≠ `Official` = non officiel) |
| `FIRMWARE_APP_SET` | Jeu d'apps intégrées (`default`, ou un set custom) |
| `FIRMWARE_APPS[...]` | Compose la liste des apps intégrées au `.bin` |
| `COPRO_*` | Version de la pile radio BLE (à ne changer qu'en connaissance de cause) |
| `DEBUG`, `COMPACT` | Options de compilation (taille/déboguage) |

## 2. Bannière CLI — `overlay/applications/services/cli/cli_main_shell.c` (remplacement)

On remplace la fonction `cli_main_motd()` pour afficher le logo « BGFlipper OS ».
Comme c'est un **remplacement de fichier**, son empreinte upstream est suivie
dans `overlay/UPSTREAM_HASHES.txt`. Régénérez-la après tout report :

```bash
make update-hashes
```

---

## Ajouter une nouvelle application (FAP)

1. Créez un dossier sous `applications/<mon_app>/` avec :
   - `application.fam` (manifeste) ;
   - `<mon_app>.c` (au moins la fonction `entry_point`).
2. Testez : `make run APP=<mon_app>`.

Manifeste minimal (`application.fam`) :

```python
App(
    appid="mon_app",
    name="Mon App",
    apptype=FlipperAppType.EXTERNAL,   # EXTERNAL = .fap chargé depuis la SD
    entry_point="mon_app_main",        # doit correspondre à la fonction C
    requires=["gui"],                  # services nécessaires
    stack_size=2 * 1024,
    fap_category="BGFlipper",          # dossier dans le menu Apps
)
```

Squelette C (voir `applications/bgflipper_splash/bgflipper_splash.c` pour un
exemple complet avec entrées + LED) :

```c
#include <furi.h>
#include <gui/gui.h>
#include <input/input.h>

static void draw_cb(Canvas* c, void* ctx) {
    UNUSED(ctx);
    canvas_clear(c);
    canvas_set_font(c, FontPrimary);
    canvas_draw_str_aligned(c, 64, 32, AlignCenter, AlignCenter, "Hello BGFlipper");
}

static void input_cb(InputEvent* e, void* ctx) {
    furi_message_queue_put((FuriMessageQueue*)ctx, e, FuriWaitForever);
}

int32_t mon_app_main(void* p) {
    UNUSED(p);
    FuriMessageQueue* q = furi_message_queue_alloc(8, sizeof(InputEvent));
    ViewPort* vp = view_port_alloc();
    view_port_draw_callback_set(vp, draw_cb, NULL);
    view_port_input_callback_set(vp, input_cb, q);
    Gui* gui = furi_record_open(RECORD_GUI);
    gui_add_view_port(gui, vp, GuiLayerFullscreen);

    InputEvent e;
    while(furi_message_queue_get(q, &e, FuriWaitForever) == FuriStatusOk) {
        if(e.type == InputTypePress && e.key == InputKeyBack) break;
    }

    view_port_enabled_set(vp, false);
    gui_remove_view_port(gui, vp);
    view_port_free(vp);
    furi_message_queue_free(q);
    furi_record_close(RECORD_GUI);
    return 0;
}
```

---

## Personnalisations plus avancées (pistes)

| Cible | Où | Nature |
|---|---|---|
| Animations « dolphin » de l'écran d'accueil | `assets/dolphin/` (manifest + frames PNG) | overlay d'assets |
| Logo de boot / slideshow | `assets/slideshow/` | overlay d'assets |
| Icônes système | `assets/icons/` | overlay d'assets |
| App « About » (texte/version affichés) | `applications/settings/about/about.c` | remplacement |
| Apps intégrées par défaut | `FIRMWARE_APPS` via `fbt_options_local.py` | hook |

> Pour tout **remplacement**, ajoutez l'empreinte du fichier upstream dans
> `overlay/UPSTREAM_HASHES.txt` (`make update-hashes` après avoir listé le
> fichier dans la cible `update-hashes` du Makefile) afin de détecter les
> divergences aux montées de version.

Les assets binaires (PNG des animations, logo) ne sont pas encore inclus dans ce
dépôt — voir `docs/ROADMAP.md`, phase 2.
