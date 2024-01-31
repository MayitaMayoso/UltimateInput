vertex_format_begin();
vertex_format_add_position_3d();
vertex_format_add_texcoord();
format = vertex_format_end();

buffer = vertex_create_buffer();
vertex_begin(buffer, format);
vertex_position_3d(buffer, 0, 0, 0);
vertex_texcoord(buffer, 0, 0);

vertex_position_3d(buffer, room_width, 0, 0);
vertex_texcoord(buffer, 1, 0);

vertex_position_3d(buffer, 0, room_height, 0);
vertex_texcoord(buffer, 0, 1);

vertex_position_3d(buffer, room_width, room_height, 0);
vertex_texcoord(buffer, 1, 1);

vertex_end(buffer);

sceneSurface = surface_create(room_width, room_height);

layer_script_begin("LogoText", scr_scene1_draw_begin);
layer_script_begin("TilesDestroyed", scr_scene1_draw_begin);
layer_script_begin("Tiles", scr_scene1_draw_begin);
layer_script_begin("Lava", scr_scene1_draw_begin);
layer_script_end("LogoText", scr_scene1_draw_end);
layer_script_end("TilesDestroyed", scr_scene1_draw_end);
layer_script_end("Tiles", scr_scene1_draw_end);
layer_script_end("Lava", scr_scene1_draw_end);