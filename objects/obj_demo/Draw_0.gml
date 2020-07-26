
Print(Input.Check("Right", "Gamermode"))

if Input.CheckPressed("MenuOpen", "Menu") {
    menu_open = !menu_open;
}

if (menu_open) {
    dir = Input.CheckRepeated("Down", "Menu") - Input.CheckRepeated("Up", "Menu");
    dir2 = Input.CheckRepeated("Right", "Menu") - Input.CheckRepeated("Left", "Menu");
    
    inputSelected = Input.Draw("GamerMode", dir, dir2, drawfunc);
    
    if (Input.CheckPressed("Enter", "Menu")) {
        Input.ChangeKey(inputSelected, KEY.ESCAPE, KEY.BACKSPACE, Input.GetKeys("Menu"));
    }
}

var d = Input.CheckDirection("Direction");
var xdir = d[0];
var ydir = d[1];
var r = 4;
x = clamp(x+xdir, r, room_width-r);
y = clamp(y+ydir, r, room_height-r);

draw_circle(x, y, 4, false);