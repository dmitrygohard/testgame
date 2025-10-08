// scr_level_system.gml
// Система уровней и прокачки персонажей

function init_level_system() {
    show_debug_message("Инициализация системы уровней...");
    
    // Инициализация героя, если еще не инициализирован
    if (!variable_global_exists("hero")) {
        init_main_hero();
    } else {
        // Гарантируем, что все необходимые свойства существуют
        if (!variable_struct_exists(global.hero, "max_level")) {
            global.hero.max_level = 100;
        }
        if (!variable_struct_exists(global.hero, "skill_points")) {
            global.hero.skill_points = 0;
        }
        if (!variable_struct_exists(global.hero, "exp_to_level")) {
            global.hero.exp_to_level = 100;
        }
    }
    
    // Инициализация помощниц, если еще не инициализированы
    if (!variable_global_exists("companions")) {
        init_companions();
    } else {
        // Для каждой помощницы добавляем max_level, если его нет
        for (var i = 0; i < array_length(global.companions); i++) {
            if (!variable_struct_exists(global.companions[i], "max_level")) {
                global.companions[i].max_level = 50;
            }
            if (!variable_struct_exists(global.companions[i], "exp_to_level")) {
                global.companions[i].exp_to_level = 50;
            }
        }
    }
    
    show_debug_message("Система уровней инициализирована");
}

function add_hero_exp(amount) {
    if (!variable_global_exists("hero")) {
        show_debug_message("Ошибка: Глобальная переменная 'hero' не существует!");
        return;
    }
    
    // Гарантируем существование всех свойств
    if (!variable_struct_exists(global.hero, "max_level")) global.hero.max_level = 100;
    if (!variable_struct_exists(global.hero, "exp")) global.hero.exp = 0;
    if (!variable_struct_exists(global.hero, "exp_to_level")) global.hero.exp_to_level = 100;
    if (!variable_struct_exists(global.hero, "level")) global.hero.level = 1;
    if (!variable_struct_exists(global.hero, "skill_points")) global.hero.skill_points = 0;
    
    global.hero.exp += amount;
    
    // Проверка повышения уровня с переносом лишнего опыта
    while (global.hero.exp >= global.hero.exp_to_level && global.hero.level < global.hero.max_level) {
        global.hero.exp -= global.hero.exp_to_level;
        global.hero.level++;
        global.hero.skill_points += 1;
        global.hero.exp_to_level = floor(global.hero.exp_to_level * 1.5);
        
        // Улучшение характеристик при уровне
        global.hero.strength += 2;
        global.hero.agility += 2;
        global.hero.intelligence += 2;
        global.hero.max_health = floor(global.hero.max_health * 1.2);
        global.hero.health = global.hero.max_health;
        
        add_notification("Уровень повышен! Теперь уровень " + string(global.hero.level));
    }
    
    // Проверка на достижение максимального уровня
    if (global.hero.level >= global.hero.max_level) {
        global.hero.exp = 0;
        global.hero.exp_to_level = 0;
        add_notification("Достигнут максимальный уровень!");
    }
}

function add_companion_exp(companion_index, amount) {
    if (!variable_global_exists("companions")) {
        show_debug_message("Ошибка: Глобальная переменная 'companions' не существует!");
        return;
    }
    
    if (companion_index < 0 || companion_index >= array_length(global.companions)) {
        show_debug_message("Ошибка: Неверный индекс помощницы: " + string(companion_index));
        return;
    }
    
    var companion = global.companions[companion_index];
    
    // Гарантируем существование всех свойств
    if (!variable_struct_exists(companion, "max_level")) companion.max_level = 50;
    if (!variable_struct_exists(companion, "exp")) companion.exp = 0;
    if (!variable_struct_exists(companion, "exp_to_level")) companion.exp_to_level = 50;
    if (!variable_struct_exists(companion, "level")) companion.level = 1;
    
    var old_level = companion.level;
    companion.exp += amount;
    
    // Проверка повышения уровня
    while (companion.exp >= companion.exp_to_level && companion.level < companion.max_level) {
        companion.exp -= companion.exp_to_level;
        companion.level++;
        companion.exp_to_level = floor(companion.exp_to_level * 1.6);
        
        // Улучшение здоровья помощницы
        companion.max_health += 5;
        companion.health = companion.max_health;
    }
    
    // Уведомляем только если уровень изменился
    if (companion.level > old_level) {
        add_notification(companion.name + " повысила уровень до " + string(companion.level));
    }
    
    // Проверка на достижение максимального уровня
    if (companion.level >= companion.max_level) {
        companion.exp = 0;
        companion.exp_to_level = 0;
        add_notification(companion.name + " достигла максимального уровня!");
    }
}

