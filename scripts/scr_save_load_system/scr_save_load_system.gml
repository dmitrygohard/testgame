// Глобальные переменные, которые должны сохраняться между комнатами
global.persistent_initialized = false;

// scr_persistent_data.gml
// scr_persistent_data.gml
function init_persistent_data() {
    if (variable_global_exists("persistent_initialized") && global.persistent_initialized) {
        return;
    }
    
    // Инициализируем только если еще не создано
    if (!variable_global_exists("hero")) {
        init_main_hero();
    }
    
    if (!variable_global_exists("companions")) {
        init_companions();
    }
    
    if (!variable_global_exists("arenas")) {
        init_arenas();
    }
    
    if (!variable_global_exists("playerInventory")) {
        global.playerInventory = ds_list_create();
    }
    
    // ГАРАНТИРУЕМ, что флаги подтверждения экспедиции установлены правильно
    global.expedition_confirmation_required = false;
    global.pending_expedition_difficulty = -1;
    
    global.persistent_initialized = true;
    show_debug_message("Persistent data initialized");
}


// scr_save_load_system.gml
// Система сохранения и загрузки игры

function game_data_init() {
    // Инициализация системы сохранения
    if (!variable_global_exists("game_data") || !ds_exists(global.game_data, ds_type_map)) {
        global.game_data = ds_map_create();
        show_debug_message("Система сохранения инициализирована");
    }
}

function game_data_save() {
    // Проверяем, что game_data существует и является корректной ds_map
    if (!variable_global_exists("game_data") || !ds_exists(global.game_data, ds_type_map)) {
        game_data_init();
    }
    
    // Очищаем предыдущие данные
    ds_map_clear(global.game_data);
    
    // Сохраняем основные данные игры
    ds_map_add(global.game_data, "gold", global.gold);
    ds_map_add(global.game_data, "max_available_difficulty", global.max_available_difficulty);
    
    // Сохраняем данные героя
    if (variable_global_exists("hero")) {
        ds_map_add(global.game_data, "hero_level", global.hero.level);
        ds_map_add(global.game_data, "hero_exp", global.hero.exp);
        ds_map_add(global.game_data, "hero_strength", global.hero.strength);
        ds_map_add(global.game_data, "hero_agility", global.hero.agility);
        ds_map_add(global.game_data, "hero_intelligence", global.hero.intelligence);
        ds_map_add(global.game_data, "hero_health", global.hero.health);
        ds_map_add(global.game_data, "hero_max_health", global.hero.max_health);
    }
    
    // Сохраняем данные помощниц
    if (variable_global_exists("companions")) {
        for (var i = 0; i < array_length(global.companions); i++) {
            var companion = global.companions[i];
            ds_map_add(global.game_data, "companion_" + string(i) + "_unlocked", companion.unlocked);
            ds_map_add(global.game_data, "companion_" + string(i) + "_level", companion.level);
            ds_map_add(global.game_data, "companion_" + string(i) + "_exp", companion.exp);
        }
    }
    
    // Сохраняем данные арен
    if (variable_global_exists("arenas")) {
        for (var i = 0; i < array_length(global.arenas); i++) {
            var arena = global.arenas[i];
            ds_map_add(global.game_data, "arena_" + string(i) + "_unlocked", arena.unlocked);
        }
    }

    // Сохраняем инвентарь игрока
    var inventory_serialized = [];
    if (variable_global_exists("playerInventory") && ds_exists(global.playerInventory, ds_type_list)) {
        for (var inv_i = 0; inv_i < ds_list_size(global.playerInventory); inv_i++) {
            var inv_entry = ds_list_find_value(global.playerInventory, inv_i);
            if (ds_exists(inv_entry, ds_type_map)) {
                var inv_struct = {
                    id: inv_entry[? "id"],
                    quantity: inv_entry[? "quantity"]
                };
                array_push(inventory_serialized, inv_struct);
            }
        }
    }
    ds_map_add(global.game_data, "inventory_json", json_stringify(inventory_serialized));

    // Сохраняем экипировку героя и бонусы
    if (variable_global_exists("equipment_slots") && array_length(global.equipment_slots) > 0) {
        var hero_equipment = global.equipment_slots[0];
        var equipment_struct = {
            weapon: variable_struct_get(hero_equipment, "weapon"),
            armor: variable_struct_get(hero_equipment, "armor"),
            accessory: variable_struct_get(hero_equipment, "accessory"),
            relic: variable_struct_get(hero_equipment, "relic")
        };
        ds_map_add(global.game_data, "hero_equipment_json", json_stringify(equipment_struct));
    }

    if (function_exists(ensure_equipment_bonus_defaults)) {
        ensure_equipment_bonus_defaults();
    }
    if (variable_global_exists("hero") && variable_struct_exists(global.hero, "equipment_bonuses")) {
        ds_map_add(global.game_data, "equipment_bonuses_json", json_stringify(global.hero.equipment_bonuses));
    }

    // Сохраняем трофеи
    var unlocked_trophies = [];
    if (variable_global_exists("trophy_state")) {
        var trophy_names = variable_struct_get_names(global.trophy_state);
        for (var t = 0; t < array_length(trophy_names); t++) {
            var trophy_id = trophy_names[t];
            if (variable_struct_get(global.trophy_state, trophy_id)) {
                array_push(unlocked_trophies, trophy_id);
            }
        }
    }
    ds_map_add(global.game_data, "trophy_unlocked_json", json_stringify(unlocked_trophies));

    if (variable_global_exists("featured_trophies")) {
        ds_map_add(global.game_data, "featured_trophies_json", json_stringify(global.featured_trophies));
    }

    if (variable_global_exists("trophy_tracker")) {
        ds_map_add(global.game_data, "trophy_total_wins", global.trophy_tracker.total_expedition_wins);
        ds_map_add(global.game_data, "trophy_gold_record", global.trophy_tracker.gold_record);
    }

    show_debug_message("Данные игры сохранены");
}

