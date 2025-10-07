function game_initialize() {
    if (!variable_global_exists("game_initialized")) {
        global.game_initialized = false;
    }
    
    if (global.game_initialized) {
        return;
    }
    
    // Базовые настройки
    global.gold = 1000;
    global.screen_width = 1000;
    global.screen_height = 800;
    
    // Разделение экрана
    global.top_height = floor(global.screen_height * 0.25);
    global.middle_height = floor(global.screen_height * 0.35);
    global.bottom_height = global.screen_height - global.top_height - global.middle_height;
    
    global.squad_width = floor(global.screen_width * 0.25);
    global.tabs_width = global.screen_width - global.squad_width;

    // Позиции областей
    global.top_y = 0;
    global.middle_y = global.top_height;
    global.bottom_y = global.top_height + global.middle_height;

    // СНАЧАЛА инициализируем основные системы
    init_persistent_data();
    
    // Инициализация базы данных предметов (ДОЛЖНА БЫТЬ ПЕРВОЙ!)
    scr_init_item_database();
    
    // Инициализация системы элитных предметов (ПОСЛЕ базы данных!)
    init_elite_items();
    
    // Инициализация героя ДО систем, которые от него зависят
    init_main_hero();
 
    // Инициализация систем артефактов
    global.expedition_auto_repeat = {
        enabled: false,
        difficulties: [false, false, false, false, false],
        completed_count: 0
    };

    global.expedition_instant_complete_chance = 0;
    global.expedition_reward_multiplier = 1.0;
    global.simultaneous_expeditions = false;
    
    init_inventory_system();
    init_level_system();
    
    // Инициализация уведомлений
    if (!variable_global_exists("notifications")) {
        global.notifications = [];
    }
    
    // Инициализация эффектов покупки
    if (!variable_global_exists("purchase_effects")) {
        global.purchase_effects = ds_list_create();
    }
    
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
    
    // ИНИЦИАЛИЗАЦИЯ ФЛАГОВ ПОДТВЕРЖДЕНИЯ ЭКСПЕДИЦИИ
    if (!variable_global_exists("expedition_confirmation_required")) {
        global.expedition_confirmation_required = false;
    }
    
    if (!variable_global_exists("pending_expedition_difficulty")) {
        global.pending_expedition_difficulty = -1;
    }
    
    // Инициализация магазина
    if (!variable_global_exists("shop_items")) {
        global.shop_items = [];
        // Заполняем магазин базовыми предметами
        var map = ds_map_create();
        var count = ds_map_size(global.ItemDB);
        var key = ds_map_find_first(global.ItemDB);
        
        for (var i = 0; i < count; i++) {
            var item = ds_map_find_value(global.ItemDB, key);
            var rarity = item[? "rarity"];
            if (rarity <= 2) {
                array_push(global.shop_items, key);
            }
            key = ds_map_find_next(global.ItemDB, key);
        }
        ds_map_destroy(map);
    }
    
    // Пагинация магазина
    global.shop_current_page = 0;
    global.shop_items_per_page = 3;
    global.shop_total_pages = ceil(array_length(global.shop_items) / global.shop_items_per_page);
    if (global.shop_total_pages == 0) global.shop_total_pages = 1;
    
    // ТЕПЕРЬ инициализируем систему способностей (ПОСЛЕ создания героя)
    init_abilities_system();
    
    global.game_initialized = true;
    show_debug_message("Базовая инициализация игры завершена");
}
// scr_game_initialize.gml - добавьте эту функцию если её нет
function init_main_hero() {
    global.hero = {
        level: 1,
        max_level: 100,
        exp: 0,
        exp_to_level: 100,
        skill_points: 0,
        strength: 5,
        agility: 5,
        intelligence: 5,
        health: 100,
        max_health: 100,
        mana: 100,
        max_mana: 100,
        mana_regen: 1.0,
        is_injured: false,
        rest_timer: 0,
        next_attack_double: false,
        phoenix_rebirth_available: false,
        equipment_bonuses: {
            strength: 0,
            agility: 0,
            intelligence: 0,
            defense: 0,
            max_health: 0,
            gold_bonus: 0,
            health_bonus: 0,
            perm_strength: 0,
            perm_intelligence: 0,
            perm_agility: 0
        },
        ability_bonuses: {
            strength: 0,
            defense: 0
        }
    };
    show_debug_message("Главный герой инициализирован");
}
function init_companions() {
    // Инициализируем массив, если не существует
    if (!variable_global_exists("companions")) {
        global.companions = [];
    }
    
    // Очищаем массив перед заполнением
    global.companions = [];
    
    // 3 основные героя-помощницы
    var companion_templates = [
        {
            id: 0,
            name: "Hepo",
            unlocked: false,
            level: 25,
            exp: 0,
            exp_to_level: 5,
            health: 80,
            max_health: 80,
            effect: "+10% к шансу успеха (зависит от Силы)",
            calculated_bonus: 10,
            training: false,
            training_progress: 0,
            training_rate: 1.0,
            rank: 0,
            max_rank: 3,
            rank_requirements: [5, 15, 25],
            rank_effects: [
                "Базовая способность: +10% к шансу успеха",
                "Улучшенная тактика: +15% к шансу успеха", 
                "Мастер экспедиций: +20% к шансу успеха и +5% к награде",
                "Легендарный стратег: +25% к шансу успеха и +10% к награде" // ДОБАВЛЕН РАНГ 3
            ],
            equipment: { weapon: -1, armor: -1 }
        },
        {
            id: 1,
            name: "Fatty", 
            unlocked: false,
            level: 25,
            exp: 0,
            exp_to_level: 5,
            health: 120,
            max_health: 120,
            effect: "+15% к здоровью (зависит от Ловкости)",
            calculated_bonus: 15,
            training: false,
            training_progress: 0,
            training_rate: 0.8,
            rank: 0,
            max_rank: 3,
            rank_requirements: [5, 15, 25],
            rank_effects: [
                "Базовая способность: +15% к здоровью отряда",
                "Укрепление: +20% к здоровью отряда",
                "Несокрушимость: +25% к здоровью отряда и снижение получаемого урона на 10%",
                "Непробиваемый: +30% к здоровью отряда и снижение получаемого урона на 15%" // ДОБАВЛЕН РАНГ 3
            ],
            equipment: { weapon: -1, armor: -1 }
        },
        {
            id: 2,
            name: "Discipline",
            unlocked: false,
            level: 25,
            exp: 0,
            exp_to_level: 5,
            health: 90,
            max_health: 90,
            effect: "+12% к золоту (зависит от Интеллекта)", 
            calculated_bonus: 12,
            training: false,
            training_progress: 0,
            training_rate: 1.2,
            rank: 0,
            max_rank: 3,
            rank_requirements: [5, 15, 25],
            rank_effects: [
                "Базовая способность: +12% к получаемому золоту",
                "Экономист: +18% к получаемому золоту",
                "Финансовый гений: +25% к получаемому золоту и шанс удвоить награду",
                "Король торговли: +30% к получаемому золоту и шанс утроить награду" // ДОБАВЛЕН РАНГ 3
            ],
            equipment: { weapon: -1, accessory: -1 }
        }
    ];
    
    // Добавляем помощниц в массив
    for (var i = 0; i < array_length(companion_templates); i++) {
        array_push(global.companions, companion_templates[i]);
    }
    
    show_debug_message("Помощницы инициализированы: " + string(array_length(global.companions)));
}

