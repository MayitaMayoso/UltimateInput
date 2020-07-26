Input.Print();

drawfunc = function(input, key, i, j, selected, listening) {
    if ( j== 0 ) draw_text(10*(j+1), 10+20*i, input);
    if ( !selected ) {
        draw_text(190*(j+1), 10+20*i, key);
    } else {
        if ( !listening ) {
            draw_text(190*(j+1), 5*sin(current_time/100) + 10+20*i, key);
        } else {
            draw_text_colour(190*(j+1), 5*sin(current_time/100) + 10+20*i, key, c_orange, c_orange, c_orange, c_orange, 1);
        }
    }
}

menu_open = false;
x = room_width/2;
y = room_height/2;