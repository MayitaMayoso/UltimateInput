// Set the configuration you are using
currentInputConfig = Input.CheckPressed("SwitchMode", "Default")
	? !currentInputConfig
	: currentInputConfig;
Input.SetProfile(inputConfigurations[currentInputConfig]);

// Get the inputs
var hdir = Input.Check("Right") - Input.Check("Left");
var vdir = Input.Check("Down") - Input.Check("Up");

// Normalize the directions
var dir = point_direction(0, 0, hdir, -vdir);
var dist = point_distance(0, 0, hdir, -vdir);

hdir = dcos(dir) * dist;
vdir = dsin(dir) * dist;

// Move the character
var spd = 10;
x += spd * hdir;
y += spd * vdir;
