function aty_generate_trinket_properties_safe(_item) {
    if (!is_struct(_item)) return;
    
    variable_struct_set(_item.stats, "crit_chance", 3 + irandom(4));
    variable_struct_set(_item.stats, "crit_damage", 5 + irandom(10));
}
function aty_generate_charm_properties_safe(_item) {
    if (!is_struct(_item)) return;
    
    variable_struct_set(_item.stats, "luck", 5 + irandom(5));
    variable_struct_set(_item.stats, "dodge_chance", 2 + irandom(3));
}

// =============================================================================
// SAFE STATS GENERATION
// =============================================================================

function aty_generate_item_stats_safe(_item) {
    if (!is_struct(_item)) return;
    
    // Базовые множители в зависимости от редкости
    var rarity_multiplier = 1 + (_item.rarity * 0.5);
    
    // Умножаем основные статы на множитель редкости
    var stat_keys = variable_struct_get_names(_item.stats);
    for (var i = 0; i < array_length(stat_keys); i++) {
        var stat_key = stat_keys[i];
        var current_value = variable_struct_get(_item.stats, stat_key);
        if (current_value > 0) {
            variable_struct_set(_item.stats, stat_key, round(current_value * rarity_multiplier));
        }
    }
}
// =============================================================================
// SAFE NAME AND DESCRIPTION GENERATION
// =============================================================================


function aty_generate_item_name_description_safe(_item) {
    if (!is_struct(_item)) return;
    
    var material_names = ["Деревянный", "Железный", "Стальной", "Серебряный", "Золотой", "Мифриловый", "Драконий", "Кристальный"];
    var type_names = ["Меч", "Броня", "Кольцо", "Амулет", "Талисман"];
    var rarity_names = ["Обычный", "Необычный", "Редкий", "Эпический", "Легендарный", "Мифический", "Божественный"];
    
    var material_index = clamp(_item.rarity, 0, array_length(material_names) - 1);
    var type_index = clamp(_item.item_type, 0, array_length(type_names) - 1);
    var rarity_index = clamp(_item.rarity, 0, array_length(rarity_names) - 1);
    
    _item.name = material_names[material_index] + " " + type_names[type_index];
    _item.description = rarity_names[rarity_index] + " предмет";
}


// =============================================================================
// BASIC ITEM FALLBACK
// =============================================================================
function aty_create_basic_item() {
    var item_types = [ITEM_TYPE.WEAPON, ITEM_TYPE.ARMOR, ITEM_TYPE.ACCESSORY, ITEM_TYPE.TRINKET, ITEM_TYPE.CHARM];
    var selected_type = item_types[irandom(array_length(item_types) - 1)];
    
    return {
        id: "item_" + string(irandom_range(10000, 99999)) + "_" + string(current_time),
        name: "Базовый предмет",
        description: "Обычный предмет без особых свойств",
        rarity: RARITY.COMMON,
        item_type: selected_type,
        slot: aty_convert_item_type_to_slot(selected_type),
        stats: {
            health: 0,
            mana: 0,
            attack_power: 0,
            magic_power: 0,
            defense: 0,
            crit_chance: 0,
            crit_damage: 0,
            attack_speed: 0,
            cast_speed: 0,
            dodge_chance: 0,
            block_chance: 0,
            lifesteal: 0,
            cooldown_reduction: 0,
            movement_speed: 0
        },
        price: 10,
        special_effects: []
    };
}

// =============================================================================
// ITEM UPGRADE SYSTEM
// =============================================================================

function aty_calculate_upgrade_cost(_item) {
    if (!is_struct(_item)) return 100;
    
    var base_cost = 100;
    var rarity_multiplier = 1;
    
    switch (_item.rarity) {
        case RARITY.COMMON: rarity_multiplier = 1; break;
        case RARITY.UNCOMMON: rarity_multiplier = 2; break;
        case RARITY.RARE: rarity_multiplier = 5; break;
        case RARITY.EPIC: rarity_multiplier = 10; break;
        case RARITY.LEGENDARY: rarity_multiplier = 25; break;
        case RARITY.MYTHIC: rarity_multiplier = 50; break;
        case RARITY.DIVINE: rarity_multiplier = 100; break;
        default: rarity_multiplier = 1;
    }
    
    return base_cost * rarity_multiplier;
}

function aty_upgrade_item(_item) {
    if (_item.upgrade_level >= _item.max_upgrade_level) {
        return false; // Достигнут максимальный уровень улучшения
    }
    
    var upgrade_cost = aty_calculate_upgrade_cost(_item);
    
    if (global.aty.hero.gold < upgrade_cost) {
        return false; // Недостаточно золота
    }
    
    // Списываем золото
    global.aty.hero.gold -= upgrade_cost;
    
    // Увеличиваем уровень улучшения
    _item.upgrade_level += 1;
    
    // Улучшаем характеристики (10% за уровень)
    var upgrade_multiplier = 1.0 + (_item.upgrade_level * 0.1);
    
    var stat_keys = variable_struct_get_names(_item.stats);
    for (var i = 0; i < array_length(stat_keys); i++) {
        var key = stat_keys[i];
        if (_item.stats[key] > 0) {
            _item.stats[key] = round(_item.stats[key] * upgrade_multiplier);
        }
    }
        // Обновляем квесты
    aty_on_item_upgraded();
    return true;
}

// =============================================================================
// GEM SOCKET SYSTEM
// =============================================================================

enum GEM_TYPE { RUBY, SAPPHIRE, EMERALD, DIAMOND, AMETHYST, TOPAZ }

function aty_create_gem_struct(_gem_type, _quality) {
    var gem = {
        gem_type: _gem_type,
        quality: _quality,
        stats: {},
        name: "",
        color: c_white
    };
    
    // Базовые статы для каждого типа камня
    switch (_gem_type) {
        case GEM_TYPE.RUBY:
            gem.stats.attack_power = 5 + (_quality * 3);
            gem.stats.crit_damage = 10 + (_quality * 5);
            gem.name = "Рубин";
            gem.color = make_color_rgb(255, 0, 0);
            break;
        case GEM_TYPE.SAPPHIRE:
            gem.stats.magic_power = 5 + (_quality * 3);
            gem.stats.mana = 20 + (_quality * 10);
            gem.name = "Сапфир";
            gem.color = make_color_rgb(0, 0, 255);
            break;
        case GEM_TYPE.EMERALD:
            gem.stats.health = 30 + (_quality * 15);
            gem.stats.defense = 3 + (_quality * 2);
            gem.name = "Изумруд";
            gem.color = make_color_rgb(0, 255, 0);
            break;
        case GEM_TYPE.DIAMOND:
            gem.stats.crit_chance = 2 + (_quality * 1);
            gem.stats.attack_speed = 3 + (_quality * 2);
            gem.name = "Алмаз";
            gem.color = make_color_rgb(255, 255, 255);
            break;
        case GEM_TYPE.AMETHYST:
            gem.stats.cast_speed = 5 + (_quality * 3);
            gem.stats.cooldown_reduction = 2 + (_quality * 1);
            gem.name = "Аметист";
            gem.color = make_color_rgb(128, 0, 128);
            break;
        case GEM_TYPE.TOPAZ:
            gem.stats.dodge_chance = 2 + (_quality * 1);
            gem.stats.movement_speed = 3 + (_quality * 2);
            gem.name = "Топаз";
            gem.color = make_color_rgb(255, 200, 0);
            break;
    }
    
    // Добавляем качество к названию
    var quality_names = ["", "Блестящий ", "Идеальный ", "Безупречный "];
    if (_quality < array_length(quality_names)) {
        gem.name = quality_names[_quality] + gem.name;
    }
    
    return gem;
}

function aty_socket_gem(_item, _gem, _socket_index) {
    if (_socket_index < 0 || _socket_index >= _item.sockets) {
        return false; // Неверный индекс сокета
    }
    
    if (_socket_index >= array_length(_item.socketed_gems)) {
        // Расширяем массив если нужно
        for (var i = array_length(_item.socketed_gems); i <= _socket_index; i++) {
            array_push(_item.socketed_gems, noone);
        }
    }
    
    // Если в слоте уже есть камень, извлекаем его
    if (is_struct(_item.socketed_gems[_socket_index])) {
        aty_unsocket_gem(_item, _socket_index);
    }
    
    // Вставляем новый камень
    _item.socketed_gems[_socket_index] = _gem;
    
    // Применяем статы камня к предмету
    var stat_keys = variable_struct_get_names(_gem.stats);
    for (var i = 0; i < array_length(stat_keys); i++) {
        var key = stat_keys[i];
        _item.stats[key] += _gem.stats[key];
    }
    
    return true;
}

function aty_unsocket_gem(_item, _socket_index) {
    if (_socket_index < 0 || _socket_index >= array_length(_item.socketed_gems)) {
        return noone;
    }
    
    var gem = _item.socketed_gems[_socket_index];
    
    if (!is_struct(gem)) {
        return noone;
    }
    
    // Убираем статы камня из предмета
    var stat_keys = variable_struct_get_names(gem.stats);
    for (var i = 0; i < array_length(stat_keys); i++) {
        var key = stat_keys[i];
        _item.stats[key] -= gem.stats[key];
    }
    
    _item.socketed_gems[_socket_index] = noone;
    
    return gem;
}
// =============================================================================
// SIMPLIFIED STAT GENERATION WITHOUT DANGEROUS OPERATIONS
// =============================================================================

function aty_generate_item_stats(_item) {
    if (!is_struct(_item)) return;
    
    var rarity_multiplier = aty_get_rarity_multiplier(_item.rarity);
    var material_multiplier = aty_get_material_multiplier(_item.material);
    var total_multiplier = rarity_multiplier * material_multiplier;
    
    // Умножаем каждый стат индивидуально с проверкой
    if (variable_struct_exists(_item.stats, "health")) 
        _item.stats.health = round(_item.stats.health * total_multiplier);
    if (variable_struct_exists(_item.stats, "mana")) 
        _item.stats.mana = round(_item.stats.mana * total_multiplier);
    if (variable_struct_exists(_item.stats, "attack_power")) 
        _item.stats.attack_power = round(_item.stats.attack_power * total_multiplier);
    if (variable_struct_exists(_item.stats, "magic_power")) 
        _item.stats.magic_power = round(_item.stats.magic_power * total_multiplier);
    if (variable_struct_exists(_item.stats, "defense")) 
        _item.stats.defense = round(_item.stats.defense * total_multiplier);
    if (variable_struct_exists(_item.stats, "crit_chance")) 
        _item.stats.crit_chance = round(_item.stats.crit_chance * total_multiplier);
    if (variable_struct_exists(_item.stats, "crit_damage")) 
        _item.stats.crit_damage = round(_item.stats.crit_damage * total_multiplier);
    if (variable_struct_exists(_item.stats, "attack_speed")) 
        _item.stats.attack_speed = round(_item.stats.attack_speed * total_multiplier);
    if (variable_struct_exists(_item.stats, "cast_speed")) 
        _item.stats.cast_speed = round(_item.stats.cast_speed * total_multiplier);
    if (variable_struct_exists(_item.stats, "dodge_chance")) 
        _item.stats.dodge_chance = round(_item.stats.dodge_chance * total_multiplier);
    if (variable_struct_exists(_item.stats, "block_chance")) 
        _item.stats.block_chance = round(_item.stats.block_chance * total_multiplier);
    if (variable_struct_exists(_item.stats, "lifesteal")) 
        _item.stats.lifesteal = round(_item.stats.lifesteal * total_multiplier);
    if (variable_struct_exists(_item.stats, "cooldown_reduction")) 
        _item.stats.cooldown_reduction = round(_item.stats.cooldown_reduction * total_multiplier);
    if (variable_struct_exists(_item.stats, "movement_speed")) 
        _item.stats.movement_speed = round(_item.stats.movement_speed * total_multiplier);
    
    // Добавляем случайные бонусные статы для редких предметов
    if (_item.rarity >= RARITY.RARE) {
        aty_add_random_bonus_stats_safe(_item);
    }
    
    // Добавляем сокеты для эпических и выше предметов
    if (_item.rarity >= RARITY.EPIC) {
        _item.sockets = 1 + (_item.rarity - RARITY.EPIC);
        _item.sockets = max(0, _item.sockets);
    }
}

