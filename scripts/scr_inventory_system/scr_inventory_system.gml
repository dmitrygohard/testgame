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

    // Всегда работаем с экипировкой главного героя по умолчанию
    global.selected_hero_index = 0;

    init_trophy_system();

    ensure_equipment_set_structs();
    update_equipment_set_bonuses();
}

function ensure_equipment_set_structs() {
    ensure_equipment_bonus_defaults();

    if (!variable_struct_exists(global.hero, "equipment_set_bonuses")) {
        global.hero.equipment_set_bonuses = {
            strength: 0,
            agility: 0,
            intelligence: 0,
            defense: 0,
            max_health: 0,
            gold_bonus: 0,
            health_bonus: 0
        };
    }

    if (!variable_struct_exists(global.hero, "active_sets")) {
        global.hero.active_sets = [];
    }

    if (!variable_global_exists("equipment_set_effects")) {
        global.equipment_set_effects = {
            reward_multiplier: 1.0,
            speed_multiplier: 1.0,
            success_bonus: 0
        };
    }
}

function ensure_equipment_bonus_defaults() {
    if (!variable_global_exists("hero")) {
        return;
    }

    if (!variable_struct_exists(global.hero, "equipment_bonuses") || !is_struct(global.hero.equipment_bonuses)) {
        global.hero.equipment_bonuses = {};
    }

    var fields = ["strength", "agility", "intelligence", "defense", "max_health", "gold_bonus", "health_bonus", "perm_strength", "perm_intelligence", "perm_agility"];
    for (var i = 0; i < array_length(fields); i++) {
        var field = fields[i];
        if (!variable_struct_exists(global.hero.equipment_bonuses, field)) {
            variable_struct_set(global.hero.equipment_bonuses, field, 0);
        }
    }
}

