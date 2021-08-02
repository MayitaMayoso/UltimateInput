surface_reset_target();
shader_set(sh_scene);

vertex_submit(buffer, pr_trianglestrip, surface_get_texture(sceneSurface));

matrix_set(matrix_world, matrix_build(0, 0, -room_width, 0, 90, 0, 1, 1, 1));
vertex_submit(buffer, pr_trianglestrip, surface_get_texture(sceneSurface));

matrix_set(matrix_world, matrix_build(room_width, 0, 0, 0, -90, 0, 1, 1, 1));
vertex_submit(buffer, pr_trianglestrip, surface_get_texture(sceneSurface));

matrix_set(matrix_world, matrix_build(room_width, 0, -room_width, 0, 180, 0, 1, 1, 1));
vertex_submit(buffer, pr_trianglestrip, surface_get_texture(sceneSurface));

matrix_set(matrix_world, matrix_build_identity());


shader_reset();











