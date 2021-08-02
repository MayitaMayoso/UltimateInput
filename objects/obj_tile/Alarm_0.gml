repeat(1)
for(var i=0; i<sprite_get_number(spr_broken_tile); i++) {
    var part = instance_create_depth(x, y, depth, obj_broken_tile);
    part.layer = layer;
    part.image_index = i;
    part.image_blend = image_blend;
    part.image_xscale = image_xscale;
    part.image_yscale = image_yscale;
}
instance_destroy();