function aty_get_rarity_multiplier(_rarity) {
    switch (_rarity) {
        case RARITY.COMMON: return 1.0;
        case RARITY.UNCOMMON: return 1.3;
        case RARITY.RARE: return 1.8;
        case RARITY.EPIC: return 2.5;
        case RARITY.LEGENDARY: return 3.5;
        case RARITY.MYTHIC: return 5.0;
        case RARITY.DIVINE: return 8.0;
        default: return 1.0;
    }
}

function aty_get_material_multiplier(_material) {
    switch (_material) {
        case MATERIAL.WOOD: return 0.8;
        case MATERIAL.IRON: return 1.0;
        case MATERIAL.STEEL: return 1.3;
        case MATERIAL.SILVER: return 1.6;
        case MATERIAL.GOLD: return 1.8;
        case MATERIAL.MITHRIL: return 2.2;
        case MATERIAL.DRAGONSCALE: return 3.0;
        case MATERIAL.CRYSTAL: return 4.0;
        default: return 1.0;
    }
}


function aty_get_material_by_rarity(_rarity) {
    // Проверяем, что редкость является числом
    if (!is_real(_rarity)) {
        return MATERIAL.IRON;
    }
    
    var materials = [];
    
    switch (_rarity) {
        case RARITY.COMMON:
            materials = [MATERIAL.WOOD, MATERIAL.IRON];
            break;
        case RARITY.UNCOMMON:
            materials = [MATERIAL.IRON, MATERIAL.STEEL];
            break;
        case RARITY.RARE:
            materials = [MATERIAL.STEEL, MATERIAL.SILVER];
            break;
        case RARITY.EPIC:
            materials = [MATERIAL.SILVER, MATERIAL.GOLD];
            break;
        case RARITY.LEGENDARY:
            materials = [MATERIAL.GOLD, MATERIAL.MITHRIL];
            break;
        case RARITY.MYTHIC:
            materials = [MATERIAL.MITHRIL, MATERIAL.DRAGONSCALE];
            break;
        case RARITY.DIVINE:
            materials = [MATERIAL.CRYSTAL];
            break;
        default:
            materials = [MATERIAL.IRON];
    }
    
    // Проверяем, что массив материалов не пустой
    if (array_length(materials) == 0) {
        return MATERIAL.IRON;
    }
    
    return materials[irandom(array_length(materials) - 1)];
}
// =============================================================================
// SIMPLIFIED SPECIAL EFFECTS GENERATION
// =============================================================================

function aty_generate_special_effects(_item) {
    if (!is_struct(_item) || _item.rarity < RARITY.RARE) return;
    
    var effect_count = 0;
    
    // Определяем количество эффектов по редкости
    switch (_item.rarity) {
        case RARITY.RARE: effect_count = 1; break;
        case RARITY.EPIC: effect_count = 2; break;
        case RARITY.LEGENDARY: effect_count = 3; break;
        case RARITY.MYTHIC: effect_count = 4; break;
        case RARITY.DIVINE: effect_count = 5; break;
        default: effect_count = 0;
    }
    
    // Простые эффекты без сложной логики
    for (var i = 0; i < effect_count; i++) {
        var effect_type = irandom(5);
        switch (effect_type) {
            case 0: // Крит
                _item.stats.crit_chance += 3;
                array_push(_item.special_effects, { id: "CRIT_BOOST", name: "Усиление Крита" });
                break;
            case 1: // Скорость
                _item.stats.attack_speed += 5;
                array_push(_item.special_effects, { id: "SPEED_BOOST", name: "Ускорение" });
                break;
            case 2: // Вампиризм
                _item.stats.lifesteal += 3;
                array_push(_item.special_effects, { id: "LIFE_STEAL", name: "Вампиризм" });
                break;
            case 3: // Защита
                _item.stats.defense += 8;
                array_push(_item.special_effects, { id: "TOUGHNESS", name: "Прочность" });
                break;
            case 4: // Мана
                _item.stats.mana += 30;
                array_push(_item.special_effects, { id: "MANA_BOOST", name: "Усиление Маны" });
                break;
            case 5: // Здоровье
                _item.stats.health += 40;
                array_push(_item.special_effects, { id: "HEALTH_BOOST", name: "Усиление Здоровья" });
                break;
        }
    }
}


function aty_get_available_effects(_item) {
    var effects = [];
    
    // Базовые эффекты для всех типов предметов
    var base_effects = [
        { id: "CRIT_BOOST", stats: { crit_chance: 5, crit_damage: 10 }, name: "Усиление Крита" },
        { id: "SPEED_BOOST", stats: { attack_speed: 10, cast_speed: 10 }, name: "Ускорение" },
        { id: "LIFE_STEAL", stats: { lifesteal: 5 }, name: "Вампиризм" },
        { id: "TOUGHNESS", stats: { defense: 15, health: 50 }, name: "Прочность" }
    ];
    
    // Эффекты для оружия
    if (_item.item_type == ITEM_TYPE.WEAPON) {
        array_push(base_effects, 
            { id: "FIRE_DAMAGE", stats: { attack_power: 10 }, name: "Огненная Атака" },
            { id: "ICE_SLOW", stats: { magic_power: 8 }, name: "Ледяное Замедление" },
            { id: "POISON_DOT", stats: { attack_power: 5 }, name: "Ядовитое Клинок" }
        );
    }
    
    // Эффекты для брони
    if (_item.item_type == ITEM_TYPE.ARMOR) {
        array_push(base_effects,
            { id: "THORNS", stats: { defense: 5 }, name: "Шипы" },
            { id: "REGENERATION", stats: { health: 100 }, name: "Регенерация" },
            { id: "MANA_SHIELD", stats: { mana: 50 }, name: "Магический Щит" }
        );
    }
    
    return base_effects;
}

function aty_apply_effect_to_item(_item, _effect) {
    var stat_keys = variable_struct_get_names(_effect.stats);
    for (var i = 0; i < array_length(stat_keys); i++) {
        var key = stat_keys[i];
        _item.stats[key] += _effect.stats[key];
    }
}

// =============================================================================
// ENHANCED ITEM NAMING SYSTEM
// =============================================================================

function aty_generate_item_name_description(_item) {
    if (!is_struct(_item)) return;
    
    var prefixes = aty_get_prefixes_by_rarity(_item.rarity);
    var bases = aty_get_base_names_by_type(_item);
    var suffixes = aty_get_suffixes_by_effects(_item);
    
    // Проверяем, что массивы не пустые
    if (array_length(prefixes) == 0) prefixes = ["Обычный"];
    if (array_length(bases) == 0) bases = ["Предмет"];
    
    // Выбираем компоненты названия
    var prefix = prefixes[irandom(array_length(prefixes) - 1)];
    var base = bases[irandom(array_length(bases) - 1)];
    var suffix = "";
    
    if (array_length(suffixes) > 0 && _item.rarity >= RARITY.RARE) {
        suffix = " " + suffixes[irandom(array_length(suffixes) - 1)];
    }
    
    // Добавляем материал для предметов выше UNCOMMON (с проверкой)
    var material_name = "";
    if (_item.rarity >= RARITY.UNCOMMON && variable_struct_exists(_item, "material")) {
        material_name = aty_get_material_name(_item.material) + " ";
    }
    
    _item.name = prefix + " " + material_name + base + suffix;
    _item.description = aty_generate_item_description(_item);
}
function aty_get_prefixes_by_rarity(_rarity) {
    switch (_rarity) {
        case RARITY.COMMON:
            return ["Старый", "Потрёпанный", "Простой", "Обычный"];
        case RARITY.UNCOMMON:
            return ["Закалённый", "Прочный", "Качественный", "Надёжный"];
        case RARITY.RARE:
            return ["Искусный", "Мастерской", "Редкий", "Ценный"];
        case RARITY.EPIC:
            return ["Эпический", "Легендарный", "Могучий", "Великий"];
        case RARITY.LEGENDARY:
            return ["Мифический", "Божественный", "Древний", "Запретный"];
        case RARITY.MYTHIC:
            return ["Вечный", "Бессмертный", "Абсолютный", "Совершенный"];
        case RARITY.DIVINE:
            return ["Божественный", "Сакральный", "Небесный", "Ангельский"];
        default:
            return ["Обычный"];
    }
}

function aty_get_base_names_by_type(_item) {
    switch (_item.item_type) {
        case ITEM_TYPE.WEAPON:
            switch (_item.weapon_type) {
                case WEAPON_TYPE.SWORD: return ["Меч", "Клинок", "Палаш", "Сабля"];
                case WEAPON_TYPE.AXE: return ["Топор", "Секира", "Колун", "Бердыш"];
                case WEAPON_TYPE.STAFF: return ["Посох", "Жезл", "Скипетр", "Трость"];
                case WEAPON_TYPE.BOW: return ["Лук", "Арбалет", "Самострел"];
                case WEAPON_TYPE.DAGGER: return ["Кинжал", "Стилет", "Крис", "Боевой Нож"];
            }
            break;
        case ITEM_TYPE.ARMOR:
            switch (_item.armor_type) {
                case ARMOR_TYPE.HELMET: return ["Шлем", "Каска", "Наголовье", "Венец"];
                case ARMOR_TYPE.CHEST: return ["Кираса", "Латы", "Доспех", "Броня"];
                case ARMOR_TYPE.GLOVES: return ["Перчатки", "Рукавицы", "Наручи"];
                case ARMOR_TYPE.BOOTS: return ["Сапоги", "Ботинки", "Башмаки"];
                case ARMOR_TYPE.SHIELD: return ["Щит", "Баклер", "Павеза", "Рондaш"];
            }
            break;
        case ITEM_TYPE.ACCESSORY:
            return ["Кольцо", "Амулет", "Ожерелье", "Браслет"];
        case ITEM_TYPE.TRINKET:
            return ["Талисман", "Регалия", "Реликвия", "Артефакт"];
        case ITEM_TYPE.CHARM:
            return ["Оберег", "Тотем", "Фетиш", "Идол"];
    }
    
    return ["Предмет"];
}

function aty_get_suffixes_by_effects(_item) {
    var suffixes = [];
    
    for (var i = 0; i < array_length(_item.special_effects); i++) {
        var effect = _item.special_effects[i];
        switch (effect.id) {
            case "CRIT_BOOST": array_push(suffixes, "Критов"); break;
            case "SPEED_BOOST": array_push(suffixes, "Скорости"); break;
            case "LIFE_STEAL": array_push(suffixes, "Вампиризма"); break;
            case "FIRE_DAMAGE": array_push(suffixes, "Пламени"); break;
            case "ICE_SLOW": array_push(suffixes, "Льда"); break;
            case "REGENERATION": array_push(suffixes, "Регенерации"); break;
        }
    }
    
    return suffixes;
}

function aty_get_material_name(_material) {
    // Проверяем, что материал является числом
    if (!is_real(_material)) {
        return "неизвестного";
    }
    
    switch (_material) {
        case MATERIAL.WOOD: return "Деревянный";
        case MATERIAL.IRON: return "Железный";
        case MATERIAL.STEEL: return "Стальной";
        case MATERIAL.SILVER: return "Серебряный";
        case MATERIAL.GOLD: return "Золотой";
        case MATERIAL.MITHRIL: return "Мифриловый";
        case MATERIAL.DRAGONSCALE: return "Драконий";
        case MATERIAL.CRYSTAL: return "Кристальный";
        default: return "неизвестного";
    }
}


// =============================================================================
// FIXED ITEM DESCRIPTION GENERATION
// =============================================================================

function aty_generate_item_description(_item) {
    var desc = "";
    
    // Основное описание по типу
    switch (_item.item_type) {
        case ITEM_TYPE.WEAPON:
            desc = "Оружие для сражений.";
            break;
        case ITEM_TYPE.ARMOR:
            desc = "Защитное снаряжение.";
            break;
        case ITEM_TYPE.ACCESSORY:
            desc = "Украшение с магическими свойствами.";
            break;
        case ITEM_TYPE.TRINKET:
            desc = "Магический артефакт.";
            break;
        case ITEM_TYPE.CHARM:
            desc = "Талисман удачи.";
            break;
    }
    
    // Добавляем информацию о материале (исправленная строка)
    var material_name = aty_get_material_name(_item.material);
    if (material_name != "") {
        desc += " Сделан из " + string_lower(material_name) + ".";
    }
    
    // Добавляем информацию об эффектах
    if (array_length(_item.special_effects) > 0) {
        desc += " Обладает особыми свойствами:";
        for (var i = 0; i < array_length(_item.special_effects); i++) {
            desc += " " + _item.special_effects[i].name + ";";
        }
    }
    
    return desc;
}

