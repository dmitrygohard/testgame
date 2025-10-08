// scr_inventory_system.gml

function init_inventory_system() {
    global.equipment_slots = [];
    
    // Главный герой (4 слота)
    array_push(global.equipment_slots, {
        weapon: -1,
        armor: -1,
        accessory: -1,
        relic: -1
    });
    
    // Помощницы (3 слота)
    for (var i = 0; i < 3; i++) {
        array_push(global.equipment_slots, {
            weapon: -1,
            armor: -1,
            accessory: -1
        });
    }
    
    if (!variable_global_exists("playerInventory")) {
        global.playerInventory = ds_list_create();
    }
}

function AddItemToInventory(_itemId, _quantity) {
    if (!variable_global_exists("playerInventory") || !ds_exists(global.playerInventory, ds_type_list)) {
        show_debug_message("Ошибка: Инвентарь не инициализирован!");
        return false;
    }
    
    var _itemData = ds_map_find_value(global.ItemDB, _itemId);
    if (_itemData == -1) {
        show_debug_message("Ошибка: Предмет с ID " + string(_itemId) + " не найден в базе данных!");
        return false;
    }
    
    var _stackable = _itemData[? "stackable"];
    var _maxStack = _itemData[? "maxStack"];
    
    // Поиск существующего стака для стакающихся предметов
    if (_stackable) {
        for (var i = 0; i < ds_list_size(global.playerInventory); i++) {
            var _invItem = ds_list_find_value(global.playerInventory, i);
            if (is_struct(_invItem) && _invItem[? "id"] == _itemId) {
                var currentQty = _invItem[? "quantity"];
                if (currentQty + _quantity <= _maxStack) {
                    _invItem[? "quantity"] = currentQty + _quantity;
                    return true;
                }
            }
        }
    }
    
    // Добавление нового предмета
    var newItem = ds_map_create();
    ds_map_add(newItem, "id", _itemId);
    ds_map_add(newItem, "quantity", _quantity);
    ds_list_add(global.playerInventory, newItem);
    
    return true;
}

function apply_artifact_effects(item_id) {
    show_debug_message("Применение эффектов артефакта: " + item_id);
    
    switch(item_id) {
        case "omnipotence_crown":
            // Корона Всесилия - позволяет запускать все экспедиции одновременно
            global.simultaneous_expeditions = true;
            add_notification("👑 КОРОНА ВСЕСИЛИЯ: Теперь можно запускать все экспедиции одновременно!");
            break;
            
        case "aegis":
            // Эгида - авто-повтор для первых трех экспедиций
            global.expedition_auto_repeat.enabled = true;
            for (var i = 0; i < 3; i++) {
                global.expedition_auto_repeat.difficulties[i] = true;
            }
            add_notification("🛡️ ЭГИДА: Первые 3 экспедиции теперь на авто-повторе!");
            break;
            
        case "gungnir":
            // Гунгнир - авто-повтор для четвертой экспедиции
            global.expedition_auto_repeat.enabled = true;
            global.expedition_auto_repeat.difficulties[3] = true;
            add_notification("🔱 ГУНГНИР: Сложная экспедиция теперь на авто-повторе!");
            break;
            
        case "concept_of_victory":
            // Концепция Победы - самая интересная механика
            global.expedition_instant_complete_chance = 15; // 15% шанс мгновенного завершения
            global.expedition_reward_multiplier = 2.5; // 2.5x награда
            add_notification("🎯 КОНЦЕПЦИЯ ПОБЕДЫ: Шанс мгновенного завершения + увеличение наград!");
            break;
            
        default:
            // Для обычных предметов ничего не делаем
            break;
    }
}


function EquipItem(item_index, character_index, slot_type) {
    // Проверяем существование инвентаря
    if (!variable_global_exists("playerInventory") || !ds_exists(global.playerInventory, ds_type_list)) {
        show_debug_message("Ошибка: Инвентарь не инициализирован!");
        return false;
    }
    
    // Проверяем существование героя
    if (!variable_global_exists("hero")) {
        show_debug_message("Ошибка: Герой не инициализирован!");
        return false;
    }
    
    // Проверяем корректность индекса предмета
    if (item_index < 0 || item_index >= ds_list_size(global.playerInventory)) {
        show_debug_message("Ошибка: Неверный индекс предмета: " + string(item_index));
        return false;
    }
    
    // Получаем данные предмета из инвентаря
    var item_data = ds_list_find_value(global.playerInventory, item_index);
    if (is_undefined(item_data)) {
        show_debug_message("Ошибка: Данные предмета не найдены!");
        return false;
    }
    
    var item_id = item_data[? "id"];
    
    // Проверяем существование базы данных предметов
    if (!variable_global_exists("ItemDB") || !ds_exists(global.ItemDB, ds_type_map)) {
        show_debug_message("Ошибка: База данных предметов не инициализирована!");
        return false;
    }
    
    // Получаем полные данные предмета из базы
    var db_data = ds_map_find_value(global.ItemDB, item_id);
    if (db_data == -1) {
        show_debug_message("Ошибка: Предмет с ID " + string(item_id) + " не найден в базе данных!");
        return false;
    }
    
    // Проверяем возможность экипировки
    var equip_slot = db_data[? "equip_slot"];
    if (equip_slot == -1) {
        add_notification("Этот предмет нельзя экипировать!");
        return false;
    }
    
    // Проверяем соответствие типа предмета и слота
    var valid_slot = false;
    switch(slot_type) {
        case "weapon":
            valid_slot = (equip_slot == global.EQUIP_SLOT.WEAPON);
            break;
        case "armor":
            valid_slot = (equip_slot == global.EQUIP_SLOT.ARMOR);
            break;
        case "accessory":
            valid_slot = (equip_slot == global.EQUIP_SLOT.ACCESSORY);
            break;
        case "relic":
            valid_slot = (equip_slot == global.EQUIP_SLOT.RELIC);
            break;
    }
    
    if (!valid_slot) {
        add_notification("Этот предмет нельзя надеть в этот слот!");
        return false;
    }
    
    // Получаем текущий предмет в слоте (если есть)
    var current_item_id = variable_struct_get(global.equipment_slots[character_index], slot_type);
    
    // Если в слоте уже есть предмет, сначала снимаем его
    if (current_item_id != -1) {
        UnequipItem(character_index, slot_type);
    }
    
    // Экипируем новый предмет в слот
    variable_struct_set(global.equipment_slots[character_index], slot_type, item_id);
    
    // Удаляем предмет из инвентаря
    RemoveItemFromInventory(item_id, 1);
    
    // ИНИЦИАЛИЗИРУЕМ ВСЕ ВОЗМОЖНЫЕ СВОЙСТВА БОНУСОВ, ЕСЛИ ОНИ ОТСУТСТВУЮТ
    if (!variable_struct_exists(global.hero, "equipment_bonuses")) {
        global.hero.equipment_bonuses = {};
    }
    
    if (!variable_struct_exists(global.hero.equipment_bonuses, "strength")) global.hero.equipment_bonuses.strength = 0;
    if (!variable_struct_exists(global.hero.equipment_bonuses, "agility")) global.hero.equipment_bonuses.agility = 0;
    if (!variable_struct_exists(global.hero.equipment_bonuses, "intelligence")) global.hero.equipment_bonuses.intelligence = 0;
    if (!variable_struct_exists(global.hero.equipment_bonuses, "defense")) global.hero.equipment_bonuses.defense = 0;
    if (!variable_struct_exists(global.hero.equipment_bonuses, "max_health")) global.hero.equipment_bonuses.max_health = 0;
    if (!variable_struct_exists(global.hero.equipment_bonuses, "gold_bonus")) global.hero.equipment_bonuses.gold_bonus = 0;
    if (!variable_struct_exists(global.hero.equipment_bonuses, "health_bonus")) global.hero.equipment_bonuses.health_bonus = 0;
    
    // ДОБАВЛЯЕМ ПЕРМАНЕНТНЫЕ БОНУСЫ - С ПРОВЕРКОЙ НА СУЩЕСТВОВАНИЕ
    if (!variable_struct_exists(global.hero.equipment_bonuses, "perm_strength")) global.hero.equipment_bonuses.perm_strength = 0;
    if (!variable_struct_exists(global.hero.equipment_bonuses, "perm_intelligence")) global.hero.equipment_bonuses.perm_intelligence = 0;
    if (!variable_struct_exists(global.hero.equipment_bonuses, "perm_agility")) global.hero.equipment_bonuses.perm_agility = 0;
 // Обновляем систему бафов от предметов
    if (variable_global_exists("update_companion_buff_system")) {
        update_companion_buff_system();
    }
    // Безопасно добавляем бонусы с проверкой на существование
    var perm_strength = db_data[? "perm_strength"];
    if (!is_undefined(perm_strength)) {
        global.hero.equipment_bonuses.perm_strength += perm_strength;
        global.hero.strength += perm_strength;
    }
    
    var perm_intelligence = db_data[? "perm_intelligence"];
    if (!is_undefined(perm_intelligence)) {
        global.hero.equipment_bonuses.perm_intelligence += perm_intelligence;
        global.hero.intelligence += perm_intelligence;
    }
    
    var perm_agility = db_data[? "perm_agility"];
    if (!is_undefined(perm_agility)) {
        global.hero.equipment_bonuses.perm_agility += perm_agility;
        global.hero.agility += perm_agility;
    }
    
    // БЕЗОПАСНО ПРИМЕНЯЕМ ВСЕ БОНУСЫ ОТ ПРЕДМЕТА (С ПРОВЕРКОЙ НА СУЩЕСТВОВАНИЕ)
    var strength_bonus = db_data[? "strength_bonus"];
    if (!is_undefined(strength_bonus)) global.hero.equipment_bonuses.strength += strength_bonus;
    
    var agility_bonus = db_data[? "agility_bonus"];
    if (!is_undefined(agility_bonus)) global.hero.equipment_bonuses.agility += agility_bonus;
    
    var intelligence_bonus = db_data[? "intelligence_bonus"];
    if (!is_undefined(intelligence_bonus)) global.hero.equipment_bonuses.intelligence += intelligence_bonus;
    
    var defense_bonus = db_data[? "defense_bonus"];
    if (!is_undefined(defense_bonus)) global.hero.equipment_bonuses.defense += defense_bonus;
    
    var max_health_bonus = db_data[? "max_health_bonus"];
    if (!is_undefined(max_health_bonus)) global.hero.equipment_bonuses.max_health += max_health_bonus;
    
    var gold_bonus = db_data[? "gold_bonus"];
    if (!is_undefined(gold_bonus)) global.hero.equipment_bonuses.gold_bonus += gold_bonus;
    
    var health_bonus = db_data[? "health_bonus"];
    if (!is_undefined(health_bonus)) global.hero.equipment_bonuses.health_bonus += health_bonus;
    
    // ПРИМЕНЯЕМ СПЕЦИАЛЬНЫЕ ЭФФЕКТЫ АРТЕФАКТОВ
    apply_artifact_effects(item_id);
    
    // Пересчитываем бонусы помощниц
    if (variable_global_exists("calculate_companion_bonuses")) {
        calculate_companion_bonuses();
    }
    
    // Обновляем максимальное здоровье
    if (variable_global_exists("update_hero_max_health")) {
        update_hero_max_health();
    }
    
    add_notification("Экипировано: " + db_data[? "name"]);
    return true;
}

