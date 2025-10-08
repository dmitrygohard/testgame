// scr_buff_system.gml

// Типы бафов
global.BUFF_TYPES = {
    STRENGTH: 0,      // + к силе
    DEFENSE: 1,       // + к защите  
    INTELLIGENCE: 2,  // + к интеллекту
    HEALTH: 3,        // + к здоровью
    SUCCESS: 4,       // + к шансу успеха
    GOLD: 5,          // + к золоту
    SPEED: 6,         // + к скорости экспедиции
    LUCK: 7,          // + к удаче (шанс двойной награды)
    TEMP_STRENGTH: 8,
    TEMP_AGILITY: 9,
    TEMP_INTELLIGENCE: 10,
    TEMP_DEFENSE: 11
};

// Базы данных бафов
global.buff_database = [
    {   // Сила
        name: "⚔️ Благословение Силы",
        description: "Увеличивает силу героя",
        icon: "💪",
        type: global.BUFF_TYPES.STRENGTH,
        value: 5,
        duration: 1, // на одну экспедицию
        color: make_color_rgb(255, 100, 100)
    },
    {   // Защита
        name: "🛡️ Магический Щит",
        description: "Увеличивает защиту героя", 
        icon: "🔰",
        type: global.BUFF_TYPES.DEFENSE,
        value: 8,
        duration: 1,
        color: make_color_rgb(100, 150, 255)
    },
    {   // Интеллект
        name: "📚 Мудрость Древних",
        description: "Увеличивает интеллект героя",
        icon: "🧠", 
        type: global.BUFF_TYPES.INTELLIGENCE,
        value: 6,
        duration: 1,
        color: make_color_rgb(150, 100, 255)
    },
    {   // Здоровье
        name: "❤️ Жизненная Энергия",
        description: "Увеличивает максимальное здоровье",
        icon: "💓",
        type: global.BUFF_TYPES.HEALTH,
        value: 25,
        duration: 1,
        color: make_color_rgb(255, 50, 50)
    },
    {   // Шанс успеха
        name: "🎯 Безошибочная Тактика",
        description: "Увеличивает шанс успеха экспедиции",
        icon: "⭐",
        type: global.BUFF_TYPES.SUCCESS,
        value: 15,
        duration: 1, 
        color: make_color_rgb(255, 255, 100)
    },
    {   // Золото
        name: "💰 Золотой Блеск",
        description: "Увеличивает получаемое золото",
        icon: "💎",
        type: global.BUFF_TYPES.GOLD,
        value: 20,
        duration: 1,
        color: make_color_rgb(255, 215, 0)
    },
    {   // Скорость
        name: "⚡ Стремительный Марш",
        description: "Ускоряет завершение экспедиции",
        icon: "🏃",
        type: global.BUFF_TYPES.SPEED,
        value: 0.8, // множитель времени
        duration: 1,
        color: make_color_rgb(100, 255, 100)
    },
    {   // Удача
        name: "🍀 Удача Авантюриста", 
        description: "Шанс получить двойную награду",
        icon: "🎲",
        type: global.BUFF_TYPES.LUCK,
        value: 25, // процент шанса
        duration: 1,
        color: make_color_rgb(200, 100, 255)
    }
];

// Активные бафы
global.active_buffs = [];

// Состояние системы бафов
global.buff_system = {
    is_applying_buffs: false,
    current_buff_index: 0,
    buff_timer: 0,
    buff_duration: 60, // Уменьшено до 1 секунды (60 кадров)
    selected_buffs: [],
    pending_expedition_difficulty: -1,
    waiting_for_expedition_start: false // НОВОЕ: флаг ожидания запуска экспедиции
};

// Инициализация системы бафов
function init_buff_system() {
    global.active_buffs = [];
    global.buff_system.is_applying_buffs = false;
    global.buff_system.current_buff_index = 0;
    global.buff_system.buff_timer = 0;
    global.buff_system.selected_buffs = [];
    global.buff_system.pending_expedition_difficulty = -1;
    global.buff_system.waiting_for_expedition_start = false;
}

/// @function clone_array(source_array)
/// @description Глубокое копирование массивов для структур бафов
function clone_array(source_array) {
    if (is_undefined(source_array)) return source_array;

    var len = array_length(source_array);
    var result = array_create(len);

    for (var i = 0; i < len; i++) {
        var value = source_array[i];

        if (is_array(value)) {
            value = clone_array(value);
        } else if (is_struct(value)) {
            value = clone_struct(value);
        }

        result[i] = value;
    }

    return result;
}

/// @function clone_struct(source_struct)
/// @description Глубокое копирование структур (бафов)
function clone_struct(source_struct) {
    if (is_undefined(source_struct)) return source_struct;

    var names = variable_struct_get_names(source_struct);
    var result = {};

    for (var i = 0; i < array_length(names); i++) {
        var key = names[i];
        var value = variable_struct_get(source_struct, key);

        if (is_array(value)) {
            value = clone_array(value);
        } else if (is_struct(value)) {
            value = clone_struct(value);
        }

        variable_struct_set(result, key, value);
    }

    return result;
}

// Функция для определения количества бафов от помощниц
function get_buff_count_from_companions() {
    var total_buffs = 0;
    
    for (var i = 0; i < array_length(global.companions); i++) {
        var companion = global.companions[i];
        if (companion.unlocked && !companion.training) {
            // Каждый ранг дает +1 баф
            total_buffs += (companion.rank + 1);
        }
    }
    
    // Ограничиваем максимум 3 бафами
    return min(total_buffs, 3);
}

// Вспомогательная функция для получения среднего уровня помощниц
function get_average_companion_level() {
    var total_level = 0;
    var count = 0;
    
    for (var i = 0; i < array_length(global.companions); i++) {
        if (global.companions[i].unlocked) {
            total_level += global.companions[i].level;
            count++;
        }
    }
    
    return count > 0 ? total_level / count : 0;
}

