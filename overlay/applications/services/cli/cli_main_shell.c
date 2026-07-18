#include "cli_main_shell.h"
#include "cli_main_commands.h"
#include <toolbox/cli/cli_ansi.h>
#include <toolbox/cli/shell/cli_shell.h>
#include <furi_hal_version.h>

/*
 * BGFlipper OS - bannière CLI personnalisée.
 *
 * Fichier d'overlay : remplace applications/services/cli/cli_main_shell.c du
 * firmware officiel 1.4.3 (md5 upstream: 9f24be977b7a2a1600b6b8c0fa546c83).
 * Seul le message d'accueil (motd) est modifié ; le reste du fichier est
 * identique à l'upstream. Si une future version du firmware change ce fichier,
 * `scripts/apply-overlay.sh` vous avertira d'une divergence à re-vérifier.
 */

void cli_main_motd(void* context) {
    UNUSED(context);
    printf(ANSI_FLIPPER_BRAND_ORANGE
           "\r\n"
           "              _.-------.._                    -,\r\n"
           "          .-\"```\"--..,,_/ /`-,               -,  \\ \r\n"
           "       .:\"          /:/  /'\\  \\     ,_...,  `. |  |\r\n"
           "      /       ,----/:/  /`\\ _\\~`_-\"`     _;\r\n"
           "     '      / /`\"\"\"'\\ \\ \\.~`_-'      ,-\"'/ \r\n"
           "    |      | |  0    | | .-'      ,/`  /\r\n"
           "   |    ,..\\ \\     ,.-\"`       ,/`    /\r\n"
           "  ;    :    `/`\"\"\\`           ,/--==,/-----,\r\n"
           "  |    `-...|        -.___-Z:_______J...---;\r\n"
           "  :         `                           _-'\r\n"
           "\r\n"
           " ____   ____ _____ _ _                          ___  ____  \r\n"
           "| __ ) / ___|  ___| (_)_ __  _ __   ___ _ __   / _ \\/ ___| \r\n"
           "|  _ \\| |  _| |_  | | | '_ \\| '_ \\ / _ \\ '__| | | | \\___ \\ \r\n"
           "| |_) | |_| |  _| | | | |_) | |_) |  __/ |    | |_| |___) |\r\n"
           "|____/ \\____|_|   |_|_| .__/| .__/ \\___|_|     \\___/|____/ \r\n"
           "                      |_|   |_|                            \r\n"
           "\r\n" ANSI_FG_BR_WHITE "Bienvenue dans BGFlipper OS - firmware Flipper Zero personnalise !\r\n"
           "Depot : https://github.com/BoiesGrimardInformatique/BGFlipper\r\n"
           "Tapez `help` ou `?` pour lister les commandes disponibles\r\n"
           "\r\n" ANSI_RESET);

    const Version* firmware_version = furi_hal_version_get_firmware_version();
    if(firmware_version) {
        printf(
            "Firmware version: %s %s (%s%s built on %s)\r\n",
            version_get_gitbranch(firmware_version),
            version_get_version(firmware_version),
            version_get_githash(firmware_version),
            version_get_dirty_flag(firmware_version) ? "-dirty" : "",
            version_get_builddate(firmware_version));
    }
}

const CliCommandExternalConfig cli_main_ext_config = {
    .search_directory = "/ext/apps_data/cli/plugins",
    .fal_prefix = "cli_",
    .appid = CLI_APPID,
};
