shader_set(sh_lava);
texture_set_stage(uni_noiseMap, tex_lava);
shader_set_uniform_f(uni_time, current_time/1000);

//draw_sprite_tiled_ext(spr_lava, 0, current_time/50, current_time/50, .5, .5, c_white, 1);
draw_self();

shader_reset();