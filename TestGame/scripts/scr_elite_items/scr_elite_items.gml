// scr_elite_items.gml
// Элитные и дорогие предметы для расширенной базы

function init_elite_items() {
    // Проверяем, что необходимые глобальные переменные инициализированы
    if (!variable_global_exists("EQUIP_SLOT") || !variable_global_exists("ITEM_TYPE")) {
        show_debug_message("Ошибка: EQUIP_SLOT или ITEM_TYPE не инициализированы перед вызовом init_elite_items()");
        return;
    }
    
    // ==================== ЛЕГЕНДАРНОЕ ОРУЖИЕ (500K - 5M) ====================
    
    AddItemToDB("blade_of_ruin", "Клинок Разрушения", global.ITEM_TYPE.WEAPON, 500000, "Меч, способный разрушать реальность.", 50, 0, 0, global.EQUIP_SLOT.WEAPON, 4, false, 1, 0, 0, 0);
    AddItemToDB("staff_of_infinity", "Посох Бесконечности", global.ITEM_TYPE.WEAPON, 750000, "Вмещает безграничную магическую силу.", 0, 60, 0, global.EQUIP_SLOT.WEAPON, 4, false, 1, 0, 0, 0);
    AddItemToDB("cosmic_bow", "Космический Лук", global.ITEM_TYPE.WEAPON, 600000, "Стрелы из чистой энергии.", 30, 30, 0, global.EQUIP_SLOT.WEAPON, 4, false, 1, 0, 25, 0);
    
    // ==================== БОЖЕСТВЕННЫЕ АРТЕФАКТЫ (1M - 10M) ====================
    
    AddItemToDB("armor_of_gods", "Доспех Богов", global.ITEM_TYPE.ARMOR, 2500000, "Созданный в кузницах Олимпа.", 0, 0, 100, global.EQUIP_SLOT.ARMOR, 5, false, 1, 0, 0, 200);
    AddItemToDB("helmet_of_omniscience", "Шлем Всеведения", global.ITEM_TYPE.ARMOR, 1500000, "Дарует знание всех вещей.", 0, 40, 30, global.EQUIP_SLOT.ARMOR, 5, false, 1, 50, 0, 100);
    AddItemToDB("boots_of_time", "Сапоги Времени", global.ITEM_TYPE.ARMOR, 1800000, "Позволяют перемещаться во времени.", 0, 0, 20, global.EQUIP_SLOT.ARMOR, 5, false, 1, 0, 50, 0);
    
    // ==================== МИФИЧЕСКИЕ РЕЛИКВИИ (10M - 50M) ====================
    
    AddItemToDB("phoenix_heart", "Сердце Феникса", global.ITEM_TYPE.RELIC, 10000000, "Воскрешает владельца при смерти.", 25, 25, 25, global.EQUIP_SLOT.RELIC, 6, false, 1, 100, 0, 300);
    AddItemToDB("dragon_king_scale", "Чешуя Короля Драконов", global.ITEM_TYPE.RELIC, 15000000, "Чешуя самого первого дракона.", 40, 40, 40, global.EQUIP_SLOT.RELIC, 6, false, 1, 0, 0, 500);
    AddItemToDB("titan_essence", "Эссенция Титана", global.ITEM_TYPE.RELIC, 12000000, "Сила древних титанов.", 50, 20, 30, global.EQUIP_SLOT.RELIC, 6, false, 1, 0, 0, 400);
    
    // ==================== КОСМИЧЕСКИЕ АРТЕФАКТЫ (50M - 100M) ====================
    
    AddItemToDB("black_hole_core", "Ядро Черной Дыры", global.ITEM_TYPE.RELIC, 50000000, "Содержит силу гравитационной сингулярности.", 75, 75, 75, global.EQUIP_SLOT.RELIC, 7, false, 1, 200, 0, 800);
    AddItemToDB("nebula_cloak", "Плащ Туманности", global.ITEM_TYPE.ARMOR, 45000000, "Создан из материи межзвездных туманностей.", 30, 60, 80, global.EQUIP_SLOT.ARMOR, 7, false, 1, 150, 40, 600);
    AddItemToDB("quantum_blade", "Квантовый Клинок", global.ITEM_TYPE.WEAPON, 60000000, "Существует во всех измерениях одновременно.", 90, 90, 0, global.EQUIP_SLOT.WEAPON, 7, false, 1, 0, 60, 0);
    
    // ==================== БОЖЕСТВЕННЫЕ РЕЛИКВИИ (100M - 500M) ====================
    
    AddItemToDB("creation_hammer", "Молот Творения", global.ITEM_TYPE.WEAPON, 250000000, "Им был создан этот мир.", 120, 120, 120, global.EQUIP_SLOT.WEAPON, 8, false, 1, 300, 0, 1000);
    AddItemToDB("infinity_gauntlet", "Перчатка Бесконечности", global.ITEM_TYPE.ACCESSORY, 350000000, "Дарует абсолютную власть над реальностью.", 100, 100, 100, global.EQUIP_SLOT.ACCESSORY, 8, false, 1, 500, 100, 1500);
    AddItemToDB("multiverse_map", "Карта Мультивселенной", global.ITEM_TYPE.RELIC, 280000000, "Позволяет путешествовать между мирами.", 80, 150, 80, global.EQUIP_SLOT.RELIC, 8, false, 1, 400, 80, 1200);
    
    // ==================== АБСОЛЮТНЫЕ АРТЕФАКТЫ (500M - 1B+) ====================
    
    AddItemToDB("omnipotence_crown", "Корона Всесилия", global.ITEM_TYPE.ACCESSORY, 750000000, "Делает владельца богом.", 200, 200, 200, global.EQUIP_SLOT.ACCESSORY, 9, false, 1, 1000, 200, 3000);
    AddItemToDB("reality_stone", "Камень Реальности", global.ITEM_TYPE.RELIC, 900000000, "Позволяет изменять реальность по желанию.", 150, 250, 150, global.EQUIP_SLOT.RELIC, 9, false, 1, 800, 150, 2500);
    AddItemToDB("concept_of_victory", "Концепция Победы", global.ITEM_TYPE.RELIC, 1000000000, "Абстрактная концепция, воплощенная в предмете.", 300, 300, 300, global.EQUIP_SLOT.RELIC, 10, false, 1, 1500, 300, 5000);
    
    // ==================== ЭКСКЛЮЗИВНЫЕ ЗЕЛЬЯ И СВИТКИ ====================
    
    AddItemToDB("potion_of_omnipotence", "Зелье Всесилия", global.ITEM_TYPE.POTION, 50000000, "Дарует божественные способности на 1 час.", 0, 0, 0, -1, 7, true, 1);
    AddItemToDB("scroll_of_universe", "Свиток Вселенной", global.ITEM_TYPE.SCROLL, 100000000, "Создает новую вселенную.", 0, 0, 0, -1, 8, true, 1);
    AddItemToDB("elixir_of_eternity", "Эликсир Вечности", global.ITEM_TYPE.POTION, 200000000, "Дарует бессмертие.", 0, 0, 0, -1, 9, true, 1);
    
    // Добавляем свойства для новых зелий
    AddEliteItemProperties();
    update_elite_item_descriptions();
    show_debug_message("Элитные предметы успешно инициализированы");
}

