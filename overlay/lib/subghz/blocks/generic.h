#pragma once

#include <stdbool.h>
#include <stdint.h>
#include <stddef.h>

#include <lib/flipper_format/flipper_format.h>
#include <furi.h>
#include <furi_hal.h>
#include "../types.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef struct SubGhzBlockGeneric SubGhzBlockGeneric;

struct SubGhzBlockGeneric {
    const char* protocol_name;
    uint64_t data;
    uint64_t data_2; // BGFlipper OS: 2e mot de données (protocoles code tournant, Unleashed)
    uint32_t serial;
    uint16_t data_count_bit;
    uint8_t btn;
    uint32_t cnt;
    uint8_t cnt_2; // BGFlipper OS: (Unleashed)
    uint32_t seed; // BGFlipper OS: graine code tournant (Unleashed)
};

/**
 * Get name preset.
 * @param preset_name name preset
 * @param preset_str Output name preset
 */
void subghz_block_generic_get_preset_name(const char* preset_name, FuriString* preset_str);

/**
 * Serialize data SubGhzBlockGeneric.
 * @param instance Pointer to a SubGhzBlockGeneric instance
 * @param flipper_format Pointer to a FlipperFormat instance
 * @param preset The modulation on which the signal was received, SubGhzRadioPreset
 * @return Status Error
 */
SubGhzProtocolStatus subghz_block_generic_serialize(
    SubGhzBlockGeneric* instance,
    FlipperFormat* flipper_format,
    SubGhzRadioPreset* preset);

/**
 * Deserialize data SubGhzBlockGeneric.
 * @param instance Pointer to a SubGhzBlockGeneric instance
 * @param flipper_format Pointer to a FlipperFormat instance
 * @return Status Error
 */
SubGhzProtocolStatus
    subghz_block_generic_deserialize(SubGhzBlockGeneric* instance, FlipperFormat* flipper_format);

/**
 * Deserialize data SubGhzBlockGeneric.
 * @param instance Pointer to a SubGhzBlockGeneric instance
 * @param flipper_format Pointer to a FlipperFormat instance
 * @param count_bit Count bit protocol
 * @return Status Error
 */
SubGhzProtocolStatus subghz_block_generic_deserialize_check_count_bit(
    SubGhzBlockGeneric* instance,
    FlipperFormat* flipper_format,
    uint16_t count_bit);

/* BGFlipper OS: global partagé porté depuis Unleashed (unlshd-089), requis par les
 * protocoles à code tournant (bouton custom + endless TX). */
typedef struct SubGhzBlockGenericGlobal SubGhzBlockGenericGlobal;

struct SubGhzBlockGenericGlobal {
    uint32_t current_cnt;
    uint32_t new_cnt;
    bool cnt_need_override;
    uint8_t cnt_length_bit;
    bool cnt_is_available;

    uint8_t current_btn;
    uint8_t new_btn;
    bool btn_need_override;
    uint8_t btn_length_bit;
    bool btn_is_available;

    bool endless_tx;
};

extern SubGhzBlockGenericGlobal subghz_block_generic_global;

bool subghz_block_generic_global_counter_override_get(uint32_t* counter);
bool subghz_block_generic_global_button_override_get(uint8_t* button);

#ifdef __cplusplus
}
#endif