function UnequipItem(character_index, slot_type) {
    // Проверяем существование необходимых глобальных структур
    if (!variable_global_exists("equipment_slots")) {
        show_debug_message("Ошибка: equipment_slots не инициализирован!");
        return false;
    }
    
    if (!variable_global_exists("ItemDB") || !ds_exists(global.ItemDB, ds_type_map)) {
        show_debug_message("Ошибка: База данных предметов (ItemDB) не инициализирована!");
        return false;
    }
    
    // Проверяем существование героя
    if (!variable_global_exists("hero")) {
        show_debug_message("Ошибка: Герой не инициализирован!");
        return false;
    }
    
    // Получаем ID предмета из слота
    var item_id = variable_struct_get(global.equipment_slots[character_index], slot_type);
    
    // Проверяем, не пустой ли слот
    if (item_id == -1) {
        return false;
    }
    
    // Получаем данные предмета из базы
    var item_data = ds_map_find_value(global.ItemDB, item_id);
    if (item_data == -1) {
        show_debug_message("Ошибка: Предмет с ID " + string(item_id) + " не найден в базе данных!");
        return false;
    }
    
    // ИНИЦИАЛИЗИРУЕМ СВОЙСТВА БОНУСОВ ПЕРЕД ВЫЧИТАНИЕМ
    if (!variable_struct_exists(global.hero, "equipment_bonuses")) {
        global.hero.equipment_bonuses = {};
    }
    
    if (!variable_struct_exists(global.hero.equipment_bonuses, "strength")) global.hero.equipment_bonuses.strength = 0;
    if (!variable_struct_exists(global.hero.equipment_bonuses, "agility")) global.hero.equipment_bonuses.agility = 0;
    if (!variable_struct_exists(global.hero.equipment_bonuses, "intelligence")) global.hero.equipment_bonuses.intelligence = 0;
    if (!variable_struct_exists(global.hero.equipment_bonuses, "defense")) global.hero.equipment_bonuses.defense = 0;
    if (!variable_struct_exists(global.hero.equipment_bonuses, "max_health")) global.hero.equipment_bonuses.max_health = 0;
    if (!variable_struct_exists(global.hero.equipment_bonuses, "gold_bonus")) global.hero.equipment_bonuses.gold_bonus = 0;
    if (!variable_struct_exists(global.hero.equipment_bonuses, "health_bonus")) global.hero.equipment_bonuses.health_bonus = 0;
    
    if (!variable_struct_exists(global.hero.equipment_bonuses, "perm_strength")) global.hero.equipment_bonuses.perm_strength = 0;
    if (!variable_struct_exists(global.hero.equipment_bonuses, "perm_intelligence")) global.hero.equipment_bonuses.perm_intelligence = 0;
    if (!variable_struct_exists(global.hero.equipment_bonuses, "perm_agility")) global.hero.equipment_bonuses.perm_agility = 0;
    
    // БЕЗОПАСНО УБИРАЕМ БОНУСЫ ПРЕДМЕТА
    var strength_bonus = item_data[? "strength_bonus"];
    if (!is_undefined(strength_bonus)) global.hero.equipment_bonuses.strength -= strength_bonus;
    // Обновляем систему бафов от предметов
    if (variable_global_exists("update_companion_buff_system")) {
        update_companion_buff_system();
    }
    var agility_bonus = item_data[? "agility_bonus"];
    if (!is_undefined(agility_bonus)) global.hero.equipment_bonuses.agility -= agility_bonus;
    
    var intelligence_bonus = item_data[? "intelligence_bonus"];
    if (!is_undefined(intelligence_bonus)) global.hero.equipment_bonuses.intelligence -= intelligence_bonus;
    
    var defense_bonus = item_data[? "defense_bonus"];
    if (!is_undefined(defense_bonus)) global.hero.equipment_bonuses.defense -= defense_bonus;
    
    var max_health_bonus = item_data[? "max_health_bonus"];
    if (!is_undefined(max_health_bonus)) global.hero.equipment_bonuses.max_health -= max_health_bonus;
    
    var gold_bonus = item_data[? "gold_bonus"];
    if (!is_undefined(gold_bonus)) global.hero.equipment_bonuses.gold_bonus -= gold_bonus;
    
    var health_bonus = item_data[? "health_bonus"];
    if (!is_undefined(health_bonus)) global.hero.equipment_bonuses.health_bonus -= health_bonus;
    
    // УБИРАЕМ ПЕРМАНЕНТНЫЕ БОНУСЫ
    var perm_strength = item_data[? "perm_strength"];
    if (!is_undefined(perm_strength)) {
        global.hero.equipment_bonuses.perm_strength -= perm_strength;
        global.hero.strength -= perm_strength;
    }
    
    var perm_intelligence = item_data[? "perm_intelligence"];
    if (!is_undefined(perm_intelligence)) {
        global.hero.equipment_bonuses.perm_intelligence -= perm_intelligence;
        global.hero.intelligence -= perm_intelligence;
    }
    
    var perm_agility = item_data[? "perm_agility"];
    if (!is_undefined(perm_agility)) {
        global.hero.equipment_bonuses.perm_agility -= perm_agility;
        global.hero.agility -= perm_agility;
    }
    
    // СНИМАЕМ СПЕЦИАЛЬНЫЕ ЭФФЕКТЫ АРТЕФАКТОВ
    remove_artifact_effects(item_id);
    
    // Возвращаем предмет в инвентарь
    if (!AddItemToInventory(item_id, 1)) {
        show_debug_message("Ошибка: Не удалось добавить предмет в инвентарь. Возможно, он полон.");
        return false;
    }
    
    // Пересчитываем бонусы
    if (variable_global_exists("calculate_companion_bonuses")) {
        calculate_companion_bonuses();
    }
    
    // Обновляем максимальное здоровье
    if (variable_global_exists("update_hero_max_health")) {
        update_hero_max_health();
    }
    
    // Очищаем слот экипировки
    variable_struct_set(global.equipment_slots[character_index], slot_type, -1);
    
    add_notification("Снято: " + item_data[? "name"]);
    
    return true;
}

