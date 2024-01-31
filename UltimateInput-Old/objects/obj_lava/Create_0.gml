uni_noiseMap = shader_get_sampler_index(sh_lava, "displacementMap");
uni_time = shader_get_uniform(sh_lava, "time");
tex_lava = sprite_get_texture(spr_perlin_noise, 0);
gpu_set_texrepeat(true);