// Обновленная функция получения случайных бафов
function select_random_buffs() {
    var num_buffs = get_buff_count_from_companions();
    global.buff_system.selected_buffs = [];
    
    // Создаем копию доступных бафов
    var available_buffs = [];
    for (var i = 0; i < array_length(global.buff_database); i++) {
        array_push(available_buffs, clone_struct(global.buff_database[i]));
    }
    
    for (var i = 0; i < num_buffs; i++) {
        if (array_length(available_buffs) == 0) break;
        
        var random_index = irandom(array_length(available_buffs) - 1);
        var selected_buff = clone_struct(available_buffs[random_index]);

        // Усиливаем бафы в зависимости от среднего уровня помощниц - БЕЗ ОГРАНИЧЕНИЙ
        var avg_level = get_average_companion_level();
        selected_buff.value = selected_buff.value * (1 + avg_level * 0.1);

        // Применяем безопасные значения ТОЛЬКО для скорости
        if (selected_buff.type == global.BUFF_TYPES.SPEED) {
            selected_buff.value = clamp(selected_buff.value, 0.5, 0.9);
        }
        
        array_push(global.buff_system.selected_buffs, selected_buff);
        array_delete(available_buffs, random_index, 1);
    }
    
    return global.buff_system.selected_buffs;
}
// Функция применения текущего бафа
function apply_current_buff() {
    if (global.buff_system.current_buff_index < array_length(global.buff_system.selected_buffs)) {
        var buff = global.buff_system.selected_buffs[global.buff_system.current_buff_index];
        array_push(global.active_buffs, buff);
        show_debug_message("Applying buff index: " + string(global.buff_system.current_buff_index));
        
        // Применяем эффект бафа
        apply_buff_effect(buff);
        
        add_notification("Наложен баф: " + buff.name);
        global.buff_system.current_buff_index++;
        global.buff_system.buff_timer = 0;
        
        return true;
    }
    return false;
}

// Функция применения эффекта бафа к герою
function apply_buff_effect(buff) {
    // Применяем безопасное значение (только для скорости)
    var safe_buff = apply_safe_buff_value(buff);
    // Обновляем исходную структуру, чтобы обратные эффекты использовали безопасное значение
    buff.value = safe_buff.value;

    // Инициализируем свойства equipment_bonuses если они отсутствуют
    if (!variable_struct_exists(global.hero, "equipment_bonuses")) {
        global.hero.equipment_bonuses = {};
    }

    if (!variable_struct_exists(global.hero.equipment_bonuses, "strength")) global.hero.equipment_bonuses.strength = 0;
    if (!variable_struct_exists(global.hero.equipment_bonuses, "defense")) global.hero.equipment_bonuses.defense = 0;
    if (!variable_struct_exists(global.hero.equipment_bonuses, "intelligence")) global.hero.equipment_bonuses.intelligence = 0;
    if (!variable_struct_exists(global.hero.equipment_bonuses, "max_health")) global.hero.equipment_bonuses.max_health = 0;
    switch(safe_buff.type) {
        case global.BUFF_TYPES.STRENGTH:
            global.hero.equipment_bonuses.strength += safe_buff.value; // Прогрессивное стакание
            break;
        case global.BUFF_TYPES.DEFENSE:
            global.hero.equipment_bonuses.defense += safe_buff.value; // Прогрессивное стакание
            break;
        case global.BUFF_TYPES.INTELLIGENCE:
            global.hero.equipment_bonuses.intelligence += safe_buff.value; // Прогрессивное стакание
            break;
        case global.BUFF_TYPES.HEALTH:
            global.hero.equipment_bonuses.max_health += safe_buff.value; // Прогрессивное стакание
            update_hero_max_health();
            break;
        // Скорость, успех, золото и удача обрабатываются в других системах
    }
}


// Функция обновления системы бафов
function update_buff_system() {
    if (global.buff_system.is_applying_buffs) {
        global.buff_system.buff_timer++;
        show_debug_message("Таймер баффа: " + string(global.buff_system.buff_timer) + "/" + string(global.buff_system.buff_duration));
        
        // Каждую секунду применяем новый баф
        if (global.buff_system.buff_timer >= global.buff_system.buff_duration) {
            show_debug_message("Пытаемся применить бафф №" + string(global.buff_system.current_buff_index));
            if (!apply_current_buff()) {
                // Все бафы применены - переходим в режим ожидания запуска экспедиции
                global.buff_system.is_applying_buffs = false;
                global.buff_system.waiting_for_expedition_start = true;
                add_notification("Все баффы применены! Экспедиция начнется в следующем кадре...");
                
                show_debug_message("Все бафы применены, ожидаем запуска экспедиции");
            }
        }
    } else if (global.buff_system.waiting_for_expedition_start) {
        // Запускаем экспедицию в следующем кадре после применения всех бафов
        show_debug_message("Запускаем экспедицию после бафов: " + string(global.buff_system.pending_expedition_difficulty));
        
        if (global.buff_system.pending_expedition_difficulty != -1) {
            start_expedition_direct(global.buff_system.pending_expedition_difficulty);
            global.buff_system.pending_expedition_difficulty = -1;
        }
        
        global.buff_system.waiting_for_expedition_start = false;
        add_notification("Экспедиция начинается!");
    }
    
    // Обновляем экспедицию, даже если применяются бафы (но только если экспедиция активна)
    if (global.expedition.active && !global.buff_system.is_applying_buffs && !global.buff_system.waiting_for_expedition_start) {
        update_expedition();
    }
}
// scr_buff_system.gml - обновляем start_expedition_direct

function start_expedition_direct(difficulty_index) {
    show_debug_message("=== start_expedition_direct вызвана ===");
    
    if (!global.expedition.active && difficulty_index >= 0 && difficulty_index < array_length(global.expedition_difficulties)) {
        var diff = global.expedition_difficulties[difficulty_index];
        
        global.expedition.active = true;
        global.expedition.progress = 0;
        global.expedition.duration = diff.duration;
        global.expedition.difficulty = difficulty_index;
        global.expedition.boss_index = diff.boss;
        global.expedition.success_chance = calculate_success_chance(difficulty_index);
        
        // Применяем модификаторы от бафов
        apply_buff_modifiers_to_expedition();
        
        // ПРИМЕНЯЕМ БАФЫ ОТ ПРЕДМЕТОВ ЭКИПИРОВКИ
        if (variable_global_exists("apply_companion_item_buffs_to_expedition")) {
            apply_companion_item_buffs_to_expedition();
        }

        if (variable_global_exists("equipment_set_effects") && is_struct(global.equipment_set_effects)) {
            var set_effects = global.equipment_set_effects;
            if (set_effects.speed_multiplier != 1.0) {
                var clamped_speed = clamp(set_effects.speed_multiplier, 0.25, 1.0);
                global.expedition.duration = max(60, round(global.expedition.duration * clamped_speed));
            }

            if (set_effects.success_bonus != 0) {
                global.expedition.success_chance = clamp(global.expedition.success_chance + set_effects.success_bonus, 5, 95);
            }
        }

        add_notification("Экспедиция '" + diff.name + "' началась!");

        show_debug_message("Экспедиция успешно запущена: " + diff.name + ", длительность: " + string(global.expedition.duration));
    } else {
        show_debug_message("Ошибка запуска экспедиции: active=" + string(global.expedition.active) + ", difficulty_index=" + string(difficulty_index));
    }
}