function init_arenas() {
    // Инициализируем массив, если не существует
    if (!variable_global_exists("arenas")) {
        global.arenas = [];
    }
       // ДОБАВЬТЕ ЭТУ СТРОКУ СРАЗУ ПОСЛЕ СОЗДАНИЯ МАССИВА
    global.arena_count = array_length(global.arenas);
    // Очищаем массив перед заполнением
    global.arenas = [];
    
    var arena_templates = [
        {
            name: "Арена Хепo",
            unlocked: false,
            level: 1,
            training_speed: 1.0,
            active: false
        },
        {
            name: "Арена Фэтти",
            unlocked: false, 
            level: 1,
            training_speed: 1.0,
            active: false
        },
        {
            name: "Арена Дисциплины",
            unlocked: false,
            level: 1,
            training_speed: 1.0,
            active: false
        }
    ];
    
    // Добавляем арены в массив
    for (var i = 0; i < array_length(arena_templates); i++) {
        array_push(global.arenas, arena_templates[i]);
    }
    
    show_debug_message("Арены инициализированы: " + string(array_length(global.arenas)));
}
function draw_hepo_buffs_section(panel_y, panel_height) {
    var section_width = global.squad_width;
    
    draw_set_color(ui_bg_dark);
    draw_rectangle(0, panel_y, section_width, panel_y + panel_height, false);
    
    draw_set_color(ui_text);
    draw_set_halign(fa_center);
    draw_text(section_width/2, panel_y + 15, "✨ БАФЫ HEPO");
    draw_set_halign(fa_left);
    
    // Список бафов, которые может накладывать Hepo
    var hepo_buffs = [
        {
            name: "⚔️ Благословение Силы",
            description: "Увеличивает силу героя перед экспедицией",
            effect: "+5 к силе",
            color: make_color_rgb(255, 100, 100)
        },
        {
            name: "🛡️ Магический Щит", 
            description: "Увеличивает защиту отряда",
            effect: "+8 к защите",
            color: make_color_rgb(100, 150, 255)
        },
        {
            name: "📚 Мудрость Древних",
            description: "Увеличивает интеллект героя",
            effect: "+6 к интеллекту", 
            color: make_color_rgb(150, 100, 255)
        },
        {
            name: "❤️ Жизненная Энергия",
            description: "Увеличивает максимальное здоровье",
            effect: "+25 к здоровью",
            color: make_color_rgb(255, 50, 50)
        },
        {
            name: "🎯 Безошибочная Тактика",
            description: "Увеличивает шанс успеха экспедиции",
            effect: "+15% к успеху",
            color: make_color_rgb(255, 255, 100)
        },
        {
            name: "💰 Золотой Блеск",
            description: "Увеличивает получаемое золото",
            effect: "+20% к золоту",
            color: make_color_rgb(255, 215, 0)
        }
    ];
    
    var buff_height = 80;
    var start_y = panel_y + 40;
    var buff_width = section_width - 20;
    
    for (var i = 0; i < array_length(hepo_buffs); i++) {
        var buff_y = start_y + i * (buff_height + 10);
        
        // Проверяем, чтобы не выйти за границы
        if (buff_y + buff_height > panel_y + panel_height) break;
        
        var buff = hepo_buffs[i];
        var is_hovered = point_in_rectangle(mouse_x, mouse_y, 10, buff_y, 10 + buff_width, buff_y + buff_height);
        
        // Фон бафа
        draw_set_color(is_hovered ? merge_color(ui_bg_medium, c_white, 0.1) : ui_bg_medium);
        draw_rectangle(10, buff_y, 10 + buff_width, buff_y + buff_height, false);
        
        // Цветная полоса
        draw_set_color(buff.color);
        draw_rectangle(10, buff_y, 10 + 5, buff_y + buff_height, false);
        
        // Название бафа
        draw_set_color(ui_text);
        draw_text(20, buff_y + 8, buff.name);
        
        // Описание
        draw_set_color(ui_text_secondary);
        draw_set_font(fnt_small);
        
        // Обрезаем описание если слишком длинное
        var desc = buff.description;
        if (string_length(desc) > 35) {
            desc = string_copy(desc, 1, 32) + "...";
        }
        draw_text(20, buff_y + 30, desc);
        
        // Эффект
        draw_set_color(ui_highlight);
        draw_text(20, buff_y + 55, buff.effect);
        
        draw_set_font(fnt_main);
        
        // Рамка
        draw_set_color(is_hovered ? merge_color(ui_border_color, c_white, 0.2) : ui_border_color);
        draw_rectangle(10, buff_y, 10 + buff_width, buff_y + buff_height, true);
    }
    
    // Информация о системе бафов
    var info_y = panel_y + panel_height - 60;
    draw_set_color(ui_text_secondary);
    draw_set_halign(fa_center);
    draw_set_font(fnt_small);
    draw_text(section_width + 15/2, info_y + 60, "Hepo автоматически накладывает");
    draw_text(section_width + 15/2, info_y + 75, "3 случайных бафа перед экспедицией");
    draw_text(section_width + 15/2, info_y + 90, "в зависимости от её ранга");
    draw_set_halign(fa_left);
    draw_set_font(fnt_main);
}
function draw_shop_item_card(x, y, width, height, item_data, index, is_hovered) {
    var rarity = item_data[? "rarity"];
    var rarity_color = get_rarity_color(rarity);
    var price = item_data[? "price"];
    var formatted_price = format_large_number(price);
    
    // Фон карточки
    var card_bg = is_hovered ? merge_color(ui_bg_light, c_white, 0.1) : ui_bg_light;
    draw_set_color(card_bg);
    draw_rectangle(x, y, x + width, y + height, false);
    
    // Полоса редкости
    draw_set_color(rarity_color);
    draw_rectangle(x, y, x + width, y + 4, false);
    
    // Название предмета
    draw_set_color(ui_text);
    var name = item_data[? "name"];
    if (string_length(name) > 15) {
        name = string_copy(name, 1, 14) + "...";
    }
    draw_text(x + 10, y + 10, name);
    
    // Цена
    draw_set_color(ui_text);
    draw_set_halign(fa_right);
    draw_text(x + width - 10, y + 10, formatted_price + "g");
    draw_set_halign(fa_left);
    
    // Редкость
    var rarity_name = get_rarity_name(rarity);
    draw_set_color(rarity_color);
    draw_text(x + 10, y + 30, rarity_name);
    
    // Описание
    var desc_y = y + 50;
    draw_set_color(ui_text_secondary);
    draw_set_font(fnt_small);
    
    var desc = item_data[? "description"];
    if (string_length(desc) > 40) {
        desc = string_copy(desc, 1, 37) + "...";
    }
    draw_text(x + 10, desc_y, desc);
    draw_set_font(fnt_main);
    
    // Бонусы
    var bonuses_y = desc_y + 40;
    draw_item_bonuses_compact(x + 10, bonuses_y, width - 20, item_data, is_hovered);
    
    // Кнопка покупки
    var btn_y = y + height - 35;
    var can_afford = global.gold >= price;
    var btn_color = can_afford ? ui_success_color : ui_danger;
    
    draw_set_color(btn_color);
    draw_rectangle(x + 10, btn_y, x + width - 10, y + height - 10, false);
    
    draw_set_color(ui_text);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    
    var btn_text = can_afford ? "🛒 КУПИТЬ" : "🔒 НЕТ ЗОЛОТА";
    draw_text(x + width/2, btn_y + 12, btn_text);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    
    // Рамка
    draw_set_color(is_hovered ? merge_color(ui_border_color, c_white, 0.2) : ui_border_color);
    draw_rectangle(x, y, x + width, y + height, true);
    
    // Сохраняем информацию о предмете для обработки кликов
    array_push(global.shop_buttons, {
        type: "shop_item",
        item_id: item_data[? "id"],
        index: index,
        x1: x, y1: y,
        x2: x + width, y2: y + height
    });
}
function draw_category_pagination(x, y, width, height) {
    var pagination_y = y + height - 40;
    var button_width = 120;
    var button_height = 30;
    var spacing = 20;
    
    var page_info = get_current_category_page_info();
    var current_page = global.shop_category_current_page[global.shop_current_category];
    var total_pages = global.shop_category_pages[global.shop_current_category];
    
    // Центрируем пагинацию
    var total_width = button_width * 2 + spacing + 100;
    var start_x = x + (width - total_width) / 2;
    
    // Кнопка "Назад"
    var prev_x = start_x;
    var can_go_prev = current_page > 0;
    var prev_hovered = can_go_prev && point_in_rectangle(mouse_x, mouse_y, prev_x, pagination_y + 50, prev_x + button_width, pagination_y + 50 + button_height);
    
    draw_modern_button(prev_x, pagination_y + 50, button_width, button_height, "◀️ Предыдущая", false, prev_hovered);
    
    // Информация о странице
    var page_x = prev_x + button_width + spacing;
    var page_width = 100;
    
    draw_set_color(ui_bg_light);
    draw_rectangle(page_x, pagination_y + 50, page_x + page_width, pagination_y + 50 + button_height, false);
    draw_set_color(ui_border_color);
    draw_rectangle(page_x, pagination_y + 50, page_x + page_width, pagination_y + 50 + button_height, true);
    
    draw_set_color(ui_text);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(page_x + page_width/2, pagination_y + 50 + button_height/2, string(page_info.current_page) + "/" + string(page_info.total_pages));
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    
    // Кнопка "Вперед"
    var next_x = page_x + page_width + spacing;
    var can_go_next = current_page < total_pages - 1;
    var next_hovered = can_go_next && point_in_rectangle(mouse_x, mouse_y, next_x, pagination_y + 50, next_x + button_width, pagination_y + 50 + button_height);
    
    draw_modern_button(next_x, pagination_y + 50, button_width, button_height, "Следующая ▶️", false, next_hovered);
    
    // Добавляем кнопки для обработки кликов
    if (can_go_prev) {
        array_push(global.shop_page_buttons, {
            type: "category_prev_page",
            x1: prev_x, y1: pagination_y + 50,
            x2: prev_x + button_width, y2: pagination_y + 50 + button_height
        });
    }
    
    if (can_go_next) {
        array_push(global.shop_page_buttons, {
            type: "category_next_page", 
            x1: next_x, y1: pagination_y + 50,
            x2: next_x + button_width, y2: pagination_y + 50 + button_height
        });
    }
}

