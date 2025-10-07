// scr_draw_functions.gml
function draw_interface() {
    // Рисуем фоновый градиент
    draw_background_gradient();
    
    // 1. Верхняя часть (25%) - зависит от комнаты
    if (room == room_hepo_arena) {
        draw_hepo_arena_room();
    } else {
        draw_arenas_section();
    }
    
    // 2. Средняя часть (35%) - Игровая зона  
    draw_game_zone();
    
    // 3. Нижняя часть (оставшееся) - Панель управления
    draw_control_panel();
    
    // 4. Окно подтверждения экспедиции (если нужно)
    draw_expedition_confirmation();
}

function draw_background_gradient() {
    // Градиентный фон с использованием прямоугольников
    for (var i = 0; i < global.screen_height; i++) {
        var ratio = i / global.screen_height;
        var r = lerp(15, 25, ratio);
        var g = lerp(20, 35, ratio);
        var b = lerp(30, 45, ratio);
        draw_set_color(make_color_rgb(r, g, b));
       // draw_rectangle(0, i, global.screen_width, i + 1, false);
    }
}

function draw_modern_panel(x, y, width, height, with_shadow = true) {
    if (with_shadow) {
        // Тень панели
        draw_set_color(c_yellow);
        draw_set_alpha(0.3);
        //draw_rectangle(x + 3, y + 3, x + width + 3, y + height + 3, false);
        draw_set_alpha(1);
    }
    
    // Основная панель с градиентом
    draw_set_color(c_yellow);
    //draw_rectangle(x, y, x + width, y + height, false);
    
    // Верхний акцент
    draw_set_color(c_yellow);
    draw_set_alpha(0.1);
    //draw_rectangle(x, y, x + width, y + 2, false);
    draw_set_alpha(1);
    
    // Рамка
    draw_set_color(c_yellow);
    //draw_rectangle(x, y, x + width, y + height, true);
}