function RemoveItemFromInventory(_itemId, _quantity) {
    // Проверяем, существует ли инвентарь игрока
    if (!variable_global_exists("playerInventory") || !ds_exists(global.playerInventory, ds_type_list)) {
        show_debug_message("Ошибка: Инвентарь игрока не инициализирован!");
        return false;
    }
    
    var _totalRemoved = 0; // Счётчик успешно удалённых предметов
    var i = 0;
    
    // Проходим по всему инвентарю
    while (i < ds_list_size(global.playerInventory) && _totalRemoved < _quantity) {
        var _invItem = ds_list_find_value(global.playerInventory, i);
        
        // Если найден нужный предмет
        if (!is_undefined(_invItem) && _invItem[? "id"] == _itemId) {
            var _itemQuantity = _invItem[? "quantity"];
            var _removeAmount = min(_quantity - _totalRemoved, _itemQuantity);
            
            if (_removeAmount == _itemQuantity) {
                // Удаляем весь стак предметов
                ds_map_destroy(_invItem); // Освобождаем память
                ds_list_delete(global.playerInventory, i);
                // Не увеличиваем i, так как элементы сместились
            } else {
                // Уменьшаем количество в стаке
                _invItem[? "quantity"] = _itemQuantity - _removeAmount;
                i++; // Переходим к следующему элементу
            }
            
            _totalRemoved += _removeAmount;
        } else {
            i++; // Переходим к следующему элементу
        }
    }
    
    // Возвращаем true, если удалено запрошенное количество
    return _totalRemoved == _quantity;
}

function GetItemCount(_itemId) {
    if (!variable_global_exists("playerInventory") || !ds_exists(global.playerInventory, ds_type_list)) {
        return 0;
    }
    
    var _total = 0;
    for (var i = 0; i < ds_list_size(global.playerInventory); i++) {
        var _invItem = ds_list_find_value(global.playerInventory, i);
        if (!is_undefined(_invItem) && _invItem[? "id"] == _itemId) {
            _total += _invItem[? "quantity"];
        }
    }
    return _total;
}

// scr_inventory_system.gml - полностью заменяем функцию use_potion

function use_potion(p_item_id) {
    var item_data = ds_map_find_value(global.ItemDB, p_item_id);
    if (item_data == -1) {
        show_debug_message("Ошибка: Предмет с ID " + string(p_item_id) + " не найден!");
        return false;
    }
    
    var item_type = item_data[? "type"];
    var item_name = item_data[? "name"];
    
    if (item_type == global.ITEM_TYPE.POTION) {
        // Обработка зелий
        var used = false;
        
        // Зелья здоровья
        if (item_data[? "health"] > 0) {
            var heal_value = item_data[? "health"];
            var actual_healing = hero_heal(heal_value);
            add_notification("Использовано " + item_name + "! +" + string(actual_healing) + " HP");
            used = true;
        }
        
        // Временные бафы от зелий
        else if (item_data[? "temp_strength"] > 0) {
            var bonus = item_data[? "temp_strength"];
            // Создаем временный баф силы
            var temp_buff = {
                name: "💪 Временная сила",
                description: "Временно увеличивает силу",
                icon: "💪",
                type: global.BUFF_TYPES.TEMP_STRENGTH,
                value: bonus,
                duration: 1800, // 30 секунд при 60 FPS
                start_time: global.frame_count,
                color: make_color_rgb(255, 100, 100)
            };
            
            // Добавляем в глобальный массив временных бафов
            if (!variable_global_exists("temp_buffs")) {
                global.temp_buffs = [];
            }
            array_push(global.temp_buffs, temp_buff);
            
            // Применяем эффект сразу
            apply_temp_buff_effect(temp_buff);
            
            add_notification("Использовано " + item_name + "! +" + string(bonus) + " к силе на 30 сек");
            used = true;
        }
        else if (item_data[? "temp_agility"] > 0) {
            var bonus = item_data[? "temp_agility"];
            var temp_buff = {
                name: "⚡ Временная ловкость",
                description: "Временно увеличивает ловкость",
                icon: "⚡",
                type: global.BUFF_TYPES.TEMP_AGILITY,
                value: bonus,
                duration: 1800,
                start_time: global.frame_count,
                color: make_color_rgb(100, 255, 100)
            };
            
            if (!variable_global_exists("temp_buffs")) {
                global.temp_buffs = [];
            }
            array_push(global.temp_buffs, temp_buff);
            apply_temp_buff_effect(temp_buff);
            
            add_notification("Использовано " + item_name + "! +" + string(bonus) + " к ловкости на 30 сек");
            used = true;
        }
        else if (item_data[? "temp_intelligence"] > 0) {
            var bonus = item_data[? "temp_intelligence"];
            var temp_buff = {
                name: "🧠 Временный интеллект",
                description: "Временно увеличивает интеллект",
                icon: "🧠",
                type: global.BUFF_TYPES.TEMP_INTELLIGENCE,
                value: bonus,
                duration: 1800,
                start_time: global.frame_count,
                color: make_color_rgb(100, 100, 255)
            };
            
            if (!variable_global_exists("temp_buffs")) {
                global.temp_buffs = [];
            }
            array_push(global.temp_buffs, temp_buff);
            apply_temp_buff_effect(temp_buff);
            
            add_notification("Использовано " + item_name + "! +" + string(bonus) + " к интеллекту на 30 сек");
            used = true;
        }
        else if (item_data[? "temp_defense"] > 0) {
            var bonus = item_data[? "temp_defense"];
            var temp_buff = {
                name: "🛡️ Временная защита",
                description: "Временно увеличивает защиту",
                icon: "🛡️",
                type: global.BUFF_TYPES.TEMP_DEFENSE,
                value: bonus,
                duration: 1800,
                start_time: global.frame_count,
                color: make_color_rgb(150, 150, 255)
            };
            
            if (!variable_global_exists("temp_buffs")) {
                global.temp_buffs = [];
            }
            array_push(global.temp_buffs, temp_buff);
            apply_temp_buff_effect(temp_buff);
            
            add_notification("Использовано " + item_name + "! +" + string(bonus) + " к защите на 30 сек");
            used = true;
        }
        
        // Специальные зелья для экспедиций
        else if (item_data[? "expedition_success_bonus"] > 0) {
            var bonus = item_data[? "expedition_success_bonus"];
            // Создаем баф для следующей экспедиции
            var expedition_buff = {
                name: item_name,
                description: "Увеличивает шанс успеха экспедиции",
                icon: "🎯",
                type: global.BUFF_TYPES.SUCCESS,
                value: bonus,
                duration: 1, // на одну экспедицию
                color: make_color_rgb(255, 255, 100)
            };
            
            array_push(global.active_buffs, expedition_buff);
            add_notification("Использовано " + item_name + "! +" + string(bonus) + "% к шансу успеха следующей экспедиции");
            used = true;
        }
        else if (item_data[? "expedition_gold_bonus"] > 0) {
            var bonus = item_data[? "expedition_gold_bonus"];
            var expedition_buff = {
                name: item_name,
                description: "Увеличивает получаемое золото",
                icon: "💰",
                type: global.BUFF_TYPES.GOLD,
                value: bonus,
                duration: 1,
                color: make_color_rgb(255, 215, 0)
            };
            
            array_push(global.active_buffs, expedition_buff);
            add_notification("Использовано " + item_name + "! +" + string(bonus) + "% к золоту следующей экспедиции");
            used = true;
        }
        
        if (used) {
            // Удаляем один предмет из инвентаря
            RemoveItemFromInventory(p_item_id, 1);
            return true;
        }
        
    } else if (item_type == global.ITEM_TYPE.SCROLL) {
        // Обработка свитков
        var used = false;
        
        if (item_data[? "instant_complete"] == true) {
            if (global.expedition.active) {
                // Мгновенно завершаем текущую экспедицию
                global.expedition.progress = global.expedition.duration;
                add_notification("Использован " + item_name + "! Экспедиция мгновенно завершена.");
                used = true;
            } else {
                add_notification("Нет активной экспедиции для использования свитка!");
            }
        }
        else if (item_data[? "defense_multiplier"] > 0) {
            var multiplier = item_data[? "defense_multiplier"];
            var bonus_percent = (multiplier - 1) * 100;
            
            var expedition_buff = {
                name: item_name,
                description: "Увеличивает защиту на экспедицию",
                icon: "🛡️",
                type: global.BUFF_TYPES.DEFENSE,
                value: bonus_percent,
                duration: 1,
                color: make_color_rgb(100, 150, 255)
            };
            
            array_push(global.active_buffs, expedition_buff);
            add_notification("Использован " + item_name + "! +" + string(round(bonus_percent)) + "% к защите на экспедицию");
            used = true;
        }
        else if (item_data[? "reward_multiplier"] > 0) {
            var multiplier = item_data[? "reward_multiplier"];
            var bonus_percent = (multiplier - 1) * 100;
            
            var expedition_buff = {
                name: item_name,
                description: "Увеличивает награду за экспедицию",
                icon: "💰",
                type: global.BUFF_TYPES.GOLD,
                value: bonus_percent,
                duration: 1,
                color: make_color_rgb(255, 215, 0)
            };
            
            array_push(global.active_buffs, expedition_buff);
            add_notification("Использован " + item_name + "! +" + string(round(bonus_percent)) + "% к награде");
            used = true;
        }
        else if (item_data[? "expedition_speed"] > 0) {
            var speed_bonus = item_data[? "expedition_speed"];
            
            var expedition_buff = {
                name: item_name,
                description: "Ускоряет экспедицию",
                icon: "⚡",
                type: global.BUFF_TYPES.SPEED,
                value: speed_bonus,
                duration: 1,
                color: make_color_rgb(100, 255, 100)
            };
            
            array_push(global.active_buffs, expedition_buff);
            add_notification("Использован " + item_name + "! Экспедиция будет завершена на " + string(round((1 - speed_bonus) * 100)) + "% быстрее");
            used = true;
        }
        
        if (used) {
            // Удаляем один предмет из инвентаря
            RemoveItemFromInventory(p_item_id, 1);
            return true;
        }
    }
    
    // Если предмет не удалось использовать
    add_notification("Не удалось использовать: " + item_name);
    return false;
}
// scr_init_item_database.gml

