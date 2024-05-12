function InputManager() : Component() constructor {

    configurations = [];
    currentConfig = "";
    listening = false;
    keysReleased = false;

    #region PRIVATE ATTRIBUTES AND METHODS TO MANAGE THE STRUCT
        
		static Create = function() {
			ConfigurationOfInputs();
		}
		
		static DrawGUIEnd = function() {
			// Last checked input was keyboard or mouse
			if (keyboard_check_pressed(vk_anykey) ||
			point_distance(mouse_screen_x_previous, mouse_screen_y_previous, mouse_screen_x, mouse_screen_y) ||
			MouseGetKey()!=-1)
				keyboard_or_gamepad = 0;
				
			// Last checked input was a gamepad
			if (GamepadGetKey()!=-1) {
				keyboard_or_gamepad = 1;
			}
			
			// Update the mouse_x_previous and mouse_y_previous macros
			mouse_x_previous = mouse_x;
			mouse_y_previous = mouse_y;
			mouse_screen_x_previous = mouse_screen_x;
			mouse_screen_y_previous = mouse_screen_y;
		}
		
        static StepBegin = function() {
        	// Update every input
        	for (var i = 0; i < array_length(configurations); i++)
        		configurations[i].Update();
        };
        
        static GetConfiguration= function(config) {
        	for (var i = 0; i < array_length(configurations); i++) {
        		if ( configurations[i].name == config ) {
        			return configurations[i];
        		}
        	}
        	return -1;
        };
        
        static GetKeys = function(configuration) {
        	var newConf = GetConfiguration(configuration);
        	
        	if ( newConf != -1 )
        		return newConf.GetKeys();
        	return -1;
        };
        
        static toString = function(tab="") {
            var str = tab + "InputManager [\n";
        	for(var i=0;i<array_length(configurations);i++) {
        		str += tab + configurations[i].toString(tab + "\t") + "\n";
        	}
        	str += tab + "]";
        	
        	return str;
        };
    
    #endregion
 
    #region MODIFIERS
    
        static AddConfiguration = function(config) {
        	var newConf = GetConfiguration(config);
        	if ( newConf == -1 ) configurations[array_length(configurations)] = new InputConfiguration(config);
        	currentConfig = config;	
        }
    
        static SetConfiguration = function(config) {
        	var newConf = GetConfiguration(config);
        	if ( newConf != -1 ) {
				currentConfig = config;
			}
        };
        
        static AddInstance = function(input, long_press_time=LONG_PRESS_TIME, double_tap_time=DOUBLE_TAP_TIME, repeated_time=REPEATED_TIME) {				
        	var config = GetConfiguration(currentConfig);
        	if ( config != -1 )
        		config.AddInstance(input, long_press_time, double_tap_time, repeated_time);
        };
        
        static AddKey = function(input, key, device = -1) {
			if ( device == -1 ) {
				for (var i = 0; i < gamepad_get_device_count(); i++) {
					if (gamepad_is_connected(i)) {
						device = i;
						break;
					}
				}
			}
        	var config = GetConfiguration(currentConfig);
        	if ( config != -1 )
        		config.AddKey(input, key, device);
        };
        	
        static DeleteConfiguration = function(input) {
        	var len = array_length(configurations);
        	for(var i=0;i<len;i++) {
        		var config = configurations[i];
        		if (config.name == input) {
        			config.FreeInstances();
        			delete config;
        			for(var j=i+1;j<len;j++) {
        				configurations[j-1] = configurations[j];
        			}
        			array_resize(configurations, len-1);
        			return;
        		}
        	}
        };
        	
        static DeleteAllConfigurations = function() {
        	for( var i=array_length(configurations)-1 ; i>=0 ; i-- ) {
        		DeleteConfiguration(configurations[i].name);
        	}
        };
        
        static Save = function() {
        	var file = file_text_open_write(FILE_NAME);
        	
        	for(var i=0;i<array_length(configurations);i++) {
        		configurations[i].Save(file);
        	}
        			
        	file_text_close(file);
        };
        
        static Load = function() {
        	if ( !file_exists(FILE_NAME) ) return -1;
        	
        	var file = file_text_open_read(FILE_NAME);
        		
        	while(!file_text_eof(file)) {
        		var line = StringSplit(file_text_read_string(file), ";");
        		file_text_readln(file);
        		
        		var lastInst;
        			
        		switch(line[0]) {
        			case "c": SetConfiguration(line[1]); break;
        			case "i": AddInstance(line[1], real(line[2]), real(line[3])); lastInst = line[1]; break;
        			case "k": AddKey(lastInst, StringToKey(line[1]), real(line[2])); break;
        		}
        	}
        			
        	file_text_close(file);
        	return 1;
        };
        
        static ChangeKey = function(key, accept, cancel, bannedKeys = []) {
            if ( !listening ) {
            	if ( accept ) { 
            	    listening = true;
            	    keysReleased = false;
            	}
            } else {
                if ( cancel ) { 
                    listening = false;
                } else {
                    var newKey = GetCurrentKey();
                    if ( newKey == -1 ) {
                        keysReleased = true;
                    } else {
                		if ( keysReleased && !IsIn(newKey[0], bannedKeys)) {
            				key.init(newKey[0], newKey[1]);
            				listening = false;
                		}
                    }
                }
        	}
        };
        
    #endregion

    #region CHECKERS
    
    	static _CheckGeneral = function(input, config, type) {
        	if (!is_array(config)) config = [config];
        	
			var inputVal = false;
			
        	for(var c=0; c<array_length(config); c++) {
	        	var newConf = GetConfiguration(config[c]);
	        	if ( newConf != -1 )
	        		inputVal = max(inputVal, newConf.Check(input, type));
        	}
        	
        	return inputVal;
    	}
    
        static Check = function(input, config=currentConfig) {
        	return _CheckGeneral(input, config, "hold");
        };
        
        static CheckPressed = function(input, config=currentConfig) {
        	return _CheckGeneral(input, config, "pressed");
        };
        
        static CheckReleased = function(input, config=currentConfig) {
        	return _CheckGeneral(input, config, "released");
        };
        
        static CheckLong = function(input, config=currentConfig) {
        	return _CheckGeneral(input, config, "long");
        };
        
        static CheckLongPressed = function(input, config=currentConfig) {
        	return _CheckGeneral(input, config, "longpressed");
        };
        
        static CheckLongReleased = function(input, config=currentConfig) {
        	return _CheckGeneral(input, config, "longreleased");
        };
        
        static CheckDouble = function(input, config=currentConfig) {
        	return _CheckGeneral(input, config, "double");
        };
        
        static CheckRepeated = function(input, config=currentConfig) {
        	return _CheckGeneral(input, config, "repeated");
        };
        
        static CheckRepeatedLong = function(input, config=currentConfig) {
        	return _CheckGeneral(input, config, "repeatedlong");
        };
        
        static CheckValue = function(input, config=currentConfig) {
        	return _CheckGeneral(input, config, "value");
        };
        
    #endregion
    
}