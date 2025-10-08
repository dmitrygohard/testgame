// Сначала инициализируем основные системы
game_initialize();
// Затем инициализируем систему сохранения
game_data_init();
// Инициализация системы способностей
init_abilities_system();
// Потом загружаем состояние
load_game_state()
// В Create Event объекта interface
if (!variable_global_exists("spr_hpbar")) {
    // Инициализация спрайтов интерфейса
    global.spr_hpbar = hpbar0transparent_spr;
    global.spr_invent = invent0_spr;
    global.spr_ramka_shop = ramka0_spr;
    global.spr_ramka_big = ramka1big_spr;
    global.spr_ramka_expedition = ramka3_spr;
    global.spr_ramka_arenas = ramka2big_spr; 
    
    // Размеры спрайтов
    global.spr_hpbar_width = 819;
    global.spr_hpbar_height = 75;
    global.spr_invent_width = 185;
    global.spr_invent_height = 203;
    global.spr_ramka_shop_width = 327;
    global.spr_ramka_shop_height = 108;
    global.spr_ramka_big_width = 768;
    global.spr_ramka_big_height = 512;
    global.spr_ramka_expedition_width = 226;
    global.spr_ramka_expedition_height = 84;
    global.spr_ramka_arenas_width = 768;
    global.spr_ramka_arenas_height = 512;
}
 global.max_available_difficulty = 2; // 0-4 = 5 экспедиций
// Добавьте в game_initialize() или Create_0.gml
global.expedition_auto_repeat = {
    enabled: false,
    difficulties: [false, false, false, false, false], // Для 5 уровней сложности
    completed_count: 0
};

global.expedition_instant_complete_chance = 0;
global.expedition_reward_multiplier = 1.0;
global.simultaneous_expeditions = false;
// Инициализация системы магазина
if (!variable_global_exists("shop_system_initialized")) {
    init_shop_system();
    global.shop_system_initialized = true;
}

function format_large_number(amount) {
    if (amount < 1000) {
        return string(amount);
    } else if (amount < 1000000) {
        return string(floor(amount / 1000)) + "K";
    } else if (amount < 1000000000) {
        return string(floor(amount / 1000000)) + "M";
    } else {
        return string(floor(amount / 1000000000)) + "B";
    }
}

// Гарантируем, что флаги подтверждения экспедиции сброшены
global.expedition_confirmation_required = false;
global.pending_expedition_difficulty = -1;
// Разрешение игры
screen_width = 1000;
screen_height = 1000;
draw_set_font(fnt_main);

// Магазин - текущие предметы на странице
global.current_shop_page_items = [];
// Пагинация магазина
global.shop_current_page = 0;
global.shop_items_per_page = 3; // Было 6, теперь 3
global.shop_total_pages = 0;
global.shop_page_buttons = [];

// Инициализируем глобальные функции бафов
if (!variable_global_exists("start_buff_application")) {
    // Если функции не объявлены глобально, инициализируем их
    init_buff_system_globals();
}

function init_buff_system_globals() {
    // Создаем простые заглушки для глобальных функций
    global.start_buff_application = function(difficulty_index) {
        show_debug_message("Глобальная start_buff_application вызвана");
        // Базовая реализация или вызов функции из scr_buff_system
    };
    
    global.get_buff_modifier = function(buff_type) {
        return { additive: 0, multiplicative: 1 };
    };
    
    global.apply_buff_modifiers_to_expedition = function() {
        // Пустая реализация по умолчанию
    };
    
    global.remove_all_buffs = function() {
        global.active_buffs = [];
    };
    
    global.update_buff_system = function() {
        // Пустая реализация по умолчанию
    };
}
// В Create Event объекта interface
game_data_init(); // Эту строку нужно разместить до кода, который может вызвать game_data_save()
// Пагинация магазина
global.shop_current_page = 0;
global.shop_items_per_page = 6;
global.shop_total_pages = 0;
global.shop_page_buttons = [];
// Добавляем инициализацию системы бафов
init_buff_system();

// Добавляем глобальную переменную для отложенной экспедиции
global.pending_expedition_after_buffs = -1;
// Прокрутка инвентаря
global.inv_scroll_offset = 0;
global.inv_max_scroll = 0;
global.inv_scroll_dragging = false;
global.inv_scroll_drag_start_y = 0;
global.inv_scroll_drag_start_offset = 0;
global.inv_scrollbar_rect = -1;
global.inv_hovered_item = -1;

// Эффекты магазина
global.shop_hovered_item = -1;
global.purchased_items = ds_list_create();
global.purchase_effects = ds_list_create();

// Расчет размеров областей
global.frame_count = 0;
global.top_height = floor(screen_height * 0.25);
global.middle_height = floor(screen_height * 0.35);
global.bottom_height = screen_height - global.top_height - global.middle_height;

global.squad_width = floor(screen_width * 0.25);
global.tabs_width = screen_width - global.squad_width;

// Позиции областей
global.top_y = 0;
global.middle_y = global.top_height;
global.bottom_y = global.top_height + global.middle_height;

// Инициализация основных систем (НЕ перезаписывает прогресс)
game_initialize();

// Загружаем текущее состояние игры
load_game_state();

// Активная вкладка (0-статистика, 1-инвентарь, 2-экспедиции, 3-магазин, 4-трофеи, 5-способности)
active_tab = 0;
global.selected_hero_index = 0;

// Массивы для кнопок
global.arena_buttons = [];
global.tab_buttons = [];
global.squad_buttons = [];
global.shop_buttons = [];
global.expedition_buttons = [];
global.companion_purchase_buttons = [];
global.inv_buttons = [];
global.expedition_confirmation_buttons = [];
global.ability_buttons = []; // Добавьте эту строку

// Цветовая палитра
ui_bg_dark = make_color_rgb(18, 22, 34);
ui_bg_medium = make_color_rgb(30, 37, 56);
ui_bg_light = make_color_rgb(44, 54, 80);
ui_bg_accent = make_color_rgb(58, 71, 108);

ui_text = make_color_rgb(235, 240, 255);
ui_text_secondary = make_color_rgb(180, 190, 220);

ui_highlight = make_color_rgb(97, 175, 239);
ui_success_color = make_color_rgb(86, 213, 150);
ui_warning_color = make_color_rgb(255, 178, 85);
ui_danger = make_color_rgb(255, 108, 132);

ui_border_color = make_color_rgb(70, 85, 120);
ui_shadow_color = make_color_rgb(10, 15, 25);

// Градиентные цвета для карточек
card_gradient_1 = make_color_rgb(40, 49, 74);
card_gradient_2 = make_color_rgb(35, 43, 65);
card_gradient_3 = make_color_rgb(30, 37, 56);

// Цвета помощниц
companion_colors = [
    make_color_rgb(97, 175, 239),   // Hepo
    make_color_rgb(86, 213, 150),   // Fatty
    make_color_rgb(255, 178, 85)    // Discipline
];

// Подтверждение экспедиции с боссом
global.expedition_confirmation_required = false;
global.pending_expedition_difficulty = -1;

// В конец Create Event добавляем:

// Инициализация кнопки возврата
global.return_button = undefined;
// Убедимся, что комната room_main существует, или создадим fallback
if (!variable_global_exists("room_main")) {
    // Если room_main не определена, используем первую комнату
    global.room_main = room_first;
}
// Create_0.gml - добавьте в конец
// Гарантируем, что флаги подтверждения сброшены
global.expedition_confirmation_required = false;
global.pending_expedition_difficulty = -1;
function draw_companions_tab(x, y, width, height) {
    draw_trophies_tab(x, y, width, height);
}