function scr_init_item_database() {
    show_debug_message("Инициализация расширенной базы данных предметов...");
    
    global.ItemDB = ds_map_create();

    // Типы предметов
    global.ITEM_TYPE = {
        WEAPON: 0,
        ARMOR: 1,
        POTION: 2,
        RESOURCE: 3,
        ACCESSORY: 4,
        SCROLL: 5,
        RELIC: 6
    };

    // Слоты экипировки
    global.EQUIP_SLOT = {
        WEAPON: 0,
        ARMOR: 1,
        ACCESSORY: 2,
        RELIC: 3
    };

    // ==================== ПРЕДМЕТЫ ДЛЯ НАЧАЛА ИГРЫ (УРОВНИ 1-10) ====================
    
    // Простое оружие
    AddItemToDB("wooden_sword", "Деревянный меч", global.ITEM_TYPE.WEAPON, 50, "Простое оружие для начинающих.", 2, 0, 0, global.EQUIP_SLOT.WEAPON, 0);
    AddItemToDB("apprentice_staff", "Посох ученика", global.ITEM_TYPE.WEAPON, 60, "Базовый магический посох.", 0, 3, 0, global.EQUIP_SLOT.WEAPON, 0);
    AddItemToDB("hunting_bow", "Охотничий лук", global.ITEM_TYPE.WEAPON, 55, "Простой лук для охоты.", 1, 0, 1, global.EQUIP_SLOT.WEAPON, 0);
    
    // Базовая броня
    AddItemToDB("cloth_robe", "Тканевая роба", global.ITEM_TYPE.ARMOR, 40, "Простая роба новичка.", 0, 1, 2, global.EQUIP_SLOT.ARMOR, 0);
    AddItemToDB("leather_helmet", "Кожаный шлем", global.ITEM_TYPE.ARMOR, 45, "Базовая защита головы.", 0, 0, 3, global.EQUIP_SLOT.ARMOR, 0);
    AddItemToDB("traveler_boots", "Сапоги путешественника", global.ITEM_TYPE.ARMOR, 35, "Удобные для длинных походов.", 0, 0, 1, global.EQUIP_SLOT.ARMOR, 0);
    
    // Аксессуары для начинающих
    AddItemToDB("novice_ring", "Кольцо новичка", global.ITEM_TYPE.ACCESSORY, 80, "Небольшой бонус ко всем атрибутам.", 1, 1, 1, global.EQUIP_SLOT.ACCESSORY, 0);
    AddItemToDB("lucky_charm", "Талисман удачи", global.ITEM_TYPE.ACCESSORY, 70, "Немного увеличивает удачу.", 0, 0, 0, global.EQUIP_SLOT.ACCESSORY, 0);
    AddItemToDB("health_amulet", "Амулет здоровья", global.ITEM_TYPE.ACCESSORY, 90, "Увеличивает максимальное здоровье.", 0, 0, 0, global.EQUIP_SLOT.ACCESSORY, 0);

    // ==================== ПРЕДМЕТЫ СРЕДНЕЙ ИГРЫ (УРОВНИ 10-20) ====================
    
    // Улучшенное оружие
    AddItemToDB("iron_sword", "Железный меч", global.ITEM_TYPE.WEAPON, 200, "Надежное железное оружие.", 5, 0, 0, global.EQUIP_SLOT.WEAPON, 1);
    AddItemToDB("mage_wand", "Волшебная палочка", global.ITEM_TYPE.WEAPON, 220, "Усиливает магические способности.", 0, 6, 0, global.EQUIP_SLOT.WEAPON, 1);
    AddItemToDB("composite_bow", "Композитный лук", global.ITEM_TYPE.WEAPON, 210, "Более точный и мощный лук.", 3, 0, 2, global.EQUIP_SLOT.WEAPON, 1);
    
    // Средняя броня
    AddItemToDB("chain_armor", "Кольчужная броня", global.ITEM_TYPE.ARMOR, 180, "Хорошая защита от физических атак.", 0, 0, 8, global.EQUIP_SLOT.ARMOR, 1);
    AddItemToDB("mage_robe", "Мантия мага", global.ITEM_TYPE.ARMOR, 190, "Увеличивает магическую силу.", 0, 4, 3, global.EQUIP_SLOT.ARMOR, 1);
    AddItemToDB("ranger_cloak", "Плащ следопыта", global.ITEM_TYPE.ARMOR, 170, "Помогает оставаться незаметным.", 2, 2, 4, global.EQUIP_SLOT.ARMOR, 1);
    
    // Аксессуары среднего уровня
    AddItemToDB("warrior_bracelet", "Браслет воина", global.ITEM_TYPE.ACCESSORY, 250, "Увеличивает физическую силу.", 4, 0, 0, global.EQUIP_SLOT.ACCESSORY, 1);
    AddItemToDB("sage_earring", "Серьга мудреца", global.ITEM_TYPE.ACCESSORY, 260, "Усиливает интеллект.", 0, 5, 0, global.EQUIP_SLOT.ACCESSORY, 1);
    AddItemToDB("guardian_pendant", "Кулон защитника", global.ITEM_TYPE.ACCESSORY, 240, "Повышает защиту.", 0, 0, 6, global.EQUIP_SLOT.ACCESSORY, 1);

    // ==================== РЕДКИЕ ПРЕДМЕТЫ С УНИКАЛЬНЫМИ БАФАМИ ====================
    
    // Редкие предметы, которые дают новые бафы помощницам
    AddItemToDB("hepo_ancient_tome", "Древний фолиант Хэпо", global.ITEM_TYPE.ACCESSORY, 1500, "Хэпо изучает древние тактики. БАФ: +20% к шансу успеха", 0, 8, 0, global.EQUIP_SLOT.ACCESSORY, 2);
    AddItemToDB("fatty_energy_crystal", "Энергетический кристалл Фэтти", global.ITEM_TYPE.ACCESSORY, 1600, "Фэтти черпает силы из кристалла. БАФ: +30% к здоровью отряда", 0, 0, 10, global.EQUIP_SLOT.ACCESSORY, 2);
    AddItemToDB("discipline_golden_scale", "Золотые весы Дисциплины", global.ITEM_TYPE.ACCESSORY, 1550, "Дисциплина находит лучшие сделки. БАФ: +25% к получаемому золоту", 0, 6, 0, global.EQUIP_SLOT.ACCESSORY, 2);
    
    // Легендарные предметы с мощными бафами
    AddItemToDB("trinity_medallion", "Медальон Троицы", global.ITEM_TYPE.ACCESSORY, 5000, "Объединяет силы всех помощниц. БАФ: Все бафы усиливаются на 50%", 5, 5, 5, global.EQUIP_SLOT.ACCESSORY, 3);
    AddItemToDB("expedition_compass", "Компас экспедиций", global.ITEM_TYPE.ACCESSORY, 4500, "Показывает кратчайший путь. БАФ: -40% времени экспедиции", 0, 0, 0, global.EQUIP_SLOT.ACCESSORY, 3);
    AddItemToDB("lucky_dice", "Кости удачи", global.ITEM_TYPE.ACCESSORY, 4800, "Приносят невероятную удачу. БАФ: Шанс удвоить всю награду", 0, 0, 0, global.EQUIP_SLOT.ACCESSORY, 3);

    // ==================== МОЩНЫЕ ПРЕДМЕТЫ ДЛЯ ПОЗДНЕЙ ИГРЫ ====================
    
    // Эпическое оружие
    AddItemToDB("dragon_slayer", "Убийца драконов", global.ITEM_TYPE.WEAPON, 5000, "Меч, пропитанный кровью драконов.", 25, 0, 0, global.EQUIP_SLOT.WEAPON, 3);
    AddItemToDB("staff_of_wisdom", "Посох мудрости", global.ITEM_TYPE.WEAPON, 7500, "Усиливает магические способности.", 5, 25, 5, global.EQUIP_SLOT.WEAPON, 3);
    AddItemToDB("bow_of_accuracy", "Лук точности", global.ITEM_TYPE.WEAPON, 6000, "Никогда не промахивается.", 15, 0, 0, global.EQUIP_SLOT.WEAPON, 3);

    // Эпическая броня
    AddItemToDB("phantom_cloak", "Призрачный плащ", global.ITEM_TYPE.ARMOR, 8000, "Делает владельца невидимым.", 0, 15, 20, global.EQUIP_SLOT.ARMOR, 3);
    AddItemToDB("titan_armor", "Доспех титана", global.ITEM_TYPE.ARMOR, 12000, "Невероятно прочная броня.", 10, 0, 40, global.EQUIP_SLOT.ARMOR, 3);

    // Эпические аксессуары
    AddItemToDB("ring_of_power", "Кольцо силы", global.ITEM_TYPE.ACCESSORY, 10000, "Увеличивает все характеристики.", 10, 10, 10, global.EQUIP_SLOT.ACCESSORY, 3);
    AddItemToDB("amulet_of_immortality", "Амулет бессмертия", global.ITEM_TYPE.ACCESSORY, 25000, "Дарует сопротивление смерти.", 0, 20, 15, global.EQUIP_SLOT.ACCESSORY, 3);

    // ==================== ЗЕЛЬЯ И СВИТКИ ====================
    
    // Базовые зелья
    AddItemToDB("health_potion", "Зелье здоровья", global.ITEM_TYPE.POTION, 50, "Восстанавливает 50 HP.", 0, 0, 0, -1, 0, true, 10);
    AddItemToDB("greater_healing", "Сильное зелье здоровья", global.ITEM_TYPE.POTION, 120, "Восстанавливает 120 HP.", 0, 0, 0, -1, 1, true, 5);
    AddItemToDB("elixir_of_life", "Эликсир жизни", global.ITEM_TYPE.POTION, 300, "Восстанавливает 300 HP.", 0, 0, 0, -1, 2, true, 3);
    
    // Зелья бафов
    AddItemToDB("potion_of_strength", "Зелье силы", global.ITEM_TYPE.POTION, 200, "+5 к силе на 1 экспедицию.", 0, 0, 0, -1, 1, true, 5);
    AddItemToDB("potion_of_intellect", "Зелье интеллекта", global.ITEM_TYPE.POTION, 200, "+5 к интеллекту на 1 экспедицию.", 0, 0, 0, -1, 1, true, 5);
    AddItemToDB("potion_of_protection", "Зелье защиты", global.ITEM_TYPE.POTION, 200, "+5 к защите на 1 экспедицию.", 0, 0, 0, -1, 1, true, 5);

    // Свитки
    AddItemToDB("scroll_teleport", "Свиток телепортации", global.ITEM_TYPE.SCROLL, 400, "Мгновенно завершает экспедицию.", 0, 0, 0, -1, 2, true, 3);
    AddItemToDB("scroll_protection", "Свиток защиты", global.ITEM_TYPE.SCROLL, 350, "+50% защиты на следующую экспедицию.", 0, 0, 0, -1, 1, true, 5);
    AddItemToDB("scroll_fortune", "Свиток удачи", global.ITEM_TYPE.SCROLL, 500, "Удваивает награду за следующую экспедицию.", 0, 0, 0, -1, 2, true, 2);
// Зелья для экспедиций
AddItemToDB("potion_of_success", "Зелье успеха", global.ITEM_TYPE.POTION, 300, "Увеличивает шанс успеха следующей экспедиции.", 0, 0, 0, -1, 1, true, 3);
AddItemToDB("potion_of_gold", "Золотое зелье", global.ITEM_TYPE.POTION, 350, "Увеличивает золото с следующей экспедиции.", 0, 0, 0, -1, 1, true, 3);

// Свиток скорости
AddItemToDB("scroll_haste", "Свиток скорости", global.ITEM_TYPE.SCROLL, 600, "Ускоряет завершение экспедиции.", 0, 0, 0, -1, 2, true, 2);
    // Добавляем свойства для зелий и свитков
    AddItemProperties();
    
    // Добавляем свойства для редких предметов с бафами
    AddCompanionBuffProperties();
    
    show_debug_message("Расширенная база данных предметов успешно инициализирована: " + string(ds_map_size(global.ItemDB)) + " предметов");
}

