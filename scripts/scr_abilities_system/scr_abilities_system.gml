// scr_abilities_system.gml
// Система способностей главного героя

// Типы способностей
global.ABILITY_TYPE = {
    ACTIVE: 0,      // Активные способности (требуют активации)
    PASSIVE: 1,     // Пассивные способности (действуют постоянно)
    ULTIMATE: 2     // Ультимативные способности (длительная перезарядка)
};

// База данных способностей
global.abilities_database = [
    {   // АКТИВНЫЕ СПОСОБНОСТИ
        id: "double_strike",
        name: "⚔️ Двойной Удар",
        description: "Следующая атака наносит двойной урон",
        type: global.ABILITY_TYPE.ACTIVE,
        icon: "⚔️",
        level_required: 5,
        mana_cost: 20,
        cooldown: 300, // 5 секунд при 60 FPS
        duration: 0,
        effect: function() {
            // Эффект применяется при следующей атаке
            global.hero.next_attack_double = true;
            add_notification("⚔️ Двойной удар активирован!");
        },
        color: make_color_rgb(255, 100, 100)
    },
    {
        id: "healing_light",
        name: "💫 Исцеляющий Свет", 
        description: "Восстанавливает 30% от максимального здоровья",
        type: global.ABILITY_TYPE.ACTIVE,
        icon: "💫",
        level_required: 8,
        mana_cost: 30,
        cooldown: 450, // 7.5 секунд
        duration: 0,
        effect: function() {
            var heal_amount = global.hero.max_health * 0.3;
            var actual_heal = hero_heal(heal_amount);
            add_notification("💫 Исцеляющий свет! +" + string(floor(actual_heal)) + " HP");
        },
        color: make_color_rgb(86, 213, 150)
    },
    {
        id: "battle_fury",
        name: "🔥 Боевая Ярость",
        description: "Увеличивает силу на 50% на 15 секунд",
        type: global.ABILITY_TYPE.ACTIVE,
        icon: "🔥",
        level_required: 12,
        mana_cost: 40,
        cooldown: 600, // 10 секунд
        duration: 900, // 15 секунд
        effect: function() {
            var temp_buff = {
                name: "Боевая Ярость",
                description: "Увеличивает силу на 50%",
                icon: "🔥",
                type: -1, // Специальный тип для способностей
                value: global.hero.strength * 0.5,
                duration: 900,
                start_time: global.frame_count,
                color: make_color_rgb(255, 50, 50),
                stat_type: "strength"
            };
            
            if (!variable_global_exists("ability_buffs")) {
                global.ability_buffs = [];
            }
            array_push(global.ability_buffs, temp_buff);
            apply_ability_buff_effect(temp_buff);
            
            add_notification("🔥 Боевая ярость! Сила увеличена!");
        },
        color: make_color_rgb(255, 50, 50)
    },
    
    {   // ПАССИВНЫЕ СПОСОБНОСТИ
        id: "iron_skin",
        name: "🛡️ Железная Кожа",
        description: "Постоянно увеличивает защиту на 10%",
        type: global.ABILITY_TYPE.PASSIVE,
        icon: "🛡️",
        level_required: 3,
        mana_cost: 0,
        cooldown: 0,
        duration: 0,
        effect: function() {
            // Пассивный эффект применяется при изучении
            global.hero.passive_defense_bonus = 0.1;
            add_notification("🛡️ Железная кожа активирована! +10% к защите");
        },
        color: make_color_rgb(100, 150, 255)
    },
    {
        id: "wisdom_aura",
        name: "📚 Аура Мудрости", 
        description: "Увеличивает получаемый опыт на 15%",
        type: global.ABILITY_TYPE.PASSIVE,
        icon: "📚",
        level_required: 6,
        mana_cost: 0,
        cooldown: 0,
        duration: 0,
        effect: function() {
            global.hero.exp_bonus = 0.15;
            add_notification("📚 Аура мудрости! +15% к опыту");
        },
        color: make_color_rgb(150, 100, 255)
    },
    {
        id: "gold_finder",
        name: "💰 Искатель Золота",
        description: "Увеличивает получаемое золото на 20%",
        type: global.ABILITY_TYPE.PASSIVE,
        icon: "💰",
        level_required: 10,
        mana_cost: 0,
        cooldown: 0,
        duration: 0,
        effect: function() {
            global.hero.gold_bonus = 0.2;
            add_notification("💰 Искатель золота! +20% к золоту");
        },
        color: make_color_rgb(255, 215, 0)
    },
    
    {   // УЛЬТИМАТИВНЫЕ СПОСОБНОСТИ
        id: "time_stop",
        name: "⏰ Остановка Времени",
        description: "Мгновенно завершает текущую экспедицию",
        type: global.ABILITY_TYPE.ULTIMATE,
        icon: "⏰",
        level_required: 20,
        mana_cost: 100,
        cooldown: 1800, // 30 секунд
        duration: 0,
        effect: function() {
            if (global.expedition.active) {
                global.expedition.progress = global.expedition.duration;
                add_notification("⏰ Время остановлено! Экспедиция завершена!");
            } else {
                add_notification("Нет активной экспедиции для использования!");
            }
        },
        color: make_color_rgb(200, 100, 255)
    },
    {
        id: "phoenix_rebirth",
        name: "🔥 Возрождение Феникса",
        description: "Воскрешает героя при смерти (1 раз за бой)",
        type: global.ABILITY_TYPE.ULTIMATE,
        icon: "🔥",
        level_required: 25,
        mana_cost: 150,
        cooldown: 3600, // 60 секунд
        duration: 0,
        effect: function() {
            global.hero.phoenix_rebirth_available = true;
            add_notification("🔥 Возрождение Феникса активировано!");
        },
        color: make_color_rgb(255, 100, 50)
    }
];

