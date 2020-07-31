// If there is a previous configuration load it and skip all these steps
//if (Input.Load()) exit;

// Default configuration
Input.SetConfiguration("Menu");

Input.AddInstance("Up");
Input.AddInstance("Down");
Input.AddInstance("Left");
Input.AddInstance("Right");
Input.AddInstance("Enter");
Input.AddInstance("MenuOpen");

Input.AddKey("Up", KEY.UP_ARROW);
Input.AddKey("Down", KEY.DOWN_ARROW);
Input.AddKey("Left", KEY.LEFT_ARROW);
Input.AddKey("Right", KEY.RIGHT_ARROW);
Input.AddKey("Enter", KEY.ENTER);
Input.AddKey("MenuOpen", KEY.M);

// Other configuration
Input.SetConfiguration("GamerMode");

Input.AddInstance("Up", 0.5);
Input.AddInstance("Down");
Input.AddInstance("Left");
Input.AddInstance("Right");

Input.AddKey("Up", KEY.W);
Input.AddKey("Down", KEY.S);
Input.AddKey("Left", KEY.A);
Input.AddKey("Right", KEY.D);

Input.AddKey("Up", KEY.LEFT_JOYSTICK_UP);
Input.AddKey("Down", KEY.LEFT_JOYSTICK_DOWN);
Input.AddKey("Left", KEY.LEFT_JOYSTICK_LEFT);
Input.AddKey("Right", KEY.LEFT_JOYSTICK_RIGHT);

// Save all the profiles
Input.Save();