// =============================================================================
// COMPLETELY REWRITTEN WEAPON PROPERTIES GENERATION - SAFE VERSION
// =============================================================================

function aty_generate_weapon_properties(_item) {
    if (!is_struct(_item)) return;
    
    _item.weapon_type = irandom(4); // SWORD, AXE, STAFF, BOW, DAGGER
    
    // Полностью сбрасываем статы к безопасным значениям
    var stats = {
        health: 0,
        mana: 0,
        attack_power: 0,
        magic_power: 0,
        defense: 0,
        crit_chance: 0,
        crit_damage: 0,
        attack_speed: 0,
        cast_speed: 0,
        dodge_chance: 0,
        block_chance: 0,
        lifesteal: 0,
        cooldown_reduction: 0,
        movement_speed: 0
    };
    
    // Базовые характеристики оружия
    switch (_item.weapon_type) {
        case WEAPON_TYPE.SWORD:
            stats.attack_power = 15;
            stats.crit_chance = 5;
            break;
        case WEAPON_TYPE.AXE:
            stats.attack_power = 20;
            stats.attack_speed = -10;
            stats.crit_damage = 25;
            break;
        case WEAPON_TYPE.STAFF:
            stats.magic_power = 18;
            stats.cast_speed = 10;
            break;
        case WEAPON_TYPE.BOW:
            stats.attack_power = 12;
            stats.attack_speed = 15;
            stats.crit_chance = 8;
            break;
        case WEAPON_TYPE.DAGGER:
            stats.attack_power = 10;
            stats.attack_speed = 25;
            stats.crit_chance = 12;
            break;
    }
    
    // Полностью заменяем статы предмета
    _item.stats = stats;
}

// =============================================================================
// COMPLETELY REWRITTEN ARMOR PROPERTIES GENERATION - SAFE VERSION
// =============================================================================

function aty_generate_armor_properties(_item) {
    if (!is_struct(_item)) return;
    
    _item.armor_type = irandom(4); // HELMET, CHEST, GLOVES, BOOTS, SHIELD
    
    // Полностью сбрасываем статы к безопасным значениям
    var stats = {
        health: 0,
        mana: 0, 
        attack_power: 0,
        magic_power: 0,
        defense: 0,
        crit_chance: 0,
        crit_damage: 0,
        attack_speed: 0,
        cast_speed: 0,
        dodge_chance: 0,
        block_chance: 0,
        lifesteal: 0,
        cooldown_reduction: 0,
        movement_speed: 0
    };
    
    // Устанавливаем базовые значения в зависимости от типа брони
    switch (_item.armor_type) {
        case ARMOR_TYPE.HELMET:
            stats.defense = 8;
            stats.health = 20;
            break;
        case ARMOR_TYPE.CHEST:
            stats.defense = 15;
            stats.health = 50;
            break;
        case ARMOR_TYPE.GLOVES:
            stats.defense = 5;
            stats.attack_speed = 5;
            break;
        case ARMOR_TYPE.BOOTS:
            stats.defense = 5;
            stats.movement_speed = 5;
            stats.dodge_chance = 3;
            break;
        case ARMOR_TYPE.SHIELD:
            stats.defense = 12;
            stats.block_chance = 15;
            break;
    }
    
    // Полностью заменяем статы предмета
    _item.stats = stats;
}
// =============================================================================
// COMPLETELY REWRITTEN ACCESSORY, TRINKET, CHARM GENERATION - SAFE VERSION
// =============================================================================

function aty_generate_accessory_properties(_item) {
    if (!is_struct(_item)) return;
    
    // Полностью сбрасываем статы
    _item.stats = {
        health: 30,
        mana: 20,
        attack_power: 0,
        magic_power: 0,
        defense: 0,
        crit_chance: 3,
        crit_damage: 0,
        attack_speed: 0,
        cast_speed: 0,
        dodge_chance: 0,
        block_chance: 0,
        lifesteal: 0,
        cooldown_reduction: 0,
        movement_speed: 0
    };
}

function aty_generate_trinket_properties(_item) {
    if (!is_struct(_item)) return;
    
    // Базовые статы для тринкета
    var stats = {
        health: 0,
        mana: 0,
        attack_power: 0,
        magic_power: 0,
        defense: 0,
        crit_chance: 0,
        crit_damage: 0,
        attack_speed: 0,
        cast_speed: 0,
        dodge_chance: 0,
        block_chance: 0,
        lifesteal: 0,
        cooldown_reduction: 0,
        movement_speed: 0
    };
    
    // Тринкеты дают специализированные бонусы
    var possible_stats = ["crit_damage", "lifesteal", "cooldown_reduction", "cast_speed"];
    var selected_stat = possible_stats[irandom(array_length(possible_stats) - 1)];
    
    // Устанавливаем выбранный стат
    switch (selected_stat) {
        case "crit_damage": stats.crit_damage = 15; break;
        case "lifesteal": stats.lifesteal = 15; break;
        case "cooldown_reduction": stats.cooldown_reduction = 15; break;
        case "cast_speed": stats.cast_speed = 15; break;
    }
    
    _item.stats = stats;
}

function aty_generate_charm_properties(_item) {
    if (!is_struct(_item)) return;
    
    _item.stats = {
        health: 0,
        mana: 0,
        attack_power: 0,
        magic_power: 0,
        defense: 0,
        crit_chance: 0,
        crit_damage: 0,
        attack_speed: 0,
        cast_speed: 0,
        dodge_chance: 0,
        block_chance: 0,
        lifesteal: 0,
        cooldown_reduction: 0,
        movement_speed: 5
    };
    
    _item.sockets = 1; // Амулеты могут иметь сокеты для камней
}

function aty_generate_item_name(_item) {
    var prefixes = {
        common: ["Обычный", "Простой", "Базовая", "Стандартный"],
        uncommon: ["Улучшенный", "Качественный", "Надежный", "Искусный"],
        rare: ["Редкий", "Исключительный", "Ценный", "Мастерский"],
        epic: ["Эпический", "Легендарный", "Великий", "Могучий"],
        legendary: ["Мифический", "Древний", "Божественный", "Величайший"]
    };
    
    var weapon_names = ["Меч", "Клинок", "Секира", "Молот", "Кинжал", "Посох", "Лук"];
    var armor_names = ["Доспех", "Броня", "Нагрудник", "Пластина", "Кираса"];
    var accessory_names = ["Кольцо", "Амулет", "Талисман", "Браслет", "Ожерелье"];
    var trinket_names = ["Артефакт", "Регалия", "Реликвия", "Символ"];
    var charm_names = ["Тотем", "Оберег", "Чары", "Фетиш"];
    
    var prefix_array = prefixes.common;
    switch (_item.rarity) {
        case RARITY.UNCOMMON: prefix_array = prefixes.uncommon; break;
        case RARITY.RARE: prefix_array = prefixes.rare; break;
        case RARITY.EPIC: prefix_array = prefixes.epic; break;
        case RARITY.LEGENDARY: prefix_array = prefixes.legendary; break;
    }
    
    var prefix = prefix_array[irandom(array_length(prefix_array) - 1)];
    var base_name = "";
    
    switch (_item.item_type) {
        case ITEM_TYPE.WEAPON: base_name = weapon_names[irandom(array_length(weapon_names) - 1)]; break;
        case ITEM_TYPE.ARMOR: base_name = armor_names[irandom(array_length(armor_names) - 1)]; break;
        case ITEM_TYPE.ACCESSORY: base_name = accessory_names[irandom(array_length(accessory_names) - 1)]; break;
        case ITEM_TYPE.TRINKET: base_name = trinket_names[irandom(array_length(trinket_names) - 1)]; break;
        case ITEM_TYPE.CHARM: base_name = charm_names[irandom(array_length(charm_names) - 1)]; break;
    }
    
    return prefix + " " + base_name;
}

// =============================================================================
// ENHANCED SET BONUSES
// =============================================================================

function aty_calculate_set_bonuses() {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) return {};
    
    var equipment = global.aty.hero.equipment;
    var set_counts = {};
    var bonuses = {};
    
    // Инициализируем счетчики сетов
    var set_types = [ITEM_SET.WARRIOR, ITEM_SET.MAGE, ITEM_SET.ROGUE, ITEM_SET.GUARDIAN];
    for (var i = 0; i < array_length(set_types); i++) {
        set_counts[set_types[i]] = 0;
    }
    
    // Считаем предметы по сетам
    var slot_names = variable_struct_get_names(equipment);
    for (var i = 0; i < array_length(slot_names); i++) {
        var item = variable_struct_get(equipment, slot_names[i]);
        if (is_struct(item) && variable_struct_exists(item, "set_type") && item.set_type != ITEM_SET.NONE) {
            set_counts[item.set_type] += 1;
        }
    }
    
    // Применяем бонусы за сеты
    for (var i = 0; i < array_length(set_types); i++) {
        var set_type = set_types[i];
        var count = set_counts[set_type];
        
        if (count >= 2) {
            // Бонус за 2 предмета
            switch (set_type) {
                case ITEM_SET.WARRIOR:
                    bonuses.attack_power = (bonuses.attack_power || 0) + 15;
                    bonuses.health = (bonuses.health || 0) + 100;
                    break;
                case ITEM_SET.MAGE:
                    bonuses.magic_power = (bonuses.magic_power || 0) + 20;
                    bonuses.mana = (bonuses.mana || 0) + 80;
                    break;
                case ITEM_SET.ROGUE:
                    bonuses.crit_chance = (bonuses.crit_chance || 0) + 8;
                    bonuses.attack_speed = (bonuses.attack_speed || 0) + 12;
                    break;
                case ITEM_SET.GUARDIAN:
                    bonuses.defense = (bonuses.defense || 0) + 25;
                    bonuses.block_chance = (bonuses.block_chance || 0) + 10;
                    break;
            }
        }
        
        if (count >= 4) {
            // Бонус за 4 предмета
            switch (set_type) {
                case ITEM_SET.WARRIOR:
                    bonuses.lifesteal = (bonuses.lifesteal || 0) + 5;
                    bonuses.crit_damage = (bonuses.crit_damage || 0) + 25;
                    break;
                case ITEM_SET.MAGE:
                    bonuses.cast_speed = (bonuses.cast_speed || 0) + 15;
                    bonuses.cooldown_reduction = (bonuses.cooldown_reduction || 0) + 10;
                    break;
                case ITEM_SET.ROGUE:
                    bonuses.dodge_chance = (bonuses.dodge_chance || 0) + 8;
                    bonuses.movement_speed = (bonuses.movement_speed || 0) + 10;
                    break;
                case ITEM_SET.GUARDIAN:
                    bonuses.health = (bonuses.health || 0) + 200;
                    bonuses.defense = (bonuses.defense || 0) + 15;
                    break;
            }
        }
        
        if (count >= 6) {
            // Уникальный бонус за полный сет
            switch (set_type) {
                case ITEM_SET.WARRIOR:
                    // Шанс оглушить врага при критической атаке
                    break;
                case ITEM_SET.MAGE:
                    // Шанс восстановить ману при использовании способности
                    break;
                case ITEM_SET.ROGUE:
                    // Шанс на двойную атаку
                    break;
                case ITEM_SET.GUARDIAN:
                    // Создание защитного щита при получении урона
                    break;
            }
        }
    }
    
    return bonuses;
}
// =============================================================================
// ITEM COMPARISON SYSTEM
// =============================================================================

function aty_compare_items(_item1, _item2) {
    if (!is_struct(_item1) || !is_struct(_item2)) return 0;
    
    var score1 = aty_calculate_item_score(_item1);
    var score2 = aty_calculate_item_score(_item2);
    
    if (score1 > score2) return 1;
    if (score1 < score2) return -1;
    return 0;
}

function aty_calculate_item_score(_item) {
    if (!is_struct(_item) || !variable_struct_exists(_item, "stats")) return 0;
    
    var stats = _item.stats;
    var sscore = 0;
    
    // Базовый счет на основе редкости
    sscore += (_item.rarity + 1) * 10;
    
    // Добавляем очки за каждую характеристику
    var stat_keys = variable_struct_get_names(stats);
    for (var i = 0; i < array_length(stat_keys); i++) {
        var value = variable_struct_get(stats, stat_keys[i]);
        if (value > 0) {
            sscore += value;
        }
    }
    
    return sscore;
}

