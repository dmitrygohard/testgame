
// Инициализация цветов интерфейса
if (!variable_global_exists("ui_text")) {
    // Базовые цвета интерфейса
    ui_text = c_white;
    ui_text_secondary = make_color_rgb(180, 190, 220);
    ui_bg_dark = make_color_rgb(18, 22, 34);
    ui_bg_medium = make_color_rgb(30, 37, 56);
    ui_bg_light = make_color_rgb(44, 54, 80);
    ui_highlight = make_color_rgb(97, 175, 239);
    ui_success_color = make_color_rgb(86, 213, 150);
    ui_danger = make_color_rgb(255, 108, 132);
    ui_border_color = make_color_rgb(70, 85, 120);
}

// Отрисовка интерфейса
draw_interface();

// Отрисовка уведомлений
draw_notifications();

// Сбрасываем флаг покупки в начале каждого кадра отрисовки
global.shop_purchase_processed = false;