function AddEliteItemProperties() {
    // Свойства для элитных зелий
    SetItemProperty("potion_of_omnipotence", "temp_strength", 100);
    SetItemProperty("potion_of_omnipotence", "temp_intelligence", 100);
    SetItemProperty("potion_of_omnipotence", "temp_defense", 100);
    SetItemProperty("potion_of_omnipotence", "health", 1000);
    
    SetItemProperty("scroll_of_universe", "reward_multiplier", 10.0);
    SetItemProperty("scroll_of_universe", "instant_complete", true);
    
    SetItemProperty("elixir_of_eternity", "health", 9999);
    SetItemProperty("elixir_of_eternity", "perm_strength", 50);
    SetItemProperty("elixir_of_eternity", "perm_intelligence", 50);
}


function draw_expedition_confirmation() {
    if (!global.expedition_confirmation_required) return;
    
    var diff = global.expedition_difficulties[global.pending_expedition_difficulty];
    var boss_name = global.companions[diff.boss].name;
    
    // Полупрозрачный фон
    draw_set_color(make_color_rgb(0, 0, 0));
    draw_set_alpha(0.7);
    draw_rectangle(0, 0, global.screen_width, global.screen_height, false);
    draw_set_alpha(1);
    
    // Окно подтверждения
    var window_width = 500;
    var window_height = 250;
    var window_x = (global.screen_width - window_width) / 2;
    var window_y = (global.screen_height - window_height) / 2;
    
    // Фон окна
    draw_set_color(ui_bg_dark);
    draw_rectangle(window_x, window_y, window_x + window_width, window_y + window_height, false);
    draw_set_color(ui_danger);
    draw_rectangle(window_x, window_y, window_x + window_width, window_y + 5, false);
    draw_set_color(ui_border_color);
    draw_rectangle(window_x, window_y, window_x + window_width, window_y + window_height, true);
    
    // Текст предупреждения
    draw_set_color(ui_danger);
    draw_set_halign(fa_center);
    draw_set_font(fnt_main);
    draw_text(window_x + window_width/2, window_y + 30, "⚠️ ОПАСНОСТЬ! ⚠️");
    
    draw_set_color(ui_text);
    draw_text(window_x + window_width/2, window_y + 70, "Эта экспедиция содержит босса:");
    draw_set_color(ui_highlight);
    draw_text(window_x + window_width/2, window_y + 100, boss_name);
    
    draw_set_color(ui_text_secondary);
    draw_set_font(fnt_small);
    draw_text(window_x + window_width/2, window_y + 130, "Сложность: " + diff.name);
    draw_text(window_x + window_width/2, window_y + 150, "Шанс успеха: " + string(round(calculate_success_chance(global.pending_expedition_difficulty))) + "%");
    
    draw_set_font(fnt_main);
    draw_set_color(ui_text);
    draw_text(window_x + window_width/2, window_y + 180, "Вы уверены, что готовы?");
    
    // Кнопки подтверждения
    var btn_width = 120;
    var btn_height = 35;
    var btn_y = window_y + window_height - 50;
    var btn_spacing = 40;
    
    // Кнопка "Да"
    var yes_btn_x = window_x + (window_width/2) - btn_width - btn_spacing/2;
    var no_btn_x = window_x + (window_width/2) + btn_spacing/2;
    
    // Проверка наведения
    var yes_hover = point_in_rectangle(mouse_x, mouse_y, yes_btn_x, btn_y, yes_btn_x + btn_width, btn_y + btn_height);
    var no_hover = point_in_rectangle(mouse_x, mouse_y, no_btn_x, btn_y, no_btn_x + btn_width, btn_y + btn_height);
    
    // Отрисовка кнопки "Да"
    draw_set_color(yes_hover ? merge_color(ui_danger, c_white, 0.2) : ui_danger);
    draw_rectangle(yes_btn_x, btn_y, yes_btn_x + btn_width, btn_y + btn_height, false);
    draw_set_color(ui_border_color);
    draw_rectangle(yes_btn_x, btn_y, yes_btn_x + btn_width, btn_y + btn_height, true);
    draw_set_color(ui_text);
    draw_set_halign(fa_center);
    draw_text(yes_btn_x + btn_width/2, btn_y + btn_height/2, "ДА, Я ГОТОВ!");
    
    // Отрисовка кнопки "Нет"
    draw_set_color(no_hover ? merge_color(ui_bg_light, c_white, 0.2) : ui_bg_light);
    draw_rectangle(no_btn_x, btn_y, no_btn_x + btn_width, btn_y + btn_height, false);
    draw_set_color(ui_border_color);
    draw_rectangle(no_btn_x, btn_y, no_btn_x + btn_width, btn_y + btn_height, true);
    draw_set_color(ui_text);
    draw_text(no_btn_x + btn_width/2, btn_y + btn_height/2, "НЕТ, Я ТРУС");
    
    draw_set_halign(fa_left);
    
    // Сохраняем кнопки для обработки кликов
    global.expedition_confirmation_buttons = [
        { type: "confirm_yes", x1: yes_btn_x, y1: btn_y, x2: yes_btn_x + btn_width, y2: btn_y + btn_height },
        { type: "confirm_no", x1: no_btn_x, y1: btn_y, x2: no_btn_x + btn_width, y2: btn_y + btn_height }
    ];
}