// =============================================================================
// ITEM FILTERING AND SORTING
// =============================================================================

function aty_filter_items_by_type(_items, _item_type) {
    var filtered = [];
    
    for (var i = 0; i < array_length(_items); i++) {
        if (_items[i].item_type == _item_type) {
            array_push(filtered, _items[i]);
        }
    }
    
    return filtered;
}

function aty_filter_items_by_rarity(_items, _rarity) {
    var filtered = [];
    
    for (var i = 0; i < array_length(_items); i++) {
        if (_items[i].rarity == _rarity) {
            array_push(filtered, _items[i]);
        }
    }
    
    return filtered;
}


// В функции aty_sort_items_by_score замените:
function aty_sort_items_by_score(_items, _ascending = false) {
    if (!is_array(_items) || array_length(_items) == 0) return [];
    
    var sorted = aty_array_copy(_items); // Исправлено здесь
    
    // Пузырьковая сортировка
    for (var i = 0; i < array_length(sorted) - 1; i++) {
        for (var j = 0; j < array_length(sorted) - i - 1; j++) {
            var score1 = aty_calculate_item_score(sorted[j]);
            var score2 = aty_calculate_item_score(sorted[j + 1]);
            
            if ((_ascending && score1 > score2) || (!_ascending && score1 < score2)) {
                var temp = sorted[j];
                sorted[j] = sorted[j + 1];
                sorted[j + 1] = temp;
            }
        }
    }
    
    return sorted;
}
// В функции aty_sort_items_by_type замените:
function aty_sort_items_by_type(_items, _ascending = false) {
    if (!is_array(_items) || array_length(_items) == 0) return [];
    
    var sorted = aty_array_copy(_items); // Исправлено здесь
    
    for (var i = 0; i < array_length(sorted) - 1; i++) {
        for (var j = 0; j < array_length(sorted) - i - 1; j++) {
            var type1 = sorted[j].item_type;
            var type2 = sorted[j + 1].item_type;
            
            if ((_ascending && type1 > type2) || (!_ascending && type1 < type2)) {
                var temp = sorted[j];
                sorted[j] = sorted[j + 1];
                sorted[j + 1] = temp;
            }
        }
    }
    
    return sorted;
}

// =============================================================================
// SAFE RANDOM BONUS STATS GENERATION
// =============================================================================

function aty_add_random_bonus_stats(_item) {
    if (!is_struct(_item)) return;
    
    var bonus_stats = [
        { stat: "crit_chance", value: 2 },
        { stat: "crit_damage", value: 5 },
        { stat: "attack_speed", value: 3 },
        { stat: "cast_speed", value: 3 },
        { stat: "dodge_chance", value: 2 },
        { stat: "lifesteal", value: 2 },
        { stat: "cooldown_reduction", value: 2 },
        { stat: "movement_speed", value: 2 }
    ];
    
    var bonus_count = 1;
    if (_item.rarity >= RARITY.EPIC) bonus_count += 1;
    if (_item.rarity >= RARITY.LEGENDARY) bonus_count += 1;
    
    for (var i = 0; i < bonus_count; i++) {
        var random_bonus = bonus_stats[irandom(array_length(bonus_stats) - 1)];
        var stat_name = random_bonus.stat;
        var bonus_value = random_bonus.value * (1 + _item.rarity);
        
        // Безопасное добавление бонуса
        switch (stat_name) {
            case "crit_chance": _item.stats.crit_chance += bonus_value; break;
            case "crit_damage": _item.stats.crit_damage += bonus_value; break;
            case "attack_speed": _item.stats.attack_speed += bonus_value; break;
            case "cast_speed": _item.stats.cast_speed += bonus_value; break;
            case "dodge_chance": _item.stats.dodge_chance += bonus_value; break;
            case "lifesteal": _item.stats.lifesteal += bonus_value; break;
            case "cooldown_reduction": _item.stats.cooldown_reduction += bonus_value; break;
            case "movement_speed": _item.stats.movement_speed += bonus_value; break;
        }
    }
}
function aty_sort_items_by_rarity(_items, _ascending = false) {
    if (!is_array(_items) || array_length(_items) == 0) return [];
    
    var sorted = aty_array_copy(_items);
    
    for (var i = 0; i < array_length(sorted) - 1; i++) {
        for (var j = 0; j < array_length(sorted) - i - 1; j++) {
            var rarity1 = sorted[j].rarity;
            var rarity2 = sorted[j + 1].rarity;
            
            if ((_ascending && rarity1 > rarity2) || (!_ascending && rarity1 < rarity2)) {
                var temp = sorted[j];
                sorted[j] = sorted[j + 1];
                sorted[j + 1] = temp;
            }
        }
    }
    
    return sorted;
}
// Заменяем проблемную функцию array_copy на безопасную версию
function aty_array_copy(_arr) {
    if (!is_array(_arr)) return [];
    var copy = [];
    for (var i = 0; i < array_length(_arr); i++) {
        array_push(copy, _arr[i]);
    }
    return copy;
}
// Безопасная функция копирования структуры (альтернативная версия)
function aty_struct_copy(_struct) {
    if (!is_struct(_struct)) return undefined;
    
    var copy = {};
    var names = variable_struct_get_names(_struct);
    
    for (var i = 0; i < array_length(names); i++) {
        var key = names[i];
        var value = variable_struct_get(_struct, key);
        
        // Рекурсивно копируем вложенные структуры
        if (is_struct(value)) {
            variable_struct_set(copy, key, aty_struct_copy(value));
        }
        // Копируем массивы
        else if (is_array(value)) {
            variable_struct_set(copy, key, aty_array_copy(value));
        }
        // Простые значения
        else {
            variable_struct_set(copy, key, value);
        }
    }
    
    return copy;
}

// И безопасную функцию для копирования части массива
function aty_array_copy_range(_array, _start, _end) {
    if (!is_array(_array)) return [];
    
    _start = max(0, _start);
    _end = min(array_length(_array) - 1, _end);
    
    var copy = [];
    for (var i = _start; i <= _end; i++) {
        array_push(copy, _array[i]);
    }
    return copy;
}
// =============================================================================
// ITEM DESTRUCTION AND MATERIAL EXTRACTION
// =============================================================================

function aty_destroy_item(_item) {
    if (!is_struct(_item)) return {};
    
    var materials = {};
    
    // Возвращаем материалы в зависимости от редкости и материала предмета
    var material_return = floor((_item.rarity + 1) * 2);
    
    // Базовые материалы
    materials[_item.material] = material_return;
    
    // Дополнительные материалы из камней
    for (var i = 0; i < array_length(_item.socketed_gems); i++) {
        var gem = _item.socketed_gems[i];
        if (is_struct(gem)) {
            var gem_material = MATERIAL.SILVER + gem.quality; // Примерное соответствие
            materials[gem_material] = (materials[gem_material] || 0) + 1;
        }
    }
    
    // Возвращаем часть стоимости улучшения
    var gold_return = floor(_item.upgrade_cost * 0.3);
    global.aty.hero.gold += gold_return;
    
    return materials;
}

// =============================================================================
// CRAFTING SYSTEM (БАЗОВАЯ ВЕРСИЯ)
// =============================================================================

function aty_craft_item(_materials, _target_rarity, _item_type) {
    // Проверяем достаточно ли материалов
    var total_material_value = 0;
    var material_keys = variable_struct_get_names(_materials);
    
    for (var i = 0; i < array_length(material_keys); i++) {
        var material = real(material_keys[i]);
        var quantity = _materials[material_keys[i]];
        total_material_value += material * quantity;
    }
    
    var required_value = (_target_rarity + 1) * 50;
    
    if (total_material_value < required_value) {
        return noone; // Недостаточно материалов
    }
    
    // Создаем предмет
    var crafted_item = aty_generate_loot_item(_target_rarity, _item_type);
    
    // Увеличиваем шанс получения сета
    if (random(1) < 0.3 + (_target_rarity * 0.1)) {
        var set_types = [ITEM_SET.WARRIOR, ITEM_SET.MAGE, ITEM_SET.ROGUE, ITEM_SET.GUARDIAN];
        crafted_item.set_type = set_types[irandom(array_length(set_types) - 1)];
    }
    
    return crafted_item;
}
// Вспомогательная функция для преобразования ITEM_SET в строку
function aty_set_type_to_string(_set_type) {
    switch (_set_type) {
        case ITEM_SET.WARRIOR: return "WARRIOR";
        case ITEM_SET.MAGE: return "MAGE";
        case ITEM_SET.ROGUE: return "ROGUE";
        case ITEM_SET.GUARDIAN: return "GUARDIAN";
        default: return "NONE";
    }
}
// Добавляем безопасную функцию для работы с массивами
function aty_safe_array_get(_array, _index, _default = undefined) {
    if (!is_array(_array)) return _default;
    if (_index < 0 || _index >= array_length(_array)) return _default;
    return _array[_index];
}
function point_in_rectangle(_px, _py, _x1, _y1, _x2, _y2) {
    return (_px >= _x1 && _px <= _x2 && _py >= _y1 && _py <= _y2);
}

// =============================================================================
// SAVE/LOAD SYSTEM
// =============================================================================

function aty_save_game() {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) return false;
    
    try {
        var save_data = {
            hero: global.aty.hero,
            arenas: global.aty.arenas,
            companions: global.aty.companions,
            inventory: global.aty.inventory,
            trophies: global.aty.trophies
        };
        
        var json_string = json_stringify(save_data);
        var buffer = buffer_create(string_byte_length(json_string) + 1, buffer_fixed, 1);
        buffer_write(buffer, buffer_string, json_string);
        
        if (file_exists("aty_save.json")) {
            file_delete("aty_save.json");
        }
        
        buffer_save(buffer, "aty_save.json");
        buffer_delete(buffer);
        
        aty_show_notification("Игра сохранена!");
        return true;
    } catch (e) {
        aty_show_notification("Ошибка сохранения: " + string(e));
        return false;
    }
}

function aty_load_game() {
    if (!file_exists("aty_save.json")) {
        aty_show_notification("Файл сохранения не найден");
        return false;
    }
    
    try {
        var buffer = buffer_load("aty_save.json");
        var json_string = buffer_read(buffer, buffer_string);
        buffer_delete(buffer);
        
        var save_data = json_parse(json_string);
        
        if (is_struct(save_data)) {
            global.aty.hero = save_data.hero;
            global.aty.arenas = save_data.arenas;
            global.aty.companions = save_data.companions;
            global.aty.inventory = save_data.inventory;
            global.aty.trophies = save_data.trophies;
            
            aty_show_notification("Игра загружена!");
            return true;
        }
    } catch (e) {
        aty_show_notification("Ошибка загрузки: " + string(e));
    }
    
    return false;
}

// Функция для неоновой панели с glow эффектом
function draw_neon_panel(_x1, _y1, _x2, _y2, _header_text) {
    var colors = global.aty_colors;
    
    // Основная панель
    draw_set_color(colors.bg_medium);
    draw_rectangle(_x1, _y1, _x2, _y2, false);
    
    // Неоновая рамка
    draw_set_color(colors.neon_blue);
    draw_set_alpha(0.7);
    draw_rectangle(_x1, _y1, _x2, _y2, true);
    draw_set_alpha(1);
    
    // Эффект свечения
    draw_set_color(colors.neon_blue);
    draw_set_alpha(0.3);
    draw_rectangle(_x1-1, _y1-1, _x2+1, _y2+1, true);
    draw_rectangle(_x1-2, _y1-2, _x2+2, _y2+2, true);
    draw_set_alpha(1);
    
    // Заголовок если передан
    if (_header_text != "") {
        draw_set_color(colors.bg_dark);
        draw_rectangle(_x1, _y1, _x2, _y1 + 25, false);
        
        draw_set_color(colors.neon_pink);
        draw_text(_x1 + 10, _y1 + 8, _header_text);
    }
}