// Функция снятия всех бафов после экспедиции
function remove_all_buffs() {
    // Снимаем эффекты бафов
    for (var i = 0; i < array_length(global.active_buffs); i++) {
        var buff = global.active_buffs[i];
        remove_buff_effect(buff);
    }
    
    global.active_buffs = [];
    add_notification("Действие бафов закончилось");
}

// Функция снятия эффекта конкретного бафа
function remove_buff_effect(buff) {
    // Инициализируем свойства equipment_bonuses если они отсутствуют
    if (!variable_struct_exists(global.hero, "equipment_bonuses")) {
        return;
    }
    
    switch(buff.type) {
        case global.BUFF_TYPES.STRENGTH:
            if (variable_struct_exists(global.hero.equipment_bonuses, "strength")) {
                global.hero.equipment_bonuses.strength -= buff.value;
            }
            break;
        case global.BUFF_TYPES.DEFENSE:
            if (variable_struct_exists(global.hero.equipment_bonuses, "defense")) {
                global.hero.equipment_bonuses.defense -= buff.value;
            }
            break;
        case global.BUFF_TYPES.INTELLIGENCE:
            if (variable_struct_exists(global.hero.equipment_bonuses, "intelligence")) {
                global.hero.equipment_bonuses.intelligence -= buff.value;
            }
            break;
        case global.BUFF_TYPES.HEALTH:
            if (variable_struct_exists(global.hero.equipment_bonuses, "max_health")) {
                global.hero.equipment_bonuses.max_health -= buff.value;
                update_hero_max_health();
            }
            break;
    }
}

// Функция получения модификатора от бафов для расчета характеристик
function get_buff_modifier(buff_type) {
    var modifier = 0;
    var multiplier = 1;
    
    for (var i = 0; i < array_length(global.active_buffs); i++) {
        var buff = global.active_buffs[i];
        if (buff.type == buff_type) {
            if (buff_type == global.BUFF_TYPES.SPEED) {
                // ТОЛЬКО для скорости используем безопасный множитель
                var speed_value = clamp(buff.value, 0.1, 0.9);
                multiplier *= speed_value;
            } else {
                // Для всех остальных бафов - прогрессивное стакание без ограничений
                modifier += buff.value;
            }
        }
    }
    
    return { additive: modifier, multiplicative: multiplier };
}
// Функция для отрисовки процесса наложения бафов
function draw_buff_application(x, y, width, height) {
    var center_x = x + width / 2;
    var center_y = y + height / 2;
    
    draw_set_color(ui_text);
    draw_set_halign(fa_center);
    
    // Заголовок
    draw_text(center_x, y + 30, "🎪 ПОДГОТОВКА К ЭКСПЕДИЦИИ");
    draw_set_color(ui_text_secondary);
    draw_text(center_x, y + 55, "Помощницы накладывают магические бафы...");
    
    // Прогресс бафов
    var total_buffs = array_length(global.buff_system.selected_buffs);
    var current_buff = global.buff_system.current_buff_index;
    
    // Таймер текущего бафа
    var progress = global.buff_system.buff_timer / global.buff_system.buff_duration;
    
    // Анимация магического круга
    draw_magic_circle(center_x, center_y, progress);
    
    // Отображение текущего применяемого бафа
    if (current_buff < total_buffs) {
        var buff = global.buff_system.selected_buffs[current_buff];
        
        // Иконка и название бафа
        draw_set_color(buff.color);
        draw_text(center_x, center_y - 60, buff.icon + " " + buff.name);
        
        draw_set_color(ui_text);
        draw_text(center_x, center_y - 30, buff.description);
        
        // Прогресс-бар применения бафа
        var bar_width = 200;
        var bar_x = center_x - bar_width / 2;
        var bar_y = center_y + 40;
        
        draw_set_color(ui_bg_dark);
        draw_rectangle(bar_x, bar_y, bar_x + bar_width, bar_y + 15, false);
        
        draw_set_color(buff.color);
        draw_rectangle(bar_x, bar_y, bar_x + bar_width * progress, bar_y + 15, false);
        
        draw_set_color(ui_border_color);
        draw_rectangle(bar_x, bar_y, bar_x + bar_width, bar_y + 15, true);
    }
    
    // Отображение уже примененных бафов
    draw_set_color(ui_text_secondary);
    draw_text(center_x, center_y + 70, "Примененные бафы:");
    
    var buffs_y = center_y + 90;
    for (var i = 0; i < current_buff; i++) {
        if (i < array_length(global.active_buffs)) {
            var applied_buff = global.active_buffs[i];
            draw_set_color(applied_buff.color);
            draw_text(center_x, buffs_y, applied_buff.icon + " " + applied_buff.name);
            buffs_y += 20;
        }
    }
    
    draw_set_halign(fa_left);
}

// Функция отрисовки магического круга
function draw_magic_circle(x, y, progress) {
    var base_radius = 50;
    var pulse_radius = base_radius + sin(global.frame_count * 0.2) * 10;
    
    // Внешний круг
    draw_set_color(make_color_rgb(97, 175, 239));
    draw_set_alpha(0.3);
    draw_circle(x, y, pulse_radius, false);
    draw_set_alpha(1);
    
    // Вращающиеся символы
    var symbols = ["✨", "⭐", "🔮", "💫", "🌟"];
    for (var i = 0; i < array_length(symbols); i++) {
        var angle = (global.frame_count * 0.1) + (i * (360 / array_length(symbols)));
        var symbol_radius = base_radius + 20;
        var symbol_x = x + lengthdir_x(symbol_radius, angle);
        var symbol_y = y + lengthdir_y(symbol_radius, angle);
        
        draw_set_color(ui_text);
        draw_set_halign(fa_center);
        draw_text(symbol_x, symbol_y, symbols[i]);
    }
    
    // Центральная иконка
    draw_set_color(ui_highlight);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(x, y, "⚡");
    draw_set_valign(fa_top);
    draw_set_halign(fa_left);
}