function draw_item_type_icon(x, y, item_type, is_hovered) {
    var icon_color = is_hovered ? merge_color(ui_highlight, c_white, 0.3) : ui_highlight;
    var icon_size = 16;
    
    draw_set_color(icon_color);
    
    switch(item_type) {
        case global.ITEM_TYPE.WEAPON:
            // Меч
            draw_rectangle(x + icon_size/2 - 1, y, x + icon_size/2 + 1, y + icon_size, false);
            draw_rectangle(x + 2, y + icon_size - 4, x + icon_size - 2, y + icon_size - 2, false);
            break;
            
        case global.ITEM_TYPE.ARMOR:
            // Щит
            draw_rectangle(x + 2, y + 4, x + icon_size - 2, y + icon_size - 2, false);
            draw_rectangle(x + icon_size/2 - 1, y + 2, x + icon_size/2 + 1, y + icon_size - 4, false);
            break;
            
        case global.ITEM_TYPE.POTION:
            // Зелье
            draw_rectangle(x + 4, y + 8, x + icon_size - 4, y + icon_size, false);
            draw_rectangle(x + 6, y + 2, x + icon_size - 6, y + 8, false);
            break;
            
        case global.ITEM_TYPE.ACCESSORY:
            // Кольцо
            draw_rectangle(x + 6, y + 6, x + icon_size - 6, y + icon_size - 6, false);
            draw_rectangle(x + 4, y + icon_size/2 - 1, x + icon_size - 4, y + icon_size/2 + 1, false);
            break;
            
        case global.ITEM_TYPE.SCROLL:
            // Свиток
            draw_rectangle(x + 6, y + 8, x + icon_size - 6, y + icon_size - 8, false);
            // Линии текста на свитке
            draw_set_color(c_white);
            for (var i = 0; i < 3; i++) {
                draw_rectangle(x + 8, y + 12 + i * 5, x + icon_size - 8, y + 13 + i * 5, false);
            }
            break;
            
        case global.ITEM_TYPE.RELIC:
            // Реликвия
            draw_set_color(make_color_rgb(255, 215, 0));
            draw_circle(x + icon_size/2, y + icon_size/2, icon_size/3, false);
            break;
            
        default:
            draw_rectangle(x + 2, y + 2, x + icon_size - 2, y + icon_size - 2, false);
            break;
    }
}
function draw_item_type_icon_simple(x, y, item_type, is_hovered) {
    var icon_size = 16;
    var icon_color = is_hovered ? merge_color(ui_highlight, c_white, 0.3) : ui_highlight;
    
    draw_set_color(icon_color);
    
    switch(item_type) {
        case global.ITEM_TYPE.WEAPON:
            // Меч
            draw_rectangle(x + icon_size/2 - 1, y, x + icon_size/2 + 1, y + icon_size, false);
            draw_rectangle(x + 2, y + icon_size - 4, x + icon_size - 2, y + icon_size - 2, false);
            break;
            
        case global.ITEM_TYPE.ARMOR:
            // Щит
            draw_rectangle(x + 2, y + 4, x + icon_size - 2, y + icon_size - 2, false);
            draw_rectangle(x + icon_size/2 - 1, y + 2, x + icon_size/2 + 1, y + icon_size - 4, false);
            break;
            
        case global.ITEM_TYPE.POTION:
            // Зелье
            draw_rectangle(x + 4, y + 8, x + icon_size - 4, y + icon_size, false);
            draw_rectangle(x + 6, y + 2, x + icon_size - 6, y + 8, false);
            break;
            
        case global.ITEM_TYPE.ACCESSORY:
            // Кольцо
            draw_rectangle(x + 6, y + 6, x + icon_size - 6, y + icon_size - 6, false);
            draw_rectangle(x + 4, y + icon_size/2 - 1, x + icon_size - 4, y + icon_size/2 + 1, false);
            break;
            
        case global.ITEM_TYPE.SCROLL:
            // Свиток
            draw_rectangle(x + 6, y + 8, x + icon_size - 6, y + icon_size - 8, false);
            // Линии текста на свитке
            draw_set_color(c_white);
            for (var i = 0; i < 3; i++) {
                draw_rectangle(x + 8, y + 12 + i * 5, x + icon_size - 8, y + 13 + i * 5, false);
            }
            break;
            
        case global.ITEM_TYPE.RELIC:
            // Реликвия
            draw_set_color(make_color_rgb(255, 215, 0));
            draw_circle(x + icon_size/2, y + icon_size/2, icon_size/3, false);
            break;
            
        default:
            draw_rectangle(x + 2, y + 2, x + icon_size - 2, y + icon_size - 2, false);
            break;
    }
}
function draw_sprite_shop_tab(x, y, width, height) {
    // Фон магазина с специальным спрайтом
    draw_sprite_modern_panel(x, y, width, height, "shop");
    
    // Остальной код магазина остается прежним, но теперь на красивом фоне
    global.shop_buttons = [];
    global.shop_page_buttons = [];
    
    // Заголовок магазина
    draw_set_color(ui_text);
    draw_set_halign(fa_center);
    draw_text(x + width/2, y + 15, "🎮 YOUTH EMPORIUM");
    draw_set_halign(fa_left);
    
    // Информация о золоте
    draw_set_color(ui_text);
    draw_text(x + 10, y + 35, "💰 Золото: " + format_large_number(global.gold));
    
    // Вкладки категорий
    draw_shop_categories(x + 10, y + 50, width - 20, 40);
    
    // Контент магазина
    var content_y = y + 100;
    var content_height = height - 110;
    draw_shop_category_items(x + 10, content_y, width - 20, content_height);
}
function init_daily_deals() {
    global.shop_daily_deals = [];
    
    // Добавляем несколько случайных предметов со скидкой
    var potential_items = [];
    var map = ds_map_create();
    var count = ds_map_size(global.ItemDB);
    var key = ds_map_find_first(global.ItemDB);
    
    for (var i = 0; i < count; i++) {
        var item = ds_map_find_value(global.ItemDB, key);
        // Выбираем предметы с редкостью от 1 до 3 для ежедневных сделок
        if (item[? "rarity"] >= 1 && item[? "rarity"] <= 3) {
            array_push(potential_items, key);
        }
        key = ds_map_find_next(global.ItemDB, key);
    }
    ds_map_destroy(map);
    
    // Выбираем 3 случайных предмета
    for (var i = 0; i < min(3, array_length(potential_items)); i++) {
        var random_index = irandom(array_length(potential_items) - 1);
        var item_id = potential_items[random_index];
        var item_data = ds_map_find_value(global.ItemDB, item_id);
        
        var deal = {
            item_id: item_id,
            original_price: item_data[? "price"],
            discount: 20 + irandom(30), // Скидка от 20% до 50%
            original_price: item_data[? "price"]
        };
        deal.final_price = floor(deal.original_price * (100 - deal.discount) / 100);
        
        array_push(global.shop_daily_deals, deal);
        array_delete(potential_items, random_index, 1);
    }
    
    show_debug_message("Ежедневные сделки инициализированы: " + string(array_length(global.shop_daily_deals)) + " предметов");
}