function AddCompanionBuffProperties() {
    // Свойства для редких предметов, которые дают бафы помощницам
    
    // Предметы Хэпо
    SetItemProperty("hepo_ancient_tome", "companion_buff", "hepo_success");
    SetItemProperty("hepo_ancient_tome", "buff_power", 20);
    
    // Предметы Фэтти
    SetItemProperty("fatty_energy_crystal", "companion_buff", "fatty_health");
    SetItemProperty("fatty_energy_crystal", "buff_power", 30);
    
    // Предметы Дисциплины
    SetItemProperty("discipline_golden_scale", "companion_buff", "discipline_gold");
    SetItemProperty("discipline_golden_scale", "buff_power", 25);
    
    // Легендарные предметы
    SetItemProperty("trinity_medallion", "companion_buff", "all_buffs_boost");
    SetItemProperty("trinity_medallion", "buff_power", 50);
    
    SetItemProperty("expedition_compass", "companion_buff", "expedition_speed");
    SetItemProperty("expedition_compass", "buff_power", 40);
    
    SetItemProperty("lucky_dice", "companion_buff", "double_rewards");
    SetItemProperty("lucky_dice", "buff_power", 15); // 15% шанс
}

function AddItemToDB(_id, _name, _type, _price, _desc, _str_bonus, _int_bonus, _def_bonus, _equip_slot, _rarity, _stackable = false, _maxStack = 1) {
    var item = ds_map_create();
    
    ds_map_add(item, "id", _id);
    ds_map_add(item, "name", _name);
    ds_map_add(item, "type", _type);
    ds_map_add(item, "price", _price);
    ds_map_add(item, "description", _desc);
    ds_map_add(item, "strength_bonus", _str_bonus);
    ds_map_add(item, "intelligence_bonus", _int_bonus);
    ds_map_add(item, "defense_bonus", _def_bonus);
    ds_map_add(item, "equip_slot", _equip_slot);
    ds_map_add(item, "rarity", _rarity);
    ds_map_add(item, "stackable", _stackable);
    ds_map_add(item, "maxStack", _maxStack);
    
    ds_map_add(global.ItemDB, _id, item);
}

// scr_init_item_database.gml - обновляем функцию AddItemProperties