// Функция для получения читаемого описания бафа
function get_buff_display_text(buff) {
    var value_text = "";
    
    switch(buff.type) {
        case global.BUFF_TYPES.STRENGTH:
        case global.BUFF_TYPES.DEFENSE:
        case global.BUFF_TYPES.INTELLIGENCE:
        case global.BUFF_TYPES.HEALTH:
            value_text = "+" + string(round(buff.value)); // Без ограничений
            break;
            
        case global.BUFF_TYPES.SUCCESS:
        case global.BUFF_TYPES.GOLD:
        case global.BUFF_TYPES.LUCK:
            value_text = "+" + string(round(buff.value)) + "%"; // Без ограничений
            break;
            
        case global.BUFF_TYPES.SPEED:
            // Для скорости гарантируем положительный процент
            var safe_value = clamp(buff.value, 0.1, 0.9);
            var acceleration_percent = (1 - safe_value) * 100;
            value_text = "-" + string(round(max(0, acceleration_percent))) + "% времени";
            break;
            
        default:
            value_text = "+" + string(round(buff.value)); // Без ограничений
    }
    
    return value_text;
}
// Функция для получения цвета бафа
function get_buff_color(buff) {
    return buff.color;
}

// Функция снятия эффекта временного бафа
function remove_temp_buff_effect(buff) {
    if (!variable_struct_exists(global.hero, "equipment_bonuses")) {
        return;
    }
    
    switch(buff.type) {
        case global.BUFF_TYPES.TEMP_STRENGTH:
            if (variable_struct_exists(global.hero.equipment_bonuses, "strength")) {
                global.hero.equipment_bonuses.strength -= buff.value;
            }
            break;
        case global.BUFF_TYPES.TEMP_AGILITY:
            if (variable_struct_exists(global.hero.equipment_bonuses, "agility")) {
                global.hero.equipment_bonuses.agility -= buff.value;
            }
            break;
        case global.BUFF_TYPES.TEMP_INTELLIGENCE:
            if (variable_struct_exists(global.hero.equipment_bonuses, "intelligence")) {
                global.hero.equipment_bonuses.intelligence -= buff.value;
            }
            break;
        case global.BUFF_TYPES.TEMP_DEFENSE:
            if (variable_struct_exists(global.hero.equipment_bonuses, "defense")) {
                global.hero.equipment_bonuses.defense -= buff.value;
            }
            break;
    }
    
    // Пересчитываем бонусы помощниц
    if (variable_global_exists("calculate_companion_bonuses")) {
        calculate_companion_bonuses();
    }
}

// Функция обновления временных бафов (вызывать каждый кадр)
function update_temp_buffs() {
    if (!variable_global_exists("temp_buffs")) return;

    for (var i = array_length(global.temp_buffs) - 1; i >= 0; i--) {
        var buff = global.temp_buffs[i];
        if (global.frame_count - buff.start_time >= buff.duration) {
            remove_temp_buff_effect(buff);
            array_delete(global.temp_buffs, i, 1);
            add_notification("Действие " + buff.name + " закончилось");
        }
    }
}
// Функция для безопасного применения значений бафов (только для скорости)
function apply_safe_buff_value(buff) {
    if (buff.type == global.BUFF_TYPES.SPEED) {
        var safe_buff = clone_struct(buff);
        safe_buff.value = clamp(buff.value, 0.5, 0.9);
        return safe_buff;
    }

    return buff;
}
// В конец файла scr_buff_system.gml добавляем:

// Глобальное объявление функций для доступа из других скриптов
global.start_buff_application = function(difficulty_index) {
    show_debug_message(">>> start_buff_application вызвана для сложности: " + string(difficulty_index));
    
    global.buff_system.is_applying_buffs = true;
    global.buff_system.current_buff_index = 0;
    global.buff_system.buff_timer = 0;
    global.buff_system.waiting_for_expedition_start = false;
    global.active_buffs = []; // Очищаем старые бафы
    
    // Сохраняем сложность экспедиции
    global.buff_system.pending_expedition_difficulty = difficulty_index;
    
    // Выбираем случайные бафы
    select_random_buffs();
    show_debug_message("Выбрано баффов: " + string(array_length(global.buff_system.selected_buffs)));
    
    add_notification("Помощницы начинают накладывать бафы...");
}

// Также объявляем другие важные функции глобально
global.get_buff_modifier = get_buff_modifier;
global.apply_buff_modifiers_to_expedition = apply_buff_modifiers_to_expedition;
global.remove_all_buffs = remove_all_buffs;
global.update_buff_system = update_buff_system;
/// @function get_rank_progress(companion_index)
/// @description Возвращает прогресс до следующего ранга
/// @param {real} companion_index - Индекс помощницы
/// @return {struct} {current: 0, required: 0, percent: 0}
function get_rank_progress(companion_index) {
    var companion = global.companions[companion_index];
    
    if (companion.rank >= companion.max_rank) {
        return {current: companion.level, required: companion.level, percent: 100};
    }
    
    var required_level = companion.rank_requirements[companion.rank];
    var progress = min(companion.level / required_level * 100, 100);
    
    return {
        current: companion.level,
        required: required_level,
        percent: progress
    };
}

/// @function get_rank_upgrade_cost(companion_index)
/// @description Возвращает стоимость повышения ранга
/// @param {real} companion_index - Индекс помощницы
/// @return {real} Стоимость повышения ранга в золоте
function get_rank_upgrade_cost(companion_index) {
    var companion = global.companions[companion_index];
    var base_cost = 500;
    return base_cost * (companion.rank + 1);
}

/// @function can_upgrade_rank(companion_index)
/// @description Проверяет, можно ли повысить ранг помощницы
/// @param {real} companion_index - Индекс помощницы
/// @return {bool} true если можно повысить ранг
function can_upgrade_rank(companion_index) {
    var companion = global.companions[companion_index];
    
    // Проверяем, что помощница разблокирована
    if (!companion.unlocked) {
        return false;
    }
    
    if (companion.rank >= companion.max_rank) {
        return false; // Уже максимальный ранг
    }
    
    var required_level = companion.rank_requirements[companion.rank];
    return companion.level >= required_level;
}

/// @function upgrade_companion_rank(companion_index)
/// @description Повышает ранг помощницы
/// @param {real} companion_index - Индекс помощницы
/// @return {bool} true если ранг успешно повышен
function upgrade_companion_rank(companion_index) {
    var companion = global.companions[companion_index];
    
    if (!can_upgrade_rank(companion_index)) {
        return false;
    }
    
    var cost = get_rank_upgrade_cost(companion_index);
    if (global.gold < cost) {
        add_notification("Недостаточно золота для повышения ранга!");
        return false;
    }
    
    global.gold -= cost;
    companion.rank++;
    
    // Применяем бонусы ранга
    apply_rank_bonuses(companion_index);
    
    add_notification(companion.name + " повышен до ранга " + string(companion.rank) + "!");
    return true;
}

