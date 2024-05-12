function InputKey(key, device) constructor {
	static init = function(key, device) {
		self.key = key;
		self.device = device;
		self.keyCode = KeyTrueCode(self.key);
		self.origin = undefined;
		self.Check = InputCallbackDefault;
		
		// GET INPUT ORIGIN
		if ( self.key < KEY.A ) self.origin = "SPECIAL";
		else if ( self.key < KEY.SHIFT_LEFT ) self.origin = "KEYBOARD";
		else if ( self.key < KEY.LEFT_CLICK ) self.origin = "KEYBOARD_DIRECT";
		else if ( self.key < KEY.WHEEL_UP ) self.origin = "MOUSE_BUTTON";
		else if ( self.key < KEY.MOUSE_UP ) self.origin = "MOUSE_WHEEL";
		else if ( self.key < KEY.FACE1 ) self.origin = "MOUSE_POSITION";
		else if ( self.key < KEY.LEFT_TRIGGER ) self.origin = "GAMEPAD_BUTTON";
		else if ( self.key < KEY.LEFT_JOYSTICK_DOWN ) self.origin = "TRIGGER";
		else if ( self.key < KEY.LEFT_JOYSTICK_UP ) self.origin = "JOYSTICK_POSITIVE";
		else self.origin = "JOYSTICK_NEGATIVE";
		
		// Check for dualsense controller
		if ( gamepad_get_description(self.device) == "Wireless Controller" ) {
			if (self.key == KEY.RIGHT_JOYSTICK_UP )
				self.origin = "JOYSTICK_NEGATIVE_PS5"
			if (self.key == KEY.RIGHT_JOYSTICK_DOWN )
				self.origin = "JOYSTICK_POSITIVE_PS5"
		}
		
		// ASSIGN CALLBACK FUNCTIONS
		switch(self.origin) {
			case "SPECIAL":
				self.Check = (self.key == KEY.ANY)?InputCallbackSpecialAny:InputCallbackSpecialNone;
				break;
			case "KEYBOARD":
				self.Check = InputCallbackKeyboardCheck;
				break;
			case "KEYBOARD_DIRECT":
				self.Check = InputCallbackKeyboardCheckDirect;
				break;
			case "MOUSE_BUTTON":
				self.Check = InputCallbackMouseCheck;
				break;
			case "MOUSE_WHEEL":
				self.Check = ( self.key == KEY.WHEEL_UP)?InputCallbackMouseWheelUp:InputCallbackMouseWheelDown;
				break;
			case "MOUSE_POSITION":
				if (self.key == KEY.MOUSE_UP) self.Check = InputCallbackMouseUp;
				if (self.key == KEY.MOUSE_DOWN) self.Check = InputCallbackMouseDown;
				if (self.key == KEY.MOUSE_LEFT) self.Check = InputCallbackMouseLeft;
				if (self.key == KEY.MOUSE_RIGHT) self.Check = InputCallbackMouseRight;
				break;
			case "GAMEPAD_BUTTON":
				self.Check = InputCallbackGamepadCheck;
				break;
			case "TRIGGER":
				self.Check = InputCallbackGamepadTrigger;
				break;
			case "JOYSTICK_POSITIVE":
				self.Check = InputCallbackGamepadJoystickPositive;
				break;
			case "JOYSTICK_NEGATIVE":
				self.Check = InputCallbackGamepadJoystickNegative;
				break;
			case "JOYSTICK_POSITIVE_PS5":
				self.Check = InputCallbackGamepadJoystickPositivePS5;
				break;
			case "JOYSTICK_NEGATIVE_PS5":
				self.Check = InputCallbackGamepadJoystickNegativePS5;
				break;
			default:
				self.Check = InputCallbackDefault;
		}
	};
	
	static Save = function(file) {
		file_text_write_string(file, "k;" + KeyToString(self.key) + ";" + string(self.device) + "\n");
	};
	
	static toString = function(tab="") {
	    return tab + "Key:" + KeyToString(key);
	}
	
	// KEY CHECKING CALLBACK FUNCTIONS
	#region		
		// SPECIAL
		static InputCallbackDefault = function() { return false; };
		static InputCallbackSpecialAny = function() { return GetCurrentKey() != -1; };
		static InputCallbackSpecialNone = function() { return GetCurrentKey() == -1; };
		// KEYBOARD
		static InputCallbackKeyboardCheck = function() { return keyboard_check(self.keyCode); };
		
		// KEYBOARD DIRECT
		static InputCallbackKeyboardCheckDirect = function() { return keyboard_check_direct(self.keyCode); };
		
		// MOUSE_BUTTON
		static InputCallbackMouseCheck = function() { return mouse_check_button(self.keyCode); };
	
		// MOUSE_WHEEL
		static InputCallbackMouseWheelUp = function() { return mouse_wheel_up(); };
		static InputCallbackMouseWheelDown = function() { return mouse_wheel_down(); };
		
		// MOUSE_POSITION
		static InputCallbackMouseUp = function() {
			var w = window_get_width()/2;
			var h = window_get_height()/2;
			return max(h-mouse_screen_y, 0)/min(w, h);
		};
		static InputCallbackMouseDown = function() {
			var w = window_get_width()/2;
			var h = window_get_height()/2;
			return max(mouse_screen_y-h, 0)/min(w, h)
		};
		static InputCallbackMouseLeft = function() {
			var w = window_get_width()/2;
			var h = window_get_height()/2;
			return max(w-mouse_screen_x, 0)/min(w, h);
		};
		static InputCallbackMouseRight = function() {
			var w = window_get_width()/2;
			var h = window_get_height()/2;
			return max(mouse_screen_x-w, 0)/min(w, h);
		};
	
		// GAMEPAD_BUTTON
		static InputCallbackGamepadCheck = function() { return gamepad_button_check(self.device, self.keyCode); };
	
		// GAMEPAD_STICK
		static InputCallbackGamepadTrigger = function() { return gamepad_button_value(self.device, self.keyCode); };
		static InputCallbackGamepadJoystickPositive = function() {
			return max(GamepadAxisValue(self.device, self.keyCode), 0);
		};
		static InputCallbackGamepadJoystickNegative = function() {
			return abs(min(GamepadAxisValue(self.device, self.keyCode), 0));
		};
		static InputCallbackGamepadJoystickPositivePS5 = function() {
			return max(GamepadAxisValue(self.device, 5), 0);
		};
		static InputCallbackGamepadJoystickNegativePS5 = function() {
			return abs(min(GamepadAxisValue(self.device, 5), 0));
		};
		
	#endregion
	
	init(key, device);
};