function AddItemProperties() {
    // Зелья здоровья
    SetItemProperty("health_potion", "health", 50);
    SetItemProperty("greater_healing", "health", 120);
    SetItemProperty("elixir_of_life", "health", 300);
    
    // Зелья временных бафов
    SetItemProperty("potion_of_strength", "temp_strength", 5);
    SetItemProperty("potion_of_intellect", "temp_intelligence", 5);
    SetItemProperty("potion_of_protection", "temp_defense", 5);
    
    // Зелья для экспедиций
    SetItemProperty("potion_of_success", "expedition_success_bonus", 15);
    SetItemProperty("potion_of_gold", "expedition_gold_bonus", 20);
    
    // Свитки
    SetItemProperty("scroll_teleport", "instant_complete", true);
    SetItemProperty("scroll_protection", "defense_multiplier", 1.5);
    SetItemProperty("scroll_fortune", "reward_multiplier", 2.0);
    SetItemProperty("scroll_haste", "expedition_speed", 0.7);
}

function SetItemProperty(item_id, property, value) {
    var item_data = ds_map_find_value(global.ItemDB, item_id);
    if (item_data != undefined) {
        ds_map_add(item_data, property, value);
    }
}
function debug_shop_items() {
    if (!variable_global_exists("shop_items") || !variable_global_exists("current_shop_page_items")) return;
    
    show_debug_message("=== ДЕБАГ МАГАЗИНА ===");
    show_debug_message("Всего предметов в магазине: " + string(array_length(global.shop_items)));
    
    // Показываем все предметы в магазине
    for (var i = 0; i < array_length(global.shop_items); i++) {
        var item_id = global.shop_items[i];
        var item_data = ds_map_find_value(global.ItemDB, item_id);
        if (item_data != -1) {
            show_debug_message("Магазин[" + string(i) + "]: " + item_data[? "name"] + " (ID: " + item_id + ")");
        }
    }
    
    // Показываем предметы на текущей странице
    show_debug_message("--- Текущая страница ---");
    for (var i = 0; i < array_length(global.current_shop_page_items); i++) {
        var item_info = global.current_shop_page_items[i];
        var item_data = ds_map_find_value(global.ItemDB, item_info.item_id);
        if (item_data != -1) {
            show_debug_message("Страница[" + string(i) + "]: " + item_data[? "name"] + " (ID: " + item_info.item_id + ")");
        }
    }
    show_debug_message("=====================");
}
// scr_shop_system.gml
// Новая система магазина

global.shop_categories = ["WEAPONS", "ARMOR", "POTIONS", "SPECIAL"];
global.shop_current_category = 0;
global.shop_reputation = 0;
global.shop_reputation_level = 0;
global.shop_daily_deals = [];
global.shop_last_refresh = 0;

// scr_shop_system.gml
// Улучшенная система магазина с пагинацией

function init_shop_system() {
    show_debug_message("Инициализация системы магазина...");
    
    // Увеличиваем количество категорий до 5
    global.shop_categories = ["WEAPONS", "ARMOR", "POTIONS", "SPECIAL", "DAILY_DEALS"];
    global.shop_current_category = 0;
    global.shop_reputation = 0;
    global.shop_reputation_level = 0;
    global.shop_daily_deals = [];
    global.shop_last_refresh = current_time;
    
    // Инициализация пагинации для категорий - теперь для 5 категорий
    global.shop_category_pages = [];
    global.shop_category_current_page = [];
    global.shop_items_per_category_page = 6;
    
    for (var i = 0; i < array_length(global.shop_categories); i++) {
        var category_items = get_shop_items_by_category(i);
        var total_pages = max(1, ceil(array_length(category_items) / global.shop_items_per_category_page));
        array_push(global.shop_category_pages, total_pages);
        array_push(global.shop_category_current_page, 0);
    }
    
    // Инициализация ежедневных сделок
    init_daily_deals();
    
    show_debug_message("Система магазина с пагинацией инициализирована: " + string(array_length(global.shop_categories)) + " категорий");
}

function get_shop_items_by_category(category_index) {
    var category_items = [];
    
    if (!variable_global_exists("ItemDB") || !ds_exists(global.ItemDB, ds_type_map)) {
        return category_items;
    }
    
    // Обработка ежедневных сделок (5-я категория)
    if (category_index == 4) {
        // Возвращаем предметы из ежедневных сделок
        for (var i = 0; i < array_length(global.shop_daily_deals); i++) {
            array_push(category_items, global.shop_daily_deals[i].item_id);
        }
        return category_items;
    }
    
    var map = ds_map_create();
    var count = ds_map_size(global.ItemDB);
    var key = ds_map_find_first(global.ItemDB);
    
    for (var i = 0; i < count; i++) {
        var item = ds_map_find_value(global.ItemDB, key);
        var item_type = item[? "type"];
        var include_item = false;
        
        switch(category_index) {
            case 0: // WEAPONS
                include_item = (item_type == global.ITEM_TYPE.WEAPON);
                break;
            case 1: // ARMOR
                include_item = (item_type == global.ITEM_TYPE.ARMOR);
                break;
            case 2: // POTIONS
                include_item = (item_type == global.ITEM_TYPE.POTION || item_type == global.ITEM_TYPE.SCROLL);
                break;
            case 3: // SPECIAL
                include_item = (item[? "rarity"] >= 2); // Редкие и выше
                break;
        }
        
        if (include_item) {
            array_push(category_items, key);
        }
        key = ds_map_find_next(global.ItemDB, key);
    }
    ds_map_destroy(map);
    
    return category_items;
}

function get_current_category_items() {
    // Защитная проверка
    if (global.shop_current_category < 0 || global.shop_current_category >= array_length(global.shop_category_pages)) {
        global.shop_current_category = 0;
    }
    
    var category_items = get_shop_items_by_category(global.shop_current_category);
    var current_page = global.shop_category_current_page[global.shop_current_category];
    var items_per_page = global.shop_items_per_category_page;
    
    var start_index = current_page * items_per_page;
    var end_index = min(start_index + items_per_page, array_length(category_items));
    
    var current_page_items = [];
    for (var i = start_index; i < end_index; i++) {
        array_push(current_page_items, category_items[i]);
    }
    
    return current_page_items;
}
function change_shop_category_page(direction) {
    // Защитная проверка
    if (global.shop_current_category < 0 || global.shop_current_category >= array_length(global.shop_category_pages)) {
        global.shop_current_category = 0;
    }
    
    var current_page = global.shop_category_current_page[global.shop_current_category];
    var total_pages = global.shop_category_pages[global.shop_current_category];
    
    if (direction == 1) { // Вперед
        if (current_page < total_pages - 1) {
            global.shop_category_current_page[global.shop_current_category] = current_page + 1;
        }
    } else if (direction == -1) { // Назад
        if (current_page > 0) {
            global.shop_category_current_page[global.shop_current_category] = current_page - 1;
        }
    }
}


function get_current_category_page_info() {
    // Защитная проверка
    if (global.shop_current_category < 0 || global.shop_current_category >= array_length(global.shop_category_pages)) {
        global.shop_current_category = 0;
    }
    
    var current_page = global.shop_category_current_page[global.shop_current_category];
    var total_pages = global.shop_category_pages[global.shop_current_category];
    var category_items = get_shop_items_by_category(global.shop_current_category);
    var total_items = array_length(category_items);
    var start_item = current_page * global.shop_items_per_category_page + 1;
    var end_item = min((current_page + 1) * global.shop_items_per_category_page, total_items);
    
    return {
        current_page: current_page + 1,
        total_pages: total_pages,
        total_items: total_items,
        start_item: start_item,
        end_item: end_item
    };
}

function calculate_discounted_price(item_id) {
    var item_data = ds_map_find_value(global.ItemDB, item_id);
    if (item_data == -1) return 0;
    
    var base_price = item_data[? "price"];
    // Простая реализация без скидок
    return base_price;
}

function add_shop_reputation(amount) {
    global.shop_reputation += amount;
}

function start_training(companion_index) {
    if (companion_index >= 0 && companion_index < array_length(global.companions)) {
        var companion = global.companions[companion_index];
        var arena = global.arenas[companion_index];
        
        if (companion.unlocked && !companion.training && arena.unlocked) {
            companion.training = true;
            companion.training_progress = 0;
            companion.last_training_time = current_time; // Запоминаем время начала
            arena.active = true;
            add_notification(companion.name + " отправилась на бесконечную тренировку!");
        }
    }
}