/// @function apply_rank_bonuses(companion_index)
/// @description Применяет бонусы ранга помощницы
/// @param {real} companion_index - Индекс помощницы
function apply_rank_bonuses(companion_index) {
    var companion = global.companions[companion_index];
    
    // Базовые значения усиливаются с рангом
    var base_value = 0;
    
    switch(companion_index) {
        case 0: // Hepo
            base_value = 10 + (global.hero.strength * 0.2);
            switch(companion.rank) {
                case 1: companion.calculated_bonus = base_value * 1.5; break;
                case 2: companion.calculated_bonus = base_value * 2.0; break;
                case 3: companion.calculated_bonus = base_value * 2.5; break;
                default: companion.calculated_bonus = base_value; break; // ЗАЩИТА ОТ НЕИЗВЕСТНОГО РАНГА
            }
            break;
            
        case 1: // Fatty
            base_value = 15 + (global.hero.agility * 0.2);
            switch(companion.rank) {
                case 1: companion.calculated_bonus = base_value * 1.5; break;
                case 2: companion.calculated_bonus = base_value * 2.0; break;
                case 3: companion.calculated_bonus = base_value * 2.5; break;
                default: companion.calculated_bonus = base_value; break; // ЗАЩИТА ОТ НЕИЗВЕСТНОГО РАНГА
            }
            break;
            
        case 2: // Discipline
            base_value = 12 + (global.hero.intelligence * 0.2);
            switch(companion.rank) {
                case 1: companion.calculated_bonus = base_value * 1.5; break;
                case 2: companion.calculated_bonus = base_value * 2.0; break;
                case 3: companion.calculated_bonus = base_value * 2.5; break;
                default: companion.calculated_bonus = base_value; break; // ЗАЩИТА ОТ НЕИЗВЕСТНОГО РАНГА
            }
            break;
    }
    
    // Пересчитываем бонусы
    calculate_companion_bonuses();
}
function calculate_companion_bonuses() {
    if (!variable_global_exists("hero") || !variable_global_exists("companions")) {
        return;
    }
    
    // Базовые значения + зависимость от атрибутов героя
    var strength_factor = global.hero.strength * 0.3;
    var agility_factor = global.hero.agility * 0.3;
    var intelligence_factor = global.hero.intelligence * 0.3;
    
    for (var i = 0; i < array_length(global.companions); i++) {
        var companion = global.companions[i];
        var level_bonus = companion.level * 2; // Бонус от уровня
        
        switch(i) {
            case 0: // Hepo - зависит от СИЛЫ героя
                var hepo_bonus = 10 + level_bonus + strength_factor;
                companion.calculated_bonus = min(hepo_bonus, 50);
                companion.effect = "+" + string(floor(companion.calculated_bonus)) + "% к шансу успеха (Сила)";
                break;
                
            case 1: // Fatty - зависит от ЛОВКОСТИ героя  
                var fatty_bonus = 15 + level_bonus + agility_factor;
                companion.calculated_bonus = min(fatty_bonus, 60);
                companion.effect = "+" + string(floor(companion.calculated_bonus)) + "% к здоровью (Ловкость)";
                break;
                
            case 2: // Discipline - зависит от ИНТЕЛЛЕКТА героя
                var discipline_bonus = 12 + level_bonus + intelligence_factor;
                companion.calculated_bonus = min(discipline_bonus, 45);
                companion.effect = "+" + string(floor(companion.calculated_bonus)) + "% к золоту (Интеллект)";
                break;
        }
    }
}

function get_active_companion_bonuses() {
    var bonuses = {
        success_chance: 0,
        health: 0,
        gold: 0
    };
    
    if (!variable_global_exists("companions")) {
        return bonuses;
    }
    
    for (var i = 0; i < array_length(global.companions); i++) {
        var companion = global.companions[i];
        if (companion.unlocked && !companion.training) {
            switch(i) {
                case 0: // Hepo
                    bonuses.success_chance += companion.calculated_bonus;
                    break;
                case 1: // Fatty
                    bonuses.health += companion.calculated_bonus;
                    break;
                case 2: // Discipline
                    bonuses.gold += companion.calculated_bonus;
                    break;
            }
        }
    }
    
    return bonuses;
}

function refresh_companion_display() {
    calculate_companion_bonuses();
}
// scr_expedition_system.gml

// scr_expedition_system.gml
// 5 уровней сложности экспедиций
global.expedition_difficulties = [
    { 
        name: "Очень легкая", 
        level: 1, 
        reward_min: 50, 
        reward_max: 100, 
        duration: 300, 
        boss: -1,
        description: "Идеально для новичков. Без боссов."
    },
    { 
        name: "Легкая", 
        level: 2, 
        reward_min: 100, 
        reward_max: 200, 
        duration: 450, 
        boss: -1,
        description: "Простая экспедиция. Без боссов."
    },
    { 
        name: "Средняя", 
        level: 3, 
        reward_min: 200, 
        reward_max: 400, 
        duration: 600, 
        boss: 0, // Hepo
        description: "Первая встреча с боссом: Hepo"
    },
    { 
        name: "Сложная", 
        level: 4, 
        reward_min: 400, 
        reward_max: 800, 
        duration: 750, 
        boss: 1, // Fatty
        description: "Опасный босс: Fatty"
    },
    { 
        name: "Очень сложная", 
        level: 5, 
        reward_min: 800, 
        reward_max: 1600, 
        duration: 900, 
        boss: 2, // Discipline
        description: "Смертельно опасный босс: Discipline"
    }
];

// Инициализация экспедиции
if (!variable_global_exists("expedition")) {
    global.expedition = {
        active: false,
        progress: 0,
        duration: 0,
        difficulty: 0,
        boss_index: -1,
        success_chance: 0
    };
}

function start_expedition(difficulty_index) {
    show_debug_message("=== start_expedition вызвана ===");
    
    // Проверяем, доступна ли выбранная сложность
    if (difficulty_index > global.max_available_difficulty) {
        add_notification("Эта сложность еще не доступна! Сначала завершите предыдущие.");
        return;
    }
    
    if (!global.expedition.active && difficulty_index >= 0 && difficulty_index < array_length(global.expedition_difficulties)) {
        // Если есть разблокированные помощницы, применяем бафы
        var has_companions = false;
        for (var i = 0; i < array_length(global.companions); i++) {
            if (global.companions[i].unlocked && !global.companions[i].training) {
                has_companions = true;
                break;
            }
        }
        
        if (has_companions && array_length(global.active_buffs) == 0) {
            // Запускаем процесс наложения бафов через глобальную функцию
            show_debug_message("Запускаем систему бафов для экспедиции сложности: " + string(difficulty_index));
            
            // Безопасный вызов - проверяем существование функции
            if (variable_global_exists("start_buff_application")) {
                global.start_buff_application(difficulty_index);
            } else {
                // Если функции нет, начинаем экспедицию напрямую
                show_debug_message("Функция start_buff_application не найдена, запускаем экспедицию напрямую");
                start_expedition_direct(difficulty_index);
            }
            return;
        }
        
        // Если бафы уже применены или помощниц нет, начинаем сразу
        start_expedition_direct(difficulty_index);
    }
}



