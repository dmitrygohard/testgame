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
    
    show_debug_message("Состояние игры загружено");
}

function save_game_state() {
    // Сохраняем состояние игры
    game_data_save();
    show_debug_message("Состояние игры сохранено");
}