// Функция для неонового прямоугольника с glow
function draw_neon_rectangle(_x1, _y1, _x2, _y2, _color, _filled) {
    if (_filled == undefined) _filled = false;
    
    // Основной прямоугольник
    draw_set_color(_color);
    if (_filled) {
        draw_rectangle(_x1, _y1, _x2, _y2, false);
    } else {
        draw_rectangle(_x1, _y1, _x2, _y2, true);
    }
    
    // Эффект свечения
    draw_set_alpha(0.5);
    if (_filled) {
        draw_rectangle(_x1-1, _y1-1, _x2+1, _y2+1, false);
    } else {
        draw_rectangle(_x1-1, _y1-1, _x2+1, _y2+1, true);
    }
    draw_set_alpha(1);
}

// Функция для стильной неоновой кнопки
function draw_neon_button(_x1, _y1, _x2, _y2, _text, _is_active, _is_disabled) {
    var colors = global.aty_colors;
    
    var button_color = colors.neon_blue;
    var text_color = colors.text_primary;
    
    if (_is_disabled) {
        button_color = colors.bg_light;
        text_color = colors.text_muted;
    } else if (_is_active) {
        button_color = colors.neon_pink;
    }
    
    // Основная кнопка
    draw_set_color(button_color);
    draw_rectangle(_x1, _y1, _x2, _y2, false);
    
    // Эффект свечения для активных кнопок
    if (!_is_disabled) {
        draw_set_alpha(0.3);
        draw_rectangle(_x1-1, _y1-1, _x2+1, _y2+1, false);
        draw_set_alpha(1);
    }
    
    // Текст по центру
    var center_x = (_x1 + _x2) / 2;
    var center_y = (_y1 + _y2) / 2;
    
    draw_set_color(text_color);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    
    // Обрезаем текст если не помещается
    var max_text_width = _x2 - _x1 - 20;
    var text_width = string_width(_text);
    
    if (text_width > max_text_width) {
        var short_text = string_copy(_text, 1, 12) + "...";
        draw_text(center_x, center_y, short_text);
    } else {
        draw_text(center_x, center_y, _text);
    }
    
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

// =============================================================================
// UTILITY FUNCTIONS
// =============================================================================

function aty_show_notification(_text) {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) return;
    
    // БЕЗОПАСНАЯ ПРОВЕРКА: убеждаемся что notification существует
    if (!variable_struct_exists(global.aty, "notification")) {
        global.aty.notification = {
            text: "",
            timer: 0
        };
    }
    
    global.aty.notification.text = _text;
    global.aty.notification.timer = 180; // 3 секунды при 60 FPS
}

// =============================================================================
// ENHANCED SHOP GENERATION
// =============================================================================

function aty_generate_shop_items() {
    var shop_items = [];
    var item_count = 6; // Количество предметов в магазине
    
    for (var i = 0; i < item_count; i++) {
        var rarity_roll = random(1);
        var rarity = RARITY.COMMON;
        
        if (rarity_roll < 0.02) rarity = RARITY.LEGENDARY;
        else if (rarity_roll < 0.08) rarity = RARITY.EPIC;
        else if (rarity_roll < 0.2) rarity = RARITY.RARE;
        else if (rarity_roll < 0.5) rarity = RARITY.UNCOMMON;
        
        // ИСПРАВЛЕНО: используем безопасную генерацию
        var item = aty_generate_loot_item_safe(rarity);
        
        // Устанавливаем цену на основе редкости
        var base_price = 0;
        switch (rarity) {
            case RARITY.COMMON: base_price = 50; break;
            case RARITY.UNCOMMON: base_price = 150; break;
            case RARITY.RARE: base_price = 400; break;
            case RARITY.EPIC: base_price = 1000; break;
            case RARITY.LEGENDARY: base_price = 2500; break;
        }
        
        item.price = base_price;
        
        // ДОБАВЛЕНО: убеждаемся что у предмета есть ID
        if (!variable_struct_exists(item, "id")) {
            item.id = "shop_item_" + string(irandom_range(10000, 99999));
        }
        
        array_push(shop_items, item);
    }
    
    return shop_items;
}
// =============================================================================
// SAFE ITEM PRICE CALCULATION
// =============================================================================


function aty_calculate_item_price_safe(_item) {
    if (!is_struct(_item)) return 10;
    
    var base_price = 10;
    var rarity_multiplier = 1 + (_item.rarity * 0.8);
    var stat_total = 0;
    
    // Суммируем все статы предмета
    var stat_names = variable_struct_get_names(_item.stats);
    for (var i = 0; i < array_length(stat_names); i++) {
        stat_total += variable_struct_get(_item.stats, stat_names[i]);
    }
    
    return max(10, round(base_price * rarity_multiplier + stat_total * 2));
}

function aty_create_gem_struct_safe(_gem_type, _quality) {
    var gem = {
        is_gem: true,
        gem_type: _gem_type,
        quality: _quality,
        stats: {},
        name: "",
        price: 0,
        rarity: RARITY.COMMON, // Добавляем редкость для камней
        item_type: ITEM_TYPE.ACCESSORY, // Добавляем тип для совместимости
        slot: "ACCESSORY" // Добавляем слот для совместимости
    };
    
    // Устанавливаем базовые статы для каждого типа камня
    switch (_gem_type) {
        case GEM_TYPE.RUBY:
            gem.stats = { attack_power: 5 + (_quality * 3), crit_damage: 10 + (_quality * 5) };
            gem.name = "Рубин";
            break;
        case GEM_TYPE.SAPPHIRE:
            gem.stats = { magic_power: 5 + (_quality * 3), mana: 20 + (_quality * 10) };
            gem.name = "Сапфир";
            break;
        case GEM_TYPE.EMERALD:
            gem.stats = { health: 30 + (_quality * 15), defense: 3 + (_quality * 2) };
            gem.name = "Изумруд";
            break;
        case GEM_TYPE.DIAMOND:
            gem.stats = { crit_chance: 2 + (_quality * 1), attack_speed: 3 + (_quality * 2) };
            gem.name = "Алмаз";
            break;
        case GEM_TYPE.AMETHYST:
            gem.stats = { cast_speed: 5 + (_quality * 3), cooldown_reduction: 2 + (_quality * 1) };
            gem.name = "Аметист";
            break;
        case GEM_TYPE.TOPAZ:
            gem.stats = { dodge_chance: 2 + (_quality * 1), movement_speed: 3 + (_quality * 2) };
            gem.name = "Топаз";
            break;
    }
    
    // Добавляем качество к названию
    var quality_names = ["", "Блестящий ", "Идеальный ", "Безупречный "];
    if (_quality < array_length(quality_names)) {
        gem.name = quality_names[_quality] + gem.name;
    }
    
    // Цена камня
    gem.price = (_quality + 1) * 100;
    
    return gem;
}
function aty_calculate_item_price(_item) {
    if (!is_struct(_item)) return 100;
    
    var base_price = 0;
    
    // Базовая цена по редкости
    switch (_item.rarity) {
        case RARITY.COMMON: base_price = 50; break;
        case RARITY.UNCOMMON: base_price = 150; break;
        case RARITY.RARE: base_price = 400; break;
        case RARITY.EPIC: base_price = 1000; break;
        case RARITY.LEGENDARY: base_price = 2500; break;
        case RARITY.MYTHIC: base_price = 6000; break;
        case RARITY.DIVINE: base_price = 15000; break;
        default: base_price = 50;
    }
    
    // Безопасное суммирование статов - проверяем каждый стат индивидуально
    var total_stats = 0;
    
    if (variable_struct_exists(_item, "stats")) {
        var stats = _item.stats;
        
        // Проверяем каждый возможный стат вручную
        if (variable_struct_exists(stats, "health") && is_real(stats.health))
            total_stats += stats.health;
        if (variable_struct_exists(stats, "mana") && is_real(stats.mana))
            total_stats += stats.mana;
        if (variable_struct_exists(stats, "attack_power") && is_real(stats.attack_power))
            total_stats += stats.attack_power;
        if (variable_struct_exists(stats, "magic_power") && is_real(stats.magic_power))
            total_stats += stats.magic_power;
        if (variable_struct_exists(stats, "defense") && is_real(stats.defense))
            total_stats += stats.defense;
        if (variable_struct_exists(stats, "crit_chance") && is_real(stats.crit_chance))
            total_stats += stats.crit_chance;
        if (variable_struct_exists(stats, "crit_damage") && is_real(stats.crit_damage))
            total_stats += stats.crit_damage;
        if (variable_struct_exists(stats, "attack_speed") && is_real(stats.attack_speed))
            total_stats += stats.attack_speed;
        if (variable_struct_exists(stats, "cast_speed") && is_real(stats.cast_speed))
            total_stats += stats.cast_speed;
        if (variable_struct_exists(stats, "dodge_chance") && is_real(stats.dodge_chance))
            total_stats += stats.dodge_chance;
        if (variable_struct_exists(stats, "block_chance") && is_real(stats.block_chance))
            total_stats += stats.block_chance;
        if (variable_struct_exists(stats, "lifesteal") && is_real(stats.lifesteal))
            total_stats += stats.lifesteal;
        if (variable_struct_exists(stats, "cooldown_reduction") && is_real(stats.cooldown_reduction))
            total_stats += stats.cooldown_reduction;
        if (variable_struct_exists(stats, "movement_speed") && is_real(stats.movement_speed))
            total_stats += stats.movement_speed;
    }
    
    // Учитываем уровень улучшения
    var upgrade_multiplier = 1.0;
    if (variable_struct_exists(_item, "upgrade_level") && is_real(_item.upgrade_level)) {
        upgrade_multiplier = 1.0 + (_item.upgrade_level * 0.3);
    }
    
    // Учитываем количество эффектов
    var effect_multiplier = 1.0;
    if (variable_struct_exists(_item, "special_effects") && is_array(_item.special_effects)) {
        effect_multiplier = 1.0 + (array_length(_item.special_effects) * 0.2);
    }
    
    // Учитываем сокеты
    var socket_multiplier = 1.0;
    if (variable_struct_exists(_item, "sockets") && is_real(_item.sockets)) {
        socket_multiplier = 1.0 + (_item.sockets * 0.15);
    }
    
    var final_price = base_price * (1 + total_stats * 0.1) * upgrade_multiplier * effect_multiplier * socket_multiplier;
    
    return max(floor(final_price), 10); // Минимальная цена 10
}

// =============================================================================
// ENHANCED ITEM CREATION WITH BETTER ERROR HANDLING
// =============================================================================