// Применение модификаторов бафов к экспедиции
function apply_buff_modifiers_to_expedition() {
    var speed_mod = get_buff_modifier(global.BUFF_TYPES.SPEED);
    if (speed_mod.multiplicative != 1) {
        // ТОЛЬКО для скорости гарантируем корректный множитель
        var speed_multiplier = clamp(speed_mod.multiplicative, 0.1, 0.95);
        global.expedition.duration = round(global.expedition.duration * speed_multiplier);
    }
    
    // Для успеха применяем без ограничений (ограничение будет в calculate_success_chance)
    var success_mod = get_buff_modifier(global.BUFF_TYPES.SUCCESS);
    if (success_mod.additive != 0) {
        global.expedition.success_chance += success_mod.additive;
    }
}
function calculate_success_chance(difficulty_index) {
    if (!variable_global_exists("expedition_difficulties") || difficulty_index < 0 || difficulty_index >= array_length(global.expedition_difficulties)) {
        return 50;
    }
    
    var base_chance = 95 - (difficulty_index * 15);
    
    // Бонусы от характеристик героя
    var hero_bonus = 0;
    if (variable_global_exists("hero")) {
        hero_bonus = (global.hero.strength + global.hero.agility + global.hero.intelligence) * 0.1;
    }
    
    // Бонусы от помощниц
    var companion_bonus = 0;
    if (variable_global_exists("get_active_companion_bonuses")) {
        var companion_bonuses = get_active_companion_bonuses();
        companion_bonus = companion_bonuses.success_chance;
    }
    
    // Бонусы от баффов
    var buff_bonus = 0;
    if (variable_global_exists("get_buff_modifier")) {
        var success_buff = get_buff_modifier(global.BUFF_TYPES.SUCCESS);
        buff_bonus = success_buff.additive;
    }
    
    var total_chance = base_chance + hero_bonus + companion_bonus + buff_bonus;
    return clamp(total_chance, 5, 95);
}
function update_expedition() {
    if (global.expedition.active) {
        global.expedition.progress++;
        
        // Даем опыт помощницам каждые 10 секунд экспедиции
        if (global.expedition.progress mod 600 == 0) { // 600 кадров = 10 секунд
            add_companion_exp_in_expedition();
        }
        
        if (global.expedition.progress >= global.expedition.duration) {
            complete_expedition();
        }
    }
}

// scr_expedition_system.gml - обновляем функцию complete_expedition