function draw_modern_button(x, y, width, height, text, is_active = false, is_hovered = false) {
    var btn_color = ui_bg_light;
    var text_color = c_yellow;
    
    if (is_active) {
        btn_color = ui_highlight;
        text_color = c_white;
    } else if (is_hovered) {
        btn_color = ui_bg_accent;
    }
    
    // Тень кнопки
    draw_set_color(ui_shadow_color);
    draw_set_alpha(0.4);
    draw_rectangle(x + 2, y + 2, x + width + 2, y + height + 2, false);
    draw_set_alpha(1);
    
    // Градиент кнопки
    draw_set_color(btn_color);
    draw_rectangle(x, y, x + width, y + height, false);
    
    // Световая полоса сверху для эффекта объема
    draw_set_color(c_white);
    draw_set_alpha(0.1);
    draw_rectangle(x, y, x + width, y + 1, false);
    draw_set_alpha(1);
    
    // Рамка
    draw_set_color(is_active ? ui_highlight : ui_border_color);
    draw_rectangle(x, y, x + width, y + height, true);
    
    // Текст
    draw_set_color(text_color);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(x + width/2, y + height/2, text);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

function draw_arenas_section() {
    var section_height = global.top_height;
    draw_set_color(ui_bg_medium);
   // draw_rectangle(0, 0, global.screen_width, section_height, false);
    
    draw_set_color(ui_text);
    draw_set_halign(fa_center);
    //draw_text(global.screen_width / 2, 10, "ТРЕНИРОВОЧНЫЕ АРЕНЫ");
    draw_set_halign(fa_left);
    
    // Отрисовка арен по количеству доступных арен
    var arena_count = array_length(global.arenas);
    var arena_width = floor((global.screen_width - 50) / arena_count);
    var arena_height = section_height - 40;
    var arena_start_y = 30;
    
    global.arena_buttons = [];
    
    for (var i = 0; i < arena_count; i++) {
        var arena_x = 10 + i * (arena_width + 10);
        
        // Проверяем границы
        if (arena_x + arena_width > global.screen_width) {
            arena_width = global.screen_width - arena_x - 10;
        }
        
        draw_arena(arena_x, arena_start_y, arena_width, arena_height, i);
    }
}
// Эта функция заменяет существующий код draw_expeditions_tab().  Она
// показывает только экспедиции с индексами ≤ global.max_available_difficulty.
function draw_expeditions_tab(x, y, width, height) {
    // Фон панели
    draw_set_color(ui_bg_dark);
    draw_rectangle(x, y, x + width, y + height, false);
    
    // Заголовок
    draw_set_color(ui_text);
    draw_set_halign(fa_center);
    draw_text(x + width/2, y + 20, "🗺️ ЭКСПЕДИЦИИ");
    draw_set_halign(fa_left);
    
    // Сброс массива кнопок
    global.expedition_buttons = [];
    
    // Проверяем инициализацию
    if (!variable_global_exists("expedition") || !variable_global_exists("max_available_difficulty") || !variable_global_exists("expedition_difficulties")) {
        draw_set_color(ui_text_secondary);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_text(x + width/2, y + height/2, "Система экспедиций загружается...");
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        return;
    }
    
    // Если экспедиция активна – отображаем прогресс (оставьте существующий код)
    if (global.expedition.active) {
        /*
         * Здесь остаётся код, который показывает активную экспедицию,
         * прогресс‑бар, оставшееся время и т.п.
         */
        return;
    }
    
    // --- Отображение списка доступных экспедиций ---
    draw_set_color(ui_text);
    draw_text(x + 20, y + 60, "Доступные экспедиции:");
    
    var expedition_width  = width - 300;
    var displayed_count = 0;
    
    // Ограничиваем максимальный индекс сложности
    var max_difficulty = min(global.max_available_difficulty, array_length(global.expedition_difficulties) - 1);
     // Чтобы все открытые экспедиции помещались в блок, распределяем их по высоте динамически.
    var total_entries = max(1, max_difficulty + 1);
    var list_top = y + 70;
    var list_bottom = y + height - 20;
    var available_height = max(1, list_bottom - list_top);
    var expedition_step = available_height / total_entries;
    var expedition_height = floor(clamp(expedition_step - 8, 36, expedition_step));
    var expedition_offset = max(0, (expedition_step - expedition_height) * 0.5);
    
    for (var i = 0; i <= max_difficulty; i++) {
        var diff = global.expedition_difficulties[i];
       var expedition_y = floor(list_top + displayed_count * expedition_step + expedition_offset);
        displayed_count++;
        
       
        // На случай округления гарантируем, что карточка не выйдет за пределы доступной области
        if (expedition_y + expedition_height > list_bottom) {
            expedition_y = max(list_top, list_bottom - expedition_height);
        }
        var success_chance = calculate_success_chance(i);
        var is_hovered = point_in_rectangle(mouse_x, mouse_y, x + 20, expedition_y, x + 20 + expedition_width, expedition_y + expedition_height);
        
        // Фон
        var bg_color = is_hovered ? merge_color(ui_bg_light, c_white, 0.1) : ui_bg_light;
        draw_set_color(bg_color);
        draw_rectangle(x + 20, expedition_y, x + 20 + expedition_width, expedition_y + expedition_height, false);
        
        // Цвет полосы сложности
        var difficulty_color = ui_highlight;
        if (i >= 3) difficulty_color = ui_danger;
        else if (i >= 1) difficulty_color = ui_warning_color;
        draw_set_color(difficulty_color);
        draw_rectangle(x + 20, expedition_y, x + 25, expedition_y + expedition_height, false);
        
        // Название и уровень
        draw_set_color(ui_text);
        draw_text(x + 35, expedition_y, diff.name);
        draw_set_color(ui_text_secondary);
        draw_text(x + 35, expedition_y + 10, "Уровень " + string(diff.level));
        
        // Описание (сокращаем до 35 символов)
        draw_set_color(ui_text_secondary);
        draw_set_font(fnt_small);
        var short_desc = string_copy(diff.description, 1, 35);
        if (string_length(diff.description) > 35) short_desc += "...";
        draw_text(x + 35, expedition_y + 20, short_desc);
        draw_set_font(fnt_main);
        
        // Статистика
        var stats_y = expedition_y + 30;
        draw_set_color(ui_text);
        draw_text(x + 35, stats_y, "💰 " + string(diff.reward_min) + "-" + string(diff.reward_max));
        draw_text(x + 150, stats_y, "⏱️ " + string(floor(diff.duration / 60)) + "с");
        draw_text(x + 220, stats_y, "🎯 " + string(round(success_chance)) + "%");
        
        // Босс, если есть
        if (diff.boss != -1 && variable_global_exists("companions") && diff.boss < array_length(global.companions)) {
            var boss_name = global.companions[diff.boss].name;
            draw_set_color(ui_danger);
            draw_text(x + expedition_width - 120, expedition_y + 10, "⚔️ " + boss_name);
        }
        
        // Рамка
        draw_set_color(is_hovered ? merge_color(ui_border_color, c_white, 0.2) : ui_border_color);
        draw_rectangle(x + 20, expedition_y, x + 20 + expedition_width, expedition_y + expedition_height, true);
        
        // Кнопка для запуска экспедиции
        array_push(global.expedition_buttons, {
            difficulty: i,
            x1: x + 20,
            y1: expedition_y,
            x2: x + 20 + expedition_width,
            y2: expedition_y + expedition_height
        });
    }
    
    // Если ничего не отобразилось
    if (displayed_count == 0) {
        draw_set_color(ui_text_secondary);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_text(x + width/2, y + height/2, "Нет доступных экспедиций");
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
    }
        // Информация о системе авто-повтора
        if (global.expedition_auto_repeat.enabled) {
            var auto_y = y + height - 40;
            draw_set_color(ui_success_color);
            draw_set_halign(fa_center);
            draw_text(x + width/2, auto_y, "🔁 АВТО-ПОВТОР АКТИВЕН");
            draw_set_halign(fa_left);
        }
    }

function draw_arena(x, y, width, height, index) {
    var arena = global.arenas[index];
    var companion = global.companions[index];
    
    // Используем современную панель
    draw_modern_panel(x, y, width, height);
    
    // Цвет арены основан на индексе
    var arena_color = companion_colors[index];
    
    draw_set_color(ui_text);
    draw_set_halign(fa_center);
    
    // Название с иконкой (текстовой)
    var name = "⚔️ " + string_copy(arena.name, 1, min(string_length(arena.name), 12));
    draw_text(x + width/2, y - 20, name);
    
    if (arena.unlocked) {
        if (arena.active) {
            // Анимированная полоса прогресса
            var progress_width = width - 20;
            var progress_x = x + 10;
            var progress_y = y + 60;
            
            // Фон прогресса
            draw_set_color(ui_bg_dark);
            draw_rectangle(progress_x, progress_y, progress_x + progress_width, progress_y + 8, false);
            
            // Заполнение прогресса с анимацией
            var pulse = 0.7 + sin(global.frame_count * 0.1) * 0.3;
            draw_set_color(merge_color(ui_success_color, c_yellow, pulse * 0.2));
            var progress = companion.training_progress / 100;
            draw_rectangle(progress_x, progress_y, progress_x + progress_width * progress, progress_y + 8, false);
            
            draw_set_color(ui_success_color);
            draw_text(x + width/2, y + 30, "🎯 Тренировка...");
            draw_text(x + width/2, y + 45, "Накоплено: " + string(floor(companion.training_progress)) + " опыта");
            
            // Кнопка завершения
            var btn_y = y + height - 35;
            var is_hovered = point_in_rectangle(mouse_x, mouse_y, x + 10, btn_y, x + width - 10, btn_y + 25);
            draw_modern_button(x + 60, btn_y, width - 100, 25, "⏹️ Завершить", false, is_hovered);
            
            array_push(global.arena_buttons, {
                type: "complete_training",
                index: index,
                x1: x + 10, y1: btn_y,
                x2: x + width - 10, y2: btn_y + 25
            });
            
        } else {
            draw_set_color(ui_text_secondary);
            draw_text(x + width/2, y + 30, "💤 Свободна");
            draw_text(x + width/2, y + 45, "⚡ " + string(companion.training_rate) + "/сек");
            
            // ДЛЯ ARENЫ HEPO (index == 0) ДОБАВЛЯЕМ ДВЕ КНОПКИ
            if (index == 0) { // Hepo имеет индекс 0
                // Кнопка "На тренировку" - верхняя
                var training_btn_y = y + height - 70;
                var training_btn_hovered = point_in_rectangle(mouse_x, mouse_y, x + 10, training_btn_y, x + width - 10, training_btn_y + 25);
                draw_modern_button(x + 10, training_btn_y, width - 20, 25, "⚡ На тренировку", false, training_btn_hovered);
                
                // Кнопка "Войти на арену" - нижняя
                var arena_btn_y = y + height - 35;
                var arena_btn_hovered = point_in_rectangle(mouse_x, mouse_y, x + 10, arena_btn_y, x + width - 10, arena_btn_y + 25);
                draw_modern_button(x + 10, arena_btn_y, width - 20, 25, "🚪 Войти на арену", false, arena_btn_hovered);
                
                // Добавляем обе кнопки в массив
                array_push(global.arena_buttons, {
                    type: "start_training",
                    index: index,
                    x1: x + 10, y1: training_btn_y,
                    x2: x + width - 10, y2: training_btn_y + 25
                });
                
                array_push(global.arena_buttons, {
                    type: "enter_arena",
                    index: index,
                    x1: x + 10, y1: arena_btn_y,
                    x2: x + width - 10, y2: arena_btn_y + 25
                });
                
            } else {
                // Для других арен оставляем обычную кнопку
                array_push(global.arena_buttons, {
                    type: "start_training",
                    index: index,
                    x1: x, y1: y,
                    x2: x + width, y2: y + height
                });
            }
        }
    } else {
        draw_set_color(ui_text_secondary);
        draw_text(x + width/2, y + 200, "🔒 Заблокирована");
    }
    
    draw_set_halign(fa_left);
}

function draw_game_zone() {
    var section_y = global.top_height;
    var section_height = global.middle_height;
    
    draw_set_color(ui_bg_dark);
   // draw_rectangle(0, section_y, global.screen_width, section_y + section_height, false);
    
    draw_set_color(ui_text);
    draw_set_halign(fa_center);
    // draw_text(global.screen_width/2, section_y + 15, "ИГРОВАЯ ЗОНА");
    draw_set_halign(fa_left);
    
    var zone_x = global.screen_width * 0.1;
    var zone_y = section_y + 40;
    var zone_width = global.screen_width * 0.8;
    var zone_height = section_height - 60;
    
    draw_set_color(ui_bg_medium);
   // draw_rectangle(zone_x, zone_y, zone_x + zone_width, zone_y + zone_height, false);
    
    if (global.expedition.active) {
        draw_text(zone_x + zone_width/2, zone_y + zone_height/2 - 20, "Экспедиция в процессе");
        var progress = global.expedition.progress / global.expedition.duration;
        draw_text(zone_x + zone_width/2, zone_y + zone_height/2, "Прогресс: " + string(floor(progress * 100)) + "%");
        
        // Прогресс бар экспедиции
        var bar_width = zone_width * 0.6;
        var bar_x = zone_x + (zone_width - bar_width) / 2;
        var bar_y = zone_y + zone_height/2 + 20;
        
        draw_set_color(ui_bg_dark);
        draw_rectangle(bar_x, bar_y, bar_x + bar_width, bar_y + 15, false);
        draw_set_color(ui_highlight);
        draw_rectangle(bar_x, bar_y, bar_x + bar_width * progress, bar_y + 15, false);
        draw_set_color(ui_border_color);
        draw_rectangle(bar_x, bar_y, bar_x + bar_width, bar_y + 15, true);
    } else if (global.buff_system.is_applying_buffs) {
        // Отрисовка процесса наложения бафов
        draw_buff_application(zone_x, zone_y, zone_width, zone_height);
    } else {
        // Отрисовываем костер при отдыхе
        draw_campfire(zone_x, zone_y, zone_width, zone_height);
        
		draw_set_alpha(0.6);
        draw_set_color(ui_text);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_text(zone_x + 180 + zone_width/2, zone_y + 90 + zone_height/2, "Отряд отдыхает");
        draw_set_color(ui_text_secondary);
        draw_text(zone_x + 200 + zone_width/2, zone_y + 110 + zone_height/2, "Отправьтесь в экспедицию для получения наград");
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
		draw_set_alpha(1);
    }
}

function draw_control_panel() {
    var panel_y = global.top_height + global.middle_height;
    var panel_height = global.bottom_height;
    
    // 3.1 Левая колонка (25%) - Отряд или бафы Hepo
    if (room == room_hepo_arena) {
        draw_hepo_buffs_section(panel_y, panel_height);
    } else {
        draw_squad_section(panel_y, panel_height);
    }
    
    // 3.2 Правая колонка (75%) - Вкладки
    draw_tabs_section(panel_y, panel_height);
    
    // Содержимое вкладок
    var content_x = global.squad_width;
    var content_y = panel_y + 40; // +40 чтобы было под вкладками
    var content_width = global.tabs_width;
    var content_height = panel_height - 40; // Уменьшаем высоту на высоту вкладок
    
    switch(active_tab) {
        case 0: draw_stats_tab(content_x, content_y, content_width, content_height); break;
        case 1: draw_inventory_tab(content_x, content_y, content_width, content_height); break;
        case 2: draw_expeditions_tab(content_x, content_y, content_width, content_height); break;
        case 3: draw_shop_tab(content_x, content_y, content_width, content_height); break;
        case 4: draw_companions_tab(content_x, content_y, content_width, content_height); break;
        case 5: draw_abilities_tab(content_x, content_y, content_width, content_height); break;
    }
}

function draw_squad_section(panel_y, panel_height) {
    var section_width = global.squad_width;
    
    draw_set_color(ui_bg_dark);
    //draw_rectangle(0, panel_y, section_width, panel_y + panel_height, false);
    
    draw_set_color(ui_text);
    draw_set_halign(fa_center);
    draw_text(section_width/2, panel_y + 15, "ОТРЯД");
    draw_set_halign(fa_left);
    
    // Отряд: главный герой + 4 помощницы
    var member_height = 70;
    var start_y = panel_y + 40;
    var member_width = section_width - 20;
    
    // Главный герой (всегда в отряде)
    draw_squad_member(10, start_y, member_width, member_height, global.hero, -1, true);
    
    // Помощницы
    global.squad_buttons = [];
    for (var i = 0; i < 3; i++) {
        var member_y = start_y + (i+1) * (member_height + 5);
        var companion = global.companions[i];
        
        if (companion.unlocked && !companion.training) {
            // Помощница в отряде
            draw_squad_member(10, member_y, member_width, member_height, companion, i, false);
            
            // Кнопка для отправки на тренировку
            array_push(global.squad_buttons, {
                type: "companion",
                index: i,
                x1: 10, y1: member_y,
                x2: 10 + member_width, y2: member_y + member_height
            });
        } else {
            // Пустой слот или помощница на тренировке
            draw_set_color(make_color_rgb(40, 40, 55));
            draw_rectangle(10, member_y, 10 + member_width, member_y + member_height, false);
            draw_set_color(ui_text_secondary);
            if (companion.training) {
                draw_text(15, member_y + 25, companion.name + " (тренируется)");
            } else {
                draw_text(15, member_y + 25, "Пустой слот");
            }
        }
    }
}

function draw_squad_member(x, y, width, height, character, companion_index, is_hero) {
    // Фон члена отряда
    draw_set_color(ui_bg_light);
    draw_rectangle(x, y, x + width, y + height, false);
    
    // Цветная полоса слева (для героя - синяя, для помощниц - их цвет)
    var color = is_hero ? ui_highlight : companion_colors[companion_index];
    draw_set_color(color);
    draw_rectangle(x, y, x + 5, y + height, false);
    
    // Информация о персонаже
    draw_set_color(ui_text);
    var name = is_hero ? "Главный герой" : character.name;
    draw_text(x + 10, y + 5, name);
    draw_text(x + 10, y + 25, "Ур. " + string(character.level));
    
    // Здоровье
    var health_text = "Зд: " + string(character.health) + "/" + string(character.max_health);
    draw_text(x + 10, y + 45, health_text);
    
    // Для помощниц показываем их эффект
    if (!is_hero) {
        draw_set_color(ui_text_secondary);
        draw_text(x + 70, y + 25, character.effect);
    }
}

function draw_campfire(x, y, width, height) {
    if (!global.expedition.active && global.hero.health < global.hero.max_health) {
        var fire_center_x = x + 200 + width / 2;
        var fire_center_y = y + height - 80;
        
        // Анимация пламени
        var time = global.frame_count * 0.1;
        var flame_wave = sin(time) * 2;
        var pulse = 0.8 + sin(time * 2) * 0.2;
        
        // Угли под костром
        draw_set_color(make_color_rgb(80, 40, 20));
        draw_circle(fire_center_x, fire_center_y + 20, 30, false);
        
        // Основное пламя (несколько слоев для объема)
        for (var i = 0; i < 3; i++) {
            var size = 25 - i * 5;
            var offset = i * 2;
            var alpha = 0.8 - i * 0.2;
            
            draw_set_color(make_color_rgb(255, 100 + i * 20, 0));
            draw_set_alpha(alpha);
            
            // Анимированные вершины пламени
            var vertices = [];
            array_push(vertices, fire_center_x, fire_center_y - size - flame_wave);
            array_push(vertices, fire_center_x - size + offset, fire_center_y + 10);
            array_push(vertices, fire_center_x + size - offset, fire_center_y + 10);
            
            draw_primitive_begin(pr_trianglelist);
            for (var j = 0; j < array_length(vertices); j += 2) {
                draw_vertex(vertices[j], vertices[j + 1]);
            }
            draw_primitive_end();
        }
        draw_set_alpha(1);
        
        // Искры
        if (global.frame_count mod 3 == 0) {
            for (var i = 0; i < 2; i++) {
                var spark_x = fire_center_x + random_range(-15, 15);
                var spark_y = fire_center_y - random_range(5, 25);
                var spark_size = random_range(1, 3);
                
                draw_set_color(make_color_rgb(255, 255, 150));
                draw_set_alpha(0.7);
                draw_rectangle(spark_x, spark_y, spark_x + spark_size, spark_y + spark_size, false);
            }
            draw_set_alpha(1);
        }
        
        // Дым
        var smoke_y = fire_center_y - 40 - (global.frame_count mod 60) * 0.5;
        draw_set_color(make_color_rgb(100, 100, 100));
        draw_set_alpha(0.3);
        draw_circle(fire_center_x + 10, smoke_y, 15, false);
        draw_set_alpha(1);
        
        // Текст с анимацией пульсации
        draw_set_color(c_aqua);
        draw_set_halign(fa_center);
        var text_alpha = 0.7 + sin(global.frame_count * 0.05) * 0.3;
        draw_set_alpha(text_alpha);
        draw_text(fire_center_x, fire_center_y - 55, "🔥 Отряд отдыхает у костра");
        draw_set_alpha(1);
        draw_set_halign(fa_left);
    }
}


// В функции draw_hepo_arena_room() улучшаем кнопку возврата:

function draw_hepo_arena_room() {
    // Фон арены Hepo
    draw_set_color(make_color_rgb(20, 35, 60));
    draw_rectangle(0, 0, global.screen_width, global.middle_height, false);
    
    // Заголовок
    draw_set_color(ui_text);
    draw_set_halign(fa_center);
    draw_text(global.screen_width / 2, 30, "🏆 АРЕНА HEPO");
    
    // Центральная сцена с Hepo
    var center_x = global.screen_width / 2;
    var center_y = global.middle_height / 2;
    
    // Магический круг
    draw_set_color(make_color_rgb(97, 175, 239));
    draw_set_alpha(0.3);
    draw_circle(center_x, center_y, 80, false);
    draw_set_alpha(1);
    
    // Анимированная Hepo
    var breath = sin(global.frame_count * 0.05) * 3;
    
    // Отрисовка простого спрайта Hepo (круги)
    draw_set_color(make_color_rgb(97, 175, 239));
    draw_circle(center_x, center_y - 20 + breath, 15, false); // голова
    
    draw_set_color(make_color_rgb(70, 130, 180));
    draw_rectangle(center_x - 12, center_y + breath, center_x + 12, center_y + 50 + breath, false); // тело
    
    // Магические эффекты
    if (global.frame_count mod 10 == 0) {
        for (var i = 0; i < 3; i++) {
            var angle = random(360);
            var dist = random(30);
            var spark_x = center_x + lengthdir_x(dist, angle);
            var spark_y = center_y + lengthdir_y(dist, angle);
            
            draw_set_color(make_color_rgb(150, 200, 255));
            draw_set_alpha(0.7);
            draw_circle(spark_x, spark_y, 2, false);
            draw_set_alpha(1);
        }
    }
    
    // Кнопка возврата - УЛУЧШЕННАЯ ВЕРСИЯ
    var return_btn_x = global.screen_width - 120;
    var return_btn_y = 20;
    var return_btn_width = 100;
    var return_btn_height = 30;
    
    var is_hovered = point_in_rectangle(mouse_x, mouse_y, return_btn_x, return_btn_y, return_btn_x + return_btn_width, return_btn_y + return_btn_height);
    
    // Рисуем кнопку с эффектом наведения
    draw_modern_button(return_btn_x, return_btn_y, return_btn_width, return_btn_height, "← Назад", false, is_hovered);
    
    // Добавляем подсказку про ESC
    draw_set_color(ui_text_secondary);
    draw_set_font(fnt_small);
    draw_set_halign(fa_center);
    draw_text(return_btn_x + return_btn_width/2, return_btn_y + return_btn_height + 15, "[ESC]");
    draw_set_halign(fa_left);
    draw_set_font(fnt_main);
    
    // Сохраняем кнопку возврата с БОЛЕЕ ЯВНЫМИ КООРДИНАТАМИ
    global.return_button = {
        x1: return_btn_x, 
        y1: return_btn_y,
        x2: return_btn_x + return_btn_width, 
        y2: return_btn_y + return_btn_height
    };
    
    // Информация об арене
    draw_set_color(ui_text);
    draw_set_halign(fa_center);
    draw_text(center_x, center_y + 80, "Тренировочная арена Hepo");
    draw_set_color(ui_text_secondary);
    draw_text(center_x, center_y + 105, "Место для будущих испытаний и тренировок");
    
    draw_set_halign(fa_left);
}

//-235 250
function draw_notifications() {
    // Проверяем, существует ли массив, прежде чем его использовать
    if (!variable_global_exists("notifications")) {
        return; // Если переменной нет, просто выходим из функции
    }
    
    var notification_x = 100;
    var notification_y = global.screen_height - 235;
    var notification_width = 250;
    var notification_height = 30;
    
    // Отрисовка эффектов продажи
    if (variable_global_exists("purchase_effects")) {
        var i = 0;
        while (i < ds_list_size(global.purchase_effects)) {
            var effect = ds_list_find_value(global.purchase_effects, i);
            
            // ИСПРАВЛЕНО: безопасная проверка существования поля
            if (variable_struct_exists(effect, "purchase_frame")) {
                var age = global.frame_count - effect.purchase_frame;
                
                if (age < 90) { // 1.5 секунды
                    var alpha = 1 - (age / 90);
                    var effect_y = notification_y - (i * 25);
                    
                    if (effect.type == "sell") {
                        // Эффект продажи - зеленый цвет
                        draw_set_color(merge_color(ui_success_color, c_white, alpha));
                        draw_set_alpha(alpha);
                        draw_set_halign(fa_center);
                        draw_text(notification_x + notification_width/2, effect_y, "💰 +" + string(effect.amount) + " золота");
                        draw_set_halign(fa_left);
                        draw_set_alpha(1);
                    }
                    i++;
                } else {
                    ds_list_delete(global.purchase_effects, i);
                    // Не увеличиваем i, так как элементы сместились
                }
            } else {
                // Если структура некорректна, удаляем её
                ds_list_delete(global.purchase_effects, i);
            }
        }
    }
    
    // Отрисовка обычных уведомлений
    for (var i = 0; i < array_length(global.notifications); i++) {
        var notification = global.notifications[i];
        var alpha = notification.timer / 180;
        
        if (alpha > 0) {
            // Фон уведомления
            draw_set_color(ui_bg_dark);
            draw_set_alpha(alpha * 0.8);
            draw_rectangle(notification_x, notification_y - notification_height, 
                          notification_x + notification_width, notification_y, false);
            draw_set_alpha(1);
            
            // Рамка
            draw_set_color(ui_highlight);
            draw_set_alpha(alpha);
            draw_rectangle(notification_x, notification_y - notification_height, 
                          notification_x + notification_width, notification_y, true);
            draw_set_alpha(1);
            
            // Текст
            draw_set_color(ui_text);
            draw_set_alpha(alpha);
            draw_text(notification_x + 10, notification_y - notification_height + 5, notification.message);
            draw_set_alpha(1);
            
            notification.timer--;
            notification_y -= notification_height + 5;
        } else {
            array_delete(global.notifications, i, 1);
            i--;
        }
    }
}
function lerp(a, b, t) {
    return a + (b - a) * t;
}

function draw_debug_bounds(x, y, width, height, color) {
    // Рисует границы области для отладки
    draw_set_color(color);
    draw_rectangle(x, y, x + width, y + height, false);
    draw_set_color(c_white);
    draw_text(x + 5, y + 5, "x:" + string(x) + " y:" + string(y) + " w:" + string(width) + " h:" + string(height));
}


// УЛУЧШЕННАЯ ФУНКЦИЯ ОТРИСОВКИ ИКОНОК ТИПОВ ПРЕДМЕТОВ
function draw_item_type_icon_improved(x, y, size, item_type, is_hovered) {
    var icon_color = is_hovered ? merge_color(ui_highlight, c_white, 0.3) : ui_highlight;
    
    draw_set_color(icon_color);
    
    switch(item_type) {
        case global.ITEM_TYPE.WEAPON:
            // Стилизованный меч
            draw_rectangle(x + size/2 - 2, y + 5, x + size/2 + 2, y + size - 5, false);
            draw_rectangle(x + 8, y + size - 8, x + size - 8, y + size - 5, false);
            break;
            
        case global.ITEM_TYPE.ARMOR:
            // Стилизованный щит
            draw_rectangle(x + 6, y + 8, x + size - 6, y + size - 6, false);
            draw_rectangle(x + size/2 - 1, y + 6, x + size/2 + 1, y + size - 8, false);
            break;
            
        case global.ITEM_TYPE.POTION:
            // Стилизованное зелье
            draw_rectangle(x + 8, y + 12, x + size - 8, y + size - 4, false);
            draw_rectangle(x + 10, y + 6, x + size - 10, y + 12, false);
            // Пузырьки
            draw_set_color(c_white);
            draw_circle(x + 12, y + 10, 1, true);
            draw_circle(x + size - 12, y + 15, 1, true);
            break;
            
        case global.ITEM_TYPE.ACCESSORY:
            // Стилизованное кольцо
            draw_rectangle(x + 8, y + 8, x + size - 8, y + size - 8, false);
            draw_rectangle(x + 6, y + size/2 - 1, x + size - 6, y + size/2 + 1, false);
            break;
            
        case global.ITEM_TYPE.SCROLL:
            // Свиток
            draw_rectangle(x + 6, y + 8, x + size - 6, y + size - 8, false);
            // Линии текста на свитке
            draw_set_color(c_white);
            for (var i = 0; i < 3; i++) {
                draw_rectangle(x + 8, y + 12 + i * 5, x + size - 8, y + 13 + i * 5, false);
            }
            break;
            
        default:
            // Стандартная иконка
            draw_rectangle(x + 4, y + 4, x + size - 4, y + size - 4, false);
            break;
    }
}
function draw_item_bonuses_compact(x, y, width, item_data, is_hovered) {
    var bonuses = [];
    
    // Собираем бонусы
    if (item_data[? "strength_bonus"] > 0) {
        array_push(bonuses, "💪 +" + string(item_data[? "strength_bonus"]));
    }
    if (item_data[? "defense_bonus"] > 0) {
        array_push(bonuses, "🛡️ +" + string(item_data[? "defense_bonus"]));
    }
    if (item_data[? "intelligence_bonus"] > 0) {
        array_push(bonuses, "🧠 +" + string(item_data[? "intelligence_bonus"]));
    }
    if (item_data[? "agility_bonus"] > 0) {
        array_push(bonuses, "⚡ +" + string(item_data[? "agility_bonus"]));
    }
    
    // Бонусы для зелий
    if (item_data[? "type"] == global.ITEM_TYPE.POTION) {
        if (item_data[? "health"] > 0) {
            array_push(bonuses, "❤️ +" + string(item_data[? "health"]));
        }
        if (item_data[? "temp_strength"] > 0) {
            array_push(bonuses, "💪 +" + string(item_data[? "temp_strength"]));
        }
    }
    
    // Отрисовываем бонусы в компактном формате
    var current_x = x;
    var current_y = y;
    var max_bonuses_per_row = 2;
    
    for (var i = 0; i < array_length(bonuses); i++) {
        if (i > 0 && i mod max_bonuses_per_row == 0) {
            current_x = x;
            current_y += 20;
        }
        
        draw_set_color(ui_text);
        draw_set_font(fnt_small);
        draw_text(current_x, current_y, bonuses[i]);
        
        current_x += string_width(bonuses[i]) + 10;
    }
}

function draw_shop_item_button_improved(x, y, width, height, item_data, index, is_hovered, custom_btn_y = -1) {
    // Используем кастомную позицию Y если задана, иначе вычисляем стандартную
    var btn_y = (custom_btn_y == -1) ? y + height - 35 : custom_btn_y;
    var btn_x = x + 10;
    var btn_width = width - 20;
    var btn_height = 35; // Увеличили высоту кнопки
    
    var can_afford = global.gold >= item_data[? "price"];
    var is_mouse_over_button = point_in_rectangle(mouse_x, mouse_y, btn_x, btn_y, btn_x + btn_width, btn_y + btn_height);
    
    // Цвет кнопки в зависимости от доступности
    var btn_color = can_afford ? ui_success_color : ui_danger;
    var text_color = ui_text;
    
    // Эффекты при наведении
    if (is_mouse_over_button) {
        if (can_afford) {
            btn_color = merge_color(ui_success_color, c_white, 0.3);
            // Анимация пульсации для доступных предметов
            var pulse = sin(global.frame_count * 0.3) * 0.1 + 0.9;
            btn_color = merge_color(btn_color, c_white, pulse * 0.1);
        } else {
            btn_color = merge_color(ui_danger, c_black, 0.2);
        }
    }
    
    // Тень кнопки
    draw_set_color(ui_shadow_color);
    draw_set_alpha(0.3);
    draw_rectangle(btn_x + 2, btn_y + 2, btn_x + btn_width + 2, btn_y + btn_height + 2, false);
    draw_set_alpha(1);
    
    // Градиентный фон кнопки
    for (var i = 0; i < btn_height; i++) {
        var ratio = i / btn_height;
        var gradient_color = merge_color(btn_color, ui_bg_dark, ratio * 0.3);
        draw_set_color(gradient_color);
        draw_rectangle(btn_x, btn_y + i, btn_x + btn_width, btn_y + i + 1, false);
    }
    
    // Верхняя световая полоса для объема
    draw_set_color(c_white);
    draw_set_alpha(0.2);
    draw_rectangle(btn_x, btn_y, btn_x + btn_width, btn_y + 2, false);
    draw_set_alpha(1);
    
    // Рамка кнопки
    draw_set_color(merge_color(btn_color, c_white, 0.2));
    draw_rectangle(btn_x, btn_y, btn_x + btn_width, btn_y + btn_height, true);
    
    // Текст кнопки с эффектами
    draw_set_color(text_color);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    
    var btn_text = can_afford ? "🛒 КУПИТЬ" : "🔒 НЕДОСТАТОЧНО";
    if (can_afford && is_mouse_over_button) {
        btn_text = "👇 " + btn_text + " 👇";
    }
    
    // Легкая тень текста для лучшей читаемости
    draw_set_color(ui_shadow_color);
    draw_set_alpha(0.5);
    draw_text(btn_x + btn_width/2 + 1, btn_y + btn_height/2 + 1, btn_text);
    draw_set_alpha(1);
    
    draw_set_color(text_color);
    draw_text(btn_x + btn_width/2, btn_y + btn_height/2, btn_text);
    
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    
    
}

function draw_abilities_tab(x, y, width, height) {
    draw_set_color(ui_bg_dark);
    draw_rectangle(x, y, x + width, y + height, false);
    
    draw_set_color(ui_text);
    draw_set_halign(fa_center);
    draw_text(x + width/2, y + 20, "СПОСОБНОСТИ ГЕРОЯ");
    draw_set_halign(fa_left);
    
    // Информация о мане и очках навыков
    draw_set_color(ui_highlight);
    draw_text(x + 20, y + 50, "Мана: " + string(floor(global.hero.mana)) + "/" + string(global.hero.max_mana));
    draw_set_color(ui_text);
    draw_text(x + 200, y + 50, "Очки навыков: " + string(global.hero.skill_points));
    
    // Сброс массива кнопок способностей
    global.ability_buttons = [];
    
    var ability_width = 350;
    var ability_height = 120;
    var start_x = x + 20;
    var start_y = y + 80;
    var spacing = 20;
    
    for (var i = 0; i < array_length(global.abilities_database); i++) {
        var ability = global.abilities_database[i];
        var column = i mod 2;
        var row = i div 2;
        
        var ability_x = start_x + column * (ability_width + spacing);
        var ability_y = start_y + row * (ability_height + spacing);
        
        // Проверяем, чтобы не выйти за границы
        if (ability_y + ability_height > y + height - 50) continue;
        
        var is_learned = ability_is_learned(ability.id);
        var can_learn = !is_learned && global.hero.level >= ability.level_required;
        var can_use = is_learned && (ability.type == global.ABILITY_TYPE.ACTIVE || ability.type == global.ABILITY_TYPE.ULTIMATE);
        var is_hovered = point_in_rectangle(mouse_x, mouse_y, ability_x, ability_y, ability_x + ability_width, ability_y + ability_height);
        
        // Фон способности в зависимости от типа
        var bg_color = ability.color;
        if (!is_learned) {
            bg_color = merge_color(ui_bg_medium, ui_bg_dark, 0.5);
        }
        
        draw_set_color(bg_color);
        draw_rectangle(ability_x, ability_y, ability_x + ability_width, ability_y + ability_height, false);
        
        // Рамка в зависимости от типа
        var border_color = ui_border_color;
        if (ability.type == global.ABILITY_TYPE.ULTIMATE) {
            border_color = merge_color(ui_danger, c_yellow, 0.5);
        } else if (ability.type == global.ABILITY_TYPE.ACTIVE) {
            border_color = ui_highlight;
        }
        
        draw_set_color(is_hovered ? merge_color(border_color, c_white, 0.2) : border_color);
        draw_rectangle(ability_x, ability_y, ability_x + ability_width, ability_y + ability_height, true);
        
        // Иконка и название
        draw_set_color(ui_text);
        draw_text(ability_x + 10, ability_y + 10, ability.icon + " " + ability.name);
        
        // Тип способности
        var type_text = "";
        switch(ability.type) {
            case global.ABILITY_TYPE.PASSIVE: type_text = "Пассивная"; break;
            case global.ABILITY_TYPE.ACTIVE: type_text = "Активная"; break;
            case global.ABILITY_TYPE.ULTIMATE: type_text = "УЛЬТИМАТИВНАЯ"; break;
        }
        draw_set_color(ui_text_secondary);
        draw_text(ability_x + ability_width - 100, ability_y + 10, type_text);
        
        // Описание
        draw_set_color(ui_text_secondary);
        draw_set_font(fnt_small);
        draw_text_ext(ability_x + 10, ability_y + 35, ability.description, ability_width - 20, 40);
        draw_set_font(fnt_main);
        
        // Требования и стоимость
        var info_y = ability_y + 80;
        draw_set_color(ui_text);
        draw_text(ability_x + 10, info_y, "Ур. " + string(ability.level_required));
        
        if (ability.mana_cost > 0) {
            draw_text(ability_x + 80, info_y, "Мана: " + string(ability.mana_cost));
        }
        
        if (ability.cooldown > 0) {
            var cooldown_sec = ability.cooldown / 60;
            draw_text(ability_x + 180, info_y, "Перезарядка: " + string(cooldown_sec) + "с");
        }
        
        // Статус и кнопки
        var status_x = ability_x + ability_width - 120;
        if (is_learned) {
            if (can_use) {
                var cooldown_remaining = get_ability_cooldown(ability.id);
                if (cooldown_remaining > 0) {
                    draw_set_color(ui_danger);
                    draw_text(status_x, info_y, "Перезарядка: " + string(ceil(cooldown_remaining / 60)) + "с");
                } else {
                    draw_set_color(ui_success_color);
                    draw_text(status_x, info_y, "Готово к использованию");
                    
                    // Кнопка использования
                    array_push(global.ability_buttons, {
                        type: "use_ability",
                        ability_id: ability.id,
                        x1: ability_x, y1: ability_y,
                        x2: ability_x + ability_width, y2: ability_y + ability_height
                    });
                }
            } else {
                draw_set_color(ui_success_color);
                draw_text(status_x, info_y, "Изучено");
            }
        } else {
            if (can_learn) {
                draw_set_color(ui_highlight);
                draw_text(status_x, info_y, "Доступно для изучения");
                
                // Кнопка изучения
                array_push(global.ability_buttons, {
                    type: "learn_ability",
                    ability_id: ability.id,
                    x1: ability_x, y1: ability_y,
                    x2: ability_x + ability_width, y2: ability_y + ability_height
                });
            } else {
                draw_set_color(ui_danger);
                draw_text(status_x, info_y, "Недоступно");
            }
        }
    }
    
    // Если способностей нет
    if (array_length(global.abilities_database) == 0) {
        draw_set_color(ui_text_secondary);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_text(x + width/2, y + height/2, "Способности пока не доступны");
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
    }
    
    // Подсказки внизу
    var hint_y = y + height - 30;
    draw_set_color(ui_text_secondary);
    draw_set_halign(fa_center);
    draw_text(x + width/2, hint_y, "🟢 Пассивные - действуют постоянно | 🔵 Активные - требуют активации | 🟡 Ультимативные - мощные с долгой перезарядкой");
    draw_set_halign(fa_left);
}