// Инициализация системы способностей
function init_abilities_system() {
    // Сначала проверяем, существует ли герой
    if (!variable_global_exists("hero")) {
        show_debug_message("Предупреждение: Герой не существует при инициализации способностей. Создаем базового героя.");
        init_main_hero(); // Создаем героя, если его нет
    }
    
    if (!variable_global_exists("hero_abilities")) {
        global.hero_abilities = [];
    }
    
    if (!variable_global_exists("ability_cooldowns")) {
        global.ability_cooldowns = ds_map_create();
    }
    
    if (!variable_global_exists("ability_buffs")) {
        global.ability_buffs = [];
    }
    
    // Инициализируем свойства героя для способностей (с проверками)
    if (!variable_struct_exists(global.hero, "max_mana")) {
        global.hero.max_mana = 100;
    }
    if (!variable_struct_exists(global.hero, "mana")) {
        global.hero.mana = global.hero.max_mana;
    }
    if (!variable_struct_exists(global.hero, "mana_regen")) {
        global.hero.mana_regen = 1.0; // Восстановление маны в секунду
    }
    if (!variable_struct_exists(global.hero, "next_attack_double")) {
        global.hero.next_attack_double = false;
    }
    if (!variable_struct_exists(global.hero, "phoenix_rebirth_available")) {
        global.hero.phoenix_rebirth_available = false;
    }
    
    show_debug_message("Система способностей инициализирована");
}

// Изучение способности
function learn_ability(ability_id) {
    var ability = get_ability(ability_id);
    if (ability == -1) {
        add_notification("Способность не найдена!");
        return false;
    }
    
    // Проверяем, изучена ли уже способность
    if (ability_is_learned(ability_id)) {
        add_notification("Способность уже изучена!");
        return false;
    }
    
    // Проверяем уровень
    if (global.hero.level < ability.level_required) {
        add_notification("Требуется уровень " + string(ability.level_required) + "!");
        return false;
    }
    
    // Для активных способностей проверяем очки навыков
    if (ability.type == global.ABILITY_TYPE.ACTIVE || ability.type == global.ABILITY_TYPE.ULTIMATE) {
        if (global.hero.skill_points < 1) {
            add_notification("Недостаточно очков навыков!");
            return false;
        }
        global.hero.skill_points--;
    }
    
    // Изучаем способность
    array_push(global.hero_abilities, ability_id);
    
    // Применяем эффект способности
    if (ability.type == global.ABILITY_TYPE.PASSIVE) {
        ability.effect();
    }
    
    add_notification("Изучена способность: " + ability.name);
    return true;
}

// Использование способности
function use_ability(ability_id) {
    var ability = get_ability(ability_id);
    if (ability == -1) {
        return false;
    }
    
    // Проверяем, изучена ли способность
    if (!ability_is_learned(ability_id)) {
        add_notification("Способность не изучена!");
        return false;
    }
    
    // Проверяем тип (только активные и ультимативные можно использовать)
    if (ability.type == global.ABILITY_TYPE.PASSIVE) {
        add_notification("Это пассивная способность!");
        return false;
    }
    
    // Проверяем ману
    if (global.hero.mana < ability.mana_cost) {
        add_notification("Недостаточно маны!");
        return false;
    }
    
    // Проверяем перезарядку
    var cooldown_remaining = get_ability_cooldown(ability_id);
    if (cooldown_remaining > 0) {
        add_notification("Перезарядка: " + string(ceil(cooldown_remaining / 60)) + "с");
        return false;
    }
    
    // Используем способность
    global.hero.mana -= ability.mana_cost;
    ability.effect();
    
    // Устанавливаем перезарядку
    set_ability_cooldown(ability_id, ability.cooldown);
    
    return true;
}

// Получить объект способности по ID
function get_ability(ability_id) {
    for (var i = 0; i < array_length(global.abilities_database); i++) {
        if (global.abilities_database[i].id == ability_id) {
            return global.abilities_database[i];
        }
    }
    return -1;
}

// Проверить, изучена ли способность
function ability_is_learned(ability_id) {
    for (var i = 0; i < array_length(global.hero_abilities); i++) {
        if (global.hero_abilities[i] == ability_id) {
            return true;
        }
    }
    return false;
}