function draw_shop_category_items(x, y, width, height) {
    // Получаем предметы для текущей страницы категории
    var current_page_items = get_current_category_items();
    var page_info = get_current_category_page_info();
    
    // Информация о странице
    draw_set_color(ui_text_secondary);
    draw_set_halign(fa_center);
    draw_text(x + width/2, y + 10, "Страница " + string(page_info.current_page) + " из " + string(page_info.total_pages));
    draw_set_halign(fa_left);
    
    // Сетка предметов
    var items_per_row = 3;
    var item_width = floor((width - 40) / items_per_row);
    var item_height = 180;
    var start_x = x;
    var start_y = y + 30;
    
    // Отрисовка предметов текущей страницы
    for (var i = 0; i < array_length(current_page_items); i++) {
        var column = i mod items_per_row;
        var row = i div items_per_row;
        
        var item_x = start_x + column * (item_width + 10);
        var item_y = start_y + row * (item_height + 10);
        
        // Проверяем, находится ли предмет в видимой области
        if (item_y + item_height > y + height) continue;
        
        var item_id = current_page_items[i];
        var item_data = ds_map_find_value(global.ItemDB, item_id);
        
        if (item_data != -1) {
            var is_hovered = point_in_rectangle(mouse_x, mouse_y, item_x, item_y, item_x + item_width, item_y + item_height);
            
            draw_shop_item_card(item_x, item_y, item_width, item_height, item_data, i, is_hovered);
        }
    }
    
    // Если предметов нет
    if (array_length(current_page_items) == 0) {
        draw_set_color(ui_text_secondary);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_text(x + width/2, y + height/2, "В этой категории пока нет товаров");
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
    }
    
    // Пагинация для категории
    draw_category_pagination(x, y, width, height);
}
function draw_shop_header(x, y, width) {
    var header_y = y + 35;
    
    // Баланс золота
    draw_set_color(ui_highlight);
    draw_set_halign(fa_left);
    draw_text(x + 10, header_y, "💰 " + string(global.gold) + "g");
    
    // Репутация
    var rep_x = x + width - 150;
    draw_set_color(make_color_rgb(255, 215, 0));
    draw_text(rep_x, header_y, "⭐ Репутация: " + string(global.shop_reputation));
    
    // Уровень репутации
    var level_x = x + width - 50;
    draw_set_color(ui_success_color);
    draw_set_halign(fa_right);
    draw_text(level_x, header_y, "Ур. " + string(global.shop_reputation_level));
    draw_set_halign(fa_left);
}

