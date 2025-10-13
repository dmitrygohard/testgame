// =============================================================================
// aty_core.gml - Complete game logic for Attacking The Youth
// =============================================================================

// Enums and Constants
// Добавляем новые enum
enum WALK_STATE { IDLE, WALKING, RETURNED }
enum ITEM_SET { NONE, WARRIOR, MAGE, ROGUE, GUARDIAN }
enum RARITY { COMMON, UNCOMMON, RARE, EPIC, LEGENDARY, MYTHIC, DIVINE }
enum EQUIPMENT_SLOT { WEAPON, ARMOR, ACCESSORY, TRINKET, CHARM }
enum TAB { HERO, INVENTORY, TROPHIES, ABILITIES, SHOP, STATISTICS, QUESTS, MINIRAIDS }
enum COMPANION_STATE { LOCKED, AVAILABLE, TRAINING, WALKING }
enum EXPEDITION_STATE { AVAILABLE, IN_PROGRESS, COMPLETED }
enum VFX_PALETTE { CALM, GOOD, BAD, NEUTRAL }
enum RAID_STATE { AVAILABLE, IN_PROGRESS, COMPLETED }
// Новые enum для улучшенной системы
enum ITEM_TYPE { WEAPON, ARMOR, ACCESSORY, TRINKET, CHARM }
enum WEAPON_TYPE { SWORD, AXE, STAFF, BOW, DAGGER }
enum TROPHY_RARITY { BRONZE, SILVER, GOLD, PLATINUM, DIAMOND }
enum TROPHY_CATEGORY { COMBAT, EXPLORATION, COLLECTION, CRAFTING, SPECIAL, BOSS }
enum ARMOR_TYPE { HELMET, CHEST, GLOVES, BOOTS, SHIELD }
enum MATERIAL { WOOD, IRON, STEEL, SILVER, GOLD, MITHRIL, DRAGONSCALE, CRYSTAL }
enum MINIGAME_TYPE {
    NONE,
    QUICK_TIME_EVENT,    // Быстрая реакция
    MEMORY_SEQUENCE,     // Запомни последовательность  
    TARGET_PRACTICE,     // Порази цель
    RHYTHM_TAP,         // Ритмичное нажатие
    SLOT_MACHINE        // Игровой автомат
}

enum MINIGAME_RESULT {
    FAILED,
    SUCCESS,
    CRITICAL_SUCCESS
}

enum PASSIVE_EFFECT { 
    TREASURE_SENSE, SET_SYNERGY, GUARDIAN_AURA, 
    QUICK_HANDS, BLADE_DANCER, RELENTLESS, FORTUNE_FAVORS 
}




// =============================================================================
// IMPROVED HERO STATS SYSTEM
// =============================================================================

enum HERO_STAT {
    // Основные характеристики
    STRENGTH,       // Сила - физическая атака, переносимый вес
    AGILITY,        // Ловкость - крит, скорость атаки, уклонение
    INTELLIGENCE,   // Интеллект - магическая атака, мудрость
    VITALITY,       // Телосложение - здоровье, защита
    DEXTERITY,      // Меткость - точность, скорость кастов
    LUCK,           // Удача - шанс крита, редкий дроп
    
    // Вторичные характеристики
    HEALTH,         // Здоровье
    MANA,           // Мана для способностей
    ATTACK_POWER,   // Сила атаки
    MAGIC_POWER,    // Магическая сила
    DEFENSE,        // Защита
    CRIT_CHANCE,    // Шанс крита
    CRIT_DAMAGE,    // Урон крита
    ATTACK_SPEED,   // Скорость атаки
    CAST_SPEED,     // Скорость кастов
    DODGE_CHANCE,   // Шанс уклонения
    BLOCK_CHANCE,   // Шанс блока
    LIFESTEAL,      // Вампиризм
    COOLDOWN_REDUCTION, // Снижение перезарядки
    MOVEMENT_SPEED  // Скорость передвижения
}

// =============================================================================
// HERO STATS INITIALIZATION FUNCTIONS
// =============================================================================

function aty_create_base_stats_struct() {
    return {
        strength: 10,      // +2 атаки за уровень, +10 здоровья
        agility: 10,       // +1% крита, +0.5% скорости атаки
        intelligence: 10,  // +2 магии, +10 маны
        vitality: 10,      // +20 здоровья, +1 защита
        dexterity: 10,     // +0.5% точности, +1% скорости кастов
        luck: 10           // +0.3% крита, +1% редкого дропа
    };
}

function aty_create_secondary_stats_struct() {
    return {
        health: 0,                // Здоровье
        mana: 0,                  // Мана
        attack_power: 0,          // Сила атаки
        magic_power: 0,           // Магическая сила
        defense: 0,               // Защита
        crit_chance: 5,           // Шанс крита %
        crit_damage: 150,         // Урон крита %
        attack_speed: 100,        // Скорость атаки %
        cast_speed: 100,          // Скорость кастов %
        dodge_chance: 2,          // Шанс уклонения %
        block_chance: 0,          // Шанс блока %
        lifesteal: 0,             // Вампиризм %
        cooldown_reduction: 0,    // Снижение перезарядки %
        movement_speed: 100       // Скорость передвижения %
    };
}

// =============================================================================
// UPDATED HERO INITIALIZATION
// =============================================================================
function aty_init() {
    // Сначала инициализируем цвета
    aty_init_colors();
    
    // 1. Создаем основную структуру global.aty, если её нет
    if (!variable_global_exists("aty")) {
        global.aty = {};
    }
    
    // 2. Инициализируем UI зоны с правильными размерами для экрана 1000x1000
    if (!variable_struct_exists(global.aty, "ui_zones")) {
        global.aty.ui_zones = {
            top: { x1: 10, y1: 10, x2: 990, y2: 180 },
            middle: { x1: 10, y1: 190, x2: 990, y2: 570 },
            bottom: { x1: 10, y1: 580, x2: 990, y2: 990 },
            portraits: { x1: 10, y1: 580, x2: 190, y2: 990 },
            tabs: { x1: 200, y1: 580, x2: 990, y2: 990 }
        };
    }
    
    // 3. Инициализируем текущую вкладку
    if (!variable_struct_exists(global.aty, "current_tab")) {
        global.aty.current_tab = TAB.HERO;
    }
    
    // 4. Инициализируем текущую категорию трофеев
    if (!variable_struct_exists(global.aty, "current_trophy_category")) {
        global.aty.current_trophy_category = TROPHY_CATEGORY.COMBAT;
    }
    
    // 5. Инициализируем текущую категорию квестов
    if (!variable_struct_exists(global.aty, "current_quest_category")) {
        global.aty.current_quest_category = 0; // 0 = Активные квесты
    }
    
    // 6. Инициализируем героя с улучшенными характеристиками
    if (!variable_struct_exists(global.aty, "hero")) {
        global.aty.hero = {
            level: 1,
            exp: 0,
            gold: 1000,
            passives: [],
            equipment: {
                WEAPON: noone,
                ARMOR: noone,
                ACCESSORY: noone, 
                TRINKET: noone,
                CHARM: noone
            },
            costumes: ["default"],
            
            // ОСНОВНЫЕ ХАРАКТЕРИСТИКИ (игрок распределяет очки)
            base_stats: aty_create_base_stats_struct(),
            
            // ВТОРИЧНЫЕ ХАРАКТЕРИСТИКИ (расчитываются автоматически)
            stats: aty_create_secondary_stats_struct(),
            
            // Система прогрессии
            stat_points: 0,        // Свободные очки характеристик
            talent_points: 0,      // Очки талантов
            prestige_level: 0,     // Уровень престижа
            
            // Специализации
            specializations: [],
            active_build: 0
        };
    }
    
    // 7. Инициализируем систему арен
    if (!variable_struct_exists(global.aty, "arenas")) {
        global.aty.arenas = {
            unlocked: [],
            training: 0,
            walk: 0
        };
    }
    
    // 8. Инициализируем экспедиции
    if (!variable_struct_exists(global.aty, "expedition")) {
        global.aty.expedition = {
            progress: 0,
            drops: [],
            active: false,
            timer: 0,
            flash: { active: false, timer: 0, color: c_white },
            active_buffs: [],
            special_event: false
        };
    }
    
    // 9. Инициализируем базу данных экспедиций
    if (!variable_struct_exists(global.aty, "expeditions")) {
        global.aty.expeditions = aty_get_expedition_database();
    }
    
    // 10. Инициализируем рейды
    if (!variable_struct_exists(global.aty, "raids")) {
        global.aty.raids = {
            timer: 0,
            active: false,
            current_raid: -1,
            state: RAID_STATE.AVAILABLE
        };
    }
    
    // 11. Инициализируем магазин
    if (!variable_struct_exists(global.aty, "shop")) {
        global.aty.shop = {
            items: []
        };
    }
    
    // 12. Инициализируем VFX систему
    if (!variable_struct_exists(global.aty, "vfx")) {
        global.aty.vfx = {
            shaders: [],
            palette: "good",
            enabled: true,
            surface: -1,
            time: 0
        };
    }
    
    // 13. Инициализируем систему уведомлений
    if (!variable_struct_exists(global.aty, "notification")) {
        global.aty.notification = {
            text: "",
            timer: 0
        };
    }
    
    // 14. Инициализируем систему трофеев
    if (!variable_struct_exists(global.aty, "trophies")) {
        global.aty.trophies = {
            unlocked: [],
            progress: {},
            bonuses: {},
            total_score: 0
        };
    } else {
        // Если trophies существует, но это массив - преобразуем в структуру
        if (is_array(global.aty.trophies)) {
            var old_trophies = global.aty.trophies;
            global.aty.trophies = {
                unlocked: old_trophies,
                progress: {},
                bonuses: {},
                total_score: 0
            };
        }
    }
    
    // 15. Инициализируем систему квестов
    if (!variable_struct_exists(global.aty, "quests")) {
        global.aty.quests = {
            active_quests: [],
            completed_quests: [],
            failed_quests: [],
            daily_quests: [],
            weekly_quests: [],
            daily_refresh_time: current_time,
            weekly_refresh_time: current_time,
            quest_stats: {
                total_completed: 0,
                daily_completed: 0,
                weekly_completed: 0,
                failed_quests: 0,
                gold_earned: 0,
                exp_earned: 0
            }
        };
    }
    
    // 16. Инициализируем компаньонов
    if (!variable_struct_exists(global.aty, "companions")) {
        global.aty.companions = aty_get_companion_database();
    }
    
    // 17. Инициализируем инвентарь
    if (!variable_struct_exists(global.aty, "inventory")) {
        global.aty.inventory = [];
    }
    
    // 18. Инициализируем настройки инвентаря
    if (!variable_struct_exists(global.aty, "inventory_settings")) {
        global.aty.inventory_settings = {
            sort_by: "name",
            sort_ascending: true,
            filter_type: "all",
            filter_rarity: "all", 
            show_equipped: false,
            search_text: ""
        };
    }
    
    // 19. Инициализируем статистику предметов
    if (!variable_struct_exists(global.aty, "item_stats")) {
        global.aty.item_stats = {
            total_items_found: 0,
            items_by_rarity: {
                common: 0,
                uncommon: 0, 
                rare: 0,
                epic: 0,
                legendary: 0,
                mythic: 0,
                divine: 0
            },
            items_by_type: {
                weapon: 0,
                armor: 0,
                accessory: 0,
                trinket: 0,
                charm: 0,
                gem: 0
            },
            highest_rarity_found: RARITY.COMMON
        };
    }
    
    // 20. Инициализируем систему мини-игр
    if (!variable_struct_exists(global.aty, "minigame")) {
        global.aty.minigame = aty_create_minigame_struct();
    }
    
    // 21. Инициализируем стили для слотов экипировки
    if (!variable_struct_exists(global, "aty_equipment_styles")) {
        global.aty_equipment_styles = {
            WEAPON: {
                color: make_color_rgb(255, 100, 100),
                border_color: make_color_rgb(200, 50, 50),
                icon: "⚔",
                name: "Оружие",
                shape: "vertical_sword"
            },
            ARMOR: {
                color: make_color_rgb(100, 100, 255),
                border_color: make_color_rgb(50, 50, 200),
                icon: "🛡",
                name: "Броня", 
                shape: "chest"
            },
            ACCESSORY: {
                color: make_color_rgb(100, 255, 100),
                border_color: make_color_rgb(50, 200, 50),
                icon: "💍",
                name: "Аксессуар",
                shape: "circle"
            },
            TRINKET: {
                color: make_color_rgb(255, 255, 100),
                border_color: make_color_rgb(200, 200, 50),
                icon: "📿",
                name: "Тринит",
                shape: "diamond"
            },
            CHARM: {
                color: make_color_rgb(255, 100, 255),
                border_color: make_color_rgb(200, 50, 200),
                icon: "🔮",
                name: "Амулет",
                shape: "hexagon"
            }
        };
    }
    
    // 22. Генерируем товары для магазина
    try {
        global.aty.shop.items = aty_generate_shop_items();
    } catch (e) {
        show_debug_message("Error generating shop items: " + string(e));
        global.aty.shop.items = [];
    }
    
    // 23. Даем герою начальные пассивные способности
    for (var i = 0; i < 3; i++) {
        try {
            aty_unlock_random_passive();
        } catch (e) {
            show_debug_message("Error unlocking passive: " + string(e));
            break;
        }
    }
    
    // 24. Инициализируем VFX
    aty_vfx_init();
    
    // 25. Пересчитываем характеристики героя
    aty_recalculate_hero_stats();
    
    // 26. Инициализируем прогресс трофеев
    aty_init_trophies();
    
    // 27. Генерируем квесты
    try {
        aty_generate_daily_quests();
        aty_generate_weekly_quests();
    } catch (e) {
        show_debug_message("Error generating quests: " + string(e));
        // Создаем квесты по умолчанию в случае ошибки
        aty_create_default_daily_quests();
        aty_create_default_weekly_quests();
    }
    
    // 28. Добавляем тестовые предметы только если их нет
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty) || array_length(global.aty.inventory) == 0) {
        try {
            aty_add_test_items();
        } catch (e) {
            show_debug_message("Error adding test items: " + string(e));
        }
    }
    
    show_debug_message("ATY System initialized successfully");
    
    // Отладочная информация
    show_debug_message("Trophies type: " + string(typeof(global.aty.trophies)));
    show_debug_message("Trophies is struct: " + string(is_struct(global.aty.trophies)));
    show_debug_message("Current tab: " + string(global.aty.current_tab));
}
// Вспомогательная функция для проверки существования ключа в ds_map
function ds_map_get_safe(_map, _key, _default = 0) {
    if (!ds_exists(_map, ds_type_map)) return _default;
    return ds_map_get(_map, _key) ?? _default;
}

// Вспомогательная функция для получения всех ключей ds_map как массива
function ds_map_get_keys(_map) {
    if (!ds_exists(_map, ds_type_map)) return [];
    return ds_map_get_keys(_map);
}
// =============================================================================
// UPDATED STAT RECALCULATION FUNCTION
// =============================================================================

function aty_recalculate_hero_stats() {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) return;
    
    // Сначала рассчитываем базовые характеристики
    aty_recalculate_base_stats();
    
    // Затем применяем бонусы от трофеев
    aty_apply_trophy_stat_bonuses();
    
    // Затем применяем активные баффы от компаньонов (если есть экспедиция)
    if (global.aty.expedition.active && variable_struct_exists(global.aty.expedition, "active_buffs")) {
        aty_apply_active_buffs();
    }
    
    // Ограничиваем максимальные значения
    var stats = global.aty.hero.stats;
    stats.crit_chance = min(stats.crit_chance, 75);
    stats.dodge_chance = min(stats.dodge_chance, 50);
    stats.cooldown_reduction = min(stats.cooldown_reduction, 70);
    stats.block_chance = min(stats.block_chance, 50);
    stats.lifesteal = min(stats.lifesteal, 30);
}

function aty_apply_trophy_stat_bonuses() {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) return;
    
    // БЕЗОПАСНАЯ ПРОВЕРКА: убеждаемся что trophies является структурой
    if (!variable_struct_exists(global.aty, "trophies") || !is_struct(global.aty.trophies)) {
        return;
    }
    
    // БЕЗОПАСНАЯ ПРОВЕРКА: убеждаемся что bonuses существует и является структурой
    if (!variable_struct_exists(global.aty.trophies, "bonuses") || !is_struct(global.aty.trophies.bonuses)) {
        return;
    }
    
    var hero = global.aty.hero;
    var base_stats = hero.base_stats;
    var stats = hero.stats;
    
    // Применяем бонусы к основным характеристикам
    var base_stat_keys = ["strength", "agility", "intelligence", "vitality", "dexterity", "luck"];
    for (var i = 0; i < array_length(base_stat_keys); i++) {
        var stat_key = base_stat_keys[i];
        if (variable_struct_exists(global.aty.trophies.bonuses, stat_key)) {
            var bonus = variable_struct_get(global.aty.trophies.bonuses, stat_key);
            if (is_real(bonus) && bonus > 0) {
                var current_value = variable_struct_get(base_stats, stat_key);
                variable_struct_set(base_stats, stat_key, current_value + bonus);
            }
        }
    }
    
    // Применяем бонусы к вторичным характеристикам
    var secondary_stats = [
        "health", "mana", "attack_power", "magic_power", "defense", 
        "crit_chance", "crit_damage", "attack_speed", "cast_speed",
        "dodge_chance", "block_chance", "lifesteal", "cooldown_reduction", "movement_speed"
    ];
    
    for (var i = 0; i < array_length(secondary_stats); i++) {
        var stat_key = secondary_stats[i];
        if (variable_struct_exists(global.aty.trophies.bonuses, stat_key)) {
            var bonus = variable_struct_get(global.aty.trophies.bonuses, stat_key);
            if (is_real(bonus) && bonus > 0) {
                var current_value = variable_struct_get(stats, stat_key) || 0;
                variable_struct_set(stats, stat_key, current_value + bonus);
            }
        }
    }
}


function aty_cleanup_trophies() {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) return;
    
    // ИЗМЕНЕНО: больше не нужно уничтожать ds_map'ы, так как используем структуры
    // Структуры автоматически управляются сборщиком мусора
}

function aty_recalculate_base_stats() {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) return;
    
    var hero = global.aty.hero;
    var base_stats = hero.base_stats;
    var stats = hero.stats;
    
    // Сбрасываем к базовым значениям (рассчитываем из основных характеристик)
    stats.health = 100 + (base_stats.vitality * 20) + (base_stats.strength * 10);
    stats.mana = 50 + (base_stats.intelligence * 15);
    stats.attack_power = 10 + (base_stats.strength * 2);
    stats.magic_power = 5 + (base_stats.intelligence * 2);
    stats.defense = 5 + (base_stats.vitality * 1.5);
    stats.crit_chance = 5 + (base_stats.agility * 1) + (base_stats.luck * 0.3);
    stats.crit_damage = 150 + (base_stats.agility * 2);
    stats.attack_speed = 100 + (base_stats.agility * 2);
    stats.cast_speed = 100 + (base_stats.dexterity * 1.5);
    stats.dodge_chance = 2 + (base_stats.agility * 0.5);
    stats.movement_speed = 100 + (base_stats.agility * 1);
    
    // Применяем бонусы от экипировки
    aty_apply_equipment_stats();
    
    // Применяем бонусы от пассивных способностей
    aty_apply_passive_stats();
    
    // Применяем бонусы от сетов
    aty_apply_set_bonuses();
}
// =============================================================================
// ENHANCED LEVEL UP FUNCTION
// =============================================================================

function aty_level_up() {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) return;
    
    var hero = global.aty.hero;
    
    hero.level += 1;
    hero.exp = 0;
    
    // Даем очки характеристик за уровень
    hero.stat_points += 3;
    
    // Каждые 5 уровней даем очко таланта
    if (hero.level % 5 == 0) {
        hero.talent_points += 1;
    }
    
    // Пересчитываем характеристики
    aty_recalculate_hero_stats();
    
    aty_show_notification("🎉 Уровень повышен до " + string(hero.level) + "! Получено очков характеристик: 3");
    
    // Проверяем новые пассивки при повышении уровня
    aty_check_level_up_passives();
}
// =============================================================================
// UPDATED STAT INCREASE FUNCTION WITH BETTER FEEDBACK
// =============================================================================

function aty_increase_stat(_stat_name) {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) return false;
    
    var hero = global.aty.hero;
    
    if (hero.stat_points <= 0) {
        aty_show_notification("❌ Недостаточно очков характеристик!");
        return false;
    }
    
    // Проверяем существование характеристики
    if (!variable_struct_exists(hero.base_stats, _stat_name)) {
        aty_show_notification("❌ Неизвестная характеристика!");
        return false;
    }
    
    // Проверяем лимит характеристики (макс 100)
    if (variable_struct_get(hero.base_stats, _stat_name) >= 100) {
        aty_show_notification("🎯 Достигнут максимум для этой характеристики!");
        return false;
    }
    
    // Увеличиваем характеристику
    var current_value = variable_struct_get(hero.base_stats, _stat_name);
    variable_struct_set(hero.base_stats, _stat_name, current_value + 1);
    hero.stat_points -= 1;
    
    // Пересчитываем все характеристики
    aty_recalculate_hero_stats();
    
    var stat_name_ru = aty_get_stat_name(_stat_name);
    var new_value = variable_struct_get(hero.base_stats, _stat_name);
    
    // Показываем подробное уведомление
    var effect_text = "";
    switch (_stat_name) {
        case "strength":
            effect_text = " (+" + string(2) + " к атаке, +" + string(10) + " к здоровью)";
            break;
        case "agility":
            effect_text = " (+" + string(1) + "% к криту, +" + string(0.5) + "% к скорости атаки)";
            break;
        case "intelligence":
            effect_text = " (+" + string(2) + " к магии, +" + string(10) + " к мане)";
            break;
        case "vitality":
            effect_text = " (+" + string(20) + " к здоровью, +" + string(1) + " к защите)";
            break;
        case "dexterity":
            effect_text = " (+" + string(0.5) + "% к точности, +" + string(1) + "% к скорости кастов)";
            break;
        case "luck":
            effect_text = " (+" + string(0.3) + "% к криту, +" + string(1) + "% к редкому дропу)";
            break;
    }
    
    aty_show_notification("📈 " + stat_name_ru + " увеличена до " + string(new_value) + effect_text);
    
    return true;
}

function aty_get_stat_name(_stat_key) {
    switch (_stat_key) {
        case "strength": return "Сила";
        case "agility": return "Ловкость";
        case "intelligence": return "Интеллект";
        case "vitality": return "Телосложение";
        case "dexterity": return "Меткость";
        case "luck": return "Удача";
        default: return "Неизвестно";
    }
}
function aty_get_filtered_inventory() {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) return [];
    
    var inventory = global.aty.inventory;
    var settings = global.aty.inventory_settings;
    var filtered = [];
    
    for (var i = 0; i < array_length(inventory); i++) {
        var item = inventory[i];
        var include = true;
        
        // Фильтр по типу - ИСПРАВЛЕННАЯ СТРОКА
        if (settings.filter_type != "all") {
            var item_type = aty_get_item_type_for_filter(item);
            if (item_type != settings.filter_type) {
                include = false;
            }
        }
        
        // Фильтр по редкости - ИСПРАВЛЕННАЯ СТРОКА
        if (include && settings.filter_rarity != "all") {
            var rarity_name = aty_get_rarity_for_filter(item.rarity);
            if (rarity_name != settings.filter_rarity) {
                include = false;
            }
        }
        
        // Поиск по тексту - ИСПРАВЛЕННАЯ СТРОКА
        if (include && settings.search_text != "") {
            var search_lower = string_lower(settings.search_text);
            var name_lower = string_lower(item.name);
            var desc_lower = string_lower(item.description);
            
            if (string_pos(search_lower, name_lower) == 0 && 
                string_pos(search_lower, desc_lower) == 0) {
                include = false;
            }
        }
        
        // Показывать экипированные
        if (include && !settings.show_equipped && aty_is_item_equipped(item)) {
            include = false;
        }
        
        if (include) {
            array_push(filtered, item);
        }
    }
    
    // Сортировка
    filtered = aty_sort_inventory(filtered, settings.sort_by, settings.sort_ascending);
    
    return filtered;
}
function aty_get_item_type_for_filter(_item) {
    if (!is_struct(_item)) return "other";
    
    // Для камней
    if (variable_struct_exists(_item, "is_gem") && _item.is_gem) {
        return "gem";
    }
    
    // Для обычных предметов
    if (variable_struct_exists(_item, "item_type")) {
        switch (_item.item_type) {
            case ITEM_TYPE.WEAPON: return "weapon";
            case ITEM_TYPE.ARMOR: return "armor";
            case ITEM_TYPE.ACCESSORY: return "accessory";
            case ITEM_TYPE.TRINKET: return "trinket";
            case ITEM_TYPE.CHARM: return "charm";
            default: return "other";
        }
    }
    
    // Для старых предметов с полем slot
    if (variable_struct_exists(_item, "slot")) {
        switch (_item.slot) {
            case "WEAPON": return "weapon";
            case "ARMOR": return "armor";
            case "ACCESSORY": return "accessory";
            case "TRINKET": return "trinket";
            case "CHARM": return "charm";
            default: return "other";
        }
    }
    
    return "other";
}
function aty_get_rarity_for_filter(_rarity) {
    switch (_rarity) {
        case RARITY.COMMON: return "common";
        case RARITY.UNCOMMON: return "uncommon";
        case RARITY.RARE: return "rare";
        case RARITY.EPIC: return "epic";
        case RARITY.LEGENDARY: return "legendary";
        case RARITY.MYTHIC: return "mythic";
        case RARITY.DIVINE: return "divine";
        default: return "common";
    }
}

function aty_sort_inventory(_items, _sort_by, _ascending) {
    if (!is_array(_items) || array_length(_items) == 0) return _items;
    
    // Создаем копию массива безопасным способом
    var sorted = aty_array_copy(_items);
    
    // Пузырьковая сортировка с сравнением
    for (var i = 0; i < array_length(sorted) - 1; i++) {
        for (var j = 0; j < array_length(sorted) - i - 1; j++) {
            var should_swap = false;
            var item1 = sorted[j];
            var item2 = sorted[j + 1];
            
            switch (_sort_by) {
                case "name":
                    should_swap = item1.name > item2.name;
                    break;
                case "rarity":
                    should_swap = item1.rarity > item2.rarity;
                    break;
                case "type":
                    var type1 = aty_get_item_type_text(item1);
                    var type2 = aty_get_item_type_text(item2);
                    should_swap = type1 > type2;
                    break;
                case "stats":
                    var score1 = aty_calculate_item_score(item1);
                    var score2 = aty_calculate_item_score(item2);
                    should_swap = score1 > score2;
                    break;
            }
            
            // Учитываем порядок сортировки
            if (_ascending) should_swap = !should_swap;
            
            if (should_swap) {
                var temp = sorted[j];
                sorted[j] = sorted[j + 1];
                sorted[j + 1] = temp;
            }
        }
    }
    
    return sorted;
}
function aty_is_item_equipped(_item) {
    if (!is_struct(_item)) return false;
    
    // ДОБАВЛЕНО: проверка наличия поля id
    if (!variable_struct_exists(_item, "id")) return false;
    
    var equipment = global.aty.hero.equipment;
    var slot_names = variable_struct_get_names(equipment);
    
    for (var i = 0; i < array_length(slot_names); i++) {
        var equipped_item = variable_struct_get(equipment, slot_names[i]);
        if (is_struct(equipped_item) && equipped_item.id == _item.id) {
            return true;
        }
    }
    
    return false;
}

function aty_get_rarity_name(_rarity) {
    switch (_rarity) {
        case RARITY.COMMON: return "Обычный";
        case RARITY.UNCOMMON: return "Необычный";
        case RARITY.RARE: return "Редкий";
        case RARITY.EPIC: return "Эпический";
        case RARITY.LEGENDARY: return "Легендарный";
        case RARITY.MYTHIC: return "Мифический";
        case RARITY.DIVINE: return "Божественный";
        default: return "Неизвестно";
    }
}
// =============================================================================
// SPECIALIZATION SYSTEM
// =============================================================================

enum SPECIALIZATION {
    WARRIOR,        // Воин - упор на силу и телосложение
    ROGUE,          // Разбойник - ловкость и криты
    MAGE,           // Маг - интеллект и магию
    RANGER,         // Лучник - меткость и скорость
    PALADIN,        // Паладин - сбалансированная защита и атака
    BERSERKER       // Берсерк - максимальный урон
}

function aty_unlock_specialization(_spec_type) {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) return false;
    
    var hero = global.aty.hero;
    
    // Проверяем требования для специализации
    if (!aty_meets_specialization_requirements(_spec_type)) {
        aty_show_notification("Не выполнены требования для этой специализации!");
        return false;
    }
    
    // Проверяем, не изучена ли уже специализация
    if (array_contains(hero.specializations, _spec_type)) {
        aty_show_notification("Специализация уже изучена!");
        return false;
    }
    
    // Тратим очко таланта
    if (hero.talent_points <= 0) {
        aty_show_notification("Недостаточно очков талантов!");
        return false;
    }
    
    hero.talent_points -= 1;
    array_push(hero.specializations, _spec_type);
    
    var spec_name = aty_get_spec_name(_spec_type);
    aty_show_notification("🎯 Изучена специализация: " + spec_name);
    
    // Применяем бонусы специализации
    aty_apply_specialization_bonuses(_spec_type);
    
    return true;
}

function aty_meets_specialization_requirements(_spec_type) {
    var hero = global.aty.hero;
    var base_stats = hero.base_stats;
    
    switch (_spec_type) {
        case SPECIALIZATION.WARRIOR:
            return base_stats[HERO_STAT.STRENGTH] >= 20 && base_stats[HERO_STAT.VITALITY] >= 15;
        case SPECIALIZATION.ROGUE:
            return base_stats[HERO_STAT.AGILITY] >= 25 && base_stats[HERO_STAT.LUCK] >= 15;
        case SPECIALIZATION.MAGE:
            return base_stats[HERO_STAT.INTELLIGENCE] >= 25 && base_stats[HERO_STAT.DEXTERITY] >= 15;
        case SPECIALIZATION.RANGER:
            return base_stats[HERO_STAT.DEXTERITY] >= 25 && base_stats[HERO_STAT.AGILITY] >= 20;
        case SPECIALIZATION.PALADIN:
            return base_stats[HERO_STAT.STRENGTH] >= 15 && base_stats[HERO_STAT.INTELLIGENCE] >= 15 && base_stats[HERO_STAT.VITALITY] >= 20;
        case SPECIALIZATION.BERSERKER:
            return base_stats[HERO_STAT.STRENGTH] >= 30 && hero.level >= 10;
    }
    
    return false;
}

function aty_apply_specialization_bonuses(_spec_type) {
    var hero = global.aty.hero;
    var stats = hero.stats;
    
    switch (_spec_type) {
        case SPECIALIZATION.WARRIOR:
            stats[HERO_STAT.HEALTH] += 100;
            stats[HERO_STAT.DEFENSE] += 10;
            stats[HERO_STAT.BLOCK_CHANCE] += 5;
            break;
        case SPECIALIZATION.ROGUE:
            stats[HERO_STAT.CRIT_CHANCE] += 10;
            stats[HERO_STAT.DODGE_CHANCE] += 5;
            stats[HERO_STAT.LIFESTEAL] += 5;
            break;
        case SPECIALIZATION.MAGE:
            stats[HERO_STAT.MANA] += 100;
            stats[HERO_STAT.MAGIC_POWER] += 20;
            stats[HERO_STAT.COOLDOWN_REDUCTION] += 10;
            break;
        case SPECIALIZATION.RANGER:
            stats[HERO_STAT.ATTACK_SPEED] += 15;
            stats[HERO_STAT.CAST_SPEED] += 15;
            stats[HERO_STAT.CRIT_DAMAGE] += 25;
            break;
        case SPECIALIZATION.PALADIN:
            stats[HERO_STAT.HEALTH] += 50;
            stats[HERO_STAT.MANA] += 50;
            stats[HERO_STAT.DEFENSE] += 5;
            stats[HERO_STAT.MAGIC_POWER] += 5;
            break;
        case SPECIALIZATION.BERSERKER:
            stats[HERO_STAT.ATTACK_POWER] += 25;
            stats[HERO_STAT.CRIT_DAMAGE] += 50;
            stats[HERO_STAT.LIFESTEAL] += 10;
            break;
    }
}
// =============================================================================
// DEBUG-ENHANCED UNIFIED INVENTORY DRAWING FUNCTION
// =============================================================================

function _aty_draw_inventory_tab_unified(_zone, _high_res = false) {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) return;
    
    // СБРОС ПОДСКАЗКИ ПЕРЕД ОТРИСОВКОЙ
    global.aty_tooltip_item = undefined;
    
    var colors = global.aty_colors;
    var settings = global.aty.inventory_settings;
    var scale = _high_res ? global.aty_render_scale : 1;
    
    // Вспомогательные функции для унифицированного рисования
    var fn_panel = _high_res ? draw_neon_panel_high_res : draw_neon_panel;
    var fn_button = _high_res ? draw_neon_button_high_res : draw_neon_button;
    var fn_rect = _high_res ? draw_neon_rectangle_high_res : draw_neon_rectangle;
    var fn_text = _high_res ? 
        function(_x, _y, _text, _w, _h) { draw_text_ext(_x, _y, _text, _w, _h); } : 
        function(_x, _y, _text, _w, _h) { draw_text(_x, _y, _text); };
    
    draw_set_color(colors.neon_blue);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    
    // ==================== РАЗДЕЛЕНИЕ НА КОЛОНКИ ====================
    var left_width = 200 * scale;
    var center_width = 400 * scale;
    var right_width = 180 * scale;
    
    var left_zone = {
        x1: _zone.x1 + 10 * scale,
        y1: _zone.y1 + 10 * scale,
        x2: _zone.x1 + left_width,
        y2: _zone.y2 - 10 * scale
    };
    
    var center_zone = {
        x1: _zone.x1 + left_width + 10 * scale,
        y1: _zone.y1 + 10 * scale,
        x2: _zone.x1 + left_width + center_width,
        y2: _zone.y2 - 10 * scale
    };
    
    var right_zone = {
        x1: _zone.x1 + left_width + center_width + 10 * scale,
        y1: _zone.y1 + 10 * scale,
        x2: _zone.x2 - 10 * scale,
        y2: _zone.y2 - 10 * scale
    };
    
   // show_debug_message("Zones: left=" + string(left_zone.x1) + "-" + string(left_zone.x2) + 
              //        ", center=" + string(center_zone.x1) + "-" + string(center_zone.x2) + 
              //        ", right=" + string(right_zone.x1) + "-" + string(right_zone.x2));
    
    // ==================== ЛЕВАЯ КОЛОНКА - СЛОТЫ ЭКИПИРОВКИ ====================
    fn_panel(left_zone.x1, left_zone.y1, left_zone.x2, left_zone.y2, "Экипировка");
    
    var equipment = global.aty.hero.equipment;
    var slot_names = ["Оружие", "Броня", "Аксессуар", "Тринит", "Амулет"];
    var slot_keys = ["WEAPON", "ARMOR", "ACCESSORY", "TRINKET", "CHARM"];
    var slot_size = 50 * scale;
    var slot_spacing = 15 * scale;
    
    // Первая колонна (3 слота)
    var col1_x = left_zone.x1 + 20 * scale;
    var col1_y = left_zone.y1 + 40 * scale;
    
    for (var i = 0; i < 3; i++) {
        _aty_draw_equipment_slot_unified(col1_x, col1_y, slot_size, slot_keys[i], slot_names[i], equipment, _high_res);
        col1_y += slot_size + slot_spacing;
    }
    
    // Вторая колонна (2 слота)
    var col2_x = left_zone.x1 + 100 * scale;
    var col2_y = left_zone.y1 + 40 * scale;
    
    for (var i = 3; i < 5; i++) {
        _aty_draw_equipment_slot_unified(col2_x, col2_y, slot_size, slot_keys[i], slot_names[i], equipment, _high_res);
        col2_y += slot_size + slot_spacing;
    }
    
    // ==================== ЦЕНТРАЛЬНАЯ ЧАСТЬ - ПРЕДМЕТЫ ====================
    fn_panel(center_zone.x1, center_zone.y1, center_zone.x2, center_zone.y2, "Инвентарь");
    
    var filtered_items = aty_get_filtered_inventory();
   // show_debug_message("Filtered items count: " + string(array_length(filtered_items)) + 
                   //   " (total: " + string(array_length(global.aty.inventory)) + ")");
    
    var items_per_row = 6;
    var item_size = 45 * scale;
    var item_spacing = 8 * scale;
    
    var inv_x = center_zone.x1 + 15 * scale;
    var inv_y = center_zone.y1 + 40 * scale;
    
    // Рассчитываем доступную высоту для инвентаря
    var max_rows = floor((center_zone.y2 - inv_y - 20 * scale) / (item_size + item_spacing));
  //  show_debug_message("Max rows: " + string(max_rows) + ", items per row: " + string(items_per_row));
    
    // Сетка предметов
    var drawn_count = 0;
    for (var i = 0; i < array_length(filtered_items); i++) {
        if (i >= items_per_row * max_rows) {
          //  show_debug_message("Stopping at item " + string(i) + " (max: " + string(items_per_row * max_rows) + ")");
            break;
        }
        
        var item = filtered_items[i];
        var row = i div items_per_row;
        var col = i mod items_per_row;
        
        var item_x = inv_x + col * (item_size + item_spacing);
        var item_y = inv_y + row * (item_size + item_spacing);
        
        _aty_draw_inventory_item_small_unified(item, item_x, item_y, item_size, _high_res);
        drawn_count++;
        
        // Проверяем наведение мыши для подсказки
        var mouse_xx = _high_res ? global.aty_mouse_x / scale : global.aty_mouse_x;
        var mouse_yy = _high_res ? global.aty_mouse_y / scale : global.aty_mouse_y;
        
        if (point_in_rectangle(mouse_xx, mouse_yy, item_x, item_y, item_x + item_size, item_y + item_size)) {
            global.aty_tooltip_item = item;
            global.aty_tooltip_x = item_x;
            global.aty_tooltip_y = item_y;
            global.aty_tooltip_high_res = _high_res;
        }
    }
    
    //show_debug_message("Drawn items: " + string(drawn_count));
    
    // Информация о количестве предметов
    draw_set_color(colors.neon_cyan);
    fn_text(center_zone.x1 + 15 * scale, center_zone.y2 - 25 * scale, 
            "Предметов: " + string(array_length(filtered_items)) + "/" + string(array_length(global.aty.inventory)), -1, -1);
    
    // ==================== ПРАВАЯ КОЛОНКА - ФИЛЬТРЫ И СОРТИРОВКА ====================
    fn_panel(right_zone.x1, right_zone.y1, right_zone.x2, right_zone.y2, "Управление");
    
    var control_y = right_zone.y1 + 40 * scale;
    var button_width = 150 * scale;
    var button_height = 25 * scale;
    var button_spacing = 10 * scale;
    
    // Заголовок сортировки
    draw_set_color(colors.neon_cyan);
    fn_text(right_zone.x1 + 15 * scale, control_y, "Сортировка:", -1, -1);
    control_y += 25 * scale;
    
    // Кнопки сортировки
    var sort_options = [
        { key: "name", label: "По имени" },
        { key: "rarity", label: "По редкости" },
        { key: "type", label: "По типу" },
        { key: "stats", label: "По силе" }
    ];
    
    for (var i = 0; i < array_length(sort_options); i++) {
        var is_active = settings.sort_by == sort_options[i].key;
        fn_button(right_zone.x1 + 15 * scale, control_y, 
                 right_zone.x1 + 15 * scale + button_width, control_y + button_height,
                 sort_options[i].label, is_active, false);
        control_y += button_height + button_spacing;
    }
    
    // Направление сортировки
    fn_button(right_zone.x1 + 15 * scale, control_y, 
             right_zone.x1 + 15 * scale + 40 * scale, control_y + button_height,
             settings.sort_ascending ? "↑" : "↓", false, false);
    control_y += button_height + 20 * scale;
    
    // Заголовок фильтров
    draw_set_color(colors.neon_cyan);
    fn_text(right_zone.x1 + 15 * scale, control_y, "Фильтры по типу:", -1, -1);
    control_y += 25 * scale;
    
    // Фильтры по типу
    var type_filters = [
        { key: "all", label: "Все предметы" },
        { key: "weapon", label: "Оружие" },
        { key: "armor", label: "Броня" },
        { key: "accessory", label: "Аксессуары" },
        { key: "trinket", label: "Тринкеты" },
        { key: "charm", label: "Амулеты" },
        { key: "gem", label: "Камни" }
    ];
    
    for (var i = 0; i < array_length(type_filters); i++) {
        var is_active = settings.filter_type == type_filters[i].key;
        fn_button(right_zone.x1 + 15 * scale, control_y, 
                 right_zone.x1 + 15 * scale + button_width, control_y + button_height,
                 type_filters[i].label, is_active, false);
        control_y += button_height + button_spacing;
    }
    
    control_y += 10 * scale;
    
    // Фильтры по редкости
    draw_set_color(colors.neon_cyan);
    fn_text(right_zone.x1 + 15 * scale, control_y, "Фильтры по редкости:", -1, -1);
    control_y += 25 * scale;
    
    var rarity_filters = [
        { key: "all", label: "Все редкости" },
        { key: "common", label: "Обычные" },
        { key: "uncommon", label: "Необычные" },
        { key: "rare", label: "Редкие" },
        { key: "epic", label: "Эпические" },
        { key: "legendary", label: "Легендарные" }
    ];
    
    for (var i = 0; i < array_length(rarity_filters); i++) {
        var is_active = settings.filter_rarity == rarity_filters[i].key;
        fn_button(right_zone.x1 + 15 * scale, control_y, 
                 right_zone.x1 + 15 * scale + button_width, control_y + button_height,
                 rarity_filters[i].label, is_active, false);
        control_y += button_height + button_spacing;
    }
    
    control_y += 10 * scale;
    
    // Дополнительные опции
    fn_button(right_zone.x1 + 15 * scale, control_y, 
             right_zone.x1 + 15 * scale + button_width, control_y + button_height,
             "Только не экипир.", settings.show_equipped, false);
    control_y += button_height + button_spacing;
    
    fn_button(right_zone.x1 + 15 * scale, control_y, 
             right_zone.x1 + 15 * scale + button_width, control_y + button_height,
             "Продать хлам", false, false);
    
    // ==================== ОТОБРАЖЕНИЕ ПОДСКАЗКИ ====================
    if (variable_struct_exists(global, "aty_tooltip_item") && is_struct(global.aty_tooltip_item)) {
        _aty_draw_item_tooltip_unified(global.aty_tooltip_item, global.aty_tooltip_x, global.aty_tooltip_y, _high_res);
    }
    
   // show_debug_message("Inventory tab drawing completed");
}
// =============================================================================
// IMPROVED TEST ITEMS GENERATION
// =============================================================================
// Обновляем функцию добавления тестовых предметов
function aty_add_test_items() {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) return;
    
    // Создаем тестовые предметы через новую систему
    var test_items = [
        aty_generate_loot_item_safe(RARITY.COMMON),
        aty_generate_loot_item_safe(RARITY.UNCOMMON),
        aty_generate_loot_item_safe(RARITY.RARE)
    ];
    
    // Устанавливаем специальные имена для тестовых предметов
    test_items[0].name = "Тестовый Меч";
    test_items[0].description = "Простой меч для тестирования";
    test_items[0].item_type = ITEM_TYPE.WEAPON;
    
    test_items[1].name = "Тестовая Броня";
    test_items[1].description = "Прочная броня для тестирования";
    test_items[1].item_type = ITEM_TYPE.ARMOR;
    
    test_items[2].name = "Тестовое Кольцо";
    test_items[2].description = "Магическое кольцо для тестирования";
    test_items[2].item_type = ITEM_TYPE.ACCESSORY;
    
    // Добавляем предметы через новую систему
    for (var i = 0; i < array_length(test_items); i++) {
        aty_add_item_to_inventory(test_items[i]);
    }
    
    aty_show_notification("Добавлены тестовые предметы!");
}
// =============================================================================
// MOUSE POSITION UPDATE FUNCTION
// =============================================================================

function aty_update_mouse_position() {
    global.aty_mouse_x = device_mouse_x_to_gui(0);
    global.aty_mouse_y = device_mouse_y_to_gui(0);
}
// =============================================================================
// UPDATE STEP FUNCTION WITH MOUSE TRACKING
// =============================================================================


// Также обновляем функцию aty_step() для безопасной проверки:
function aty_step(_dt) {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) return;
    
    // Обновляем позицию мыши для подсказок
    aty_update_mouse_position();
    
    // Handle ESC key to return to main room
    if (keyboard_check_pressed(vk_escape)) {
        var rm_main = asset_get_index("rm_main");
        if (room_exists(room_main)) {
            room_goto(room_main);
        }
    }
    
    // Expedition logic
    if (global.aty.expedition.active) {
        global.aty.expedition.timer -= _dt;
        global.aty.expedition.progress = 1 - (global.aty.expedition.timer / 180);
        
        // Palette change at 50% progress
        if (global.aty.expedition.progress >= 0.5 && global.aty.expedition.progress < 0.51) {
            global.aty.vfx.palette = choose("good", "bad");
        }
        
        if (global.aty.expedition.timer <= 0) {
            aty_complete_expedition();
        }
    }
    
    // Raid boss logic - БЕЗОПАСНАЯ ПРОВЕРКА
    if (variable_struct_exists(global.aty, "raid_boss") && global.aty.raid_boss.active) {
        aty_raid_boss_step(_dt);
    }
    
    // Raid logic
    if (global.aty.raids.active) {
        global.aty.raids.timer -= _dt;
        if (global.aty.raids.timer <= 0) {
            aty_complete_raid();
        }
    }
    
    // Companion walk logic
    for (var i = 0; i < array_length(global.aty.companions); i++) {
        var companion = global.aty.companions[i];
        
        if (variable_struct_exists(companion, "walk_state") && companion.walk_state == WALK_STATE.WALKING) {
            companion.walk_timer -= _dt;
            
            if (companion.walk_timer <= 0) {
                aty_complete_walk(i);
            }
        }
    }
    
    // Quest progress updates
    aty_update_quest_progress();
    
    // Notification timer - БЕЗОПАСНАЯ ПРОВЕРКА
    if (variable_struct_exists(global.aty, "notification") && 
        variable_struct_exists(global.aty.notification, "timer") && 
        global.aty.notification.timer > 0) {
        global.aty.notification.timer -= _dt;
    }
    
    // VFX update
    aty_vfx_step(_dt);
    
    // Отслеживаем прогресс трофеев
    aty_track_wealth_trophies();
    aty_track_level_trophies();
}

// =============================================================================
// UNIFIED ITEM TOOLTIP
// =============================================================================
function _aty_draw_item_tooltip_unified(_item, _x, _y, _high_res = false) {
    var colors = global.aty_colors;
    var scale = _high_res ? global.aty_render_scale : 1;
    
    var tooltip_width = 300 * scale;
    var tooltip_height = 200 * scale;
    var padding = 15 * scale;
    
    // Позиционируем подсказку так, чтобы не выходить за границы экрана
    var tooltip_x = _x + 50 * scale;
    var tooltip_y = _y;
    
    // Если подсказка выходит за правый край, сдвигаем влево
    if (tooltip_x + tooltip_width > (display_get_width() / (_high_res ? global.aty_render_scale : 1))) {
        tooltip_x = _x - tooltip_width - 10 * scale;
    }
    
    // Если подсказка выходит за нижний край, сдвигаем вверх
    if (tooltip_y + tooltip_height > (display_get_height() / (_high_res ? global.aty_render_scale : 1))) {
        tooltip_y = (display_get_height() / (_high_res ? global.aty_render_scale : 1)) - tooltip_height - 10 * scale;
    }
    
    // Фон подсказки
    draw_set_color(colors.bg_dark);
    draw_set_alpha(0.95);
    draw_rectangle(tooltip_x, tooltip_y, tooltip_x + tooltip_width, tooltip_y + tooltip_height, false);
    draw_set_alpha(1);
    
    // Рамка подсказки
    var border_color = aty_rarity_color(_item.rarity);
    draw_set_color(border_color);
    draw_rectangle(tooltip_x, tooltip_y, tooltip_x + tooltip_width, tooltip_y + tooltip_height, true);
    
    var content_x = tooltip_x + padding;
    var content_y = tooltip_y + padding;
    
    // Название предмета
    draw_set_color(border_color);
    draw_text_ext(content_x, content_y, _item.name, -1, -1);
    content_y += 25 * scale;
    
    // Тип и редкость
    draw_set_color(colors.neon_cyan);
    var type_text = aty_get_item_type_text(_item);
    var rarity_text = aty_get_rarity_name(_item.rarity);
    draw_text_ext(content_x, content_y, type_text + " • " + rarity_text, -1, -1);
    content_y += 20 * scale;
    
    // Основные характеристики
    draw_set_color(colors.neon_green);
    var stats = _item.stats;
    
    if (variable_struct_exists(stats, "attack_power") && stats.attack_power > 0) {
        draw_text_ext(content_x, content_y, "⚔ Атака: +" + string(stats.attack_power), -1, -1);
        content_y += 18 * scale;
    }
    
    if (variable_struct_exists(stats, "magic_power") && stats.magic_power > 0) {
        draw_text_ext(content_x, content_y, "🔮 Магия: +" + string(stats.magic_power), -1, -1);
        content_y += 18 * scale;
    }
    
    if (variable_struct_exists(stats, "defense") && stats.defense > 0) {
        draw_text_ext(content_x, content_y, "🛡 Защита: +" + string(stats.defense), -1, -1);
        content_y += 18 * scale;
    }
    
    if (variable_struct_exists(stats, "health") && stats.health > 0) {
        draw_text_ext(content_x, content_y, "❤ Здоровье: +" + string(stats.health), -1, -1);
        content_y += 18 * scale;
    }
    
    if (variable_struct_exists(stats, "mana") && stats.mana > 0) {
        draw_text_ext(content_x, content_y, "💧 Мана: +" + string(stats.mana), -1, -1);
        content_y += 18 * scale;
    }
    
    // Вторичные характеристики
    var secondary_stats = false;
    
    if (variable_struct_exists(stats, "crit_chance") && stats.crit_chance > 0) {
        draw_text_ext(content_x, content_y, "🎯 Крит: +" + string(stats.crit_chance) + "%", -1, -1);
        content_y += 16 * scale;
        secondary_stats = true;
    }
    
    if (variable_struct_exists(stats, "crit_damage") && stats.crit_damage > 0) {
        draw_text_ext(content_x, content_y, "💥 Урон крита: +" + string(stats.crit_damage) + "%", -1, -1);
        content_y += 16 * scale;
        secondary_stats = true;
    }
    
    if (variable_struct_exists(stats, "attack_speed") && stats.attack_speed > 0) {
        draw_text_ext(content_x, content_y, "⚡ Скор. атаки: +" + string(stats.attack_speed) + "%", -1, -1);
        content_y += 16 * scale;
        secondary_stats = true;
    }
    
    if (variable_struct_exists(stats, "lifesteal") && stats.lifesteal > 0) {
        draw_text_ext(content_x, content_y, "🩸 Вампиризм: +" + string(stats.lifesteal) + "%", -1, -1);
        content_y += 16 * scale;
        secondary_stats = true;
    }
    
    if (secondary_stats) {
        content_y += 5 * scale;
    }
    
    // Специальные эффекты
    if (variable_struct_exists(_item, "special_effects") && array_length(_item.special_effects) > 0) {
        draw_set_color(colors.neon_purple);
        draw_text_ext(content_x, content_y, "Особые свойства:", -1, -1);
        content_y += 20 * scale;
        
        for (var i = 0; i < array_length(_item.special_effects); i++) {
            draw_set_color(colors.neon_cyan);
            draw_text_ext(content_x + 10 * scale, content_y, "• " + _item.special_effects[i].name, -1, -1);
            content_y += 16 * scale;
        }
    }
    
    // Информация об экипировке - обновленная
    if (aty_is_item_equipped(_item)) {
        var equipped_slot = aty_get_equipped_slot_for_item(_item);
        if (equipped_slot != undefined) {
            var slot_style = global.aty_equipment_styles[equipped_slot];
            draw_set_color(slot_style.color);
            draw_text_ext(content_x, content_y + 10 * scale, 
                         "✓ Экипировано в слот: " + slot_style.name, -1, -1);
        } else {
            draw_set_color(colors.neon_green);
            draw_text_ext(content_x, content_y + 10 * scale, "✓ Экипировано", -1, -1);
        }
    }
    
    // Подсказка управления
    draw_set_color(colors.text_muted);
    draw_text_ext(content_x, tooltip_y + tooltip_height - 25 * scale, "ЛКМ - надеть | ПКМ - продать", -1, -1);
}
// =============================================================================
// UNIFIED SMALL INVENTORY ITEM DRAWING
// =============================================================================
function _aty_draw_inventory_item_small_unified(_item, _x, _y, _size, _high_res = false) {
    var colors = global.aty_colors;
    
    var fn_rect = _high_res ? draw_neon_rectangle_high_res : draw_neon_rectangle;
    var fn_text = _high_res ? 
        function(_x, _y, _text, _w, _h) { draw_text_ext(_x, _y, _text, _w, _h); } : 
        function(_x, _y, _text, _w, _h) { draw_text(_x, _y, _text); };

    var item_color = aty_rarity_color(_item.rarity);
    var is_equipped = aty_is_item_equipped(_item);
    
    // Если предмет экипирован, используем стиль соответствующего слота
    if (is_equipped) {
        var equipped_slot = aty_get_equipped_slot_for_item(_item);
        if (equipped_slot != undefined) {
            var slot_style = global.aty_equipment_styles[equipped_slot];
            item_color = slot_style.color;
        }
    }
    
    // Рисуем предмет с уникальной формой если он экипирован
    if (is_equipped) {
        var equipped_slot = aty_get_equipped_slot_for_item(_item);
        if (equipped_slot != undefined) {
            var slot_style = global.aty_equipment_styles[equipped_slot];
            _aty_draw_equipment_slot_shape(_x, _y, _size, slot_style.shape, item_color, _high_res);
        } else {
            fn_rect(_x, _y, _x + _size, _y + _size, item_color, true);
        }
    } else {
        // Обычный прямоугольник для неэкипированных предметов
        fn_rect(_x, _y, _x + _size, _y + _size, item_color, true);
    }
    
    // Иконка экипировки (используем иконку слота)
    if (is_equipped) {
        var equipped_slot = aty_get_equipped_slot_for_item(_item);
        if (equipped_slot != undefined) {
            var slot_style = global.aty_equipment_styles[equipped_slot];
            draw_set_color(colors.text_primary);
            fn_text(_x + 3, _y + 3, slot_style.icon, -1, -1);
        } else {
            draw_set_color(colors.neon_green);
            fn_text(_x + 3, _y + 3, "✓", -1, -1);
        }
    }
    
    // Сокращенное название
    draw_set_color(colors.text_primary);
    var short_name = string_copy(_item.name, 1, 4) + (string_length(_item.name) > 4 ? ".." : "");
    fn_text(_x + 5, _y + 15, short_name, -1, -1);
    
    // Маленькие статы
    draw_set_color(colors.neon_green);
    var mini_stats = aty_get_mini_stats_text(_item);
    if (mini_stats != "") {
        fn_text(_x + 5, _y + 28, mini_stats, -1, -1);
    }
}
function aty_get_equipped_slot_for_item(_item) {
    if (!is_struct(_item)) return undefined;
    if (!variable_struct_exists(_item, "id")) return undefined;
    
    var equipment = global.aty.hero.equipment;
    var slot_names = variable_struct_get_names(equipment);
    
    for (var i = 0; i < array_length(slot_names); i++) {
        var equipped_item = variable_struct_get(equipment, slot_names[i]);
        if (is_struct(equipped_item) && equipped_item.id == _item.id) {
            return slot_names[i];
        }
    }
    
    return undefined;
}
// FIXED EQUIPMENT SLOT DRAWING FUNCTION
// =============================================================================
function _aty_draw_equipment_slot_unified(_x, _y, _size, _slot_key, _slot_name, _equipment, _high_res = false) {
    try {
        var colors = global.aty_colors;
        
        var fn_rect = _high_res ? draw_neon_rectangle_high_res : draw_neon_rectangle;
        var fn_text = _high_res ? 
            function(__x, __y, __text, __w, __h) { draw_text_ext(__x, __y, __text, __w, __h); } : 
            function(__x, __y, __text, __w, __h) { draw_text(__x, __y, __text); };

        // БЕЗОПАСНОЕ ПОЛУЧЕНИЕ ПРЕДМЕТА ИЗ СЛОТА
        var slot_item = noone;
        if (is_struct(_equipment)) {
            var equipment_names = variable_struct_get_names(_equipment);
            var slot_found = false;
            for (var i = 0; i < array_length(equipment_names); i++) {
                if (equipment_names[i] == _slot_key) {
                    slot_item = variable_struct_get(_equipment, _slot_key);
                    slot_found = true;
                    break;
                }
            }
            if (!slot_found) {
                // Если слот не найден, используем noone
                slot_item = noone;
            }
        }
        
        // БЕЗОПАСНОЕ ПОЛУЧЕНИЕ СТИЛЯ СЛОТА - ПОЛНОСТЬЮ ПЕРЕПИСАНО
        var slot_style = {
            color: colors.neon_blue,
            border_color: colors.neon_blue,
            icon: "?",
            name: _slot_name,
            shape: "rectangle"
        };
        
        // Ручная проверка каждого возможного слота
        if (variable_struct_exists(global, "aty_equipment_styles") && is_struct(global.aty_equipment_styles)) {
            if (_slot_key == "WEAPON" && variable_struct_exists(global.aty_equipment_styles, "WEAPON")) {
                slot_style = global.aty_equipment_styles.WEAPON;
            }
            else if (_slot_key == "ARMOR" && variable_struct_exists(global.aty_equipment_styles, "ARMOR")) {
                slot_style = global.aty_equipment_styles.ARMOR;
            }
            else if (_slot_key == "ACCESSORY" && variable_struct_exists(global.aty_equipment_styles, "ACCESSORY")) {
                slot_style = global.aty_equipment_styles.ACCESSORY;
            }
            else if (_slot_key == "TRINKET" && variable_struct_exists(global.aty_equipment_styles, "TRINKET")) {
                slot_style = global.aty_equipment_styles.TRINKET;
            }
            else if (_slot_key == "CHARM" && variable_struct_exists(global.aty_equipment_styles, "CHARM")) {
                slot_style = global.aty_equipment_styles.CHARM;
            }
        }
        
        // БЕЗОПАСНОЕ ОПРЕДЕЛЕНИЕ ЦВЕТА СЛОТА
        var slot_color = slot_style.color;
        if (is_struct(slot_item)) {
            if (variable_struct_exists(slot_item, "rarity")) {
                var rarity_value = slot_item.rarity;
                
                // ЕСЛИ RARITY - СТРОКА, ПРЕОБРАЗУЕМ В ЧИСЛО
                if (is_string(rarity_value)) {
                    switch (rarity_value) {
                        case "COMMON": rarity_value = 0; break;
                        case "UNCOMMON": rarity_value = 1; break;
                        case "RARE": rarity_value = 2; break;
                        case "EPIC": rarity_value = 3; break;
                        case "LEGENDARY": rarity_value = 4; break;
                        case "MYTHIC": rarity_value = 5; break;
                        case "DIVINE": rarity_value = 6; break;
                        default: rarity_value = 0; break;
                    }
                }
                
                // ПРОВЕРЯЕМ ЧТО RARITY_VALUE - ЧИСЛО
                if (is_real(rarity_value)) {
                    slot_color = aty_rarity_color(rarity_value);
                }
            }
        }
        
        // РИСУЕМ ОСНОВУ СЛОТА
        draw_set_color(slot_color);
        if (slot_style.shape == "vertical_sword") {
            // Вертикальный прямоугольник для оружия
            draw_rectangle(_x + _size/4, _y, _x + _size*3/4, _y + _size, false);
        }
        else if (slot_style.shape == "chest") {
            // Горизонтальный прямоугольник для брони
            draw_rectangle(_x, _y + _size/4, _x + _size, _y + _size*3/4, false);
        }
        else if (slot_style.shape == "circle") {
            // Круг для аксессуаров
            draw_circle(_x + _size/2, _y + _size/2, _size/2, false);
        }
        else if (slot_style.shape == "diamond") {
            // Ромб для тринкетов
            draw_primitive_begin(pr_trianglefan);
            draw_vertex(_x + _size/2, _y);
            draw_vertex(_x + _size, _y + _size/2);
            draw_vertex(_x + _size/2, _y + _size);
            draw_vertex(_x, _y + _size/2);
            draw_primitive_end();
        }
        else if (slot_style.shape == "hexagon") {
            // Шестиугольник для амулетов
            draw_primitive_begin(pr_trianglefan);
            draw_vertex(_x + _size/2, _y + _size/2);
            for (var i = 0; i < 6; i++) {
                var angle = i * 60;
                var vx = _x + _size/2 + _size/2 * cos(angle);
                var vy = _y + _size/2 + _size/2 * sin(angle);
                draw_vertex(vx, vy);
            }
            draw_primitive_end();
        }
        else {
            // Прямоугольник по умолчанию
            draw_rectangle(_x, _y, _x + _size, _y + _size, false);
        }
        
        // РАМКА СЛОТА
        draw_set_color(slot_style.border_color);
        if (slot_style.shape == "vertical_sword") {
            draw_rectangle(_x + _size/4, _y, _x + _size*3/4, _y + _size, true);
        }
        else if (slot_style.shape == "chest") {
            draw_rectangle(_x, _y + _size/4, _x + _size, _y + _size*3/4, true);
        }
        else if (slot_style.shape == "circle") {
            draw_circle(_x + _size/2, _y + _size/2, _size/2, true);
        }
        else if (slot_style.shape == "diamond") {
            draw_primitive_begin(pr_linestrip);
            draw_vertex(_x + _size/2, _y);
            draw_vertex(_x + _size, _y + _size/2);
            draw_vertex(_x + _size/2, _y + _size);
            draw_vertex(_x, _y + _size/2);
            draw_vertex(_x + _size/2, _y);
            draw_primitive_end();
        }
        else if (slot_style.shape == "hexagon") {
            draw_primitive_begin(pr_linestrip);
            for (var i = 0; i <= 6; i++) {
                var angle = i * 60;
                var vx = _x + _size/2 + _size/2 * cos(angle);
                var vy = _y + _size/2 + _size/2 * sin(angle);
                draw_vertex(vx, vy);
            }
            draw_primitive_end();
        }
        else {
            draw_rectangle(_x, _y, _x + _size, _y + _size, true);
        }
        
        // ИКОНКА ТИПА СЛОТА
        draw_set_color(colors.text_primary);
        fn_text(_x + _size/2 - 8, _y + 5, slot_style.icon, -1, -1);
        
        if (is_struct(slot_item)) {
            // ЭКИПИРОВАННЫЙ ПРЕДМЕТ
            draw_set_color(slot_style.border_color);
            
            // БЕЗОПАСНОЕ ПОЛУЧЕНИЕ ИМЕНИ ПРЕДМЕТА
            var item_name = "Предмет";
            if (variable_struct_exists(slot_item, "name")) {
                item_name = slot_item.name;
            }
            var short_name = string_copy(item_name, 1, 6);
            if (string_length(item_name) > 6) {
                short_name += "..";
            }
            fn_text(_x + 5, _y + 25, short_name, -1, -1);
            
            // СТАТЫ ПРЕДМЕТА
            draw_set_color(slot_style.color);
            var stats_text = aty_get_short_stats_text(slot_item);
            if (stats_text != "") {
                fn_text(_x + 5, _y + 40, stats_text, -1, -1);
            }
        } else {
            // ПУСТОЙ СЛОТ
            draw_set_color(colors.text_muted);
            fn_text(_x + 5, _y + 25, slot_style.name, -1, -1);
        }
        
    } catch (e) {
        // РЕЗЕРВНАЯ ОТРИСОВКА ПРИ ОШИБКЕ
        show_debug_message("Error in equipment slot drawing: " + string(e));
        
        // Простой прямоугольник как запасной вариант
        draw_set_color(c_white);
        draw_rectangle(_x, _y, _x + _size, _y + _size, false);
        draw_rectangle(_x, _y, _x + _size, _y + _size, true);
        
        draw_set_color(c_black);
        var simple_fn_text = _high_res ? 
            function(__x, __y, __text) { draw_text_ext(__x, __y, __text, -1, -1); } : 
            function(__x, __y, __text) { draw_text(__x, __y, __text); };
        simple_fn_text(_x + 5, _y + 25, "ERROR");
    }
}
// =============================================================================
// FIXED EQUIPMENT SLOT SHAPE DRAWING
// =============================================================================
function _aty_draw_equipment_slot_shape(_x, _y, _size, _shape, _color, _high_res = false) {
    var fn_rect = _high_res ? draw_neon_rectangle_high_res : draw_neon_rectangle;
    
    switch (_shape) {
        case "vertical_sword":
            // Вертикальный прямоугольник для оружия
            fn_rect(_x + _size/4, _y, _x + _size*3/4, _y + _size, _color, true);
            break;
        case "chest":
            // Горизонтальный прямоугольник для брони
            fn_rect(_x, _y + _size/4, _x + _size, _y + _size*3/4, _color, true);
            break;
        case "circle":
            // Круг для аксессуаров
            draw_set_color(_color);
            draw_circle(_x + _size/2, _y + _size/2, _size/2, false);
            break;
        case "diamond":
            // Ромб для тринкетов
            draw_set_color(_color);
            draw_primitive_begin(pr_trianglefan);
            draw_vertex(_x + _size/2, _y);
            draw_vertex(_x + _size, _y + _size/2);
            draw_vertex(_x + _size/2, _y + _size);
            draw_vertex(_x, _y + _size/2);
            draw_primitive_end();
            break;
        case "hexagon":
            // Шестиугольник для амулетов
            draw_set_color(_color);
            draw_primitive_begin(pr_trianglefan);
            draw_vertex(_x + _size/2, _y + _size/2);
            for (var i = 0; i < 6; i++) {
                var angle = i * 60;
                var vx = _x + _size/2 + _size/2 * cos(angle);
                var vy = _y + _size/2 + _size/2 * sin(angle);
                draw_vertex(vx, vy);
            }
            draw_primitive_end();
            break;
        default:
            // Прямоугольник по умолчанию
            fn_rect(_x, _y, _x + _size, _y + _size, _color, true);
            break;
    }
}
// =============================================================================
// QUEST SYSTEM
function _aty_draw_daily_quests_enhanced(_zone) {
    var quests = _aty_get_safe_quest_array("daily_quests");
    var safe_colors = _aty_get_safe_colors();
    
    var quest_y_position = _zone.y1 + 15;
    
    // Заголовок с таймером
    draw_set_font(global.aty_font_bold);
    draw_set_color(safe_colors.neon_green);
    draw_text(_zone.x1 + 15, _zone.y1 + 10, "ЕЖЕДНЕВНЫЕ ЗАДАНИЯ");
    
    // Таймер обновления
    var refresh_time = _aty_get_daily_refresh_time();
    draw_set_font(global.aty_font_small);
    draw_set_color(safe_colors.neon_cyan);
    draw_text(_zone.x1 + 200, _zone.y1 + 12, "Обновление через: " + refresh_time);
    
    quest_y_position += 25;
    
    if (array_length(quests) == 0) {
        _aty_draw_empty_state(_zone, "Нет ежедневных заданий", "Ежедневные квесты обновляются каждый день в 00:00", safe_colors.text_muted);
        return;
    }
    
    for (var i = 0; i < array_length(quests); i++) {
        if (quest_y_position > _zone.y2 - 180) {
            _aty_draw_more_items_indicator(_zone, quest_y_position, array_length(quests) - i);
            break;
        }
        
        var quest = quests[i];
        quest_y_position = _aty_draw_quest_card_enhanced(_zone.x1, quest_y_position, _zone.x2, quest, false);
        quest_y_position += 15;
    }
}

function aty_generate_quest_from_template(template, player_level) {
    var quest = aty_copy_quest(template);
    
    // Масштабируем сложность под уровень игрока
    var scale_factor = max(1, player_level / 10);
    
    // Масштабируем цели
    for (var i = 0; i < array_length(quest.objectives); i++) {
        var objective = quest.objectives[i];
        objective.target = round(objective.target * scale_factor);
        
        // Добавляем вариативность
        if (random(1) < 0.3) { // 30% шанс изменить цель
            objective.target = round(objective.target * random_range(0.8, 1.2));
        }
    }
    
    // Масштабируем награды
    quest.rewards.gold = round(quest.rewards.gold * scale_factor);
    quest.rewards.exp = round(quest.rewards.exp * scale_factor);
    
    quest.state = QUEST_STATE.AVAILABLE;
    quest.current_progress = array_create(array_length(quest.objectives), 0);
    
    return quest;
}
// Добавляем функцию для перемещения квеста в проваленные
function aty_move_quest_to_failed(_quest_id) {
    var quest = aty_find_quest_by_id(_quest_id);
    
    if (!is_struct(quest)) return false;
    
    // Удаляем из активных квестов
    aty_remove_quest_from_active(_quest_id);
    
    // Добавляем в проваленные
    array_push(global.aty.quests.failed_quests, quest);
    
    return true;
}
function aty_calculate_objective_progress(objective, current_progress) {
    switch (objective.type) {
        case QUEST_OBJECTIVE_TYPE.COLLECT_ITEMS:
            return aty_count_items_in_inventory(objective.item_id);
            
        case QUEST_OBJECTIVE_TYPE.DEFEAT_ENEMIES:
            return global.aty.stats.enemies_defeated || 0;
            
        case QUEST_OBJECTIVE_TYPE.COMPLETE_EXPEDITIONS:
            return global.aty.stats.expeditions_completed || 0;
            
        case QUEST_OBJECTIVE_TYPE.EARN_GOLD:
            return global.aty.stats.gold_earned || 0;
            
        case QUEST_OBJECTIVE_TYPE.REACH_LEVEL:
            return global.aty.hero.level;
            
        case QUEST_OBJECTIVE_TYPE.COMPLETE_MINIGAMES:
            return global.aty.stats.minigames_completed || 0;
            
        default:
            return current_progress;
    }
}
function aty_update_quest_progress() {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) return;
    
    var all_quests = array_merge(global.aty.quests.active_quests, 
                                global.aty.quests.daily_quests,
                                global.aty.quests.weekly_quests);
    
    for (var i = 0; i < array_length(all_quests); i++) {
        var quest = all_quests[i];
        
        if (quest.state == QUEST_STATE.IN_PROGRESS) {
            var completed = true;
            
            for (var j = 0; j < array_length(quest.objectives); j++) {
                var objective = quest.objectives[j];
                var current_progress = quest.current_progress[j];
                
                // Обновляем прогресс в зависимости от типа цели
                switch (objective.type) {
                    case "complete_expedition":
                        // Прогресс обновляется при завершении экспедиций
                        break;
                        
                    case "collect_items":
                        quest.current_progress[j] = array_length(global.aty.inventory);
                        break;
                        
                    case "sell_items":
                        // Прогресс обновляется при продаже предметов
                        break;
                        
                    case "defeat_enemies":
                        // Прогресс обновляется в бою
                        break;
                        
                    case "complete_high_expedition":
                        // Прогресс обновляется при завершении сложных экспедиций
                        break;
                        
                    case "upgrade_items":
                        // Прогресс обновляется при улучшении предметов
                        break;
                        
                    case "level_companion":
                        // Проверяем уровень помощниц
                        var max_companion_level = 0;
                        for (var k = 0; k < array_length(global.aty.companions); k++) {
                            if (global.aty.companions[k].level > max_companion_level) {
                                max_companion_level = global.aty.companions[k].level;
                            }
                        }
                        quest.current_progress[j] = max_companion_level;
                        break;
                        
                    case "collect_legendary":
                        // Считаем легендарные предметы в инвентаре
                        var legendary_count = 0;
                        for (var k = 0; k < array_length(global.aty.inventory); k++) {
                            // ИСПРАВЛЕНО: LEGENDAry -> LEGENDARY
                            if (global.aty.inventory[k].rarity == RARITY.LEGENDARY) {
                                legendary_count++;
                            }
                        }
                        quest.current_progress[j] = legendary_count;
                        break;
                }
                
                // Проверяем выполнена ли цель
                if (quest.current_progress[j] < objective.target) {
                    completed = false;
                }
            }
            
            // Если все цели выполнены
            if (completed) {
                quest.state = QUEST_STATE.COMPLETED;
                aty_show_notification("🎉 Квест завершен: " + quest.name);
                
                // Обновляем статистику
                if (quest.is_daily) {
                    global.aty.quests.quest_stats.daily_completed++;
                } else if (quest.is_weekly) {
                    global.aty.quests.quest_stats.weekly_completed++;
                }
            }
            
            // Проверяем ограничение по времени
            if (quest.time_limit > 0 && current_time - quest.start_time > quest.time_limit) {
                // ИСПРАВЛЕНО: Убедитесь что FAILED добавлен в enum QUEST_STATE
                quest.state = QUEST_STATE.FAILED;
                aty_show_notification("⏰ Время на квест истекло: " + quest.name);
                
                // Перемещаем в список проваленных квестов
                aty_move_quest_to_failed(quest.id);
                
                // Обновляем статистику
                global.aty.quests.quest_stats.failed_quests++;
            }
        }
    }
}
function aty_start_quest(_quest_id) {
    // Находим квест во всех возможных местах
    var quest = aty_find_quest_by_id(_quest_id);
    
    if (!is_struct(quest)) {
        aty_show_notification("❌ Квест не найден!");
        return false;
    }
    
    if (quest.state != QUEST_STATE.AVAILABLE) {
        aty_show_notification("❌ Квест недоступен!");
        return false;
    }
    
    // Проверяем требования
    if (!aty_meets_quest_requirements(quest)) {
        aty_show_notification("❌ Не выполнены требования для квеста!");
        return false;
    }
    
    quest.state = QUEST_STATE.IN_PROGRESS;
    quest.start_time = current_time;
    
    // Если квест с ограничением по времени, устанавливаем время окончания
    if (quest.time_limit > 0) {
        quest.end_time = current_time + quest.time_limit;
    }
    
    // Инициализируем прогресс если нужно
    if (!variable_struct_exists(quest, "current_progress") || !is_array(quest.current_progress)) {
        quest.current_progress = array_create(array_length(quest.objectives), 0);
    }
    
    // Добавляем в активные квесты если это не ежедневный/еженедельный
    if (!quest.is_daily && !quest.is_weekly) {
        // Проверяем что квеста еще нет в активных
        var already_active = false;
        for (var i = 0; i < array_length(global.aty.quests.active_quests); i++) {
            if (global.aty.quests.active_quests[i].id == _quest_id) {
                already_active = true;
                break;
            }
        }
        
        if (!already_active) {
            array_push(global.aty.quests.active_quests, quest);
        }
    }
    
    aty_show_notification("📜 Квест начат: " + quest.name);
    return true;
}
function _aty_handle_quests_tab_clicks(_mx, _my, _zone) {
    var tab_y = _zone.y1 + 70;
    var categories = ["Активные", "Ежедневные", "Еженедельные", "Доступные", "Завершенные", "Проваленные"];
    var tab_width = 120;
    
    // Обработка кликов по вкладкам
    for (var i = 0; i < array_length(categories); i++) {
        var tab_x = _zone.x1 + 20 + i * (tab_width + 10);
        
        if (point_in_rectangle(_mx, _my, tab_x, tab_y, tab_x + tab_width, tab_y + 30)) {
            global.aty.current_quest_category = i;
            return true;
        }
    }
    
    // Обработка кликов по кнопкам квестов
    var content_y = tab_y + 40;
    var quests = [];
    
    switch (global.aty.current_quest_category) {
        case 0: quests = global.aty.quests.active_quests; break;
        case 1: quests = global.aty.quests.daily_quests; break;
        case 2: quests = global.aty.quests.weekly_quests; break;
        case 3: quests = aty_get_available_quests(); break;
        case 4: quests = global.aty.quests.completed_quests; break;
        case 5: quests = global.aty.quests.failed_quests; break;
    }
    
    var quest_start_y = content_y + 40;
    
    for (var i = 0; i < array_length(quests); i++) {
        var quest = quests[i];
        var quest_y = quest_start_y + i * 100;
        
        if (quest_y > _zone.y2 - 100) break;
        
        // Определяем позицию кнопки в зависимости от состояния квеста
        var button_x1 = _zone.x2 - 120;
        var button_y1 = quest_y + 60;
        var button_x2 = _zone.x2 - 20;
        var button_y2 = button_y1 + 25;
        
        if (point_in_rectangle(_mx, _my, button_x1, button_y1, button_x2, button_y2)) {
            if (quest.state == QUEST_STATE.AVAILABLE) {
                aty_start_quest(quest.id);
                return true;
            } else if (quest.state == QUEST_STATE.COMPLETED) {
                aty_claim_quest_reward(quest.id);
                return true;
            } else if (quest.state == QUEST_STATE.IN_PROGRESS && global.aty.current_quest_category == 0) {
                aty_abandon_quest(quest.id);
                return true;
            }
        }
    }
    
    return false;
}
function aty_claim_quest_reward(_quest_id) {
    var quest = aty_find_quest_by_id(_quest_id);
    
    if (!is_struct(quest)) return false;
    
    if (quest.state != QUEST_STATE.COMPLETED) {
        aty_show_notification("❌ Квест еще не завершен!");
        return false;
    }
    
    // Выдаем награды
    aty_give_quest_rewards(quest);
    
    // Обновляем статистику
    global.aty.quests.quest_stats.total_completed++;
    global.aty.quests.quest_stats.gold_earned += quest.rewards.gold;
    global.aty.quests.quest_stats.exp_earned += quest.rewards.exp;
    
    // Перемещаем квест в завершенные
    quest.state = QUEST_STATE.CLAIMED;
    
    // Удаляем из активных если это не повторяемый квест
    if (!quest.repeatable) {
        aty_remove_quest_from_active(_quest_id);
        array_push(global.aty.quests.completed_quests, quest);
    } else {
        // Сбрасываем повторяемый квест
        aty_reset_repeatable_quest(quest);
    }
    
    aty_show_notification("🎁 Награда получена: " + quest.name);
    return true;
}
// =============================================================================
// MINI-RAID SYSTEM  
// =============================================================================

function aty_get_miniraid_database() {
    return [
        {
            id: "raid_001",
            name: "Логово Древнего Змея",
            description: "Победите древнего змея в его логове",
            required_level: 3,
            duration: 300, // 5 minutes
            reward: { gold: 500, items: [RARITY.RARE, RARITY.EPIC] },
            state: RAID_STATE.AVAILABLE
        },
        {
            id: "raid_002",
            name: "Храм Забытых Богов", 
            description: "Исследуйте древний храм и победите стражей",
            required_level: 5,
            duration: 420, // 7 minutes
            reward: { gold: 800, items: [RARITY.EPIC, RARITY.LEGENDARY] },
            state: RAID_STATE.AVAILABLE
        },
        {
            id: "raid_003",
            name: "Пещеры Ледяного Великана",
            description: "Сразитесь с ледяным великаном в его пещерах",
            required_level: 7, 
            duration: 600, // 10 minutes
            reward: { gold: 1200, items: [RARITY.LEGENDARY, RARITY.MYTHIC] },
            state: RAID_STATE.AVAILABLE
        }
    ];
}

function aty_start_miniraid(_raid_index) {
    var raid = global.aty.miniraids[_raid_index];
    
    if (raid.state != RAID_STATE.AVAILABLE) {
        aty_show_notification("Рейд уже завершен или в процессе!");
        return false;
    }
    
    if (global.aty.hero.level < raid.required_level) {
        aty_show_notification("Требуется уровень " + string(raid.required_level) + " для этого рейда!");
        return false;
    }
    
    if (global.aty.raids.active) {
        aty_show_notification("Уже идет другой рейд!");
        return false;
    }
    
    // Start the raid
    global.aty.raids.active = true;
    global.aty.raids.current_raid = _raid_index;
    global.aty.raids.timer = raid.duration;
    global.aty.raids.state = RAID_STATE.IN_PROGRESS;
    
    raid.state = RAID_STATE.IN_PROGRESS;
    aty_show_notification("Рейд начат: " + raid.name);
    return true;
}

function aty_complete_raid() {
    if (!global.aty.raids.active) return;
    
    var raid_index = global.aty.raids.current_raid;
    var raid = global.aty.miniraids[raid_index];
    
    global.aty.raids.active = false;
    raid.state = RAID_STATE.COMPLETED;
    
    // Give rewards
    global.aty.hero.gold += raid.reward.gold;
    
    // Generate loot
    for (var i = 0; i < 2; i++) {
        var rarity = raid.reward.items[i];
        var loot_item = aty_generate_loot_item(rarity);
        array_push(global.aty.inventory, loot_item);
    }
    
    aty_show_notification("Рейд завершен! Получено: " + string(raid.reward.gold) + " золота и 2 предмета");
}

// =============================================================================
// ARENA SYSTEM
// =============================================================================

function aty_enter_arena(_arena_index) {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) return false;
    
    // Check if arena is unlocked
    if (!array_contains(global.aty.arenas.unlocked, _arena_index)) {
        aty_show_notification("Арена заблокирована! Победите соответствующего босса в экспедиции.");
        return false;
    }
    
    var room_name = "rm_arena_" + string(_arena_index);
    var room_id = asset_get_index(room_name);
    
    if (room_exists(room_id)) {
        room_goto(room_id);
        return true;
    } else {
        aty_show_notification("Комната арены не найдена: " + room_name);
        return false;
    }
}

function aty_unlock_arena(_arena_index) {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) return;
    
    if (!array_contains(global.aty.arenas.unlocked, _arena_index)) {
        array_push(global.aty.arenas.unlocked, _arena_index);
        aty_show_notification("Арена " + string(_arena_index) + " разблокирована!");
    }
}

// =============================================================================
// PASSIVE ABILITIES SYSTEM
// =============================================================================

function aty_get_passive_database() {
    return [
        {
            aid: "TREASURE_SENSE",
            name: "Чувство Сокровищ",
            description: "+20% к шансу дропа редких предметов",
            effect: PASSIVE_EFFECT.TREASURE_SENSE
        },
        {
            aid: "SET_SYNERGY", 
            name: "Синергия Сета",
            description: "+15% к характеристикам при полном сете",
            effect: PASSIVE_EFFECT.SET_SYNERGY
        },
        {
            aid: "GUARDIAN_AURA",
            name: "Аура Защитника", 
            description: "-30% получаемого урона",
            effect: PASSIVE_EFFECT.GUARDIAN_AURA
        },
        {
            aid: "QUICK_HANDS",
            name: "Ловкие Руки",
            description: "Увеличивает скорость атаки",
            effect: PASSIVE_EFFECT.QUICK_HANDS
        },
        {
            aid: "BLADE_DANCER",
            name: "Танец Клинков",
            description: "Шанс двойной атаки",
            effect: PASSIVE_EFFECT.BLADE_DANCER
        },
        {
            aid: "FORTUNE_FAVORS",
            name: "Благоволение Фортуны",
            description: "Улучшает исход экспедиций",
            effect: PASSIVE_EFFECT.FORTUNE_FAVORS
        }
    ];
}

function aty_unlock_random_passive() {
    if (!variable_struct_exists(global, "aty") || !variable_struct_exists(global.aty, "hero")) return;
    
    var available_passives = aty_get_passive_database();
    var current_passives = global.aty.hero.passives;
    
    // Filter out already owned passives
    for (var i = array_length(available_passives) - 1; i >= 0; i--) {
        for (var j = 0; j < array_length(current_passives); j++) {
            if (available_passives[i].aid == current_passives[j].aid) {
                array_delete(available_passives, i, 1);
                break;
            }
        }
    }
    
    // Check if hero can learn more passives (max 6)
    if (array_length(current_passives) >= 6) {
        aty_show_notification("Достигнут максимум пассивных способностей (6)");
        return;
    }
    
    if (array_length(available_passives) > 0) {
        var random_index = irandom(array_length(available_passives) - 1);
        var new_passive = available_passives[random_index];
        
        array_push(global.aty.hero.passives, new_passive);
        aty_show_notification("Получена новая способность: " + new_passive.name);
        
        // Apply passive effects
        aty_apply_passive_effects();
    }
}
function aty_apply_passive_effects() {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) return;
    
    var stats = global.aty.hero.stats;
    var base_stats = { hp: 100, maxhp: 100, atk: 10, def: 5, crit: 5, critdmg: 150, aspd: 100, ms: 100, wisdom: 10 };
    
    // Reset to base stats
    variable_struct_set(stats, "hp", base_stats.hp);
    variable_struct_set(stats, "maxhp", base_stats.maxhp);
    variable_struct_set(stats, "atk", base_stats.atk);
    variable_struct_set(stats, "def", base_stats.def);
    variable_struct_set(stats, "crit", base_stats.crit);
    variable_struct_set(stats, "critdmg", base_stats.critdmg);
    variable_struct_set(stats, "aspd", base_stats.aspd);
    variable_struct_set(stats, "ms", base_stats.ms);
    variable_struct_set(stats, "wisdom", base_stats.wisdom);
    
    // Apply passive modifications
    for (var i = 0; i < array_length(global.aty.hero.passives); i++) {
        var passive = global.aty.hero.passives[i];
        
        switch (passive.effect) {
            case PASSIVE_EFFECT.TREASURE_SENSE:
                break;
            case PASSIVE_EFFECT.SET_SYNERGY:
                break;
            case PASSIVE_EFFECT.GUARDIAN_AURA:
                stats.def += base_stats.def * 0.3;
                break;
            case PASSIVE_EFFECT.QUICK_HANDS:
                stats.aspd += 15;
                break;
        }
    }
}

// =============================================================================
// EXPEDITION SYSTEM
// =============================================================================
// Также обновляем функцию aty_start_expedition() для рейд-босса:
function aty_start_expedition(_difficulty) {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) return false;
    
    // Проверяем на рейд-босса (уровень 6)
    if (_difficulty == 6) {
        return aty_start_raid_boss();
    }
    
    if (_difficulty < 1 || _difficulty > 5) {
        show_debug_message("Invalid expedition difficulty: " + string(_difficulty));
        return false;
    }
    
    var expedition_index = _difficulty - 1;
    
    // Проверяем что индекс валиден
    if (expedition_index < 0 || expedition_index >= array_length(global.aty.expeditions)) {
        show_debug_message("Invalid expedition index: " + string(expedition_index));
        return false;
    }
    
    var expedition = global.aty.expeditions[expedition_index];
    
    // Проверяем требования уровня
    if (global.aty.hero.level < expedition.required_level) {
        aty_show_notification("Требуется уровень " + string(expedition.required_level) + " для этой экспедиции!");
        return false;
    }
    
    if (global.aty.expedition.active) {
        aty_show_notification("Экспедиция уже в процессе!");
        return false;
    }
    
    // Устанавливаем текущую экспедицию
    global.aty.current_expedition = expedition_index;
    global.aty.expedition.active = true;
    global.aty.expedition.timer = expedition.duration;
    global.aty.expedition.progress = 0;
    global.aty.expedition.drops = [];
    global.aty.expedition.special_event = false;
    
    // Инициализируем active_buffs если не существует
    if (!variable_struct_exists(global.aty.expedition, "active_buffs")) {
        global.aty.expedition.active_buffs = [];
    }
    
    global.aty.vfx.palette = "good";
    
    // Применяем баффы от помощниц
    aty_apply_companion_buffs();
    
    // Показываем уведомление о начале экспедиции
    aty_show_notification("🚀 Начата экспедиция: " + expedition.name);
    
    return true;
}

function aty_equip_item(_inv_index) {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) return false;
    
    if (_inv_index < 0 || _inv_index >= array_length(global.aty.inventory)) return false;
    
    var item = global.aty.inventory[_inv_index];
    if (!is_struct(item)) return false;
    
    // Определяем слот для экипировки
    var slot = "";
    if (variable_struct_exists(item, "slot")) {
        slot = item.slot;
    } else if (variable_struct_exists(item, "item_type")) {
        // Конвертируем item_type в slot для обратной совместимости
        slot = aty_convert_item_type_to_slot(item.item_type);
    } else {
        return false;
    }
    
    var equipment = global.aty.hero.equipment;
    if (!variable_struct_exists(equipment, slot)) return false;
    
    var current_item = variable_struct_get(equipment, slot);
    
    // Если в слоте уже есть предмет, возвращаем его в инвентарь
    if (is_struct(current_item)) {
        array_push(global.aty.inventory, current_item);
    }
    
    // Экипируем новый предмет
    variable_struct_set(equipment, slot, item);
    array_delete(global.aty.inventory, _inv_index, 1);
    
    // Пересчитываем характеристики героя
    aty_recalculate_hero_stats();
    
    aty_show_notification("Экипирован: " + item.name);
    return true;
}

function aty_apply_passive_stats() {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) return;
    
    var hero = global.aty.hero;
    var stats = hero.stats;
    var passives = hero.passives;
    
    for (var i = 0; i < array_length(passives); i++) {
        var passive = passives[i];
        
        switch (passive.effect) {
            case PASSIVE_EFFECT.TREASURE_SENSE:
                // Уже обрабатывается в других системах
                break;
            case PASSIVE_EFFECT.SET_SYNERGY:
                // Уже обрабатывается в системе сетов
                break;
            case PASSIVE_EFFECT.GUARDIAN_AURA:
                stats.defense += stats.defense * 0.3; // +30% защиты
                break;
            case PASSIVE_EFFECT.QUICK_HANDS:
                stats.attack_speed += 15;
                break;
            case PASSIVE_EFFECT.BLADE_DANCER:
                stats.crit_chance += 5;
                break;
            case PASSIVE_EFFECT.FORTUNE_FAVORS:
                // Увеличивает удачу экспедиций (обрабатывается отдельно)
                break;
        }
    }
}
// =============================================================================
// UPDATED ACTIVE BUFFS APPLICATION WITH PERCENTAGES
// =============================================================================

function aty_apply_active_buffs() {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) return;
    
    // Проверяем существование активных баффов
    if (!variable_struct_exists(global.aty.expedition, "active_buffs")) {
        return;
    }
    
    var active_buffs = global.aty.expedition.active_buffs;
    var stats = global.aty.hero.stats;
    var base_stats = global.aty.hero.base_stats;
    
    // Сначала сбрасываем все процентные бонусы от предыдущих баффов
    // Пересчитываем базовые характеристики
    aty_recalculate_base_stats();
    
    for (var i = 0; i < array_length(active_buffs); i++) {
        var buff = active_buffs[i];
        if (!is_struct(buff) || !variable_struct_exists(buff, "stats")) continue;
        
        var buff_stats = buff.stats;
        
        // Применяем процентные бонусы к характеристикам
        if (variable_struct_exists(buff_stats, "health_percent")) {
            var base_health = 100 + (base_stats.vitality * 20) + (base_stats.strength * 10);
            stats.health += base_health * (buff_stats.health_percent / 100);
        }
        if (variable_struct_exists(buff_stats, "mana_percent")) {
            var base_mana = 50 + (base_stats.intelligence * 15);
            stats.mana += base_mana * (buff_stats.mana_percent / 100);
        }
        if (variable_struct_exists(buff_stats, "attack_power_percent")) {
            var base_attack = 10 + (base_stats.strength * 2);
            stats.attack_power += base_attack * (buff_stats.attack_power_percent / 100);
        }
        if (variable_struct_exists(buff_stats, "magic_power_percent")) {
            var base_magic = 5 + (base_stats.intelligence * 2);
            stats.magic_power += base_magic * (buff_stats.magic_power_percent / 100);
        }
        if (variable_struct_exists(buff_stats, "defense_percent")) {
            var base_defense = 5 + (base_stats.vitality * 1.5);
            stats.defense += base_defense * (buff_stats.defense_percent / 100);
        }
        if (variable_struct_exists(buff_stats, "crit_chance_percent")) {
            var base_crit = 5 + (base_stats.agility * 1) + (base_stats.luck * 0.3);
            stats.crit_chance += base_crit * (buff_stats.crit_chance_percent / 100);
        }
        if (variable_struct_exists(buff_stats, "crit_damage_percent")) {
            var base_crit_dmg = 150 + (base_stats.agility * 2);
            stats.crit_damage += base_crit_dmg * (buff_stats.crit_damage_percent / 100);
        }
        if (variable_struct_exists(buff_stats, "attack_speed_percent")) {
            var base_attack_speed = 100 + (base_stats.agility * 2);
            stats.attack_speed += base_attack_speed * (buff_stats.attack_speed_percent / 100);
        }
        if (variable_struct_exists(buff_stats, "cast_speed_percent")) {
            var base_cast_speed = 100 + (base_stats.dexterity * 1.5);
            stats.cast_speed += base_cast_speed * (buff_stats.cast_speed_percent / 100);
        }
        if (variable_struct_exists(buff_stats, "dodge_chance_percent")) {
            var base_dodge = 2 + (base_stats.agility * 0.5);
            stats.dodge_chance += base_dodge * (buff_stats.dodge_chance_percent / 100);
        }
        if (variable_struct_exists(buff_stats, "block_chance_percent")) {
            stats.block_chance += buff_stats.block_chance_percent;
        }
        if (variable_struct_exists(buff_stats, "lifesteal_percent")) {
            stats.lifesteal += buff_stats.lifesteal_percent;
        }
        if (variable_struct_exists(buff_stats, "cooldown_reduction_percent")) {
            stats.cooldown_reduction += buff_stats.cooldown_reduction_percent;
        }
        if (variable_struct_exists(buff_stats, "movement_speed_percent")) {
            var base_movement = 100 + (base_stats.agility * 1);
            stats.movement_speed += base_movement * (buff_stats.movement_speed_percent / 100);
        }
        if (variable_struct_exists(buff_stats, "dexterity_percent")) {
            var base_dex_bonus = base_stats.dexterity * 0.5; // 0.5% точности за уровень ловкости
            stats.cast_speed += base_dex_bonus * (buff_stats.dexterity_percent / 100);
        }
    }
}

function aty_apply_set_bonuses() {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) return;
    
    var bonuses = aty_calculate_set_bonuses();
    var stats = global.aty.hero.stats;
    
    // Применяем бонусы сетов
    if (variable_struct_exists(bonuses, "health")) 
        stats.health += bonuses.health;
    if (variable_struct_exists(bonuses, "mana")) 
        stats.mana += bonuses.mana;
    if (variable_struct_exists(bonuses, "attack_power")) 
        stats.attack_power += bonuses.attack_power;
    if (variable_struct_exists(bonuses, "magic_power")) 
        stats.magic_power += bonuses.magic_power;
    if (variable_struct_exists(bonuses, "defense")) 
        stats.defense += bonuses.defense;
    if (variable_struct_exists(bonuses, "crit_chance")) 
        stats.crit_chance += bonuses.crit_chance;
    if (variable_struct_exists(bonuses, "crit_damage")) 
        stats.crit_damage += bonuses.crit_damage;
    if (variable_struct_exists(bonuses, "attack_speed")) 
        stats.attack_speed += bonuses.attack_speed;
    if (variable_struct_exists(bonuses, "cast_speed")) 
        stats.cast_speed += bonuses.cast_speed;
    if (variable_struct_exists(bonuses, "dodge_chance")) 
        stats.dodge_chance += bonuses.dodge_chance;
    if (variable_struct_exists(bonuses, "block_chance")) 
        stats.block_chance += bonuses.block_chance;
    if (variable_struct_exists(bonuses, "lifesteal")) 
        stats.lifesteal += bonuses.lifesteal;
    if (variable_struct_exists(bonuses, "cooldown_reduction")) 
        stats.cooldown_reduction += bonuses.cooldown_reduction;
    if (variable_struct_exists(bonuses, "movement_speed")) 
        stats.movement_speed += bonuses.movement_speed;
}
// Новая система прогулки для помощниц
function aty_start_walk(_companion_index) {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) return false;
    
    if (_companion_index < 0 || _companion_index >= array_length(global.aty.companions)) return false;
    
    var companion = global.aty.companions[_companion_index];
    
    if (companion.state != COMPANION_STATE.AVAILABLE) {
        aty_show_notification("Помощница недоступна для прогулки!");
        return false;
    }
    
    if (companion.walk_state == WALK_STATE.WALKING) {
        aty_show_notification("Помощница уже на прогулке!");
        return false;
    }
    
    // Устанавливаем таймер прогулки (5 минут в шагах)
    companion.walk_state = WALK_STATE.WALKING;
    companion.walk_timer = 5 * 60 * room_speed; // 5 минут
    companion.state = COMPANION_STATE.WALKING;
    
    aty_show_notification(companion.name + " отправилась на прогулку! Вернется через 5 минут.");
    return true;
}

function aty_complete_walk(_companion_index) {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) return;
    
    var companion = global.aty.companions[_companion_index];
    
    companion.walk_state = WALK_STATE.RETURNED;
    companion.state = COMPANION_STATE.AVAILABLE;
    
    // Добавляем случайный костюм
    var new_costume = "костюм_" + string(irandom(4) + 1);
    if (!array_contains(companion.costumes, new_costume)) {
        array_push(companion.costumes, new_costume);
        aty_show_notification("🎉 " + companion.name + " вернулась с прогулки с новым костюмом: " + new_costume + "!");
    } else {
        aty_show_notification(companion.name + " вернулась с прогулки!");
    }
}

function aty_check_level_up_passives() {
    if (!is_struct(global.aty)) return;
    
    var hero_level = global.aty.hero.level;
    var current_passives = array_length(global.aty.hero.passives);
    
    // Unlock new passive every 5 levels (max 6 total)
    var expected_passives = min(3 + floor(hero_level / 5), 6);
    
    if (current_passives < expected_passives) {
        aty_unlock_random_passive();
    }
}
// Функция продажи предмета
function aty_sell_item(_inv_index) {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) return false;
    
    if (_inv_index < 0 || _inv_index >= array_length(global.aty.inventory)) return false;
    
    var item = global.aty.inventory[_inv_index];
    
    // Рассчитываем цену продажи на основе редкости
    var sell_price = aty_calculate_sell_price(item);
    
    // Добавляем золото герою
    global.aty.hero.gold += sell_price;
    
    // Удаляем предмет из инвентаря
    array_delete(global.aty.inventory, _inv_index, 1);
	    // Обновляем квесты
    aty_on_item_sold();  
    aty_show_notification("Предмет продан за " + string(sell_price) + " золота");
    return true;
	
}

// Функция расчета цены продажи
function aty_calculate_sell_price(_item) {
    var base_price = 0;
    switch (_item.rarity) {
        case RARITY.COMMON: base_price = 25; break;
        case RARITY.UNCOMMON: base_price = 75; break;
        case RARITY.RARE: base_price = 200; break;
        case RARITY.EPIC: base_price = 500; break;
        case RARITY.LEGENDARY: base_price = 1500; break;
        default: base_price = 10;
    }
    
    // Добавляем бонусы за характеристики
    var stats_bonus = 0;
    if (variable_struct_exists(_item.stats, "atk")) {
        stats_bonus += _item.stats.atk * 5;
    }
    if (variable_struct_exists(_item.stats, "def")) {
        stats_bonus += _item.stats.def * 5;
    }
    
    return base_price + stats_bonus;
}

// =============================================================================
// UPDATED EXPEDITION COMPLETION TO REMOVE BUFFS - FIXED TYPO
// =============================================================================

function aty_complete_expedition() {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) return;
    
    var exp_index = global.aty.current_expedition;
    
    // Проверяем что индекс экспедиции валиден
    if (exp_index < 0 || exp_index >= array_length(global.aty.expeditions)) {
        show_debug_message("Invalid expedition index: " + string(exp_index));
        return;
    }
    
    var expedition = global.aty.expeditions[exp_index];
    
    global.aty.expedition.active = false;
    global.aty.expedition.active_buffs = [];
    
    // Награда за уровень
    var exp_reward = expedition.difficulty * 100;
    global.aty.hero.exp += exp_reward;
    
    // Награда золотом
    global.aty.hero.gold += expedition.gold_reward;
    
    // Проверяем повышение уровня
    var level_up = false;
    while (global.aty.hero.exp >= global.aty.hero.level * 200) {
        aty_level_up();
        level_up = true;
    }
    
    // Генерация лута с использованием новой системы
    var loot_count = 2 + expedition.difficulty;
    var has_treasure_sense = false;
    
    // Проверяем пассивку Treasure Sense
    for (var i = 0; i < array_length(global.aty.hero.passives); i++) {
        if (global.aty.hero.passives[i].effect == PASSIVE_EFFECT.TREASURE_SENSE) {
            has_treasure_sense = true;
            break;
        }
    }
    
    if (has_treasure_sense && random(1) < 0.2) {
        loot_count += 1;
    }
    
    // Генерируем лут с новой функцией
    for (var i = 0; i < loot_count; i++) {
        var rarity_roll = random(1);
        var item_rarity = RARITY.COMMON;
        
        // Более высокие шансы для редких предметов на сложных экспедициях
        var rarity_mod = expedition.difficulty * 0.05;
        
        if (rarity_roll < 0.01 + rarity_mod) item_rarity = RARITY.LEGENDARY;
        else if (rarity_roll < 0.05 + rarity_mod) item_rarity = RARITY.EPIC;
        else if (rarity_roll < 0.15 + rarity_mod) item_rarity = RARITY.RARE;
        else if (rarity_roll < 0.4 + rarity_mod) item_rarity = RARITY.UNCOMMON;
        
        // Используем безопасную функцию генерации лута
        var loot_item = aty_generate_loot_item_safe(item_rarity);
        
        // Добавляем в инвентарь через новую систему
        aty_add_item_to_inventory(loot_item);
        
        // Также добавляем в дропы экспедиции для визуализации (копируем предмет)
        var loot_copy = aty_copy_item(loot_item);
        array_push(global.aty.expedition.drops, loot_copy);
    }
    
    // Отмечаем экспедицию как завершенную
    if (!expedition.completed) {
        expedition.completed = true;
        
        // Открываем помощницу если есть босс
        if (expedition.boss != "") {
            aty_unlock_companion_by_key(expedition.boss);
        }
    }
    
    // Пересчитываем характеристики без баффов
    aty_recalculate_hero_stats();
    
    // Показываем визуализацию лута
    aty_show_loot_visualization();
    
    // Отслеживаем трофеи экспедиций
    aty_track_expedition_trophies();
    
    aty_show_notification("Экспедиция завершена! Получено: " + string(loot_count) + " предметов, " + string(expedition.gold_reward) + " золота");
	    // Обновляем квесты
    aty_on_expedition_complete(global.aty.current_expedition + 1);
}

function aty_add_item_to_inventory(_item) {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) return false;
    
    // Проверяем валидность предмета
    if (!is_struct(_item)) {
        show_debug_message("ERROR: Trying to add invalid item to inventory");
        return false;
    }
    
    // Убеждаемся, что у предмета есть ID
    if (!variable_struct_exists(_item, "id")) {
        _item.id = "item_" + string(irandom_range(10000, 99999)) + "_" + string(current_time);
    }
    
    // Добавляем предмет в инвентарь
    array_push(global.aty.inventory, _item);
    
    // Отслеживаем трофеи коллекции
    aty_track_collection_trophies();
    
    // Показываем уведомление, если это редкий предмет
    if (variable_struct_exists(_item, "rarity") && _item.rarity >= RARITY.RARE) {
        var rarity_name = aty_get_rarity_name(_item.rarity);
        aty_show_notification("🎁 Получен " + rarity_name + " предмет: " + _item.name);
    }
    
    // Обновляем статистику
    aty_update_item_statistics(_item);
    
    return true;
}

function aty_update_item_statistics(_item) {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) return;
    
    // Инициализируем статистику предметов если нужно
    if (!variable_struct_exists(global.aty, "item_stats")) {
        global.aty.item_stats = {
            total_items_found: 0,
            items_by_rarity: {
                common: 0,
                uncommon: 0,
                rare: 0,
                epic: 0,
                legendary: 0,
                mythic: 0,
                divine: 0
            },
            items_by_type: {
                weapon: 0,
                armor: 0,
                accessory: 0,
                trinket: 0,
                charm: 0,
                gem: 0
            },
            highest_rarity_found: RARITY.COMMON
        };
    }
    
    var stats = global.aty.item_stats;
    stats.total_items_found++;
    
    // Обновляем статистику по редкости
    if (variable_struct_exists(_item, "rarity")) {
        var rarity = _item.rarity;
        
        // Обновляем максимальную редкость
        if (rarity > stats.highest_rarity_found) {
            stats.highest_rarity_found = rarity;
        }
        
        // Обновляем счетчики по редкости
        switch (rarity) {
            case RARITY.COMMON: stats.items_by_rarity.common++; break;
            case RARITY.UNCOMMON: stats.items_by_rarity.uncommon++; break;
            case RARITY.RARE: stats.items_by_rarity.rare++; break;
            case RARITY.EPIC: stats.items_by_rarity.epic++; break;
            case RARITY.LEGENDARY: stats.items_by_rarity.legendary++; break;
            case RARITY.MYTHIC: stats.items_by_rarity.mythic++; break;
            case RARITY.DIVINE: stats.items_by_rarity.divine++; break;
        }
    }
    
    // Обновляем статистику по типу
    var item_type = aty_get_item_type_for_filter(_item);
    switch (item_type) {
        case "weapon": stats.items_by_type.weapon++; break;
        case "armor": stats.items_by_type.armor++; break;
        case "accessory": stats.items_by_type.accessory++; break;
        case "trinket": stats.items_by_type.trinket++; break;
        case "charm": stats.items_by_type.charm++; break;
        case "gem": stats.items_by_type.gem++; break;
    }
}

// Добавляем обработку кликов для категорий трофеев
function aty_handle_trophies_tab_clicks(_mx, _my, _zone) {
    var category_y = _zone.y1 + 120;
    var categories = [
        TROPHY_CATEGORY.COMBAT,
        TROPHY_CATEGORY.EXPLORATION,
        TROPHY_CATEGORY.COLLECTION, 
        TROPHY_CATEGORY.CRAFTING,
        TROPHY_CATEGORY.SPECIAL,
        TROPHY_CATEGORY.BOSS
    ];
    
    var button_width = 120;
    var button_height = 30;
    var button_spacing = 10;
    
    for (var i = 0; i < array_length(categories); i++) {
        var button_x = _zone.x1 + 20 + i * (button_width + button_spacing);
        
        if (point_in_rectangle(_mx, _my, button_x, category_y, button_x + button_width, category_y + button_height)) {
            global.aty.current_trophy_category = categories[i];
            return true;
        }
    }
    
    return false;
}
function aty_safe_compare_items(_item1, _item2) {
    if (!is_struct(_item1) || !is_struct(_item2)) return false;
    
    // Сначала проверяем наличие ID
    if (!variable_struct_exists(_item1, "id") || !variable_struct_exists(_item2, "id")) {
        return false;
    }
    
    return _item1.id == _item2.id;
}
// =============================================================================
// FIXED COMPANION UNLOCKING
// =============================================================================

function aty_unlock_companion_by_key(_comp_key) {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) return;
    
    for (var i = 0; i < array_length(global.aty.companions); i++) {
        if (global.aty.companions[i].comp_key == _comp_key) {
            global.aty.companions[i].unlocked = true;
            global.aty.companions[i].state = COMPANION_STATE.AVAILABLE;
            aty_unlock_arena(i);
            
            // Специальное уведомление для новой помощницы
            aty_show_notification("🎉 " + global.aty.companions[i].name + " присоединилась к отряду! 🎉");
            return;
        }
    }
    
    show_debug_message("Companion with key '" + _comp_key + "' not found");
}

function aty_show_loot_visualization() {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) return;
    
    // Create flash effect based on highest rarity
    var highest_rarity = RARITY.COMMON;
    for (var i = 0; i < array_length(global.aty.expedition.drops); i++) {
        var drop = global.aty.expedition.drops[i];
        if (is_struct(drop) && variable_struct_exists(drop, "rarity") && drop.rarity > highest_rarity) {
            highest_rarity = drop.rarity;
        }
    }
    
    // Set flash color based on rarity
    var flash_color = c_white;
    switch (highest_rarity) {
        case RARITY.COMMON: flash_color = global.aty_colors.rarity_common; break;
        case RARITY.UNCOMMON: flash_color = global.aty_colors.rarity_uncommon; break;
        case RARITY.RARE: flash_color = global.aty_colors.rarity_rare; break;
        case RARITY.EPIC: flash_color = global.aty_colors.rarity_epic; break;
        case RARITY.LEGENDARY: flash_color = global.aty_colors.rarity_legendary; break;
    }
    
    global.aty.expedition.flash = {
        active: true,
        timer: 60,
        color: flash_color
    };
}
// =============================================================================
// COMPANION SYSTEM
// =============================================================================

// В функции aty_get_companion_database() обновляем структуру компаньонов:
function aty_get_companion_database() {
    return [
        { 
            comp_key: "HEPO", 
            name: "Хефа", 
            buffs: ["MIGHT", "BLESSED_BODY", "HASTE", "BERSERKER", "ACUTE"],
            unlocked: false, 
            rank: 1, 
            level: 1,
            state: COMPANION_STATE.LOCKED,
            training_progress: 0,
            walk_timer: 0,
            walk_state: WALK_STATE.IDLE, // ДОБАВЛЯЕМ ЭТУ СТРОКУ
            current_costume: "default",  // ДОБАВЛЯЕМ ЭТУ СТРОКУ
            costumes: ["default"]
        },
        { 
            comp_key: "FATTY", 
            name: "Афина", 
            buffs: ["SHIELD", "FOCUS", "PROPHECY", "HOLY_SHIELD", "GUIDANCE"],
            unlocked: false, 
            rank: 1, 
            level: 1,
            state: COMPANION_STATE.LOCKED,
            training_progress: 0,
            walk_timer: 0,
            walk_state: WALK_STATE.IDLE, // ДОБАВЛЯЕМ ЭТУ СТРОКУ
            current_costume: "default",  // ДОБАВЛЯЕМ ЭТУ СТРОКУ
            costumes: ["default"]
        },
        { 
            comp_key: "DISC", 
            name: "Артемида", 
            buffs: ["WIND_WALK", "DEATH_WHISPER", "BLESSED_SOUL", "VELOCITY", "AGILITY"],
            unlocked: false, 
            rank: 1, 
            level: 1,
            state: COMPANION_STATE.LOCKED,
            training_progress: 0,
            walk_timer: 0,
            walk_state: WALK_STATE.IDLE, // ДОБАВЛЯЕМ ЭТУ СТРОКУ
            current_costume: "default",  // ДОБАВЛЯЕМ ЭТУ СТРОКУ
            costumes: ["default"]
        }
    ];
}

function aty_apply_companion_buffs() {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) return;
    
    var active_buffs = [];
    var buff_db = aty_get_buff_database();
    
    // Сбрасываем предыдущие баффы
    if (!variable_struct_exists(global.aty.expedition, "active_buffs")) {
        global.aty.expedition.active_buffs = [];
    } else {
        global.aty.expedition.active_buffs = [];
    }
    
    for (var i = 0; i < array_length(global.aty.companions); i++) {
        var companion = global.aty.companions[i];
        
        if (companion.state == COMPANION_STATE.AVAILABLE && companion.unlocked) {
            // Применяем баффы в зависимости от ранга (1 бафф за ранг)
            var buff_count = companion.rank;
            
            for (var j = 0; j < buff_count; j++) {
                if (j < array_length(companion.buffs)) {
                    var buff_key = companion.buffs[j];
                    var buff_data = aty_find_buff_data(buff_db, buff_key);
                    
                    if (is_struct(buff_data)) {
                        array_push(active_buffs, buff_data);
                    }
                }
            }
        }
    }
    
    global.aty.expedition.active_buffs = active_buffs;
    
    // Пересчитываем характеристики для применения баффов
    aty_recalculate_hero_stats();
}

// Добавляем функцию для безопасного получения длины массива
function aty_safe_array_length(_array) {
    if (!is_array(_array)) return 0;
    return array_length(_array);
}
// =============================================================================
// UTILITY FUNCTION: FIND BUFF DATA
// =============================================================================

function aty_find_buff_data(_buff_db, _buff_key) {
    for (var i = 0; i < array_length(_buff_db); i++) {
        if (_buff_db[i].buff_key == _buff_key) {
            return _buff_db[i];
        }
    }
    return undefined;
}

function aty_apply_buff_stats(_active_buffs) {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) return;
    
    var hero_stats = global.aty.hero.stats;
    var base_stats = { atk: 10, def: 5, crit: 5, critdmg: 150, aspd: 100, ms: 100, maxhp: 100 };
    
    // Временное хранение модификаторов
    var stat_modifiers = {};
    
    // Собираем все модификаторы из активных баффов
    for (var i = 0; i < array_length(_active_buffs); i++) {
        var buff = _active_buffs[i];
        var buff_stats = buff.stats;
        var stat_keys = variable_struct_get_names(buff_stats);
        
        for (var j = 0; j < array_length(stat_keys); j++) {
            var stat_key = stat_keys[j];
            var stat_value = variable_struct_get(buff_stats, stat_key);
            
            if (!variable_struct_exists(stat_modifiers, stat_key)) {
                variable_struct_set(stat_modifiers, stat_key, 0);
            }
            
            var current_value = variable_struct_get(stat_modifiers, stat_key);
            variable_struct_set(stat_modifiers, stat_key, current_value + stat_value);
        }
    }
    
    // Применяем модификаторы к базовым статам
    var modifier_keys = variable_struct_get_names(stat_modifiers);
    for (var k = 0; k < array_length(modifier_keys); k++) {
        var mod_key = modifier_keys[k];
        var mod_value = variable_struct_get(stat_modifiers, mod_key);
        
        // Процентные бонусы применяются к базовому значению
        if (string_pos("%", string(mod_key)) > 0) {
            var base_value = variable_struct_get(base_stats, mod_key);
            var bonus = base_value * (mod_value / 100);
            variable_struct_set(hero_stats, mod_key, base_value + bonus);
        } else {
            // Абсолютные бонусы добавляются напрямую
            var current_value = variable_struct_get(hero_stats, mod_key);
            variable_struct_set(hero_stats, mod_key, current_value + mod_value);
        }
    }
}

function aty_unlock_companion(_companion_index) {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) return;
    
    if (_companion_index >= 0 && _companion_index < array_length(global.aty.companions)) {
        global.aty.companions[_companion_index].state = COMPANION_STATE.AVAILABLE;
        aty_unlock_arena(_companion_index);
        aty_show_notification("Помощница " + global.aty.companions[_companion_index].name + " присоединилась к отряду!");
    }
}

// =============================================================================
// UI SYSTEM - С ДОПОЛНИТЕЛЬНЫМИ ПРОВЕРКАМИ
// =============================================================================

function aty_draw_ui() {  
    // Initialize colors if needed
    if (!variable_struct_exists(global, "aty_colors")) {
        aty_init_colors();
    }
    
    var user_interface_colors = global.aty_colors;
    var aty_system = global.aty;
    
    // Verify colors are properly initialized
    if (!is_struct(user_interface_colors)) {
        // Fallback colors if main structure is damaged
        draw_set_color(c_black);
        draw_rectangle(0, 0, 1000, 1000, false);
        draw_set_color(c_yellow);
        draw_text(100, 100, "UI System Error - Colors not initialized");
        return;
    }
    
    // Dark fantasy background with neon accents
    draw_set_color(user_interface_colors.bg_dark);
    draw_rectangle(0, 0, 1000, 1000, false);
    
    // Safe drawing of all UI zones
    try {
        _aty_draw_top_zone();
        _aty_draw_middle_zone();
        _aty_draw_portraits();
        _aty_draw_tabs();
    } catch (zone_drawing_error) {
        show_debug_message("Error drawing UI zones: " + string(zone_drawing_error));
        // Fallback error display
        draw_set_color(c_yellow);
        draw_text(100, 150, "UI Drawing Error: " + string(zone_drawing_error));
    }
    
    // Stylish neon VFX toggle button
    var vfx_toggle_button_x = 900;
    var vfx_toggle_button_y = 20;
    var vfx_toggle_button_width = 80;
    var vfx_toggle_button_height = 30;
    
    var vfx_status_text = "VFX: " + (aty_system.vfx.enabled ? "ON" : "OFF");
    draw_neon_button(vfx_toggle_button_x, vfx_toggle_button_y, vfx_toggle_button_x + vfx_toggle_button_width, vfx_toggle_button_y + vfx_toggle_button_height, 
                    vfx_status_text, false, false);
    
    // Beautiful neon notification display
    if (aty_system.notification.timer > 0) {
        draw_neon_panel(350, 20, 650, 60, "Уведомление");
        draw_set_color(user_interface_colors.neon_pink);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_text(500, 40, aty_system.notification.text);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
    }
    
    // Draw mini-game interface if active
    if (variable_struct_exists(aty_system, "minigame") && aty_system.minigame.active) {
        aty_draw_minigame();
    }
}
// =============================================================================
// UPDATED TAB DRAWING FUNCTIONS
// =============================================================================
function _aty_draw_tabs() {
    var aty = global.aty;
    var zones = aty.ui_zones;
    var colors = global.aty_colors;
    
    // БЕЗОПАСНАЯ ПРОВЕРКА: убеждаемся что current_tab существует
    var current_tab = variable_struct_exists(aty, "current_tab") ? aty.current_tab : TAB.HERO;
    
    // Фон вкладок в стиле dark fantasy
    draw_neon_panel(zones.tabs.x1, zones.tabs.y1, zones.tabs.x2, zones.tabs.y2, "");
    
    var tab_names = ["Герой", "Инвентарь", "Трофеи", "Способности", "Магазин", "Статистика", "Квесты", "Рейды"];
    var tab_width = 110;
    var tab_y = zones.tabs.y1 + 10;
    var tab_spacing = 5;
    
    // Неоновые вкладки
    for (var i = 0; i < 8; i++) {
        var tab_x = zones.tabs.x1 + 10 + i * (tab_width + tab_spacing);
        var is_active = (i == current_tab);
        
        draw_neon_button(tab_x, tab_y, tab_x + tab_width, tab_y + 30, tab_names[i], is_active, false);
    }
    
    // Содержимое вкладки
    var content_y = tab_y + 50;
    var content_zone = {
        x1: zones.tabs.x1 + 10,
        y1: content_y,
        x2: zones.tabs.x2 - 10,
        y2: zones.tabs.y2 - 10
    };
    
    // Рисуем панель содержимого с неоновой рамкой
    draw_neon_panel(content_zone.x1, content_zone.y1, content_zone.x2, content_zone.y2, "");
    
    // Включаем ограничение области отрисовки
    gpu_set_scissor(content_zone.x1, content_zone.y1, content_zone.x2 - content_zone.x1, content_zone.y2 - content_zone.y1);
    
    // Безопасная отрисовка содержимого вкладки
    try {
        switch (current_tab) {
            case TAB.HERO: _aty_draw_hero_tab(content_zone); break;
            case TAB.INVENTORY: _aty_draw_inventory_tab_unified(content_zone, false); break;
            case TAB.TROPHIES: _aty_draw_trophies_tab_enhanced(content_zone); break;
            case TAB.ABILITIES: _aty_draw_abilities_tab(content_zone); break;
            case TAB.SHOP: _aty_draw_shop_tab(content_zone); break;
            case TAB.STATISTICS: _aty_draw_statistics_tab(content_zone); break;
            case TAB.QUESTS: _aty_draw_quests_tab_enhanced(content_zone); break;
            case TAB.MINIRAIDS: _aty_draw_miniraids_tab(content_zone); break;
            default: _aty_draw_hero_tab(content_zone); break; // Вкладка по умолчанию
        }
    } catch (e) {
        show_debug_message("Error drawing tab content: " + string(e));
        draw_set_color(c_yellow);
        draw_text(content_zone.x1 + 10, content_zone.y1 + 10, "Error drawing tab: " + string(e));
    }
    
    // Сбрасываем ограничение области отрисовки
    gpu_set_scissor(false);
}

// Заменяем старые функции на унифицированные
function _aty_draw_inventory_tab(_zone) {
    _aty_draw_inventory_tab_unified(_zone, false);
}

function _aty_draw_inventory_tab_high_res(_zone) {
    _aty_draw_inventory_tab_unified(_zone, true);
}

function _aty_draw_available_quests_enhanced(_zone) {
    var quests = [];
    try {
        quests = aty_get_available_quests();
    } catch (e) {
        show_debug_message("Error getting available quests: " + string(e));
    }
    
    var safe_colors = _aty_get_safe_colors();
    var quest_y_position = _zone.y1 + 25;
    
    draw_set_font(global.aty_font_bold);
    draw_set_color(safe_colors.neon_blue);
    draw_text(_zone.x1 + 15, _zone.y1 + 10, "ДОСТУПНЫЕ ЗАДАНИЯ (" + string(array_length(quests)) + ")");
    
    if (array_length(quests) == 0) {
        _aty_draw_empty_state(_zone, "Нет доступных заданий", "Выполните требования для открытия новых квестов", safe_colors.text_muted);
        return;
    }
    
    for (var i = 0; i < array_length(quests); i++) {
        if (quest_y_position > _zone.y2 - 180) {
            _aty_draw_more_items_indicator(_zone, quest_y_position, array_length(quests) - i);
            break;
        }
        
        var quest = quests[i];
        quest_y_position = _aty_draw_quest_card_enhanced(_zone.x1, quest_y_position, _zone.x2, quest, false);
        quest_y_position += 15;
    }
}

function _aty_draw_weekly_quests_enhanced(_zone) {
    var quests = _aty_get_safe_quest_array("weekly_quests");
    var safe_colors = _aty_get_safe_colors();
    
    var quest_y_position = _zone.y1 + 15;
    
    // Заголовок с таймером
    draw_set_font(global.aty_font_bold);
    draw_set_color(safe_colors.neon_yellow);
    draw_text(_zone.x1 + 15, _zone.y1 + 10, "ЕЖЕНЕДЕЛЬНЫЕ ЗАДАНИЯ");
    
    // Таймер обновления
    var refresh_time = _aty_get_weekly_refresh_time();
    draw_set_font(global.aty_font_small);
    draw_set_color(safe_colors.neon_cyan);
    draw_text(_zone.x1 + 220, _zone.y1 + 12, "Обновление через: " + refresh_time);
    
    quest_y_position += 25;
    
    if (array_length(quests) == 0) {
        _aty_draw_empty_state(_zone, "Нет еженедельных заданий", "Еженедельные квесты обновляются каждый понедельник", safe_colors.text_muted);
        return;
    }
    
    for (var i = 0; i < array_length(quests); i++) {
        if (quest_y_position > _zone.y2 - 180) {
            _aty_draw_more_items_indicator(_zone, quest_y_position, array_length(quests) - i);
            break;
        }
        
        var quest = quests[i];
        quest_y_position = _aty_draw_quest_card_enhanced(_zone.x1, quest_y_position, _zone.x2, quest, false);
        quest_y_position += 15;
    }
}

function _aty_draw_failed_quests_enhanced(_zone) {
    var quests = _aty_get_safe_quest_array("failed_quests");
    var safe_colors = _aty_get_safe_colors();
    
    var quest_y_position = _zone.y1 + 25;
    
    draw_set_font(global.aty_font_bold);
    draw_set_color(safe_colors.error);
    draw_text(_zone.x1 + 15, _zone.y1 + 10, "ПРОВАЛЕННЫЕ ЗАДАНИЯ (" + string(array_length(quests)) + ")");
    
    if (array_length(quests) == 0) {
        _aty_draw_empty_state(_zone, "Нет проваленных заданий", "Отлично! Вы успешно справляетесь со всеми квестами", safe_colors.success);
        return;
    }
    
    for (var i = 0; i < array_length(quests); i++) {
        if (quest_y_position > _zone.y2 - 180) {
            _aty_draw_more_items_indicator(_zone, quest_y_position, array_length(quests) - i);
            break;
        }
        
        var quest = quests[i];
        quest_y_position = _aty_draw_quest_card_enhanced(_zone.x1, quest_y_position, _zone.x2, quest, false);
        quest_y_position += 15;
    }
}
function _aty_draw_miniraids_tab(_zone) {
    var colors = global.aty_colors;
    var raids = global.aty.miniraids;
    
    draw_set_color(colors.neon_blue);
    draw_text(_zone.x1 + 20, _zone.y1 + 20, "Мини-Рейдбоссы");
    
    var raid_y = _zone.y1 + 50;
    
    for (var i = 0; i < array_length(raids); i++) {
        var raid = raids[i];
        
        if (raid_y > _zone.y2 - 100) break;
        
        // Неоновая панель рейда
        draw_neon_panel(_zone.x1 + 20, raid_y, _zone.x2 - 20, raid_y + 90, "");
        
        // Статус рейда
        var status_color = colors.neon_cyan;
        var status_text = "Доступен";
        var can_start = global.aty.hero.level >= raid.required_level;
        
        if (!can_start) {
            status_color = colors.neon_red;
            status_text = "Требуется уровень " + string(raid.required_level);
        } else if (raid.state == RAID_STATE.IN_PROGRESS) {
            status_color = colors.neon_yellow;
            status_text = "В процессе: " + string(floor(global.aty.raids.timer)) + "с";
        } else if (raid.state == RAID_STATE.COMPLETED) {
            status_color = colors.neon_green;
            status_text = "Завершен";
        }
        
        // Информация о рейде
        draw_set_color(colors.neon_pink);
        draw_text(_zone.x1 + 30, raid_y + 10, raid.name);
        draw_set_color(colors.neon_cyan);
        draw_text(_zone.x1 + 30, raid_y + 30, raid.description);
        draw_set_color(status_color);
        draw_text(_zone.x1 + 30, raid_y + 50, status_text);
        
        // Награда
        draw_set_color(colors.neon_yellow);
        draw_text(_zone.x1 + 30, raid_y + 70, "Награда: " + string(raid.reward.gold) + " золота");
        
        // Кнопка старта
        if (can_start && raid.state == RAID_STATE.AVAILABLE && !global.aty.raids.active) {
            draw_neon_button(_zone.x2 - 120, raid_y + 25, _zone.x2 - 30, raid_y + 55, "Начать", false, false);
        }
        
        raid_y += 110;
    }
}

// =============================================================================
// HIGH-RESOLUTION RENDERING SYSTEM - ИСПРАВЛЕННАЯ
// =============================================================================

function aty_draw_ui_high_res() {
    // Безопасная инициализация цветов
    if (!variable_global_exists("aty_colors")) {
        aty_init_colors();
    }
    var colors = global.aty_colors;
    
    // Проверяем наличие необходимых цветов
    if (!variable_struct_exists(colors, "neon_grid")) colors.neon_grid = make_color_rgb(0, 100, 150);
    if (!variable_struct_exists(colors, "bg_dark")) colors.bg_dark = make_color_rgb(20, 20, 30);
    
    // Очищаем экран
    draw_clear_alpha(colors.bg_dark, 1);
    
    // Рисуем фон с сеткой (если это то, что нужно)
    draw_set_color(colors.neon_grid);
    draw_set_alpha(0.15);
    
    // Рисуем сетку (примерная реализация)
    var grid_size = 20;
    for (var xx = 0; xx < room_width; xx += grid_size) {
        draw_line(xx, 0, xx, room_height);
    }
    for (var yy = 0; yy < room_height; yy += grid_size) {
        draw_line(0, yy, room_width, yy);
    }
    
    draw_set_alpha(1);
    
    // Рисуем UI зоны
    var zones = global.aty.ui_zones;
    
    // Верхняя зона
    draw_set_color(colors.bg_medium);
    draw_rectangle(zones.top.x1, zones.top.y1, zones.top.x2, zones.top.y2, false);
    
    // Средняя зона
    draw_set_color(colors.bg_medium);
    draw_rectangle(zones.middle.x1, zones.middle.y1, zones.middle.x2, zones.middle.y2, false);
    
    // Нижняя зона (вкладки)
    draw_set_color(colors.bg_medium);
    draw_rectangle(zones.bottom.x1, zones.bottom.y1, zones.bottom.x2, zones.bottom.y2, false);
    
    // Рисуем вкладки
    _aty_draw_tabs_high_res();
    
    // Рисуем уведомления, если есть
    if (variable_struct_exists(global.aty, "notification") && global.aty.notification.timer > 0) {
        _aty_draw_notification();
    }
}
// =============================================================================
// HIGH-RESOLUTION HERO TAB DRAWING FUNCTION
// =============================================================================

function _aty_draw_hero_tab_high_res(_zone) {
    var scale = global.aty_render_scale;
    var colors = global.aty_colors;
    var hero = global.aty.hero;
    
    draw_set_color(colors.neon_blue);
    draw_text_ext(_zone.x1 + 20 * scale, _zone.y1 + 20 * scale, "Информация о Герое", -1, -1);
    
    // Основная статистика
    var stats_y = _zone.y1 + 50 * scale;
    draw_set_color(colors.neon_cyan);
    draw_text_ext(_zone.x1 + 20 * scale, stats_y, "Уровень: " + string(hero.level), -1, -1);
    draw_text_ext(_zone.x1 + 20 * scale, stats_y + 25 * scale, "Опыт: " + string(hero.exp) + "/" + string(hero.level * 200), -1, -1);
    draw_text_ext(_zone.x1 + 20 * scale, stats_y + 50 * scale, "Золото: " + string(hero.gold) + " G", -1, -1);
    draw_text_ext(_zone.x1 + 20 * scale, stats_y + 75 * scale, "Очки характеристик: " + string(hero.stat_points), -1, -1);
    draw_text_ext(_zone.x1 + 20 * scale, stats_y + 100 * scale, "Очки талантов: " + string(hero.talent_points), -1, -1);
    
    // ОСНОВНЫЕ ХАРАКТЕРИСТИКИ
    var base_x = _zone.x1 + 200 * scale;
    stats_y = _zone.y1 + 50 * scale;
    
    draw_set_color(colors.neon_pink);
    draw_text_ext(base_x, stats_y, "Основные характеристики:", -1, -1);
    draw_set_color(colors.neon_cyan);
    
    var base_stats = hero.base_stats;
    var stat_keys = ["strength", "agility", "intelligence", "vitality", "dexterity", "luck"];
    var stat_display_names = ["Сила", "Ловкость", "Интеллект", "Телосложение", "Меткость", "Удача"];
    
    for (var i = 0; i < 6; i++) {
        var stat_y = stats_y + 25 * scale + i * 25 * scale;
        var stat_value = variable_struct_get(base_stats, stat_keys[i]);
        draw_text_ext(base_x, stat_y, stat_display_names[i] + ": " + string(stat_value), -1, -1);
        
        // Рисуем кнопки "+" если есть очки характеристик
        if (hero.stat_points > 0 && stat_value < 100) {
            draw_neon_button_high_res(base_x + 120 * scale, stat_y - 5 * scale, 
                                    base_x + 140 * scale, stat_y + 15 * scale, "+", false, false);
        }
    }
    
    // ВТОРИЧНЫЕ ХАРАКТЕРИСТИКИ
    var sec_x = _zone.x1 + 350 * scale;
    stats_y = _zone.y1 + 50 * scale;
    
    draw_set_color(colors.neon_pink);
    draw_text_ext(sec_x, stats_y, "Боевые характеристики:", -1, -1);
    draw_set_color(colors.neon_green);
    
    var stats = hero.stats;
    var sec_stat_keys = [
        "health", "mana", "attack_power", "magic_power", "defense", 
        "crit_chance", "crit_damage", "attack_speed", "cast_speed",
        "dodge_chance", "block_chance", "lifesteal", "cooldown_reduction", "movement_speed"
    ];
    var sec_stat_display_names = [
        "Здоровье", "Мана", "Атака", "Магия", "Защита", 
        "Крит %", "Урон крита %", "Скор. атаки", "Скор. кастов",
        "Уклонение %", "Блок %", "Вампиризм %", "Сниж. КД %", "Скорость"
    ];
    
    for (var i = 0; i < 14; i++) {
        if (stats_y + 25 * scale + i * 20 * scale < _zone.y2 - 30 * scale) {
            var stat_value = variable_struct_get(stats, sec_stat_keys[i]);
            var display_value = stat_value;
            if (i >= 5 && i <= 12) { // Проценты
                display_value = string(stat_value) + "%";
            } else {
                display_value = string(stat_value);
            }
            draw_text_ext(sec_x, stats_y + 25 * scale + i * 20 * scale, 
                         sec_stat_display_names[i] + ": " + display_value, -1, -1);
        }
    }
    
    // СПЕЦИАЛИЗАЦИИ
    if (array_length(hero.specializations) > 0) {
        var spec_y = _zone.y1 + 200 * scale;
        draw_set_color(colors.neon_yellow);
        draw_text_ext(_zone.x1 + 20 * scale, spec_y, "Специализации:", -1, -1);
        
        for (var i = 0; i < array_length(hero.specializations); i++) {
            var spec_name = aty_get_spec_name(hero.specializations[i]);
            draw_set_color(colors.neon_green);
            draw_text_ext(_zone.x1 + 40 * scale, spec_y + 25 * scale + i * 20 * scale, 
                         "✓ " + spec_name, -1, -1);
        }
    }
}
// =============================================================================
// UPDATED CLICK HANDLING FOR HIGH-RES ATTRIBUTE UPGRADES
// =============================================================================

function _aty_handle_hero_tab_clicks_high_res(_mx, _my, _zone) {
    var hero = global.aty.hero;
    var scale = global.aty_render_scale;
    
    // Проверяем, есть ли очки для распределения
    if (hero.stat_points <= 0) return;
    
    var base_x = _zone.x1 + 200 * scale;
    var stats_y = _zone.y1 + 50 * scale;
    var stat_keys = ["strength", "agility", "intelligence", "vitality", "dexterity", "luck"];
    
    // Проверяем клики по кнопкам "+" для каждой характеристики
    for (var i = 0; i < array_length(stat_keys); i++) {
        var stat_y = stats_y + 25 * scale + i * 25 * scale;
        var button_x1 = base_x + 120 * scale;
        var button_y1 = stat_y - 5 * scale;
        var button_x2 = base_x + 140 * scale;
        var button_y2 = stat_y + 15 * scale;
        
        if (point_in_rectangle(_mx, _my, button_x1, button_y1, button_x2, button_y2)) {
            // Увеличиваем соответствующую характеристику
            aty_increase_stat(stat_keys[i]);
            return;
        }
    }
}
function _aty_draw_tabs_high_res() {
    var aty = global.aty;
    var zones = aty.ui_zones;
    var colors = global.aty_colors;
    
    // Безопасная проверка: убеждаемся что current_tab существует
    var current_tab = variable_struct_exists(aty, "current_tab") ? aty.current_tab : TAB.HERO;
    
    // Фон вкладок
    draw_set_color(colors.bg_light);
    draw_rectangle(zones.tabs.x1, zones.tabs.y1, zones.tabs.x2, zones.tabs.y2, false);
    
    var tab_names = ["Герой", "Инвентарь", "Трофеи", "Способности", "Магазин", "Статистика", "Квесты", "Рейды"];
    var tab_width = 110;
    var tab_y = zones.tabs.y1 + 10;
    var tab_spacing = 5;
    
    // Вкладки
    for (var i = 0; i < 8; i++) {
        var tab_x = zones.tabs.x1 + 10 + i * (tab_width + tab_spacing);
        var is_active = (i == current_tab);
        
        // Фон вкладки
        draw_set_color(is_active ? colors.accent : colors.bg_medium);
        draw_rectangle(tab_x, tab_y, tab_x + tab_width, tab_y + 30, false);
        
        // Текст вкладки
        draw_set_color(is_active ? colors.text_light : colors.text_primary);
        draw_set_font(global.aty_font_small);
        draw_text(tab_x + 5, tab_y + 8, tab_names[i]);
    }
    
    // Содержимое вкладки
    var content_y = tab_y + 50;
    var content_zone = {
        x1: zones.tabs.x1 + 10,
        y1: content_y,
        x2: zones.tabs.x2 - 10,
        y2: zones.tabs.y2 - 10
    };
    
    // Фон содержимого
    draw_set_color(colors.bg_light);
    draw_rectangle(content_zone.x1, content_zone.y1, content_zone.x2, content_zone.y2, false);
    
    // Включаем ограничение области отрисовки
    gpu_set_scissor(content_zone.x1, content_zone.y1, content_zone.x2 - content_zone.x1, content_zone.y2 - content_zone.y1);
    
    // Безопасная отрисовка содержимого вкладки
    try {
        switch (current_tab) {
            case TAB.HERO: _aty_draw_hero_tab(content_zone); break;
            case TAB.INVENTORY: _aty_draw_inventory_tab_unified(content_zone, true); break;
            case TAB.TROPHIES: _aty_draw_trophies_tab_enhanced(content_zone); break;
            case TAB.ABILITIES: _aty_draw_abilities_tab(content_zone); break;
            case TAB.SHOP: _aty_draw_shop_tab(content_zone); break;
            case TAB.STATISTICS: _aty_draw_statistics_tab(content_zone); break;
            case TAB.QUESTS: _aty_draw_quests_tab_enhanced(content_zone); break;
            case TAB.MINIRAIDS: _aty_draw_miniraids_tab(content_zone); break;
            default: _aty_draw_hero_tab(content_zone); break;
        }
    } catch (e) {
        show_debug_message("Error drawing tab content (high res): " + string(e));
        draw_set_color(colors.error);
        draw_text(content_zone.x1 + 10, content_zone.y1 + 10, "Error drawing tab: " + string(e));
    }
    
    // Сбрасываем ограничение области отрисовки
    gpu_set_scissor(false);
}
function _aty_draw_trophies_tab_safe(_zone) {
    // АБСОЛЮТНО БЕЗОПАСНАЯ ПРОВЕРКА ИНИЦИАЛИЗАЦИИ
    if (!variable_struct_exists(global, "aty")) {
        global.aty = {};
    }
    if (!variable_struct_exists(global.aty, "trophies")) {
        global.aty.trophies = {
            unlocked: [],
            progress: {},
            bonuses: {},
            total_score: 0
        };
    }
    if (!variable_struct_exists(global.aty, "current_trophy_category")) {
        global.aty.current_trophy_category = TROPHY_CATEGORY.COMBAT;
    }
    if (!variable_struct_exists(global.aty, "trophy_ui")) {
        global.aty.trophy_ui = {
            scroll_offset: 0,
            selected_trophy: -1,
            animation_timer: 0,
            pulse_effect: 0
        };
    }
    
    var colors = global.aty_colors;
    var ui = global.aty.trophy_ui;
    
    try {
        // САМЫЙ ПРОСТОЙ ФОН
        draw_set_color(colors.bg_dark);
        draw_rectangle(_zone.x1, _zone.y1, _zone.x2, _zone.y2, false);
        
        // ЗАГОЛОВОК
        draw_set_color(colors.neon_blue);
        draw_text(_zone.x1 + 20, _zone.y1 + 20, "🏆 ТРОФЕИ");
        
        // ПРОСТАЯ СТАТИСТИКА
        var stats = global.aty.trophies;
        var total_trophies = array_length(aty_get_trophy_database());
        var unlocked_count = variable_struct_exists(stats, "unlocked") ? array_length(stats.unlocked) : 0;
        
        draw_set_color(colors.text_primary);
        draw_text(_zone.x1 + 20, _zone.y1 + 50, "Разблокировано: " + string(unlocked_count) + "/" + string(total_trophies));
        
        // ПРОСТЫЕ КАТЕГОРИИ
        var category_y = _zone.y1 + 80;
        var categories = [
            { name: "⚔️ Боевые", key: TROPHY_CATEGORY.COMBAT },
            { name: "🗺️ Исследования", key: TROPHY_CATEGORY.EXPLORATION },
            { name: "🎒 Коллекции", key: TROPHY_CATEGORY.COLLECTION },
            { name: "⚒️ Крафт", key: TROPHY_CATEGORY.CRAFTING },
            { name: "🌟 Особые", key: TROPHY_CATEGORY.SPECIAL }
        ];
        
        for (var i = 0; i < array_length(categories); i++) {
            var cat = categories[i];
            var is_active = (global.aty.current_trophy_category == cat.key);
            var btn_x = _zone.x1 + 20 + i * 120;
            
            // Простая кнопка
            draw_set_color(is_active ? colors.neon_blue : colors.bg_medium);
            draw_rectangle(btn_x, category_y, btn_x + 110, category_y + 30, false);
            
            draw_set_color(is_active ? colors.text_primary : colors.text_secondary);
            draw_text(btn_x + 5, category_y + 8, cat.name);
            
            // Обработка клика
            if (point_in_rectangle(mouse_x, mouse_y, btn_x, category_y, btn_x + 110, category_y + 30) && 
                mouse_check_button_pressed(mb_left)) {
                global.aty.current_trophy_category = cat.key;
                ui.selected_trophy = -1;
            }
        }
        
        // ПРОСТОЙ СПИСОК ТРОФЕЕВ
        var list_y = category_y + 50;
        var trophies = aty_get_trophies_by_category(global.aty.current_trophy_category);
        
        // Ограничиваем зону отрисовки
        gpu_set_scissor(_zone.x1 + 20, list_y, _zone.x2 - _zone.x1 - 40, _zone.y2 - list_y - 20);
        
        for (var i = 0; i < array_length(trophies); i++) {
            if (list_y > _zone.y2 - 50) break;
            
            var trophy = trophies[i];
            _aty_draw_trophy_item_simple(_zone.x1 + 20, list_y, _zone.x2 - 20, list_y + 60, trophy);
            list_y += 70;
        }
        
        gpu_set_scissor(false);
        
    } catch (e) {
        // ЕСЛИ ЧТО-ТО ПОШЛО НЕ ТАК
        draw_set_color(c_red);
        draw_text(_zone.x1 + 20, _zone.y1 + 20, "ОШИБКА ТРОФЕЕВ");
        draw_text(_zone.x1 + 20, _zone.y1 + 40, "Сообщите разработчику");
    }
}
// Улучшенная функция фона с частицами
function _aty_draw_trophy_background(_zone) {
    var colors = global.aty_colors;
    
    // Основной градиентный фон
    draw_set_gradient_color(colors.bg_dark, colors.bg_darker, 0);
    draw_rectangle(_zone.x1, _zone.y1, _zone.x2, _zone.y2, false);
    
    // Блестящие частицы
    var time = current_time * 0.001;
    for (var i = 0; i < 5; i++) {
        if (random(1) < 0.02) {
            var particle_x = _zone.x1 + random(_zone.x2 - _zone.x1);
            var particle_y = _zone.y1 + random(_zone.y2 - _zone.y1);
            var particle_size = random_range(1, 2);
            var alpha = random_range(0.3, 0.8);
            var particle_color = merge_color(colors.neon_blue, c_white, random(1));
            draw_set_alpha(alpha);
            draw_set_color(particle_color);
            draw_circle(particle_x, particle_y, particle_size, false);
            draw_set_alpha(1);
        }
    }
}
function aty_add_random_trophy() {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) {
        show_debug_message("ERROR: ATY system not initialized");
        return false;
    }
    
    // Безопасная проверка структуры трофеев
    if (!variable_struct_exists(global.aty, "trophies") || !is_struct(global.aty.trophies)) {
        show_debug_message("ERROR: Trophies system not initialized");
        return false;
    }
    
    var trophy_db = aty_get_trophy_database();
    if (!is_array(trophy_db) || array_length(trophy_db) == 0) {
        aty_show_notification("❌ База данных трофеев пуста!");
        return false;
    }
    
    // Собираем доступные для разблокировки трофеи
    var available_trophies = [];
    for (var i = 0; i < array_length(trophy_db); i++) {
        var trophy = trophy_db[i];
        if (is_struct(trophy) && variable_struct_exists(trophy, "id")) {
            if (!aty_has_trophy(trophy.id)) {
                array_push(available_trophies, trophy);
            }
        }
    }
    
    if (array_length(available_trophies) == 0) {
        aty_show_notification("🎉 Все трофеи уже разблокированы!");
        return true;
    }
    
    // Выбираем случайный трофей
    var random_index = irandom(array_length(available_trophies) - 1);
    var selected_trophy = available_trophies[random_index];
    
    // Разблокируем трофей
    aty_unlock_trophy(selected_trophy.id);
    
    return true;
}

function aty_start_random_quest() {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) {
        show_debug_message("ERROR: ATY system not initialized");
        return false;
    }
    
    // Безопасная проверка структуры квестов
    if (!variable_struct_exists(global.aty, "quests") || !is_struct(global.aty.quests)) {
        show_debug_message("ERROR: Quests system not initialized");
        return false;
    }
    
    var available_quests = aty_get_available_quests();
    if (!is_array(available_quests) || array_length(available_quests) == 0) {
        aty_show_notification("❌ Нет доступных квестов!");
        return false;
    }
    
    // Выбираем случайный квест
    var random_index = irandom(array_length(available_quests) - 1);
    var selected_quest = available_quests[random_index];
    
    // Начинаем квест
    var success = aty_start_quest(selected_quest.id);
    
    if (success) {
        aty_show_notification("📜 Квест начат: " + selected_quest.name);
    } else {
        aty_show_notification("❌ Не удалось начать квест!");
    }
    
    return success;
}

function aty_handle_start_quest_click(_mx, _my, _zone) {
    // Проверяем клик по кнопке "Начать квест" в зоне квестов
    var button_x1 = _zone.x1 + 20;
    var button_y1 = _zone.y1 + 120;
    var button_x2 = _zone.x1 + 170;
    var button_y2 = _zone.y1 + 160;
    
    if (point_in_rectangle(_mx, _my, button_x1, button_y1, button_x2, button_y2)) {
        aty_start_random_quest();
        return true;
    }
    
    return false;
}

function aty_handle_special_tabs_clicks(_mx, _my, _zone, _tab_type) {
    if (_tab_type == "trophies") {
        return aty_handle_add_trophy_click(_mx, _my, _zone);
    } else if (_tab_type == "quests") {
        return aty_handle_start_quest_click(_mx, _my, _zone);
    }
    
    return false;
}

function aty_handle_add_trophy_click(_mx, _my, _zone) {
    // Проверяем клик по кнопке "Добавить трофей"
    var button_x1 = _zone.x1 + 20;
    var button_y1 = _zone.y1 + 50;
    var button_x2 = _zone.x1 + 170;
    var button_y2 = _zone.y1 + 90;
    
    if (point_in_rectangle(_mx, _my, button_x1, button_y1, button_x2, button_y2)) {
        aty_add_random_trophy();
        return true;
    }
    
    return false;
}

function _aty_draw_quests_tab_enhanced(_zone) {
    // Безопасная инициализация
    if (!variable_global_exists("aty_colors")) aty_init_colors();
    var colors = global.aty_colors;
    
    // Проверяем наличие необходимых цветов
    var safe_colors = _aty_get_safe_colors();
    
    // Заголовок и статистика
    var header_height = 70;
    var categories_height = 45;
    
    // Рисуем фон вкладки
    draw_set_color(safe_colors.bg_medium);
    draw_rectangle(_zone.x1, _zone.y1, _zone.x2, _zone.y2, false);
    
    // Рисуем заголовок с градиентом
    _aty_draw_panel_header(_zone.x1, _zone.y1, _zone.x2, _zone.y1 + header_height, "Журнал Заданий", safe_colors.accent);
    
    // Получаем статистику безопасно
    var quest_stats = _aty_get_quest_stats();
    
    // Рисуем статистику квестов
    draw_set_font(global.aty_font_small);
    draw_set_color(safe_colors.text_secondary);
    var stats_x = _zone.x1 + 20;
    var stats_y = _zone.y1 + 45;
    
    draw_text(stats_x, stats_y, "Выполнено: " + string(quest_stats.total_completed));
    draw_text(stats_x + 150, stats_y, "Активные: " + string(quest_stats.active_count));
    draw_text(stats_x + 280, stats_y, "Доступные: " + string(quest_stats.available_count));
    
    // Рисуем категории квестов
    var categories = ["АКТИВНЫЕ", "ЕЖЕДНЕВНЫЕ", "ЕЖЕНЕДЕЛЬНЫЕ", "ДОСТУПНЫЕ", "ЗАВЕРШЁННЫЕ", "ПРОВАЛЕННЫЕ"];
    var category_icons = ["▶", "📅", "📆", "✅", "🏆", "❌"];
    var category_width = (_zone.x2 - _zone.x1) / array_length(categories);
    var category_y = _zone.y1 + header_height;
    
    for (var i = 0; i < array_length(categories); i++) {
        var category_x1 = _zone.x1 + i * category_width;
        var category_x2 = category_x1 + category_width;
        var is_active = (global.aty.current_quest_category == i);
        
        // Фон категории
        var category_color = is_active ? safe_colors.accent : safe_colors.bg_light;
        draw_set_color(category_color);
        draw_rectangle(category_x1, category_y, category_x2, category_y + categories_height, false);
        
        // Граница категории
        draw_set_color(is_active ? safe_colors.accent_light : safe_colors.border);
        draw_rectangle(category_x1, category_y, category_x2, category_y + categories_height, true);
        
        // Иконка и текст категории
        draw_set_color(is_active ? safe_colors.text_light : safe_colors.text_primary);
        draw_set_font(global.aty_font_small);
        
        var icon_x = category_x1 + (category_width / 2) - 20;
        var text_x = category_x1 + (category_width / 2);
        
        draw_text(icon_x, category_y + 15, category_icons[i]);
        draw_text_centered(text_x, category_y + 30, categories[i]);
    }
    
    // Область контента
    var content_zone = {
        x1: _zone.x1 + 5,
        y1: category_y + categories_height + 5,
        x2: _zone.x2 - 5,
        y2: _zone.y2 - 5
    };
    
    // Рисуем фон контента
    draw_set_color(safe_colors.bg_light);
    draw_rectangle(content_zone.x1, content_zone.y1, content_zone.x2, content_zone.y2, false);
    
    // Включаем ограничение области отрисовки
    gpu_set_scissor(content_zone.x1, content_zone.y1, content_zone.x2 - content_zone.x1, content_zone.y2 - content_zone.y1);
    
    // Безопасная отрисовка содержимого в зависимости от выбранной категории
    try {
        switch (global.aty.current_quest_category) {
            case 0: _aty_draw_active_quests_enhanced(content_zone); break;
            case 1: _aty_draw_daily_quests_enhanced(content_zone); break;
            case 2: _aty_draw_weekly_quests_enhanced(content_zone); break;
            case 3: _aty_draw_available_quests_enhanced(content_zone); break;
            case 4: _aty_draw_completed_quests_enhanced(content_zone); break;
            case 5: _aty_draw_failed_quests_enhanced(content_zone); break;
            default: _aty_draw_active_quests_enhanced(content_zone); break;
        }
    } catch (e) {
        show_debug_message("Error drawing quests content: " + string(e));
        draw_set_color(safe_colors.error);
        draw_text(content_zone.x1 + 20, content_zone.y1 + 20, "Ошибка загрузки квестов: " + string(e));
    }
    
    // Сбрасываем ограничение области отрисовки
    gpu_set_scissor(false);
}

function _aty_draw_active_quests_enhanced(_zone) {
    var quests = _aty_get_safe_quest_array("active_quests");
    var safe_colors = _aty_get_safe_colors();
    
    var quest_y_position = _zone.y1 + 15;
    
    if (array_length(quests) == 0) {
        _aty_draw_empty_state(_zone, "Нет активных заданий", "Начните новый квест из вкладки 'Доступные'", safe_colors.text_muted);
        return;
    }
    
    draw_set_font(global.aty_font_bold);
    draw_set_color(safe_colors.text_primary);
    draw_text(_zone.x1 + 15, _zone.y1 + 10, "АКТИВНЫЕ ЗАДАНИЯ (" + string(array_length(quests)) + ")");
    
    for (var i = 0; i < array_length(quests); i++) {
        if (quest_y_position > _zone.y2 - 180) {
            _aty_draw_more_items_indicator(_zone, quest_y_position, array_length(quests) - i);
            break;
        }
        
        var quest = quests[i];
        quest_y_position = _aty_draw_quest_card_enhanced(_zone.x1, quest_y_position, _zone.x2, quest, true);
        quest_y_position += 15;
    }
}

// Обновляем функцию отрисовки для безопасной проверки:
function _aty_draw_middle_zone() {
    var zones = global.aty.ui_zones;
    var colors = global.aty_colors;
    
    // Проверяем активен ли рейд-босс
    if (variable_struct_exists(global.aty, "raid_boss") && global.aty.raid_boss.active) {
        aty_draw_raid_boss_ui();
        return; // Не рисуем стандартный интерфейс экспедиции
    }
    
    // Фон с параллакс-эффектом
    draw_set_color(colors.bg_medium);
    draw_rectangle(zones.middle.x1, zones.middle.y1, zones.middle.x2, zones.middle.y2, false);
    
    // Параллакс слои
    var time = global.aty.vfx.time;
    
    // Слой 1 - дальние звезды
    draw_set_color(colors.neon_cyan);
    draw_set_alpha(0.3);
    for (var i = 0; i < 20; i++) {
        var xx = zones.middle.x1 + (sin(time * 0.5 + i) * 50 + i * 40) mod (zones.middle.x2 - zones.middle.x1);
        var yy = zones.middle.y1 + (cos(time * 0.3 + i) * 30 + i * 35) mod (zones.middle.y2 - zones.middle.y1);
        draw_circle(xx, yy, 1, false);
    }
    
    // Слой 2 - средние элементы
    draw_set_color(colors.neon_purple);
    draw_set_alpha(0.5);
    for (var i = 0; i < 15; i++) {
        var xx = zones.middle.x1 + (sin(time * 0.8 + i * 2) * 80 + i * 60) mod (zones.middle.x2 - zones.middle.x1);
        var yy = zones.middle.y1 + (cos(time * 0.6 + i * 2) * 50 + i * 45) mod (zones.middle.y2 - zones.middle.y1);
        draw_rectangle(xx, yy, xx + 3, yy + 3, false);
    }
    
    // Слой 3 - ближние элементы
    draw_set_color(colors.neon_pink);
    draw_set_alpha(0.7);
    for (var i = 0; i < 10; i++) {
        var xx = zones.middle.x1 + (sin(time * 1.2 + i * 3) * 120 + i * 80) mod (zones.middle.x2 - zones.middle.x1);
        var yy = zones.middle.y1 + (cos(time * 1.0 + i * 3) * 70 + i * 60) mod (zones.middle.y2 - zones.middle.y1);
        draw_rectangle(xx - 2,yy - 2, xx + 2, yy + 2, false);
    }
    
    draw_set_alpha(1);
    
    // Контент в зависимости от состояния
    if (global.aty.expedition.active) {
        _aty_draw_expedition_progress();
    } else {
        _aty_draw_idle_state();
    }
    
    // VFX поверх всего
    aty_vfx_draw(zones.middle.x1, zones.middle.y1, 
                 zones.middle.x2 - zones.middle.x1, 
                 zones.middle.y2 - zones.middle.y1,
                 global.aty.expedition.progress);
}

// Добавляем функцию для отображения прогресса экспедиции с более детальной информацией
function _aty_draw_expedition_progress() {
    var zones = global.aty.ui_zones;
    var colors = global.aty_colors;
    var middle_zone = zones.middle;
    
    var center_x = (middle_zone.x1 + middle_zone.x2) / 2;
    var center_y = (middle_zone.y1 + middle_zone.y2) / 2;
    
    var expedition = global.aty.expeditions[global.aty.current_expedition];
    
    // Панель прогресса экспедиции
    draw_neon_panel(center_x - 200, center_y - 120, center_x + 200, center_y + 120, "Экспедиция: " + expedition.name);
    
    // Информация об экспедиции
    draw_set_color(colors.neon_cyan);
    draw_set_halign(fa_center);
    draw_text(center_x, center_y - 80, "Сложность: Уровень " + string(expedition.difficulty));
    draw_text(center_x, center_y - 60, "Требуемый уровень: " + string(expedition.required_level));
    draw_text(center_x, center_y - 40, "Награда: " + string(expedition.gold_reward) + " золота");
    
    // Полоса прогресса
    var bar_width = 350;
    var bar_height = 25;
    var bar_x = center_x - bar_width / 2;
    var bar_y = center_y - 10;
    
    // Фон полосы
    draw_set_color(colors.bg_light);
    draw_rectangle(bar_x, bar_y, bar_x + bar_width, bar_y + bar_height, false);
    
    // Заполнение
    var progress = global.aty.expedition.progress;
    draw_set_color(colors.neon_green);
    draw_rectangle(bar_x, bar_y, bar_x + bar_width * progress, bar_y + bar_height, false);
    
    // Рамка
    draw_set_color(colors.neon_blue);
    draw_rectangle(bar_x, bar_y, bar_x + bar_width, bar_y + bar_height, true);
    
    // Текст прогресса
    draw_set_color(colors.text_primary);
    draw_text(center_x, bar_y - 25, "Прогресс: " + string(floor(progress * 100)) + "%");
    draw_text(center_x, bar_y + 30, "Осталось: " + string(ceil(global.aty.expedition.timer)) + "с");
    
    // Специальное событие
    if (global.aty.expedition.special_event) {
        draw_set_color(colors.neon_yellow);
        draw_text(center_x, center_y + 60, "⚡ Произошло что-то интересное! ⚡");
    }
    
    // Активные баффы во время экспедиции
    if (array_length(global.aty.expedition.active_buffs) > 0) {
        draw_set_color(colors.neon_purple);
        draw_text(center_x, center_y + 90, "Активные баффы:");
        
        var buff_y = center_y + 110;
        for (var i = 0; i < array_length(global.aty.expedition.active_buffs); i++) {
            var buff = global.aty.expedition.active_buffs[i];
            draw_set_color(colors.neon_cyan);
            draw_text(center_x, buff_y, "• " + buff.name + " - " + buff.description);
            buff_y += 20;
        }
    }
    
    draw_set_halign(fa_left);
}
// Обновляем функцию _aty_draw_idle_state() для отображения кнопки 6 уровня:
function _aty_draw_idle_state() {
    var zones = global.aty.ui_zones;
    var colors = global.aty_colors;
    var middle_zone = zones.middle;
    
    var center_x = (middle_zone.x1 + middle_zone.x2) / 2;
    var center_y = (middle_zone.y1 + middle_zone.y2) / 2;
    
    draw_set_color(colors.neon_cyan);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    
    draw_text(center_x, center_y - 100, "🏰 Главный Лагерь 🏰");
    draw_set_color(colors.text_secondary);
    draw_text(center_x, center_y - 70, "Отряд отдыхает и готовится");
    draw_text(center_x, center_y - 50, "к новым приключениям");
    
    // Отображение активных баффов
    if (variable_struct_exists(global.aty.expedition, "active_buffs") && 
        array_length(global.aty.expedition.active_buffs) > 0) {
        draw_set_color(colors.neon_green);
        draw_text(center_x, center_y - 20, "Активные баффы:");
        
        var buff_y = center_y + 10;
        for (var i = 0; i < array_length(global.aty.expedition.active_buffs); i++) {
            var buff = global.aty.expedition.active_buffs[i];
            draw_set_color(colors.neon_cyan);
            draw_text(center_x, buff_y, "• " + buff.name);
            buff_y += 20;
        }
    }


    // Кнопки выбора экспедиций - ДОБАВЛЕНА КНОПКА РЕЙД-БОССА
    draw_set_color(colors.neon_pink);
    draw_text(center_x, center_y + 60, "Выберите экспедицию:");
    
    var expedition_button_width = 150;
    var expedition_button_height = 40;
    var expedition_spacing = 20;
    var total_width = 6 * expedition_button_width + 5 * expedition_spacing; // Изменено с 5 на 6
    var start_x = center_x - total_width / 2;
    var button_y = center_y + 100;
    
    // Обычные экспедиции (уровни 1-5)
    for (var i = 1; i <= 5; i++) {
        var button_x = start_x + (i-1) * (expedition_button_width + expedition_spacing);
        var expedition = global.aty.expeditions[i-1];
        var can_start = global.aty.hero.level >= expedition.required_level;
        var is_completed = expedition.completed;
        
        var button_text = "Ур. " + string(i);
        if (!can_start) {
            button_text += "\nТреб. ур. " + string(expedition.required_level);
        }
        
        var button_color = colors.neon_blue;
        if (!can_start) {
            button_color = colors.neon_red;
        } else if (is_completed) {
            button_color = colors.neon_green;
        }
        
        draw_neon_button(button_x, button_y, 
                        button_x + expedition_button_width, 
                        button_y + expedition_button_height, 
                        button_text, false, !can_start);
        
        draw_set_color(colors.neon_cyan);
        draw_set_halign(fa_center);
        draw_text(button_x + expedition_button_width/2, button_y + expedition_button_height + 15, 
                 expedition.name);
        draw_set_color(colors.neon_yellow);
        draw_text(button_x + expedition_button_width/2, button_y + expedition_button_height + 30, 
                 "Награда: " + string(expedition.gold_reward) + " золота");
        draw_set_color(colors.text_secondary);
        draw_text(button_x + expedition_button_width/2, button_y + expedition_button_height + 45, 
                 "Длительность: " + string(expedition.duration) + "с");
    }
    
    // КНОПКА РЕЙД-БОССА (уровень 6)
    var raid_button_x = start_x + 5 * (expedition_button_width + expedition_spacing);
    var raid_expedition = global.aty.expeditions[5]; // 6-я экспедиция (индекс 5)
    
    // ПРЯМАЯ ПРОВЕРКА УСЛОВИЙ ДОСТУПА К РЕЙД-БОССУ
    var raid_unlocked = true;
    for (var j = 0; j < 5; j++) {
        if (!global.aty.expeditions[j].completed) {
            raid_unlocked = false;
            break;
        }
    }
    var raid_can_start = global.aty.hero.level >= raid_expedition.required_level && raid_unlocked;
    
    var raid_button_color = raid_can_start ? colors.neon_purple : colors.neon_red;
    var raid_button_text = "Ур. 6\nРЕЙД-БОСС";
    if (!raid_can_start) {
        if (!raid_unlocked) {
            raid_button_text += "\nТребуются все\nпред. экспедиции";
        } else {
            raid_button_text += "\nТреб. ур. " + string(raid_expedition.required_level);
        }
    }
    
    draw_neon_button(raid_button_x, button_y, 
                    raid_button_x + expedition_button_width, 
                    button_y + expedition_button_height, 
                    raid_button_text, false, !raid_can_start);
    
    draw_set_color(colors.neon_purple);
    draw_set_halign(fa_center);
    draw_text(raid_button_x + expedition_button_width/2, button_y + expedition_button_height + 15, 
             raid_expedition.name);
    draw_set_color(colors.neon_yellow);
    draw_text(raid_button_x + expedition_button_width/2, button_y + expedition_button_height + 30, 
             "Награда: " + string(raid_expedition.gold_reward) + " золота");
    draw_set_color(colors.text_secondary);
    draw_text(raid_button_x + expedition_button_width/2, button_y + expedition_button_height + 45, 
             "Длительность: " + string(raid_expedition.duration) + "с");
    
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

function _aty_draw_miniraids_tab_high_res(_zone) {
    var colors = global.aty_colors;
    var raids = global.aty.miniraids;
    var scale = global.aty_render_scale;
    
    draw_set_color(colors.neon_blue);
    draw_text_ext(_zone.x1 + 20 * scale, _zone.y1 + 20 * scale, "Мини-Рейдбоссы", -1, -1);
    
    var raid_y = _zone.y1 + 50 * scale;
    
    for (var i = 0; i < array_length(raids); i++) {
        var raid = raids[i];
        
        if (raid_y > _zone.y2 - 100 * scale) break;
        
        // Неоновая панель рейда
        draw_neon_panel_high_res(_zone.x1 + 20 * scale, raid_y, _zone.x2 - 20 * scale, raid_y + 90 * scale, "");
        
        // Статус рейда
        var status_color = colors.neon_cyan;
        var status_text = "Доступен";
        var can_start = global.aty.hero.level >= raid.required_level;
        
        if (!can_start) {
            status_color = colors.neon_red;
            status_text = "Требуется уровень " + string(raid.required_level);
        } else if (raid.state == RAID_STATE.IN_PROGRESS) {
            status_color = colors.neon_yellow;
            status_text = "В процессе: " + string(floor(global.aty.raids.timer)) + "с";
        } else if (raid.state == RAID_STATE.COMPLETED) {
            status_color = colors.neon_green;
            status_text = "Завершен";
        }
        
        // Информация о рейде
        draw_set_color(colors.neon_pink);
        draw_text_ext(_zone.x1 + 30 * scale, raid_y + 10 * scale, raid.name, -1, -1);
        draw_set_color(colors.neon_cyan);
        draw_text_ext(_zone.x1 + 30 * scale, raid_y + 30 * scale, raid.description, -1, -1);
        draw_set_color(status_color);
        draw_text_ext(_zone.x1 + 30 * scale, raid_y + 50 * scale, status_text, -1, -1);
        
        // Награда
        draw_set_color(colors.neon_yellow);
        draw_text_ext(_zone.x1 + 30 * scale, raid_y + 70 * scale, "Награда: " + string(raid.reward.gold) + " золота", -1, -1);
        
        // Кнопка старта
        if (can_start && raid.state == RAID_STATE.AVAILABLE && !global.aty.raids.active) {
            draw_neon_button_high_res(_zone.x2 - 120 * scale, raid_y + 25 * scale, 
                                    _zone.x2 - 30 * scale, raid_y + 55 * scale, "Начать", false, false);
        }
        
        raid_y += 110 * scale;
    }
}

// =============================================================================
// ОБРАБОТКА КЛИКОВ ДЛЯ НОВЫХ СИСТЕМ
// =============================================================================
// В функции aty_handle_click() обновляем обработку клика для рейд-босса:
function aty_handle_click(_mx, _my, _button) {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) return;
	var scale = global.aty_render_scale;
    var zones = global.aty.ui_zones;
    
    // Обработка ЛЕВОЙ кнопки мыши (стандартные действия)
    if (_button == mb_left) {
        // 1. Проверка клика по кнопке VFX в верхней части экрана
        if (point_in_rectangle(_mx, _my, 900, 20, 980, 50)) {
            aty_vfx_toggle();
            return;
        }
        
        // 2. Проверка кликов по вкладкам
        if (point_in_rectangle(_mx, _my, zones.tabs.x1, zones.tabs.y1, zones.tabs.x2, zones.tabs.y2)) {
            var tab_width = 110;
            var tab_spacing = 5;
            var tab_y = zones.tabs.y1 + 10;
			    if (point_in_rectangle(_mx, _my, zones.tabs.x1, zones.tabs.y1, zones.tabs.x2, zones.tabs.y2)) {
        var content_y = tab_y + 50;
        var content_zone = {
            x1: zones.tabs.x1 + 10,
            y1: content_y,
            x2: zones.tabs.x2 - 10,
            y2: zones.tabs.y2 - 10
        };
        
        // Обработка кликов в зависимости от активной вкладки
        switch (global.aty.current_tab) {
            case TAB.TROPHIES:
                if (aty_handle_special_tabs_clicks(_mx, _my, content_zone, "trophies")) {
                    return;
                }
                break;
                
            case TAB.QUESTS:
                if (aty_handle_special_tabs_clicks(_mx, _my, content_zone, "quests")) {
                    return;
                }
                break;
        }
    }
    
            
            // Проверка кликов по самим вкладкам
            for (var i = 0; i < 8; i++) {
                var tab_x = zones.tabs.x1 + 10 + i * (tab_width + tab_spacing);
                if (point_in_rectangle(_mx, _my, tab_x, tab_y, tab_x + tab_width, tab_y + 30)) {
                    global.aty.current_tab = i;
                    return;
                }
            }
            
            // 3. Проверка кликов по контенту активной вкладки
            var content_y = tab_y + 50;
            var content_zone = {
                x1: zones.tabs.x1 + 10,
                y1: content_y,
                x2: zones.tabs.x2 - 10,
                y2: zones.tabs.y2 - 10
            };
            
            // Для высокого разрешения используем масштабированные координаты
            var scaled_mx = _mx;
            var scaled_my = _my;
            var scaled_content_zone = content_zone;
            
            if (global.aty_high_res) {
                scaled_mx = _mx / scale;
                scaled_my = _my / scale;
                scaled_content_zone = {
                    x1: content_zone.x1 / scale,
                    y1: content_zone.y1 / scale,
                    x2: content_zone.x2 / scale,
                    y2: content_zone.y2 / scale
                };
            }
            
            switch (global.aty.current_tab) {
                case TAB.HERO:
                    // Обработка кликов по кнопкам прокачки атрибутов
                    if (global.aty_high_res) {
                        _aty_handle_hero_tab_clicks_high_res(scaled_mx, scaled_my, scaled_content_zone);
                    } else {
                        _aty_handle_hero_tab_clicks(_mx, _my, content_zone);
                    }
                    break;
                    
                case TAB.INVENTORY:
                    var click_result = -1;
                    
                    if (global.aty_high_res) {
                        // Для высокого разрешения - масштабируем координаты
                        var scaled_mx = _mx / global.aty_render_scale;
                        var scaled_my = _my / global.aty_render_scale;
                        var scaled_content_zone = {
                            x1: content_zone.x1 / global.aty_render_scale,
                            y1: content_zone.y1 / global.aty_render_scale,
                            x2: content_zone.x2 / global.aty_render_scale,
                            y2: content_zone.y2 / global.aty_render_scale
                        };
                        click_result = _aty_handle_inventory_clicks_high_res(scaled_mx, scaled_my, scaled_content_zone);
                    } else {
                        // Для обычного разрешения
                        click_result = _aty_handle_inventory_clicks(_mx, _my, content_zone);
                    }
                    
                    // Обработка результатов клика
                    if (click_result != -1) {
                        if (click_result == true) {
                            // Клик обработан (фильтры/сортировка)
                            return;
                        } else if (is_real(click_result)) {
                            // Клик по предмету - click_result содержит индекс предмета
                            var item_index = click_result;
                            if (_button == mb_left) {
                                // ЛКМ - экипировать предмет
                                aty_equip_item(item_index);
                            } else if (_button == mb_right) {
                                // ПКМ - продать предмет
                                aty_sell_item(item_index);
                            }
                            return;
                        }
                    }
                    break;
                    
                case TAB.TROPHIES:
                    // Кнопка добавления трофея - ИСПРАВЛЕННАЯ ВЕРСИЯ
                    if (point_in_rectangle(_mx, _my, content_zone.x1 + 20, content_zone.y1 + 50, 
                                         content_zone.x1 + 170, content_zone.y1 + 90)) {
                        // Используем правильную систему разблокировки трофеев
                        var trophy_db = aty_get_trophy_database();
                        if (array_length(trophy_db) > 0) {
                            // Выбираем случайный трофей из базы данных, который еще не разблокирован
                            var available_trophies = [];
                            for (var i = 0; i < array_length(trophy_db); i++) {
                                if (!aty_has_trophy(trophy_db[i].id)) {
                                    array_push(available_trophies, trophy_db[i]);
                                }
                            }
                            
                            if (array_length(available_trophies) > 0) {
                                var random_index = irandom(array_length(available_trophies) - 1);
                                var random_trophy = available_trophies[random_index];
                                
                                // Разблокируем трофей через систему трофеев
                                aty_unlock_trophy(random_trophy.id);
                            } else {
                                aty_show_notification("Все трофеи уже разблокированы!");
                            }
                        }
                        return true;
                    }
                    
                    // Обработка кликов по категориям трофеев
                    var category_y = content_zone.y1 + 120;
                    var categories = [
                        TROPHY_CATEGORY.COMBAT,
                        TROPHY_CATEGORY.EXPLORATION, 
                        TROPHY_CATEGORY.COLLECTION,
                        TROPHY_CATEGORY.CRAFTING,
                        TROPHY_CATEGORY.SPECIAL,
                        TROPHY_CATEGORY.BOSS
                    ];
                    
                    var button_width = 120;
                    var button_height = 30;
                    var button_spacing = 10;
                    
                    for (var i = 0; i < array_length(categories); i++) {
                        var button_x = content_zone.x1 + 20 + i * (button_width + button_spacing);
                        
                        if (point_in_rectangle(_mx, _my, button_x, category_y, button_x + button_width, category_y + button_height)) {
                            global.aty.current_trophy_category = categories[i];
                            return true;
                        }
                    }
                    break;
                case TAB.ABILITIES:
                    // Способности - нет кликабельных элементов
                    break;
                    
                case TAB.SHOP:
                    // Обработка магазина
                    var shop_items = global.aty.shop.items;
                    var start_x = content_zone.x1 + 20;
                    var start_y = content_zone.y1 + 80;
                    var items_per_row = 4;
                    var item_size = 80;
                    var item_spacing = 15;
                    
                    for (var i = 0; i < array_length(shop_items); i++) {
                        var row = i div items_per_row;
                        var col = i mod items_per_row;
                        var item_x = start_x + col * (item_size + item_spacing);
                        var item_y = start_y + row * (item_size + item_spacing + 30);
                        
                        if (point_in_rectangle(_mx, _my, item_x, item_y, item_x + item_size, item_y + item_size)) {
                            aty_buy_item(i);
                            return;
                        }
                    }
                    
                    // Кнопка обновления магазина
                    if (point_in_rectangle(_mx, _my, content_zone.x1 + 200, content_zone.y1 + 20, 
                                         content_zone.x1 + 350, content_zone.y1 + 50)) {
                        aty_refresh_shop();
                        return;
                    }
                    break;
                    
                case TAB.STATISTICS:
                    // Кнопки сохранения/загрузки
                    if (point_in_rectangle(_mx, _my, content_zone.x1 + 20, content_zone.y1 + 20, 
                                         content_zone.x1 + 140, content_zone.y1 + 60)) {
                        aty_save_game();
                        return;
                    }
                    
                    if (point_in_rectangle(_mx, _my, content_zone.x1 + 160, content_zone.y1 + 20, 
                                         content_zone.x1 + 280, content_zone.y1 + 60)) {
                        aty_load_game();
                        return;
                    }
                    break;
                    
                case TAB.QUESTS:
				    if (aty_handle_quests_tab_clicks(_mx, _my, content_zone)) {
						return;
					}

                    break;
                    
                case TAB.MINIRAIDS:
                    // Обработка мини-рейдов
                    var raid_y = content_zone.y1 + 50;
                    for (var i = 0; i < array_length(global.aty.miniraids); i++) {
                        var raid = global.aty.miniraids[i];
                        
                        if (raid.state == RAID_STATE.AVAILABLE && !global.aty.raids.active) {
                            var button_x = content_zone.x2 - 120;
                            var button_y = raid_y + 25;
                            
                            if (point_in_rectangle(_mx, _my, button_x, button_y, button_x + 90, button_y + 30)) {
                                aty_start_miniraid(i);
                                return;
                            }
                        }
                        
                        raid_y += 110;
                        if (raid_y > content_zone.y2 - 100) break;
                    }
                    break;
            }
        }
        
        // 4. Проверка кликов по верхним аренам
        if (point_in_rectangle(_mx, _my, zones.top.x1, zones.top.y1, zones.top.x2, zones.top.y2)) {
            var button_width = 250;
            var button_height = 120;
            var button_spacing = 20;
            
            for (var i = 0; i < 3; i++) {
                var button_x = zones.top.x1 + 30 + i * (button_width + button_spacing);
                var button_y = zones.top.y1 + 50;
                
                if (point_in_rectangle(_mx, _my, button_x, button_y, button_x + button_width, button_y + button_height)) {
                    var is_unlocked = array_contains(global.aty.arenas.unlocked, i);
                    if (is_unlocked) {
                        aty_enter_arena(i);
                        return;
                    } else {
                        aty_show_notification("Арена заблокирована! Победите босса в экспедиции.");
                        return;
                    }
                }
            }
        }
        
        // 5. Проверка кликов по портретам отряда
        if (point_in_rectangle(_mx, _my, zones.portraits.x1, zones.portraits.y1, zones.portraits.x2, zones.portraits.y2)) {
            var hero_x = zones.portraits.x1 + 25;
            var hero_y = zones.portraits.y1 + 50;
            var portrait_size = 60;
            
            // Клик по портрету героя
            if (point_in_rectangle(_mx, _my, hero_x, hero_y, hero_x + portrait_size, hero_y + portrait_size)) {
                global.aty.current_tab = TAB.HERO;
                return;
            }
            
            // Клики по портретам помощниц
            var companion_y = hero_y + portrait_size + 40; // Уменьшено расстояние
            
            for (var i = 0; i < array_length(global.aty.companions); i++) {
                if (point_in_rectangle(_mx, _my, hero_x, companion_y, hero_x + portrait_size, companion_y + portrait_size)) {
                    var companion = global.aty.companions[i];
                    if (companion.unlocked) {
                        // Переходим на арену помощницы
                        aty_enter_arena(i);
                        return;
                    } else {
                        aty_show_notification(companion.name + " еще не присоединилась к отряду!");
                        return;
                    }
                }
                companion_y += portrait_size + 60; // Уменьшено расстояние
            }
        }
        
        // 6. Проверка кликов по кнопкам экспедиций в средней зоне
        if (!global.aty.expedition.active && point_in_rectangle(_mx, _my, zones.middle.x1, zones.middle.y1, zones.middle.x2, zones.middle.y2)) {
            var center_x = (zones.middle.x1 + zones.middle.x2) / 2;
            var center_y = (zones.middle.y1 + zones.middle.y2) / 2;
            
            var expedition_button_width = 150;
            var expedition_button_height = 40;
            var expedition_spacing = 20;
            var total_width = 6 * expedition_button_width + 5 * expedition_spacing;
            var start_x = center_x - total_width / 2;
            var button_y = center_y + 100;
            
            for (var i = 1; i <= 6; i++) {
                var button_x = start_x + (i-1) * (expedition_button_width + expedition_spacing);
                
                if (point_in_rectangle(_mx, _my, button_x, button_y, button_x + expedition_button_width, button_y + expedition_button_height)) {
                    if (i <= 5) {
                        // Обычные экспедиции (1-5)
                        var expedition = global.aty.expeditions[i-1];
                        
                        // Проверяем требования уровня
                        if (global.aty.hero.level >= expedition.required_level) {
                            if (aty_start_expedition(i)) {
                                aty_show_notification("Экспедиция '" + expedition.name + "' начата!");
                            }
                        } else {
                            aty_show_notification("Требуется уровень " + string(expedition.required_level) + " для этой экспедиции!");
                        }
                    } else {
                        // Рейд-босс (уровень 6)
                        var raid_expedition = global.aty.expeditions[5];
                        
                        // ПРЯМАЯ ПРОВЕРКА УСЛОВИЙ ДЛЯ РЕЙД-БОССА
                        var raid_unlocked = true;
                        for (var j = 0; j < 5; j++) {
                            if (!global.aty.expeditions[j].completed) {
                                raid_unlocked = false;
                                break;
                            }
                        }
                        
                        var raid_can_start = global.aty.hero.level >= raid_expedition.required_level && raid_unlocked;
                        
                        if (raid_can_start) {
                            if (aty_start_raid_boss()) {
                                aty_show_notification("⚔️ РЕЙД-БОСС '" + raid_expedition.name + "' начат!");
                            }
                        } else if (!raid_unlocked) {
                            aty_show_notification("Требуется завершить все предыдущие экспедиции для доступа к рейд-боссу!");
                        } else {
                            aty_show_notification("Требуется уровень " + string(raid_expedition.required_level) + " для рейд-босса!");
                        }
                    }
                    return;
                }
            }
        }
    }

    
    // Обработка ПРАВОЙ кнопки мыши (альтернативные действия)
    if (_button == mb_right) {
        // 1. Проверка кликов по инвентарю (продажа предметов)
        if (point_in_rectangle(_mx, _my, zones.tabs.x1, zones.tabs.y1, zones.tabs.x2, zones.tabs.y2)) {
            var tab_width = 110;
            var tab_spacing = 5;
            var tab_y = zones.tabs.y1 + 10;
            
            var content_y = tab_y + 50;
            var content_zone = {
                x1: zones.tabs.x1 + 10,
                y1: content_y,
                x2: zones.tabs.x2 - 10,
                y2: zones.tabs.y2 - 10
            };
            
            if (global.aty.current_tab == TAB.INVENTORY) {
                var inv_x = content_zone.x1 + 120;
                var inv_y = content_zone.y1 + 50;
                var items_per_row = 5;
                var item_size = 70;
                var item_spacing = 10;
                
                for (var i = 0; i < array_length(global.aty.inventory); i++) {
                    var row = i div items_per_row;
                    var col = i mod items_per_row;
                    var item_x = inv_x + col * (item_size + item_spacing);
                    var item_y = inv_y + row * (item_size + item_spacing);
                    
                    if (point_in_rectangle(_mx, _my, item_x, item_y, item_x + item_size, item_y + item_size)) {
                        aty_sell_item(i);
                        return;
                    }
                }
            }
        }
        
        // 2. Проверка кликов по верхним аренам (информация о помощницах)
        if (point_in_rectangle(_mx, _my, zones.top.x1, zones.top.y1, zones.top.x2, zones.top.y2)) {
            var button_width = 250;
            var button_height = 120;
            var button_spacing = 20;
            
            for (var i = 0; i < 3; i++) {
                var button_x = zones.top.x1 + 30 + i * (button_width + button_spacing);
                var button_y = zones.top.y1 + 50;
                
                if (point_in_rectangle(_mx, _my, button_x, button_y, button_x + button_width, button_y + button_height)) {
                    var companion = global.aty.companions[i];
                    var buffs_text = "Баффы: ";
                    for (var j = 0; j < array_length(companion.buffs); j++) {
                        if (j > 0) buffs_text += ", ";
                        buffs_text += companion.buffs[j];
                    }
                    aty_show_notification(companion.name + " - " + buffs_text);
                    return;
                }
            }
        }
    }
}
// =============================================================================
// STANDARD RESOLUTION HERO TAB CLICK HANDLING
// =============================================================================

function _aty_handle_hero_tab_clicks(_mx, _my, _zone) {
    var hero = global.aty.hero;
    
    // Проверяем, есть ли очки для распределения
    if (hero.stat_points <= 0) return;
    
    var base_x = _zone.x1 + 200;
    var stats_y = _zone.y1 + 50;
    var stat_keys = ["strength", "agility", "intelligence", "vitality", "dexterity", "luck"];
    
    // Проверяем клики по кнопкам "+" для каждой характеристики
    for (var i = 0; i < array_length(stat_keys); i++) {
        var stat_y = stats_y + 25 + i * 25;
        var button_x1 = base_x + 120;
        var button_y1 = stat_y - 5;
        var button_x2 = base_x + 140;
        var button_y2 = stat_y + 15;
        
        if (point_in_rectangle(_mx, _my, button_x1, button_y1, button_x2, button_y2)) {
            // Увеличиваем соответствующую характеристику
            aty_increase_stat(stat_keys[i]);
            return;
        }
    }
}


// CLEANUP FUNCTION
// =============================================================================

function aty_cleanup() {
    // Очищаем поверхность высокого разрешения при выходе
    if (surface_exists(global.aty_render_surface)) {
        surface_free(global.aty_render_surface);
    }
}
function aty_vfx_init() {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) return;
    
    // Initialize shaders - временно отключаем шейдеры
    global.aty.vfx.shaders = [];
    
    // Закомментировано на время отладки
    /*
    var shader_names = ["sh_vfx_flow", "sh_vfx_voronoi", "sh_vfx_polar"];
    for (var i = 0; i < array_length(shader_names); i++) {
        var shader_id = asset_get_index(shader_names[i]);
        if (shader_id != -1) {
            array_push(global.aty.vfx.shaders, shader_id);
        }
    }
    */
    
    // Create VFX surface - с дополнительными проверками
    if (surface_exists(global.aty.vfx.surface)) {
        surface_free(global.aty.vfx.surface);
    }
    
    // Пробуем создать поверхность, но если не получается - не падаем
    try {
        global.aty.vfx.surface = surface_create(500, 380);
    } catch (e) {
        show_debug_message("Failed to create VFX surface: " + string(e));
        global.aty.vfx.surface = -1;
    }
}
function aty_vfx_step(_dt) {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty) || !global.aty.vfx.enabled) return;
    
    global.aty.vfx.time += _dt;
}
function aty_vfx_draw(_x, _y, _width, _height, _progress) {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty) || !global.aty.vfx.enabled) return;
    
    // Временная заглушка для VFX
    draw_set_color(global.aty_colors.neon_purple);
    draw_set_alpha(0.3);
    draw_rectangle(_x, _y, _x + _width, _y + _height, false);
    draw_set_alpha(1);
    
    /*
    // Закомментированный оригинальный код VFX
    if (!surface_exists(global.aty.vfx.surface)) {
        aty_vfx_init();
        if (!surface_exists(global.aty.vfx.surface)) return;
    }
    
    // Draw to surface with active shader
    surface_set_target(global.aty.vfx.surface);
    draw_clear_alpha(c_black, 0);
    
    if (array_length(global.aty.vfx.shaders) > 0) {
        var shader_index = floor(global.aty.vfx.time) mod array_length(global.aty.vfx.shaders);
        var current_shader = global.aty.vfx.shaders[shader_index];
        
        shader_set(current_shader);
        
        // Set shader uniforms
        var u_time = shader_get_uniform(current_shader, "u_time");
        var u_resolution = shader_get_uniform(current_shader, "u_resolution");
        var u_progress = shader_get_uniform(current_shader, "u_progress");
        var u_palette = shader_get_uniform(current_shader, "u_palette");
        
        if (u_time != -1) shader_set_uniform_f(u_time, global.aty.vfx.time);
        if (u_resolution != -1) shader_set_uniform_f(u_resolution, 500, 380);
        if (u_progress != -1) shader_set_uniform_f(u_progress, _progress);
        if (u_palette != -1) {
            var palette_value = (global.aty.vfx.palette == "good") ? 0 : 1;
            shader_set_uniform_f(u_palette, palette_value);
        }
        
        // Draw shader effect
        draw_rectangle(0, 0, 500, 380, false);
        shader_reset();
    }
    
    surface_reset_target();
    
    // Draw surface to screen
    draw_surface_stretched(global.aty.vfx.surface, _x, _y, _width, _height);
    */
    
    // Draw expedition flash if active
    if (variable_struct_exists(global.aty.expedition, "flash") && global.aty.expedition.flash.active) {
        var alpha = global.aty.expedition.flash.timer / 60;
        draw_set_alpha(alpha);
        draw_set_color(global.aty.expedition.flash.color);
        draw_rectangle(_x, _y, _x + _width, _y + _height, false);
        draw_set_alpha(1);
        
        global.aty.expedition.flash.timer -= 1;
        if (global.aty.expedition.flash.timer <= 0) {
            global.aty.expedition.flash.active = false;
        }
    }
}
function aty_vfx_toggle() {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) return;
    global.aty.vfx.enabled = !global.aty.vfx.enabled;
}
function _aty_draw_top_zone() {
    var aty = global.aty;
    var zones = aty.ui_zones;
    var colors = global.aty_colors;
    
    // Фон верхней зоны в стиле dark fantasy
    draw_neon_panel(zones.top.x1, zones.top.y1, zones.top.x2, zones.top.y2, "Тренировочные Арены");
    
    var button_width = 250;
    var button_height = 120;
    var button_spacing = 20;
    
    for (var i = 0; i < 3; i++) {
        var button_x = zones.top.x1 + 30 + i * (button_width + button_spacing);
        var button_y = zones.top.y1 + 50;
        
        var companion = aty.companions[i];
        var is_unlocked = array_contains(aty.arenas.unlocked, i);
        
        // Неоновая кнопка арены
        draw_neon_button(button_x, button_y, button_x + button_width, button_y + button_height, 
                        companion.name, is_unlocked, !is_unlocked);
        
        // Дополнительная информация
        draw_set_color(is_unlocked ? colors.neon_green : colors.neon_red);
        draw_text(button_x + 15, button_y + 40, is_unlocked ? "✓ Доступна" : "✗ Заблокирована");
        draw_set_color(colors.neon_cyan);
        draw_text(button_x + 15, button_y + 60, "Ранг: " + string(companion.rank));
        draw_text(button_x + 15, button_y + 80, "Уровень: " + string(companion.level));
        
        // Прогресс тренировки если есть
        if (companion.training_progress > 0) {
            draw_set_color(colors.neon_pink);
            draw_text(button_x + 15, button_y + 100, "Тренировка: " + string(floor(companion.training_progress)) + "%");
        }
    }
}

function _aty_draw_portraits() {
    var aty = global.aty;
    var zones = aty.ui_zones;
    var colors = global.aty_colors;
    
    draw_neon_panel(zones.portraits.x1, zones.portraits.y1, zones.portraits.x2, zones.portraits.y2, "Отряд");
    
    // Портрет героя
    var hero_x = zones.portraits.x1 + 25;
    var hero_y = zones.portraits.y1 + 50;
    var portrait_size = 60;
    
    draw_neon_rectangle(hero_x, hero_y, hero_x + portrait_size, hero_y + portrait_size, colors.neon_blue, true);
    draw_set_color(colors.neon_cyan);
    draw_text(hero_x, hero_y + portrait_size + 5, "Герой");
    draw_text(hero_x, hero_y + portrait_size + 25, "Ур. " + string(aty.hero.level));
    
    // Портреты компаньонов - УМЕНЬШЕНО РАССТОЯНИЕ
    var companion_y = hero_y + portrait_size + 40; // Было +60
    
    for (var i = 0; i < array_length(aty.companions); i++) {
        var companion = aty.companions[i];
        var companion_color = companion.unlocked ? colors.neon_green : colors.neon_red;
        
        draw_neon_rectangle(hero_x, companion_y, hero_x + portrait_size, companion_y + portrait_size, 
                          companion_color, true);
        
        draw_set_color(colors.neon_cyan);
        draw_text(hero_x, companion_y + portrait_size + 5, companion.name);
        draw_text(hero_x, companion_y + portrait_size + 25, "Ранг " + string(companion.rank));
        
        // Статус
        draw_set_color(companion.unlocked ? colors.neon_green : colors.neon_red);
        draw_text(hero_x, companion_y + portrait_size + 45, companion.unlocked ? "✓ В отряде" : "✗ Заблокирована");
        
        companion_y += portrait_size + 60; // Было +80 - УМЕНЬШЕНО РАССТОЯНИЕ
    }
}

// =============================================================================
// HIGH-RESOLUTION INVENTORY CLICK HANDLING
// =============================================================================

function _aty_handle_inventory_clicks_high_res(_mx, _my, _zone) {
    var settings = global.aty.inventory_settings;
    var scale = global.aty_render_scale;
    
    // ==================== РАЗДЕЛЕНИЕ НА КОЛОНКИ (как в отрисовке) ====================
    var left_width = 200 * scale;
    var center_width = 400 * scale;
    var right_width = 180 * scale;
    
    var left_zone = {
        x1: _zone.x1 + 10 * scale,
        y1: _zone.y1 + 10 * scale,
        x2: _zone.x1 + left_width,
        y2: _zone.y2 - 10 * scale
    };
    
    var center_zone = {
        x1: _zone.x1 + left_width + 10 * scale,
        y1: _zone.y1 + 10 * scale,
        x2: _zone.x1 + left_width + center_width,
        y2: _zone.y2 - 10 * scale
    };
    
    var right_zone = {
        x1: _zone.x1 + left_width + center_width + 10 * scale,
        y1: _zone.y1 + 10 * scale,
        x2: _zone.x2 - 10 * scale,
        y2: _zone.y2 - 10 * scale
    };
    
    // ==================== ОБРАБОТКА ПРАВОЙ КОЛОНКИ (ФИЛЬТРЫ) ====================
    if (point_in_rectangle(_mx, _my, right_zone.x1, right_zone.y1, right_zone.x2, right_zone.y2)) {
        var control_y = right_zone.y1 + 40 * scale;
        var button_width = 150 * scale;
        var button_height = 25 * scale;
        var button_spacing = 10 * scale;
        
        // Кнопки сортировки
        var sort_options = [
            { key: "name", label: "По имени" },
            { key: "rarity", label: "По редкости" },
            { key: "type", label: "По типу" },
            { key: "stats", label: "По силе" }
        ];
        
        for (var i = 0; i < array_length(sort_options); i++) {
            if (point_in_rectangle(_mx, _my, right_zone.x1 + 15 * scale, control_y, 
                                 right_zone.x1 + 15 * scale + button_width, control_y + button_height)) {
                settings.sort_by = sort_options[i].key;
                return true;
            }
            control_y += button_height + button_spacing;
        }
        
        // Кнопка направления сортировки
        if (point_in_rectangle(_mx, _my, right_zone.x1 + 15 * scale, control_y, 
                             right_zone.x1 + 15 * scale + 40 * scale, control_y + button_height)) {
            settings.sort_ascending = !settings.sort_ascending;
            return true;
        }
        
        control_y += button_height + 20 * scale;
        
        // Фильтры по типу
        var type_filters = [
            { key: "all", label: "Все предметы" },
            { key: "weapon", label: "Оружие" },
            { key: "armor", label: "Броня" },
            { key: "accessory", label: "Аксессуары" },
            { key: "trinket", label: "Тринкеты" },
            { key: "charm", label: "Амулеты" },
            { key: "gem", label: "Камни" }
        ];
        
        for (var i = 0; i < array_length(type_filters); i++) {
            if (point_in_rectangle(_mx, _my, right_zone.x1 + 15 * scale, control_y, 
                                 right_zone.x1 + 15 * scale + button_width, control_y + button_height)) {
                settings.filter_type = type_filters[i].key;
                return true;
            }
            control_y += button_height + button_spacing;
        }
        
        control_y += 10 * scale;
        
        // Фильтры по редкости
        var rarity_filters = [
            { key: "all", label: "Все редкости" },
            { key: "common", label: "Обычные" },
            { key: "uncommon", label: "Необычные" },
            { key: "rare", label: "Редкие" },
            { key: "epic", label: "Эпические" },
            { key: "legendary", label: "Легендарные" }
        ];
        
        for (var i = 0; i < array_length(rarity_filters); i++) {
            if (point_in_rectangle(_mx, _my, right_zone.x1 + 15 * scale, control_y, 
                                 right_zone.x1 + 15 * scale + button_width, control_y + button_height)) {
                settings.filter_rarity = rarity_filters[i].key;
                return true;
            }
            control_y += button_height + button_spacing;
        }
        
        control_y += 10 * scale;
        
        // Кнопка показа экипированных
        if (point_in_rectangle(_mx, _my, right_zone.x1 + 15 * scale, control_y, 
                             right_zone.x1 + 15 * scale + button_width, control_y + button_height)) {
            settings.show_equipped = !settings.show_equipped;
            return true;
        }
        
        control_y += button_height + button_spacing;
        
        // Кнопка массовой продажи
        if (point_in_rectangle(_mx, _my, right_zone.x1 + 15 * scale, control_y, 
                             right_zone.x1 + 15 * scale + button_width, control_y + button_height)) {
            aty_sell_all_junk();
            return true;
        }
    }
    
    // ==================== ОБРАБОТКА ЦЕНТРАЛЬНОЙ ЧАСТИ (ПРЕДМЕТЫ) ====================
    if (point_in_rectangle(_mx, _my, center_zone.x1, center_zone.y1, center_zone.x2, center_zone.y2)) {
        var filtered_items = aty_get_filtered_inventory();
        var items_per_row = 6;
        var item_size = 45 * scale;
        var item_spacing = 8 * scale;
        
        var inv_x = center_zone.x1 + 15 * scale;
        var inv_y = center_zone.y1 + 40 * scale;
        var max_rows = floor((center_zone.y2 - inv_y - 20 * scale) / (item_size + item_spacing));
        
        for (var i = 0; i < array_length(filtered_items); i++) {
            if (i >= items_per_row * max_rows) break;
            
            var row = i div items_per_row;
            var col = i mod items_per_row;
            
            var item_x = inv_x + col * (item_size + item_spacing);
            var item_y = inv_y + row * (item_size + item_spacing);
            
            if (point_in_rectangle(_mx, _my, item_x, item_y, item_x + item_size, item_y + item_size)) {
                var real_index = aty_find_item_in_inventory(filtered_items[i]);
                if (real_index != -1) {
                    return real_index; // Возвращаем индекс для обработки
                }
            }
        }
    }
    
    // ==================== ОБРАБОТКА ЛЕВОЙ КОЛОНКИ (СЛОТЫ ЭКИПИРОВКИ) ====================
    if (point_in_rectangle(_mx, _my, left_zone.x1, left_zone.y1, left_zone.x2, left_zone.y2)) {
        // Обработка кликов по слотам экипировки (для снятия предметов)
        var slot_size = 50 * scale;
        var slot_spacing = 15 * scale;
        
        // Первая колонна
        var col1_x = left_zone.x1 + 20 * scale;
        var col1_y = left_zone.y1 + 40 * scale;
        var slot_keys = ["WEAPON", "ARMOR", "ACCESSORY", "TRINKET", "CHARM"];
        
        for (var i = 0; i < 3; i++) {
            if (point_in_rectangle(_mx, _my, col1_x, col1_y, col1_x + slot_size, col1_y + slot_size)) {
                var equipment = global.aty.hero.equipment;
                var slot_item = variable_struct_get(equipment, slot_keys[i]);
                
                // Если в слоте есть предмет - снимаем его
                if (is_struct(slot_item)) {
                    aty_unequip_item(slot_keys[i]);
                    return true;
                }
            }
            col1_y += slot_size + slot_spacing;
        }
        
        // Вторая колонна
        var col2_x = left_zone.x1 + 100 * scale;
        var col2_y = left_zone.y1 + 40 * scale;
        
        for (var i = 3; i < 5; i++) {
            if (point_in_rectangle(_mx, _my, col2_x, col2_y, col2_x + slot_size, col2_y + slot_size)) {
                var equipment = global.aty.hero.equipment;
                var slot_item = variable_struct_get(equipment, slot_keys[i]);
                
                if (is_struct(slot_item)) {
                    aty_unequip_item(slot_keys[i]);
                    return true;
                }
            }
            col2_y += slot_size + slot_spacing;
        }
    }
    
    return -1;
}
// =============================================================================
// ENHANCED INVENTORY CLICK HANDLING
// =============================================================================

function _aty_handle_inventory_clicks(_mx, _my, _zone) {
    var settings = global.aty.inventory_settings;
    
    // Сбрасываем подсказку при клике
    global.aty_tooltip_item = undefined;
    
    // ==================== РАЗДЕЛЕНИЕ НА КОЛОНКИ ====================
    var left_width = 200;
    var center_width = 400;
    var right_width = 180;
    
    var left_zone = {
        x1: _zone.x1 + 10,
        y1: _zone.y1 + 10,
        x2: _zone.x1 + left_width,
        y2: _zone.y2 - 10
    };
    
    var center_zone = {
        x1: _zone.x1 + left_width + 10,
        y1: _zone.y1 + 10,
        x2: _zone.x1 + left_width + center_width,
        y2: _zone.y2 - 10
    };
    
    var right_zone = {
        x1: _zone.x1 + left_width + center_width + 10,
        y1: _zone.y1 + 10,
        x2: _zone.x2 - 10,
        y2: _zone.y2 - 10
    };
    
    // ==================== ОБРАБОТКА ПРАВОЙ КОЛОНКИ (ФИЛЬТРЫ) ====================
    if (point_in_rectangle(_mx, _my, right_zone.x1, right_zone.y1, right_zone.x2, right_zone.y2)) {
        var control_y = right_zone.y1 + 40;
        var button_width = 150;
        var button_height = 25;
        var button_spacing = 10;
        
        // Кнопки сортировки
        var sort_options = ["name", "rarity", "type", "stats"];
        for (var i = 0; i < 4; i++) {
            if (point_in_rectangle(_mx, _my, right_zone.x1 + 15, control_y, 
                                 right_zone.x1 + 15 + button_width, control_y + button_height)) {
                settings.sort_by = sort_options[i];
                return true;
            }
            control_y += button_height + button_spacing;
        }
        
        // Кнопка направления сортировки
        if (point_in_rectangle(_mx, _my, right_zone.x1 + 15, control_y, 
                             right_zone.x1 + 15 + 40, control_y + button_height)) {
            settings.sort_ascending = !settings.sort_ascending;
            return true;
        }
        
        control_y += button_height + 20;
        
        // Фильтры по типу
        var type_filters = ["all", "weapon", "armor", "accessory", "trinket", "charm", "gem"];
        for (var i = 0; i < 7; i++) {
            if (point_in_rectangle(_mx, _my, right_zone.x1 + 15, control_y, 
                                 right_zone.x1 + 15 + button_width, control_y + button_height)) {
                settings.filter_type = type_filters[i];
                return true;
            }
            control_y += button_height + button_spacing;
        }
        
        control_y += 10;
        
        // Фильтры по редкости
        var rarity_filters = ["all", "common", "uncommon", "rare", "epic", "legendary"];
        for (var i = 0; i < 6; i++) {
            if (point_in_rectangle(_mx, _my, right_zone.x1 + 15, control_y, 
                                 right_zone.x1 + 15 + button_width, control_y + button_height)) {
                settings.filter_rarity = rarity_filters[i];
                return true;
            }
            control_y += button_height + button_spacing;
        }
        
        control_y += 10;
        
        // Кнопка показа экипированных
        if (point_in_rectangle(_mx, _my, right_zone.x1 + 15, control_y, 
                             right_zone.x1 + 15 + button_width, control_y + button_height)) {
            settings.show_equipped = !settings.show_equipped;
            return true;
        }
        
        control_y += button_height + button_spacing;
        
        // Кнопка массовой продажи
        if (point_in_rectangle(_mx, _my, right_zone.x1 + 15, control_y, 
                             right_zone.x1 + 15 + button_width, control_y + button_height)) {
            aty_sell_all_junk();
            return true;
        }
    }
    
    // ==================== ОБРАБОТКА ЦЕНТРАЛЬНОЙ ЧАСТИ (ПРЕДМЕТЫ) ====================
    if (point_in_rectangle(_mx, _my, center_zone.x1, center_zone.y1, center_zone.x2, center_zone.y2)) {
        var filtered_items = aty_get_filtered_inventory();
        var items_per_row = 6;
        var item_size = 45;
        var item_spacing = 8;
        
        var inv_x = center_zone.x1 + 15;
        var inv_y = center_zone.y1 + 40;
        var max_rows = floor((center_zone.y2 - inv_y - 20) / (item_size + item_spacing));
        
        for (var i = 0; i < array_length(filtered_items); i++) {
            if (i >= items_per_row * max_rows) break;
            
            var row = i div items_per_row;
            var col = i mod items_per_row;
            
            var item_x = inv_x + col * (item_size + item_spacing);
            var item_y = inv_y + row * (item_size + item_spacing);
            
            if (point_in_rectangle(_mx, _my, item_x, item_y, item_x + item_size, item_y + item_size)) {
                var real_index = aty_find_item_in_inventory(filtered_items[i]);
                if (real_index != -1) {
                    return real_index;
                }
            }
        }
    }
    
    // ==================== ОБРАБОТКА ЛЕВОЙ КОЛОНКИ (СЛОТЫ ЭКИПИРОВКИ) ====================
    if (point_in_rectangle(_mx, _my, left_zone.x1, left_zone.y1, left_zone.x2, left_zone.y2)) {
        // Обработка кликов по слотам экипировки (для снятия предметов)
        var slot_size = 50;
        var slot_spacing = 15;
        
        // Первая колонна
        var col1_x = left_zone.x1 + 20;
        var col1_y = left_zone.y1 + 40;
        var slot_keys = ["WEAPON", "ARMOR", "ACCESSORY", "TRINKET", "CHARM"];
        
        for (var i = 0; i < 3; i++) {
            if (point_in_rectangle(_mx, _my, col1_x, col1_y, col1_x + slot_size, col1_y + slot_size)) {
                var equipment = global.aty.hero.equipment;
                var slot_item = variable_struct_get(equipment, slot_keys[i]);
                
                // Если в слоте есть предмет - снимаем его
                if (is_struct(slot_item)) {
                    aty_unequip_item(slot_keys[i]);
                    return true;
                }
            }
            col1_y += slot_size + slot_spacing;
        }
        
        // Вторая колонна
        var col2_x = left_zone.x1 + 100;
        var col2_y = left_zone.y1 + 40;
        
        for (var i = 3; i < 5; i++) {
            if (point_in_rectangle(_mx, _my, col2_x, col2_y, col2_x + slot_size, col2_y + slot_size)) {
                var equipment = global.aty.hero.equipment;
                var slot_item = variable_struct_get(equipment, slot_keys[i]);
                
                if (is_struct(slot_item)) {
                    aty_unequip_item(slot_keys[i]);
                    return true;
                }
            }
            col2_y += slot_size + slot_spacing;
        }
    }
    
    return -1;
}
function aty_unequip_item(_slot) {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) return false;
    
    var equipment = global.aty.hero.equipment;
    
    if (!variable_struct_exists(equipment, _slot)) return false;
    
    var item = variable_struct_get(equipment, _slot);
    
    if (!is_struct(item)) return false;
    
    // Возвращаем предмет в инвентарь
    array_push(global.aty.inventory, item);
    
    // Очищаем слот
    variable_struct_set(equipment, _slot, noone);
    
    // Пересчитываем характеристики
    aty_recalculate_hero_stats();
    
    aty_show_notification("Снят: " + item.name);
    return true;
}
function aty_find_item_in_inventory(_item) {
    var inventory = global.aty.inventory;
    
    for (var i = 0; i < array_length(inventory); i++) {
        if (aty_safe_compare_items(inventory[i], _item)) {
            return i;
        }
    }
    
    return -1;
}
// =============================================================================
// BULK SELLING SYSTEM
// =============================================================================

function aty_sell_all_junk() {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) return 0;
    
    var inventory = global.aty.inventory;
    var total_gold = 0;
    var sold_count = 0;
    
    // Создаем копию для безопасного удаления
    var items_to_sell = [];
    
    for (var i = 0; i < array_length(inventory); i++) {
        var item = inventory[i];
        
        // Продаем только обычные и необычные предметы, которые не экипированы
        if ((item.rarity == RARITY.COMMON || item.rarity == RARITY.UNCOMMON) && 
            !aty_is_item_equipped(item)) {
            array_push(items_to_sell, { index: i, item: item });
        }
    }
    
    // Продаем в обратном порядке чтобы индексы не сбивались
    for (var i = array_length(items_to_sell) - 1; i >= 0; i--) {
        var sell_info = items_to_sell[i];
        var sell_price = aty_calculate_sell_price(sell_info.item);
        
        total_gold += sell_price;
        sold_count++;
        
        // Удаляем предмет из инвентаря
        array_delete(global.aty.inventory, sell_info.index, 1);
    }
    
    // Добавляем золото
    global.aty.hero.gold += total_gold;
    
    if (sold_count > 0) {
        aty_show_notification("Продано " + string(sold_count) + " предметов за " + string(total_gold) + " золота");
    } else {
        aty_show_notification("Нет предметов для продажи");
    }
    
    return total_gold;
}

function aty_sell_items_by_rarity(_rarity) {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) return 0;
    
    var inventory = global.aty.inventory;
    var total_gold = 0;
    var sold_count = 0;
    
    var items_to_sell = [];
    
    for (var i = 0; i < array_length(inventory); i++) {
        var item = inventory[i];
        
        if (item.rarity == _rarity && !aty_is_item_equipped(item)) {
            array_push(items_to_sell, { index: i, item: item });
        }
    }
    
    for (var i = array_length(items_to_sell) - 1; i >= 0; i--) {
        var sell_info = items_to_sell[i];
        var sell_price = aty_calculate_sell_price(sell_info.item);
        
        total_gold += sell_price;
        sold_count++;
        array_delete(global.aty.inventory, sell_info.index, 1);
    }
    
    global.aty.hero.gold += total_gold;
    
    var rarity_name = aty_get_rarity_name(_rarity);
    aty_show_notification("Продано " + string(sold_count) + " " + rarity_name + " предметов за " + string(total_gold) + " золота");
    
    return total_gold;
}

// =============================================================================
// UPDATED EQUIPMENT STATS APPLICATION
// =============================================================================

function aty_apply_equipment_stats() {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) return;
    
    var hero = global.aty.hero;
    var equipment = hero.equipment;
    var stats = hero.stats;
    
    // Временные переменные для накопления бонусов
    var health_bonus = 0;
    var mana_bonus = 0;
    var attack_power_bonus = 0;
    var magic_power_bonus = 0;
    var defense_bonus = 0;
    var crit_chance_bonus = 0;
    var crit_damage_bonus = 0;
    var attack_speed_bonus = 0;
    var cast_speed_bonus = 0;
    var dodge_chance_bonus = 0;
    var block_chance_bonus = 0;
    var lifesteal_bonus = 0;
    var cooldown_reduction_bonus = 0;
    var movement_speed_bonus = 0;
    
    // Собираем бонусы со всей экипировки
    var slot_names = variable_struct_get_names(equipment);
    for (var i = 0; i < array_length(slot_names); i++) {
        var item = variable_struct_get(equipment, slot_names[i]);
        if (is_struct(item) && variable_struct_exists(item, "stats")) {
            var item_stats = item.stats;
            
            // Суммируем все статы из предмета
            if (variable_struct_exists(item_stats, "health")) 
                health_bonus += item_stats.health;
            if (variable_struct_exists(item_stats, "mana")) 
                mana_bonus += item_stats.mana;
            if (variable_struct_exists(item_stats, "attack_power")) 
                attack_power_bonus += item_stats.attack_power;
            if (variable_struct_exists(item_stats, "magic_power")) 
                magic_power_bonus += item_stats.magic_power;
            if (variable_struct_exists(item_stats, "defense")) 
                defense_bonus += item_stats.defense;
            if (variable_struct_exists(item_stats, "crit_chance")) 
                crit_chance_bonus += item_stats.crit_chance;
            if (variable_struct_exists(item_stats, "crit_damage")) 
                crit_damage_bonus += item_stats.crit_damage;
            if (variable_struct_exists(item_stats, "attack_speed")) 
                attack_speed_bonus += item_stats.attack_speed;
            if (variable_struct_exists(item_stats, "cast_speed")) 
                cast_speed_bonus += item_stats.cast_speed;
            if (variable_struct_exists(item_stats, "dodge_chance")) 
                dodge_chance_bonus += item_stats.dodge_chance;
            if (variable_struct_exists(item_stats, "block_chance")) 
                block_chance_bonus += item_stats.block_chance;
            if (variable_struct_exists(item_stats, "lifesteal")) 
                lifesteal_bonus += item_stats.lifesteal;
            if (variable_struct_exists(item_stats, "cooldown_reduction")) 
                cooldown_reduction_bonus += item_stats.cooldown_reduction;
            if (variable_struct_exists(item_stats, "movement_speed")) 
                movement_speed_bonus += item_stats.movement_speed;
        }
    }
    
    // Применяем накопленные бонусы
    stats.health += health_bonus;
    stats.mana += mana_bonus;
    stats.attack_power += attack_power_bonus;
    stats.magic_power += magic_power_bonus;
    stats.defense += defense_bonus;
    stats.crit_chance += crit_chance_bonus;
    stats.crit_damage += crit_damage_bonus;
    stats.attack_speed += attack_speed_bonus;
    stats.cast_speed += cast_speed_bonus;
    stats.dodge_chance += dodge_chance_bonus;
    stats.block_chance += block_chance_bonus;
    stats.lifesteal += lifesteal_bonus;
    stats.cooldown_reduction += cooldown_reduction_bonus;
    stats.movement_speed += movement_speed_bonus;
}
function aty_get_item_type_text(_item) {
    if (!is_struct(_item)) return "Предмет";
    
    // Для камней
    if (variable_struct_exists(_item, "is_gem") && _item.is_gem) {
        return "Камень";
    }
    
    // Для обычных предметов
    if (variable_struct_exists(_item, "item_type")) {
        switch (_item.item_type) {
            case ITEM_TYPE.WEAPON: return "Оружие";
            case ITEM_TYPE.ARMOR: return "Броня";
            case ITEM_TYPE.ACCESSORY: return "Аксессуар";
            case ITEM_TYPE.TRINKET: return "Тринит";
            case ITEM_TYPE.CHARM: return "Амулет";
            default: return "Предмет";
        }
    }
    
    // Для старых предметов с полем slot
    if (variable_struct_exists(_item, "slot")) {
        return _item.slot;
    }
    
    return "Предмет";
}

function aty_get_item_stats_text(_item) {
    if (!is_struct(_item) || !variable_struct_exists(_item, "stats")) return "";
    
    var stats = _item.stats;
    var text = "";
    
    if (variable_struct_exists(stats, "attack_power") && stats.attack_power > 0) {
        text += "+" + string(stats.attack_power) + "АТК ";
    }
    if (variable_struct_exists(stats, "magic_power") && stats.magic_power > 0) {
        text += "+" + string(stats.magic_power) + "МАГ ";
    }
    if (variable_struct_exists(stats, "defense") && stats.defense > 0) {
        text += "+" + string(stats.defense) + "ЗЩТ";
    }
    
    return text;
}

// =============================================================================
// SIMPLE STATS TEXT FUNCTION
// =============================================================================
function aty_get_short_stats_text(_item) {
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
function aty_convert_stat_key_to_enum(_stat_key) {
    switch (_stat_key) {
        case "health": return HERO_STAT.HEALTH;
        case "mana": return HERO_STAT.MANA;
        case "atk": return HERO_STAT.ATTACK_POWER;
        case "matk": return HERO_STAT.MAGIC_POWER;
        case "def": return HERO_STAT.DEFENSE;
        case "crit": return HERO_STAT.CRIT_CHANCE;
        case "critdmg": return HERO_STAT.CRIT_DAMAGE;
        case "aspd": return HERO_STAT.ATTACK_SPEED;
        case "castspd": return HERO_STAT.CAST_SPEED;
        case "dodge": return HERO_STAT.DODGE_CHANCE;
        case "block": return HERO_STAT.BLOCK_CHANCE;
        case "lifesteal": return HERO_STAT.LIFESTEAL;
        case "cdr": return HERO_STAT.COOLDOWN_REDUCTION;
        case "ms": return HERO_STAT.MOVEMENT_SPEED;
        default: return -1;
    }
}

// Обновленная функция отрисовки категории трофеев
function _aty_draw_trophy_category(_zone, _category) {
    var colors = global.aty_colors;
    var trophy_db = aty_get_trophy_database();
    
    var trophy_y = _zone.y1 + 10;
    var has_trophies = false;
    
    for (var i = 0; i < array_length(trophy_db); i++) {
        var trophy = trophy_db[i];
        
        if (trophy.category != _category) continue;
        
        has_trophies = true;
        
        if (trophy_y > _zone.y2 - 80) break;
        
        _aty_draw_trophy_details(_zone.x1, trophy_y, _zone.x2, trophy_y + 70, trophy);
        trophy_y += 80;
    }
    
    // Если нет трофеев в категории
    if (!has_trophies) {
        draw_set_color(colors.neon_purple);
        draw_set_halign(fa_center);
        draw_text(_zone.x1 + (_zone.x2 - _zone.x1) / 2, _zone.y1 + 40, "В этой категории пока нет трофеев");
        draw_set_halign(fa_left);
    }
}

// Обновленная функция отрисовки деталей трофея
function _aty_draw_trophy_details(_x1, _y1, _x2, _y2, _trophy) {
    var colors = global.aty_colors;
    var is_unlocked = aty_has_trophy(_trophy.id);
    var progress = aty_get_trophy_progress(_trophy.id);
    
    // Цвет в зависимости от редкости и статуса
    var bg_color = colors.bg_light;
    var border_color = colors.neon_blue;
    
    if (is_unlocked) {
        switch (_trophy.rarity) {
            case TROPHY_RARITY.BRONZE: border_color = make_color_rgb(205, 127, 50); break;
            case TROPHY_RARITY.SILVER: border_color = make_color_rgb(192, 192, 192); break;
            case TROPHY_RARITY.GOLD: border_color = make_color_rgb(255, 215, 0); break;
            case TROPHY_RARITY.PLATINUM: border_color = make_color_rgb(229, 228, 226); break;
            case TROPHY_RARITY.DIAMOND: border_color = make_color_rgb(185, 242, 255); break;
        }
    }
    
    // Панель трофея
    draw_set_color(bg_color);
    draw_rectangle(_x1, _y1, _x2, _y2, false);
    draw_set_color(border_color);
    draw_rectangle(_x1, _y1, _x2, _y2, true);
    
    // Иконка трофея
    draw_set_color(is_unlocked ? border_color : colors.text_muted);
    draw_text(_x1 + 15, _y1 + 15, _trophy.icon);
    
    // Название и описание
    var text_x = _x1 + 50;
    draw_set_color(is_unlocked ? colors.neon_pink : colors.text_muted);
    draw_text(text_x, _y1 + 10, _trophy.name);
    draw_set_color(is_unlocked ? colors.neon_cyan : colors.text_muted);
    draw_text(text_x, _y1 + 30, _trophy.description);
    
    // Прогресс
    draw_set_color(is_unlocked ? colors.neon_green : colors.neon_yellow);
    if (!is_unlocked) {
        draw_text(text_x, _y1 + 50, "Прогресс: " + string(progress) + "/" + string(_trophy.target));
    } else {
        draw_text(text_x, _y1 + 50, "✓ Разблокирован");
    }
    
    // Редкость справа
    draw_set_color(border_color);
    draw_set_halign(fa_right);
    draw_text(_x2 - 10, _y1 + 10, aty_get_trophy_rarity_name(_trophy.rarity));
    draw_set_halign(fa_left);
}
function _aty_draw_abilities_tab_high_res(_zone) {
    var colors = global.aty_colors;
    var scale = global.aty_render_scale;
    
    draw_set_color(colors.neon_blue);
    draw_text_ext(_zone.x1 + 20 * scale, _zone.y1 + 20 * scale, "Пассивные Способности", -1, -1);
    
    var ability_y = _zone.y1 + 50 * scale;
    for (var i = 0; i < array_length(global.aty.hero.passives); i++) {
        if (ability_y < _zone.y2 - 60 * scale) {
            var passive = global.aty.hero.passives[i];
            
            // Неоновая панель способности
            draw_neon_panel_high_res(_zone.x1 + 20 * scale, ability_y, 
                                   _zone.x2 - 20 * scale, ability_y + 50 * scale, "");
            
            draw_set_color(colors.neon_pink);
            draw_text_ext(_zone.x1 + 30 * scale, ability_y + 10 * scale, passive.name, -1, -1);
            draw_set_color(colors.neon_cyan);
            draw_text_ext(_zone.x1 + 30 * scale, ability_y + 30 * scale, passive.description, -1, -1);
            
            ability_y += 70 * scale;
        }
    }
    
    if (array_length(global.aty.hero.passives) == 0) {
        draw_set_color(colors.neon_purple);
        draw_set_halign(fa_center);
        draw_text_ext(_zone.x1 + (_zone.x2 - _zone.x1) / 2, _zone.y1 + 150 * scale, 
                     "Пассивные способности появятся с уровнем", -1, -1);
        draw_set_halign(fa_left);
    }
}
// =============================================================================
// FIXED SHOP TAB DRAWING WITH COMPLETE SAFETY CHECKS
// =============================================================================
function _aty_draw_shop_tab_high_res(_zone) {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) return;
    
    var colors = global.aty_colors;
    var shop = global.aty.shop;
    var scale = global.aty_render_scale;
    
    draw_set_color(colors.neon_blue);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    
    // Заголовок
    draw_text_ext(_zone.x1 + 20 * scale, _zone.y1 + 20 * scale, "Магазин", -1, -1);
    draw_text_ext(_zone.x1 + 20 * scale, _zone.y1 + 45 * scale, "Золото: " + string(global.aty.hero.gold) + " G", -1, -1);
    
    // Кнопка обновления ассортимента
    draw_neon_button_high_res(_zone.x1 + 200 * scale, _zone.y1 + 20 * scale, 
                            _zone.x1 + 350 * scale, _zone.y1 + 50 * scale, 
                            "Обновить (100G)", false, false);
    
    var items_per_row = 4;
    var item_size = 80 * scale;
    var item_spacing = 15 * scale;
    var start_x = _zone.x1 + 20 * scale;
    var start_y = _zone.y1 + 80 * scale;
    
    // Отрисовка товаров в магазине с полной безопасностью
    for (var i = 0; i < array_length(shop.items); i++) {
        var item = shop.items[i];
        
        // Пропускаем невалидные предметы
        if (!is_struct(item)) continue;
        
        var row = i div items_per_row;
        var col = i mod items_per_row;
        
        var item_x = start_x + col * (item_size + item_spacing);
        var item_y = start_y + row * (item_size + item_spacing + 30 * scale);
        
        // Безопасная проверка цены и возможности покупки
        var item_price = 0;
        var can_afford = false;
        if (variable_struct_exists(item, "price") && is_real(item.price)) {
            item_price = item.price;
            can_afford = global.aty.hero.gold >= item_price;
        }
        
        // Безопасное определение цвета по редкости
        var item_color = colors.neon_blue; // цвет по умолчанию
        if (variable_struct_exists(item, "rarity") && is_real(item.rarity)) {
            item_color = aty_rarity_color(item.rarity);
        } else if (variable_struct_exists(item, "is_gem") && item.is_gem) {
            // Для камней используем специальный цвет
            item_color = colors.neon_purple;
        }
        
        // Если предмет недоступен, используем красный цвет
        if (!can_afford) {
            item_color = colors.neon_red;
        }
        
        // Неоновая рамка предмета
        draw_neon_rectangle_high_res(item_x, item_y, item_x + item_size, item_y + item_size, item_color, true);
        
        // Название предмета с проверкой
        draw_set_color(colors.text_primary);
        var item_name = "Предмет";
        if (variable_struct_exists(item, "name") && is_string(item.name)) {
            item_name = item.name;
        }
        
        var name_width = string_width(item_name);
        var max_name_width = item_size - 10 * scale;
        
        if (name_width > max_name_width) {
            var short_name = string_copy(item_name, 1, 8) + "...";
            draw_text_ext(item_x + 5 * scale, item_y + 5 * scale, short_name, -1, -1);
        } else {
            draw_text_ext(item_x + 5 * scale, item_y + 5 * scale, item_name, -1, -1);
        }
        
        // Тип предмета с проверкой
        draw_set_color(colors.neon_cyan);
        var type_text = aty_get_item_type_text(item);
        draw_text_ext(item_x + 5 * scale, item_y + 25 * scale, type_text, -1, -1);
        
        // Бонусы с проверкой
        draw_set_color(colors.neon_green);
        var stats_text = aty_get_item_stats_text(item);
        
        if (stats_text != "") {
            var stats_width = string_width(stats_text);
            var stats_x = item_x + (item_size - stats_width) / 2;
            draw_text_ext(stats_x, item_y + 45 * scale, stats_text, -1, -1);
        }
        
        // Цена с проверкой
        draw_set_color(can_afford ? colors.neon_yellow : colors.neon_red);
        draw_text_ext(item_x + 5 * scale, item_y + 65 * scale, string(item_price) + "G", -1, -1);
    }
    
    // Если магазин пуст
    if (array_length(shop.items) == 0) {
        draw_set_color(colors.neon_purple);
        draw_set_halign(fa_center);
        draw_text_ext(_zone.x1 + (_zone.x2 - _zone.x1) / 2, start_y + 50 * scale, 
                     "Магазин пуст - обновите ассортимент!", -1, -1);
        draw_set_halign(fa_left);
    }
    
    // Подсказка
    draw_set_color(colors.neon_blue);
    draw_set_halign(fa_center);
    draw_text_ext(_zone.x1 + (_zone.x2 - _zone.x1) / 2, _zone.y2 - 30 * scale, 
                 "Кликните на предмет чтобы купить", -1, -1);
    draw_set_halign(fa_left);
}
function _aty_draw_statistics_tab_high_res(_zone) {
    var colors = global.aty_colors;
    var scale = global.aty_render_scale;
    
    draw_set_color(colors.neon_blue);
    
    // Кнопки "Сохранить" и "Загрузить"
    draw_neon_button_high_res(_zone.x1 + 20 * scale, _zone.y1 + 20 * scale, 
                            _zone.x1 + 140 * scale, _zone.y1 + 60 * scale, 
                            "Сохранить", false, false);
    draw_neon_button_high_res(_zone.x1 + 160 * scale, _zone.y1 + 20 * scale, 
                            _zone.x1 + 280 * scale, _zone.y1 + 60 * scale, 
                            "Загрузить", false, false);
    
    // Статистика
    var stats_y = _zone.y1 + 80 * scale;
    draw_text_ext(_zone.x1 + 20 * scale, stats_y, "Статистика Игры", -1, -1);
    draw_set_color(colors.neon_cyan);
    
    stats_y += 30 * scale;
    draw_text_ext(_zone.x1 + 20 * scale, stats_y, "Уровень героя: " + string(global.aty.hero.level), -1, -1);
    stats_y += 25 * scale;
    draw_text_ext(_zone.x1 + 20 * scale, stats_y, "Золото: " + string(global.aty.hero.gold) + " G", -1, -1);
    stats_y += 25 * scale;
    draw_text_ext(_zone.x1 + 20 * scale, stats_y, "Предметов в инвентаре: " + string(array_length(global.aty.inventory)), -1, -1);
    stats_y += 25 * scale;
    draw_text_ext(_zone.x1 + 20 * scale, stats_y, "Разблокировано арен: " + string(array_length(global.aty.arenas.unlocked)), -1, -1);
    stats_y += 25 * scale;
    draw_text_ext(_zone.x1 + 20 * scale, stats_y, "Пассивных способностей: " + string(array_length(global.aty.hero.passives)), -1, -1);
    stats_y += 25 * scale;
    
    // Статистика экспедиций
    var completed_expeditions = 0;
    for (var i = 0; i < array_length(global.aty.expeditions); i++) {
        if (global.aty.expeditions[i].completed) completed_expeditions++;
    }
    draw_text_ext(_zone.x1 + 20 * scale, stats_y, "Завершено экспедиций: " + string(completed_expeditions) + "/5", -1, -1);
}

// =============================================================================
// ADDITIONAL UTILITY FUNCTION FOR HIGH-RES
// =============================================================================

function aty_get_spec_name(_spec_type) {
    switch (_spec_type) {
        case SPECIALIZATION.WARRIOR: return "Воин";
        case SPECIALIZATION.ROGUE: return "Разбойник";
        case SPECIALIZATION.MAGE: return "Маг";
        case SPECIALIZATION.RANGER: return "Лучник";
        case SPECIALIZATION.PALADIN: return "Паладин";
        case SPECIALIZATION.BERSERKER: return "Берсерк";
        default: return "Неизвестно";
    }
}
// Добавляем недостающие функции для высокого разрешения
function _aty_draw_top_zone_high_res() {
    var scale = global.aty_render_scale;
    var aty = global.aty;
    var zones = aty.ui_zones;
    var colors = global.aty_colors;
    
    // Фон верхней зоны
    draw_neon_panel_high_res(zones.top.x1 * scale, zones.top.y1 * scale, 
                           zones.top.x2 * scale, zones.top.y2 * scale, "Тренировочные Арены");
    
    var button_width = 250 * scale;
    var button_height = 120 * scale;
    var button_spacing = 20 * scale;
    
    for (var i = 0; i < 3; i++) {
        var button_x = zones.top.x1 * scale + 30 * scale + i * (button_width + button_spacing);
        var button_y = zones.top.y1 * scale + 50 * scale;
        
        var companion = aty.companions[i];
        var is_unlocked = array_contains(aty.arenas.unlocked, i);
        
        // Неоновая кнопка арены
        draw_neon_button_high_res(button_x, button_y, button_x + button_width, button_y + button_height, 
                                companion.name, is_unlocked, !is_unlocked);
        
        // Дополнительная информация
        draw_set_color(is_unlocked ? colors.neon_green : colors.neon_red);
        draw_text_ext(button_x + 15 * scale, button_y + 40 * scale, 
                     is_unlocked ? "✓ Доступна" : "✗ Заблокирована", -1, -1);
        draw_set_color(colors.neon_cyan);
        draw_text_ext(button_x + 15 * scale, button_y + 60 * scale, "Ранг: " + string(companion.rank), -1, -1);
        draw_text_ext(button_x + 15 * scale, button_y + 80 * scale, "Уровень: " + string(companion.level), -1, -1);
        
        // Прогресс тренировки если есть
        if (companion.training_progress > 0) {
            draw_set_color(colors.neon_pink);
            draw_text_ext(button_x + 15 * scale, button_y + 100 * scale, 
                         "Тренировка: " + string(floor(companion.training_progress)) + "%", -1, -1);
        }
    }
}
function _aty_draw_middle_zone_high_res() {
    var scale = global.aty_render_scale;
    var zones = global.aty.ui_zones;
    var colors = global.aty_colors;
    
    // Проверяем активен ли рейд-босс ПЕРЕД отрисовкой стандартного интерфейса
    if (variable_struct_exists(global.aty, "raid_boss") && global.aty.raid_boss.active) {
        aty_draw_raid_boss_ui();
        return; // Не рисуем стандартный интерфейс экспедиции
    }
    // Фон с параллакс-эффектом
    draw_set_color(colors.bg_medium);
    draw_rectangle(zones.middle.x1 * scale, zones.middle.y1 * scale, 
                   zones.middle.x2 * scale, zones.middle.y2 * scale, false);
    
    // Параллакс слои (аналогично обычной версии, но с масштабированием)
    var time = global.aty.vfx.time;
    
    draw_set_color(colors.neon_cyan);
    draw_set_alpha(0.3);
    for (var i = 0; i < 20; i++) {
        var xx = zones.middle.x1 * scale + (sin(time * 0.5 + i) * 50 * scale + i * 40 * scale) mod ((zones.middle.x2 - zones.middle.x1) * scale);
        var yy = zones.middle.y1 * scale + (cos(time * 0.3 + i) * 30 * scale + i * 35 * scale) mod ((zones.middle.y2 - zones.middle.y1) * scale);
        draw_circle(xx, yy, 1 * scale, false);
    }
    
    // Остальные слои аналогично...
    draw_set_alpha(1);
    
    // Контент в зависимости от состояния
    if (global.aty.expedition.active) {
        _aty_draw_expedition_progress_high_res();
    } else {
        _aty_draw_idle_state_high_res();
    }
    
    // VFX поверх всего
    aty_vfx_draw(zones.middle.x1 * scale, zones.middle.y1 * scale, 
                 (zones.middle.x2 - zones.middle.x1) * scale, 
                 (zones.middle.y2 - zones.middle.y1) * scale,
                 global.aty.expedition.progress);
}
// Аналогично обновляем функцию для высокого разрешения
function _aty_draw_expedition_progress_high_res() {
    var scale = global.aty_render_scale;
    var zones = global.aty.ui_zones;
    var colors = global.aty_colors;
    var middle_zone = zones.middle;
    
    var center_x = (middle_zone.x1 + middle_zone.x2) * scale / 2;
    var center_y = (middle_zone.y1 + middle_zone.y2) * scale / 2;
    
    var expedition = global.aty.expeditions[global.aty.current_expedition];
    
    // Панель прогресса экспедиции
    draw_neon_panel_high_res(center_x - 200 * scale, center_y - 120 * scale, 
                           center_x + 200 * scale, center_y + 120 * scale, 
                           "Экспедиция: " + expedition.name);
    
    // Информация об экспедиции
    draw_set_color(colors.neon_cyan);
    draw_set_halign(fa_center);
    draw_text_ext(center_x, center_y - 80 * scale, "Сложность: Уровень " + string(expedition.difficulty), -1, -1);
    draw_text_ext(center_x, center_y - 60 * scale, "Требуемый уровень: " + string(expedition.required_level), -1, -1);
    draw_text_ext(center_x, center_y - 40 * scale, "Награда: " + string(expedition.gold_reward) + " золота", -1, -1);
    
    // Полоса прогресса
    var bar_width = 350 * scale;
    var bar_height = 25 * scale;
    var bar_x = center_x - bar_width / 2;
    var bar_y = center_y - 10 * scale;
    
    // Фон полосы
    draw_set_color(colors.bg_light);
    draw_rectangle(bar_x, bar_y, bar_x + bar_width, bar_y + bar_height, false);
    
    // Заполнение
    var progress = global.aty.expedition.progress;
    draw_set_color(colors.neon_green);
    draw_rectangle(bar_x, bar_y, bar_x + bar_width * progress, bar_y + bar_height, false);
    
    // Рамка
    draw_set_color(colors.neon_blue);
    draw_rectangle(bar_x, bar_y, bar_x + bar_width, bar_y + bar_height, true);
    
    // Текст прогресса
    draw_set_color(colors.text_primary);
    draw_text_ext(center_x, bar_y - 25 * scale, "Прогресс: " + string(floor(progress * 100)) + "%", -1, -1);
    draw_text_ext(center_x, bar_y + 30 * scale, "Осталось: " + string(ceil(global.aty.expedition.timer)) + "с", -1, -1);
    
    // Специальное событие
    if (global.aty.expedition.special_event) {
        draw_set_color(colors.neon_yellow);
        draw_text_ext(center_x, center_y + 60 * scale, "⚡ Произошло что-то интересное! ⚡", -1, -1);
    }
    
    // Активные баффы во время экспедиции
    if (array_length(global.aty.expedition.active_buffs) > 0) {
        draw_set_color(colors.neon_purple);
        draw_text_ext(center_x, center_y + 90 * scale, "Активные баффы:", -1, -1);
        
        var buff_y = center_y + 110 * scale;
        for (var i = 0; i < array_length(global.aty.expedition.active_buffs); i++) {
            var buff = global.aty.expedition.active_buffs[i];
            draw_set_color(colors.neon_cyan);
            draw_text_ext(center_x, buff_y, "• " + buff.name + " - " + buff.description, -1, -1);
            buff_y += 20 * scale;
        }
    }
    
    draw_set_halign(fa_left);
}

// Обновляем функцию _aty_draw_idle_state_high_res() аналогично:
function _aty_draw_idle_state_high_res() {
    var scale = global.aty_render_scale;
    var zones = global.aty.ui_zones;
    var colors = global.aty_colors;
    var middle_zone = zones.middle;
    
    var center_x = (middle_zone.x1 + middle_zone.x2) * scale / 2;
    var center_y = (middle_zone.y1 + middle_zone.y2) * scale / 2;
    
    draw_set_color(colors.neon_cyan);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    
    draw_text_ext(center_x, center_y - 100 * scale, "🏰 Главный Лагерь 🏰", -1, -1);
    draw_set_color(colors.text_secondary);
    draw_text_ext(center_x, center_y - 70 * scale, "Отряд отдыхает и готовится", -1, -1);
    draw_text_ext(center_x, center_y - 50 * scale, "к новым приключениям", -1, -1);
    
    // Отображение активных баффов с проверкой
    if (variable_struct_exists(global.aty.expedition, "active_buffs") && 
        aty_safe_array_length(global.aty.expedition.active_buffs) > 0) {
        draw_set_color(colors.neon_green);
        draw_text_ext(center_x, center_y - 20 * scale, "Активные баффы:", -1, -1);
        
        var buff_y = center_y + 10 * scale;
        for (var i = 0; i < aty_safe_array_length(global.aty.expedition.active_buffs); i++) {
            var buff = global.aty.expedition.active_buffs[i];
            draw_set_color(colors.neon_cyan);
            draw_text_ext(center_x, buff_y, "• " + buff.name, -1, -1);
            buff_y += 20 * scale;
        }
    }
    

    // Кнопки выбора экспедиций - ДОБАВЛЕНА КНОПКА РЕЙД-БОССА
    draw_set_color(colors.neon_pink);
    draw_text_ext(center_x, center_y + 60 * scale, "Выберите экспедицию:", -1, -1);
    
    var expedition_button_width = 150 * scale;
    var expedition_button_height = 40 * scale;
    var expedition_spacing = 20 * scale;
    var total_width = 6 * expedition_button_width + 5 * expedition_spacing; // Изменено с 5 на 6
    var start_x = center_x - total_width / 2;
    var button_y = center_y + 100 * scale;
    
    // Обычные экспедиции (уровни 1-5)
    for (var i = 1; i <= 5; i++) {
        var button_x = start_x + (i-1) * (expedition_button_width + expedition_spacing);
        var expedition = global.aty.expeditions[i-1];
        var can_start = global.aty.hero.level >= expedition.required_level;
        var is_completed = expedition.completed;
        
        var button_text = "Ур. " + string(i);
        if (!can_start) {
            button_text += "\nТреб. ур. " + string(expedition.required_level);
        }
        
        var button_color = colors.neon_blue;
        if (!can_start) {
            button_color = colors.neon_red;
        } else if (is_completed) {
            button_color = colors.neon_green;
        }
        
        draw_neon_button_high_res(button_x, button_y, 
                                button_x + expedition_button_width, 
                                button_y + expedition_button_height, 
                                button_text, false, !can_start);
        
        draw_set_color(colors.neon_cyan);
        draw_set_halign(fa_center);
        draw_text_ext(button_x + expedition_button_width/2, button_y + expedition_button_height + 15 * scale, 
                     expedition.name, -1, -1);
        draw_set_color(colors.neon_yellow);
        draw_text_ext(button_x + expedition_button_width/2, button_y + expedition_button_height + 30 * scale, 
                     "Награда: " + string(expedition.gold_reward) + " золота", -1, -1);
        draw_set_color(colors.text_secondary);
        draw_text_ext(button_x + expedition_button_width/2, button_y + expedition_button_height + 45 * scale, 
                     "Длительность: " + string(expedition.duration) + "с", -1, -1);
    }
    
    // КНОПКА РЕЙД-БОССА (уровень 6)
    var raid_button_x = start_x + 5 * (expedition_button_width + expedition_spacing);
    var raid_expedition = global.aty.expeditions[5]; // 6-я экспедиция (индекс 5)
    
    // ПРЯМАЯ ПРОВЕРКА УСЛОВИЙ ДОСТУПА К РЕЙД-БОССУ
    var raid_unlocked = true;
    for (var j = 0; j < 5; j++) {
        if (!global.aty.expeditions[j].completed) {
            raid_unlocked = false;
            break;
        }
    }
    var raid_can_start = global.aty.hero.level >= raid_expedition.required_level && raid_unlocked;
    
    var raid_button_color = raid_can_start ? colors.neon_purple : colors.neon_red;
    var raid_button_text = "Ур. 6\nРЕЙД-БОСС";
    if (!raid_can_start) {
        if (!raid_unlocked) {
            raid_button_text += "\nТребуются все\nпред. экспедиции";
        } else {
            raid_button_text += "\nТреб. ур. " + string(raid_expedition.required_level);
        }
    }
    
    draw_neon_button_high_res(raid_button_x, button_y, 
                            raid_button_x + expedition_button_width, 
                            button_y + expedition_button_height, 
                            raid_button_text, false, !raid_can_start);
    
    draw_set_color(colors.neon_purple);
    draw_set_halign(fa_center);
    draw_text_ext(raid_button_x + expedition_button_width/2, button_y + expedition_button_height + 15 * scale, 
                 raid_expedition.name, -1, -1);
    draw_set_color(colors.neon_yellow);
    draw_text_ext(raid_button_x + expedition_button_width/2, button_y + expedition_button_height + 30 * scale, 
                 "Награда: " + string(raid_expedition.gold_reward) + " золота", -1, -1);
    draw_set_color(colors.text_secondary);
    draw_text_ext(raid_button_x + expedition_button_width/2, button_y + expedition_button_height + 45 * scale, 
                 "Длительность: " + string(raid_expedition.duration) + "с", -1, -1);
    
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

function _aty_draw_portraits_high_res() {
    var scale = global.aty_render_scale;
    var aty = global.aty;
    var zones = aty.ui_zones;
    var colors = global.aty_colors;
    
    draw_neon_panel_high_res(zones.portraits.x1 * scale, zones.portraits.y1 * scale, 
                           zones.portraits.x2 * scale, zones.portraits.y2 * scale, "Отряд");
    
    // Портрет героя
    var hero_x = zones.portraits.x1 * scale + 25 * scale;
    var hero_y = zones.portraits.y1 * scale + 50 * scale;
    var portrait_size = 50 * scale;
    
    draw_neon_rectangle_high_res(hero_x, hero_y, hero_x + portrait_size, hero_y + portrait_size, colors.neon_blue, true);
    draw_set_color(colors.neon_cyan);
    draw_text_ext(hero_x, hero_y + portrait_size + 5 * scale, "Герой", -1, -1);
    draw_text_ext(hero_x, hero_y + portrait_size + 25 * scale, "Ур. " + string(aty.hero.level), -1, -1);
    
    // Портреты компаньонов - УМЕНЬШЕНО РАССТОЯНИЕ
    var companion_y = hero_y + portrait_size + 30 * scale; // Было +40
    
    for (var i = 0; i < array_length(aty.companions); i++) {
        var companion = aty.companions[i];
        var companion_color = companion.unlocked ? colors.neon_green : colors.neon_red;
        
        draw_neon_rectangle_high_res(hero_x, companion_y, hero_x + portrait_size, companion_y + portrait_size, 
                                   companion_color, true);
        
        draw_set_color(colors.neon_cyan);
        draw_text_ext(hero_x, companion_y + portrait_size + 5 * scale, companion.name, -1, -1);
        draw_text_ext(hero_x, companion_y + portrait_size + 25 * scale, "Ранг " + string(companion.rank), -1, -1);
        
        draw_set_color(companion.unlocked ? colors.neon_green : colors.neon_red);
        draw_text_ext(hero_x, companion_y + portrait_size + 45 * scale, 
                     companion.unlocked ? "✓ В отряде" : "✗ Заблокирована", -1, -1);
        
        companion_y += portrait_size + 50 * scale; // Было +80 - УМЕНЬШЕНО РАССТОЯНИЕ
    }
}
// =============================================================================
// ADDED MISSING HIGH-RES DRAWING FUNCTIONS
// =============================================================================

function _aty_draw_hero_tab(_zone) {
    var colors = global.aty_colors;
    var hero = global.aty.hero;
    
    draw_set_color(colors.neon_blue);
    draw_text(_zone.x1 + 20, _zone.y1 + 20, "Информация о Герое");
    
    // Основная статистика
    var stats_y = _zone.y1 + 50;
    draw_set_color(colors.neon_cyan);
    draw_text(_zone.x1 + 20, stats_y, "Уровень: " + string(hero.level));
    draw_text(_zone.x1 + 20, stats_y + 25, "Опыт: " + string(hero.exp) + "/" + string(hero.level * 200));
    draw_text(_zone.x1 + 20, stats_y + 50, "Золото: " + string(hero.gold) + " G");
    draw_text(_zone.x1 + 20, stats_y + 75, "Очки характеристик: " + string(hero.stat_points));
    draw_text(_zone.x1 + 20, stats_y + 100, "Очки талантов: " + string(hero.talent_points));
    
    // ОСНОВНЫЕ ХАРАКТЕРИСТИКИ
    var base_x = _zone.x1 + 200;
    stats_y = _zone.y1 + 50;
    
    draw_set_color(colors.neon_pink);
    draw_text(base_x, stats_y, "Основные характеристики:");
    draw_set_color(colors.neon_cyan);
    
    var base_stats = hero.base_stats;
    var stat_keys = ["strength", "agility", "intelligence", "vitality", "dexterity", "luck"];
    var stat_display_names = ["Сила", "Ловкость", "Интеллект", "Телосложение", "Меткость", "Удача"];
    
    for (var i = 0; i < 6; i++) {
        var stat_y = stats_y + 25 + i * 25;
        var stat_value = variable_struct_get(base_stats, stat_keys[i]);
        draw_text(base_x, stat_y, stat_display_names[i] + ": " + string(stat_value));
        
        // Рисуем кнопки "+" если есть очки характеристик
        if (hero.stat_points > 0 && stat_value < 100) {
            draw_neon_button(base_x + 120, stat_y - 5, base_x + 140, stat_y + 15, "+", false, false);
        }
    }
    
    // ВТОРИЧНЫЕ ХАРАКТЕРИСТИКИ
    var sec_x = _zone.x1 + 350;
    stats_y = _zone.y1 + 50;
    
    draw_set_color(colors.neon_pink);
    draw_text(sec_x, stats_y, "Боевые характеристики:");
    draw_set_color(colors.neon_green);
    
    var stats = hero.stats;
    var sec_stat_keys = [
        "health", "mana", "attack_power", "magic_power", "defense", 
        "crit_chance", "crit_damage", "attack_speed", "cast_speed",
        "dodge_chance", "block_chance", "lifesteal", "cooldown_reduction", "movement_speed"
    ];
    var sec_stat_display_names = [
        "Здоровье", "Мана", "Атака", "Магия", "Защита", 
        "Крит %", "Урон крита %", "Скор. атаки", "Скор. кастов",
        "Уклонение %", "Блок %", "Вампиризм %", "Сниж. КД %", "Скорость"
    ];
    
    for (var i = 0; i < 14; i++) {
        if (stats_y + 25 + i * 20 < _zone.y2 - 30) {
            var stat_value = variable_struct_get(stats, sec_stat_keys[i]);
            var display_value = stat_value;
            if (i >= 5 && i <= 12) { // Проценты
                display_value = string(stat_value) + "%";
            } else {
                display_value = string(stat_value);
            }
            draw_text(sec_x, stats_y + 25 + i * 20, sec_stat_display_names[i] + ": " + display_value);
        }
    }
}

// Добавляем функции для высокого разрешения
function draw_neon_panel_high_res(_x1, _y1, _x2, _y2, _header_text) {
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
        draw_text_ext(_x1 + 10, _y1 + 8, _header_text, -1, -1);
    }
}
function draw_neon_rectangle_high_res(_x1, _y1, _x2, _y2, _color, _filled) {
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

function draw_neon_button_high_res(_x1, _y1, _x2, _y2, _text, _is_active, _is_disabled) {
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
        draw_text_ext(center_x, center_y, short_text, -1, -1);
    } else {
        draw_text_ext(center_x, center_y, _text, -1, -1);
    }
    
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

// =============================================================================
// UTILITY FUNCTIONS
// =============================================================================

function struct_count(_struct) {
    if (!is_struct(_struct)) return 0;
    var names = variable_struct_get_names(_struct);
    return array_length(names);
}

function array_contains(_array, _value) {
    if (!is_array(_array)) return false;
    for (var i = 0; i < array_length(_array); i++) {
        if (_array[i] == _value) return true;
    }
    return false;
}
// Добавляем недостающие функции для других вкладок
function _aty_draw_abilities_tab(_zone) {
    var colors = global.aty_colors;
    
    draw_set_color(colors.neon_blue);
    draw_text(_zone.x1 + 20, _zone.y1 + 20, "Пассивные Способности");
    
    var ability_y = _zone.y1 + 50;
    for (var i = 0; i < array_length(global.aty.hero.passives); i++) {
        if (ability_y < _zone.y2 - 60) {
            var passive = global.aty.hero.passives[i];
            
            // Неоновая панель способности
            draw_neon_panel(_zone.x1 + 20, ability_y, _zone.x2 - 20, ability_y + 50, "");
            
            draw_set_color(colors.neon_pink);
            draw_text(_zone.x1 + 30, ability_y + 10, passive.name);
            draw_set_color(colors.neon_cyan);
            draw_text(_zone.x1 + 30, ability_y + 30, passive.description);
            
            ability_y += 70;
        }
    }
    
    if (array_length(global.aty.hero.passives) == 0) {
        draw_set_color(colors.neon_purple);
        draw_set_halign(fa_center);
        draw_text(_zone.x1 + (_zone.x2 - _zone.x1) / 2, _zone.y1 + 150, "Пассивные способности появятся с уровнем");
        draw_set_halign(fa_left);
    }
}

// =============================================================================
// FIXED NORMAL RESOLUTION SHOP TAB
// =============================================================================

function _aty_draw_shop_tab(_zone) {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) return;
    
    var colors = global.aty_colors;
    var shop = global.aty.shop;
    
    draw_set_color(colors.neon_blue);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    
    // Заголовок
    draw_text(_zone.x1 + 20, _zone.y1 + 20, "Магазин");
    draw_text(_zone.x1 + 20, _zone.y1 + 45, "Золото: " + string(global.aty.hero.gold) + " G");
    
    // Кнопка обновления ассортимента
    draw_neon_button(_zone.x1 + 200, _zone.y1 + 20, _zone.x1 + 350, _zone.y1 + 50, "Обновить (100G)", false, false);
    
    var items_per_row = 4;
    var item_size = 80;
    var item_spacing = 15;
    var start_x = _zone.x1 + 20;
    var start_y = _zone.y1 + 80;
    
    // Отрисовка товаров в магазине с полной безопасностью
    for (var i = 0; i < array_length(shop.items); i++) {
        var item = shop.items[i];
        
        // Пропускаем невалидные предметы
        if (!is_struct(item)) continue;
        
        var row = i div items_per_row;
        var col = i mod items_per_row;
        
        var item_x = start_x + col * (item_size + item_spacing);
        var item_y = start_y + row * (item_size + item_spacing + 30);
        
        // Безопасная проверка цены и возможности покупки
        var item_price = 0;
        var can_afford = false;
        if (variable_struct_exists(item, "price") && is_real(item.price)) {
            item_price = item.price;
            can_afford = global.aty.hero.gold >= item_price;
        }
        
        // Безопасное определение цвета по редкости
        var item_color = colors.neon_blue; // цвет по умолчанию
        if (variable_struct_exists(item, "rarity") && is_real(item.rarity)) {
            item_color = aty_rarity_color(item.rarity);
        } else if (variable_struct_exists(item, "is_gem") && item.is_gem) {
            // Для камней используем специальный цвет
            item_color = colors.neon_purple;
        }
        
        // Если предмет недоступен, используем красный цвет
        if (!can_afford) {
            item_color = colors.neon_red;
        }
        
        // Неоновая рамка предмета
        draw_neon_rectangle(item_x, item_y, item_x + item_size, item_y + item_size, item_color, true);
        
        // Название предмета с проверкой
        draw_set_color(colors.text_primary);
        var item_name = "Предмет";
        if (variable_struct_exists(item, "name") && is_string(item.name)) {
            item_name = item.name;
        }
        
        var name_width = string_width(item_name);
        var max_name_width = item_size - 10;
        
        if (name_width > max_name_width) {
            var short_name = string_copy(item_name, 1, 8) + "...";
            draw_text(item_x + 5, item_y + 5, short_name);
        } else {
            draw_text(item_x + 5, item_y + 5, item_name);
        }
        
        // Тип предмета с проверкой
        draw_set_color(colors.neon_cyan);
        var type_text = aty_get_item_type_text(item);
        draw_text(item_x + 5, item_y + 25, type_text);
        
        // Бонусы с проверкой
        draw_set_color(colors.neon_green);
        var stats_text = aty_get_item_stats_text(item);
        
        if (stats_text != "") {
            var stats_width = string_width(stats_text);
            var stats_x = item_x + (item_size - stats_width) / 2;
            draw_text(stats_x, item_y + 45, stats_text);
        }
        
        // Цена с проверкой
        draw_set_color(can_afford ? colors.neon_yellow : colors.neon_red);
        draw_text(item_x + 5, item_y + 65, string(item_price) + "G");
    }
    
    // Если магазин пуст
    if (array_length(shop.items) == 0) {
        draw_set_color(colors.neon_purple);
        draw_set_halign(fa_center);
        draw_text(_zone.x1 + (_zone.x2 - _zone.x1) / 2, start_y + 50, "Магазин пуст - обновите ассортимент!");
        draw_set_halign(fa_left);
    }
    
    // Подсказка
    draw_set_color(colors.neon_blue);
    draw_set_halign(fa_center);
    draw_text(_zone.x1 + (_zone.x2 - _zone.x1) / 2, _zone.y2 - 30, "Кликните на предмет чтобы купить");
    draw_set_halign(fa_left);
}

function _aty_draw_statistics_tab(_zone) {
    var colors = global.aty_colors;
    
    draw_set_color(colors.neon_blue);
    
    // Кнопки "Сохранить" и "Загрузить"
    draw_neon_button(_zone.x1 + 20, _zone.y1 + 20, _zone.x1 + 140, _zone.y1 + 60, "Сохранить", false, false);
    draw_neon_button(_zone.x1 + 160, _zone.y1 + 20, _zone.x1 + 280, _zone.y1 + 60, "Загрузить", false, false);
    
    // Статистика
    var stats_y = _zone.y1 + 80;
    draw_text(_zone.x1 + 20, stats_y, "Статистика Игры");
    draw_set_color(colors.neon_cyan);
    
    stats_y += 30;
    draw_text(_zone.x1 + 20, stats_y, "Уровень героя: " + string(global.aty.hero.level));
    stats_y += 25;
    draw_text(_zone.x1 + 20, stats_y, "Золото: " + string(global.aty.hero.gold) + " G");
    stats_y += 25;
    draw_text(_zone.x1 + 20, stats_y, "Предметов в инвентаре: " + string(array_length(global.aty.inventory)));
    stats_y += 25;
    draw_text(_zone.x1 + 20, stats_y, "Разблокировано арен: " + string(array_length(global.aty.arenas.unlocked)));
    stats_y += 25;
    draw_text(_zone.x1 + 20, stats_y, "Пассивных способностей: " + string(array_length(global.aty.hero.passives)));
    stats_y += 25;
    
    // Статистика экспедиций
    var completed_expeditions = 0;
    for (var i = 0; i < array_length(global.aty.expeditions); i++) {
        if (global.aty.expeditions[i].completed) completed_expeditions++;
    }
    draw_text(_zone.x1 + 20, stats_y, "Завершено экспедиций: " + string(completed_expeditions) + "/5");
}
// =============================================================================
// ULTRA-SAFE RARITY COLOR FUNCTION
// =============================================================================
function aty_rarity_color(_rarity) {
    // ЕСЛИ ГЛОБАЛЬНЫЕ ЦВЕТА НЕ ИНИЦИАЛИЗИРОВАНЫ, ВОЗВРАЩАЕМ БЕЛЫЙ
    if (!variable_struct_exists(global, "aty_colors") || !is_struct(global.aty_colors)) {
        return c_white;
    }
    
    var colors = global.aty_colors;
    
    // ЕСЛИ RARITY - СТРОКА, ПРЕОБРАЗУЕМ В ЧИСЛО
    if (is_string(_rarity)) {
        switch (_rarity) {
            case "COMMON": _rarity = 0; break;
            case "UNCOMMON": _rarity = 1; break;
            case "RARE": _rarity = 2; break;
            case "EPIC": _rarity = 3; break;
            case "LEGENDARY": _rarity = 4; break;
            case "MYTHIC": _rarity = 5; break;
            case "DIVINE": _rarity = 6; break;
            default: _rarity = 0; break;
        }
    }
    
    // ПРОВЕРЯЕМ ЧТО RARITY - ЧИСЛО
    if (!is_real(_rarity)) {
        return colors.rarity_common;
    }
    
    // ВОЗВРАЩАЕМ ЦВЕТ ПО РЕДКОСТИ
    if (_rarity == 0) return colors.rarity_common;
    else if (_rarity == 1) return colors.rarity_uncommon;
    else if (_rarity == 2) return colors.rarity_rare;
    else if (_rarity == 3) return colors.rarity_epic;
    else if (_rarity == 4) return colors.rarity_legendary;
    else if (_rarity == 5) return colors.rarity_mythic;
    else if (_rarity == 6) return colors.rarity_divine;
    else return colors.rarity_common;
}
// =============================================================================
function aty_init_colors() {
    if (!variable_global_exists("aty_colors")) {
        global.aty_colors = {
            // Основные цвета
            bg_dark: make_color_rgb(15, 15, 25),
            bg_medium: make_color_rgb(30, 30, 45),
            bg_light: make_color_rgb(50, 50, 70),
            bg_lighter: make_color_rgb(70, 70, 90),
            
            // Текстовые цвета
            text_primary: make_color_rgb(255, 255, 255),
            text_secondary: make_color_rgb(180, 180, 200),
            text_light: make_color_rgb(240, 240, 255),
            text_accent: make_color_rgb(100, 200, 255),
            text_muted: make_color_rgb(120, 120, 150),
            
            // Акцентные цвета
            accent: make_color_rgb(0, 150, 255),
            accent_light: make_color_rgb(100, 200, 255),
            accent_dark: make_color_rgb(0, 100, 200),
            
            // Статусные цвета
            success: make_color_rgb(0, 200, 100),
            warning: make_color_rgb(255, 200, 0),
            error: make_color_rgb(255, 80, 80),
            info: make_color_rgb(100, 150, 255),
            
            // Неоновые цвета (полный набор)
            neon_blue: make_color_rgb(0, 200, 255),
            neon_green: make_color_rgb(0, 255, 150),
            neon_red: make_color_rgb(255, 50, 100),
            neon_yellow: make_color_rgb(255, 255, 0),
            neon_purple: make_color_rgb(180, 70, 255),
            neon_cyan: make_color_rgb(0, 255, 255),
            neon_orange: make_color_rgb(255, 150, 0),
            neon_pink: make_color_rgb(255, 100, 200), // Добавляем neon_pink
            neon_white: make_color_rgb(255, 255, 255),
            neon_gray: make_color_rgb(150, 150, 150),
            
            // Цвета редкости
            rarity_common: make_color_rgb(200, 200, 200),
            rarity_uncommon: make_color_rgb(0, 200, 0),
            rarity_rare: make_color_rgb(0, 100, 255),
            rarity_epic: make_color_rgb(180, 0, 255),
            rarity_legendary: make_color_rgb(255, 150, 0),
            rarity_mythic: make_color_rgb(255, 50, 50),
            
            // Цвета состояния квестов
            quest_available: make_color_rgb(100, 200, 100),
            quest_active: make_color_rgb(100, 150, 255),
            quest_completed: make_color_rgb(200, 200, 100),
            quest_failed: make_color_rgb(255, 100, 100),
            quest_claimed: make_color_rgb(150, 150, 200),
            
            // Границы и разделители
            border: make_color_rgb(80, 80, 120),
            border_light: make_color_rgb(100, 100, 140),
            border_dark: make_color_rgb(60, 60, 90),
            
            // Специальные эффекты
            glow_blue: make_color_rgb(0, 100, 200),
            glow_green: make_color_rgb(0, 150, 100),
            glow_red: make_color_rgb(200, 0, 50),
            glow_yellow: make_color_rgb(200, 150, 0),
            glow_purple: make_color_rgb(150, 0, 200),
            
            // Цвета для характеристик героя
            stat_strength: make_color_rgb(255, 100, 100),
            stat_agility: make_color_rgb(100, 255, 100),
            stat_intelligence: make_color_rgb(100, 150, 255),
            stat_vitality: make_color_rgb(255, 200, 100),
            stat_luck: make_color_rgb(200, 100, 255),
            
            // Цвета для здоровья и маны
            health: make_color_rgb(255, 50, 50),
            mana: make_color_rgb(50, 100, 255),
            stamina: make_color_rgb(50, 200, 100),
            
            // Дополнительные цвета UI
            ui_highlight: make_color_rgb(100, 150, 255),
            ui_selected: make_color_rgb(0, 150, 255),
            ui_disabled: make_color_rgb(80, 80, 100)
        };
    }
}
function aty_create_minigame_struct() {
    return {
        active: false,
        type: MINIGAME_TYPE.NONE,
        difficulty: 1,
        timer: 0,
        progress: 0,
        score: 0,
        target_score: 10,
        sequence: [],
        current_sequence_index: 0,
        targets: [],
        rhythm_pattern: [],
        current_rhythm_index: 0,
        slots: [0, 0, 0],
        spin_timer: 0,
        result: MINIGAME_RESULT.FAILED
    };
}

// =============================================================================
// MINI-GAME EVENT DATABASE
// =============================================================================

function aty_get_minigame_events_database() {
    return [
        {
            id: "qte_chest",
            name: "Загадочный сундук",
            description: "Сундук защищен магическим замком! Быстро нажмите указанные клавиши!",
            minigame_type: MINIGAME_TYPE.QUICK_TIME_EVENT,
            difficulty_range: [1, 3],
            rewards: {
                success: { gold: 50, items: [RARITY.UNCOMMON] },
                critical: { gold: 100, items: [RARITY.RARE] }
            },
            weight: 15
        },
        {
            id: "memory_rune", 
            name: "Древние руны",
            description: "Запомните последовательность магических рун и повторите её!",
            minigame_type: MINIGAME_TYPE.MEMORY_SEQUENCE,
            difficulty_range: [1, 4],
            rewards: {
                success: { gold: 75, items: [RARITY.UNCOMMON, RARITY.RARE] },
                critical: { gold: 150, items: [RARITY.EPIC] }
            },
            weight: 12
        },
        {
            id: "target_practice",
            name: "Тренировка меткости", 
            description: "Поразите движущиеся мишени! У вас ограниченное время!",
            minigame_type: MINIGAME_TYPE.TARGET_PRACTICE,
            difficulty_range: [1, 3],
            rewards: {
                success: { gold: 60, exp: 25 },
                critical: { gold: 120, exp: 50, items: [RARITY.RARE] }
            },
            weight: 10
        },
        {
            id: "rhythm_drums",
            name: "Барабаны шамана",
            description: "Повторите ритмичный рисунок в такт барабанам!",
            minigame_type: MINIGAME_TYPE.RHYTHM_TAP,
            difficulty_range: [1, 3], 
            rewards: {
                success: { gold: 40, buffs: ["HASTE"] },
                critical: { gold: 80, buffs: ["HASTE", "BERSERKER"] }
            },
            weight: 8
        },
        {
            id: "slot_machine",
            name: "Магический автомат",
            description: "Испытайте удачу в магическом автомате!",
            minigame_type: MINIGAME_TYPE.SLOT_MACHINE,
            difficulty_range: [1, 2],
            rewards: {
                success: { gold: 30 },
                critical: { gold: 200, items: [RARITY.LEGENDARY] }
            },
            weight: 5
        }
    ];
}

// =============================================================================
// MINI-GAME TRIGGER SYSTEM
// =============================================================================

function aty_check_minigame_trigger() {
    if (!global.aty.expedition.active) return false;
    
    // Шанс триггера мини-игры зависит от прогресса экспедиции
    var trigger_chance = 0.15 + (global.aty.expedition.progress * 0.1);
    
    // Увеличиваем шанс при наличии пассивки Fortune Favors
    var has_fortune_favors = false;
    for (var i = 0; i < array_length(global.aty.hero.passives); i++) {
        if (global.aty.hero.passives[i].effect == PASSIVE_EFFECT.FORTUNE_FAVORS) {
            has_fortune_favors = true;
            break;
        }
    }
    
    if (has_fortune_favors) {
        trigger_chance += 0.1;
    }
    
    return random(1) < trigger_chance;
}

function aty_trigger_random_minigame() {
    if (!global.aty.expedition.active) return false;
    
    var events_db = aty_get_minigame_events_database();
    var total_weight = 0;
    
    // Суммируем веса
    for (var i = 0; i < array_length(events_db); i++) {
        total_weight += events_db[i].weight;
    }
    
    // Выбираем случайное событие
    var random_value = irandom(total_weight - 1);
    var current_weight = 0;
    
    for (var i = 0; i < array_length(events_db); i++) {
        current_weight += events_db[i].weight;
        if (random_value < current_weight) {
            aty_start_minigame(events_db[i]);
            return true;
        }
    }
    
    return false;
}

// =============================================================================
// MINI-GAME START/END FUNCTIONS
// =============================================================================

function aty_start_minigame(_event_data) {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) return false;
    
    // Инициализируем мини-игру если нужно
    if (!variable_struct_exists(global.aty, "minigame")) {
        global.aty.minigame = aty_create_minigame_struct();
    }
    
    var minigame = global.aty.minigame;
    
    // Заполняем данные мини-игры
    minigame.active = true;
    minigame.type = _event_data.minigame_type;
    minigame.difficulty = irandom_range(_event_data.difficulty_range[0], _event_data.difficulty_range[1]);
    minigame.event_data = _event_data;
    minigame.result = MINIGAME_RESULT.FAILED;
    minigame.score = 0;
    minigame.progress = 0;
    
    // Инициализируем в зависимости от типа
    switch (minigame.type) {
        case MINIGAME_TYPE.QUICK_TIME_EVENT:
            aty_init_qte_minigame(minigame);
            break;
        case MINIGAME_TYPE.MEMORY_SEQUENCE:
            aty_init_memory_minigame(minigame);
            break;
        case MINIGAME_TYPE.TARGET_PRACTICE:
            aty_init_target_minigame(minigame);
            break;
        case MINIGAME_TYPE.RHYTHM_TAP:
            aty_init_rhythm_minigame(minigame);
            break;
        case MINIGAME_TYPE.SLOT_MACHINE:
            aty_init_slot_minigame(minigame);
            break;
    }
    
    aty_show_notification("🎮 Мини-игра: " + _event_data.name);
    return true;
}

function aty_end_minigame(_result) {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) return;
    
    var minigame = global.aty.minigame;
    minigame.result = _result;
    minigame.active = false;
    
    // Выдаем награды
    aty_give_minigame_rewards(minigame);
    
    // Показываем результат
    var result_text = "";
    switch (_result) {
        case MINIGAME_RESULT.FAILED:
            result_text = "Мини-игра провалена!";
            break;
        case MINIGAME_RESULT.SUCCESS:
            result_text = "Мини-игра пройдена успешно!";
            break;
        case MINIGAME_RESULT.CRITICAL_SUCCESS:
            result_text = "🎉 Критический успех!";
            break;
    }
    
    aty_show_notification(result_text);
}

// =============================================================================
// MINI-GAME INITIALIZATION FUNCTIONS
// =============================================================================

function aty_init_qte_minigame(_minigame) {
    _minigame.timer = 180 - (_minigame.difficulty * 20); // 3 секунды на сложности 1
    _minigame.target_score = 5 + (_minigame.difficulty * 2);
    _minigame.current_key = aty_get_random_key();
    _minigame.key_timer = 60; // 1 секунда на нажатие каждой клавиши
}

function aty_init_memory_minigame(_minigame) {
    _minigame.timer = 240;
    _minigame.sequence = [];
    _minigame.current_sequence_index = 0;
    
    // Генерируем последовательность
    var sequence_length = 3 + _minigame.difficulty;
    for (var i = 0; i < sequence_length; i++) {
        array_push(_minigame.sequence, irandom(3)); // 0-3 для 4 направлений
    }
    
    _minigame.show_sequence = true;
    _minigame.sequence_timer = 0;
    _minigame.current_sequence_step = 0;
}

function aty_init_target_minigame(_minigame) {
    _minigame.timer = 300;
    _minigame.target_score = 8 + (_minigame.difficulty * 3);
    _minigame.targets = [];
    
    // Создаем начальные мишени
    for (var i = 0; i < 3; i++) {
        aty_create_target(_minigame);
    }
}

function aty_init_rhythm_minigame(_minigame) {
    _minigame.timer = 240;
    _minigame.rhythm_pattern = [];
    _minigame.current_rhythm_index = 0;
    _minigame.target_score = 6 + (_minigame.difficulty * 2);
    
    // Генерируем ритмический паттерн
    var pattern_length = 8 + (_minigame.difficulty * 2);
    for (var i = 0; i < pattern_length; i++) {
        array_push(_minigame.rhythm_pattern, random(1) < 0.7); // 70% шанс что нужно нажать
    }
    
    _minigame.rhythm_timer = 0;
    _minigame.rhythm_speed = 30 - (_minigame.difficulty * 5); // Скорость ритма
}

function aty_init_slot_minigame(_minigame) {
    _minigame.timer = 180;
    _minigame.spin_timer = 0;
    _minigame.spinning = false;
    _minigame.spins_remaining = 3;
    _minigame.slots = [0, 0, 0];
}

// =============================================================================
// MINI-GAME STEP FUNCTIONS
// =============================================================================

function aty_minigame_step(_dt) {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) return;
    if (!global.aty.minigame.active) return;
    
    var minigame = global.aty.minigame;
    minigame.timer -= _dt;
    
    // Проверяем таймер
    if (minigame.timer <= 0) {
        aty_end_minigame(MINIGAME_RESULT.FAILED);
        return;
    }
    
    // Обновляем в зависимости от типа
    switch (minigame.type) {
        case MINIGAME_TYPE.QUICK_TIME_EVENT:
            aty_step_qte_minigame(_dt);
            break;
        case MINIGAME_TYPE.MEMORY_SEQUENCE:
            aty_step_memory_minigame(_dt);
            break;
        case MINIGAME_TYPE.TARGET_PRACTICE:
            aty_step_target_minigame(_dt);
            break;
        case MINIGAME_TYPE.RHYTHM_TAP:
            aty_step_rhythm_minigame(_dt);
            break;
        case MINIGAME_TYPE.SLOT_MACHINE:
            aty_step_slot_minigame(_dt);
            break;
    }
    
    // Проверяем завершение
    if (minigame.score >= minigame.target_score) {
        var result = (minigame.score >= minigame.target_score * 1.5) ? 
                    MINIGAME_RESULT.CRITICAL_SUCCESS : MINIGAME_RESULT.SUCCESS;
        aty_end_minigame(result);
    }
}

function aty_step_qte_minigame(_dt) {
    var minigame = global.aty.minigame;
    minigame.key_timer -= _dt;
    
    // Если время на текущую клавишу истекло
    if (minigame.key_timer <= 0) {
        minigame.key_timer = 60 - (minigame.difficulty * 10); // Меньше времени на высоких сложностях
        minigame.current_key = aty_get_random_key();
    }
}

function aty_step_memory_minigame(_dt) {
    var minigame = global.aty.minigame;
    
    if (minigame.show_sequence) {
        minigame.sequence_timer += _dt;
        
        // Показываем последовательность с задержкой
        if (minigame.sequence_timer >= 60) { // 1 секунда на каждый элемент
            minigame.sequence_timer = 0;
            minigame.current_sequence_step++;
            
            if (minigame.current_sequence_step >= array_length(minigame.sequence)) {
                minigame.show_sequence = false;
                minigame.current_sequence_index = 0;
            }
        }
    }
}

function aty_step_target_minigame(_dt) {
    var minigame = global.aty.minigame;
    
    // Обновляем позиции мишеней
    for (var i = array_length(minigame.targets) - 1; i >= 0; i--) {
        var target = minigame.targets[i];
        target.xx += target.speed_x;
        target.yy += target.speed_y;
        
        // Отскок от границ
        if (target.xx < 50 || target.xx > 450) target.speed_x *= -1;
        if (target.yy < 50 || target.yy > 250) target.speed_y *= -1;
        
        // Уменьшаем время жизни
        target.lifetime -= _dt;
        if (target.lifetime <= 0) {
            array_delete(minigame.targets, i, 1);
        }
    }
    
    // Добавляем новые мишени
    if (array_length(minigame.targets) < 3 + minigame.difficulty && random(1) < 0.02) {
        aty_create_target(minigame);
    }
}

function aty_step_rhythm_minigame(_dt) {
    var minigame = global.aty.minigame;
    minigame.rhythm_timer += _dt;
    
    // Переход к следующей ноте в ритме
    if (minigame.rhythm_timer >= minigame.rhythm_speed) {
        minigame.rhythm_timer = 0;
        minigame.current_rhythm_index = (minigame.current_rhythm_index + 1) % array_length(minigame.rhythm_pattern);
    }
}

function aty_step_slot_minigame(_dt) {
    var minigame = global.aty.minigame;
    
    if (minigame.spinning) {
        minigame.spin_timer -= _dt;
        
        if (minigame.spin_timer <= 0) {
            minigame.spinning = false;
            aty_check_slot_result(minigame);
        }
    }
}

// =============================================================================
// MINI-GAME INPUT HANDLING
// =============================================================================

function aty_handle_minigame_input(_key) {
    if (!global.aty.minigame.active) return false;
    
    var minigame = global.aty.minigame;
    var handled = false;
    
    switch (minigame.type) {
        case MINIGAME_TYPE.QUICK_TIME_EVENT:
            handled = aty_handle_qte_input(_key);
            break;
        case MINIGAME_TYPE.MEMORY_SEQUENCE:
            handled = aty_handle_memory_input(_key);
            break;
        case MINIGAME_TYPE.TARGET_PRACTICE:
            handled = aty_handle_target_input(_key);
            break;
        case MINIGAME_TYPE.RHYTHM_TAP:
            handled = aty_handle_rhythm_input(_key);
            break;
        case MINIGAME_TYPE.SLOT_MACHINE:
            handled = aty_handle_slot_input(_key);
            break;
    }
    
    return handled;
}

function aty_handle_qte_input(_key) {
    var minigame = global.aty.minigame;
    
    if (_key == minigame.current_key) {
        // Правильная клавиша
        minigame.score += 1;
        minigame.key_timer = 60 - (minigame.difficulty * 10);
        minigame.current_key = aty_get_random_key();
        return true;
    }
    
    return false;
}

function aty_handle_memory_input(_key) {
    var minigame = global.aty.minigame;
    
    if (minigame.show_sequence) return false; // Не принимаем ввод во время показа последовательности
    
    var expected_direction = minigame.sequence[minigame.current_sequence_index];
    var input_direction = -1;
    
    // Конвертируем клавишу в направление
    switch (_key) {
        case vk_left: input_direction = 0; break;
        case vk_up: input_direction = 1; break;
        case vk_right: input_direction = 2; break;
        case vk_down: input_direction = 3; break;
    }
    
    if (input_direction == expected_direction) {
        // Правильное направление
        minigame.current_sequence_index++;
        if (minigame.current_sequence_index >= array_length(minigame.sequence)) {
            // Вся последовательность правильно введена
            minigame.score += array_length(minigame.sequence);
            
            // Начинаем новую, более длинную последовательность
            aty_init_memory_minigame(minigame);
        }
        return true;
    } else {
        // Неправильное направление - сбрасываем
        minigame.current_sequence_index = 0;
        return true;
    }
}

function aty_handle_target_input(_key) {
    var minigame = global.aty.minigame;
    
    // Для простоты используем пробел для "выстрела"
    if (_key == vk_space) {
        // Проверяем попадание по мишеням
        for (var i = array_length(minigame.targets) - 1; i >= 0; i--) {
            var target = minigame.targets[i];
            
            // Простая проверка попадания (в реальной игре нужно учитывать позицию мыши)
            if (random(1) < 0.3 + (minigame.difficulty * 0.1)) { // Шанс попадания
                minigame.score += 1;
                array_delete(minigame.targets, i, 1);
                return true;
            }
        }
    }
    
    return false;
}

function aty_handle_rhythm_input(_key) {
    var minigame = global.aty.minigame;
    
    // Используем пробел для такта
    if (_key == vk_space) {
        var should_have_pressed = minigame.rhythm_pattern[minigame.current_rhythm_index];
        
        if (should_have_pressed) {
            minigame.score += 1;
            return true;
        } else {
            // Штраф за нажатие в неподходящее время
            minigame.score = max(0, minigame.score - 1);
            return true;
        }
    }
    
    return false;
}

function aty_handle_slot_input(_key) {
    var minigame = global.aty.minigame;
    
    // Используем пробел для вращения
    if (_key == vk_space && !minigame.spinning && minigame.spins_remaining > 0) {
        minigame.spinning = true;
        minigame.spin_timer = 90; // 1.5 секунды вращения
        minigame.spins_remaining -= 1;
        return true;
    }
    
    return false;
}

// =============================================================================
// MINI-GAME DRAWING FUNCTIONS
// =============================================================================

function aty_draw_minigame() {
    if (!global.aty.minigame.active) return;
    
    var minigame = global.aty.minigame;
    var colors = global.aty_colors;
    
    // Фон мини-игры
    draw_set_color(make_color_rgb(0, 0, 0));
    draw_set_alpha(0.8);
    draw_rectangle(200, 150, 800, 650, false);
    draw_set_alpha(1);
    
    // Рамка
    draw_set_color(colors.neon_pink);
    draw_rectangle(200, 150, 800, 650, true);
    
    // Заголовок
    draw_set_color(colors.neon_cyan);
    draw_set_halign(fa_center);
    draw_text(500, 170, minigame.event_data.name);
    draw_text(500, 200, minigame.event_data.description);
    
    // Таймер
    var time_left = ceil(minigame.timer / room_speed);
    draw_text(500, 230, "Время: " + string(time_left) + "с");
    
    // Отрисовка в зависимости от типа
    switch (minigame.type) {
        case MINIGAME_TYPE.QUICK_TIME_EVENT:
            aty_draw_qte_minigame();
            break;
        case MINIGAME_TYPE.MEMORY_SEQUENCE:
            aty_draw_memory_minigame();
            break;
        case MINIGAME_TYPE.TARGET_PRACTICE:
            aty_draw_target_minigame();
            break;
        case MINIGAME_TYPE.RHYTHM_TAP:
            aty_draw_rhythm_minigame();
            break;
        case MINIGAME_TYPE.SLOT_MACHINE:
            aty_draw_slot_minigame();
            break;
    }
    
    // Прогресс
    draw_set_color(colors.neon_green);
    draw_text(500, 620, "Счет: " + string(minigame.score) + " / " + string(minigame.target_score));
    
    // Подсказка управления
    draw_set_color(colors.text_muted);
    draw_text(500, 640, "ESC - пропустить мини-игру");
    
    draw_set_halign(fa_left);
}

function aty_draw_qte_minigame() {
    var minigame = global.aty.minigame;
    var colors = global.aty_colors;
    
    var center_x = 500;
    var center_y = 400;
    
    // Отображаем текущую клавишу
    draw_set_color(colors.neon_yellow);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(center_x, center_y - 50, "Быстро нажмите:");
    
    // Большое отображение клавиши
    draw_set_color(colors.neon_pink);
    draw_rectangle(center_x - 40, center_y, center_x + 40, center_y + 80, false);
    draw_text(center_x, center_y + 40, chr(minigame.current_key));
    
    // Полоса времени
    var time_ratio = minigame.key_timer / 60;
    draw_set_color(colors.neon_blue);
    draw_rectangle(center_x - 50, center_y + 100, center_x - 50 + (100 * time_ratio), center_y + 110, false);
    
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

function aty_draw_memory_minigame() {
    var minigame = global.aty.minigame;
    var colors = global.aty_colors;
    
    var center_x = 500;
    var center_y = 400;
    
    if (minigame.show_sequence) {
        // Показываем последовательность
        draw_set_color(colors.neon_cyan);
        draw_text(center_x, center_y - 50, "Запоминайте последовательность...");
        
        var current_symbol = minigame.sequence[minigame.current_sequence_step];
        draw_set_color(colors.neon_yellow);
        
        // Отрисовываем текущий символ последовательности
        switch (current_symbol) {
            case 0: draw_text(center_x, center_y, "←"); break;
            case 1: draw_text(center_x, center_y, "↑"); break;
            case 2: draw_text(center_x, center_y, "→"); break;
            case 3: draw_text(center_x, center_y, "↓"); break;
        }
    } else {
        // Ждем ввод от игрока
        draw_set_color(colors.neon_green);
        draw_text(center_x, center_y - 50, "Повторите последовательность!");
        draw_text(center_x, center_y, "Используйте стрелки");
        
        // Показываем прогресс
        draw_text(center_x, center_y + 50, 
                 "Прогресс: " + string(minigame.current_sequence_index) + 
                 " / " + string(array_length(minigame.sequence)));
    }
}

function aty_draw_target_minigame() {
    var minigame = global.aty.minigame;
    var colors = global.aty_colors;
    
    // Отрисовываем мишени
    for (var i = 0; i < array_length(minigame.targets); i++) {
        var target = minigame.targets[i];
        
        // Цвет в зависимости от времени жизни
        var alpha = target.lifetime / 180; // 3 секунды жизни
        draw_set_alpha(alpha);
        
        draw_set_color(colors.neon_red);
        draw_circle(target.x, target.y, 15, false);
        
        draw_set_color(colors.neon_yellow);
        draw_circle(target.x, target.y, 8, false);
        
        draw_set_alpha(1);
    }
    
    draw_set_color(colors.neon_cyan);
    draw_set_halign(fa_center);
    draw_text(500, 350, "Нажимайте ПРОБЕЛ чтобы стрелять!");
    draw_set_halign(fa_left);
}

function aty_draw_rhythm_minigame() {
    var minigame = global.aty.minigame;
    var colors = global.aty_colors;
    
    var center_x = 500;
    var center_y = 400;
    
    // Отрисовываем ритмическую дорожку
    for (var i = 0; i < array_length(minigame.rhythm_pattern); i++) {
        var xx = center_x - 200 + (i * 40);
        var yy = center_y;
        var is_current = (i == minigame.current_rhythm_index);
        var should_press = minigame.rhythm_pattern[i];
        
        // Цвет в зависимости от типа и текущей позиции
        if (is_current) {
            draw_set_color(colors.neon_yellow);
        } else if (should_press) {
            draw_set_color(colors.neon_green);
        } else {
            draw_set_color(colors.neon_blue);
        }
        
        draw_rectangle(xx - 15, yy - 15, xx + 15, yy + 15, false);
        
        if (should_press) {
            draw_set_color(colors.neon_pink);
            draw_text(x - 5, y - 10, "X");
        }
    }
    
    draw_set_color(colors.neon_cyan);
    draw_set_halign(fa_center);
    draw_text(center_x, center_y + 50, "Нажимайте ПРОБЕЛ на желвых квадратах!");
    draw_set_halign(fa_left);
}

function aty_draw_slot_minigame() {
    var minigame = global.aty.minigame;
    var colors = global.aty_colors;
    
    var center_x = 500;
    var center_y = 400;
    
    // Отрисовываем слот-машину
    draw_set_color(colors.neon_blue);
    draw_rectangle(center_x - 150, center_y - 50, center_x + 150, center_y + 50, false);
    
    // Слоты
    var symbols = ["🍒", "🍋", "⭐", "🔔", "💎"];
    
    for (var i = 0; i < 3; i++) {
        var xx = center_x - 80 + (i * 80);
        
        if (minigame.spinning) {
            // Вращающийся слот
            var random_symbol = symbols[irandom(array_length(symbols) - 1)];
            draw_set_color(colors.neon_yellow);
            draw_text(xx - 10, center_y - 10, random_symbol);
        } else {
            // Остановленный слот
            var symbol = symbols[minigame.slots[i]];
            draw_set_color(colors.neon_green);
            draw_text(xx - 10, center_y - 10, symbol);
        }
    }
    
    draw_set_color(colors.neon_cyan);
    draw_set_halign(fa_center);
    draw_text(center_x, center_y + 80, "ПРОБЕЛ - крутить (" + string(minigame.spins_remaining) + " осталось)");
    draw_set_halign(fa_left);
}

// =============================================================================
// MINI-GAME UTILITY FUNCTIONS
// =============================================================================

function aty_get_random_key() {
    var keys = [
        ord("A"), ord("B"), ord("C"), ord("D"), ord("E"), 
        ord("F"), ord("G"), ord("H"), ord("I"), ord("J"),
        ord("K"), ord("L"), ord("M"), ord("N"), ord("O"),
        ord("P"), ord("Q"), ord("R"), ord("S"), ord("T"),
        vk_left, vk_right, vk_up, vk_down, vk_space
    ];
    
    return keys[irandom(array_length(keys) - 1)];
}

function aty_create_target(_minigame) {
    var target = {
        xx: irandom_range(100, 400),
        yy: irandom_range(100, 300),
        speed_x: random_range(1, 3) * choose(-1, 1),
        speed_y: random_range(1, 3) * choose(-1, 1),
        lifetime: 180 // 3 секунды
    };
    
    array_push(_minigame.targets, target);
}

function aty_check_slot_result(_minigame) {
    // Генерируем случайные результаты
    for (var i = 0; i < 3; i++) {
        _minigame.slots[i] = irandom(4); // 0-4 для 5 символов
    }
    
    // Проверяем выигрышные комбинации
    if (_minigame.slots[0] == _minigame.slots[1] && _minigame.slots[1] == _minigame.slots[2]) {
        // Три одинаковых символа
        _minigame.score += 10;
    } else if (_minigame.slots[0] == _minigame.slots[1] || _minigame.slots[1] == _minigame.slots[2]) {
        // Два одинаковых символа
        _minigame.score += 3;
    } else {
        _minigame.score += 1;
    }
}
function _aty_draw_completed_quests_enhanced(_zone) {
    var quests = _aty_get_safe_quest_array("completed_quests");
    var safe_colors = _aty_get_safe_colors();
    
    var quest_y_position = _zone.y1 + 25;
    
    draw_set_font(global.aty_font_bold);
    draw_set_color(safe_colors.success);
    draw_text(_zone.x1 + 15, _zone.y1 + 10, "ЗАВЕРШЁННЫЕ ЗАДАНИЯ (" + string(array_length(quests)) + ")");
    
    if (array_length(quests) == 0) {
        _aty_draw_empty_state(_zone, "Нет завершённых заданий", "Завершите свои первые квесты чтобы увидеть их здесь", safe_colors.text_muted);
        return;
    }
    
    for (var i = 0; i < array_length(quests); i++) {
        if (quest_y_position > _zone.y2 - 180) {
            _aty_draw_more_items_indicator(_zone, quest_y_position, array_length(quests) - i);
            break;
        }
        
        var quest = quests[i];
        quest_y_position = _aty_draw_quest_card_enhanced(_zone.x1, quest_y_position, _zone.x2, quest, false);
        quest_y_position += 15;
    }
}

function aty_apply_minigame_buff(_buff_key) {
    if (!variable_struct_exists(global.aty.expedition, "active_buffs")) {
        global.aty.expedition.active_buffs = [];
    }
    
    var buff_db = aty_get_buff_database();
    var buff_data = aty_find_buff_data(buff_db, _buff_key);
    
    if (is_struct(buff_data)) {
        array_push(global.aty.expedition.active_buffs, buff_data);
        aty_show_notification("Получен бафф: " + buff_data.name);
        
        // Пересчитываем характеристики для применения баффа
        aty_recalculate_hero_stats();
    }
}
function aty_create_trophy_struct() {
    return {
        id: "",
        name: "",
        description: "",
        icon: "🏆",
        category: TROPHY_CATEGORY.COMBAT,
        rarity: TROPHY_RARITY.BRONZE,
        unlocked: false,
        unlock_date: 0,
        progress: 0,
        target: 1,
        stat_bonus: {}, // Бонусы к характеристикам
        reward_gold: 0,
        reward_items: [],
        hidden: false, // Скрыт ли трофей до разблокировки
        series_id: "", // ID серии трофеев
        tier: 1 // Уровень в серии
    };
}

// База данных трофеев
function aty_get_trophy_database() {
    return [
        {
            id: "trophy_first_kill",
            name: "Первая кровь",
            description: "Победите первого врага",
            icon: "⚔️",
            category: TROPHY_CATEGORY.COMBAT,
            rarity: TROPHY_RARITY.BRONZE,
            target: 1,
            reward_gold: 50,
            stat_bonus: { attack_power: 2 },
            hidden: true // ДОБАВЛЕНО
        },
        {
            id: "trophy_warrior",
            name: "Опытный воин", 
            description: "Победите 100 врагов",
            icon: "🛡️",
            category: TROPHY_CATEGORY.COMBAT,
            rarity: TROPHY_RARITY.SILVER,
            target: 100,
            reward_gold: 200,
            stat_bonus: { attack_power: 5, health: 20 },
            hidden: false // ДОБАВЛЕНО
        },
        {
            id: "trophy_dragon_slayer",
            name: "Убийца драконов",
            description: "Победите рейд-босса",
            icon: "🐉",
            category: TROPHY_CATEGORY.COMBAT, 
            rarity: TROPHY_RARITY.GOLD,
            target: 1,
            reward_gold: 1000,
            stat_bonus: { attack_power: 15, crit_chance: 3 },
            hidden: true
        },

        // ==================== ИССЛЕДОВАТЕЛЬСКИЕ ТРОФЕИ ====================
        {
            id: "trophy_explorer",
            name: "Исследователь",
            description: "Завершите 10 экспедиций",
            icon: "🗺️",
            category: TROPHY_CATEGORY.EXPLORATION,
            rarity: TROPHY_RARITY.BRONZE,
            target: 10,
            reward_gold: 150,
            stat_bonus: { movement_speed: 3 },
			hidden: false // ДОБАВЛЕНО
        },
        {
            id: "trophy_master_explorer",
            name: "Мастер исследований",
            description: "Завершите все экспедиции",
            icon: "🌟",
            category: TROPHY_CATEGORY.EXPLORATION,
            rarity: TROPHY_RARITY.PLATINUM,
            target: 6,
            reward_gold: 500,
            stat_bonus: { movement_speed: 10, health: 50 },
			hidden: false // ДОБАВЛЕНО
        },

        // ==================== КОЛЛЕКЦИОННЫЕ ТРОФЕИ ====================
        {
            id: "trophy_collector",
            name: "Коллекционер",
            description: "Соберите 50 предметов",
            icon: "🎒",
            category: TROPHY_CATEGORY.COLLECTION,
            rarity: TROPHY_RARITY.SILVER,
            target: 50,
            reward_gold: 300,
            stat_bonus: { luck: 5 },
			hidden: false // ДОБАВЛЕНО
        },
        {
            id: "trophy_hoarder",
            name: "Накопитель",
            description: "Иметь 10 легендарных предметов",
            icon: "💎",
            category: TROPHY_CATEGORY.COLLECTION,
            rarity: TROPHY_RARITY.GOLD,
            target: 10,
            reward_gold: 800,
            stat_bonus: { luck: 10, magic_power: 15 },
			hidden: false // ДОБАВЛЕНО
        },

        // ==================== ТРОФЕИ КРАФТА ====================
        {
            id: "trophy_crafter",
            name: "Ремесленник",
            description: "Создайте 25 предметов",
            icon: "⚒️",
            category: TROPHY_CATEGORY.CRAFTING,
            rarity: TROPHY_RARITY.SILVER,
            target: 25,
            reward_gold: 400,
            stat_bonus: { dexterity: 5 },
			hidden: false // ДОБАВЛЕНО
        },

        // ==================== ОСОБЫЕ ТРОФЕИ ====================
        {
            id: "trophy_rich",
            name: "Богач",
            description: "Накопите 10,000 золота",
            icon: "💰",
            category: TROPHY_CATEGORY.SPECIAL,
            rarity: TROPHY_RARITY.GOLD,
            target: 10000,
            reward_gold: 2000,
            stat_bonus: { gold_bonus: 10 }, // +10% к получаемому золоту
			hidden: true // ДОБАВЛЕНО
        },
        {
            id: "trophy_legendary",
            name: "Легенда",
            description: "Достигните 50 уровня",
            icon: "👑",
            category: TROPHY_CATEGORY.SPECIAL,
            rarity: TROPHY_RARITY.DIAMOND,
            target: 50,
            reward_gold: 5000,
            stat_bonus: { all_stats: 5 }, // +5 ко всем характеристикам
			hidden: false // ДОБАВЛЕНО
        }
    ];
}
// Улучшенная функция инициализации системы трофеев
function aty_init_trophy_system() {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) {
        // Создаем базовую структуру, если не существует
        global.aty = {
            trophies: {
                unlocked: [],
                progress: {},
                bonuses: {},
                total_score: 0
            }
        };
    }
    
    // Гарантируем инициализацию trophies
    aty_init_trophies();
    
    // Инициализируем текущую категорию трофеев
    global.aty.current_trophy_category = TROPHY_CATEGORY.COMBAT;
    
    // Инициализируем анимации и эффекты - ГАРАНТИРУЕМ создание структуры
    global.aty.trophy_ui = {
        scroll_offset: 0,
        selected_trophy: -1,
        animation_timer: 0,
        pulse_effect: 0,
        filter_rarity: -1, // -1 = все редкости
        sort_method: 0, // 0 = по умолчанию, 1 = по редкости, 2 = по прогрессу
        search_text: ""
    };
}

// =============================================================================
// TROPHY MANAGEMENT FUNCTIONS
// =============================================================================

// Обновляем функцию инициализации трофеев для большей надежности
function aty_init_trophies() {
    // Создаем базовую структуру global.aty если не существует
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) {
        global.aty = {};
    }
    
    // Гарантируем структуру trophies
    if (!variable_struct_exists(global.aty, "trophies") || !is_struct(global.aty.trophies)) {
        global.aty.trophies = {
            unlocked: [],
            progress: {},
            bonuses: {},
            total_score: 0
        };
    } else {
        // Если trophies существует, но это массив - преобразуем в структуру
        if (is_array(global.aty.trophies)) {
            var old_trophies = global.aty.trophies;
            global.aty.trophies = {
                unlocked: old_trophies,
                progress: {},
                bonuses: {},
                total_score: 0
            };
        }
        
        // Гарантируем что все необходимые поля существуют
        if (!variable_struct_exists(global.aty.trophies, "unlocked") || !is_array(global.aty.trophies.unlocked)) {
            global.aty.trophies.unlocked = [];
        }
        if (!variable_struct_exists(global.aty.trophies, "progress") || !is_struct(global.aty.trophies.progress)) {
            global.aty.trophies.progress = {};
        }
        if (!variable_struct_exists(global.aty.trophies, "bonuses") || !is_struct(global.aty.trophies.bonuses)) {
            global.aty.trophies.bonuses = {};
        }
        if (!variable_struct_exists(global.aty.trophies, "total_score")) {
            global.aty.trophies.total_score = 0;
        }
    }

    // Инициализируем прогресс всех трофеев
    var trophy_db = aty_get_trophy_database();
    for (var i = 0; i < array_length(trophy_db); i++) {
        var tid = trophy_db[i].id;
        if (!variable_struct_exists(global.aty.trophies.progress, tid)) {
            variable_struct_set(global.aty.trophies.progress, tid, 0);
        }
    }
}
function aty_unlock_trophy(_trophy_id) {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) return;
    
    var trophy_db = aty_get_trophy_database();
    var trophy_data = aty_find_trophy_by_id(trophy_db, _trophy_id);
    
    if (!is_struct(trophy_data)) return;
    
    // Если трофей уже разблокирован, пропускаем
    if (aty_has_trophy(_trophy_id)) return;
    
    // Создаем копию трофея с дополнительными полями
    var unlocked_trophy = aty_create_trophy_struct();
    unlocked_trophy.id = trophy_data.id;
    unlocked_trophy.name = trophy_data.name;
    unlocked_trophy.description = trophy_data.description;
    unlocked_trophy.icon = trophy_data.icon;
    unlocked_trophy.category = trophy_data.category;
    unlocked_trophy.rarity = trophy_data.rarity;
    unlocked_trophy.unlocked = true;
    unlocked_trophy.unlock_date = current_time;
    unlocked_trophy.progress = trophy_data.target;
    unlocked_trophy.target = trophy_data.target;
    unlocked_trophy.reward_gold = trophy_data.reward_gold;
    unlocked_trophy.stat_bonus = trophy_data.stat_bonus;
    
    // Безопасное установление поля hidden
    if (variable_struct_exists(trophy_data, "hidden")) {
        unlocked_trophy.hidden = trophy_data.hidden;
    } else {
        unlocked_trophy.hidden = false;
    }
    
    // Добавляем в список разблокированных
    array_push(global.aty.trophies.unlocked, unlocked_trophy);
    
    // Выдаем награды
    aty_give_trophy_rewards(unlocked_trophy);
    
    // Пересчитываем счет и применяем бонусы
    aty_calculate_trophy_score();
    aty_apply_trophy_bonuses();
    
    // Пересчитываем характеристики героя
    aty_recalculate_hero_stats();
    
    // Показываем уведомление
    aty_show_trophy_notification(unlocked_trophy);
}
// Вспомогательная функция для проверки существования ключа в структуре
function struct_key_exists(_struct, _key) {
    if (!is_struct(_struct)) return false;
    var names = variable_struct_get_names(_struct);
    return array_contains(names, _key);
}
function aty_give_trophy_rewards(_trophy) {
    // Выдаем золото
    if (_trophy.reward_gold > 0) {
        global.aty.hero.gold += _trophy.reward_gold;
    }
    
    // Выдаем предметы если есть
    if (variable_struct_exists(_trophy, "reward_items") && array_length(_trophy.reward_items) > 0) {
        for (var i = 0; i < array_length(_trophy.reward_items); i++) {
            var item = aty_generate_loot_item_safe(_trophy.reward_items[i]);
            array_push(global.aty.inventory, item);
        }
    }
}
function array_merge(_arr1, _arr2, _arr3 = undefined) {
    var result = [];
    
    for (var i = 0; i < array_length(_arr1); i++) {
        array_push(result, _arr1[i]);
    }
    
    for (var i = 0; i < array_length(_arr2); i++) {
        array_push(result, _arr2[i]);
    }
    
    if (is_array(_arr3)) {
        for (var i = 0; i < array_length(_arr3); i++) {
            array_push(result, _arr3[i]);
        }
    }
    
    return result;
}
function array_create(_size, _value) {
    var arr = [];
    for (var i = 0; i < _size; i++) {
        array_push(arr, _value);
    }
    return arr;
}
function aty_apply_trophy_bonuses() {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) return;
    
    // БЕЗОПАСНАЯ ПРОВЕРКА: убеждаемся что trophies является структурой
    if (!variable_struct_exists(global.aty, "trophies") || !is_struct(global.aty.trophies)) {
        return;
    }
    
    // Очищаем предыдущие бонусы
    global.aty.trophies.bonuses = {};
    
    var unlocked_trophies = global.aty.trophies.unlocked;
    
    for (var i = 0; i < array_length(unlocked_trophies); i++) {
        var trophy = unlocked_trophies[i];
        
        // Безопасная проверка stat_bonus
        if (!variable_struct_exists(trophy, "stat_bonus") || !is_struct(trophy.stat_bonus)) {
            continue;
        }
        
        var stat_bonus = trophy.stat_bonus;
        var stat_keys = variable_struct_get_names(stat_bonus);
        
        for (var j = 0; j < array_length(stat_keys); j++) {
            var stat_key = stat_keys[j];
            var bonus_value = variable_struct_get(stat_bonus, stat_key);
            
            if (!is_real(bonus_value) || bonus_value <= 0) {
                continue;
            }
            
            // Специальный бонус "все характеристики"
            if (stat_key == "all_stats") {
                var all_stats = ["strength", "agility", "intelligence", "vitality", "dexterity", "luck"];
                for (var k = 0; k < array_length(all_stats); k++) {
                    var current_bonus = variable_struct_exists(global.aty.trophies.bonuses, all_stats[k]) ? 
                                      variable_struct_get(global.aty.trophies.bonuses, all_stats[k]) : 0;
                    variable_struct_set(global.aty.trophies.bonuses, all_stats[k], current_bonus + bonus_value);
                }
            } else {
                var current_bonus = variable_struct_exists(global.aty.trophies.bonuses, stat_key) ? 
                                  variable_struct_get(global.aty.trophies.bonuses, stat_key) : 0;
                variable_struct_set(global.aty.trophies.bonuses, stat_key, current_bonus + bonus_value);
            }
        }
    }
}

function aty_calculate_trophy_score() {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) return;
    
    var total_score = 0;
    var unlocked_trophies = global.aty.trophies.unlocked;
    
    for (var i = 0; i < array_length(unlocked_trophies); i++) {
        var trophy = unlocked_trophies[i];
        
        // Баллы в зависимости от редкости трофея
        switch (trophy.rarity) {
            case TROPHY_RARITY.BRONZE: total_score += 10; break;
            case TROPHY_RARITY.SILVER: total_score += 25; break;
            case TROPHY_RARITY.GOLD: total_score += 50; break;
            case TROPHY_RARITY.PLATINUM: total_score += 100; break;
            case TROPHY_RARITY.DIAMOND: total_score += 250; break;
        }
    }
    
    global.aty.trophies.total_score = total_score;
}

// =============================================================================
// TROPHY UTILITY FUNCTIONS
// =============================================================================

function aty_find_trophy_by_id(_trophy_db, _trophy_id) {
    if (!is_array(_trophy_db)) return undefined;
    
    for (var i = 0; i < array_length(_trophy_db); i++) {
        var trophy = _trophy_db[i];
        // Безопасная проверка существования id
        if (is_struct(trophy) && variable_struct_exists(trophy, "id") && trophy.id == _trophy_id) {
            return trophy;
        }
    }
    return undefined;
}
function aty_has_trophy(_trophy_id) {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) return false;
    
    // БЕЗОПАСНАЯ ПРОВЕРКА: убеждаемся что trophies является структурой
    if (!variable_struct_exists(global.aty, "trophies") || !is_struct(global.aty.trophies)) {
        return false;
    }
    
    // Проверяем, что unlocked существует и является массивом
    if (!variable_struct_exists(global.aty.trophies, "unlocked") || !is_array(global.aty.trophies.unlocked)) {
        return false;
    }
    
    var unlocked_trophies = global.aty.trophies.unlocked;
    
    for (var i = 0; i < array_length(unlocked_trophies); i++) {
        if (unlocked_trophies[i].id == _trophy_id) {
            return true;
        }
    }
    
    return false;
}

function aty_get_trophy_progress(_trophy_id) {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) return 0;
    
    // БЕЗОПАСНАЯ ПРОВЕРКА: убеждаемся что trophies является структурой
    if (!variable_struct_exists(global.aty, "trophies") || !is_struct(global.aty.trophies)) {
        return 0;
    }
    
    // БЕЗОПАСНАЯ ПРОВЕРКА: убеждаемся что progress существует и является структурой
    if (!variable_struct_exists(global.aty.trophies, "progress") || !is_struct(global.aty.trophies.progress)) {
        return 0;
    }
    
    return variable_struct_exists(global.aty.trophies.progress, _trophy_id) ? 
           variable_struct_get(global.aty.trophies.progress, _trophy_id) : 0;
}
function aty_debug_trophies() {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) {
        show_debug_message("global.aty not found");
        return;
    }
    
    if (!variable_struct_exists(global.aty, "trophies")) {
        show_debug_message("global.aty.trophies not found");
        return;
    }
    
    show_debug_message("Trophies type: " + string(typeof(global.aty.trophies)));
    show_debug_message("Is array: " + string(is_array(global.aty.trophies)));
    show_debug_message("Is struct: " + string(is_struct(global.aty.trophies)));
    
    if (is_struct(global.aty.trophies)) {
        var trophy_keys = variable_struct_get_names(global.aty.trophies);
        show_debug_message("Trophy keys: " + string(trophy_keys));
    }
}
// =============================================================================
// FIXED TROPHY BONUS SYSTEM - SIMPLIFIED VERSION
// =============================================================================
// Обновляем функцию получения трофеев по категории
function aty_get_trophies_by_category(_category) {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) return [];
    
    var trophy_db = aty_get_trophy_database();
    var filtered = [];
    
    for (var i = 0; i < array_length(trophy_db); i++) {
        var trophy = trophy_db[i];
        
        // Для скрытых трофеев показываем только разблокированные
        if (trophy.hidden && !aty_has_trophy(trophy.id)) {
            continue;
        }
        
        if (trophy.category == _category) {
            // Создаем объект с информацией о прогрессе
            var trophy_info = aty_create_trophy_struct();
            trophy_info.id = trophy.id;
            trophy_info.name = trophy.name;
            trophy_info.description = trophy.description;
            trophy_info.icon = trophy.icon;
            trophy_info.category = trophy.category;
            trophy_info.rarity = trophy.rarity;
            trophy_info.unlocked = aty_has_trophy(trophy.id);
            trophy_info.progress = aty_get_trophy_progress(trophy.id);
            trophy_info.target = trophy.target;
            trophy_info.hidden = trophy.hidden;
            
            array_push(filtered, trophy_info);
        }
    }
    
    return filtered;
}
function aty_get_trophy_rarity_name(_rarity) {
    switch (_rarity) {
        case TROPHY_RARITY.BRONZE: return "Бронза";
        case TROPHY_RARITY.SILVER: return "Серебро";
        case TROPHY_RARITY.GOLD: return "Золото";
        case TROPHY_RARITY.PLATINUM: return "Платина";
        case TROPHY_RARITY.DIAMOND: return "Алмаз";
        default: return "Обычный";
    }
}

function aty_get_trophy_category_name(_category) {
    switch (_category) {
        case TROPHY_CATEGORY.COMBAT: return "Боевые";
        case TROPHY_CATEGORY.EXPLORATION: return "Исследования";
        case TROPHY_CATEGORY.COLLECTION: return "Коллекции";
        case TROPHY_CATEGORY.CRAFTING: return "Крафт";
        case TROPHY_CATEGORY.SPECIAL: return "Особые";
        case TROPHY_CATEGORY.BOSS: return "Боссы";
        default: return "Разное";
    }
}

function aty_get_trophy_rarity_color(_rarity) {
    var colors = global.aty_colors;
    
    switch (_rarity) {
        case TROPHY_RARITY.BRONZE: return make_color_rgb(205, 127, 50);
        case TROPHY_RARITY.SILVER: return make_color_rgb(192, 192, 192);
        case TROPHY_RARITY.GOLD: return make_color_rgb(255, 215, 0);
        case TROPHY_RARITY.PLATINUM: return make_color_rgb(229, 228, 226);
        case TROPHY_RARITY.DIAMOND: return make_color_rgb(185, 242, 255);
        default: return colors.text_primary;
    }
}

// =============================================================================
// TROPHY NOTIFICATION
// =============================================================================

function aty_show_trophy_notification(_trophy) {
    var colors = global.aty_colors;
    var rarity_color = aty_get_trophy_rarity_color(_trophy.rarity);
    var rarity_name = aty_get_trophy_rarity_name(_trophy.rarity);
    
    var notification_text = _trophy.icon + " ТРОФЕЙ РАЗБЛОКИРОВАН! " + _trophy.icon + "\n" +
                          _trophy.name + " (" + rarity_name + ")\n" +
                          _trophy.description;
    
    if (_trophy.reward_gold > 0) {
        notification_text += "\nНаграда: " + string(_trophy.reward_gold) + " золота";
    }
    
    // Создаем специальное уведомление для трофеев
    global.aty.trophy_notification = {
        text: notification_text,
        trophy: _trophy,
        timer: 300, // 5 секунд
        color: rarity_color
    };
    
    // Также показываем стандартное уведомление
    aty_show_notification("🎉 Получен трофей: " + _trophy.name);
}

// =============================================================================
// ENHANCED TROPHIES TAB
// =============================================================================
// Обновленная основная функция отрисовки
// Улучшенная функция отрисовки вкладки с обработкой ошибок
function _aty_draw_trophies_tab_enhanced(_zone) {
    try {
        // ГАРАНТИРУЕМ инициализацию перед отрисовкой
        if (!variable_struct_exists(global, "aty") || !is_struct(global.aty) || 
            !variable_struct_exists(global.aty, "trophy_ui") || !is_struct(global.aty.trophy_ui)) {
            aty_init_trophy_system();
        }
        
        var colors = global.aty_colors;
        var ui = global.aty.trophy_ui;
        
        // Простая анимация пульсации
        ui.animation_timer++;
        ui.pulse_effect = sin(ui.animation_timer * 0.1) * 0.3 + 0.7;
        
        // Базовый фон
        draw_set_color(global.aty_colors.bg_dark);
        draw_rectangle(_zone.x1, _zone.y1, _zone.x2, _zone.y2, false);
        
        // Заголовок
        draw_set_color(global.aty_colors.neon_blue);
        draw_text(_zone.x1 + 20, _zone.y1 + 20, "🏆 СИСТЕМА ТРОФЕЕВ");
        
        // Статистика
        _aty_draw_trophy_stats_simple(_zone);
        
        // Категории
        _aty_draw_trophy_categories_simple(_zone);
        
        // Сетка трофеев
        _aty_draw_trophy_grid_simple(_zone);
        
    } catch (e) {
        // Резервная отрисовка при ошибке
        show_debug_message("ERROR in trophy tab: " + string(e));
        
        draw_set_color(c_white);
        draw_text(_zone.x1 + 20, _zone.y1 + 20, "Трофеи (ошибка отрисовки)");
        draw_text(_zone.x1 + 20, _zone.y1 + 40, "Попробуйте перезагрузить игру");
    }
}

// Упрощенная статистика
function _aty_draw_trophy_stats_simple(_zone) {
    var colors = global.aty_colors;
    var stats = global.aty.trophies;
    
    var total = array_length(aty_get_trophy_database());
    var unlocked = variable_struct_exists(stats, "unlocked") ? array_length(stats.unlocked) : 0;
    var sscore = variable_struct_exists(stats, "total_score") ? stats.total_score : 0;
    var percent = total > 0 ? floor((unlocked / total) * 100) : 0;
    
    var stats_y = _zone.y1 + 50;
    
    draw_set_color(colors.text_primary);
    draw_text(_zone.x1 + 20, stats_y, "Разблокировано: " + string(unlocked) + " / " + string(total));
    draw_text(_zone.x1 + 20, stats_y + 20, "Прогресс: " + string(percent) + "%");
    draw_text(_zone.x1 + 20, stats_y + 40, "Общий счет: " + string(sscore));
}


// Улучшенная функция категорий
function _aty_draw_trophy_categories_simple(_zone) {
    var colors = global.aty_colors;
    var ui = global.aty.trophy_ui;
    
    var category_y = _zone.y1 + 100;
    
    var categories = [
        { name: "⚔️ Боевые", key: TROPHY_CATEGORY.COMBAT },
        { name: "🗺️ Исследования", key: TROPHY_CATEGORY.EXPLORATION },
        { name: "🎒 Коллекции", key: TROPHY_CATEGORY.COLLECTION },
        { name: "⚒️ Крафт", key: TROPHY_CATEGORY.CRAFTING },
        { name: "🌟 Особые", key: TROPHY_CATEGORY.SPECIAL },
        { name: "👑 Боссы", key: TROPHY_CATEGORY.BOSS }
    ];
    
    var button_width = 110;
    var button_height = 30;
    
    for (var i = 0; i < array_length(categories); i++) {
        var cat = categories[i];
        var is_active = (global.aty.current_trophy_category == cat.key);
        
        var button_x = _zone.x1 + 20 + i * (button_width + 10);
        
        // Если кнопка не помещается - пропускаем
        if (button_x + button_width > _zone.x2 - 20) break;
        
        // Простая кнопка
        draw_set_color(is_active ? colors.neon_blue : colors.bg_medium);
        draw_rectangle(button_x, category_y, button_x + button_width, category_y + button_height, false);
        
        draw_set_color(is_active ? colors.text_primary : colors.text_secondary);
        
        // Обрезаем текст кнопки если не помещается
        var button_text = cat.name;
        var text_width = string_width(button_text);
        if (text_width > button_width - 10) {
            button_text = _aty_truncate_text(button_text, button_width - 10);
        }
        
        draw_text(button_x + 5, category_y + 8, button_text);
        
        // Обработка клика
        var mouse_in_button = point_in_rectangle(mouse_x, mouse_y, 
            button_x, category_y, 
            button_x + button_width, category_y + button_height);
            
        if (mouse_in_button && mouse_check_button_pressed(mb_left)) {
            global.aty.current_trophy_category = cat.key;
            ui.selected_trophy = -1;
            ui.scroll_offset = 0;
        }
    }
}
// Добавляем функцию для безопасного получения высоты текста
function string_height_ext_safe(_text, _width, _max_lines) {
    try {
        return string_height_ext(_text, _width, _max_lines);
    } catch (e) {
        // Возвращаем безопасное значение по умолчанию
        return 20;
    }
}

// Обновленная функция сетки с минимальными размерами
function _aty_draw_trophy_grid_simple(_zone) {
    var colors = global.aty_colors;
    var ui = global.aty.trophy_ui;
    
    var grid_y = _zone.y1 + 150;
    var grid_height = _zone.y2 - grid_y - 20;
    
    // Получаем трофеи текущей категории
    var trophies = aty_get_trophies_by_category(global.aty.current_trophy_category);
    
    // Прокрутка
    if (mouse_check_button_pressed(mb_middle)) {
        var scroll_direction = sign(mouse_wheel_delta());
        ui.scroll_offset = max(0, ui.scroll_offset - scroll_direction * 3);
    }
    
    // Ограничиваем область отрисовки
    gpu_set_scissor(_zone.x1 + 20, grid_y, _zone.x2 - _zone.x1 - 40, grid_height);
    
    // Адаптивная сетка с минимальными размерами
    var min_card_width = 160; // Минимальная ширина карточки
    var max_card_width = 200; // Максимальная ширина карточки
    var card_height = 120; // Фиксированная высота карточки
    var spacing = 15;
    
    var available_width = _zone.x2 - _zone.x1 - 40;
    var cols = max(1, floor(available_width / min_card_width));
    var cell_width = min(max_card_width, (available_width - spacing * (cols - 1)) / cols);
    
    // Гарантируем минимальную ширину
    cell_width = max(min_card_width, cell_width);
    
    var start_row = floor(ui.scroll_offset / card_height);
    var visible_rows = ceil(grid_height / card_height) + 1;
    
    for (var i = 0; i < array_length(trophies); i++) {
        var trophy = trophies[i];
        var row = floor(i / cols);
        var col = i % cols;
        
        // Пропускаем невидимые строки
        if (row < start_row || row >= start_row + visible_rows) continue;
        
        var cell_x = _zone.x1 + 20 + col * (cell_width + spacing);
        var cell_y = grid_y + (row - start_row) * (card_height + spacing) - (ui.scroll_offset % card_height);
        
        // Проверяем, что карточка видима в зоне отрисовки
        if (cell_y + card_height < grid_y || cell_y > grid_y + grid_height) continue;
        
        _aty_draw_trophy_card_simple(cell_x, cell_y, cell_x + cell_width, cell_y + card_height, trophy, i);
    }
    
    gpu_set_scissor(false);
    
    // Полоса прокрутки если нужно
    var total_rows = ceil(array_length(trophies) / cols);
    if (total_rows > visible_rows) {
        _aty_draw_scrollbar_simple(_zone, grid_y, grid_height, total_rows, visible_rows);
    }
}

// Функция для обрезания текста по ширине
function _aty_truncate_text(_text, _max_width) {
    if (!is_string(_text)) return "";
    
    var text_width = string_width(_text);
    if (text_width <= _max_width) {
        return _text;
    }
    
    // Постепенно укорачиваем текст пока не поместится
    var result = _text;
    var max_chars = string_length(_text);
    
    for (var i = max_chars - 1; i > 0; i--) {
        result = string_copy(_text, 1, i) + "...";
        if (string_width(result) <= _max_width) {
            return result;
        }
    }
    
    // Если даже одна буква не помещается, возвращаем пустую строку
    return _text;
}
// Функция для обрезания текста по высоте
function _aty_truncate_text_to_height(_text, _max_width, _max_height) {
    if (!is_string(_text)) return "";
    
    var lines = 1;
    var result = _text;
    var current_height = string_height_ext(_text, _max_width, -1);
    
    if (current_height <= _max_height) {
        return _text;
    }
    
    // Укорачиваем текст пока не поместится по высоте
    var max_chars = string_length(_text);
    
    for (var i = max_chars - 1; i > 0; i--) {
        result = string_copy(_text, 1, i) + "...";
        current_height = string_height_ext(result, _max_width, -1);
        
        if (current_height <= _max_height) {
            return result;
        }
    }
    
    return "...";
}

// Обновленная функция отрисовки карточки трофея с безопасной обработкой текста
function _aty_draw_trophy_card_simple(_x1, _y1, _x2, _y2, _trophy, _index) {
    var colors = global.aty_colors;
    var ui = global.aty.trophy_ui;
    
    var is_unlocked = aty_has_trophy(_trophy.id);
    var progress = aty_get_trophy_progress(_trophy.id);
    var is_selected = (ui.selected_trophy == _index);
    var rarity_color = aty_get_trophy_rarity_color(_trophy.rarity);
    
    // Вычисляем реальные размеры карточки
    var card_width = _x2 - _x1;
    var card_height = _y2 - _y1;
    
    // Фон
    draw_set_color(is_unlocked ? merge_color(colors.bg_light, rarity_color, 0.1) : colors.bg_medium);
    draw_rectangle(_x1, _y1, _x2, _y2, false);
    
    // Рамка
    draw_set_color(is_selected ? colors.neon_cyan : rarity_color);
    draw_rectangle(_x1, _y1, _x2, _y2, true);
    
    // Иконка и название
    draw_set_color(is_unlocked ? rarity_color : colors.text_muted);
    draw_text(_x1 + 10, _y1 + 10, _trophy.icon);
    
    draw_set_color(is_unlocked ? colors.text_primary : colors.text_muted);
    
    // Безопасное обрезание названия
    var name_x = _x1 + 40;
    var max_name_width = card_width - 50; // 40 + 10 отступ
    var display_name = _aty_truncate_text(_trophy.name, max_name_width);
    draw_text(name_x, _y1 + 10, display_name);
    
    // Описание - БЕЗОПАСНАЯ ОБРАБОТКА
    var desc_x = _x1 + 10;
    var desc_y = _y1 + 35;
    var desc_width = card_width - 20; // 10px отступы с обеих сторон
    
    draw_set_color(colors.text_secondary);
    
    // Если ширина слишком мала, не рисуем описание вообще
    if (desc_width >= 20) {
        var display_desc = _aty_truncate_text(_trophy.description, desc_width);
        
        // Проверяем высоту текста
        var text_height = string_height_ext(display_desc, desc_width, -1);
        var available_height = _y2 - desc_y - 30; // 30px для прогресс-бара и отступов
        
        if (text_height <= available_height) {
            draw_text_ext(desc_x, desc_y, display_desc, desc_width, -1);
        } else {
            // Если текст не помещается по высоте, обрезаем и добавляем "..."
            var truncated = _aty_truncate_text_to_height(_trophy.description, desc_width, available_height);
            draw_text_ext(desc_x, desc_y, truncated, desc_width, -1);
        }
    }
    
    // Прогресс - УПРОЩЕННАЯ ВЕРСИЯ
    var progress_width = max(10, card_width - 20); // Минимальная ширина 10px
    var progress_fill = (progress / _trophy.target) * progress_width;
    var progress_y = _y2 - 20;
    
    // Фон прогресс-бара
    draw_set_color(colors.bg_dark);
    draw_rectangle(_x1 + 10, progress_y, _x1 + 10 + progress_width, progress_y + 8, false);
    
    if (is_unlocked) {
        // Заполненный прогресс-бар для разблокированных
        draw_set_color(colors.neon_green);
        draw_rectangle(_x1 + 10, progress_y, _x1 + 10 + progress_width, progress_y + 8, false);
        
        draw_set_color(colors.text_primary);
        var done_text = "✓ ВЫПОЛНЕНО";
        var done_width = string_width(done_text);
        if (done_width <= progress_width) {
            draw_text(_x1 + 10, progress_y - 15, done_text);
        } else {
            draw_text(_x1 + 10, progress_y - 15, "✓");
        }
    } else {
        // Прогресс-бар для незавершенных
        if (progress_fill > 0) {
            draw_set_color(rarity_color);
            draw_rectangle(_x1 + 10, progress_y, _x1 + 10 + progress_fill, progress_y + 8, false);
        }
        
        draw_set_color(colors.text_secondary);
        var progress_text = string(progress) + "/" + string(_trophy.target);
        var progress_text_width = string_width(progress_text);
        
        if (progress_text_width <= progress_width) {
            draw_text(_x1 + 10, progress_y - 15, progress_text);
        } else {
            // Альтернативный формат если не помещается
            var percent = floor((progress / _trophy.target) * 100);
            draw_text(_x1 + 10, progress_y - 15, string(percent) + "%");
        }
    }
    
    // Обработка клика
    var mouse_in_card = point_in_rectangle(mouse_x, mouse_y, _x1, _y1, _x2, _y2);
    if (mouse_in_card && mouse_check_button_pressed(mb_left)) {
        ui.selected_trophy = _index;
    }
}


// Упрощенная полоса прокрутки
function _aty_draw_scrollbar_simple(_zone, _start_y, _height, _total_rows, _visible_rows) {
    var colors = global.aty_colors;
    var ui = global.aty.trophy_ui;
    
    var scrollbar_width = 8;
    var scrollbar_x = _zone.x2 - scrollbar_width - 10;
    
    var thumb_height = max(20, _height * (_visible_rows / _total_rows));
    var thumb_y = _start_y + (ui.scroll_offset / _total_rows) * _height;
    
    // Фон
    draw_set_color(colors.bg_dark);
    draw_rectangle(scrollbar_x, _start_y, scrollbar_x + scrollbar_width, _start_y + _height, false);
    
    // Бегунок
    draw_set_color(colors.neon_blue);
    draw_rectangle(scrollbar_x, thumb_y, scrollbar_x + scrollbar_width, thumb_y + thumb_height, false);
}
// Заголовок с анимацией
function _aty_draw_trophy_header(_zone) {
    var colors = global.aty_colors;
    var ui = global.aty.trophy_ui;
    
    var header_y = _zone.y1 + 20;
    
    // Анимированный текст
    var pulse_color = merge_color(colors.neon_blue, colors.neon_cyan, ui.pulse_effect);
    draw_set_color(pulse_color);
    draw_set_font(global.aty_font_title);
    draw_text(_zone.x1 + 20, header_y, "🏆 СИСТЕМА ТРОФЕЕВ");
    draw_set_font(global.aty_font_normal);
    
    // Декоративная линия
    draw_set_color(colors.neon_blue);
    draw_line(_zone.x1 + 20, header_y + 25, _zone.x1 + 300, header_y + 25);
}
// Улучшенная панель статистики с прогресс-барами
function _aty_draw_trophy_stats(_zone) {
    var colors = global.aty_colors;
    var stats = global.aty.trophies;
    var ui = global.aty.trophy_ui;
    
    var stats_y = _zone.y1 + 60;
    var stats_width = (_zone.x2 - _zone.x1 - 60) / 4;
    
    var total_trophies = array_length(aty_get_trophy_database());
    var unlocked_count = variable_struct_exists(stats, "unlocked") ? array_length(stats.unlocked) : 0;
    var completion = total_trophies > 0 ? (unlocked_count / total_trophies) * 100 : 0;
    
    var stats_data = [
        {
            value: unlocked_count,
            total: total_trophies,
            label: "Разблокировано",
            icon: "✅",
            color: colors.neon_green,
            show_progress: true
        },
        {
            value: variable_struct_exists(stats, "total_score") ? stats.total_score : 0,
            total: 0,
            label: "Общий счет",
            icon: "⭐",
            color: colors.neon_yellow,
            show_progress: false
        },
        {
            value: floor(completion),
            total: 100,
            label: "Завершение",
            icon: "📊",
            color: colors.neon_cyan,
            show_progress: true
        },
        {
            value: _aty_calculate_rarity_count(TROPHY_RARITY.DIAMOND),
            total: 0,
            label: "Алмазных",
            icon: "💎",
            color: make_color_rgb(185, 242, 255),
            show_progress: false
        }
    ];
    
    for (var i = 0; i < array_length(stats_data); i++) {
        var stat = stats_data[i];
        var stat_x = _zone.x1 + 20 + i * (stats_width + 10);
        
        // Панель статистики с эффектом свечения
        var is_hover = point_in_rectangle(mouse_x, mouse_y, stat_x, stats_y, stat_x + stats_width, stats_y + 80);
        var glow = is_hover ? 0.2 : 0;
        draw_set_color(merge_color(colors.bg_medium, stat.color, glow));
        draw_roundrect(stat_x, stats_y, stat_x + stats_width, stats_y + 80, 8);
        
        // Рамка
        draw_set_color(stat.color);
        draw_roundrect(stat_x, stats_y, stat_x + stats_width, stats_y + 80, 8);
        
        // Иконка
        draw_set_color(stat.color);
        draw_text(stat_x + 15, stats_y + 15, stat.icon);
        
        // Значение
        draw_set_color(colors.text_primary);
        draw_set_font(global.aty_font_bold);
        var value_text = string(stat.value);
        if (stat.total > 0) value_text += " / " + string(stat.total);
        draw_text(stat_x + 40, stats_y + 15, value_text);
        
        // Прогресс-бар для соответствующих статов
        if (stat.show_progress && stat.total > 0) {
            var progress_width = stats_width - 20;
            var progress = stat.value / stat.total;
            
            // Фон прогресса
            draw_set_color(colors.bg_dark);
            draw_rectangle(stat_x + 10, stats_y + 45, stat_x + 10 + progress_width, stats_y + 55, false);
            
            // Заполнение
            draw_set_color(stat.color);
            draw_rectangle(stat_x + 10, stats_y + 45, stat_x + 10 + progress_width * progress, stats_y + 55, false);
        }
        
        // Название
        draw_set_font(global.aty_font_small);
        draw_set_color(colors.text_secondary);
        draw_text(stat_x + 10, stats_y + 60, stat.label);
        draw_set_font(global.aty_font_normal);
    }
}
// Улучшенная система фильтров с иконками
function _aty_draw_trophy_filters(_zone) {
    var colors = global.aty_colors;
    var ui = global.aty.trophy_ui;
    
    var filters_y = _zone.y1 + 150;
    
    // Поиск с иконкой
    draw_set_color(colors.text_secondary);
    draw_text(_zone.x1 + 20, filters_y + 5, "🔍 Поиск:");
    
    // Поле ввода поиска
    var search_result = draw_neon_input_field(_zone.x1 + 90, filters_y, _zone.x1 + 290, filters_y + 30, ui.search_text, "Введите название трофея...");
    if (is_string(search_result)) {
        ui.search_text = search_result;
    }
    
    // Фильтры по редкости с цветными иконками
    var rarity_x = _zone.x1 + 320;
    var rarities = [
        { name: "Все", icon: "🌈", value: -1 },
        { name: "Бронза", icon: "🥉", value: TROPHY_RARITY.BRONZE },
        { name: "Серебро", icon: "🥈", value: TROPHY_RARITY.SILVER },
        { name: "Золото", icon: "🥇", value: TROPHY_RARITY.GOLD },
        { name: "Платина", icon: "📜", value: TROPHY_RARITY.PLATINUM },
        { name: "Алмаз", icon: "💎", value: TROPHY_RARITY.DIAMOND }
    ];
    
    for (var i = 0; i < array_length(rarities); i++) {
        var rarity = rarities[i];
        var btn_x = rarity_x + i * 75;
        var is_active = (ui.filter_rarity == rarity.value);
        
        // Цвет кнопки в зависимости от редкости
        var btn_color = is_active ? aty_get_trophy_rarity_color(rarity.value) : colors.bg_medium;
        if (rarity.value == -1) btn_color = is_active ? colors.neon_blue : colors.bg_medium;
        
        if (draw_neon_button(btn_x, filters_y, btn_x + 70, filters_y + 30, 
                           rarity.icon, is_active, false, btn_color)) {
            ui.filter_rarity = rarity.value;
            ui.selected_trophy = -1;
        }
        
        // Подпись под кнопкой
        draw_set_color(colors.text_secondary);
        draw_set_font(global.aty_font_small);
        draw_text(btn_x + 35, filters_y + 35, rarity.name);
        draw_set_font(global.aty_font_normal);
    }
    
    // Сортировка с выпадающим меню
    var sort_x = _zone.x2 - 200;
    var sort_methods = ["По умолчанию", "По редкости", "По прогрессу"];
    
    if (draw_neon_button(sort_x, filters_y, sort_x + 180, filters_y + 30, 
                        "📊 " + sort_methods[ui.sort_method], false, false)) {
        ui.sort_method = (ui.sort_method + 1) % array_length(sort_methods);
        ui.selected_trophy = -1;
    }
}

// Категории трофеев
function _aty_draw_trophy_categories(_zone) {
    var colors = global.aty_colors;
    var ui = global.aty.trophy_ui;
    
    var category_y = _zone.y1 + 190;
    
    var categories = [
        { name: "⚔️ Боевые", key: TROPHY_CATEGORY.COMBAT, icon: "⚔️" },
        { name: "🗺️ Исследования", key: TROPHY_CATEGORY.EXPLORATION, icon: "🗺️" },
        { name: "🎒 Коллекции", key: TROPHY_CATEGORY.COLLECTION, icon: "🎒" },
        { name: "⚒️ Крафт", key: TROPHY_CATEGORY.CRAFTING, icon: "⚒️" },
        { name: "🌟 Особые", key: TROPHY_CATEGORY.SPECIAL, icon: "🌟" },
        { name: "👑 Боссы", key: TROPHY_CATEGORY.BOSS, icon: "👑" }
    ];
    
    var cat_width = 140;
    var cat_height = 50;
    
    for (var i = 0; i < array_length(categories); i++) {
        var cat = categories[i];
        var cat_x = _zone.x1 + 20 + i * (cat_width + 10);
        
        if (cat_x + cat_width > _zone.x2 - 20) break;
        
        var is_active = (global.aty.current_trophy_category == cat.key);
        var is_hover = point_in_rectangle(mouse_x, mouse_y, cat_x, category_y, cat_x + cat_width, category_y + cat_height);
        
        // Специальный эффект для активной категории
        if (is_active) {
            var glow_color = merge_color(colors.neon_blue, colors.neon_cyan, ui.pulse_effect);
            draw_set_color(glow_color);
            draw_rectangle(cat_x - 2, category_y - 2, cat_x + cat_width + 2, category_y + cat_height + 2, false);
        }
        
        if (draw_neon_button(cat_x, category_y, cat_x + cat_width, category_y + cat_height, 
                           cat.name, is_active, is_hover)) {
            global.aty.current_trophy_category = cat.key;
            ui.selected_trophy = -1;
            ui.scroll_offset = 0;
        }
        
        // Дополнительная иконка
        draw_set_color(is_active ? colors.neon_cyan : colors.text_secondary);
        draw_text(cat_x + cat_width - 25, category_y + 15, cat.icon);
    }
}

// Сетка трофеев
function _aty_draw_trophy_grid(_zone) {
    var colors = global.aty_colors;
    var ui = global.aty.trophy_ui;
    
    var grid_y = _zone.y1 + 260;
    var grid_zone = {
        x1: _zone.x1 + 20,
        y1: grid_y,
        x2: _zone.x2 - 20,
        y2: _zone.y2 - 20
    };
    
    // Получаем отфильтрованные и отсортированные трофеи
    var trophies = _aty_get_filtered_trophies();
    
    // Прокрутка колесиком мыши
    if (mouse_check_button_pressed(mb_middle)) {
        var scroll_direction = sign(mouse_wheel_delta());
        ui.scroll_offset = max(0, ui.scroll_offset - scroll_direction * 3);
    }
    
    gpu_set_scissor(grid_zone.x1, grid_zone.y1, grid_zone.x2 - grid_zone.x1, grid_zone.y2 - grid_zone.y1);
    
    var cell_width = 180;
    var cell_height = 120;
    var cols = floor((grid_zone.x2 - grid_zone.x1) / cell_width);
    var spacing = (grid_zone.x2 - grid_zone.x1 - cols * cell_width) / (cols + 1);
    
    var visible_rows = floor((grid_zone.y2 - grid_zone.y1) / cell_height) + 1;
    var start_index = floor(ui.scroll_offset / cell_height) * cols;
    var end_index = min(array_length(trophies), start_index + visible_rows * cols);
    
    for (var i = start_index; i < end_index; i++) {
        var trophy = trophies[i];
        var row = floor((i - start_index) / cols);
        var col = (i - start_index) % cols;
        
        var cell_x = grid_zone.x1 + spacing + col * (cell_width + spacing);
        var cell_y = grid_zone.y1 + row * cell_height - (ui.scroll_offset % cell_height);
        
        _aty_draw_trophy_card(cell_x, cell_y, cell_x + cell_width, cell_y + cell_height, trophy, i);
    }
    
    // Полоса прокрутки
    if (array_length(trophies) > visible_rows * cols) {
        _aty_draw_scrollbar(grid_zone, array_length(trophies), visible_rows * cols);
    }
    
    gpu_set_scissor(false);
}
// Улучшенная функция получения отфильтрованных трофеев
function _aty_get_filtered_trophies() {
    var ui = global.aty.trophy_ui;
    var all_trophies = aty_get_trophies_by_category(global.aty.current_trophy_category);
    var filtered = [];
    
    for (var i = 0; i < array_length(all_trophies); i++) {
        var trophy = all_trophies[i];
        
        // Фильтр по редкости
        if (ui.filter_rarity != -1 && trophy.rarity != ui.filter_rarity) continue;
        
        // Фильтр по поиску
        if (ui.search_text != "" && string_pos(lower(ui.search_text), lower(trophy.name)) == 0) continue;
        
        array_push(filtered, trophy);
    }
    
    // Сортировка с использованием безопасной функции
    return _aty_sort_trophies_enhanced(filtered, ui.sort_method);
}

// Добавляем недостающие вспомогательные функции
function merge_color(_color1, _color2, _ratio) {
    var r1 = color_get_red(_color1);
    var g1 = color_get_green(_color1);
    var b1 = color_get_blue(_color1);
    
    var r2 = color_get_red(_color2);
    var g2 = color_get_green(_color2);
    var b2 = color_get_blue(_color2);
    
    var r = r1 + (r2 - r1) * _ratio;
    var g = g1 + (g2 - g1) * _ratio;
    var b = b1 + (b2 - b1) * _ratio;
    
    return make_color_rgb(r, g, b);
}

function draw_set_gradient_color(_color1, _color2, _direction) {
    // Упрощенная версия - используем первый цвет
    draw_set_color(_color1);
}

// Обновленная функция сортировки
function _aty_sort_trophies_enhanced(_trophies, _method) {
    // Используем безопасное копирование
    var sorted = aty_array_copy(_trophies);
    
    switch (_method) {
        case 1: // По редкости
            array_sort(sorted, function(a, b) {
                if (a.unlocked != b.unlocked) return b.unlocked - a.unlocked;
                return b.rarity - a.rarity;
            });
            break;
            
        case 2: // По прогрессу
            array_sort(sorted, function(a, b) {
                if (a.unlocked != b.unlocked) return b.unlocked - a.unlocked;
                var a_progress = a.progress / a.target;
                var b_progress = b.progress / b.target;
                return b_progress - a_progress;
            });
            break;
            
        default: // По умолчанию
            sorted = aty_sort_trophies(sorted);
            break;
    }
    
    return sorted;
}

function _aty_calculate_completion_percent() {
    var total = array_length(aty_get_trophy_database());
    var unlocked = variable_struct_exists(global.aty.trophies, "unlocked") ? 
                   array_length(global.aty.trophies.unlocked) : 0;
    return total > 0 ? floor((unlocked / total) * 100) : 0;
}

function _aty_calculate_rarity_count(_rarity) {
    var count = 0;
    var unlocked = variable_struct_exists(global.aty.trophies, "unlocked") ? 
                   global.aty.trophies.unlocked : [];
    
    for (var i = 0; i < array_length(unlocked); i++) {
        if (unlocked[i].rarity == _rarity) count++;
    }
    return count;
}

function _aty_format_stat_bonus(_stat, _value) {
    var stat_names = {
        attack_power: "Сила атаки",
        health: "Здоровье", 
        crit_chance: "Шанс крита",
        movement_speed: "Скорость",
        luck: "Удача",
        dexterity: "Ловкость",
        magic_power: "Магия",
        gold_bonus: "Бонус золота",
        all_stats: "Все характеристики"
    };
    
    var name = variable_struct_exists(stat_names, _stat) ? 
               variable_struct_get(stat_names, _stat) : _stat;
    
    return name + " +" + string(_value);
}

function _aty_format_date(_timestamp) {
    // Упрощенное форматирование даты
    return "сегодня"; // Можно реализовать полноценное форматирование
}

function _aty_find_unlocked_trophy(_trophy_id) {
    var unlocked = variable_struct_exists(global.aty.trophies, "unlocked") ? 
                   global.aty.trophies.unlocked : [];
    
    for (var i = 0; i < array_length(unlocked); i++) {
        if (unlocked[i].id == _trophy_id) return unlocked[i];
    }
    return undefined;
}

function _aty_draw_scrollbar(_zone, _total_items, _visible_items) {
    var colors = global.aty_colors;
    var ui = global.aty.trophy_ui;
    
    var scrollbar_width = 8;
    var scrollbar_x = _zone.x2 - scrollbar_width - 5;
    var scrollbar_height = _zone.y2 - _zone.y1;
    
    var thumb_height = max(20, scrollbar_height * (_visible_items / _total_items));
    var thumb_y = _zone.y1 + (ui.scroll_offset / _total_items) * scrollbar_height;
    
    // Фон полосы прокрутки
    draw_set_color(colors.bg_dark);
    draw_rectangle(scrollbar_x, _zone.y1, scrollbar_x + scrollbar_width, _zone.y2, false);
    
    // Бегунок
    draw_set_color(colors.neon_blue);
    draw_rectangle(scrollbar_x, thumb_y, scrollbar_x + scrollbar_width, thumb_y + thumb_height, false);
}
// Карточка трофея
function _aty_draw_trophy_card(_x1, _y1, _x2, _y2, _trophy, _index) {
    var colors = global.aty_colors;
    var ui = global.aty.trophy_ui;
    
    var is_unlocked = aty_has_trophy(_trophy.id);
    var progress = aty_get_trophy_progress(_trophy.id);
    var is_selected = (ui.selected_trophy == _index);
    var is_hover = point_in_rectangle(mouse_x, mouse_y, _x1, _y1, _x2, _y2);
    
    // Цвета в зависимости от редкости и статуса
    var rarity_color = aty_get_trophy_rarity_color(_trophy.rarity);
    var bg_color = is_unlocked ? merge_color(colors.bg_light, rarity_color, 0.1) : colors.bg_medium;
    var border_color = is_unlocked ? rarity_color : colors.bg_dark;
    
    // Эффект при наведении
    if (is_hover) {
        bg_color = merge_color(bg_color, colors.neon_blue, 0.2);
        if (!is_selected) {
            border_color = merge_color(border_color, colors.neon_cyan, 0.5);
        }
    }
    
    // Эффект выделения
    if (is_selected) {
        var glow_strength = ui.pulse_effect * 0.5 + 0.5;
        border_color = merge_color(rarity_color, colors.neon_cyan, glow_strength);
        draw_set_color(merge_color(rarity_color, c_white, 0.1));
        draw_rectangle(_x1 - 3, _y1 - 3, _x2 + 3, _y2 + 3, false);
    }
    
    // Основная панель
    draw_set_color(bg_color);
    draw_rectangle(_x1, _y1, _x2, _y2, false);
    
    // Рамка
    draw_set_color(border_color);
    draw_rectangle(_x1, _y1, _x2, _y2, true);
    
    // Иконка трофея (центрированная)
    var icon_size = 32;
    var icon_x = _x1 + (_x2 - _x1 - icon_size) / 2;
    draw_set_color(is_unlocked ? rarity_color : colors.text_muted);
    draw_set_font(global.aty_font_large);
    draw_text(icon_x, _y1 + 15, _trophy.icon);
    draw_set_font(global.aty_font_normal);
    
    // Название (обрезанное если нужно)
    draw_set_color(is_unlocked ? colors.text_primary : colors.text_muted);
    draw_set_halign(fa_center);
    var name_width = string_width(_trophy.name);
    var max_width = _x2 - _x1 - 20;
    var display_name = name_width > max_width ? string_copy(_trophy.name, 1, 15) + "..." : _trophy.name;
    draw_text(_x1 + (_x2 - _x1) / 2, _y1 + 55, display_name);
    
    // Прогресс бар
    var progress_width = _x2 - _x1 - 20;
    var progress_fill = (progress / _trophy.target) * progress_width;
    var progress_y = _y1 + 75;
    
    draw_set_color(colors.bg_dark);
    draw_rectangle(_x1 + 10, progress_y, _x1 + 10 + progress_width, progress_y + 8, false);
    
    if (is_unlocked) {
        draw_set_color(colors.neon_green);
        draw_rectangle(_x1 + 10, progress_y, _x1 + 10 + progress_width, progress_y + 8, false);
        draw_set_color(colors.text_primary);
        draw_text(_x1 + (_x2 - _x1) / 2, progress_y + 10, "✓ ВЫПОЛНЕНО");
    } else {
        draw_set_color(rarity_color);
        draw_rectangle(_x1 + 10, progress_y, _x1 + 10 + progress_fill, progress_y + 8, false);
        draw_set_color(colors.text_secondary);
        draw_text(_x1 + (_x2 - _x1) / 2, progress_y + 10, string(progress) + "/" + string(_trophy.target));
    }
    
    // Индикатор редкости
    draw_set_halign(fa_left);
    draw_set_color(rarity_color);
    draw_text(_x1 + 5, _y1 + 5, aty_get_trophy_rarity_name(_trophy.rarity));
    
    // Обработка клика
    if (is_hover && mouse_check_button_pressed(mb_left)) {
        ui.selected_trophy = _index;
    }
    
    draw_set_halign(fa_left);
}

// Улучшенная панель деталей трофея
function _aty_draw_trophy_details_panel(_zone) {
    var colors = global.aty_colors;
    var ui = global.aty.trophy_ui;
    
    var trophies = _aty_get_filtered_trophies();
    if (ui.selected_trophy < 0 || ui.selected_trophy >= array_length(trophies)) {
        ui.selected_trophy = -1;
        return;
    }
    
    var trophy = trophies[ui.selected_trophy];
    var is_unlocked = aty_has_trophy(trophy.id);
    var rarity_color = aty_get_trophy_rarity_color(trophy.rarity);
    
    var panel_width = 320;
    var panel_x = _zone.x2 - panel_width - 20;
    var panel_y = _zone.y1 + 260;
    var panel_height = _zone.y2 - panel_y - 20;
    
    // Фон панели с градиентом
    draw_set_gradient_color(merge_color(colors.bg_dark, c_black, 0.5), colors.bg_dark, 0);
    draw_roundrect(panel_x, panel_y, panel_x + panel_width, panel_y + panel_height, 12);
    
    // Заголовок с иконкой
    draw_set_color(rarity_color);
    draw_set_font(global.aty_font_bold);
    
    var title_width = string_width(trophy.name);
    var max_title_width = panel_width - 60;
    var display_name = title_width > max_title_width ? string_copy(trophy.name, 1, 20) + "..." : trophy.name;
    
    draw_text(panel_x + 15, panel_y + 20, display_name);
    draw_text(panel_x + panel_width - 35, panel_y + 20, trophy.icon);
    
    // Редкость и категория
    draw_set_font(global.aty_font_small);
    draw_set_color(colors.text_secondary);
    draw_text(panel_x + 15, panel_y + 45, aty_get_trophy_rarity_name(trophy.rarity));
    draw_text(panel_x + panel_width - 100, panel_y + 45, aty_get_trophy_category_name(trophy.category));
    
    // Разделитель
    draw_set_color(colors.neon_blue);
    draw_line(panel_x + 10, panel_y + 65, panel_x + panel_width - 10, panel_y + 65);
    
    // Описание
    draw_set_font(global.aty_font_normal);
    draw_set_color(colors.text_primary);
    var desc_y = panel_y + 80;
    draw_text_ext(panel_x + 15, desc_y, trophy.description, panel_width - 30, -1);
    
    // Награды
    var rewards_y = desc_y + string_height_ext(trophy.description, panel_width - 30, +20);
    draw_set_color(colors.neon_yellow);
    draw_text(panel_x + 15, rewards_y, "🎁 Награды:");
    
    var reward_start_y = rewards_y + 25;
    var reward_offset = 0;
    
    // Награда золотом
    if (trophy.reward_gold > 0) {
        draw_set_color(colors.neon_yellow);
        draw_text(panel_x + 25, reward_start_y + reward_offset, "💰");
        draw_set_color(colors.text_primary);
        draw_text(panel_x + 50, reward_start_y + reward_offset, string(trophy.reward_gold) + " золота");
        reward_offset += 20;
    }
    
    // Бонусы характеристик
    if (is_struct(trophy.stat_bonus)) {
        var bonus_keys = variable_struct_get_names(trophy.stat_bonus);
        for (var i = 0; i < array_length(bonus_keys); i++) {
            var key = bonus_keys[i];
            var value = variable_struct_get(trophy.stat_bonus, key);
            var bonus_text = _aty_format_stat_bonus(key, value);
            
            draw_set_color(colors.neon_green);
            draw_text(panel_x + 25, reward_start_y + reward_offset, "✨");
            draw_set_color(colors.text_primary);
            draw_text(panel_x + 50, reward_start_y + reward_offset, bonus_text);
            reward_offset += 20;
        }
    }
    
    // Статус выполнения
    var status_y = panel_y + panel_height - 60;
    draw_set_color(colors.neon_blue);
    draw_text(panel_x + 15, status_y, "📈 Статус:");
    
    if (is_unlocked) {
        var unlocked_trophy = _aty_find_unlocked_trophy(trophy.id);
        if (is_struct(unlocked_trophy) && unlocked_trophy.unlock_date > 0) {
            var date_text = _aty_format_date(unlocked_trophy.unlock_date);
            draw_set_color(colors.neon_green);
            draw_text(panel_x + 25, status_y + 25, "✅ Разблокирован: " + date_text);
        }
    } else {
        var progress = aty_get_trophy_progress(trophy.id);
        var percent = (progress / trophy.target) * 100;
        
        draw_set_color(colors.text_secondary);
        draw_text(panel_x + 25, status_y + 25, "Прогресс: " + string(progress) + "/" + string(trophy.target));
        
        // Мини-прогресс бар
        var mini_progress_width = panel_width - 50;
        draw_set_color(colors.bg_dark);
        draw_rectangle(panel_x + 25, status_y + 45, panel_x + 25 + mini_progress_width, status_y + 50, false);
        draw_set_color(rarity_color);
        draw_rectangle(panel_x + 25, status_y + 45, panel_x + 25 + mini_progress_width * (percent / 100), status_y + 50, false);
        
        draw_set_color(colors.text_primary);
        draw_text(panel_x + 25, status_y + 45, string(floor(percent)) + "%");
    }
    
    // Кнопка "Быстрое выполнение" (только в режиме отладки)
    if (global.aty.debug_mode && !is_unlocked) {
        var debug_btn_y = panel_y + panel_height - 30;
        if (draw_neon_button(panel_x + 15, debug_btn_y, 
                           panel_x + panel_width - 15, debug_btn_y + 25, 
                           "🧪 Разблокировать (тест)", false, false)) {
            aty_unlock_trophy(trophy.id);
        }
    }
}
// Вспомогательная функция для скругленных прямоугольников
function draw_roundrect(_x1, _y1, _x2, _y2, _radius) {
    // Упрощенная версия - обычный прямоугольник
    draw_rectangle(_x1, _y1, _x2, _y2, false);
}
function _aty_draw_trophy_entry(_x1, _y1, _x2, _y2, _trophy) {
    var colors = global.aty_colors;
    var rarity_color = aty_get_trophy_rarity_color(_trophy.rarity);
    
    // Фон трофея
    draw_set_color(colors.bg_medium);
    draw_rectangle(_x1, _y1, _x2, _y2, false);
    
    // Рамка по редкости
    draw_set_color(rarity_color);
    draw_rectangle(_x1, _y1, _x2, _y2, true);
    
    // Иконка трофея
    draw_set_color(_trophy.unlocked ? rarity_color : colors.text_muted);
    draw_text(_x1 + 10, _y1 + 10, _trophy.icon);
    
    // Название и описание
    draw_set_color(_trophy.unlocked ? colors.text_primary : colors.text_muted);
    draw_text(_x1 + 40, _y1 + 10, _trophy.name);
    draw_set_color(_trophy.unlocked ? colors.text_secondary : colors.text_muted);
    draw_text(_x1 + 40, _y1 + 30, _trophy.description);
    
    // Прогресс
    var progress_width = (_x2 - _x1 - 60);
    var progress_fill = (_trophy.progress / _trophy.target) * progress_width;
    
    // Фон прогресса
    draw_set_color(colors.bg_dark);
    draw_rectangle(_x1 + 40, _y1 + 50, _x1 + 40 + progress_width, _y1 + 60, false);
    
    // Заполнение прогресса
    if (_trophy.unlocked) {
        draw_set_color(colors.neon_green);
    } else {
        draw_set_color(colors.neon_blue);
    }
    draw_rectangle(_x1 + 40, _y1 + 50, _x1 + 40 + progress_fill, _y1 + 60, false);
    
    // Текст прогресса
    draw_set_color(colors.text_primary);
    draw_text(_x1 + 40, _y1 + 50, string(_trophy.progress) + " / " + string(_trophy.target));
    
    // Редкость
    draw_set_color(rarity_color);
    draw_set_halign(fa_right);
    draw_text(_x2 - 10, _y1 + 10, aty_get_trophy_rarity_name(_trophy.rarity));
    draw_set_halign(fa_left);
}
function aty_copy_item(_item) {
    if (!is_struct(_item)) return undefined;
    
    var copy = {};
    var names = variable_struct_get_names(_item);
    
    for (var i = 0; i < array_length(names); i++) {
        var key = names[i];
        var value = variable_struct_get(_item, key);
        
        // Для вложенных структур создаем копию
        if (is_struct(value)) {
            var sub_copy = {};
            var sub_names = variable_struct_get_names(value);
            for (var j = 0; j < array_length(sub_names); j++) {
                var sub_key = sub_names[j];
                variable_struct_set(sub_copy, sub_key, variable_struct_get(value, sub_key));
            }
            variable_struct_set(copy, key, sub_copy);
        }
        // Для массивов создаем копию
        else if (is_array(value)) {
            var arr_copy = [];
            for (var k = 0; k < array_length(value); k++) {
                array_push(arr_copy, value[k]);
            }
            variable_struct_set(copy, key, arr_copy);
        }
        // Для простых значений просто копируем
        else {
            variable_struct_set(copy, key, value);
        }
    }
    
    return copy;
}

// =============================================================================
// TROPHY PROGRESS TRACKING INTEGRATION
// =============================================================================

// Добавляем вызовы отслеживания прогресса в ключевые игровые события

function aty_track_combat_trophies() {
    aty_update_trophy_progress("trophy_first_kill");
    aty_update_trophy_progress("trophy_warrior");
}

function aty_track_expedition_trophies() {
    aty_update_trophy_progress("trophy_explorer");
    
    // Проверяем завершение всех экспедиций
    var all_completed = true;
    for (var i = 0; i < 5; i++) { // Обычные экспедиции
        if (!global.aty.expeditions[i].completed) {
            all_completed = false;
            break;
        }
    }
    
    if (all_completed) {
        aty_update_trophy_progress("trophy_master_explorer");
    }
}

function aty_track_collection_trophies() {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) return;
    
    var inventory_size = array_length(global.aty.inventory);
    
    // Обновляем трофей коллекционера (общее количество предметов)
    aty_update_trophy_progress("trophy_collector", inventory_size);
    
    // Считаем легендарные предметы
    var legendary_count = 0;
    for (var i = 0; i < array_length(global.aty.inventory); i++) {
        if (global.aty.inventory[i].rarity == RARITY.LEGENDARY) {
            legendary_count++;
        }
    }
    
    // Обновляем трофей накопителя (легендарные предметы)
    aty_update_trophy_progress("trophy_hoarder", legendary_count);
}

function aty_track_wealth_trophies() {
    if (global.aty.hero.gold >= 10000) {
        aty_update_trophy_progress("trophy_rich", 10000);
    }
}

function aty_track_level_trophies() {
    if (global.aty.hero.level >= 50) {
        aty_update_trophy_progress("trophy_legendary", 50);
    }
}
// Функция для создания базовой структуры квеста
function aty_create_quest_struct() {
    return {
        id: "",
        name: "",
        description: "",
        category: QUEST_CATEGORY.SIDE_QUEST,
        type: QUEST_TYPE.EXPEDITION,
        rarity: QUEST_RARITY.COMMON,
        state: QUEST_STATE.AVAILABLE,
        
        // Цели
        objectives: [],
        current_progress: [],
        
        // Требования
        required_level: 1,
        required_quests: [],
        required_items: [],
        
        // Временные ограничения
        time_limit: 0,
        start_time: 0,
        end_time: 0,
        
        // Награды
        rewards: {
            gold: 0,
            exp: 0,
            items: [],
            currency: {},
            buffs: [],
            unlock_features: []
        },
        
        // Дополнительные параметры
        repeatable: false,
        is_daily: false,
        is_weekly: false,
        difficulty: 1,
        location: "",
        story_text: "",
        completion_text: ""
    };
}

// =============================================================================
// QUEST DATABASE
// =============================================================================

function aty_get_quest_database() {
    var quests = [
        {
            id: "main_001",
            name: "Первое задание",
            description: "Завершите 5 экспедиций",
            category: QUEST_CATEGORY.MAIN_STORY,
            type: QUEST_TYPE.EXPEDITION,
            rarity: QUEST_RARITY.COMMON,
            objectives: [
                { 
                    type: QUEST_OBJECTIVE_TYPE.COMPLETE_EXPEDITIONS, 
                    target: 5, 
                    description: "Завершить экспедиции"
                }
            ],
            rewards: { 
                gold: 100, 
                exp: 50, 
                items: [],
                currency: {},
                buffs: []
            },
            time_limit: 0,
            start_time: 0,
            end_time: 0,
            required_level: 1,
            required_quests: [],
            required_items: [],
            repeatable: false,
            is_daily: false,
            is_weekly: false,
            difficulty: 1,
            location: "",
            story_text: "",
            completion_text: "",
            state: QUEST_STATE.AVAILABLE,
            current_progress: [0]
        },
        {
            id: "main_002",
            name: "Сбор ресурсов",
            description: "Соберите 10 обычных предметов",
            category: QUEST_CATEGORY.MAIN_STORY,
            type: QUEST_TYPE.COLLECTION,
            rarity: QUEST_RARITY.COMMON,
            objectives: [
                { 
                    type: QUEST_OBJECTIVE_TYPE.COLLECT_ITEMS, 
                    target: 10, 
                    description: "Собрать обычные предметы"
                }
            ],
            rewards: { 
                gold: 150, 
                exp: 75, 
                items: [],
                currency: {},
                buffs: []
            },
            time_limit: 0,
            start_time: 0,
            end_time: 0,
            required_level: 1,
            required_quests: ["main_001"],
            required_items: [],
            repeatable: false,
            is_daily: false,
            is_weekly: false,
            difficulty: 1,
            location: "",
            story_text: "",
            completion_text: "",
            state: QUEST_STATE.AVAILABLE,
            current_progress: [0]
        },
        {
            id: "daily_collect",
            name: "Ежедневный сбор",
            description: "Соберите 5 предметов за сегодня",
            category: QUEST_CATEGORY.DAILY,
            type: QUEST_TYPE.COLLECTION,
            rarity: QUEST_RARITY.COMMON,
            objectives: [
                { 
                    type: QUEST_OBJECTIVE_TYPE.COLLECT_ITEMS, 
                    target: 5, 
                    description: "Собрать предметы"
                }
            ],
            rewards: { 
                gold: 50, 
                exp: 25, 
                items: [],
                currency: {},
                buffs: []
            },
            time_limit: 86400,
            start_time: 0,
            end_time: 0,
            required_level: 1,
            required_quests: [],
            required_items: [],
            repeatable: true,
            is_daily: true,
            is_weekly: false,
            difficulty: 1,
            location: "",
            story_text: "",
            completion_text: "",
            state: QUEST_STATE.AVAILABLE,
            current_progress: [0]
        },
        {
            id: "weekly_expedition",
            name: "Еженедельная экспедиция",
            description: "Завершите 10 экспедиций за неделю",
            category: QUEST_CATEGORY.WEEKLY,
            type: QUEST_TYPE.EXPEDITION,
            rarity: QUEST_RARITY.UNCOMMON,
            objectives: [
                { 
                    type: QUEST_OBJECTIVE_TYPE.COMPLETE_EXPEDITIONS, 
                    target: 10, 
                    description: "Завершить экспедиции"
                }
            ],
            rewards: { 
                gold: 500, 
                exp: 250, 
                items: [],
                currency: {},
                buffs: []
            },
            time_limit: 604800,
            start_time: 0,
            end_time: 0,
            required_level: 1,
            required_quests: [],
            required_items: [],
            repeatable: true,
            is_daily: false,
            is_weekly: true,
            difficulty: 2,
            location: "",
            story_text: "",
            completion_text: "",
            state: QUEST_STATE.AVAILABLE,
            current_progress: [0]
        }
    ];
    
    return quests;
}
function aty_init_quests() {
    if (!variable_struct_exists(global, "aty") || !is_struct(global.aty)) return;
    
    if (!variable_struct_exists(global.aty, "quests")) {
        global.aty.quests = {
            active_quests: [],
            completed_quests: [],
            failed_quests: [],
            daily_quests: [],
            weekly_quests: [],
            daily_refresh_time: current_time, // Устанавливаем текущее время
            weekly_refresh_time: current_time, // Устанавливаем текущее время
            quest_stats: {
                total_completed: 0,
                daily_completed: 0,
                weekly_completed: 0,
                failed_quests: 0,
                gold_earned: 0,
                exp_earned: 0
            }
        };
    }
    
    // Проверяем необходимость обновления ежедневных квестов
    aty_check_daily_quest_refresh();
    aty_check_weekly_quest_refresh();
    
    // Генерируем квесты если нужно
    if (array_length(global.aty.quests.daily_quests) == 0) {
        aty_generate_daily_quests();
    }
    
    if (array_length(global.aty.quests.weekly_quests) == 0) {
        aty_generate_weekly_quests();
    }
}
function aty_check_daily_quest_refresh() {
    var current_time_value = current_time; // переименовали переменную
    var last_refresh = global.aty.quests.daily_refresh_time;
    
    // Проверяем, прошел ли день с последнего обновления
    if (current_time_value - last_refresh >= 86400) { // 24 часа в секундах
        aty_generate_daily_quests();
        global.aty.quests.daily_refresh_time = current_time_value;
        global.aty.quests.quest_stats.daily_completed = 0;
    }
}

function aty_check_weekly_quest_refresh() {
    var current_time_value = current_time; // переименовали переменную
    var last_refresh = global.aty.quests.weekly_refresh_time;
    
    // Проверяем, прошла ли неделя с последнего обновления
    if (current_time_value - last_refresh >= 604800) { // 7 дней в секундах
        aty_generate_weekly_quests();
        global.aty.quests.weekly_refresh_time = current_time_value;
        global.aty.quests.quest_stats.weekly_completed = 0;
    }
}

function aty_generate_weekly_quests() {
    // Аналогично aty_generate_daily_quests, но для недельных квестов
    if (!variable_struct_exists(global.aty, "quests")) return;
    
    var quest_db = aty_get_quest_database();
    var weekly_quests = [];
    
    for (var i = 0; i < array_length(quest_db); i++) {
        if (variable_struct_exists(quest_db[i], "is_weekly") && quest_db[i].is_weekly) {
            var quest_copy = aty_copy_quest(quest_db[i]);
            quest_copy.state = QUEST_STATE.AVAILABLE;
            quest_copy.current_progress = array_create(array_length(quest_copy.objectives), 0);
            array_push(weekly_quests, quest_copy);
        }
    }
    
    if (!variable_struct_exists(global.aty.quests, "weekly_quests")) {
        global.aty.quests.weekly_quests = [];
    }
    
    global.aty.quests.weekly_quests = [];
    
    for (var i = 0; i < min(2, array_length(weekly_quests)); i++) {
        if (array_length(weekly_quests) == 0) break;
        
        var random_index = irandom(array_length(weekly_quests) - 1);
        array_push(global.aty.quests.weekly_quests, weekly_quests[random_index]);
        array_delete(weekly_quests, random_index, 1);
    }
    
    if (array_length(global.aty.quests.weekly_quests) == 0) {
        aty_create_default_weekly_quests();
    }
}
// Исправленная функция aty_create_default_daily_quests
function aty_create_default_daily_quests() {
    if (!variable_struct_exists(global.aty, "quests")) return;
    
    var default_dailies = [
        {
            id: "daily_collect_common",
            name: "Сбор ресурсов",
            description: "Соберите обычные предметы",
            category: QUEST_CATEGORY.DAILY,
            type: QUEST_TYPE.COLLECTION,
            rarity: QUEST_RARITY.COMMON,
            objectives: [
                { 
                    type: QUEST_OBJECTIVE_TYPE.COLLECT_ITEMS, 
                    target: 5, 
                    description: "Собрать обычные предметы",
                    item_id: "common_item" // Добавляем конкретный ID предмета
                }
            ],
            rewards: { 
                gold: 50, 
                exp: 25, 
                items: [],
                currency: {},
                buffs: []
            },
            time_limit: 86400, // 24 часа
            start_time: 0,
            end_time: 0,
            required_level: 1,
            required_quests: [],
            required_items: [],
            repeatable: true,
            is_daily: true,
            is_weekly: false,
            difficulty: 1,
            state: QUEST_STATE.AVAILABLE,
            current_progress: [0]
        },
        {
            id: "daily_defeat_enemies",
            name: "Охотник за головами",
            description: "Победите врагов в экспедициях",
            category: QUEST_CATEGORY.DAILY,
            type: QUEST_TYPE.COMBAT,
            rarity: QUEST_RARITY.COMMON,
            objectives: [
                { 
                    type: QUEST_OBJECTIVE_TYPE.DEFEAT_ENEMIES, 
                    target: 10, 
                    description: "Победить врагов",
                    enemy_type: "any" // Тип врага (any - любой)
                }
            ],
            rewards: { 
                gold: 75, 
                exp: 50, 
                items: [],
                currency: {},
                buffs: []
            },
            time_limit: 86400,
            start_time: 0,
            end_time: 0,
            required_level: 1,
            required_quests: [],
            required_items: [],
            repeatable: true,
            is_daily: true,
            is_weekly: false,
            difficulty: 1,
            state: QUEST_STATE.AVAILABLE,
            current_progress: [0]
        },
        {
            id: "daily_complete_expeditions", 
            name: "Исследователь",
            description: "Завершите экспедиции",
            category: QUEST_CATEGORY.DAILY,
            type: QUEST_TYPE.EXPEDITION,
            rarity: QUEST_RARITY.COMMON,
            objectives: [
                { 
                    type: QUEST_OBJECTIVE_TYPE.COMPLETE_EXPEDITIONS, 
                    target: 3, 
                    description: "Завершить экспедиции",
                    expedition_type: "any"
                }
            ],
            rewards: { 
                gold: 100, 
                exp: 75, 
                items: [],
                currency: {},
                buffs: []
            },
            time_limit: 86400,
            start_time: 0,
            end_time: 0,
            required_level: 1,
            required_quests: [],
            required_items: [],
            repeatable: true,
            is_daily: true,
            is_weekly: false,
            difficulty: 1,
            state: QUEST_STATE.AVAILABLE,
            current_progress: [0]
        }
    ];
    
    global.aty.quests.daily_quests = [];
    for (var i = 0; i < array_length(default_dailies); i++) {
        var quest_copy = aty_copy_quest(default_dailies[i]);
        quest_copy.state = QUEST_STATE.AVAILABLE;
        quest_copy.current_progress = array_create(array_length(quest_copy.objectives), 0);
        array_push(global.aty.quests.daily_quests, quest_copy);
    }
    
    show_debug_message("Created " + string(array_length(global.aty.quests.daily_quests)) + " default daily quests");
}

// Также исправьте aty_create_default_weekly_quests
function aty_create_default_weekly_quests() {
    if (!variable_struct_exists(global.aty, "quests")) return;
    
    var default_weeklies = [
        {
            id: "weekly_collect_rare",
            name: "Сбор редких ресурсов",
            description: "Соберите редкие предметы",
            category: QUEST_CATEGORY.WEEKLY,
            type: QUEST_TYPE.COLLECTION,
            rarity: QUEST_RARITY.UNCOMMON,
            objectives: [
                { 
                    type: QUEST_OBJECTIVE_TYPE.COLLECT_ITEMS, 
                    target: 10, 
                    description: "Собрать редкие предметы",
                    item_id: "rare_item"
                }
            ],
            rewards: { 
                gold: 500, 
                exp: 300, 
                items: [{"id": "rare_chest", "count": 1}],
                currency: {},
                buffs: []
            },
            time_limit: 604800, // 7 дней
            start_time: 0,
            end_time: 0,
            required_level: 5,
            required_quests: [],
            required_items: [],
            repeatable: true,
            is_daily: false,
            is_weekly: true,
            difficulty: 2,
            state: QUEST_STATE.AVAILABLE,
            current_progress: [0]
        },
        {
            id: "weekly_earn_gold",
            name: "Золотая лихорадка",
            description: "Заработайте много золота",
            category: QUEST_CATEGORY.WEEKLY,
            type: QUEST_TYPE.ECONOMY,
            rarity: QUEST_RARITY.UNCOMMON,
            objectives: [
                { 
                    type: QUEST_OBJECTIVE_TYPE.EARN_GOLD, 
                    target: 5000, 
                    description: "Заработать золото"
                }
            ],
            rewards: { 
                gold: 1000, 
                exp: 500, 
                items: [],
                currency: {},
                buffs: []
            },
            time_limit: 604800,
            start_time: 0,
            end_time: 0,
            required_level: 3,
            required_quests: [],
            required_items: [],
            repeatable: true,
            is_daily: false,
            is_weekly: true,
            difficulty: 2,
            state: QUEST_STATE.AVAILABLE,
            current_progress: [0]
        }
    ];
    
    global.aty.quests.weekly_quests = [];
    for (var i = 0; i < array_length(default_weeklies); i++) {
        var quest_copy = aty_copy_quest(default_weeklies[i]);
        quest_copy.state = QUEST_STATE.AVAILABLE;
        quest_copy.current_progress = array_create(array_length(quest_copy.objectives), 0);
        array_push(global.aty.quests.weekly_quests, quest_copy);
    }
    
    show_debug_message("Created " + string(array_length(global.aty.quests.weekly_quests)) + " default weekly quests");
}
// =============================================================================
// QUEST EVENT HANDLERS
// =============================================================================

function aty_on_expedition_complete(_expedition_level) {
    // Обновляем прогресс квестов связанных с экспедициями
    var all_quests = array_merge(global.aty.quests.active_quests, 
                                global.aty.quests.daily_quests,
                                global.aty.quests.weekly_quests);
    
    for (var i = 0; i < array_length(all_quests); i++) {
        var quest = all_quests[i];
        
        if (quest.state == QUEST_STATE.IN_PROGRESS) {
            for (var j = 0; j < array_length(quest.objectives); j++) {
                var objective = quest.objectives[j];
                
                if (objective.type == "complete_expedition") {
                    quest.current_progress[j] += 1;
                } else if (objective.type == "complete_high_expedition" && _expedition_level >= 3) {
                    quest.current_progress[j] += 1;
                }
            }
        }
    }
}

function aty_on_item_sold() {
    // Обновляем прогресс квестов связанных с продажей
    var all_quests = array_merge(global.aty.quests.active_quests, 
                                global.aty.quests.daily_quests,
                                global.aty.quests.weekly_quests);
    
    for (var i = 0; i < array_length(all_quests); i++) {
        var quest = all_quests[i];
        
        if (quest.state == QUEST_STATE.IN_PROGRESS) {
            for (var j = 0; j < array_length(quest.objectives); j++) {
                var objective = quest.objectives[j];
                
                if (objective.type == "sell_items") {
                    quest.current_progress[j] += 1;
                }
            }
        }
    }
}

function aty_on_item_upgraded() {
    // Обновляем прогресс квестов связанных с улучшением
    var all_quests = array_merge(global.aty.quests.active_quests, 
                                global.aty.quests.daily_quests,
                                global.aty.quests.weekly_quests);
    
    for (var i = 0; i < array_length(all_quests); i++) {
        var quest = all_quests[i];
        
        if (quest.state == QUEST_STATE.IN_PROGRESS) {
            for (var j = 0; j < array_length(quest.objectives); j++) {
                var objective = quest.objectives[j];
                
                if (objective.type == "upgrade_items") {
                    quest.current_progress[j] += 1;
                }
            }
        }
    }
}

// =============================================================================
// QUEST INTERACTION FUNCTIONS
// =============================================================================

function aty_give_minigame_rewards(_minigame) {
    if (!is_struct(_minigame) || !variable_struct_exists(_minigame, "event_data")) {
        show_debug_message("ERROR: Invalid minigame struct in aty_give_minigame_rewards");
        return;
    }
    
    var eevent_data = _minigame.event_data;
    var rewards = eevent_data.rewards;
    
    // Безопасно определяем результат
    var result = MINIGAME_RESULT.SUCCESS;
    if (variable_struct_exists(_minigame, "result")) {
        result = _minigame.result;
    }
    
    var reward_data = (result == MINIGAME_RESULT.CRITICAL_SUCCESS) ? 
                     (variable_struct_exists(rewards, "critical") ? rewards.critical : rewards.success) : 
                     rewards.success;
    
    // Безопасно выдаем награды
    if (is_struct(reward_data)) {
        // Выдаем золото
        if (variable_struct_exists(reward_data, "gold")) {
            global.aty.hero.gold += reward_data.gold;
        }
        
        // Выдаем опыт
        if (variable_struct_exists(reward_data, "exp")) {
            global.aty.hero.exp += reward_data.exp;
        }
        
        // Выдаем предметы
        if (variable_struct_exists(reward_data, "items") && is_array(reward_data.items)) {
            for (var i = 0; i < array_length(reward_data.items); i++) {
                var item = aty_generate_loot_item_safe(reward_data.items[i]);
                array_push(global.aty.inventory, item);
            }
        }
        
        // Применяем баффы
        if (variable_struct_exists(reward_data, "buffs") && is_array(reward_data.buffs)) {
            for (var i = 0; i < array_length(reward_data.buffs); i++) {
                aty_apply_minigame_buff(reward_data.buffs[i]);
            }
        }
    }
}
function aty_give_quest_rewards(_quest) {
    var rewards = _quest.rewards;
    
    // Золото
    if (rewards.gold > 0) {
        global.aty.hero.gold += rewards.gold;
    }
    
    // Опыт
    if (rewards.exp > 0) {
        global.aty.hero.exp += rewards.exp;
        // Проверяем повышение уровня
        aty_check_level_up();
    }
    
    // Предметы
    if (array_length(rewards.items) > 0) {
        for (var i = 0; i < array_length(rewards.items); i++) {
            var item = aty_generate_loot_item_safe(rewards.items[i]);
            aty_add_item_to_inventory(item);
        }
    }
    
    // Баффы
    if (array_length(rewards.buffs) > 0) {
        for (var i = 0; i < array_length(rewards.buffs); i++) {
            aty_apply_quest_buff(rewards.buffs[i]);
        }
    }
    
    // Особые разблокировки
    if (rewards.special_unlock != "") {
        aty_unlock_special_content(rewards.special_unlock);
    }
}

// =============================================================================
// QUEST UTILITY FUNCTIONS
// =============================================================================

function aty_find_quest_by_id(_quest_id) {
    // Ищем во всех типах квестов
    var search_arrays = [
        global.aty.quests.active_quests,
        global.aty.quests.daily_quests, 
        global.aty.quests.weekly_quests,
        global.aty.quests.completed_quests,
        global.aty.quests.failed_quests
    ];
    
    for (var i = 0; i < array_length(search_arrays); i++) {
        for (var j = 0; j < array_length(search_arrays[i]); j++) {
            if (search_arrays[i][j].id == _quest_id) {
                return search_arrays[i][j];
            }
        }
    }
    
    // Если не нашли в массивах, ищем в базе данных
    var quest_db = aty_get_quest_database();
    for (var i = 0; i < array_length(quest_db); i++) {
        if (quest_db[i].id == _quest_id) {
            return quest_db[i];
        }
    }
    
    return undefined;
}
function aty_meets_quest_requirements(_quest) {
    // Базовая проверка уровня
    if (_quest.required_level > global.aty.hero.level) {
        return false;
    }
    
    // Дополнительные проверки можно добавить здесь
    return true;
}

function aty_is_quest_completed(_quest_id) {
    if (!variable_struct_exists(global.aty.quests, "completed_quests")) return false;
    
    for (var i = 0; i < array_length(global.aty.quests.completed_quests); i++) {
        if (global.aty.quests.completed_quests[i].id == _quest_id) {
            return true;
        }
    }
    return false;
}
function aty_has_item_in_inventory(_item_id) {
    if (!variable_struct_exists(global.aty, "inventory")) return false;
    
    for (var i = 0; i < array_length(global.aty.inventory); i++) {
        if (global.aty.inventory[i].id == _item_id) {
            return true;
        }
    }
    return false;
}
function aty_has_required_item(_item_requirement) {
    // Реализуйте проверку наличия предмета в инвентаре
    // Это упрощенная версия - нужно доработать под конкретные требования
    return true;
}

function aty_copy_quest(_quest = undefined) {
    var copy = aty_create_quest_struct();
    
    // Если аргумент не передан или не является структурой, возвращаем пустой квест
    if (!is_struct(_quest)) return copy;
    
    // Остальной код функции остается без изменений
    var names = variable_struct_get_names(_quest);
    for (var i = 0; i < array_length(names); i++) {
        var key = names[i];
        var value = variable_struct_get(_quest, key);
        
        if (is_array(value)) {
            var arr_copy = [];
            for (var j = 0; j < array_length(value); j++) {
                if (is_struct(value[j])) {
                    array_push(arr_copy, aty_copy_quest(value[j]));
                } else {
                    array_push(arr_copy, value[j]);
                }
            }
            variable_struct_set(copy, key, arr_copy);
        } else if (is_struct(value)) {
            variable_struct_set(copy, key, aty_copy_quest(value));
        } else {
            variable_struct_set(copy, key, value);
        }
    }
    
    return copy;
}
function aty_remove_quest_from_active(_quest_id) {
    for (var i = array_length(global.aty.quests.active_quests) - 1; i >= 0; i--) {
        if (global.aty.quests.active_quests[i].id == _quest_id) {
            array_delete(global.aty.quests.active_quests, i, 1);
            return true;
        }
    }
    return false;
}

function aty_reset_repeatable_quest(_quest) {
    _quest.state = QUEST_STATE.AVAILABLE;
    _quest.current_progress = array_create(array_length(_quest.objectives), 0);
    _quest.start_time = 0;
    _quest.end_time = 0;
}

function aty_apply_quest_buff(_buff_key) {
    // Применяем временные баффы от квестов
    if (!variable_struct_exists(global.aty, "quest_buffs")) {
        global.aty.quest_buffs = [];
    }
    
    var buff_data = aty_get_quest_buff_data(_buff_key);
    if (is_struct(buff_data)) {
        array_push(global.aty.quest_buffs, buff_data);
        aty_show_notification("Получен бафф: " + buff_data.name);
    }
}

function aty_get_quest_buff_data(_buff_key) {
    var buffs_db = {
        "NEWBIE_BLESSING": {
            name: "Благословение новичка",
            description: "+10% к получаемому опыту на 1 час",
            duration: 3600, // 1 час в секундах
            stats: { exp_bonus: 10 }
        },
        "BETTER_DEALS": {
            name: "Удачная сделка", 
            description: "+15% к золоту с продаж на 2 часа",
            duration: 7200,
            stats: { sell_bonus: 15 }
        },
        "WEEKLY_BOOST": {
            name: "Еженедельный импульс",
            description: "+20% ко всем характеристикам на 24 часа",
            duration: 86400,
            stats: { all_stats: 20 }
        },
        "UPGRADE_MASTERY": {
            name: "Мастер улучшений",
            description: "Скидка 25% на улучшение предметов на 3 дня",
            duration: 259200,
            stats: { upgrade_discount: 25 }
        },
        "LEGENDARY_LUCK": {
            name: "Удача легенд",
            description: "Увеличивает шанс найти легендарные предметы на 5% на 1 неделю",
            duration: 604800,
            stats: { legendary_drop: 5 }
        }
    };
    
    return buffs_db[_buff_key] || undefined;
}

function aty_unlock_special_content(_unlock_key) {
    switch (_unlock_key) {
        case "COMPANION_COSTUME":
            // Разблокируем особый костюм для случайной помощницы
            var available_companions = [];
            for (var i = 0; i < array_length(global.aty.companions); i++) {
                if (global.aty.companions[i].unlocked) {
                    array_push(available_companions, i);
                }
            }
            
            if (array_length(available_companions) > 0) {
                var random_index = available_companions[irandom(array_length(available_companions) - 1)];
                var new_costume = "special_" + string(irandom(3));
                if (!array_contains(global.aty.companions[random_index].costumes, new_costume)) {
                    array_push(global.aty.companions[random_index].costumes, new_costume);
                    aty_show_notification("🎉 Разблокирован особый костюм для " + global.aty.companions[random_index].name + "!");
                }
            }
            break;
            
        // Добавьте другие особые разблокировки по мере необходимости
    }
}

// =============================================================================
// ENHANCED QUEST UI
// =============================================================================

function _aty_draw_quest_card_enhanced(_x1, _y1, _x2, _quest, _show_progress) {
    var card_height = 160;
    var _y2 = _y1 + card_height;
    var safe_colors = _aty_get_safe_colors();
    
    // Безопасная проверка квеста
    if (!is_struct(_quest)) {
        return _y2;
    }
    
    // Фон карточки с закруглёнными углами (эффект)
    draw_set_color(safe_colors.bg_lighter);
    draw_rectangle(_x1 + 2, _y1 + 2, _x2 - 2, _y2 - 2, false);
    
    // Основной фон
    draw_set_color(safe_colors.bg_light);
    draw_rectangle(_x1, _y1, _x2, _y2, false);
    
    // Полоска редкости с градиентом
    var rarity_color = _aty_get_quest_rarity_color_safe(_quest.rarity);
    draw_set_color(rarity_color);
    draw_rectangle(_x1, _y1, _x1 + 6, _y2, false);
    
    // Внешняя рамка
    draw_set_color(safe_colors.border);
    draw_rectangle(_x1, _y1, _x2, _y2, true);
    
    // Заголовок квеста
    draw_set_font(global.aty_font_bold);
    draw_set_color(safe_colors.text_primary);
    var quest_name = variable_struct_exists(_quest, "name") ? _quest.name : "Неизвестный квест";
    draw_text(_x1 + 15, _y1 + 12, quest_name);
    
    // Иконка типа квеста
    var type_icon = _aty_get_quest_type_icon(_quest.type);
    draw_set_color(safe_colors.text_accent);
    draw_text(_x1 + _x2 - 30, _y1 + 12, type_icon);
    
    // Описание квеста
    draw_set_font(global.aty_font_small);
    draw_set_color(safe_colors.text_secondary);
    var quest_desc = variable_struct_exists(_quest, "description") ? _quest.description : "Описание отсутствует";
    draw_text_ext(_x1 + 15, _y1 + 35, quest_desc, _x2 - _x1 - 30, 40);
    
    // Прогресс (только для активных квестов)
    if (_show_progress && variable_struct_exists(_quest, "objectives") && variable_struct_exists(_quest, "current_progress")) {
        var progress_y = _y1 + 80;
        
        for (var i = 0; i < min(array_length(_quest.objectives), 2); i++) { // Ограничиваем 2 целями
            if (i >= array_length(_quest.current_progress)) break;
            
            var objective = _quest.objectives[i];
            var progress = _quest.current_progress[i];
            var target = variable_struct_exists(objective, "target") ? objective.target : 1;
            
            // Текст цели
            var objective_text = _aty_get_objective_text_safe(objective);
            draw_set_color(safe_colors.text_secondary);
            draw_text(_x1 + 15, progress_y, objective_text);
            
            // Прогресс-бар
            if (target > 0) {
                var bar_width = (_x2 - _x1 - 40);
                var progress_width = bar_width * (progress / target);
                
                // Фон прогресс-бара
                draw_set_color(safe_colors.bg_medium);
                draw_rectangle(_x1 + 15, progress_y + 15, _x1 + 15 + bar_width, progress_y + 22, false);
                
                // Заполнение прогресс-бара
                var progress_color = (progress >= target) ? safe_colors.success : safe_colors.accent;
                draw_set_color(progress_color);
                draw_rectangle(_x1 + 15, progress_y + 15, _x1 + 15 + progress_width, progress_y + 22, false);
                
                // Текст прогресса
                draw_set_color(safe_colors.text_light);
                draw_set_font(global.aty_font_small);
                var progress_text = string(progress) + "/" + string(target);
                draw_text_centered(_x1 + 15 + (bar_width / 2), progress_y + 16, progress_text);
            }
            
            progress_y += 30;
        }
    }
    
    // Награды
    var rewards_y = _y1 + card_height - 35;
    draw_set_font(global.aty_font_small);
    draw_set_color(safe_colors.text_accent);
    
    var reward_text = "Награда: ";
    if (variable_struct_exists(_quest, "rewards")) {
        var rewards = _quest.rewards;
        if (variable_struct_exists(rewards, "gold") && rewards.gold > 0) reward_text += "💰" + string(rewards.gold) + " ";
        if (variable_struct_exists(rewards, "exp") && rewards.exp > 0) reward_text += "⭐" + string(rewards.exp) + " ";
        if (variable_struct_exists(rewards, "items") && array_length(rewards.items) > 0) reward_text += "🎁" + string(array_length(rewards.items));
    }
    
    draw_text(_x1 + 15, rewards_y, reward_text);
    
    // Временные ограничения (для активных квестов с таймером)
    if (_show_progress && variable_struct_exists(_quest, "time_limit") && _quest.time_limit > 0 && 
        variable_struct_exists(_quest, "state") && _quest.state == QUEST_STATE.IN_PROGRESS) {
        
        var time_left = 0;
        if (variable_struct_exists(_quest, "end_time")) {
            time_left = _quest.end_time - current_time;
        }
        
        if (time_left > 0) {
            var time_text = "Осталось: " + _aty_format_time_safe(time_left);
            draw_set_color(safe_colors.warning);
            draw_text(_x2 - 150, rewards_y, time_text);
        }
    }
    
    // Статус квеста
    var status_y = _y1 + card_height - 15;
    var status_text = _aty_get_quest_status_text(_quest.state);
    var status_color = _aty_get_quest_status_color(_quest.state);
    
    draw_set_color(status_color);
    draw_text(_x1 + 15, status_y, status_text);
    
    return _y2;
}
// =============================================================================
// QUEST HELPER FUNCTIONS (SAFE)
// =============================================================================

function _aty_get_safe_colors() {
    if (!variable_global_exists("aty_colors")) {
        aty_init_colors();
    }
    
    var colors = global.aty_colors;
    var safe_colors = {};
    var color_names = variable_struct_get_names(colors);
    
    for (var i = 0; i < array_length(color_names); i++) {
        var color_name = color_names[i];
        safe_colors[color_name] = colors[color_name];
    }
    
    // Гарантируем наличие основных цветов
    if (!variable_struct_exists(safe_colors, "accent")) safe_colors.accent = make_color_rgb(0, 150, 255);
    if (!variable_struct_exists(safe_colors, "bg_light")) safe_colors.bg_light = make_color_rgb(50, 50, 70);
    if (!variable_struct_exists(safe_colors, "text_primary")) safe_colors.text_primary = make_color_rgb(255, 255, 255);
    if (!variable_struct_exists(safe_colors, "text_secondary")) safe_colors.text_secondary = make_color_rgb(180, 180, 200);
    if (!variable_struct_exists(safe_colors, "border")) safe_colors.border = make_color_rgb(80, 80, 120);
    
    return safe_colors;
}

function _aty_get_safe_quest_array(_quest_type) {
    if (!variable_struct_exists(global.aty, "quests")) return [];
    if (!variable_struct_exists(global.aty.quests, _quest_type)) return [];
    
    var quests = global.aty.quests[_quest_type];
    return is_array(quests) ? quests : [];
}

function _aty_get_quest_stats() {
    var stats = {
        total_completed: 0,
        active_count: 0,
        available_count: 0
    };
    
    if (!variable_struct_exists(global.aty, "quests")) return stats;
    
    // Общее количество выполненных
    if (variable_struct_exists(global.aty.quests.quest_stats, "total_completed")) {
        stats.total_completed = global.aty.quests.quest_stats.total_completed;
    }
    
    // Активные квесты
    stats.active_count = _aty_get_safe_quest_array("active_quests").length;
    
    // Доступные квесты
    try {
        stats.available_count = array_length(aty_get_available_quests());
    } catch (e) {
        stats.available_count = 0;
    }
    
    return stats;
}

function _aty_get_daily_refresh_time() {
    if (!variable_struct_exists(global.aty.quests, "daily_refresh_time")) return "00:00";
    
    var time_left = 86400 - (current_time - global.aty.quests.daily_refresh_time);
    var hours = floor(time_left / 3600);
    var minutes = floor((time_left % 3600) / 60);
    
    return string(hours) + "ч " + string(minutes) + "м";
}

function _aty_get_weekly_refresh_time() {
    if (!variable_struct_exists(global.aty.quests, "weekly_refresh_time")) return "7д 00ч";
    
    var time_left = 604800 - (current_time - global.aty.quests.weekly_refresh_time);
    var days = floor(time_left / 86400);
    var hours = floor((time_left % 86400) / 3600);
    
    return string(days) + "д " + string(hours) + "ч";
}

function _aty_get_quest_rarity_color_safe(_rarity) {
    var safe_colors = _aty_get_safe_colors();
    
    switch (_rarity) {
        case QUEST_RARITY.COMMON: return safe_colors.rarity_common;
        case QUEST_RARITY.UNCOMMON: return safe_colors.rarity_uncommon;
        case QUEST_RARITY.RARE: return safe_colors.rarity_rare;
        case QUEST_RARITY.EPIC: return safe_colors.rarity_epic;
        case QUEST_RARITY.LEGENDARY: return safe_colors.rarity_legendary;
        default: return safe_colors.rarity_common;
    }
}

function _aty_get_quest_type_icon(_quest_type) {
    switch (_quest_type) {
        case QUEST_TYPE.EXPEDITION: return "🗺️";
        case QUEST_TYPE.COLLECTION: return "📦";
        case QUEST_TYPE.COMBAT: return "⚔️";
        case QUEST_TYPE.ECONOMY: return "💰";
        case QUEST_TYPE.UPGRADE: return "🛠️";
        case QUEST_TYPE.COMPANION: return "👥";
        default: return "❓";
    }
}

function _aty_get_objective_text_safe(_objective) {
    if (!is_struct(_objective)) return "Неизвестная цель";
    
    var objective_type = variable_struct_exists(_objective, "type") ? _objective.type : QUEST_OBJECTIVE_TYPE.COLLECT_ITEMS;
    
    switch (objective_type) {
        case QUEST_OBJECTIVE_TYPE.COLLECT_ITEMS: return "Собрать предметы";
        case QUEST_OBJECTIVE_TYPE.DEFEAT_ENEMIES: return "Победить врагов";
        case QUEST_OBJECTIVE_TYPE.COMPLETE_EXPEDITIONS: return "Завершить экспедиции";
        case QUEST_OBJECTIVE_TYPE.EARN_GOLD: return "Заработать золото";
        case QUEST_OBJECTIVE_TYPE.REACH_LEVEL: return "Достигнуть уровня";
        case QUEST_OBJECTIVE_TYPE.COMPLETE_MINIGAMES: return "Завершить мини-игры";
        default: return "Выполнить задание";
    }
}

function _aty_format_time_safe(_seconds) {
    if (_seconds <= 0) return "00:00";
    
    var hours = floor(_seconds / 3600);
    var minutes = floor((_seconds % 3600) / 60);
    
    if (hours > 0) {
        return string(hours) + "ч " + string(minutes) + "м";
    } else {
        return string(minutes) + "м";
    }
}

function _aty_get_quest_status_text(_state) {
    switch (_state) {
        case QUEST_STATE.AVAILABLE: return "Доступен";
        case QUEST_STATE.IN_PROGRESS: return "В процессе";
        case QUEST_STATE.COMPLETED: return "Завершён";
        case QUEST_STATE.CLAIMED: return "Награда получена";
        case QUEST_STATE.FAILED: return "Провален";
        default: return "Неизвестно";
    }
}

function _aty_get_quest_status_color(_state) {
    var safe_colors = _aty_get_safe_colors();
    
    switch (_state) {
        case QUEST_STATE.AVAILABLE: return safe_colors.quest_available;
        case QUEST_STATE.IN_PROGRESS: return safe_colors.quest_active;
        case QUEST_STATE.COMPLETED: return safe_colors.quest_completed;
        case QUEST_STATE.CLAIMED: return safe_colors.quest_claimed;
        case QUEST_STATE.FAILED: return safe_colors.quest_failed;
        default: return safe_colors.text_muted;
    }
}

function _aty_draw_empty_state(_zone, _title, _subtitle, _color) {
    var center_x = _zone.x1 + (_zone.x2 - _zone.x1) / 2;
    var center_y = _zone.y1 + (_zone.y2 - _zone.y1) / 2;
    
    draw_set_font(global.aty_font_bold);
    draw_set_color(_color);
    draw_set_halign(fa_center);
    draw_text(center_x, center_y - 20, _title);
    
    draw_set_font(global.aty_font_small);
    draw_text(center_x, center_y + 5, _subtitle);
    draw_set_halign(fa_left);
}

function _aty_draw_more_items_indicator(_zone, _y, _count) {
    var safe_colors = _aty_get_safe_colors();
    var center_x = _zone.x1 + (_zone.x2 - _zone.x1) / 2;
    
    draw_set_font(global.aty_font_small);
    draw_set_color(safe_colors.text_muted);
    draw_set_halign(fa_center);
    draw_text(center_x, _y + 10, "... и ещё " + string(_count) + " квестов ...");
    draw_set_halign(fa_left);
}

function _aty_draw_panel_header(_x1, _y1, _x2, _y2, _title, _color) {
    var safe_colors = _aty_get_safe_colors();
    
    // Фон заголовка
    draw_set_color(safe_colors.bg_medium);
    draw_rectangle(_x1, _y1, _x2, _y2, false);
    
    // Акцентная полоса сверху
    draw_set_color(_color);
    draw_rectangle(_x1, _y1, _x2, _y1 + 3, false);
    
    // Текст заголовка
    draw_set_font(global.aty_font_title);
    draw_set_color(safe_colors.text_primary);
    draw_text(_x1 + 15, _y1 + 15, _title);
}
// Helper functions
function aty_get_objective_text(_objective) {
    switch (_objective.type) {
        case QUEST_OBJECTIVE_TYPE.COLLECT_ITEMS:
            return "Collect items";
        case QUEST_OBJECTIVE_TYPE.DEFEAT_ENEMIES:
            return "Defeat enemies";
        case QUEST_OBJECTIVE_TYPE.COMPLETE_EXPEDITIONS:
            return "Complete expeditions";
        case QUEST_OBJECTIVE_TYPE.EARN_GOLD:
            return "Earn gold";
        case QUEST_OBJECTIVE_TYPE.REACH_LEVEL:
            return "Reach level";
        case QUEST_OBJECTIVE_TYPE.COMPLETE_MINIGAMES:
            return "Complete minigames";
        default:
            return "Complete objective";
    }
}
function aty_format_time(_seconds) {
    var hours = floor(_seconds / 3600);
    var minutes = floor((_seconds % 3600) / 60);
    var seconds = _seconds % 60;
    
    if (hours > 0) {
        return string(hours) + "h " + string(minutes) + "m";
    } else if (minutes > 0) {
        return string(minutes) + "m " + string(seconds) + "s";
    } else {
        return string(seconds) + "s";
    }
}

function aty_get_quest_rarity_color(_rarity) {
    // Безопасная инициализация цветов
    if (!variable_global_exists("aty_colors")) {
        aty_init_colors();
    }
    var colors = global.aty_colors;
    
    // Проверяем наличие цветов редкости
    if (!variable_struct_exists(colors, "rarity_common")) colors.rarity_common = make_color_rgb(200, 200, 200);
    if (!variable_struct_exists(colors, "rarity_uncommon")) colors.rarity_uncommon = make_color_rgb(0, 200, 0);
    if (!variable_struct_exists(colors, "rarity_rare")) colors.rarity_rare = make_color_rgb(0, 100, 255);
    if (!variable_struct_exists(colors, "rarity_epic")) colors.rarity_epic = make_color_rgb(180, 0, 255);
    if (!variable_struct_exists(colors, "rarity_legendary")) colors.rarity_legendary = make_color_rgb(255, 150, 0);
    
    switch (_rarity) {
        case QUEST_RARITY.COMMON: return colors.rarity_common;
        case QUEST_RARITY.UNCOMMON: return colors.rarity_uncommon;
        case QUEST_RARITY.RARE: return colors.rarity_rare;
        case QUEST_RARITY.EPIC: return colors.rarity_epic;
        case QUEST_RARITY.LEGENDARY: return colors.rarity_legendary;
        default: return colors.rarity_common;
    }
}
// =============================================================================
// QUEST INTEGRATION WITH EXISTING SYSTEMS
// =============================================================================

function aty_handle_quests_tab_clicks(_mx, _my, _zone) {
    // Обработка вкладок категорий квестов
    var tab_y = _zone.y1 + 70;
    var categories = ["Активные", "Ежедневные", "Еженедельные", "Доступные", "Завершенные", "Проваленные"];
    var tab_width = 120;
    
    for (var i = 0; i < array_length(categories); i++) {
        var tab_x = _zone.x1 + 20 + i * (tab_width + 10);
        
        if (point_in_rectangle(_mx, _my, tab_x, tab_y, tab_x + tab_width, tab_y + 30)) {
            global.aty.current_quest_category = i;
            return true;
        }
    }
    
    // Обработка кликов по кнопкам квестов
    var content_y = tab_y + 40;
    var quests = [];
    
    switch (global.aty.current_quest_category) {
        case 0: quests = global.aty.quests.active_quests; break;
        case 1: quests = global.aty.quests.daily_quests; break;
        case 2: quests = global.aty.quests.weekly_quests; break;
        case 3: quests = aty_get_available_quests(); break;
        case 4: quests = global.aty.quests.completed_quests; break;
        case 5: quests = global.aty.quests.failed_quests; break;
    }
    
    var quest_y = content_y;
    
    for (var i = 0; i < array_length(quests); i++) {
        if (quest_y > _zone.y2 - 100) break;
        
        var quest = quests[i];
        var button_x = _zone.x2 - 120;
        var button_y = quest_y + 60;
        
        if (point_in_rectangle(_mx, _my, button_x, button_y, button_x + 90, button_y + 30)) {
            if (quest.state == QUEST_STATE.AVAILABLE) {
                aty_start_quest(quest.id);
                return true;
            } else if (quest.state == QUEST_STATE.COMPLETED) {
                aty_claim_quest_reward(quest.id);
                return true;
            }
        }
        
        quest_y += 100;
    }
    
    return false;
}

function aty_get_available_quests() {
    var available = [];
    var quest_database = aty_get_quest_database();
    
    for (var i = 0; i < array_length(quest_database); i++) {
        var quest = quest_database[i];
        
        // Check if quest is not daily/weekly and is available
        if (!quest.is_daily && !quest.is_weekly) {
            var existing_quest = aty_find_quest_by_id(quest.id);
            
            // If quest not found in active/completed/failed - it's available
            if (!is_struct(existing_quest)) {
                if (aty_meets_quest_requirements(quest)) {
                    array_push(available, quest);
                }
            }
        }
    }
    
    return available;
}
function aty_abandon_quest(_quest_id) {
    var quest = aty_find_quest_by_id(_quest_id);
    
    if (!is_struct(quest) || quest.state != QUEST_STATE.IN_PROGRESS) {
        return false;
    }
    
    quest.state = QUEST_STATE.AVAILABLE;
    quest.current_progress = array_create(array_length(quest.objectives), 0);
    quest.start_time = 0;
    quest.end_time = 0;
    
    // Удаляем из активных квестов
    aty_remove_quest_from_active(_quest_id);
    
    aty_show_notification("❌ Квест отменен: " + quest.name);
    return true;
}

// Обновляем функцию шага игры для обработки квестов
// Расширенная система обновления прогресса
function aty_update_quest_progress_enhanced() {
    var all_quests = array_merge(
        global.aty.quests.active_quests,
        global.aty.quests.daily_quests,
        global.aty.quests.weekly_quests
    );
    
    for (var i = 0; i < array_length(all_quests); i++) {
        var quest = all_quests[i];
        
        if (quest.state == QUEST_STATE.IN_PROGRESS) {
            var all_objectives_complete = true;
            
            for (var j = 0; j < array_length(quest.objectives); j++) {
                var objective = quest.objectives[j];
                var new_progress = aty_calculate_objective_progress(objective, quest.current_progress[j]);
                
                quest.current_progress[j] = new_progress;
                
                if (new_progress < objective.target) {
                    all_objectives_complete = false;
                }
            }
            
            // Проверяем завершение квеста
            if (all_objectives_complete) {
                quest.state = QUEST_STATE.COMPLETED;
                aty_on_quest_completed(quest);
            }
            
            // Проверяем временные ограничения
            aty_check_quest_time_limit(quest);
        }
    }
}
// Система событий для квестов
function aty_on_quest_completed(_quest) {
    // Показываем уведомление
    aty_show_quest_notification("🎉 Квест завершен!", _quest.name, _quest.rewards);
    
    // Добавляем опыт и золото
    global.aty.hero.gold += _quest.rewards.gold;
    global.aty.hero.exp += _quest.rewards.exp;
    
    // Выдаем предметы
    for (var i = 0; i < array_length(_quest.rewards.items); i++) {
        aty_add_item_to_inventory(_quest.rewards.items[i]);
    }
    
    // Применяем баффы
    for (var i = 0; i < array_length(_quest.rewards.buffs); i++) {
        aty_apply_quest_buff(_quest.rewards.buffs[i]);
    }
    
    // Обновляем статистику
    global.aty.quests.quest_stats.total_completed++;
    
    // Проверяем достижения
    aty_check_quest_achievements();
    
    // Воспроизводим звук
    audio_play_sound(snd_quest_complete, 1, false);
}

function aty_show_quest_notification(_title, _subtitle, _rewards) {
    // Создаем структуру уведомления
    var notification = {
        title: _title,
        subtitle: _subtitle,
        rewards: _rewards,
        start_time: current_time,
        duration: 5 // секунд
    };
    
    // Добавляем в очередь уведомлений
    if (!variable_struct_exists(global.aty, "quest_notifications")) {
        global.aty.quest_notifications = [];
    }
    array_push(global.aty.quest_notifications, notification);
}
// Цепочки квестов
function aty_start_quest_chain(_chain_id) {
    var chain = aty_get_quest_chain(_chain_id);
    if (!is_struct(chain)) return false;
    
    // Запускаем первый квест в цепочке
    var first_quest = chain.quests[0];
    return aty_start_quest(first_quest.id);
}

// Сезонные квесты
function aty_generate_seasonal_quests(_season) {
    var seasonal_templates = aty_get_seasonal_quest_templates(_season);
    var seasonal_quests = [];
    
    for (var i = 0; i < array_length(seasonal_templates); i++) {
        var quest = aty_generate_quest_from_template(seasonal_templates[i], global.aty.hero.level);
        array_push(seasonal_quests, quest);
    }
    
    global.aty.quests.seasonal_quests = seasonal_quests;
}
// Рекомендации квестов
function aty_get_recommended_quests() {
    var available = aty_get_available_quests();
    var recommended = [];
    
    for (var i = 0; i < array_length(available); i++) {
        var quest = available[i];
        var sscore = aty_calculate_quest_recommendation_score(quest);
        
        if (sscore > 0.7) { // Порог для рекомендации
            array_push(recommended, quest);
        }
    }
    
    return recommended;
}

function aty_calculate_quest_recommendation_score(_quest) {
    var sscore = 0;
    var player_level = global.aty.hero.level;
    
    // Бонус за соответствие уровню
    if (_quest.required_level <= player_level && _quest.required_level >= player_level - 2) {
        sscore += 0.3;
    }
    
    // Бонус за тип квеста, который игрок часто выполняет
    if (aty_is_quest_type_preferred(_quest.type)) {
        sscore += 0.2;
    }
    
    // Бонус за хорошее соотношение награды/сложности
    var reward_ratio = (_quest.rewards.gold + _quest.rewards.exp) / _quest.difficulty;
    sscore += min(0.3, reward_ratio / 100);
    
    // Бонус за редкие квесты
    if (_quest.rarity == QUEST_RARITY.EPIC || _quest.rarity == QUEST_RARITY.LEGENDARY) {
        sscore += 0.2;
    }
    
    return min(1.0, sscore);
}
function aty_update_quest_buffs(_dt) {
    if (!variable_struct_exists(global.aty, "quest_buffs")) return;
    
    for (var i = array_length(global.aty.quest_buffs) - 1; i >= 0; i--) {
        var buff = global.aty.quest_buffs[i];
        
        if (variable_struct_exists(buff, "duration")) {
            buff.duration -= _dt;
            
            if (buff.duration <= 0) {
                array_delete(global.aty.quest_buffs, i, 1);
                aty_show_notification("Бафф '" + buff.name + "' закончился");
            }
        }
    }
}