// Установить перезарядку для способности
function set_ability_cooldown(ability_id, cooldown) {
    ds_map_replace(global.ability_cooldowns, ability_id, cooldown);
}

// Получить оставшееся время перезарядки
function get_ability_cooldown(ability_id) {
    if (ds_map_exists(global.ability_cooldowns, ability_id)) {
        return ds_map_find_value(global.ability_cooldowns, ability_id);
    }
    return 0;
}

// Обновление перезарядок способностей
function update_abilities_cooldowns() {
    if (!variable_global_exists("ability_cooldowns")) return;
    
    var ability_id = ds_map_find_first(global.ability_cooldowns);
    while (!is_undefined(ability_id)) {
        var current_cooldown = ds_map_find_value(global.ability_cooldowns, ability_id);
        if (current_cooldown > 0) {
            ds_map_replace(global.ability_cooldowns, ability_id, current_cooldown - 1);
        }
        ability_id = ds_map_find_next(global.ability_cooldowns, ability_id);
    }
}

// Обновление баффов от способностей
function update_ability_buffs() {
    if (!variable_global_exists("ability_buffs")) return;
    
    for (var i = array_length(global.ability_buffs) - 1; i >= 0; i--) {
        var buff = global.ability_buffs[i];
        if (global.frame_count - buff.start_time >= buff.duration) {
            remove_ability_buff_effect(buff);
            array_delete(global.ability_buffs, i, 1);
            add_notification("Действие " + buff.name + " закончилось");
        }
    }
}

// Применение эффекта баффа от способности
function apply_ability_buff_effect(buff) {
    if (!variable_global_exists("hero")) return;
    if (!variable_struct_exists(global.hero, "ability_bonuses")) {
        global.hero.ability_bonuses = {};
    }
    
    switch(buff.stat_type) {
        case "strength":
            if (!variable_struct_exists(global.hero.ability_bonuses, "strength")) {
                global.hero.ability_bonuses.strength = 0;
            }
            global.hero.ability_bonuses.strength += buff.value;
            break;
        case "defense":
            if (!variable_struct_exists(global.hero.ability_bonuses, "defense")) {
                global.hero.ability_bonuses.defense = 0;
            }
            global.hero.ability_bonuses.defense += buff.value;
            break;
    }
}

// Снятие эффекта баффа от способности
function remove_ability_buff_effect(buff) {
    if (!variable_global_exists("hero")) return;
    if (!variable_struct_exists(global.hero, "ability_bonuses")) {
        return;
    }
    
    switch(buff.stat_type) {
        case "strength":
            if (variable_struct_exists(global.hero.ability_bonuses, "strength")) {
                global.hero.ability_bonuses.strength -= buff.value;
            }
            break;
        case "defense":
            if (variable_struct_exists(global.hero.ability_bonuses, "defense")) {
                global.hero.ability_bonuses.defense -= buff.value;
            }
            break;
    }
}

// Восстановление маны
function update_mana_regeneration() {
    if (!variable_global_exists("hero")) return;
    
    if (global.hero.mana < global.hero.max_mana) {
        global.hero.mana += global.hero.mana_regen / 60; // Восстановление в кадр
        global.hero.mana = min(global.hero.mana, global.hero.max_mana);
    }
}

// Получить общую силу с учетом баффов от способностей
function get_total_strength() {
    if (!variable_global_exists("hero")) return 0;
    
    var base_strength = global.hero.strength + global.hero.equipment_bonuses.strength;
    var ability_bonus = variable_struct_exists(global.hero, "ability_bonuses") && variable_struct_exists(global.hero.ability_bonuses, "strength") 
        ? global.hero.ability_bonuses.strength 
        : 0;
    return base_strength + ability_bonus;
}

// Получить общую защиту с учетом баффов от способностей
function get_total_defense() {
    if (!variable_global_exists("hero")) return 0;
    
    var base_defense = global.hero.equipment_bonuses.defense;
    var ability_bonus = variable_struct_exists(global.hero, "ability_bonuses") && variable_struct_exists(global.hero.ability_bonuses, "defense") 
        ? global.hero.ability_bonuses.defense 
        : 0;
    var passive_bonus = variable_struct_exists(global.hero, "passive_defense_bonus")
        ? base_defense * global.hero.passive_defense_bonus
        : 0;
    return base_defense + ability_bonus + passive_bonus;
}

// Обработка двойной атаки
function handle_double_attack() {
    if (!variable_global_exists("hero")) return false;
    
    if (global.hero.next_attack_double) {
        global.hero.next_attack_double = false;
        return true;
    }
    return false;
}

// Обработка возрождения Феникса
function handle_phoenix_rebirth() {
    if (!variable_global_exists("hero")) return false;
    
    if (global.hero.phoenix_rebirth_available && global.hero.health <= 0) {
        global.hero.health = global.hero.max_health * 0.5;
        global.hero.phoenix_rebirth_available = false;
        add_notification("🔥 Феникс возродил героя!");
        return true;
    }
    return false;
}