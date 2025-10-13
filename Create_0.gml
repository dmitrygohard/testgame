// Сначала объявляем все необходимые перечисления
enum QUEST_TYPE {
    EXPEDITION,
    COLLECTION,
    COMBAT,
    ECONOMY,
    UPGRADE,
    COMPANION
}

enum QUEST_RARITY {
    COMMON,
    UNCOMMON,
    RARE,
    EPIC,
    LEGENDARY
}

enum QUEST_STATE {
    AVAILABLE,
    IN_PROGRESS,
    COMPLETED,
    CLAIMED,
    FAILED
}

enum QUEST_CATEGORY {
    MAIN_STORY,
    SIDE_QUEST,
    DAILY,
    WEEKLY,
    EVENT,
    ACHIEVEMENT
}

enum QUEST_OBJECTIVE_TYPE {
    COLLECT_ITEMS,
    DEFEAT_ENEMIES,
    COMPLETE_EXPEDITIONS,
    UPGRADE_ITEMS,
    EARN_GOLD,
    SPEND_GOLD,
    USE_ABILITIES,
    COMPLETE_MINIGAMES,
    REACH_LEVEL,
    CRAFT_ITEMS,
    COMPLETE_RAIDS,
    INTERACT_NPCS
}

// Сначала инициализируем цвета
aty_init_colors();

global.aty_high_res = true;
global.aty_render_scale = 1;

// Добавьте в инициализацию шрифтов
global.aty_font_title = font_main_title;   // Крупный шрифт для заголовков
global.aty_font_bold = font_main_bold;     // Жирный шрифт
global.aty_font_normal = font_main;        // Основной шрифт  
global.aty_font_small = font_main_small;   // Мелкий шрифт
global.aty_font_large = font_main;   // Крупный шрифт для иконок

// Инициализация переменных для подсказок
global.aty_tooltip_item = undefined;
global.aty_tooltip_x = 0;
global.aty_tooltip_y = 0;
global.aty_tooltip_high_res = false;
global.aty_mouse_x = 0;
global.aty_mouse_y = 0;

global.aty_render_surface = -1;
if (global.aty_high_res) {
    var width = room_width * global.aty_render_scale;
    var height = room_height * global.aty_render_scale;
    global.aty_render_surface = surface_create(width, height);
}

// В главной функции инициализации игры (например в Create событии)
aty_init_trophy_system();
draw_set_font(fnt_main);
global.aty = {};
aty_init();

// Добавляем тестовые предметы только если их нет
if (!variable_struct_exists(global, "aty") || !is_struct(global.aty) || array_length(global.aty.inventory) == 0) {
    aty_add_test_items();
}