function reapply_hero_artifact_effects() {
    if (!variable_global_exists("equipment_slots") || array_length(global.equipment_slots) == 0) {
        return;
    }
    if (!variable_global_exists("ItemDB") || !ds_exists(global.ItemDB, ds_type_map)) {
        return;
    }

    var hero_equipment = global.equipment_slots[0];
    var slot_names = ["weapon", "armor", "accessory", "relic"];
    for (var i = 0; i < array_length(slot_names); i++) {
        var slot_name = slot_names[i];
        if (!variable_struct_exists(hero_equipment, slot_name)) {
            continue;
        }
        var item_id = variable_struct_get(hero_equipment, slot_name);
        if (item_id != -1) {
            apply_artifact_effects(item_id, true);
        }
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

    var _itemClass = _itemData[? "item_class"];
    var _isTrophy = (_itemData[? "type"] == global.ITEM_TYPE.TROPHY) || (_itemClass == "trophy");

    if (_isTrophy) {
        if (inventory_contains_item(_itemId)) {
            return false;
        }
        _quantity = 1;
    }

    var _stackable = _itemData[? "stackable"];
    var _maxStack = _itemData[? "maxStack"];

    // Поиск существующего стака для стакающихся предметов
    if (_stackable && !_isTrophy) {
        for (var i = 0; i < ds_list_size(global.playerInventory); i++) {
            var _invItem = ds_list_find_value(global.playerInventory, i);
            if (ds_exists(_invItem, ds_type_map) && _invItem[? "id"] == _itemId) {
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

function inventory_contains_item(_itemId) {
    if (!variable_global_exists("playerInventory") || !ds_exists(global.playerInventory, ds_type_list)) {
        return false;
    }

    for (var i = 0; i < ds_list_size(global.playerInventory); i++) {
        var _invItem = ds_list_find_value(global.playerInventory, i);
        if (ds_exists(_invItem, ds_type_map) && _invItem[? "id"] == _itemId) {
            return true;
        }
    }

    return false;
}

function inventory_clear_all() {
    if (!variable_global_exists("playerInventory") || !ds_exists(global.playerInventory, ds_type_list)) {
        return;
    }

    for (var i = ds_list_size(global.playerInventory) - 1; i >= 0; i--) {
        var entry = ds_list_find_value(global.playerInventory, i);
        if (ds_exists(entry, ds_type_map)) {
            ds_map_destroy(entry);
        }
        ds_list_delete(global.playerInventory, i);
    }
}

function apply_artifact_effects(item_id, silent = false) {
    show_debug_message("Применение эффектов артефакта: " + item_id);
    
    switch(item_id) {
        case "omnipotence_crown":
            // Корона Всесилия - позволяет запускать все экспедиции одновременно
            global.simultaneous_expeditions = true;
            if (!silent) add_notification("👑 КОРОНА ВСЕСИЛИЯ: Теперь можно запускать все экспедиции одновременно!");
            break;

        case "aegis":
            // Эгида - авто-повтор для первых трех экспедиций
            global.expedition_auto_repeat.enabled = true;
            for (var i = 0; i < 3; i++) {
                global.expedition_auto_repeat.difficulties[i] = true;
            }
            if (!silent) add_notification("🛡️ ЭГИДА: Первые 3 экспедиции теперь на авто-повторе!");
            break;

        case "gungnir":
            // Гунгнир - авто-повтор для четвертой экспедиции
            global.expedition_auto_repeat.enabled = true;
            global.expedition_auto_repeat.difficulties[3] = true;
            if (!silent) add_notification("🔱 ГУНГНИР: Сложная экспедиция теперь на авто-повторе!");
            break;

        case "concept_of_victory":
            // Концепция Победы - самая интересная механика
            global.expedition_instant_complete_chance = 15; // 15% шанс мгновенного завершения
            global.expedition_reward_multiplier = 2.5; // 2.5x награда
            if (!silent) add_notification("🎯 КОНЦЕПЦИЯ ПОБЕДЫ: Шанс мгновенного завершения + увеличение наград!");
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
    
    ensure_equipment_bonus_defaults();

    // Обновляем систему бафов от предметов
    if (variable_global_exists("update_companion_buff_system")) {
        update_companion_buff_system();
    }
   // Безопасно добавляем бонусы с проверкой на существование
    var perm_strength = db_data[? "perm_strength"];
    if (!is_undefined(perm_strength)) {
        global.hero.equipment_bonuses.perm_strength = global.hero.equipment_bonuses.perm_strength + perm_strength;
        global.hero.strength = global.hero.strength + perm_strength;
    }

    var perm_intelligence = db_data[? "perm_intelligence"];
    if (!is_undefined(perm_intelligence)) {
        global.hero.equipment_bonuses.perm_intelligence = global.hero.equipment_bonuses.perm_intelligence + perm_intelligence;
        global.hero.intelligence = global.hero.intelligence + perm_intelligence;
    }

    var perm_agility = db_data[? "perm_agility"];
    if (!is_undefined(perm_agility)) {
        global.hero.equipment_bonuses.perm_agility = global.hero.equipment_bonuses.perm_agility + perm_agility;
        global.hero.agility = global.hero.agility + perm_agility;
    }

    // БЕЗОПАСНО ПРИМЕНЯЕМ ВСЕ БОНУСЫ ОТ ПРЕДМЕТА (С ПРОВЕРКОЙ НА СУЩЕСТВОВАНИЕ)
    var strength_bonus = db_data[? "strength_bonus"];
    if (!is_undefined(strength_bonus)) {
        global.hero.equipment_bonuses.strength = global.hero.equipment_bonuses.strength + strength_bonus;
    }

    var agility_bonus = db_data[? "agility_bonus"];
    if (!is_undefined(agility_bonus)) {
        global.hero.equipment_bonuses.agility = global.hero.equipment_bonuses.agility + agility_bonus;
    }

    var intelligence_bonus = db_data[? "intelligence_bonus"];
    if (!is_undefined(intelligence_bonus)) {
        global.hero.equipment_bonuses.intelligence = global.hero.equipment_bonuses.intelligence + intelligence_bonus;
    }

    var defense_bonus = db_data[? "defense_bonus"];
    if (!is_undefined(defense_bonus)) {
        global.hero.equipment_bonuses.defense = global.hero.equipment_bonuses.defense + defense_bonus;
    }

    var max_health_bonus = db_data[? "max_health_bonus"];
    if (!is_undefined(max_health_bonus)) {
        global.hero.equipment_bonuses.max_health = global.hero.equipment_bonuses.max_health + max_health_bonus;
    }

    var gold_bonus = db_data[? "gold_bonus"];
    if (!is_undefined(gold_bonus)) {
        global.hero.equipment_bonuses.gold_bonus = global.hero.equipment_bonuses.gold_bonus + gold_bonus;
    }

    var health_bonus = db_data[? "health_bonus"];
    if (!is_undefined(health_bonus)) {
        global.hero.equipment_bonuses.health_bonus = global.hero.equipment_bonuses.health_bonus + health_bonus;
    }
    
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

    update_equipment_set_bonuses();

    add_notification("Экипировано: " + db_data[? "name"]);
    return true;
}

function UnequipItem(_character_index, _slot_type) {
    if (!variable_global_exists("equipment_slots")) {
        show_debug_message("Ошибка: equipment_slots не инициализирован!");
        return false;
    }
	
    var total_slots = array_length(global.equipment_slots);
    if (_character_index < 0 || _character_index >= total_slots) {
        show_debug_message("Ошибка: индекс персонажа вне диапазона при снятии предмета.");
        return false;
    }
	
    var slot_struct = global.equipment_slots[_character_index];
    if (!is_struct(slot_struct) || !variable_struct_exists(slot_struct, _slot_type)) {
        show_debug_message("Ошибка: указанный слот экипировки не найден.");
        return false;
    }
	
    var item_id = variable_struct_get(slot_struct, _slot_type);
    if (is_undefined(item_id) || item_id == -1) {
        return false;
    }
	
    if (!variable_global_exists("ItemDB") || !ds_exists(global.ItemDB, ds_type_map)) {
        show_debug_message("Ошибка: база данных предметов не инициализирована.");
        return false;
    }

    var item_data = ds_map_find_value(global.ItemDB, item_id);
    if (item_data == -1) {show_debug_message("Ошибка: предмет с ID " + string(item_id) + " не найден в базе данных.");
        return false;
    }

    if (!variable_global_exists("hero")) {
        show_debug_message("Ошибка: герой не инициализирован при попытке снять предмет.");
        return false;
    }

    ensure_equipment_bonus_defaults();

    var strength_bonus = item_data[? "strength_bonus"];
    if (!is_undefined(strength_bonus)) {
        global.hero.equipment_bonuses.strength = global.hero.equipment_bonuses.strength - strength_bonus;
    }

    var agility_bonus = item_data[? "agility_bonus"];
    if (!is_undefined(agility_bonus)) {
        global.hero.equipment_bonuses.agility = global.hero.equipment_bonuses.agility - agility_bonus;
    }

    var intelligence_bonus = item_data[? "intelligence_bonus"];
    if (!is_undefined(intelligence_bonus)) {
        global.hero.equipment_bonuses.intelligence = global.hero.equipment_bonuses.intelligence - intelligence_bonus;
    }

    var defense_bonus = item_data[? "defense_bonus"];
    if (!is_undefined(defense_bonus)) {
        global.hero.equipment_bonuses.defense = global.hero.equipment_bonuses.defense - defense_bonus;
    }

    var max_health_bonus = item_data[? "max_health_bonus"];
    if (!is_undefined(max_health_bonus)) {
        global.hero.equipment_bonuses.max_health = global.hero.equipment_bonuses.max_health - max_health_bonus;
    }

    var gold_bonus = item_data[? "gold_bonus"];
    if (!is_undefined(gold_bonus)) {
        global.hero.equipment_bonuses.gold_bonus = global.hero.equipment_bonuses.gold_bonus - gold_bonus;
    }

    var health_bonus = item_data[? "health_bonus"];
    if (!is_undefined(health_bonus)) {
        global.hero.equipment_bonuses.health_bonus = global.hero.equipment_bonuses.health_bonus - health_bonus;
    }

    var perm_strength = item_data[? "perm_strength"];
    if (!is_undefined(perm_strength)) {
        global.hero.equipment_bonuses.perm_strength = global.hero.equipment_bonuses.perm_strength - perm_strength;
        global.hero.strength = global.hero.strength - perm_strength;
    }

    var perm_agility = item_data[? "perm_agility"];
    if (!is_undefined(perm_agility)) {
        global.hero.equipment_bonuses.perm_agility = global.hero.equipment_bonuses.perm_agility - perm_agility;
        global.hero.agility = global.hero.agility - perm_agility;
    }

    var perm_intelligence = item_data[? "perm_intelligence"];
    if (!is_undefined(perm_intelligence)) {
        global.hero.equipment_bonuses.perm_intelligence = global.hero.equipment_bonuses.perm_intelligence - perm_intelligence;
        global.hero.intelligence = global.hero.intelligence - perm_intelligence;
    }

    remove_artifact_effects(item_id);

    variable_struct_set(slot_struct, _slot_type, -1);

    if (!AddItemToInventory(item_id, 1)) {
        show_debug_message("Предупреждение: не удалось вернуть предмет в инвентарь после снятия.");
    }

    if (variable_global_exists("calculate_companion_bonuses")) {
        calculate_companion_bonuses();
    }

    if (variable_global_exists("update_hero_max_health")) {
        update_hero_max_health();
    }

    update_equipment_set_bonuses();

    if (variable_global_exists("update_companion_buff_system")) {
        update_companion_buff_system();
    }

    var item_name = item_data[? "name"];
    if (is_undefined(item_name)) {
        item_name = "Предмет";
    }

    add_notification("Снято: " + string(item_name));

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

        if (!ds_exists(_invItem, ds_type_map)) {
            i++;
            continue;
        }

        // Если найден нужный предмет
        if (_invItem[? "id"] == _itemId) {
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
function init_item_sets() {
    reset_item_set_map();

    define_item_set("storm_legacy", "Наследие Бури", "Штормовое", "Арсенал, выкованный молниями и закаленный в циклонах.");
    add_set_piece("storm_legacy", "stormcallers_edge");
    add_set_piece("storm_legacy", "tempest_plate");
    add_set_piece("storm_legacy", "cyclone_loop");
    add_set_piece("storm_legacy", "eye_of_typhoon");
    add_set_bonus("storm_legacy", 2, "Шторм ускоряет удары: +4 силы, +6 ловкости.", { strength: 4, agility: 6 });
    add_set_bonus("storm_legacy", 3, "Электрический панцирь: +10 защиты и +40 здоровья.", { defense: 10, max_health: 40 });
    add_set_bonus("storm_legacy", 4, "Буря несёт богатства: награды +35%, успех +5%.", { agility: 4 }, { reward_multiplier: 1.35, success_bonus: 5 });

    define_item_set("arcane_paradox", "Арканический парадокс", "Хрономантия", "Инструменты, переплетающие время, знания и риск.");
    add_set_piece("arcane_paradox", "paradox_staff");
    add_set_piece("arcane_paradox", "chronoweave_robe");
    add_set_piece("arcane_paradox", "loop_of_infinite_ink");
    add_set_piece("arcane_paradox", "timebound_tome");
    add_set_bonus("arcane_paradox", 2, "Сознание вне времени: +8 интеллекта, +2 защиты.", { intelligence: 8, defense: 2 });
    add_set_bonus("arcane_paradox", 3, "Сферы замедляют угрозы: +5 ловкости, +60 здоровья.", { agility: 5, max_health: 60 });
    add_set_bonus("arcane_paradox", 4, "Временные петли: экспедиции быстрее на 20%, успех +7%.", { intelligence: 5 }, { speed_multiplier: 0.8, success_bonus: 7 });

    define_item_set("iron_frontier", "Ковенант железного фронтира", "Осада", "Неодолимый оплот, удерживающий самый тяжёлый натиск.");
    add_set_piece("iron_frontier", "frontier_bastion");
    add_set_piece("iron_frontier", "bulwark_carapace");
    add_set_piece("iron_frontier", "sentinel_seal");
    add_set_piece("iron_frontier", "heart_of_citadels");
    add_set_bonus("iron_frontier", 2, "Живая крепость: +12 защиты и +30 здоровья.", { defense: 12, max_health: 30 });
    add_set_bonus("iron_frontier", 3, "Контрудар гарнизона: +6 силы и +6 защиты.", { strength: 6, defense: 6 });
    add_set_bonus("iron_frontier", 4, "Панцирь гарнизона: награды +20%, успех +10%.", { max_health: 50 }, { reward_multiplier: 1.2, success_bonus: 10 });
}

// scr_init_item_database.gml

function scr_init_item_database() {
    show_debug_message("Инициализация расширенной базы данных предметов...");

    if (variable_global_exists("ItemDB") && ds_exists(global.ItemDB, ds_type_map)) {
        ds_map_destroy(global.ItemDB);
    }

    global.ItemDB = ds_map_create();

    // Типы предметов
    global.ITEM_TYPE = {
        WEAPON: 0,
        ARMOR: 1,
        POTION: 2,
        RESOURCE: 3,
        ACCESSORY: 4,
        SCROLL: 5,
        RELIC: 6,
        TROPHY: 7
    };

    // Слоты экипировки
    global.EQUIP_SLOT = {
        WEAPON: 0,
        ARMOR: 1,
        ACCESSORY: 2,
        RELIC: 3
    };

    init_item_sets();

    var equipment_definitions = [
        { id: "wanderer_blade", name: "Клинок странника", type: global.ITEM_TYPE.WEAPON, price: 80, desc: "Бывший меч новобранца, привыкший к дальним дорогам.", strength: 3, agility: 1, slot: global.EQUIP_SLOT.WEAPON, rarity: 0 },
        { id: "sapling_wand", name: "Посох ростка", type: global.ITEM_TYPE.WEAPON, price: 85, desc: "Живая древесина усиливает природную магию.", intelligence: 4, slot: global.EQUIP_SLOT.WEAPON, rarity: 0 },
        { id: "scout_sling", name: "Праща разведчика", type: global.ITEM_TYPE.WEAPON, price: 75, desc: "Метает камни с точностью опытного скаута.", strength: 1, agility: 2, slot: global.EQUIP_SLOT.WEAPON, rarity: 0 },
        { id: "linen_coat", name: "Льняной колет", type: global.ITEM_TYPE.ARMOR, price: 60, desc: "Лёгкая защита, впитавшая запахи первой экспедиции.", defense: 3, intelligence: 1, slot: global.EQUIP_SLOT.ARMOR, rarity: 0 },
        { id: "stone_guard", name: "Каменный нагрудник", type: global.ITEM_TYPE.ARMOR, price: 95, desc: "Пластина из полированного гранита.", defense: 5, max_health: 20, slot: global.EQUIP_SLOT.ARMOR, rarity: 0 },
        { id: "windrunner_boots", name: "Ботинки вихря", type: global.ITEM_TYPE.ARMOR, price: 110, desc: "Подошвы нашиты перьями, ускоряющими шаг.", agility: 3, defense: 1, slot: global.EQUIP_SLOT.ARMOR, rarity: 1 },
        { id: "ember_ring", name: "Углистый перстень", type: global.ITEM_TYPE.ACCESSORY, price: 140, desc: "Удерживает тёплый жар костра.", strength: 2, gold: 4, slot: global.EQUIP_SLOT.ACCESSORY, rarity: 1 },
        { id: "mindfocus_charm", name: "Амулет сосредоточения", type: global.ITEM_TYPE.ACCESSORY, price: 155, desc: "Тонкий рисунок уравновешивает мысли.", intelligence: 3, defense: 1, slot: global.EQUIP_SLOT.ACCESSORY, rarity: 1 },
        { id: "ironbark_brooch", name: "Брошь железокора", type: global.ITEM_TYPE.ACCESSORY, price: 150, desc: "Кора, напитанная минералами, усиливает стойкость.", defense: 2, max_health: 25, slot: global.EQUIP_SLOT.ACCESSORY, rarity: 1 },
        { id: "resonant_totem", name: "Резонансный тотем", type: global.ITEM_TYPE.RELIC, price: 220, desc: "Впитывает отголоски побед и переводит их в силу.", strength: 2, intelligence: 2, slot: global.EQUIP_SLOT.RELIC, rarity: 1 },
        { id: "aurora_tablet", name: "Пластина авроры", type: global.ITEM_TYPE.RELIC, price: 260, desc: "Хранит северное сияние, укрепляя тело.", defense: 3, max_health: 30, slot: global.EQUIP_SLOT.RELIC, rarity: 1 },
        { id: "sunsteel_sabre", name: "Сабля солнечной стали", type: global.ITEM_TYPE.WEAPON, price: 620, desc: "Рубит так же быстро, как рассвет рассеивает тьму.", strength: 6, agility: 2, slot: global.EQUIP_SLOT.WEAPON, rarity: 2 },
        { id: "starseer_staff", name: "Посох звёздочёта", type: global.ITEM_TYPE.WEAPON, price: 640, desc: "Хранит фрагменты ночного неба.", intelligence: 7, defense: 1, slot: global.EQUIP_SLOT.WEAPON, rarity: 2 },
        { id: "stormstriker_bow", name: "Лук грозового удара", type: global.ITEM_TYPE.WEAPON, price: 660, desc: "Тетива впитывает статический заряд.", strength: 3, agility: 5, slot: global.EQUIP_SLOT.WEAPON, rarity: 2 },
        { id: "duskcarapace", name: "Сумеречный панцирь", type: global.ITEM_TYPE.ARMOR, price: 720, desc: "Заглушает звуки шагов и гасит удары.", defense: 9, agility: 2, slot: global.EQUIP_SLOT.ARMOR, rarity: 2 },
        { id: "astral_mantle", name: "Астральная мантия", type: global.ITEM_TYPE.ARMOR, price: 780, desc: "Глифы усиливают поток маны.", intelligence: 6, defense: 4, slot: global.EQUIP_SLOT.ARMOR, rarity: 2 },
        { id: "shadowmantle", name: "Плащ теней", type: global.ITEM_TYPE.ARMOR, price: 740, desc: "Скрывает силуэт и помогает уклоняться.", agility: 6, defense: 3, slot: global.EQUIP_SLOT.ARMOR, rarity: 2 },
        { id: "rallying_girdle", name: "Пояс воодушевления", type: global.ITEM_TYPE.ACCESSORY, price: 520, desc: "Собирает силу отряда в одно целое.", strength: 4, defense: 2, slot: global.EQUIP_SLOT.ACCESSORY, rarity: 2 },
        { id: "stargazer_band", name: "Кольцо звёздочёта", type: global.ITEM_TYPE.ACCESSORY, price: 540, desc: "Излучает мягкий свет, очищающий разум.", intelligence: 5, agility: 1, slot: global.EQUIP_SLOT.ACCESSORY, rarity: 2 },
        { id: "whisper_cloak", name: "Покров шёпота", type: global.ITEM_TYPE.ACCESSORY, price: 510, desc: "Волокна шёлка гасят любое движение.", agility: 4, max_health: 20, slot: global.EQUIP_SLOT.ACCESSORY, rarity: 2 },
        { id: "aurora_relic", name: "Реликвия рассвета", type: global.ITEM_TYPE.RELIC, price: 920, desc: "Сияние усиливает магические навыки.", intelligence: 4, defense: 2, slot: global.EQUIP_SLOT.RELIC, rarity: 2 },
        { id: "stoneward_idol", name: "Идол каменного стража", type: global.ITEM_TYPE.RELIC, price: 960, desc: "Призывает терпение древних големов.", defense: 5, max_health: 40, slot: global.EQUIP_SLOT.RELIC, rarity: 2 },
        { id: "echoing_compass", name: "Отголосочный компас", type: global.ITEM_TYPE.RELIC, price: 980, desc: "Ведёт к скрытым артефактам.", gold: 10, defense: 2, slot: global.EQUIP_SLOT.RELIC, rarity: 2 },
        { id: "hepo_ancient_tome", name: "Древний фолиант Хэпо", type: global.ITEM_TYPE.ACCESSORY, price: 1500, desc: "Хэпо изучает забытые тактики, усиливая отряд.", intelligence: 8, slot: global.EQUIP_SLOT.ACCESSORY, rarity: 3 },
        { id: "fatty_energy_crystal", name: "Энергетический кристалл Фэтти", type: global.ITEM_TYPE.ACCESSORY, price: 1600, desc: "Хранит сладкую энергию для длинных походов.", defense: 3, max_health: 60, slot: global.EQUIP_SLOT.ACCESSORY, rarity: 3 },
        { id: "discipline_golden_scale", name: "Золотые весы Дисциплины", type: global.ITEM_TYPE.ACCESSORY, price: 1550, desc: "Отмеряет выгоду каждой экспедиции.", intelligence: 4, gold: 12, slot: global.EQUIP_SLOT.ACCESSORY, rarity: 3 },
        { id: "trinity_medallion", name: "Медальон троицы", type: global.ITEM_TYPE.ACCESSORY, price: 5200, desc: "Синхронизирует такт всех помощниц.", strength: 5, intelligence: 5, defense: 5, slot: global.EQUIP_SLOT.ACCESSORY, rarity: 4 },
        { id: "expedition_compass", name: "Компас экспедиций", type: global.ITEM_TYPE.ACCESSORY, price: 4800, desc: "Показывает кратчайший путь через хаос.", agility: 2, slot: global.EQUIP_SLOT.ACCESSORY, rarity: 4 },
        { id: "lucky_dice", name: "Игральные кости удачи", type: global.ITEM_TYPE.ACCESSORY, price: 4900, desc: "Каждый бросок в пользу отряда.", gold: 18, slot: global.EQUIP_SLOT.ACCESSORY, rarity: 4 },
        { id: "stormcallers_edge", name: "Клинок штормов", type: global.ITEM_TYPE.WEAPON, price: 18500, desc: "Вызывает грозу с каждым взмахом.", strength: 9, agility: 6, slot: global.EQUIP_SLOT.WEAPON, rarity: 4, set_id: "storm_legacy", set_piece_name: "Клинок" },
        { id: "tempest_plate", name: "Панцирь бури", type: global.ITEM_TYPE.ARMOR, price: 17800, desc: "Проводит молнии вдоль контуров брони.", agility: 4, defense: 12, slot: global.EQUIP_SLOT.ARMOR, rarity: 4, set_id: "storm_legacy", set_piece_name: "Панцирь" },
        { id: "cyclone_loop", name: "Кольцо циклона", type: global.ITEM_TYPE.ACCESSORY, price: 16200, desc: "Невидимые вихри защищают владельца.", agility: 5, gold: 8, slot: global.EQUIP_SLOT.ACCESSORY, rarity: 4, set_id: "storm_legacy", set_piece_name: "Кольцо" },
        { id: "eye_of_typhoon", name: "Око тайфуна", type: global.ITEM_TYPE.RELIC, price: 17500, desc: "Хранит тишину внутри шторма.", intelligence: 4, agility: 4, defense: 4, slot: global.EQUIP_SLOT.RELIC, rarity: 4, set_id: "storm_legacy", set_piece_name: "Реликвия" },
        { id: "paradox_staff", name: "Посох парадокса", type: global.ITEM_TYPE.WEAPON, price: 19000, desc: "Преломляет время, позволяя видеть будущее удара.", intelligence: 10, defense: 2, slot: global.EQUIP_SLOT.WEAPON, rarity: 4, set_id: "arcane_paradox", set_piece_name: "Посох" },
        { id: "chronoweave_robe", name: "Хронопокров", type: global.ITEM_TYPE.ARMOR, price: 18600, desc: "Каждая нить сплетена с прошедшим и будущим моментом.", intelligence: 8, max_health: 60, slot: global.EQUIP_SLOT.ARMOR, rarity: 4, set_id: "arcane_paradox", set_piece_name: "Одеяние" },
        { id: "loop_of_infinite_ink", name: "Петля бесконечных чернил", type: global.ITEM_TYPE.ACCESSORY, price: 17300, desc: "Записывает все возможные исходы сражения.", intelligence: 6, gold: 6, slot: global.EQUIP_SLOT.ACCESSORY, rarity: 4, set_id: "arcane_paradox", set_piece_name: "Аксессуар" },
        { id: "timebound_tome", name: "Том за пределами времени", type: global.ITEM_TYPE.RELIC, price: 18800, desc: "Перелистывает страницы быстрее течения часов.", intelligence: 7, defense: 3, slot: global.EQUIP_SLOT.RELIC, rarity: 4, set_id: "arcane_paradox", set_piece_name: "Реликвия" },
        { id: "frontier_bastion", name: "Цитадель фронтира", type: global.ITEM_TYPE.WEAPON, price: 20000, desc: "Массивное копьё, служащее подвижной стеной.", strength: 9, defense: 6, slot: global.EQUIP_SLOT.WEAPON, rarity: 4, set_id: "iron_frontier", set_piece_name: "Оружие" },
        { id: "bulwark_carapace", name: "Панцирь бастиона", type: global.ITEM_TYPE.ARMOR, price: 19800, desc: "Стягивает металлические пластины в непробиваемую оболочку.", defense: 14, max_health: 40, slot: global.EQUIP_SLOT.ARMOR, rarity: 4, set_id: "iron_frontier", set_piece_name: "Броня" },
        { id: "sentinel_seal", name: "Печать стража", type: global.ITEM_TYPE.ACCESSORY, price: 17600, desc: "Закрепляет присягу стоять до конца.", defense: 5, max_health: 40, slot: global.EQUIP_SLOT.ACCESSORY, rarity: 4, set_id: "iron_frontier", set_piece_name: "Печать" },
        { id: "heart_of_citadels", name: "Сердце цитаделей", type: global.ITEM_TYPE.RELIC, price: 20500, desc: "Пульс крепостей звучит внутри артефакта.", defense: 6, max_health: 80, slot: global.EQUIP_SLOT.RELIC, rarity: 4, set_id: "iron_frontier", set_piece_name: "Ядро" }
    ];

    for (var i = 0; i < array_length(equipment_definitions); i++) {
        var def = equipment_definitions[i];
        var strength = is_undefined(def.strength) ? 0 : def.strength;
        var intelligence = is_undefined(def.intelligence) ? 0 : def.intelligence;
        var defense = is_undefined(def.defense) ? 0 : def.defense;
        var agility = is_undefined(def.agility) ? 0 : def.agility;
        var max_health = is_undefined(def.max_health) ? 0 : def.max_health;
        var health = is_undefined(def.health) ? 0 : def.health;
        var gold = is_undefined(def.gold) ? 0 : def.gold;
        var slot = is_undefined(def.slot) ? -1 : def.slot;
        var rarity = is_undefined(def.rarity) ? 0 : def.rarity;
        var stackable = is_undefined(def.stackable) ? false : def.stackable;
        var maxStack = is_undefined(def.maxStack) ? 1 : def.maxStack;
        var item_class = is_undefined(def.item_class) ? "standard" : def.item_class;
        var set_id = is_undefined(def.set_id) ? "" : def.set_id;
        var set_piece_name = is_undefined(def.set_piece_name) ? "" : def.set_piece_name;

        AddItemToDB(def.id, def.name, def.type, def.price, def.desc, strength, intelligence, defense, slot, rarity, stackable, maxStack, item_class, agility, max_health, health, gold, set_id, set_piece_name);
    }

    var potion_definitions = [
        { id: "health_potion", name: "Зелье здоровья", price: 50, desc: "Восстанавливает здоровье после стычки.", rarity: 0, maxStack: 10 },
        { id: "greater_healing", name: "Сильное зелье здоровья", price: 120, desc: "Быстро залечивает глубокие раны.", rarity: 1, maxStack: 5 },
        { id: "elixir_of_life", name: "Эликсир жизни", price: 320, desc: "Редкий настой, возвращающий силу.", rarity: 2, maxStack: 3 },
        { id: "potion_of_strength", name: "Зелье силы", price: 220, desc: "+5 к силе на следующую экспедицию.", rarity: 1, maxStack: 5 },
        { id: "potion_of_intellect", name: "Зелье интеллекта", price: 220, desc: "+5 к интеллекту на следующую экспедицию.", rarity: 1, maxStack: 5 },
        { id: "potion_of_protection", name: "Зелье защиты", price: 220, desc: "+5 к защите на следующую экспедицию.", rarity: 1, maxStack: 5 },
        { id: "potion_of_success", name: "Зелье успеха", price: 310, desc: "Повышает шансы на удачу в экспедиции.", rarity: 2, maxStack: 3 },
        { id: "potion_of_gold", name: "Золотое зелье", price: 340, desc: "Увеличивает трофеи со следующей вылазки.", rarity: 2, maxStack: 3 }
    ];

    for (var p = 0; p < array_length(potion_definitions); p++) {
        var pd = potion_definitions[p];
        AddItemToDB(pd.id, pd.name, global.ITEM_TYPE.POTION, pd.price, pd.desc, 0, 0, 0, -1, pd.rarity, true, pd.maxStack);

    }

    var scroll_definitions = [
        { id: "scroll_teleport", name: "Свиток телепортации", price: 420, desc: "Мгновенно завершает экспедицию.", rarity: 2 },
        { id: "scroll_protection", name: "Свиток защиты", price: 360, desc: "+50% защиты на следующую экспедицию.", rarity: 1 },
        { id: "scroll_fortune", name: "Свиток удачи", price: 520, desc: "Удваивает награды следующей вылазки.", rarity: 2 },
        { id: "scroll_haste", name: "Свиток скорости", price: 610, desc: "Ускоряет завершение экспедиции.", rarity: 2 }
    ];

    for (var s = 0; s < array_length(scroll_definitions); s++) {
        var sd = scroll_definitions[s];
        AddItemToDB(sd.id, sd.name, global.ITEM_TYPE.SCROLL, sd.price, sd.desc, 0, 0, 0, -1, sd.rarity, true, 3);
    }

    var trophy_definitions = [
        { id: "trophy_first_victory", name: "Знамя первопроходца", desc: "Символ первой победы в экспедиции." },
        { id: "trophy_perfect_run", name: "Безупречный шлем", desc: "Даруется за поход без единой царапины." },
        { id: "trophy_gilded_ledger", name: "Позолоченный реестр", desc: "Подтверждает внушительные накопления." },
        { id: "trophy_training_mosaic", name: "Мозаика наставника", desc: "Собрана из осколков долгих тренировок." }
    ];

    for (var t = 0; t < array_length(trophy_definitions); t++) {
        var td = trophy_definitions[t];
        AddItemToDB(td.id, td.name, global.ITEM_TYPE.TROPHY, 0, td.desc, 0, 0, 0, -1, 5, false, 1, "trophy");

    }

    // Добавляем свойства для зелий и свитков

    AddItemProperties();

    // Добавляем свойства для редких предметов с бафами

    AddCompanionBuffProperties();

    show_debug_message("Расширенная база данных предметов успешно инициализирована: " + string(ds_map_size(global.ItemDB)) + " предметов");
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

    // Трофеи
    SetItemProperty("trophy_first_victory", "trophy_condition", "Победите свою первую экспедицию.");
    SetItemProperty("trophy_first_victory", "icon", "🏁");

    SetItemProperty("trophy_perfect_run", "trophy_condition", "Завершите экспедицию без получения урона.");
    SetItemProperty("trophy_perfect_run", "icon", "🛡️");

    SetItemProperty("trophy_gilded_ledger", "trophy_condition", "Накопите 5000 золота сразу.");
    SetItemProperty("trophy_gilded_ledger", "icon", "💰");

    SetItemProperty("trophy_training_mosaic", "trophy_condition", "Завершите тренировку с 100+ накопленного опыта.");
    SetItemProperty("trophy_training_mosaic", "icon", "🎓");
}

function SetItemProperty(item_id, property, value) {
    var item_data = ds_map_find_value(global.ItemDB, item_id);
    if (item_data != undefined) {
        ds_map_add(item_data, property, value);
    }
}

function AddItemToDB(_id, _name, _type, _price, _desc, _str_bonus = 0, _int_bonus = 0, _def_bonus = 0, _equip_slot = -1, _rarity = 0, _stackable = false, _maxStack = 1, _item_class = "standard", _agility_bonus = 0, _max_health_bonus = 0, _health_bonus = 0, _gold_bonus = 0, _set_id = "", _set_piece_name = "") {
    if (!variable_global_exists("ItemDB") || !ds_exists(global.ItemDB, ds_type_map)) {
        global.ItemDB = ds_map_create();
    }

    if (!is_string(_item_class)) {
        _gold_bonus = _item_class;
        _item_class = "standard";
    }

    if (ds_map_exists(global.ItemDB, _id)) {
        var existing = ds_map_find_value(global.ItemDB, _id);
        if (ds_exists(existing, ds_type_map)) {
            ds_map_destroy(existing);
        }
        ds_map_delete(global.ItemDB, _id);
    }

    var item = ds_map_create();
    ds_map_add(item, "id", _id);
    ds_map_add(item, "name", _name);
    ds_map_add(item, "type", _type);
    ds_map_add(item, "price", _price);
    ds_map_add(item, "description", _desc);
    ds_map_add(item, "rarity", _rarity);
    ds_map_add(item, "equip_slot", _equip_slot);
    ds_map_add(item, "stackable", _stackable);
    ds_map_add(item, "maxStack", max(1, _maxStack));
    ds_map_add(item, "item_class", _item_class);
    ds_map_add(item, "set_id", _set_id);
    ds_map_add(item, "set_piece_name", _set_piece_name);

    ds_map_add(item, "strength_bonus", _str_bonus);
    ds_map_add(item, "agility_bonus", _agility_bonus);
    ds_map_add(item, "intelligence_bonus", _int_bonus);
    ds_map_add(item, "defense_bonus", _def_bonus);
    ds_map_add(item, "max_health_bonus", _max_health_bonus);
    ds_map_add(item, "health_bonus", _health_bonus);
    ds_map_add(item, "gold_bonus", _gold_bonus);

    // Заглушки для временных эффектов и специальных свойств
    ds_map_add(item, "temp_strength", 0);
    ds_map_add(item, "temp_agility", 0);
    ds_map_add(item, "temp_intelligence", 0);
    ds_map_add(item, "temp_defense", 0);
    ds_map_add(item, "expedition_success_bonus", 0);
    ds_map_add(item, "expedition_gold_bonus", 0);
    ds_map_add(item, "instant_complete", false);
    ds_map_add(item, "defense_multiplier", 0);
    ds_map_add(item, "reward_multiplier", 0);
    ds_map_add(item, "expedition_speed", 0);

    // Трофейные поля по умолчанию
    ds_map_add(item, "icon", "");
    ds_map_add(item, "trophy_condition", "");

    if (_item_class == "trophy") {
        item[? "stackable"] = false;
        item[? "maxStack"] = 1;
    }

    ds_map_add(global.ItemDB, _id, item);
    return item;
}

function ensure_item_set_map() {
    if (!variable_global_exists("ItemSets") || !ds_exists(global.ItemSets, ds_type_map)) {
        global.ItemSets = ds_map_create();
    }
}

function reset_item_set_map() {
    ensure_item_set_map();

    var keys = ds_map_keys_to_array(global.ItemSets);
    for (var i = 0; i < array_length(keys); i++) {
        var key = keys[i];
        var set_map = ds_map_find_value(global.ItemSets, key);
        if (set_map != -1) {
            ds_map_destroy(set_map);
        }
    }

    ds_map_clear(global.ItemSets);
}

function define_item_set(_id, _name, _theme, _description) {
    ensure_item_set_map();

    if (ds_map_exists(global.ItemSets, _id)) {
        var old_set = ds_map_find_value(global.ItemSets, _id);
        if (old_set != -1) {
            ds_map_destroy(old_set);
        }
        ds_map_delete(global.ItemSets, _id);
    }

    var set = ds_map_create();
    ds_map_add(set, "id", _id);
    ds_map_add(set, "name", _name);
    ds_map_add(set, "theme", _theme);
    ds_map_add(set, "description", _description);
    ds_map_add(set, "pieces", []);
    ds_map_add(set, "bonuses", []);

    ds_map_add(global.ItemSets, _id, set);

    return set;
}

function array_index_of(arr, value) {
    for (var i = 0; i < array_length(arr); i++) {
        if (arr[i] == value) {
            return i;
        }
    }
    return -1;
}

function add_set_piece(_set_id, _item_id) {
    if (!variable_global_exists("ItemSets") || !ds_exists(global.ItemSets, ds_type_map)) {
        return;
    }

    if (!ds_map_exists(global.ItemSets, _set_id)) {
        return;
    }

    var set = ds_map_find_value(global.ItemSets, _set_id);
    if (set == -1) {
        return;
    }

    var pieces = set[? "pieces"];
    if (array_index_of(pieces, _item_id) == -1) {
        array_push(pieces, _item_id);
        set[? "pieces"] = pieces;
    }
}

function sort_set_bonus_array(bonuses) {
    for (var i = 0; i < array_length(bonuses); i++) {
        for (var j = i + 1; j < array_length(bonuses); j++) {
            if (bonuses[j].count < bonuses[i].count) {
                var temp = bonuses[i];
                bonuses[i] = bonuses[j];
                bonuses[j] = temp;
            }
        }
    }

    return bonuses;
}

function add_set_bonus(_set_id, _count, _description, _stats = undefined, _effects = undefined) {
    if (!variable_global_exists("ItemSets") || !ds_exists(global.ItemSets, ds_type_map)) {
        return;
    }

    if (!ds_map_exists(global.ItemSets, _set_id)) {
        return;
    }

    var set = ds_map_find_value(global.ItemSets, _set_id);
    if (set == -1) {
        return;
    }

    var entry = {
        count: _count,
        description: _description,
        stats: is_undefined(_stats) ? {} : _stats,
        effects: is_undefined(_effects) ? {} : _effects
    };

    var bonuses = set[? "bonuses"];
    array_push(bonuses, entry);
    bonuses = sort_set_bonus_array(bonuses);
    set[? "bonuses"] = bonuses;
}

function get_set_definition(set_id) {
    if (!variable_global_exists("ItemSets") || !ds_exists(global.ItemSets, ds_type_map)) {
        return -1;
    }
    if (!ds_map_exists(global.ItemSets, set_id)) {
        return -1;
    }
    return ds_map_find_value(global.ItemSets, set_id);
}

function get_equipped_set_piece_count(set_id) {
    if (!variable_global_exists("equipment_slots")) {
        return 0;
    }

    if (!variable_global_exists("ItemDB") || !ds_exists(global.ItemDB, ds_type_map)) {
        return 0;
    }

    var hero_equipment = global.equipment_slots[0];
    var slot_names = ["weapon", "armor", "accessory", "relic"];
    var count = 0;

    for (var i = 0; i < array_length(slot_names); i++) {
        var slot_name = slot_names[i];
        if (!variable_struct_exists(hero_equipment, slot_name)) {
            continue;
        }

        var item_id = variable_struct_get(hero_equipment, slot_name);
        if (item_id == -1) {
            continue;
        }

        var item_data = ds_map_find_value(global.ItemDB, item_id);
        if (item_data == -1) {
            continue;
        }

        var set_id_item = item_data[? "set_id"];
        if (!is_undefined(set_id_item) && set_id_item == set_id) {
            count++;
        }
    }

    return count;
}

function is_item_equipped(item_id) {
    if (!variable_global_exists("equipment_slots")) {
        return false;
    }

    var hero_equipment = global.equipment_slots[0];
    var slot_names = ["weapon", "armor", "accessory", "relic"];

    for (var i = 0; i < array_length(slot_names); i++) {
        var slot = slot_names[i];
        if (variable_struct_exists(hero_equipment, slot) && variable_struct_get(hero_equipment, slot) == item_id) {
            return true;
        }
    }

    return false;
}

function reset_equipment_set_bonuses() {
    ensure_equipment_set_structs();

    var fields = ["strength", "agility", "intelligence", "defense", "max_health", "gold_bonus", "health_bonus"];
    for (var i = 0; i < array_length(fields); i++) {
        var field = fields[i];
        var previous = variable_struct_get(global.hero.equipment_set_bonuses, field);
        if (!is_undefined(previous) && variable_struct_exists(global.hero.equipment_bonuses, field)) {
            var current = variable_struct_get(global.hero.equipment_bonuses, field);
            variable_struct_set(global.hero.equipment_bonuses, field, current - previous);
        }
        variable_struct_set(global.hero.equipment_set_bonuses, field, 0);
    }

    global.hero.active_sets = [];

    global.equipment_set_effects.reward_multiplier = 1.0;
    global.equipment_set_effects.speed_multiplier = 1.0;
    global.equipment_set_effects.success_bonus = 0;
}

function apply_set_stat_bonus(field, value) {
    if (value == 0) {
        return;
    }

    if (!variable_struct_exists(global.hero.equipment_bonuses, field)) {
        variable_struct_set(global.hero.equipment_bonuses, field, 0);
    }

    var current = variable_struct_get(global.hero.equipment_bonuses, field);
    variable_struct_set(global.hero.equipment_bonuses, field, current + value);

    var tracking = variable_struct_get(global.hero.equipment_set_bonuses, field);
    variable_struct_set(global.hero.equipment_set_bonuses, field, tracking + value);
}

function apply_set_stats(stats_struct) {
    if (!is_struct(stats_struct)) {
        return;
    }

    if (variable_struct_exists(stats_struct, "strength")) apply_set_stat_bonus("strength", stats_struct.strength);
    if (variable_struct_exists(stats_struct, "agility")) apply_set_stat_bonus("agility", stats_struct.agility);
    if (variable_struct_exists(stats_struct, "intelligence")) apply_set_stat_bonus("intelligence", stats_struct.intelligence);
    if (variable_struct_exists(stats_struct, "defense")) apply_set_stat_bonus("defense", stats_struct.defense);
    if (variable_struct_exists(stats_struct, "max_health")) apply_set_stat_bonus("max_health", stats_struct.max_health);
    if (variable_struct_exists(stats_struct, "gold_bonus")) apply_set_stat_bonus("gold_bonus", stats_struct.gold_bonus);
    if (variable_struct_exists(stats_struct, "health_bonus")) apply_set_stat_bonus("health_bonus", stats_struct.health_bonus);
}

function apply_set_effects(effect_struct) {
    if (!is_struct(effect_struct)) {
        return;
    }

    if (variable_struct_exists(effect_struct, "reward_multiplier")) {
        global.equipment_set_effects.reward_multiplier *= effect_struct.reward_multiplier;
    }

    if (variable_struct_exists(effect_struct, "speed_multiplier")) {
        global.equipment_set_effects.speed_multiplier *= effect_struct.speed_multiplier;
    }

    if (variable_struct_exists(effect_struct, "success_bonus")) {
        global.equipment_set_effects.success_bonus += effect_struct.success_bonus;
    }
}

function update_equipment_set_bonuses() {
    if (!variable_global_exists("ItemDB") || !ds_exists(global.ItemDB, ds_type_map)) {
        return;
    }

    ensure_equipment_set_structs();
    reset_equipment_set_bonuses();

    if (!variable_global_exists("ItemSets") || !ds_exists(global.ItemSets, ds_type_map)) {
        return;
    }

    if (!variable_global_exists("equipment_slots")) {
        return;
    }

    var hero_equipment = global.equipment_slots[0];
    var slot_names = ["weapon", "armor", "accessory", "relic"];
    var set_counts = {};

    for (var i = 0; i < array_length(slot_names); i++) {
        var slot_name = slot_names[i];
        if (!variable_struct_exists(hero_equipment, slot_name)) {
            continue;
        }

        var item_id = variable_struct_get(hero_equipment, slot_name);
        if (item_id == -1) {
            continue;
        }

        var item_data = ds_map_find_value(global.ItemDB, item_id);
        if (item_data == -1) {
            continue;
        }

        var set_id = item_data[? "set_id"];
        if (is_undefined(set_id) || set_id == "") {
            continue;
        }

        if (!variable_struct_exists(set_counts, set_id)) {
            variable_struct_set(set_counts, set_id, 0);
        }
        var current_count = variable_struct_get(set_counts, set_id);
        variable_struct_set(set_counts, set_id, current_count + 1);
    }

    var set_ids = variable_struct_get_names(set_counts);
    for (var s = 0; s < array_length(set_ids); s++) {
        var set_id = set_ids[s];
        var pieces_owned = variable_struct_get(set_counts, set_id);
        var set_data = get_set_definition(set_id);
        if (set_data == -1) {
            continue;
        }

        var total_pieces = array_length(set_data[? "pieces"]);
        var bonuses = set_data[? "bonuses"];
        var unlocked_descriptions = [];
        var next_description = "";

        for (var b = 0; b < array_length(bonuses); b++) {
            var bonus_entry = bonuses[b];
            if (pieces_owned >= bonus_entry.count) {
                apply_set_stats(bonus_entry.stats);
                apply_set_effects(bonus_entry.effects);
                array_push(unlocked_descriptions, bonus_entry.description);
            } else if (next_description == "") {
                next_description = string(bonus_entry.count) + " предмета: " + bonus_entry.description;
            }
        }

        var summary = {
            id: set_id,
            name: set_data[? "name"],
            theme: set_data[? "theme"],
            description: set_data[? "description"],
            owned: pieces_owned,
            total: total_pieces,
            unlocked: unlocked_descriptions,
            next: next_description,
            reward_multiplier: global.equipment_set_effects.reward_multiplier,
            speed_multiplier: global.equipment_set_effects.speed_multiplier,
            success_bonus: global.equipment_set_effects.success_bonus
        };

        array_push(global.hero.active_sets, summary);
    }

    if (variable_global_exists("update_hero_max_health")) {
        update_hero_max_health();
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

        if (include_item && (item_type == global.ITEM_TYPE.TROPHY || item[? "item_class"] == "trophy")) {
            include_item = false;
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
        check_training_trophies(exp_gained);
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

// ==================== ТРОФЕИ ====================

function init_trophy_system() {
    if (!variable_global_exists("trophy_catalog")) {
        global.trophy_catalog = [];
    }
    if (!variable_global_exists("trophy_lookup")) {
        global.trophy_lookup = ds_map_create();
    }
    if (!variable_global_exists("trophy_state")) {
        global.trophy_state = {};
    }
    if (!variable_global_exists("featured_trophies")) {
        global.featured_trophies = ["", "", ""];
    }
    if (!variable_global_exists("trophy_tracker")) {
        global.trophy_tracker = {
            total_expedition_wins: 0,
            gold_record: 0
        };
    }

    if (array_length(global.trophy_catalog) == 0) {
        register_trophy("trophy_first_victory", "🏁", "Знамя первопроходца", "Победите первую экспедицию.");
        register_trophy("trophy_perfect_run", "🛡️", "Безупречный шлем", "Завершите экспедицию без ранений героя.");
        register_trophy("trophy_gilded_ledger", "💰", "Позолоченный реестр", "Накопите 5000 золота.");
        register_trophy("trophy_training_mosaic", "🎓", "Мозаика наставника", "Завершите тренировку помощницы с 100 опытом.");
    }
}

function register_trophy(_id, _icon, _name, _condition) {
    var entry = {
        id: _id,
        icon: _icon,
        name: _name,
        condition: _condition
    };

    array_push(global.trophy_catalog, entry);
    ds_map_add(global.trophy_lookup, _id, entry);
}

function get_trophy_definition(_id) {
    if (ds_map_exists(global.trophy_lookup, _id)) {
        return ds_map_find_value(global.trophy_lookup, _id);
    }
    return undefined;
}

function is_trophy_unlocked(_id) {
    if (!variable_struct_exists(global.trophy_state, _id)) {
        return false;
    }
    return variable_struct_get(global.trophy_state, _id);
}

function unlock_trophy(_id) {
    if (is_trophy_unlocked(_id)) {
        return false;
    }

    variable_struct_set(global.trophy_state, _id, true);

    var trophy_data = get_trophy_definition(_id);
    if (trophy_data != undefined) {
        add_notification("🏆 Трофей получен: " + trophy_data.name);
    }

    if (!inventory_contains_item(_id)) {
        AddItemToInventory(_id, 1);
    }

    return true;
}

function check_trophies_after_expedition(_success, _gold_reward, _damage_taken) {
    if (!_success) return;

    global.trophy_tracker.total_expedition_wins++;
    global.trophy_tracker.gold_record = max(global.trophy_tracker.gold_record, global.gold);

    if (global.trophy_tracker.total_expedition_wins == 1) {
        unlock_trophy("trophy_first_victory");
    }

    if (_damage_taken <= 0) {
        unlock_trophy("trophy_perfect_run");
    }

    check_gold_trophies();
}

function check_gold_trophies() {
    if (global.gold >= 5000) {
        unlock_trophy("trophy_gilded_ledger");
    }
}

function check_training_trophies(_exp_gained) {
    if (_exp_gained >= 100) {
        unlock_trophy("trophy_training_mosaic");
    }
}

function toggle_featured_trophy(_id) {
    for (var i = 0; i < array_length(global.featured_trophies); i++) {
        if (global.featured_trophies[i] == _id) {
            global.featured_trophies[i] = "";
            return;
        }
    }

    for (var i = 0; i < array_length(global.featured_trophies); i++) {
        if (global.featured_trophies[i] == "") {
            global.featured_trophies[i] = _id;
            return;
        }
    }

    global.featured_trophies[0] = _id;
}

function clear_featured_slot(_slot_index) {
    if (_slot_index >= 0 && _slot_index < array_length(global.featured_trophies)) {
        global.featured_trophies[_slot_index] = "";
    }
}