function complete_expedition() {
    var success = random(100) < global.expedition.success_chance;
    var diff = global.expedition_difficulties[global.expedition.difficulty];
    
    // Базовые награды
    var gold_reward = irandom_range(diff.reward_min, diff.reward_max);
    var exp_reward = 25 * (global.expedition.difficulty + 1);

    var equipment_effects = undefined;
    if (variable_global_exists("equipment_set_effects")) {
        equipment_effects = global.equipment_set_effects;
    }

    // Проверяем двойную атаку
    var is_double_attack = handle_double_attack();
    if (is_double_attack) {
        gold_reward *= 2;
        exp_reward *= 2;
        add_notification("⚔️ Двойной удар! Награда удвоена!");
    }
    
    // Применяем множитель награды от Концепции Победы
    gold_reward = floor(gold_reward * global.expedition_reward_multiplier);
    exp_reward = floor(exp_reward * global.expedition_reward_multiplier);

    if (is_struct(equipment_effects)) {
        gold_reward = floor(gold_reward * equipment_effects.reward_multiplier);
        exp_reward = floor(exp_reward * equipment_effects.reward_multiplier);
    }

    // Бонус от бафов и помощниц
    var gold_mod = get_buff_modifier(global.BUFF_TYPES.GOLD);
    gold_reward = gold_reward * (1 + gold_mod.additive / 100);

    var companion_bonuses = get_active_companion_bonuses();
    gold_reward = gold_reward * (1 + companion_bonuses.gold / 100);

    // БАФ ОТ ПРЕДМЕТОВ: Дисциплины (дополнительный бонус к золоту)
    var discipline_item_buff = get_companion_buff_modifier("discipline_gold");
    gold_reward = gold_reward * (1 + discipline_item_buff / 100);

    if (variable_struct_exists(global.hero.equipment_bonuses, "gold_bonus")) {
        gold_reward = gold_reward * (1 + global.hero.equipment_bonuses.gold_bonus / 100);
    }

    // БАФ ОТ ПРЕДМЕТОВ: Проверка удвоения награды
    var reward_multiplier = check_double_rewards_chance();
    gold_reward = floor(gold_reward * reward_multiplier);
    exp_reward = floor(exp_reward * reward_multiplier);
    
    if (success) {
        global.gold += gold_reward;
        add_hero_exp(exp_reward);
        
        // Урон герою даже при успехе
        var damage = irandom_range(5, 15) * (global.expedition.difficulty + 1);
        var actual_damage = hero_take_damage(damage);
        
        // Шанс выпадения предмета с учетом множителя
        var item_chance = 10 + (global.expedition.difficulty * 15);
        var drop_multiplier = global.expedition_reward_multiplier;
        if (is_struct(equipment_effects)) {
            drop_multiplier *= equipment_effects.reward_multiplier;
        }

        if (random(100) < item_chance * drop_multiplier) {
            var item_id = get_random_expedition_item(global.expedition.difficulty);
            if (AddItemToInventory(item_id, 1)) {
                var item_data = ds_map_find_value(global.ItemDB, item_id);
                add_notification("Найден предмет: " + item_data[? "name"]);
            }
        }
        
        // Разблокировка помощницы при победе над боссом
        if (global.expedition.boss_index != -1 && !global.companions[global.expedition.boss_index].unlocked) {
            global.companions[global.expedition.boss_index].unlocked = true;
            global.arenas[global.expedition.boss_index].unlocked = true;
            add_notification("Помощница " + global.companions[global.expedition.boss_index].name + " присоединилась к отряду!");
        }
        
        // Открытие следующей сложности
        if (global.expedition.difficulty == global.max_available_difficulty) {
            global.max_available_difficulty = min(global.max_available_difficulty + 1, array_length(global.expedition_difficulties) - 1);
            if (global.max_available_difficulty < array_length(global.expedition_difficulties) - 1) {
                var next_diff = global.expedition_difficulties[global.max_available_difficulty];
                add_notification("Открыта новая сложность: " + next_diff.name + "!");
            }
        }
        
        // Опыт помощницам
        var companion_exp = 20 * (global.expedition.difficulty + 1);
        for (var i = 0; i < array_length(global.companions); i++) {
            var companion = global.companions[i];
            if (companion.unlocked && !companion.training) {
                add_companion_exp(i, companion_exp);
            }
        }
        
        add_notification("Экспедиция успешна! +" + string(floor(gold_reward)) + " золота, получено " + string(actual_damage) + " урона");

        // Авто-повтор для Эгиды и Гунгнира
        if (global.expedition_auto_repeat.enabled && global.expedition_auto_repeat.difficulties[global.expedition.difficulty]) {
            global.expedition_auto_repeat.completed_count++;
            add_notification("🔁 Авто-повтор: экспедиция запускается снова! (№" + string(global.expedition_auto_repeat.completed_count) + ")");
            start_expedition(global.expedition.difficulty);
            return; // Не снимаем бафы и не завершаем экспедицию
        }

        check_trophies_after_expedition(true, gold_reward, actual_damage);

    } else {
        var damage = irandom_range(20, 40) * (global.expedition.difficulty + 1);
        var actual_damage = hero_take_damage(damage);
        add_notification("Экспедиция провалилась! Получено " + string(actual_damage) + " урона");

        check_trophies_after_expedition(false, 0, actual_damage);
    }
    
    // Снимаем бафы после завершения экспедиции (только если не авто-повтор)
    if (!global.expedition_auto_repeat.enabled || !global.expedition_auto_repeat.difficulties[global.expedition.difficulty]) {
        if (variable_global_exists("remove_all_buffs")) {
            global.remove_all_buffs();
        } else {
            global.active_buffs = [];
        }
        global.expedition.active = false;
    }
}
// Обновляем функцию получения случайных предметов
function get_random_expedition_item(difficulty) {
    var available_items = [];
    
    var map = ds_map_create();
    var count = ds_map_size(global.ItemDB);
    var key = ds_map_find_first(global.ItemDB);
    
    for (var i = 0; i < count; i++) {
        var item = ds_map_find_value(global.ItemDB, key);
        var item_rarity = item[? "rarity"];
        if (item[? "type"] == global.ITEM_TYPE.TROPHY || item[? "item_class"] == "trophy") {
            key = ds_map_find_next(global.ItemDB, key);
            continue;
        }

        // Шанс выпадения предмета зависит от сложности и редкости
        var max_rarity = floor(difficulty / 2) + 1;
        if (item_rarity <= max_rarity) {
            // Учитываем вес редкости (более редкие предметы выпадают реже)
            var weight = 10 - (item_rarity * 2);
            for (var j = 0; j < weight; j++) {
                array_push(available_items, key);
            }
        }
        
        key = ds_map_find_next(global.ItemDB, key);
    }
    ds_map_destroy(map);
    
    if (array_length(available_items) > 0) {
        return available_items[irandom(array_length(available_items) - 1)];
    }
    
    return "health_potion"; // fallback
}
/// @function update_hero_max_health()
/// @description Пересчитывает максимальное здоровье героя с учетом бонусов
function update_hero_max_health() {
    var base_health = 100 + (global.hero.strength * 5);
    var bonus_health = global.hero.equipment_bonuses.max_health;
    
    // Бонус от Fatty к здоровью
    var companion_bonuses = get_active_companion_bonuses();
    var health_multiplier = 1 + (companion_bonuses.health / 100);
    
    global.hero.max_health = (base_health + bonus_health) * health_multiplier;
    
    // Не даем текущему здоровью превысить максимум
    if (global.hero.health > global.hero.max_health) {
        global.hero.health = global.hero.max_health;
    }
}

function hero_take_damage(damage_amount) {
    // Учитываем защиту от брони и бафов
    var defense = get_total_defense(); // Используем общую защиту с учетом способностей
    var actual_damage = max(1, damage_amount - defense * 0.5);
    
    global.hero.health -= actual_damage;
    
    if (global.hero.health <= 0) {
        // Проверяем возрождение Феникса
        if (!handle_phoenix_rebirth()) {
            global.hero.health = 0;
            global.hero.is_injured = true;
            add_notification("Герой тяжело ранен! Нужно лечение!");
        }
    } else if (global.hero.health < global.hero.max_health * 0.3) {
        add_notification("Герой сильно ранен! Здоровье: " + string(floor(global.hero.health)));
    }
    
    return actual_damage;
}

/// @function hero_heal(heal_amount)
/// @description Лечит героя
/// @param {real} heal_amount - Количество здоровья для восстановления
function hero_heal(heal_amount) {
    var old_health = global.hero.health;
    global.hero.health += heal_amount;
    
    if (global.hero.health > global.hero.max_health) {
        global.hero.health = global.hero.max_health;
    }
    
    var actual_heal = global.hero.health - old_health;
    
    // Снимаем статус ранения если здоровье выше 50%
    if (global.hero.health >= global.hero.max_health * 0.5) {
        global.hero.is_injured = false;
    }
    
    return actual_heal;
}

/// @function hero_rest()
/// @description Герой отдыхает и восстанавливает здоровье
function hero_rest() {
    if (!global.expedition.active && global.hero.health < global.hero.max_health) {
        var heal_amount = global.hero.max_health * 0.1; // 10% от максимума за отдых
        var actual_heal = hero_heal(heal_amount);
        
        add_notification("Герой отдыхает... +" + string(floor(actual_heal)) + " здоровья");
        
        // Если здоровье полностью восстановлено
        if (global.hero.health >= global.hero.max_health) {
            global.hero.health = global.hero.max_health;
            add_notification("Герой полностью отдохнул!");
        }
        
        return true;
    }
    return false;
}

// ОБНОВЛЯЕМ функцию use_health_potion для использования новой системы:

function use_health_potion() {
    // Теперь используем универсальную систему использования предметов
    return use_potion("health_potion");
}