/// @function complete_training_early(companion_index)
/// @description Завершает тренировку помощницы и начисляет накопленный опыт
/// @param {real} companion_index - Индекс помощницы в массиве global.companions
function complete_training_early(companion_index) {
    if (companion_index < 0 || companion_index >= array_length(global.companions)) {
        show_debug_message("Ошибка: Неверный индекс помощницы: " + string(companion_index));
        return false;
    }
    
    var companion = global.companions[companion_index];
    var arena = global.arenas[companion_index];
    
    if (!companion.training || !arena.active) {
        show_debug_message("Ошибка: Помощница не на тренировке!");
        return false;
    }
    
    // Начисляем накопленный опыт
    var exp_gained = companion.training_progress;
    if (exp_gained > 0) {
        add_companion_exp(companion_index, exp_gained);
    }
    
    // Завершаем тренировку
    companion.training = false;
    companion.training_progress = 0;
    arena.active = false;
    
    add_notification(companion.name + " завершила тренировку! +" + string(exp_gained) + " опыта");
    return true;
}

function update_trainings() {
    for (var i = 0; i < array_length(global.companions); i++) {
        var companion = global.companions[i];
        if (companion.training) {
            // Накапливаем опыт каждую секунду (при 60 FPS)
            companion.training_progress += companion.training_rate;
            
            // Автоматическое начисление опыта каждые 10 секунд для обратной связи
            if (companion.training_progress >= 10) {
                var exp_to_add = floor(companion.training_progress);
                add_companion_exp(i, exp_to_add);
                companion.training_progress -= exp_to_add;
            }
        }
    }
}

/// @function add_companion_exp_in_expedition()
/// @description Добавляет опыт всем активным помощницам в экспедиции
function add_companion_exp_in_expedition() {
    if (!global.expedition.active) return;
    
    var base_exp = 5 * (global.expedition.difficulty + 1);
    
    for (var i = 0; i < array_length(global.companions); i++) {
        var companion = global.companions[i];
        // Даем опыт только разблокированным помощницам, которые в отряде (не на тренировке)
        if (companion.unlocked && !companion.training) {
            add_companion_exp(i, base_exp);
        }
    }
}

function stop_training(companion_index) {
    if (companion_index >= 0 && companion_index < array_length(global.companions)) {
        var companion = global.companions[companion_index];
        var arena = global.arenas[companion_index];
        
        // Начисляем накопленный опыт при остановке
        if (companion.training_progress > 0) {
            add_companion_exp(companion_index, floor(companion.training_progress));
        }
        
        companion.training = false;
        companion.training_progress = 0;
        arena.active = false;
        add_notification(companion.name + " вернулась из тренировки");
    }
}
// Функция завершения тренировки
function complete_arena_training() {
    var companion_index = 0; // Hepo
    add_companion_exp(companion_index, 25);
    add_notification("Тренировка на арене Hepo завершена!");
    training_progress = 0;
    global.arena_training_active = false;
}
function point_in_rectangle(px, py, x1, y1, x2, y2) {
    return (px >= x1 && px <= x2 && py >= y1 && py <= y2);
}

function add_notification(message) {
    if (!variable_global_exists("notifications")) {
        global.notifications = [];
    }
    
    array_push(global.notifications, {
        message: message,
        timer: 360 // 3 секунды
    });
}
function get_rarity_name(rarity) {
    switch(rarity) {
        case 0: return "Обычный";
        case 1: return "Необычный"; 
        case 2: return "Редкий";
        case 3: return "Эпический";
        case 4: return "Легендарный";
        case 5: return "Мифический";
        case 6: return "Божественный";
        case 7: return "Космический";
        case 8: return "Божественный+";
        case 9: return "Абсолютный";
        case 10: return "КОНЦЕПТУАЛЬНЫЙ";
        default: return "Неизвестно";
    }
}

function get_rainbow_color() {
    // Радужный эффект для космических предметов
    var time = global.frame_count * 0.1;
    var r = (sin(time) * 127 + 128);
    var g = (sin(time + 2) * 127 + 128);
    var b = (sin(time + 4) * 127 + 128);
    return make_color_rgb(r, g, b);
}

function get_animated_divine_color() {
    // Анимированный цвет для концептуальных предметов
    var time = global.frame_count * 0.2;
    var pulse = (sin(time) * 0.5 + 0.5);
    return merge_color(make_color_rgb(255, 255, 0), make_color_rgb(255, 0, 0), pulse);
}

function merge_color(color1, color2, ratio) {
    var r1 = color_get_red(color1);
    var g1 = color_get_green(color1);
    var b1 = color_get_blue(color1);
    
    var r2 = color_get_red(color2);
    var g2 = color_get_green(color2);
    var b2 = color_get_blue(color2);
    
    var r = r1 + (r2 - r1) * ratio;
    var g = g1 + (g2 - g1) * ratio;
    var b = b1 + (b2 - b1) * ratio;
    
    return make_color_rgb(r, g, b);
}

/// @function sin(angle)
/// @description Возвращает синус угла в радианах
/// @param {real} angle - Угол в радианах
/// @return {real} Значение синуса

function sin(angle) {
    return dsin(angle);
}

/// @function cos(angle)
/// @description Возвращает косинус угла в радианах
/// @param {real} angle - Угол в радианах
/// @return {real} Значение косинуса

function cos(angle) {
    return dcos(angle);
}
/// @function abs(value)
/// @description Возвращает абсолютное значение числа
/// @param {real} value - Число
/// @return {real} Абсолютное значение

function abs(value) {
    if (value < 0) return -value;
    return value;
}

/// @function clamp(value, min, max)
/// @description Ограничивает значение между минимумом и максимумом
/// @param {real} value - Исходное значение
/// @param {real} min - Минимальное значение
/// @param {real} max - Максимальное значение
/// @return {real} Ограниченное значение

function clamp(value, min, max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
}

/// @function max(a, b)
/// @description Возвращает максимальное из двух чисел
/// @param {real} a - Первое число
/// @param {real} b - Второе число
/// @return {real} Максимальное число

function max(a, b) {
    if (a > b) return a;
    return b;
}

/// @function min(a, b)
/// @description Возвращает минимальное из двух чисел
/// @param {real} a - Первое число
/// @param {real} b - Второе число
/// @return {real} Минимальное число

function min(a, b) {
    if (a < b) return a;
    return b;
}

/// @function round(value)
/// @description Округляет число до ближайшего целого
/// @param {real} value - Число для округления
/// @return {real} Округленное число

function round(value) {
    return floor(value + 0.5);
}
function wrap_text(text, max_width, font) {
    // Проверяем, что текст не пустой и max_width достаточно большой
    if (string_length(text) == 0 || max_width < 10) {
        return text; // Возвращаем текст как есть, если ширина слишком мала
    }
    
    // Проверяем, что шрифт корректен
    if (font == -1) {
        font = fnt_main;
    }
    
    var words = string_split(text, " ");
    var current_line = "";
    var result = "";
    
    for (var i = 0; i < array_length(words); i++) {
        var test_line = current_line == "" ? words[i] : current_line + " " + words[i];
        var test_width = string_width_ext(test_line, -1, font);
        
        if (test_width <= max_width) {
            current_line = test_line;
        } else {
            if (current_line != "") {
                result += current_line + "\n";
            }
            current_line = words[i];
        }
    }
    
    if (current_line != "") {
        result += current_line;
    }
    
    // Ограничиваем количество строк (максимум 2)
    var lines = string_split(result, "\n");
    if (array_length(lines) > 2) {
        result = lines[0] + "\n" + string_copy(lines[1], 1, min(string_length(lines[1]), 30)) + "...";
    }
    
    return result;
}
/// @function array_join(array, separator)
/// @description Объединяет элементы массива в строку с разделителем
/// @param {array} array - Массив для объединения
/// @param {string} separator - Разделитель
/// @return {string} Объединенная строка

function array_join(array, separator) {
    if (array_length(array) == 0) return "";
    
    var result = array[0];
    for (var i = 1; i < array_length(array); i++) {
        result += separator + array[i];
    }
    return result;
}

/// @function string_split(string, delimiter)
/// @description Разделяет строку на массив по разделителю
/// @param {string} string - Строка для разделения
/// @param {string} delimiter - Разделитель
/// @return {array} Массив подстрок

function string_split(string, delimiter) {
    var result = [];
    var current = "";
    
    for (var i = 1; i <= string_length(string); i++) {
        var char = string_char_at(string, i);
        if (char == delimiter) {
            if (current != "") {
                array_push(result, current);
                current = "";
            }
        } else {
            current += char;
        }
    }
    
    if (current != "") {
        array_push(result, current);
    }
    
    return result;
}
global.game_data = noone;




