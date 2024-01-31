
Destroy = function() {
    falling = true;
    alarm[0] = 50;
    layer = layer_get_id("TilesDestroyed");
};

falling = false;
dir = random(360);
spd = random_range(5, 10);
rspd = (irandom(1)*2-1) * random_range(30, 35);