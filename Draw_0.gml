// =============================================================================
// MAIN ROOM CONTROLLER - Draw Event
// =============================================================================
if (global.aty_high_res && surface_exists(global.aty_render_surface)) {
    surface_set_target(global.aty_render_surface);
    
    draw_clear_alpha(global.aty_colors.bg_dark, 1);
    aty_draw_ui_high_res();

    surface_reset_target();
    
    gpu_set_tex_filter(true);
    draw_surface_stretched(global.aty_render_surface, 0, 0, room_width, room_height);
} else {
    return;
}
