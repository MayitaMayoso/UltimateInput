
x = xstart + Wave(-5, 5, 20000, rand) + random_range(-shake, shake);
y = ystart + Wave(-5, 5, 10000, rand) + random_range(-shake, shake);
image_angle = Wave(-2, 2, 20000, rand) + random_range(-shake, shake);


if (Input.CheckPressed("TileDestroy")) {
    shake = 7;
}

shake = max(0, shake-damp);