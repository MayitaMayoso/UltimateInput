// End game
if (keyboard_check(vk_escape)) game_end();

// Update the structs of port and view
port.Update();
view.Update();

// Shake Effect!
if (Input.CheckPressed("TileDestroy")) {
	shake = 5;
}

shake = max(0, shake-damp);
view.x = room_width/2 + random_range(-shake, shake);
view.y = room_height/2 + random_range(-shake, shake);
view.z = -room_width/2 + random_range(-shake, shake);

if (Input.CheckPressed("NextScene")) {
    scene = Modulo(scene+1, array_length(sceneCam));
}

view.xto = lerp(view.xto, sceneCam[scene][0], 0.15);
view.yto = lerp(view.yto, sceneCam[scene][1], 0.15);
view.zto = lerp(view.zto, sceneCam[scene][2], 0.15);
view.xup = lerp(view.xup, sceneCam[scene][3], 0.15);
view.yup = lerp(view.yup, sceneCam[scene][4], 0.15);
view.zup = lerp(view.zup, sceneCam[scene][5], 0.15);