function upgrade_hero_attribute(attribute) {
    if (!variable_global_exists("hero")) {
        return false;
    }
    
    // Проверяем существование skill_points
    if (!variable_struct_exists(global.hero, "skill_points")) {
        global.hero.skill_points = 0;
    }
    
    if (global.hero.skill_points > 0) {
        switch (attribute) {
            case "strength":
                global.hero.strength += 1;
                break;
            case "agility":
                global.hero.agility += 1;
                break;
            case "intelligence":
                global.hero.intelligence += 1;
                break;
            default:
                show_debug_message("Неизвестный атрибут: " + string(attribute));
                return false;
        }
        
        global.hero.skill_points--;
        
        // Пересчитываем бонусы помощниц после улучшения атрибута
        calculate_companion_bonuses();
        // Обновляем максимальное здоровье с учетом новых бонусов
        update_hero_max_health();
        
        add_notification("Атрибут " + attribute + " улучшен до " + string(global.hero[? attribute]));
        return true;
    }
    return false;
}
// В scr_expedition_system.gml
function check_instant_expedition_completion() {
    if (global.expedition_instant_complete_chance > 0 && global.expedition.active) {
        if (random(100) < global.expedition_instant_complete_chance) {
            var diff = global.expedition_difficulties[global.expedition.difficulty];
            var time_saved = global.expedition.duration - global.expedition.progress;
            
            // Награда за мгновенное завершение (уменьшенная)
            var base_reward = irandom_range(diff.reward_min, diff.reward_max) * 0.7;
            var exp_reward = 15 * (global.expedition.difficulty + 1);
            
            global.gold += floor(base_reward * global.expedition_reward_multiplier);
            add_hero_exp(floor(exp_reward * global.expedition_reward_multiplier));
            
            add_notification("⚡ КОНЦЕПЦИЯ ПОБЕДЫ! Экспедиция мгновенно завершена! Сэкономлено: " + string(floor(time_saved/60)) + " минут");
            
            // Завершаем экспедицию
            global.expedition.active = false;
            if (variable_global_exists("remove_all_buffs")) {
                global.remove_all_buffs();
            }
            
            return true;
        }
    }
    return false;
}
function remove_artifact_effects(item_id) {
    show_debug_message("Снятие эффектов артефакта: " + item_id);
    
    switch(item_id) {
        case "omnipotence_crown":
            global.simultaneous_expeditions = false;
            break;
            
        case "aegis":
            for (var i = 0; i < 3; i++) {
                global.expedition_auto_repeat.difficulties[i] = false;
            }
            // Проверяем, остались ли активные авто-повторы
            global.expedition_auto_repeat.enabled = false;
            for (var i = 0; i < array_length(global.expedition_auto_repeat.difficulties); i++) {
                if (global.expedition_auto_repeat.difficulties[i]) {
                    global.expedition_auto_repeat.enabled = true;
                    break;
                }
            }
            break;
            
        case "gungnir":
            global.expedition_auto_repeat.difficulties[3] = false;
            // Аналогичная проверка как выше
            global.expedition_auto_repeat.enabled = false;
            for (var i = 0; i < array_length(global.expedition_auto_repeat.difficulties); i++) {
                if (global.expedition_auto_repeat.difficulties[i]) {
                    global.expedition_auto_repeat.enabled = true;
                    break;
                }
            }
            break;
            
        case "concept_of_victory":
            global.expedition_instant_complete_chance = 0;
            global.expedition_reward_multiplier = 1.0;
            break;
            
        default:
            // Для обычных предметов ничего не делаем
            break;
    }
}