function aty_create_item_struct() {
    return {
        id: "",
        name: "",
        description: "",
        item_type: ITEM_TYPE.WEAPON,
        weapon_type: WEAPON_TYPE.SWORD,
        armor_type: ARMOR_TYPE.HELMET,
        material: MATERIAL.IRON,
        rarity: RARITY.COMMON,
        set_type: ITEM_SET.NONE,
        level_requirement: 1,
        
        // Основные характеристики
        stats: {
            health: 0,
            mana: 0,
            attack_power: 0,
            magic_power: 0,
            defense: 0,
            crit_chance: 0,
            crit_damage: 0,
            attack_speed: 0,
            cast_speed: 0,
            dodge_chance: 0,
            block_chance: 0,
            lifesteal: 0,
            cooldown_reduction: 0,
            movement_speed: 0
        },
        
        // Специальные свойства
        special_effects: [],
        sockets: 0,
        socketed_gems: [],
        durability: 100,
        max_durability: 100,
        
        // Система улучшений
        upgrade_level: 0,
        max_upgrade_level: 5,
        upgrade_cost: 0,
        
        // Визуальные свойства
        color: c_white,
        particle_effect: "",
        custom_icon: -1,
        
        // Совместимость со старой системой
        slot: "WEAPON" // Будет установлено автоматически
    };
}
// =============================================================================
// ENHANCED SAFE LOOT ITEM GENERATION
// =============================================================================
function aty_generate_loot_item_safe(_rarity)
{
    // --- 1) Базовый предмет -------------------------------------------------
    var item = aty_create_basic_item();          // уже содержит пустой struct .stats

    // --- 2) Устанавливаем редкость -----------------------------------------
    item.rarity = _rarity;

    // --- 3) Основные базовые статы (можно менять под свои нужды) ----------
    var base_power = 5 + (_rarity * 3);           // чем выше редкость – тем сильнее

    // --- 4) Список возможных статов ----------------------------------------
    var possible_stats = [
        "attack_power", "magic_power", "defense",
        "health", "mana",
        "crit_chance", "crit_damage",
        "attack_speed", "cast_speed"
    ];

    // --- 5) Сколько разных статов будет у предмета -------------------------
    var num_stats = 2 + _rarity;                 // больше статов у редких предметов
    num_stats = min(num_stats, array_length(possible_stats));

    // --- 6) Случайно заполняем выбранные статы -----------------------------
    for (var i = 0; i < num_stats; i++)
    {
        var stat  = possible_stats[irandom(array_length(possible_stats) - 1)];
        var value = base_power + irandom(base_power);

        // Для процентных статов уменьшаем значение (чтобы не было огромных %)
        if (stat == "crit_chance"   ||
            stat == "crit_damage"   ||
            stat == "attack_speed"  ||
            stat == "cast_speed")
        {
            value = value / 10;                // 0‑9 вместо 0‑90
        }

        // ----------  <-- Ключевая строка, исправленная -----------------------
        // Текущее значение может отсутствовать → считаем 0
        var cur = variable_struct_exists(item.stats, stat) ? variable_struct_get(item.stats, stat) : 0;
        variable_struct_set(item.stats, stat, cur + value);
        // --------------------------------------------------------------------
    }

    // --- 7) Генерируем имя (можно заменить своей функцией) -----------------
    item.name = aty_generate_item_name(item);

    // --- 8) Описание (при желании можно добавить) ---------------------------
    // item.description = "…";

    return item;
}
function aty_add_random_bonus_stats_safe(_item) {
    if (!is_struct(_item)) return;
    
    var bonus_stats = [
        { stat: "crit_chance", value: 1 + irandom(2) },
        { stat: "crit_damage", value: 5 + irandom(10) },
        { stat: "attack_speed", value: 2 + irandom(3) },
        { stat: "cast_speed", value: 2 + irandom(3) },
        { stat: "dodge_chance", value: 1 + irandom(2) },
        { stat: "lifesteal", value: 1 + irandom(2) }
    ];
    
    var bonus_count = 1;
    if (_item.rarity >= RARITY.EPIC) bonus_count += 1;
    if (_item.rarity >= RARITY.LEGENDARY) bonus_count += 1;
    
    for (var i = 0; i < bonus_count; i++) {
        if (array_length(bonus_stats) == 0) break;
        
        var random_index = irandom(array_length(bonus_stats) - 1);
        var bonus = bonus_stats[random_index];
        var current_value = variable_struct_get(_item.stats, bonus.stat);
        variable_struct_set(_item.stats, bonus.stat, current_value + bonus.value);
        
        // Удаляем использованный бонус чтобы не повторяться
        array_delete(bonus_stats, random_index, 1);
    }
}

function aty_apply_rarity_bonuses_safe(_item) {
    if (!is_struct(_item)) return;
    
    // Базовые множители в зависимости от редкости
    var rarity_multiplier = 1 + (_item.rarity * 0.3);
    
    // Умножаем основные статы на множитель редкости
    var stat_names = variable_struct_get_names(_item.stats);
    for (var i = 0; i < array_length(stat_names); i++) {
        var stat_name = stat_names[i];
        var current_value = variable_struct_get(_item.stats, stat_name);
        if (current_value > 0) {
            var new_value = round(current_value * rarity_multiplier);
            variable_struct_set(_item.stats, stat_name, new_value);
        }
    }
}
// =============================================================================
// SLOT CONVERSION FOR BACKWARD COMPATIBILITY
// =============================================================================
function aty_convert_item_type_to_slot(_item_type) {
    switch (_item_type) {
        case ITEM_TYPE.WEAPON: return "WEAPON";
        case ITEM_TYPE.ARMOR: return "ARMOR";
        case ITEM_TYPE.ACCESSORY: return "ACCESSORY";
        case ITEM_TYPE.TRINKET: return "TRINKET";
        case ITEM_TYPE.CHARM: return "CHARM";
        default: return "WEAPON";
    }
}
// =============================================================================
// SAFE VERSIONS OF PROPERTY GENERATORS
// =============================================================================

function aty_generate_weapon_properties_safe(_item) {
    if (!is_struct(_item)) return;
    
    _item.weapon_type = irandom(4); // SWORD, AXE, STAFF, BOW, DAGGER
    
    // Безопасно устанавливаем базовые статы
    variable_struct_set(_item.stats, "attack_power", 10 + irandom(10));
    variable_struct_set(_item.stats, "crit_chance", 2 + irandom(3));
}

function aty_generate_armor_properties_safe(_item) {
    if (!is_struct(_item)) return;
    
    _item.armor_type = irandom(4); // HELMET, CHEST, GLOVES, BOOTS, SHIELD
    
    // Безопасно устанавливаем базовые статы
    variable_struct_set(_item.stats, "defense", 8 + irandom(8));
    variable_struct_set(_item.stats, "health", 20 + irandom(30));
}
function aty_generate_accessory_properties_safe(_item) {
    if (!is_struct(_item)) return;
    
    // Безопасно устанавливаем базовые статы
    variable_struct_set(_item.stats, "health", 15 + irandom(15));
    variable_struct_set(_item.stats, "mana", 10 + irandom(10));
    variable_struct_set(_item.stats, "crit_chance", 1 + irandom(2));
}


// =============================================================================
// UTILITY FUNCTION FOR MINI STATS DISPLAY
// =============================================================================

function aty_get_mini_stats_text(_item) {
    if (!is_struct(_item) || !variable_struct_exists(_item, "stats")) return "";
    
    var stats = _item.stats;
    var text = "";
    
    if (variable_struct_exists(stats, "attack_power") && stats.attack_power > 0) {
        text += "+" + string(stats.attack_power) + "A";
    }
    
    if (variable_struct_exists(stats, "magic_power") && stats.magic_power > 0) {
        if (text != "") text += " ";
        text += "+" + string(stats.magic_power) + "M";
    }
    
    if (variable_struct_exists(stats, "defense") && stats.defense > 0) {
        if (text != "") text += " ";
        text += "+" + string(stats.defense) + "D";
    }
    
    return text;
}

function aty_buy_item(_shop_index) {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) return false;
    
    if (_shop_index < 0 || _shop_index >= array_length(global.aty.shop.items)) return false;
    
    var item = global.aty.shop.items[_shop_index];
    var price = item.price || 100;
    
    if (global.aty.hero.gold < price) {
        aty_show_notification("❌ Недостаточно золота!");
        return false;
    }
    
    // Используем исправленную функцию копирования
    var item_copy = aty_copy_item(item);
    
    // Обновляем ID чтобы избежать конфликтов
    item_copy.id = item_copy.id + "_bought_" + string(current_time);
    
    // Используем новую систему добавления
    if (aty_add_item_to_inventory(item_copy)) {
        global.aty.hero.gold -= price;
        array_delete(global.aty.shop.items, _shop_index, 1);
        aty_show_notification("✅ Куплено: " + item.name + " за " + string(price) + " золота");
        return true;
    }
    
    return false;
}
function aty_refresh_shop() {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) return false;
    
    // Стоимость обновления
    var refresh_cost = 100;
    
    if (global.aty.hero.gold < refresh_cost) {
        aty_show_notification("Недостаточно золота для обновления!");
        return false;
    }
    
    // Списываем золото
    global.aty.hero.gold -= refresh_cost;
    
    // Генерируем новый ассортимент
    global.aty.shop.items = aty_generate_shop_items();
    
    aty_show_notification("Ассортимент магазина обновлен!");
    return true;
}

// =============================================================================
// UPDATED BUFF SYSTEM WITH PERCENTAGE BONUSES
// =============================================================================

function aty_get_buff_database() {
    return [
        {
            buff_key: "MIGHT",
            name: "Могущество",
            description: "+20% к силе атаки",
            stats: { attack_power_percent: 20 }
        },
        {
            buff_key: "BLESSED_BODY", 
            name: "Благословение Тела",
            description: "+15% к здоровью",
            stats: { health_percent: 15 }
        },
        {
            buff_key: "HASTE",
            name: "Ускорение",
            description: "+10% к скорости атаки",
            stats: { attack_speed_percent: 10 }
        },
        {
            buff_key: "BERSERKER",
            name: "Берсерк",
            description: "+25% к урону крита",
            stats: { crit_damage_percent: 25 }
        },
        {
            buff_key: "ACUTE",
            name: "Проницательность", 
            description: "+8% к шансу крита",
            stats: { crit_chance_percent: 8 }
        },
        {
            buff_key: "SHIELD",
            name: "Щит",
            description: "+20% к защите",
            stats: { defense_percent: 20 }
        },
        {
            buff_key: "FOCUS",
            name: "Фокусировка",
            description: "+15% к магической силе", 
            stats: { magic_power_percent: 15 }
        },
        {
            buff_key: "PROPHECY",
            name: "Пророчество",
            description: "+12% к скорости кастов",
            stats: { cast_speed_percent: 12 }
        },
        {
            buff_key: "HOLY_SHIELD",
            name: "Святой Щит",
            description: "+10% к шансу блока",
            stats: { block_chance_percent: 10 }
        },
        {
            buff_key: "GUIDANCE",
            name: "Наведение",
            description: "+5% к меткости",
            stats: { dexterity_percent: 5 }
        },
        {
            buff_key: "WIND_WALK",
            name: "Походка Ветра", 
            description: "+15% к скорости движения",
            stats: { movement_speed_percent: 15 }
        },
        {
            buff_key: "DEATH_WHISPER",
            name: "Шепот Смерти",
            description: "+10% к вампиризму",
            stats: { lifesteal_percent: 10 }
        },
        {
            buff_key: "BLESSED_SOUL",
            name: "Благословенная Душа",
            description: "+20% к мане",
            stats: { mana_percent: 20 }
        },
        {
            buff_key: "VELOCITY",
            name: "Скорость",
            description: "+8% к снижению перезарядки",
            stats: { cooldown_reduction_percent: 8 }
        },
        {
            buff_key: "AGILITY", 
            name: "Проворство",
            description: "+6% к уклонению",
            stats: { dodge_chance_percent: 6 }
        }
    ];
}

function aty_get_expedition_database() {
    return [
        {
            exp_key: "RUINS_1",
            name: "Руины Древних (Уровень 1)",
            duration: 60, // 1 минута
            difficulty: 1,
            boss: "",
            loot: [RARITY.COMMON, RARITY.UNCOMMON],
            completed: false,
            required_level: 1,
            gold_reward: 50,
            is_raid: false,
            description: "Исследуйте древние руины в поисках сокровищ"
        },
        {
            exp_key: "FOREST_2", 
            name: "Зачарованный Лес (Уровень 2)",
            duration: 120, // 2 минуты
            difficulty: 2,
            boss: "",
            loot: [RARITY.UNCOMMON, RARITY.RARE],
            completed: false,
            required_level: 2,
            gold_reward: 150,
            is_raid: false,
            description: "Пройдите через магический лес полный загадок"
        },
        {
            exp_key: "MOUNTAIN_3",
            name: "Гора Хефа (Уровень 3)",
            duration: 180, // 3 минуты
            difficulty: 3,
            boss: "HEPO",
            loot: [RARITY.RARE, RARITY.EPIC],
            completed: false,
            required_level: 3,
            gold_reward: 300,
            is_raid: false,
            description: "Восхождение на вулкан для встречи с Хефой"
        },
        {
            exp_key: "TEMPLE_4",
            name: "Храм Афины (Уровень 4)", 
            duration: 240, // 4 минуты
            difficulty: 4,
            boss: "FATTY",
            loot: [RARITY.EPIC, RARITY.LEGENDARY],
            completed: false,
            required_level: 4,
            gold_reward: 500,
            is_raid: false,
            description: "Проникните в древний храм богини мудрости"
        },
        {
            exp_key: "SPIRE_5",
            name: "Шпиль Дисциплины (Уровень 5)",
            duration: 300, // 5 минут
            difficulty: 5,
            boss: "DISC",
            loot: [RARITY.LEGENDARY, RARITY.MYTHIC],
            completed: false, 
            required_level: 5,
            gold_reward: 800,
            is_raid: false,
            description: "Испытайте себя на вершине башни дисциплины"
        },
        {
            exp_key: "DRAGON_LAIR_6",
            name: "Логово Древнего Дракона (Уровень 6)",
            duration: 180, // 3 минуты на нанесение урона
            difficulty: 6,
            boss: "ANCIENT_DRAGON",
            loot: [RARITY.MYTHIC, RARITY.DIVINE],
            completed: false,
            required_level: 6,
            gold_reward: 2000,
            is_raid: true,
            description: "Сразитесь с могущественным драконом! Нанесите максимальный урон за 3 минуты!",
            boss_health: 10000,
            phases: [70, 30], // Проценты HP для смены фаз
            enrage_timer: 120, // Энрейдж через 2 минуты
            abilities: [
                {
                    name: "Огненное Дыхание",
                    damage: 200,
                    cooldown: 30,
                    type: "FIRE",
                    description: "Наносит 200 урона всем игрокам"
                },
                {
                    name: "Хвостовой Удар", 
                    damage: 150,
                    cooldown: 20,
                    type: "PHYSICAL",
                    description: "Оглушает на 5 секунд"
                },
                {
                    name: "Магический Щит",
                    damage: 0,
                    cooldown: 45,
                    type: "SHIELD",
                    description: "Уменьшает получаемый урон на 50% на 10 секунд"
                },
                {
                    name: "Призыв Молодых Драконов",
                    damage: 100,
                    cooldown: 60,
                    type: "SUMMON",
                    description: "Призывает помощников"
                }
            ]
        }
    ];
}