function draw_shop_categories(x, y, width, height) {
    var category_names = ["⚔️ ОРУЖИЕ", "🛡️ БРОНЯ", "🧪 ЗЕЛЬЯ", "💎 ОСОБЫЕ", "🔥 СДЕЛКИ"];
    var category_width = width / array_length(category_names);
    
    for (var i = 0; i < array_length(category_names); i++) {
        var cat_x = x + i * category_width;
        var is_active = (i == global.shop_current_category);
        var is_hovered = point_in_rectangle(mouse_x, mouse_y, cat_x, y, cat_x + category_width, y + height);
        
        // Цвет вкладки
        var cat_color = is_active ? ui_highlight : (is_hovered ? ui_bg_accent : ui_bg_medium);
        
        // Фон вкладки
        draw_set_color(cat_color);
        draw_rectangle(cat_x, y, cat_x + category_width, y + height, false);
        
        // Рамка
        draw_set_color(is_active ? ui_highlight : ui_border_color);
        draw_rectangle(cat_x, y, cat_x + category_width, y + height, true);
        
        // Текст
        draw_set_color(is_active ? c_white : ui_text);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_text(cat_x + category_width/2, y + height/2, category_names[i]);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        
        // Кнопка категории
        array_push(global.shop_buttons, {
            type: "category",
            index: i,
            x1: cat_x, y1: y,
            x2: cat_x + category_width, y2: y + height
        });
    }
}

