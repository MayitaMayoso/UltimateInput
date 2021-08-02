if (falling) {
    x += spd*dcos(dir);
    y += spd*dsin(dir);
    image_angle+= rspd;
    spd /= 1.1;
    rspd /= 1.1;
    //depth -= spd;
    image_xscale += spd/100;
    image_yscale += spd/100;
    var g = 155+100*max(0, 1-image_xscale);
    image_blend = make_color_rgb(g,g,g);
}