function aty_get_expedition_info(_expedition_key) {
    var expeditions = aty_get_expedition_database();
    
    for (var i = 0; i < array_length(expeditions); i++) {
        if (expeditions[i].exp_key == _expedition_key) {
            return expeditions[i];
        }
    }
    
    return undefined;
}
// Обновите функцию aty_is_expedition_unlocked:
function aty_is_expedition_unlocked(_difficulty) {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) return false;
    
    // Проверяем уровень героя
    if (global.aty.hero.level < _difficulty) {
        return false;
    }
    
    // Для рейд-босса (уровень 6) нужны все предыдущие экспедиции завершены
    if (_difficulty == 6) {
        // Прямая проверка завершения экспедиций 1-5
        for (var i = 0; i < 5; i++) {
            if (!global.aty.expeditions[i].completed) {
                return false;
            }
        }
        return true;
    }
    
    return true;
}
function aty_get_difficulty_name(_difficulty) {
    switch (_difficulty) {
        case 1: return "Легкая";
        case 2: return "Простая";
        case 3: return "Средняя";
        case 4: return "Сложная";
        case 5: return "Эксперт";
        case 6: return "РЕЙД-БОСС";
        default: return "Неизвестно";
    }
}
function aty_calculate_expedition_rewards(_difficulty, _performance_multiplier = 1.0) {
    var base_gold = 0;
    var base_exp = 0;
    
    switch (_difficulty) {
        case 1: base_gold = 50; base_exp = 100; break;
        case 2: base_gold = 150; base_exp = 200; break;
        case 3: base_gold = 300; base_exp = 400; break;
        case 4: base_gold = 500; base_exp = 700; break;
        case 5: base_gold = 800; base_exp = 1100; break;
        case 6: base_gold = 2000; base_exp = 2500; break;
        default: base_gold = 50; base_exp = 100;
    }
    
    return {
        gold: round(base_gold * _performance_multiplier),
        exp: round(base_exp * _performance_multiplier),
        items: _difficulty + 1 // Количество предметов
    };
}
function aty_mark_expedition_completed(_expedition_key) {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) return false;
    
    var expeditions = global.aty.expeditions;
    
    for (var i = 0; i < array_length(expeditions); i++) {
        if (expeditions[i].exp_key == _expedition_key) {
            expeditions[i].completed = true;
            
            // Разблокируем помощницу если есть босс
            if (expeditions[i].boss != "" && expeditions[i].boss != "ANCIENT_DRAGON") {
                aty_unlock_companion_by_key(expeditions[i].boss);
            }
            
            // Специальное уведомление для рейд-босса
            if (expeditions[i].is_raid) {
                aty_show_notification("🎉 ВЕЛИКАЯ ПОБЕДА! Вы победили Древнего Дракона! 🎉");
            }
            
            return true;
        }
    }
    
    return false;
}
function aty_get_expedition_progress() {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) return { completed: 0, total: 0, percentage: 0 };
    
    var expeditions = global.aty.expeditions;
    var completed_count = 0;
    
    for (var i = 0; i < array_length(expeditions); i++) {
        if (expeditions[i].completed) {
            completed_count++;
        }
    }
    
    return {
        completed: completed_count,
        total: array_length(expeditions),
        percentage: round((completed_count / array_length(expeditions)) * 100)
    };
}
function aty_get_difficulty_color(_difficulty) {
    var colors = global.aty_colors;
    
    switch (_difficulty) {
        case 1: return colors.neon_green;
        case 2: return colors.neon_cyan;
        case 3: return colors.neon_blue;
        case 4: return colors.neon_yellow;
        case 5: return colors.neon_pink;
        case 6: return colors.neon_red;
        default: return colors.neon_blue;
    }
}
// Функция для тестирования рейд-босса (можно вызвать из консоли)
function aty_unlock_raid_boss() {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) return;
    
    // Завершаем все экспедиции
    for (var i = 0; i < 5; i++) {
        global.aty.expeditions[i].completed = true;
    }
    
    // Устанавливаем уровень героя
    global.aty.hero.level = max(global.aty.hero.level, 6);
    
    aty_show_notification("Рейд-босс разблокирован для тестирования!");
}
function aty_init_raid_boss() {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) return;
    
    global.aty.raid_boss = {
        active: false,
        boss_health: 0,
        boss_max_health: 10000, // 10,000 HP для босса
        boss_phase: 1,
        time_remaining: 180,
        total_damage: 0,
        player_dps: 0,
        abilities: [],
        phase_transition: false,
        special_attack_timer: 0,
        enrage_timer: 120, // Энрейдж через 2 минуты
        is_enraged: false
    };
}

// =============================================================================
// RAID BOSS START FUNCTION
// =============================================================================
// Также обновим функцию aty_start_raid_boss() для лучшей обработки ошибок:
function aty_start_raid_boss() {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) {
        show_debug_message("ATY system not initialized");
        return false;
    }
    
    // Проверяем требования
    if (global.aty.hero.level < 6) {
        aty_show_notification("Требуется уровень 6 для рейд-босса!");
        return false;
    }
    
    // Проверяем завершение всех предыдущих экспедиций
    var all_expeditions_completed = true;
    for (var i = 0; i < 5; i++) {
        if (!global.aty.expeditions[i].completed) {
            all_expeditions_completed = false;
            break;
        }
    }
    
    if (!all_expeditions_completed) {
        aty_show_notification("Требуется завершить все предыдущие экспедиции!");
        return false;
    }
    
    if (global.aty.expedition.active) {
        aty_show_notification("Завершите текущую экспедицию сначала!");
        return false;
    }
    
    // Инициализируем босса если нужно
    if (!variable_struct_exists(global.aty, "raid_boss")) {
        aty_init_raid_boss();
    }
    
    var raid_boss = global.aty.raid_boss;
    
    // Настраиваем босса
    raid_boss.active = true;
    raid_boss.boss_health = raid_boss.boss_max_health;
    raid_boss.time_remaining = 180;
    raid_boss.total_damage = 0;
    raid_boss.player_dps = 0;
    raid_boss.boss_phase = 1;
    raid_boss.phase_transition = false;
    raid_boss.special_attack_timer = 0;
    raid_boss.enrage_timer = 120;
    raid_boss.is_enraged = false;
    
    // Устанавливаем текущую экспедицию как рейд-босс
    global.aty.current_expedition = 5; // Индекс рейд-босса
    
    aty_show_notification("⚔️ РЕЙД-БОСС: Древний Дракон! У вас 3 минуты чтобы нанести максимальный урон!");
    return true;
}

// =============================================================================
// BOSS ABILITIES GENERATION
// =============================================================================

function aty_generate_boss_abilities() {
    return [
        {
            name: "Огненное Дыхание",
            damage: 200,
            cooldown: 30,
            timer: 0,
            description: "Наносит 200 урона всем игрокам",
            type: "FIRE"
        },
        {
            name: "Хвостовой Удар", 
            damage: 150,
            cooldown: 20,
            timer: 0,
            description: "Оглушает на 5 секунд",
            type: "PHYSICAL"
        },
        {
            name: "Магический Щит",
            damage: 0,
            cooldown: 45,
            timer: 0,
            description: "Уменьшает получаемый урон на 50% на 10 секунд",
            type: "SHIELD"
        },
        {
            name: "Призыв Молодых Драконов",
            damage: 100,
            cooldown: 60,
            timer: 0,
            description: "Призывает помощников",
            type: "SUMMON"
        }
    ];
}
// =============================================================================
// RAID BOSS STEP LOGIC
// =============================================================================
// Обновим функцию aty_raid_boss_step():
function aty_raid_boss_step(_dt) {
    if (!variable_struct_exists(global.aty, "raid_boss") || !global.aty.raid_boss.active) return;
    
    var raid_boss = global.aty.raid_boss;
    
    // Уменьшаем таймер
    raid_boss.time_remaining -= _dt;
    
    // Обновляем DPS
    if (raid_boss.time_remaining > 0) {
        raid_boss.player_dps = raid_boss.total_damage / (180 - raid_boss.time_remaining);
    }
    
    // Проверяем завершение (время вышло или босс убит)
    if (raid_boss.time_remaining <= 0 || raid_boss.boss_health <= 0) {
        aty_complete_raid_boss();
    }
    
    // Обновляем таймер энрейджа
    if (!raid_boss.is_enraged) {
        raid_boss.enrage_timer -= _dt;
        if (raid_boss.enrage_timer <= 0) {
            raid_boss.is_enraged = true;
            aty_show_notification("⚡ Дракон впадает в ярость! Урон увеличен!");
        }
    }
}

// =============================================================================
// BOSS PHASE TRANSITIONS
// =============================================================================

function aty_boss_phase_transition(_new_phase) {
    var raid_boss = global.aty.raid_boss;
    raid_boss.boss_phase = _new_phase;
    raid_boss.phase_transition = true;
    
    switch (_new_phase) {
        case 2:
            aty_show_notification("⚡ Фаза 2: Дракон усиливает свою броню!");
            raid_boss.boss_max_health += 2000; // Увеличиваем HP
            raid_boss.boss_health += 2000;
            break;
        case 3:
            aty_show_notification("🔥 Фаза 3: ДРАКОН В ЯРОСТИ! Атаки усиливаются!");
            // Увеличиваем урон способностей
            for (var i = 0; i < array_length(raid_boss.abilities); i++) {
                raid_boss.abilities[i].damage *= 1.5;
            }
            break;
    }
    
    // Сбрасываем переход через 3 секунды
    alarm[3] = 3 * room_speed;
}

// =============================================================================
// BOSS SPECIAL ATTACKS
// =============================================================================

function aty_boss_special_attack() {
    if (!global.aty.raid_boss.active) return;
    
    var raid_boss = global.aty.raid_boss;
    var random_ability = raid_boss.abilities[irandom(array_length(raid_boss.abilities) - 1)];
    
    // Проверяем кулдаун
    if (random_ability.timer > 0) return;
    
    // Применяем способность
    switch (random_ability.type) {
        case "FIRE":
            aty_show_notification("🐉 Дракон использует: " + random_ability.name + "!");
            // В реальной игре здесь был бы урон по игрокам
            break;
        case "SHIELD":
            aty_show_notification("🛡️ Дракон использует: " + random_ability.name + "!");
            // Уменьшение получаемого урона
            break;
        case "SUMMON":
            aty_show_notification("👥 Дракон использует: " + random_ability.name + "!");
            break;
        default:
            aty_show_notification("⚔️ Дракон использует: " + random_ability.name + "!");
            break;
    }
    
    random_ability.timer = random_ability.cooldown;
}

// =============================================================================
// BOSS ENRAGE MECHANIC
// =============================================================================
function aty_boss_enrage() {
    var raid_boss = global.aty.raid_boss;
    
    aty_show_notification("💢 ДРАКОН ВПАДАЕТ В ЯРОСТЬ! Урон увеличен на 100%!");
    
    // Удваиваем урон всех способностей
    for (var i = 0; i < array_length(raid_boss.abilities); i++) {
        raid_boss.abilities[i].damage *= 2;
        raid_boss.abilities[i].cooldown *= 0.7; // Уменьшаем кулдаун
    }
}