function draw_shop_items_section(x, y, width, height) {
    // Получаем предметы для текущей категории
    var shop_items = get_shop_items_by_category(global.shop_current_category);
    
    // Сетка предметов
    var items_per_row = 3;
    var item_width = floor((width - 40) / items_per_row);
    var item_height = 180;
    var start_x = x;
    var start_y = y;
    
    // Отрисовка предметов
    for (var i = 0; i < array_length(shop_items); i++) {
        var column = i mod items_per_row;
        var row = i div items_per_row;
        
        var item_x = start_x + column * (item_width + 10);
        var item_y = start_y + row * (item_height + 10);
        
        // Проверяем, находится ли предмет в видимой области
        if (item_y + item_height > y + height) continue;
        
        var item_id = shop_items[i];
        var item_data = ds_map_find_value(global.ItemDB, item_id);
        
        if (item_data != -1) {
            var is_hovered = point_in_rectangle(mouse_x, mouse_y, item_x, item_y, item_x + item_width, item_y + item_height);
            
            draw_modern_shop_item(item_x, item_y, item_width, item_height, item_data, i, is_hovered);
        }
    }
    
    // Если предметов нет
    if (array_length(shop_items) == 0) {
        draw_set_color(ui_text_secondary);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_text(x + width/2, y + height/2, "В этой категории пока нет товаров\n\nЗайдите позже!");
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
    }
}

function draw_daily_deals_section(x, y, width, height) {
    // Заголовок раздела
    draw_set_color(ui_text);
    draw_set_halign(fa_center);
    draw_text(x + width/2, y + 10, "🔥 ЕЖЕДНЕВНЫЕ СДЕЛКИ");
    draw_set_halign(fa_left);
    
    // Таймер обновления
    var time_left = 86400 - (current_time - global.shop_last_refresh); // 24 часа
    var hours = floor(time_left / 3600);
    var minutes = floor((time_left mod 3600) / 60);
    
    draw_set_color(ui_text_secondary);
    draw_set_halign(fa_center);
    draw_text(x + width/2, y + 35, "Обновление через: " + string(hours) + "ч " + string(minutes) + "м");
    draw_set_halign(fa_left);
    
    // Отрисовка сделок
    var deal_width = width;
    var deal_height = 120;
    var start_y = y + 60;
    
    for (var i = 0; i < array_length(global.shop_daily_deals); i++) {
        var deal = global.shop_daily_deals[i];
        var deal_y = start_y + i * (deal_height + 10);
        
        if (deal_y + deal_height > y + height) continue;
        
        var item_data = ds_map_find_value(global.ItemDB, deal.item_id);
        if (item_data != -1) {
            var is_hovered = point_in_rectangle(mouse_x, mouse_y, x, deal_y, x + deal_width, deal_y + deal_height);
            draw_daily_deal_item(x, deal_y, deal_width, deal_height, item_data, deal, i, is_hovered);
        }
    }
    
    // Если сделок нет
    if (array_length(global.shop_daily_deals) == 0) {
        draw_set_color(ui_text_secondary);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_text(x + width/2, y + height/2, "Сегодня нет специальных предложений\n\nЗагляните завтра!");
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
    }
}

