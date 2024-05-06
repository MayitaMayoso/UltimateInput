function ConfigurationOfInputs(LoadFromDisk = false) {
    // If there is a previous configuration load it and skip all these steps
    if (LoadFromDisk && !Input.Load()) exit;

    #region GAME CONTROLS
        
		// Default		
        Input.AddConfiguration("Default");
        Input.AddInstance("SwitchMode");
		Input.AddKey("SwitchMode", KEY.SPACE);
		
        // Player
        Input.AddConfiguration("Keyboard1");
    
        Input.AddInstance("Up");
        Input.AddInstance("Down");
        Input.AddInstance("Left");
        Input.AddInstance("Right");
		
		Input.AddKey("Up", KEY.W);
		Input.AddKey("Down", KEY.S);
		Input.AddKey("Left", KEY.A);
		Input.AddKey("Right", KEY.D);		
		
        Input.AddConfiguration("Keyboard2");
    
        Input.AddInstance("Up");
        Input.AddInstance("Down");
        Input.AddInstance("Left");
        Input.AddInstance("Right");
		
		Input.AddKey("Up", KEY.UP_ARROW);
		Input.AddKey("Down", KEY.DOWN_ARROW);
		Input.AddKey("Left", KEY.LEFT_ARROW);
		Input.AddKey("Right", KEY.RIGHT_ARROW);
    
    #endregion
    
    // Save all the profiles
    Input.Save();
}