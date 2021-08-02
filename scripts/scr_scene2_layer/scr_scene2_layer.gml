function scr_scene2_draw_begin(){
	if (event_type == ev_draw)   {
		if (event_number == 0) {
			if (!surface_exists(obj_scene2_controller.sceneSurface))
			obj_scene2_controller.sceneSurface = surface_create(room_width, room_height);
			
			surface_set_target(obj_scene2_controller.sceneSurface);
		}
	}
};

function scr_scene2_draw_end(){
	if (event_type == ev_draw) {
		if (event_number == 0) {
			surface_reset_target();
			shader_set(sh_scene);
			
			matrix_set(matrix_world, matrix_build(room_width, 0, 0, 0, -90, 0, 1, 1, 1));
			vertex_submit(obj_scene2_controller.buffer, pr_trianglestrip, surface_get_texture(obj_scene2_controller.sceneSurface));
			
			matrix_set(matrix_world, matrix_build(room_width, 0, -room_width, 0, 180, 0, 1, 1, 1));
			vertex_submit(obj_scene2_controller.buffer, pr_trianglestrip, surface_get_texture(obj_scene1_controller.sceneSurface));
			
			matrix_set(matrix_world, matrix_build(0, 0, -room_width, 0, 90, 0, 1, 1, 1));
			vertex_submit(obj_scene2_controller.buffer, pr_trianglestrip, surface_get_texture(obj_scene2_controller.sceneSurface));
			
			matrix_set(matrix_world, matrix_build_identity());
			
			
			shader_reset();
		}
   	}
};