// scr_shop_enhancements.gml
// Улучшения для магазина с поддержкой больших чисел
function draw_elite_item_tooltip(x, y, width, item_data) {
    var tooltip_height = 200;
    var tooltip_y = y - tooltip_height - 10;
    
    // Фон тултипа
    draw_set_color(ui_bg_dark);
    draw_rectangle(x, tooltip_y, x + width, tooltip_y + tooltip_height, false);
    
    // Рамка цвета редкости
    var rarity_color = get_rarity_color(item_data[? "rarity"]);
    draw_set_color(rarity_color);
    draw_rectangle(x, tooltip_y, x + width, tooltip_y + 4, false);
    
    // Название
    draw_set_color(ui_text);
    draw_set_halign(fa_center);
    draw_text(x + width/2, tooltip_y + 15, item_data[? "name"]);
    draw_set_halign(fa_left);
    
    // Редкость
    var rarity_name = get_rarity_name(item_data[? "rarity"]);
    draw_set_color(rarity_color);
    draw_set_halign(fa_center);
    draw_text(x + width/2, tooltip_y + 35, rarity_name);
    draw_set_halign(fa_left);
    
    // Описание
    draw_set_color(ui_text_secondary);
    draw_set_font(fnt_small);
    draw_text_ext(x + 10, tooltip_y + 55, item_data[? "description"], width - 20, 80);
    draw_set_font(fnt_main);
    
    // Бонусы
    var bonus_y = tooltip_y + 120;
    draw_set_color(ui_text);
    
    if (item_data[? "strength_bonus"] > 0) {
        draw_text(x + 10, bonus_y, "💪 Сила: +" + string(item_data[? "strength_bonus"]));
        bonus_y += 20;
    }
    if (item_data[? "intelligence_bonus"] > 0) {
        draw_text(x + 10, bonus_y, "🧠 Интеллект: +" + string(item_data[? "intelligence_bonus"]));
        bonus_y += 20;
    }
    if (item_data[? "defense_bonus"] > 0) {
        draw_text(x + 10, bonus_y, "🛡️ Защита: +" + string(item_data[? "defense_bonus"]));
        bonus_y += 20;
    }
    if (item_data[? "health_bonus"] > 0) {
        draw_text(x + 10, bonus_y, "❤️ Здоровье: +" + string(item_data[? "health_bonus"]));
        bonus_y += 20;
    }
    if (item_data[? "gold_bonus"] > 0) {
        draw_text(x + 10, bonus_y, "💰 Золото: +" + string(item_data[? "gold_bonus"]) + "%");
        bonus_y += 20;
    }
    
    // Рамка
    draw_set_color(ui_border_color);
    draw_rectangle(x, tooltip_y, x + width, tooltip_y + tooltip_height, true);
}

function update_shop_system_for_elite_items() {
    // Увеличиваем максимальный уровень репутации для больших скидок
    global.shop_max_reputation_level = 20;
    global.shop_reputation_discount_per_level = 2; // 2% за уровень
    
    // Обновляем расчет скидки
    var reputation_discount = min(global.shop_reputation_level * global.shop_reputation_discount_per_level, 40); // Макс 40% скидка
    return reputation_discount;
}

function calculate_elite_discount(item_id) {
    var base_price = ds_map_find_value(global.ItemDB, item_id)[? "price"];
    var reputation_discount = min(global.shop_reputation_level * 2, 40);
    
    // Дополнительная скидка для очень дорогих предметов
    var elite_discount = 0;
    if (base_price >= 100000000) { // 100M+
        elite_discount = 10;
    }
    if (base_price >= 500000000) { // 500M+
        elite_discount = 15;
    }
    if (base_price >= 1000000000) { // 1B+
        elite_discount = 20;
    }
    
    var total_discount = reputation_discount + elite_discount;
    return max(1, floor(base_price * (100 - total_discount) / 100));
}
// Функция безопасной продажи с проверками
function safe_sell_item(item_index, quantity) {
    // Проверяем существование инвентаря
    if (!variable_global_exists("playerInventory") || !ds_exists(global.playerInventory, ds_type_list)) {
        show_debug_message("Ошибка: Инвентарь не инициализирован!");
        return false;
    }
    
    // Проверяем корректность индекса
    if (item_index < 0 || item_index >= ds_list_size(global.playerInventory)) {
        show_debug_message("Ошибка: Неверный индекс предмета: " + string(item_index));
        return false;
    }
    
    // Получаем данные предмета
    var item_data = ds_list_find_value(global.playerInventory, item_index);
    if (is_undefined(item_data)) {
        show_debug_message("Ошибка: Данные предмета не найдены!");
        return false;
    }
    
    // Проверяем существование необходимых полей
    if (!variable_struct_exists(item_data, "id") || !variable_struct_exists(item_data, "quantity")) {
        show_debug_message("Ошибка: Структура предмета некорректна!");
        return false;
    }
    
    // Вызываем основную функцию продажи
    return sell_item(item_index, quantity);
}
// scr_inventory_system.gml - добавьте эту функцию

function use_item_from_inventory(cell_index) {
    show_debug_message("=== ИСПОЛЬЗОВАНИЕ ПРЕДМЕТА ИЗ ИНВЕНТАРЯ ===");
    
    // Проверяем существование инвентаря
    if (!variable_global_exists("playerInventory") || !ds_exists(global.playerInventory, ds_type_list)) {
        show_debug_message("Ошибка: Инвентарь не инициализирован!");
        return false;
    }
    
    // Проверяем корректность индекса
    if (cell_index < 0 || cell_index >= ds_list_size(global.playerInventory)) {
        show_debug_message("Ошибка: Неверный индекс предмета: " + string(cell_index));
        return false;
    }
    
    // Получаем данные предмета из инвентаря
    var item_data = ds_list_find_value(global.playerInventory, cell_index);
    if (is_undefined(item_data)) {
        show_debug_message("Ошибка: Данные предмета не найдены!");
        return false;
    }
    
    var item_id = item_data[? "id"];
    
    // Проверяем существование базы данных предметов
    if (!variable_global_exists("ItemDB") || !ds_exists(global.ItemDB, ds_type_map)) {
        show_debug_message("Ошибка: База данных предметов не инициализирована!");
        return false;
    }
    
    // Получаем полные данные предмета из базы
    var db_data = ds_map_find_value(global.ItemDB, item_id);
    if (db_data == -1) {
        show_debug_message("Ошибка: Предмет с ID " + string(item_id) + " не найден в базе данных!");
        return false;
    }
    
    var item_type = db_data[? "type"];
    var item_name = db_data[? "name"];
    
    // Проверяем, можно ли использовать этот предмет
    if (item_type != global.ITEM_TYPE.POTION && item_type != global.ITEM_TYPE.SCROLL) {
        add_notification("Этот предмет нельзя использовать!");
        return false;
    }
    
    // Используем предмет
    var success = use_potion(item_id);
    
    if (success) {
        add_notification("Использовано: " + item_name);
    } else {
        add_notification("Не удалось использовать: " + item_name);
    }
    
    return success;
}
// scr_inventory_system.gml - добавьте эту функцию

function unequip_item_from_slot(hero_index, slot_type) {
    show_debug_message("=== СНЯТИЕ ПРЕДМЕТА С ЭКИПИРОВКИ ===");
    
    // Проверяем существование слотов экипировки
    if (!variable_global_exists("equipment_slots")) {
        show_debug_message("Ошибка: equipment_slots не инициализирован!");
        return false;
    }
    
    // Проверяем корректность индекса героя
    if (hero_index < 0 || hero_index >= array_length(global.equipment_slots)) {
        show_debug_message("Ошибка: Неверный индекс героя: " + string(hero_index));
        return false;
    }
    
    // Получаем ID предмета из слота
    var item_id = variable_struct_get(global.equipment_slots[hero_index], slot_type);
    
    // Проверяем, не пустой ли слот
    if (item_id == -1) {
        add_notification("Слот экипировки пуст!");
        return false;
    }
    
    // Вызываем основную функцию снятия предмета
    var success = UnequipItem(hero_index, slot_type);
    
    if (success) {
        add_notification("Предмет снят с " + get_hero_name(hero_index));
    } else {
        add_notification("Не удалось снять предмет!");
    }
    
    return success;
}