// В scr_elite_items.gml - обновите описания
function update_elite_item_descriptions() {
    // Корона Всесилия
    SetItemProperty("omnipotence_crown", "description", "Делает владельца богом. ПОБОЧНЫЙ ЭФФЕКТ: Позволяет запускать все экспедиции одновременно");
    
    // Эгида  
    SetItemProperty("aegis", "description", "Щит Зевса. ПОБОЧНЫЙ ЭФФЕКТ: Ставит первые 3 экспедиции на авто-повтор");
    
    // Гунгнир
    SetItemProperty("gungnir", "description", "Копье Одина. ПОБОЧНЫЙ ЭФФЕКТ: Ставит четвертую экспедицию на авто-повтор");
    
    // Концепция Победы
    SetItemProperty("concept_of_victory", "description", "Абстрактная концепция, воплощенная в предмете. ПОБОЧНЫЙ ЭФФЕКТ: 15% шанс мгновенно завершить экспедицию + x2.5 награды");
}


// Функция создания эффекта продажи
function create_sell_effect(item_index, sell_price) {
    if (!variable_global_exists("purchase_effects")) {
        global.purchase_effects = ds_list_create();
    }
    
    var effect = {
        type: "sell",
        amount: sell_price,
        purchase_frame: global.frame_count,
        item_index: item_index
    };
    
    ds_list_add(global.purchase_effects, effect);
    show_debug_message("Создан эффект продажи: +" + string(sell_price) + " золота");
}
// Функция получения цены продажи предмета
function get_sell_price(item_id, quantity) {
    var db_data = ds_map_find_value(global.ItemDB, item_id);
    if (db_data == -1) return 0;
    
    var base_price = db_data[? "price"];
    return floor(base_price * 0.5 * quantity);
}
// Функция прямой продажи (вызывается напрямую из отрисовки)
function sell_item_direct(item_index, quantity) {
    show_debug_message("=== ПРЯМАЯ ПРОДАЖА ===");
    
    // Быстрая проверка инвентаря
    if (!variable_global_exists("playerInventory") || item_index < 0 || item_index >= ds_list_size(global.playerInventory)) {
        show_debug_message("Ошибка: неверный индекс предмета");
        return false;
    }
    
    var item_data = ds_list_find_value(global.playerInventory, item_index);
    if (is_undefined(item_data)) {
        show_debug_message("Ошибка: данные предмета не найдены");
        return false;
    }
    
    var item_id = item_data[? "id"];
    var current_quantity = item_data[? "quantity"];
    
    // Проверяем количество
    if (quantity > current_quantity) {
        add_notification("Недостаточно предметов для продажи!");
        return false;
    }
    
    // Получаем данные из базы
    var db_data = ds_map_find_value(global.ItemDB, item_id);
    if (db_data == -1) {
        show_debug_message("Ошибка: предмет не найден в базе данных");
        return false;
    }
    
    var item_name = db_data[? "name"];
    var base_price = db_data[? "price"];
    var sell_price = floor(base_price * 0.5 * quantity);
    
    show_debug_message("Продаем: " + item_name + " x" + string(quantity) + " за " + string(sell_price) + " золота");
    
    // Удаляем предмет из инвентаря
    if (quantity == current_quantity) {
        // Удаляем весь стак
        ds_map_destroy(item_data);
        ds_list_delete(global.playerInventory, item_index);
    } else {
        // Уменьшаем количество
        item_data[? "quantity"] = current_quantity - quantity;
    }
    
    // Добавляем золото
    global.gold += sell_price;
    
    // Создаем эффект продажи
    create_sell_effect(item_index, sell_price);
    
    add_notification("Продано: " + item_name + " x" + string(quantity) + " за " + string(sell_price) + " золота");
    
    show_debug_message("=== ПРОДАЖА УСПЕШНА ===");
    return true;
}
