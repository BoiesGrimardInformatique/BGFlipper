/**
 * @file bgflipper_splash.c
 * @brief BGFlipper OS - écran de bienvenue / carte d'identité du firmware.
 *
 * Application externe (FAP) de démonstration pour BGFlipper OS. Elle affiche
 * une bannière "BGFlipper OS" ainsi que les informations de version et
 * d'origine du firmware (renseignées via FIRMWARE_ORIGIN dans
 * fbt_options_local.py).
 *
 * Commandes :
 *   - OK   : fait clignoter la LED (retour visuel via le service notification)
 *   - Back : quitte l'application
 *
 * Écrite pour l'API du firmware Flipper Zero 1.4.3.
 */

#include <furi.h>
#include <furi_hal.h>

#include <gui/gui.h>
#include <input/input.h>
#include <notification/notification_messages.h>

#define TAG "BGFlipperSplash"

typedef struct {
    FuriMessageQueue* input_queue;
    ViewPort* view_port;
    Gui* gui;
    NotificationApp* notifications;
    uint32_t blink_count;
} BGFlipperApp;

/* Rendu de l'écran (128x64 px). Appelé par le service GUI. */
static void bgflipper_draw_callback(Canvas* canvas, void* ctx) {
    furi_assert(ctx);
    BGFlipperApp* app = ctx;

    canvas_clear(canvas);

    /* Cadre arrondi autour de tout l'écran. */
    canvas_draw_rframe(canvas, 0, 0, 128, 64, 4);

    /* Titre. */
    canvas_set_font(canvas, FontPrimary);
    canvas_draw_str_aligned(canvas, 64, 12, AlignCenter, AlignCenter, "BGFlipper OS");

    /* Ligne de séparation. */
    canvas_draw_line(canvas, 8, 21, 120, 21);

    /* Version + origine du firmware. */
    canvas_set_font(canvas, FontSecondary);

    const Version* fw = furi_hal_version_get_firmware_version();
    char line[48];

    if(fw) {
        snprintf(line, sizeof(line), "Origine: %s", version_get_firmware_origin(fw));
        canvas_draw_str_aligned(canvas, 64, 30, AlignCenter, AlignCenter, line);

        snprintf(line, sizeof(line), "Base FW: %s", version_get_version(fw));
        canvas_draw_str_aligned(canvas, 64, 40, AlignCenter, AlignCenter, line);
    } else {
        canvas_draw_str_aligned(canvas, 64, 35, AlignCenter, AlignCenter, "Version inconnue");
    }

    /* Compteur de clignotements. */
    snprintf(line, sizeof(line), "Blinks: %lu", (unsigned long)app->blink_count);
    canvas_draw_str_aligned(canvas, 64, 50, AlignCenter, AlignCenter, line);

    /* Aide en bas d'écran. */
    canvas_draw_str_aligned(canvas, 64, 59, AlignCenter, AlignCenter, "OK: LED   Back: Quitter");
}

/* Callback d'entrée : on empile simplement l'évènement dans la file. */
static void bgflipper_input_callback(InputEvent* input_event, void* ctx) {
    furi_assert(ctx);
    FuriMessageQueue* input_queue = ctx;
    furi_message_queue_put(input_queue, input_event, FuriWaitForever);
}

static BGFlipperApp* bgflipper_app_alloc(void) {
    BGFlipperApp* app = malloc(sizeof(BGFlipperApp));

    app->blink_count = 0;
    app->input_queue = furi_message_queue_alloc(8, sizeof(InputEvent));

    app->view_port = view_port_alloc();
    view_port_draw_callback_set(app->view_port, bgflipper_draw_callback, app);
    view_port_input_callback_set(app->view_port, bgflipper_input_callback, app->input_queue);

    app->gui = furi_record_open(RECORD_GUI);
    gui_add_view_port(app->gui, app->view_port, GuiLayerFullscreen);

    app->notifications = furi_record_open(RECORD_NOTIFICATION);

    return app;
}

static void bgflipper_app_free(BGFlipperApp* app) {
    furi_assert(app);

    view_port_enabled_set(app->view_port, false);
    gui_remove_view_port(app->gui, app->view_port);
    view_port_free(app->view_port);

    furi_message_queue_free(app->input_queue);

    furi_record_close(RECORD_NOTIFICATION);
    furi_record_close(RECORD_GUI);

    free(app);
}

int32_t bgflipper_splash_app(void* arg) {
    UNUSED(arg);

    BGFlipperApp* app = bgflipper_app_alloc();
    FURI_LOG_I(TAG, "BGFlipper OS splash started");

    InputEvent event;
    bool running = true;

    while(running) {
        if(furi_message_queue_get(app->input_queue, &event, FuriWaitForever) != FuriStatusOk) {
            continue;
        }

        if(event.type != InputTypePress) {
            continue;
        }

        switch(event.key) {
        case InputKeyOk:
            app->blink_count++;
            notification_message(app->notifications, &sequence_blink_cyan_10);
            view_port_update(app->view_port);
            break;
        case InputKeyBack:
            running = false;
            break;
        default:
            break;
        }
    }

    FURI_LOG_I(TAG, "BGFlipper OS splash stopped");
    bgflipper_app_free(app);

    return 0;
}
