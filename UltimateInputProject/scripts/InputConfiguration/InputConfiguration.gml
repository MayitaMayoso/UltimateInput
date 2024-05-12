function InputConfiguration(LoadFromDisk = false) {
    // If there is a previous configuration load it and skip all these steps
    if (LoadFromDisk && !Input.Load()) exit;
    
    // Default		
    Input.AddProfile("Default");
    Input.AddInstance("SwitchMode");
    Input.AddKey("SwitchMode", KEY.SPACE);
    
    // Player 1
    Input.AddProfile("Player1");

    Input.AddInstance("Up");
    Input.AddInstance("Down");
    Input.AddInstance("Left");
    Input.AddInstance("Right");
    
    Input.AddKey("Up", KEY.W);
    Input.AddKey("Down", KEY.S);
    Input.AddKey("Left", KEY.A);
    Input.AddKey("Right", KEY.D);		
    
    Input.AddKey("Up", KEY.UP_ARROW);
    Input.AddKey("Down", KEY.DOWN_ARROW);
    Input.AddKey("Left", KEY.LEFT_ARROW);
    Input.AddKey("Right", KEY.RIGHT_ARROW);
    
    // Player 2
    Input.AddProfile("Player2");

    Input.AddInstance("Up");
    Input.AddInstance("Down");
    Input.AddInstance("Left");
    Input.AddInstance("Right");
    
    Input.AddKey("Up", KEY.LEFT_JOYSTICK_UP, 4);
    Input.AddKey("Down", KEY.LEFT_JOYSTICK_DOWN);
    Input.AddKey("Left", KEY.LEFT_JOYSTICK_LEFT);
    Input.AddKey("Right", KEY.LEFT_JOYSTICK_RIGHT);
    
    Input.AddKey("Up", KEY.PAD_UP);
    Input.AddKey("Down", KEY.PAD_DOWN);
    Input.AddKey("Left", KEY.PAD_LEFT);
    Input.AddKey("Right", KEY.PAD_RIGHT);
    
    // Save all the profiles
    Input.Save();
}