// Обновляем функцию AddItemToDB для поддержки новых свойств
function AddItemToDBExtended(_id, _name, _type, _price, _desc, _str_bonus, _int_bonus, _def_bonus, _equip_slot, _rarity, _stackable = false, _maxStack = 1, _gold_bonus = 0, _agi_bonus = 0, _health_bonus = 0, _perm_str = 0, _perm_int = 0, _perm_agi = 0) {
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
    ds_map_add(item, "gold_bonus", _gold_bonus);
    ds_map_add(item, "agility_bonus", _agi_bonus);
    ds_map_add(item, "health_bonus", _health_bonus);
    ds_map_add(item, "perm_strength", _perm_str);
    ds_map_add(item, "perm_intelligence", _perm_int);
    ds_map_add(item, "perm_agility", _perm_agi);
    
    ds_map_add(global.ItemDB, _id, item);
}
// scr_rarity_system.gml
// Расширенная система редкости для поддержки новых уровней

function get_rarity_color(rarity) {
    switch(rarity) {
        case 0: return make_color_rgb(200, 200, 200);    // Обычный - серый
        case 1: return make_color_rgb(30, 255, 0);       // Необычный - зеленый
        case 2: return make_color_rgb(0, 112, 221);      // Редкий - синий
        case 3: return make_color_rgb(163, 53, 238);     // Эпический - фиолетовый
        case 4: return make_color_rgb(255, 128, 0);      // Легендарный - оранжевый
        case 5: return make_color_rgb(255, 50, 50);      // Мифический - красный
        case 6: return make_color_rgb(255, 215, 0);      // Божественный - золотой
        case 7: return get_rainbow_color();              // Космический - радужный
        case 8: return make_color_rgb(0, 255, 255);      // Божественный+ - голубой
        case 9: return make_color_rgb(255, 0, 255);      // Абсолютный - пурпурный
        case 10: return get_animated_divine_color();     // Концептуальный - анимированный
        default: return make_color_rgb(255, 255, 255);   // По умолчанию - белый
    }
}