function draw_modern_shop_item(x, y, width, height, item_data, index, is_hovered) {
    var rarity = item_data[? "rarity"];
    var rarity_color = get_rarity_color(rarity);
     // Обновляем отображение цены для больших чисел
    var final_price = calculate_elite_discount(item_data[? "id"]);
    var formatted_price = format_large_number(final_price);
    
    // В разделе отрисовки цены заменяем:
    draw_set_halign(fa_right);
    if (is_daily_deal) {
    
    // Проверяем, является ли предмет ежедневной сделкой
    for (var i = 0; i < array_length(global.shop_daily_deals); i++) {
        if (global.shop_daily_deals[i].item_id == item_data[? "id"]) {
            is_daily_deal = true;
            break;
        }
    }
    
    // Эффект подъема при наведении
    var hover_lift = is_hovered ? -2 : 0;
    
    // Фон карточки
    var card_bg = is_hovered ? merge_color(ui_bg_light, c_white, 0.1) : ui_bg_light;
    draw_set_color(card_bg);
    draw_rectangle(x, y + hover_lift, x + width, y + height + hover_lift, false);
    
    // Полоса редкости
    draw_set_color(rarity_color);
    draw_rectangle(x, y + hover_lift, x + width, y + 4 + hover_lift, false);
    
    // Иконка предмета
    var icon_size = 40;
    var icon_x = x + 10;
    var icon_y = y + 15 + hover_lift;
    
    draw_item_type_icon_improved(icon_x, icon_y, icon_size, item_data[? "type"], is_hovered);
    
    // Название предмета
    draw_set_color(ui_text);
    var name = item_data[? "name"];
    if (string_length(name) > 15) {
        name = string_copy(name, 1, 14) + "...";
    }
    draw_text(icon_x + icon_size + 15, icon_y, name);
    
    // Цена
    var price_x = x + width - 10;
    var price_y = icon_y;
    
    draw_set_color(ui_text);
    draw_set_halign(fa_right);
    
    if (is_daily_deal) {
        // Показываем старую и новую цену
        var original_price = item_data[? "price"];
        draw_set_color(ui_text_secondary);
        draw_set_font(fnt_small);
        draw_text(price_x, price_y, string(original_price) + "g");
        draw_set_font(fnt_main);
        
        // Зачеркнутая цена
        draw_set_color(ui_danger);
        draw_line(price_x - string_width(string(original_price) + "g"), price_y + 5, 
                 price_x, price_y + 5);
        
        // Новая цена
        draw_set_color(ui_success_color);
        draw_text(price_x, price_y + 20, string(final_price) + "g");
    } else {
        draw_text(price_x, price_y, formatted_price + "g");
    }
    draw_set_halign(fa_left);
    
    // Добавляем тултип для элитных предметов
    if (is_hovered && item_data[? "rarity"] >= 5) {
        draw_elite_item_tooltip(x, y, width, item_data);
    }
    // Описание
    var desc_y = icon_y + 25;
    draw_set_color(ui_text_secondary);
    draw_set_font(fnt_small);
    
    var desc = item_data[? "description"];
    if (string_length(desc) > 40) {
        desc = string_copy(desc, 1, 37) + "...";
    }
    draw_text(icon_x + icon_size + 15, desc_y, desc);
    draw_set_font(fnt_main);
    
    // Бонусы
    var bonuses_y = desc_y + 35;
    draw_item_bonuses_compact(icon_x + icon_size + 15, bonuses_y, width - (icon_x + icon_size + 25), item_data, is_hovered);
    
    // Кнопка покупки
    var btn_y = y + height - 35 + hover_lift;
    var can_afford = global.gold >= final_price;
    
    draw_modern_shop_button(x + 10, btn_y, width - 20, 30, item_data, final_price, can_afford, is_hovered && can_afford);
    
    // Рамка
    draw_set_color(is_hovered ? merge_color(ui_border_color, c_white, 0.2) : ui_border_color);
    draw_rectangle(x, y + hover_lift, x + width, y + height + hover_lift, true);
    
    // Сохраняем информацию о предмете для обработки кликов
    array_push(global.shop_buttons, {
        type: "shop_item",
        item_id: item_data[? "id"],
        index: index,
        x1: x, y1: y,
        x2: x + width, y2: y + height
    });
}

function draw_daily_deal_item(x, y, width, height, item_data, deal, index, is_hovered) {
    var rarity = item_data[? "rarity"];
    var rarity_color = get_rarity_color(rarity);
    var final_price = calculate_discounted_price(item_data[? "id"]);
    
    // Специальный фон для сделок
    var card_bg = is_hovered ? merge_color(make_color_rgb(60, 30, 40), c_white, 0.1) : make_color_rgb(50, 25, 35);
    draw_set_color(card_bg);
    draw_rectangle(x, y, x + width, y + height, false);
    
    // Яркая полоса для сделок
    draw_set_color(make_color_rgb(255, 100, 100));
    draw_rectangle(x, y, x + width, y + 4, false);
    
    // Бейдж "СДЕЛКА"
    draw_set_color(make_color_rgb(255, 50, 50));
    draw_set_halign(fa_center);
    draw_text(x + 50, y + 15, "🔥");
    draw_text(x + 50, y + 30, "СКИДКА");
    draw_text(x + 50, y + 45, string(deal.discount) + "%");
    draw_set_halign(fa_left);
    
    // Иконка предмета
    var icon_size = 50;
    var icon_x = x + 80;
    var icon_y = y + 10;
    
    draw_item_type_icon_improved(icon_x, icon_y, icon_size, item_data[? "type"], is_hovered);
    
    // Информация о предмете
    var info_x = icon_x + icon_size + 15;
    
    draw_set_color(ui_text);
    draw_text(info_x, icon_y, item_data[? "name"]);
    
    draw_set_color(ui_text_secondary);
    draw_set_font(fnt_small);
    draw_text(info_x, icon_y + 25, item_data[? "description"]);
    draw_set_font(fnt_main);
    
    // Цены
    var price_x = x + width - 150;
    
    draw_set_color(ui_text_secondary);
    draw_set_halign(fa_right);
    draw_text(price_x, icon_y, "Было: " + string(deal.original_price) + "g");
    
    // Зачеркнутая цена
    draw_set_color(ui_danger);
    draw_line(price_x - string_width("Было: " + string(deal.original_price) + "g"), icon_y + 5, 
             price_x, icon_y + 5);
    
    // Новая цена
    draw_set_color(ui_success_color);
    draw_text(price_x, icon_y + 25, "Стало: " + string(final_price) + "g");
    draw_set_halign(fa_left);
    
    // Экономия
    var savings = deal.original_price - final_price;
    draw_set_color(ui_highlight);
    draw_text(price_x + 10, icon_y + 50, "Экономия: " + string(savings) + "g!");
    
    // Бонусы
    var bonuses_y = icon_y + 50;
    draw_item_bonuses_compact(info_x, bonuses_y, width - info_x - 160, item_data, is_hovered);
    
    // Кнопка покупки
    var btn_x = x + width - 140;
    var btn_y = y + height - 35;
    var can_afford = global.gold >= final_price;
    
    draw_modern_shop_button(btn_x, btn_y, 130, 30, item_data, final_price, can_afford, is_hovered && can_afford);
    
    // Рамка
    draw_set_color(is_hovered ? merge_color(make_color_rgb(255, 100, 100), c_white, 0.2) : make_color_rgb(200, 80, 80));
    draw_rectangle(x, y, x + width, y + height, true);
    
    // Сохраняем информацию о предмете для обработки кликов
    array_push(global.shop_buttons, {
        type: "daily_deal",
        item_id: item_data[? "id"],
        index: index,
        x1: x, y1: y,
        x2: x + width, y2: y + height
    });
}

function draw_modern_shop_button(x, y, width, height, item_data, price, can_afford, is_hovered) {
    var btn_color = can_afford ? 
        (is_hovered ? merge_color(ui_success_color, c_white, 0.2) : ui_success_color) :
        (is_hovered ? merge_color(ui_danger, c_black, 0.2) : ui_danger);
    
    var text_color = can_afford ? ui_text : make_color_rgb(100, 100, 100);
    
    // Тень
    draw_set_color(ui_shadow_color);
    draw_set_alpha(0.3);
    draw_rectangle(x + 2, y + 2, x + width + 2, y + height + 2, false);
    draw_set_alpha(1);
    
    // Градиентный фон
    for (var i = 0; i < height; i++) {
        var ratio = i / height;
        var gradient_color = merge_color(btn_color, ui_bg_dark, ratio * 0.3);
        draw_set_color(gradient_color);
        draw_rectangle(x, y + i, x + width, y + i + 1, false);
    }
    
    // Верхняя световая полоса
    draw_set_color(c_white);
    draw_set_alpha(0.1);
    draw_rectangle(x, y, x + width, y + 2, false);
    draw_set_alpha(1);
    
    // Рамка
    draw_set_color(merge_color(btn_color, c_white, 0.1));
    draw_rectangle(x, y, x + width, y + height, true);
    
    // Текст кнопки
    draw_set_color(text_color);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    
    var btn_text = can_afford ? "🛒 КУПИТЬ" : "🔒 НЕТ ЗОЛОТА";
    if (can_afford && is_hovered) {
        btn_text = "👇 " + string(price) + "g 👇";
    } else if (can_afford) {
        btn_text = "🛒 " + string(price) + "g";
    }
    
    draw_text(x + width/2, y + height/2, btn_text);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
function draw_companions_tab(x, y, width, height) {
    draw_trophies_tab(x, y, width, height);
}
}