// =============================================================================
// PLAYER ATTACK SYSTEM
// =============================================================================
function aty_player_attack_boss() {
    if (!global.aty.raid_boss.active) return 0;
    
    var raid_boss = global.aty.raid_boss;
    var hero = global.aty.hero;
    
    // Базовый урон от атаки
    var base_damage = hero.stats.attack_power * 0.5;
    
    // Учитываем магическую силу
    var magic_damage = hero.stats.magic_power * 0.3;
    
    // Случайный множитель (0.8 - 1.2)
    var random_multiplier = 0.8 + random(0.4);
    
    // Шанс крита
    var is_critical = false;
    var crit_damage = 1.0;
    if (random(100) < hero.stats.crit_chance) {
        is_critical = true;
        crit_damage = hero.stats.crit_damage / 100;
    }
    
    // Финальный урон
    var total_damage = round((base_damage + magic_damage) * random_multiplier * crit_damage);
    
    // Уменьшаем урон если у босса щит
    var has_shield = false;
    for (var i = 0; i < array_length(raid_boss.abilities); i++) {
        if (raid_boss.abilities[i].type == "SHIELD" && raid_boss.abilities[i].timer > 0) {
            has_shield = true;
            break;
        }
    }
    
    if (has_shield) {
        total_damage = round(total_damage * 0.5);
    }
    
    // Применяем урон
    raid_boss.boss_health -= total_damage;
    raid_boss.total_damage += total_damage;
    
    // Создаем текст урона для отображения
    var damage_text = {
        x: 300 + irandom(200),
        y: 200 + irandom(100),
        text: string(total_damage),
        timer: 60,
        color: is_critical ? c_yellow : c_white,
        is_critical: is_critical
    };
    
    if (!variable_struct_exists(global.aty, "damage_numbers")) {
        global.aty.damage_numbers = [];
    }
    
    array_push(global.aty.damage_numbers, damage_text);
    
    return total_damage;
}
// =============================================================================
// COMPLETE RAID BOSS
// =============================================================================
// Добавим функцию завершения рейд-босса:
function aty_complete_raid_boss() {
    if (!variable_struct_exists(global.aty, "raid_boss")) return;
    
    var raid_boss = global.aty.raid_boss;
    var raid_expedition = global.aty.expeditions[5];
    
    raid_boss.active = false;
    
    // Вычисляем результат
    var performance_ratio = raid_boss.total_damage / raid_boss.boss_max_health;
    var is_victory = raid_boss.boss_health <= 0;
    
    if (is_victory) {
        // Победа - полная награда
        global.aty.hero.gold += raid_expedition.gold_reward;
        global.aty.hero.exp += raid_expedition.gold_reward * 2;
        
        // Отмечаем экспедицию как завершенную
        raid_expedition.completed = true;
        aty_mark_expedition_completed("DRAGON_LAIR_6");
        
        aty_show_notification("🎉 ПОБЕДА! Вы победили Древнего Дракона! 🎉");
    } else {
        // Поражение по времени - частичная награда
        var partial_reward = floor(raid_expedition.gold_reward * performance_ratio * 0.5);
        global.aty.hero.gold += partial_reward;
        global.aty.hero.exp += partial_reward;
        
        aty_show_notification("Время вышло! Нанесено урона: " + string(floor(performance_ratio * 100)) + "%");
    }
    
    // Генерируем лут
    var loot_count = 2 + floor(performance_ratio * 3);
    for (var i = 0; i < loot_count; i++) {
        var rarity_roll = random(1);
        var item_rarity = RARITY.RARE;
        
        if (rarity_roll < 0.1) item_rarity = RARITY.LEGENDARY;
        else if (rarity_roll < 0.3) item_rarity = RARITY.EPIC;
        
        var loot_item = aty_generate_loot_item_safe(item_rarity);
        array_push(global.aty.inventory, loot_item);
    }
    
    aty_show_notification("Получено: " + string(loot_count) + " предметов");
}
// =============================================================================
// RAID BOSS REWARDS
// =============================================================================

function aty_give_raid_boss_rewards(_victory, _tier, _efficiency) {
    var base_gold = 2000;
    var bonus_gold = 0;
    
    // Базовые награды
    if (_victory) {
        bonus_gold = base_gold * (_efficiency / 100);
        global.aty.hero.gold += round(base_gold + bonus_gold);
    } else {
        global.aty.hero.gold += round(base_gold * 0.3);
    }
    
    // Предметы в зависимости от тира
    var item_count = 0;
    var item_rarity = RARITY.EPIC;
    
    switch (_tier) {
        case "S":
            item_count = 4;
            item_rarity = RARITY.DIVINE;
            break;
        case "A":
            item_count = 3;
            item_rarity = RARITY.MYTHIC;
            break;
        case "B":
            item_count = 2;
            item_rarity = RARITY.LEGENDARY;
            break;
        case "C":
            item_count = 2;
            item_rarity = RARITY.EPIC;
            break;
        case "D":
            item_count = 1;
            item_rarity = RARITY.RARE;
            break;
    }
    
    // Генерируем предметы
    for (var i = 0; i < item_count; i++) {
        var loot_item = aty_generate_loot_item_safe(item_rarity);
        array_push(global.aty.inventory, loot_item);
    }
    
    // Специальная награда за победу
    if (_victory) {
        var special_reward = aty_create_dragon_trophy();
        array_push(global.aty.trophies, special_reward);
    }
}

// =============================================================================
// DRAGON TROPHY
// =============================================================================
function aty_create_dragon_trophy() {
    return {
        id: "trophy_ancient_dragon",
        name: "Сердце Древнего Дракона",
        description: "Трофей за победу над Древним Драконом",
        type: "SPECIAL",
        bonus: {
            attack_power: 50,
            magic_power: 50,
            health: 200
        },
        acquired_date: current_time
    };
}
// =============================================================================
// RAID BOSS RESULTS DISPLAY
// =============================================================================
function aty_show_raid_boss_results(_victory, _efficiency, _tier) {
    var result_text = "";
    
    if (_victory) {
        result_text = "🎉 ПОБЕДА! Древний Дракон повержен! 🎉";
    } else {
        result_text = "💀 Поражение! Дракон оказался сильнее...";
    }
    
    var details = "Рейтинг эффективности: " + string(floor(_efficiency)) + "%\n" +
                 "Уровень награды: " + _tier + "\n" +
                 "Получено золота: " + string(global.aty.hero.gold) + "G";
    
    aty_show_notification(result_text + "\n" + details);
}
// =============================================================================
// RAID BOSS UI DRAWING
// =============================================================================

// Добавим функцию для отображения интерфейса рейд-босса:
function aty_draw_raid_boss_ui() {
    var zones = global.aty.ui_zones;
    var colors = global.aty_colors;
    var middle_zone = zones.middle;
    var raid_boss = global.aty.raid_boss;
    
    var center_x = (middle_zone.x1 + middle_zone.x2) / 2;
    var center_y = (middle_zone.y1 + middle_zone.y2) / 2;
    
    // Панель рейд-босса
    draw_neon_panel(center_x - 250, center_y - 150, center_x + 250, center_y + 150, "⚔️ РЕЙД-БОСС: Древний Дракон");
    
    // Полоса здоровья босса
    var health_ratio = raid_boss.boss_health / raid_boss.boss_max_health;
    var health_bar_width = 400;
    var health_bar_height = 30;
    var health_bar_x = center_x - health_bar_width / 2;
    var health_bar_y = center_y - 100;
    
    // Фон полосы здоровья
    draw_set_color(colors.bg_light);
    draw_rectangle(health_bar_x, health_bar_y, health_bar_x + health_bar_width, health_bar_y + health_bar_height, false);
    
    // Заполнение здоровья
    var health_color = colors.neon_green;
    if (health_ratio < 0.3) health_color = colors.neon_red;
    else if (health_ratio < 0.6) health_color = colors.neon_yellow;
    
    draw_set_color(health_color);
    draw_rectangle(health_bar_x, health_bar_y, health_bar_x + health_bar_width * health_ratio, health_bar_y + health_bar_height, false);
    
    // Рамка полосы здоровья
    draw_set_color(colors.neon_blue);
    draw_rectangle(health_bar_x, health_bar_y, health_bar_x + health_bar_width, health_bar_y + health_bar_height, true);
    
    // Текст здоровья
    draw_set_color(colors.text_primary);
    draw_set_halign(fa_center);
    draw_text(center_x, health_bar_y - 25, "Здоровье босса: " + string(floor(raid_boss.boss_health)) + "/" + string(raid_boss.boss_max_health));
    
    // Таймер
    draw_text(center_x, health_bar_y + 40, "Осталось времени: " + string(ceil(raid_boss.time_remaining)) + "с");
    
    // Нанесенный урон
    draw_text(center_x, health_bar_y + 70, "Нанесено урона: " + string(raid_boss.total_damage));
    draw_text(center_x, health_bar_y + 95, "DPS: " + string(floor(raid_boss.player_dps)));
    
    // Подсказка управления
    draw_set_color(colors.neon_cyan);
    draw_text(center_x, center_y + 120, "ПРОБЕЛ - атаковать босса");
    
    draw_set_halign(fa_left);
}

// =============================================================================
// DAMAGE NUMBERS DRAWING
// =============================================================================
function aty_draw_damage_numbers() {
    if (!variable_struct_exists(global.aty, "damage_numbers")) return;
    
    var damage_numbers = global.aty.damage_numbers;
    
    for (var i = array_length(damage_numbers) - 1; i >= 0; i--) {
        var damage = damage_numbers[i];
        
        damage.y -= 2; // Движение вверх
        damage.timer -= 1;
        
        // Прозрачность по таймеру
        var alpha = damage.timer / 60;
        draw_set_alpha(alpha);
        
        // Размер текста для критов
        if (damage.is_critical) {
            draw_set_font(fnt_large);
        }
        
        draw_set_color(damage.color);
        draw_set_halign(fa_center);
        draw_text(damage.x, damage.y, damage.text);
        draw_set_halign(fa_left);
        
        if (damage.is_critical) {
            draw_set_font(fnt_main);
        }
        
        draw_set_alpha(1);
        
        // Удаляем старые числа
        if (damage.timer <= 0) {
            array_delete(damage_numbers, i, 1);
        }
    }
}
function aty_upgrade_companion_rank(_companion_index) {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) return false;
    
    if (_companion_index < 0 || _companion_index >= array_length(global.aty.companions)) return false;
    
    var companion = global.aty.companions[_companion_index];
    var upgrade_cost = companion.rank * 500; // Стоимость увеличивается с каждым рангом
    
    if (global.aty.hero.gold < upgrade_cost) {
        aty_show_notification("Недостаточно золота для повышения ранга!");
        return false;
    }
    
    if (companion.rank >= 3) {
        aty_show_notification("Достигнут максимальный ранг!");
        return false;
    }
    
    // Списываем золото и повышаем ранг
    global.aty.hero.gold -= upgrade_cost;
    companion.rank += 1;
    
    aty_show_notification(companion.name + " повышен до ранга " + string(companion.rank) + "! Доступен новый бафф.");
    return true;
}
function aty_update_trophy_progress(_trophy_id, _progress = 1) {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) return;
    
    var trophy_db = aty_get_trophy_database();
    var trophy_data = aty_find_trophy_by_id(trophy_db, _trophy_id);
    
    if (!is_struct(trophy_data)) return;
    
    // Если трофей уже разблокирован, пропускаем
    if (aty_has_trophy(_trophy_id)) return;
    
    // Обновляем прогресс - ИЗМЕНЕНО: работа со структурой вместо ds_map
    var current_progress = aty_get_trophy_progress(_trophy_id);
    var new_progress = max(current_progress, _progress);
    
    variable_struct_set(global.aty.trophies.progress, _trophy_id, new_progress);
    
    // Проверяем, достигнут ли целевой прогресс
    if (new_progress >= trophy_data.target) {
        aty_unlock_trophy(_trophy_id);
    }
}

function aty_check_trophy_unlock(_trophy_id, _current_progress) {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) return;
    
    var trophy_db = aty_get_trophy_database();
    var trophy_data = aty_find_trophy_by_id(trophy_db, _trophy_id);
    
    if (!is_struct(trophy_data)) return;
    
    // Если трофей уже разблокирован, пропускаем
    if (aty_has_trophy(_trophy_id)) return;
    
    // Проверяем, достигнут ли целевой показатель
    if (_current_progress >= trophy_data.target) {
        aty_unlock_trophy(_trophy_id);
    }
}