function game_data_load() {
    // Проверяем, существует ли game_data и является ли корректной ds_map
    if (!variable_global_exists("game_data") || !ds_exists(global.game_data, ds_type_map)) {
        show_debug_message("Нет данных для загрузки: global.game_data не инициализирован");
        return;
    }
    
    // Проверяем, что карта не пустая
    if (ds_map_size(global.game_data) == 0) {
        show_debug_message("Нет данных для загрузки: global.game_data пуст");
        return;
    }
    
    // Загружаем основные данные
    if (ds_map_exists(global.game_data, "gold")) {
        global.gold = ds_map_find_value(global.game_data, "gold");
    }
    
    if (ds_map_exists(global.game_data, "max_available_difficulty")) {
        global.max_available_difficulty = ds_map_find_value(global.game_data, "max_available_difficulty");
    }
    
    // Загружаем данные героя
    if (variable_global_exists("hero")) {
        if (ds_map_exists(global.game_data, "hero_level")) {
            global.hero.level = ds_map_find_value(global.game_data, "hero_level");
        }
        if (ds_map_exists(global.game_data, "hero_exp")) {
            global.hero.exp = ds_map_find_value(global.game_data, "hero_exp");
        }
        if (ds_map_exists(global.game_data, "hero_strength")) {
            global.hero.strength = ds_map_find_value(global.game_data, "hero_strength");
        }
        if (ds_map_exists(global.game_data, "hero_agility")) {
            global.hero.agility = ds_map_find_value(global.game_data, "hero_agility");
        }
        if (ds_map_exists(global.game_data, "hero_intelligence")) {
            global.hero.intelligence = ds_map_find_value(global.game_data, "hero_intelligence");
        }
        if (ds_map_exists(global.game_data, "hero_health")) {
            global.hero.health = ds_map_find_value(global.game_data, "hero_health");
        }
        if (ds_map_exists(global.game_data, "hero_max_health")) {
            global.hero.max_health = ds_map_find_value(global.game_data, "hero_max_health");
        }
    }
    
    // Загружаем данные помощниц
    if (variable_global_exists("companions")) {
        for (var i = 0; i < array_length(global.companions); i++) {
            var key_unlocked = "companion_" + string(i) + "_unlocked";
            var key_level = "companion_" + string(i) + "_level";
            var key_exp = "companion_" + string(i) + "_exp";
            
            if (ds_map_exists(global.game_data, key_unlocked)) {
                global.companions[i].unlocked = ds_map_find_value(global.game_data, key_unlocked);
            }
            if (ds_map_exists(global.game_data, key_level)) {
                global.companions[i].level = ds_map_find_value(global.game_data, key_level);
            }
            if (ds_map_exists(global.game_data, key_exp)) {
                global.companions[i].exp = ds_map_find_value(global.game_data, key_exp);
            }
        }
    }
    
    // Загружаем данные арен
    if (variable_global_exists("arenas")) {
        for (var i = 0; i < array_length(global.arenas); i++) {
            var key = "arena_" + string(i) + "_unlocked";
            if (ds_map_exists(global.game_data, key)) {
                global.arenas[i].unlocked = ds_map_find_value(global.game_data, key);
            }
        }
    }

    // Загружаем инвентарь
    if (ds_map_exists(global.game_data, "inventory_json")) {
        var inventory_json = ds_map_find_value(global.game_data, "inventory_json");
        if (is_string(inventory_json) && string_length(inventory_json) > 0) {
            var inventory_array = json_parse(inventory_json);
            if (is_array(inventory_array)) {
                if (function_exists(inventory_clear_all)) {
                    inventory_clear_all();
                }
                for (var inv_i = 0; inv_i < array_length(inventory_array); inv_i++) {
                    var entry = inventory_array[inv_i];
                    if (is_struct(entry) && variable_struct_exists(entry, "id")) {
                        var qty = 1;
                        if (variable_struct_exists(entry, "quantity")) {
                            qty = max(1, entry.quantity);
                        }
                        AddItemToInventory(entry.id, qty);
                    }
                }
            }
        } else if (function_exists(inventory_clear_all)) {
            inventory_clear_all();
        }
    }

    // Загружаем экипировку героя
    if (ds_map_exists(global.game_data, "hero_equipment_json") && variable_global_exists("equipment_slots") && array_length(global.equipment_slots) > 0) {
        var equipment_json = ds_map_find_value(global.game_data, "hero_equipment_json");
        if (is_string(equipment_json) && string_length(equipment_json) > 0) {
            var equipment_struct = json_parse(equipment_json);
            if (is_struct(equipment_struct)) {
                var hero_equipment = global.equipment_slots[0];
                if (!is_struct(hero_equipment)) {
                    hero_equipment = { weapon: -1, armor: -1, accessory: -1, relic: -1 };
                    global.equipment_slots[0] = hero_equipment;
                }

                var slot_names = ["weapon", "armor", "accessory", "relic"];
                for (var s = 0; s < array_length(slot_names); s++) {
                    var slot_name = slot_names[s];
                    var slot_value = -1;
                    if (variable_struct_exists(equipment_struct, slot_name)) {
                        slot_value = equipment_struct[? slot_name];
                    }
                    variable_struct_set(hero_equipment, slot_name, slot_value);
                }
            }
        }
    }

    if (ds_map_exists(global.game_data, "equipment_bonuses_json") && variable_global_exists("hero")) {
        var bonuses_json = ds_map_find_value(global.game_data, "equipment_bonuses_json");
        if (is_string(bonuses_json) && string_length(bonuses_json) > 0) {
            var bonus_struct = json_parse(bonuses_json);
            if (is_struct(bonus_struct)) {
                global.hero.equipment_bonuses = bonus_struct;
            }
        }
        if (function_exists(ensure_equipment_bonus_defaults)) {
            ensure_equipment_bonus_defaults();
        }
    }

    if (function_exists(reapply_hero_artifact_effects)) {
        reapply_hero_artifact_effects();
    }

    if (function_exists(ensure_equipment_set_structs)) {
        ensure_equipment_set_structs();
    }
    if (function_exists(update_equipment_set_bonuses)) {
        update_equipment_set_bonuses();
    }

    // Загружаем трофеи
    if (ds_map_exists(global.game_data, "trophy_unlocked_json")) {
        var trophy_json = ds_map_find_value(global.game_data, "trophy_unlocked_json");
        if (is_string(trophy_json) && string_length(trophy_json) > 0) {
            var trophy_array = json_parse(trophy_json);
            if (is_array(trophy_array)) {
                if (!variable_global_exists("trophy_state")) {
                    global.trophy_state = {};
                }
                global.trophy_state = {};
                for (var tt = 0; tt < array_length(trophy_array); tt++) {
                    var trophy_id = trophy_array[tt];
                    variable_struct_set(global.trophy_state, trophy_id, true);
                }
            }
        }
    }

    if (ds_map_exists(global.game_data, "featured_trophies_json")) {
        var featured_json = ds_map_find_value(global.game_data, "featured_trophies_json");
        if (is_string(featured_json) && string_length(featured_json) > 0) {
            var featured_array = json_parse(featured_json);
            if (is_array(featured_array)) {
                if (!variable_global_exists("featured_trophies")) {
                    global.featured_trophies = ["", "", ""];
                }
                for (var ft = 0; ft < min(array_length(featured_array), array_length(global.featured_trophies)); ft++) {
                    global.featured_trophies[ft] = featured_array[ft];
                }
            }
        }
    }

    if (variable_global_exists("trophy_tracker")) {
        if (ds_map_exists(global.game_data, "trophy_total_wins")) {
            global.trophy_tracker.total_expedition_wins = ds_map_find_value(global.game_data, "trophy_total_wins");
        }
        if (ds_map_exists(global.game_data, "trophy_gold_record")) {
            global.trophy_tracker.gold_record = ds_map_find_value(global.game_data, "trophy_gold_record");
        }
    }

    show_debug_message("Данные игры загружены");
}

function load_game_state() {
    // Загружаем состояние игры
    game_data_load();
    
    // Пересчитываем бонусы после загрузки
    if (variable_global_exists("calculate_companion_bonuses")) {
        calculate_companion_bonuses();
    }

    // Обновляем здоровье после загрузки
    if (variable_global_exists("update_hero_max_health")) {
        update_hero_max_health();
    }

    if (function_exists(update_equipment_set_bonuses)) {
        update_equipment_set_bonuses();
    }

    show_debug_message("Состояние игры загружено");
}

function save_game_state() {
    // Сохраняем состояние игры
    game_data_save();
    show_debug_message("Состояние игры сохранено");
}