/// @function update_health_system()
/// @description Обновляет систему здоровья (вызывать каждый шаг)
function update_health_system() {
    // Автоматическое восстановление здоровья при отдыхе
    if (!global.expedition.active && global.hero.health < global.hero.max_health) {
        global.hero.rest_timer++;
        
        // Восстанавливаем 1% здоровья каждые 5 секунд (при 60 FPS)
        if (global.hero.rest_timer >= 300) { // 300 кадров = 5 секунд
            hero_rest();
            global.hero.rest_timer = 0;
        }
    } else {
        global.hero.rest_timer = 0;
    }
}
// Функция для проверки и обновления экспедиции во время применения бафов
function update_expedition_during_buffs() {
    if (global.expedition.active && !global.buff_system.is_applying_buffs && !global.buff_system.waiting_for_expedition_start) {
        update_expedition();
    }
}

// scr_buff_system.gml - добавляем в конец файла

// Новая система бафов от предметов экипировки
global.companion_buff_items = [];

function update_companion_buff_system() {
    // Очищаем предыдущие бафы от предметов
    global.companion_buff_items = [];
    
    // Проверяем экипировку всех героев на предметы с бафами
    for (var hero_index = 0; hero_index < array_length(global.equipment_slots); hero_index++) {
        var equipment = global.equipment_slots[hero_index];
        var slot_names = variable_struct_get_names(equipment);
        
        for (var i = 0; i < array_length(slot_names); i++) {
            var item_id = variable_struct_get(equipment, slot_names[i]);
            if (item_id != -1) {
                var item_data = ds_map_find_value(global.ItemDB, item_id);
                if (item_data != -1) {
                    var companion_buff = item_data[? "companion_buff"];
                    if (!is_undefined(companion_buff)) {
                        // Добавляем баф в систему
                        var buff_power = item_data[? "buff_power"];
                        if (is_undefined(buff_power)) buff_power = 0;
                        
                        array_push(global.companion_buff_items, {
                            buff_type: companion_buff,
                            power: buff_power,
                            source_item: item_id,
                            hero_index: hero_index
                        });
                        
                        show_debug_message("Активирован баф от предмета: " + companion_buff + " с силой: " + string(buff_power));
                    }
                }
            }
        }
    }
}

function get_companion_buff_modifier(buff_type) {
    var total_power = 0;
    
    for (var i = 0; i < array_length(global.companion_buff_items); i++) {
        var buff_item = global.companion_buff_items[i];
        if (buff_item.buff_type == buff_type) {
            total_power += buff_item.power;
        }
    }
    
    return total_power;
}

// Функция применения бафов от предметов к экспедиции
function apply_companion_item_buffs_to_expedition() {
    if (!global.expedition.active) return;
    
    var success_buff = get_companion_buff_modifier("hepo_success");
    var health_buff = get_companion_buff_modifier("fatty_health");
    var gold_buff = get_companion_buff_modifier("discipline_gold");
    var all_buffs_boost = get_companion_buff_modifier("all_buffs_boost");
    var speed_buff = get_companion_buff_modifier("expedition_speed");
    
    // Применяем бафы к экспедиции
    if (success_buff > 0) {
        global.expedition.success_chance += success_buff;
        show_debug_message("Баф Хэпо: +" + string(success_buff) + "% к шансу успеха");
    }
    
    if (health_buff > 0) {
        // Баф Фэтти увеличивает здоровье отряда
        var health_multiplier = 1 + (health_buff / 100);
        global.hero.max_health *= health_multiplier;
        global.hero.health *= health_multiplier;
        show_debug_message("Баф Фэтти: +" + string(health_buff) + "% к здоровью");
    }
    
    if (gold_buff > 0) {
        // Баф Дисциплины увеличивает награду (применяется в complete_expedition)
        show_debug_message("Баф Дисциплины: +" + string(gold_buff) + "% к золоту");
    }
    
    if (speed_buff > 0) {
        global.expedition.duration = round(global.expedition.duration * (1 - speed_buff / 100));
        show_debug_message("Баф компаса: -" + string(speed_buff) + "% времени экспедиции");
    }
    
    if (all_buffs_boost > 0) {
        // Усиливаем все активные бафы
        for (var i = 0; i < array_length(global.active_buffs); i++) {
            global.active_buffs[i].value *= (1 + all_buffs_boost / 100);
        }
        show_debug_message("Баф Троицы: +" + string(all_buffs_boost) + "% ко всем бафам");
    }
}

// Функция проверки шанса удвоения награды
function check_double_rewards_chance() {
    var double_rewards_chance = get_companion_buff_modifier("double_rewards");
    if (double_rewards_chance > 0 && random(100) < double_rewards_chance) {
        add_notification("🎲 Удача! Награда удвоена благодаря Костям удачи!");
        return 2.0;
    }
    return 1.0;
}
// scr_buff_system.gml - добавляем в конец файла

// Функция применения эффекта временного бафа
function apply_temp_buff_effect(buff) {
    // ИНИЦИАЛИЗИРУЕМ СВОЙСТВА equipment_bonuses если они отсутствуют
    if (!variable_struct_exists(global.hero, "equipment_bonuses")) {
        global.hero.equipment_bonuses = {};
    }
    
    if (!variable_struct_exists(global.hero.equipment_bonuses, "strength")) global.hero.equipment_bonuses.strength = 0;
    if (!variable_struct_exists(global.hero.equipment_bonuses, "agility")) global.hero.equipment_bonuses.agility = 0;
    if (!variable_struct_exists(global.hero.equipment_bonuses, "intelligence")) global.hero.equipment_bonuses.intelligence = 0;
    if (!variable_struct_exists(global.hero.equipment_bonuses, "defense")) global.hero.equipment_bonuses.defense = 0;
    
    switch(buff.type) {
        case global.BUFF_TYPES.TEMP_STRENGTH:
            global.hero.equipment_bonuses.strength += buff.value;
            break;
        case global.BUFF_TYPES.TEMP_AGILITY:
            global.hero.equipment_bonuses.agility += buff.value;
            break;
        case global.BUFF_TYPES.TEMP_INTELLIGENCE:
            global.hero.equipment_bonuses.intelligence += buff.value;
            break;
        case global.BUFF_TYPES.TEMP_DEFENSE:
            global.hero.equipment_bonuses.defense += buff.value;
            break;
    }
    
    // Пересчитываем бонусы помощниц
    if (variable_global_exists("calculate_companion_bonuses")) {
        calculate_companion_bonuses();
    }
}

// Функция получения модификаторов от временных бафов
function get_temp_buff_modifier(buff_type) {
    var modifier = 0;
    
    if (!variable_global_exists("temp_buffs")) return modifier;
    
    for (var i = 0; i < array_length(global.temp_buffs); i++) {
        var buff = global.temp_buffs[i];
        if (buff.type == buff_type) {
            modifier += buff.value;
        }
    }
    
    return modifier;
}