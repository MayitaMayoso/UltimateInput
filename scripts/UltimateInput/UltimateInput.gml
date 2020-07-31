#macro Input (GetInputManager())

#macro ANALOGUE_THRESHOLD 0.1
#macro LONG_PRESS_TIME 500
#macro DOUBLE_TAP_TIME 300
#macro REPEATED_TIME 300
#macro FILE_NAME ("CONFIGURATION.data")

enum KEY {
	// THE EMPTY KEY
	EMPTY,
	
	// SPECIAL
	ANY, NONE,
	
	// KEYBOARD
	A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z,
	ZERO, ONE, TWO, THREE, FOUR, FIVE, SIX, SEVEN, EIGHT, NINE,
	LEFT_ARROW, RIGHT_ARROW, UP_ARROW, DOWN_ARROW,
	ENTER, BACKSPACE, SPACE, TAB, ESCAPE,
	HOME, END, DELETE, INSERT, PAGEUP, PAGEDOWN, PAUSE, PRINTSCREEN,
	F1, F2, F3, F4, F5, F6, F7, F8, F9, F10, F11, F12,
	NUMPAD0, NUMPAD1, NUMPAD2, NUMPAD3, NUMPAD4, NUMPAD5, NUMPAD6, NUMPAD7, NUMPAD8, NUMPAD9,
	MULTIPLY, DIVIDE, ADD, SUBSTRACT, DECIMAL,
	
	// KEYBOARD DIRECT
	SHIFT_LEFT, SHIFT_RIGHT, CONTROL_LEFT, CONTROL_RIGHT, ALT_LEFT, ALT_RIGHT,
	
	// MOUSE
	LEFT_CLICK, RIGHT_CLICK, MIDDLE_CLICK, WHEEL_UP, WHEEL_DOWN,
	
	// GAMEPAD
	FACE1, FACE2, FACE3, FACE4,
	LEFT_SHOULDER, RIGHT_SHOULDER,
	SELECT, START,
	LEFT_JOYSTICK_CLICK, RIGHT_JOYSTICK_CLICK,
	PAD_UP, PAD_DOWN, PAD_LEFT, PAD_RIGHT,
	
	// ANALOGUE
	LEFT_TRIGGER, RIGHT_TRIGGER,
	LEFT_JOYSTICK_DOWN, LEFT_JOYSTICK_RIGHT, RIGHT_JOYSTICK_DOWN, RIGHT_JOYSTICK_RIGHT,
	LEFT_JOYSTICK_UP, LEFT_JOYSTICK_LEFT, RIGHT_JOYSTICK_UP, RIGHT_JOYSTICK_LEFT

}

function GetInputManager() {
	static manager = {
		#region PRIVATE ATTRIBUTES AND METHODS TO MANAGE THE STRUCT
			configurations: [new InputConfiguration("default")],
			currentConfig: "default",
			selector : 0,
			selector2 : 0, 
			listening: false,
			key2listen : undefined,
			cancelInput : -1,
			emptyInput : -1,
			denyList : undefined,
		
			Update: function() {
				// Update every input
				for (var i = 0; i < array_length(configurations); i++) {
					configurations[i].Update();
				}
				
				listen();
			},
			
			listen: function() {
				if ( listening ) {
					var newKey = GetCurrentKey(key2listen.type);
					
					if ( newKey != -1 ) {
						if ( newKey == cancelInput ) {
							listening = false;
							key2listen = undefined;
							cancelInput = -1;
							emptyInput = -1;
						} else {
							var dev = 0;
							if is_array(newKey) {
								dev = newKey[1];
								newKey = newKey[0];
							}
						
							if ( !ValueInArray(denyList, newKey) ) {
								if ( newKey != emptyInput ) {
									key2listen.init(newKey, dev);
								} else {
									key2listen.init(KEY.EMPTY);
								}
								listening = false;
								key2listen = undefined;
								cancelInput = -1;
								emptyInput = -1;
							}
						}
					}
				}
			},
			
			GetConfiguration: function(config) {
				for (var i = 0; i < array_length(configurations); i++) {
					if ( configurations[i].name == string_upper(config) ) {
						return configurations[i];
					}
				}
				return -1;
			},
		#endregion
			
		#region MODIFIERS
			SetConfiguration: function(config) {
				var newConf = GetConfiguration(config);
				if ( newConf == -1 ) configurations[array_length(configurations)] = new InputConfiguration(config);
				currentConfig = config;	
			},
		
			AddInstance: function(input, analogue_threshold, long_press_time, double_tap_time, repeated_time) {				
				var config = GetConfiguration(currentConfig);
				if ( config != -1 )
					config.AddInstance(input, analogue_threshold, long_press_time, double_tap_time, repeated_time);
			},
			
			AddKey: function(input, key, device) {
				var config = GetConfiguration(currentConfig);
				if ( config != -1 )
					config.AddKey(input, key, device);
			},
				
			DeleteConfiguration: function(input) {
				var len = array_length(configurations);
				for(var i=0;i<len;i++) {
					var config = configurations[i];
					if (config.name == string_upper(input)) {
						config.FreeInstances();
						delete config;
						for(var j=i+1;j<len;j++) {
							configurations[j-1] = configurations[j];
						}
						array_resize(configurations, len-1);
						return;
					}
				}
			},
				
			DeleteAllConfigurations: function(input) {
				for( var i=array_length(configurations)-1 ; i>=0 ; i-- ) {
					DeleteInstance(configurations[i].name);
				}
			},
				
			Print: function(input) {
				Print("---------------------------")
				for(var i=0;i<array_length(configurations);i++) {
					configurations[i].Print();
				}
				Print("---------------------------")
			},

			Save: function() {
				var file = file_text_open_write(FILE_NAME);
				
				for(var i=0;i<array_length(configurations);i++) {
					configurations[i].Save(file);
				}
						
				file_text_close(file);
			},
			
			Load: function() {
				if ( !file_exists(FILE_NAME) ) return -1;
				
				var file = file_text_open_read(FILE_NAME);
					
				while(!file_text_eof(file)) {
					var line = StringSplit(file_text_read_string(file), ";");
					file_text_readln(file);
					
					var lastInst;
						
					switch(line[|0]) {
						case "c": SetConfiguration(line[|1]); break;
						case "i": AddInstance(line[|1], real(line[|2]), real(line[|3]), real(line[|4])); lastInst = line[|1]; break;
						case "k": AddKey(lastInst, StringToKey(line[|1]), real(line[|2])); break;
					}
						
					ds_list_destroy(line);
				}
						
				file_text_close(file);
				return 1;
			},

			Draw: function(config, dir, dir2, func) {
				dir = ( dir == undefined ) ? 0 : dir;
				dir2 = ( dir2 == undefined ) ? 0 : dir2;
				if ( func == undefined ) func = function(input, key, i, j, selected, listening) {
					if ( j== 0 ) draw_text(10*(j+1), 15*i, input);
					if ( !selected ) {
					    draw_text(70*(j+1), 15*i, key);
					} else {
					    if ( !listening ) {
					        draw_text(90*(j+1), 15*i, key);
					    } else {
					        draw_text_colour(90*(j+1), 15*i, key, c_orange, c_orange, c_orange, c_orange, 1);
					    }
					}
				}
				
				var selectedInput = -1;
				var newConf = GetConfiguration(config);
				if ( newConf != -1 ) {
					var totalInputs = array_length(newConf.instances);
					selector += dir;
					selector -= floor( (selector) / totalInputs ) * totalInputs;
					
					var totalKeys = array_length(newConf.instances[selector].keys);
					selector2 += dir2;
					selector2 -= floor( (selector2) / totalKeys ) * totalKeys;
				
					selectedInput = newConf.Draw(func, selector, selector2, listening);
				}
				
				return selectedInput;
			},
			
			GetCurrentKey: function(type) {
				if (type == undefined) type = "DIGITAL";
				var kCheck = KeyboardGetKey();
				var gCheck = GamepadGetKey();
				var mCheck = MouseGetKey();
				
				if ( kCheck != -1 ) return kCheck;
				if ( gCheck != -1 && type == "DIGITAL") return gCheck;
				if ( gaCheck != -1 && type == "ANALOGUE") return gaCheck;
				if ( mCheck != -1 ) return mCheck;
				
				return -1;
			},
			
			ChangeKey: function(key2listen, cancelInput, emptyInput, denyList) {
				listening = true;
				self.key2listen = key2listen;
				self.cancelInput = cancelInput;
				self.emptyInput = emptyInput;
				self.denyList = denyList;
			},
			
			GetKeys: function(configuration) {
				var newConf = GetConfiguration(configuration);
				
				if ( newConf != -1 )
					return newConf.GetKeys();
				return -1;
			},
		#endregion
			
		#region CHECKERS
			Check: function(input, config) {
				if listening return false;
				config = ( config == undefined ) ? currentConfig : config;
				var newConf = GetConfiguration(config);
				if ( newConf != -1 ) return newConf.Check(input, "hold");
				
				return false;
			},
			
			CheckPressed: function(input, config) {
				if listening return false;
				config = ( config == undefined ) ? currentConfig : config;
				var newConf = GetConfiguration(config);
				if ( newConf != -1 ) return newConf.Check(input, "pressed");
				
				return false;
			},
			
			CheckReleased: function(input, config) {
				if listening return false;
				config = ( config == undefined ) ? currentConfig : config;
				var newConf = GetConfiguration(config);
				if ( newConf != -1 ) return newConf.Check(input, "released");
				
				return false;
			},
			
			CheckLong: function(input, config) {
				if listening return false;
				config = ( config == undefined ) ? currentConfig : config;
				var newConf = GetConfiguration(config);
				if ( newConf != -1 ) return newConf.Check(input, "long");
				
				return false;
			},
			
			CheckLongPressed: function(input, config) {
				if listening return false;
				config = ( config == undefined ) ? currentConfig : config;
				var newConf = GetConfiguration(config);
				if ( newConf != -1 ) return newConf.Check(input, "longpressed");
				
				return false;
			},
			
			CheckLongReleased: function(input, config) {
				if listening return false;
				config = ( config == undefined ) ? currentConfig : config;
				var newConf = GetConfiguration(config);
				if ( newConf != -1 ) return newConf.Check(input, "longreleased");
				
				return false;
			},
			
			CheckDouble: function(input, config) {
				if listening return false;
				config = ( config == undefined ) ? currentConfig : config;
				var newConf = GetConfiguration(config);
				if ( newConf != -1 ) return newConf.Check(input, "double");
				
				return false;
			},
			
			CheckRepeated: function(input, config) {
				if listening return false;
				config = ( config == undefined ) ? currentConfig : config;
				var newConf = GetConfiguration(config);
				if ( newConf != -1 ) return newConf.Check(input, "repeated");
				
				return false;
			},
			
			CheckRepeatedLong: function(input, config) {
				if listening return false;
				config = ( config == undefined ) ? currentConfig: config;
				var newConf = GetConfiguration(config);
				if ( newConf != -1 ) return newConf.Check(input, "repeatedlong");
				
				return false;
			},
			
			CheckValue: function(input, config) {
				if listening return 0;
				config = ( config == undefined ) ? currentConfig : config;
				var newConf = GetConfiguration(config);
				if ( newConf != -1 ) return newConf.Check(input, "value");
				
				return 0;
			},
			
			CheckNormalized: function(input, config) {
				if listening return 0;
				config = ( config == undefined ) ? currentConfig : config;
				var newConf = GetConfiguration(config);
				if ( newConf != -1 ) return newConf.Check(input, "normalized");
				
				return 0;
			}
		#endregion
	}		
	return manager;
}

function InputConfiguration(name) constructor {
	// General variables
	self.name = string_upper(name);
	self.instances = [];
	
	static GetInstance = function(name) {
		for (var i=0; i<array_length(self.instances); i++) {
		    if ( self.instances[i].name == string_upper(name) ) return self.instances[i];
		}
		return -1;
	}
	
	static Check = function(input, type) {
		var inst = GetInstance(input);
		
		if ( inst != -1 ) {
			switch(type) {
				case "hold": return inst.hold; break;
				case "pressed": return inst.pressed; break;
				case "released": return inst.released; break;
				case "long": return inst.long; break;
				case "longpressed": return inst.longPressed; break;
				case "longreleased": return inst.longReleased; break;
				case "double": return inst.double; break;
				case "repeated": return inst.repeated; break;
				case "repeatedlong": return inst.repeatedLong; break;
				case "value": return inst.value; break;
				case "normalized": return inst.normalized; break;
			}
		}
		
		return -1;
	}
	
	static Update = function() {
		for (var i=0; i<array_length(self.instances); i++) {
		    self.instances[i].Update();
		}	
	}

	static AddInstance = function(name, analogue_threshold, long_press_time, double_tap_time, repeated_time) {
		if ( GetInstance(name) != -1 ) return -1;
		self.instances[array_length(self.instances)] = new InputInstance(name, analogue_threshold, long_press_time, double_tap_time, repeated_time);
	}

	static AddKey = function(input, key, device) {
		var newInst = self.GetInstance(input);
		if ( newInst == -1 ) return -1;
		newInst.AddKey(key, device);
	};
	
	static FreeInstances = function() {
		for( var i = 0 ; i < array_length(self.instances) ; i++ ) {
			self.instances[i].FreeKeys();
		}	
	};

	static Print = function() {
		Print(self.name + ":")
		for( var i = 0 ; i < array_length(self.instances) ; i++ ) {
			self.instances[i].Print();
		}
	};
	
	static Save = function(file) {
		file_text_write_string(file, "c;" + self.name + "\n");
		for( var i = 0 ; i < array_length(self.instances) ; i++ ) {
			self.instances[i].Save(file);
		}
	}
	
	static Draw = function(func, selector, selector2, listening) {
		var key2ret = -1;
		for( var i=0 ; i<array_length(self.instances) ; i++ ) {
			var ret = self.instances[i].Draw(func, i, selector, selector2, listening);
			if ( ret != -1 ) key2ret = ret;
		}
		
		return key2ret;
	}
	
	static GetKeys = function() {
		var arr = [];
		for( var i=0 ; i<array_length(self.instances) ; i++ ) {
			for( var j=0 ; j<array_length(self.instances[i].keys) ; j++ )
			arr[array_length(arr)] = self.instances[i].keys[j].key;
		}
		return arr;
	}
}

function InputInstance(name, analogue_threshold, long_press_time, double_tap_time, repeated_time) constructor {
	self.name = string_upper(name);
	self.keys = [];
	self.analogue_threshold = ( analogue_threshold == undefined ) ? ANALOGUE_THRESHOLD : analogue_threshold;
	self.long_press_time = ( long_press_time == undefined ) ? LONG_PRESS_TIME : long_press_time;
	self.double_tap_time = ( double_tap_time == undefined ) ? DOUBLE_TAP_TIME : double_tap_time;
	self.repeated_time = ( repeated_time == undefined ) ? REPEATED_TIME : repeated_time;
	
	// Different input states
	self.hold = false;		
	self.pressed = false;
	self.released = false;	
	self.long = false;
	self.longPressed = false;
	self.longReleased = false;
	self.double = false;	
	self.repeated = false;
	self.repeatedLong = false;
	self.value = 0;
	self.normalized = 0;
	
	// Aux variables
	self.last_press = 0;
	self.canDouble = false;
	self.repeated_last_press = 0;
	self.long_repeated_last_press = 0;
	
	static Update = function() {
		// GET THE CURRENT STATE OF THE KEYS
		var len = array_length(self.keys);
		if ( !len ) return;
		
		self.value = 0;
		
		if ( len ) {
			for (var i = 0; i < len; i++) {
				var k = self.keys[i];
				if ( k != KEY.EMPTY ) {
					var newVal = k.Check();
					if ( newVal > abs(self.value) ) self.value = newVal;
				}
			}
		}
		
		self.normalized = ( self.value - self.analogue_threshold ) / ( 1 - self.analogue_threshold )
		
		if ( self.value <= self.analogue_threshold ) {
			self.value = 0;
			self.normalized = 0;
		}
		
		// REGULAR TAP			
		var previous_state = self.hold;
		self.hold = self.value > 0;
			
		self.pressed = ( self.hold && !previous_state )
		self.released = ( !self.hold && previous_state )
			
		if ( self.pressed ) {
			self.last_press = current_time;
			self.repeated_last_press = current_time;
		}
		var time_pressing = current_time - self.last_press;
			
		// DOUBLE TAP			
		if ( self.canDouble ) {
			if ( time_pressing < self.double_tap_time ) {
				if ( self.pressed ) {
					self.double = true;
					self.canDouble = false;
				}
			} else {
				self.canDouble = false;		
			}
		} else {
			self.double = false;
			if ( self.pressed ) self.canDouble = true;
		}
			
		// LONG TAP			
		if ( self.hold ) {
			if ( time_pressing >= self.long_press_time ) {
				self.longPressed = !self.long;
				self.long = true;
			}
		} else {
			self.longReleased = self.long && self.released;
			self.long = false;
			self.longPressed = false;
		}
			
		// REPEATED			
		self.repeated = self.pressed;
			
		if ( self.hold && !self.pressed) {
			var time_pressing_modulo = current_time - self.repeated_last_press;
			if ( time_pressing_modulo >= self.repeated_time ) {
				self.repeated_last_press = current_time;
				self.repeated = true;
			} else {
				self.repeated = false;
			}
		}
			
		// LONG REPEATED
		self.repeatedLong = self.longPressed;
		
		if ( self.longPressed ) self.long_repeated_last_press = current_time;
			
		if ( self.long && !self.longPressed) {
			var time_pressing_modulo = current_time - self.long_repeated_last_press;
			if ( time_pressing_modulo >= self.repeated_time ) {
				self.long_repeated_last_press = current_time;
				self.repeatedLong = true;
			} else {
				self.repeatedLong = false;
			}
		}
	}

	static AddKey = function(key, device) {
		for (var i=0; i<array_length(self.keys); i++) {
			if ( self.keys[i].key == key ) return -1;
		}
		
		var newKey = new InputKey(key, device);
		self.keys[array_length(self.keys)] = newKey;
	};
		
	static FreeKeys = function() {
		for( var i = 0 ; i < array_length(self.keys) ; i++ ) {
			delete self.keys[i];
		}
		array_resize(self.keys,0);
	};
		
	static Print = function() {
		var len = array_length(self.keys);
		var str = "\t" + self.name + " --> [";
		for( var i = 0 ; i < len-1 ; i++ ) {
			str += KeyToString(self.keys[i].key) + ", ";
		}
		if ( len )	str += KeyToString(self.keys[len-1].key) + "]";
		else str += " ]";
		
		Print(str);
	};

	static Save = function(file) {
		file_text_write_string(file, "i;" + self.name + ";" + string(self.long_press_time) + ";" + string(self.double_tap_time) + ";" + string(self.repeated_time) + "\n");
		for( var i = 0 ; i < array_length(self.keys) ; i++ ) {
			self.keys[i].Save(file);
		}
	}
	
	static Draw = function(func, i, selector, selector2, listening) {
		var key2ret = -1;
		for( var j=0 ; j<array_length(self.keys) ; j++ ) {
			var selected = (i==selector && j==selector2);
			func(self.name, KeyToString(self.keys[j].key), i, j, selected, listening);
			if ( selected ) key2ret = self.keys[j];
		}
		
		return key2ret;
	}
}

function InputKey(key, device) constructor {
	static init = function(key, device) {
		self.key = key;
		self.device = ( device != undefined ) ? device : 0;
		self.keyCode = KeyTrueCode(self.key);
		self.origin = undefined
		self.Check = undefined;
		
		// GET INPUT ORIGIN
		if ( self.key < KEY.A ) self.origin = "SPECIAL";
		else if ( self.key < KEY.SHIFT_LEFT ) self.origin = "KEYBOARD";
		else if ( self.key < KEY.LEFT_CLICK ) self.origin = "KEYBOARD_DIRECT";
		else if ( self.key < KEY.WHEEL_UP ) self.origin = "MOUSE_BUTTON";
		else if ( self.key < KEY.FACE1 ) self.origin = "MOUSE_WHEEL";
		else if ( self.key < KEY.LEFT_TRIGGER ) self.origin = "GAMEPAD_BUTTON";
		else if ( self.key < KEY.LEFT_JOYSTICK_DOWN ) self.origin = "TRIGGER";
		else if ( self.key < KEY.LEFT_JOYSTICK_UP ) self.origin = "JOYSTICK_POSITIVE";
		else self.origin = "JOYSTICK_NEGATIVE";
		
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
			default:
				self.Check = InputCallbackDefault;
		}
	}
	
	static Save = function(file) {
		file_text_write_string(file, "k;" + KeyToString(self.key) + ";" + string(self.device) + "\n");
	}
	
	// KEY CHECKING CALLBACK FUNCTIONS
	#region		
		// SPECIAL
		static InputCallbackDefault = function() { return false; }
		static InputCallbackSpecialAny = function() { return Input.GetCurrentKey() != -1; }
		static InputCallbackSpecialNone = function() { return Input.GetCurrentKey() == -1; }
		// KEYBOARD
		static InputCallbackKeyboardCheck = function() { return keyboard_check(self.keyCode); }
		
		// KEYBOARD DIRECT
		static InputCallbackKeyboardCheckDirect = function() { return keyboard_check_direct(self.keyCode); }
		
		// MOUSE_BUTTON
		static InputCallbackMouseCheck = function() { return mouse_check_button(self.keyCode); }
	
		// MOUSE_WHEEL
		static InputCallbackMouseWheelUp = function() { return mouse_wheel_up(); }
		static InputCallbackMouseWheelDown = function() { return mouse_wheel_down(); }	
	
		// GAMEPAD_BUTTON
		static InputCallbackGamepadCheck = function() { return gamepad_button_check(self.device, self.keyCode); }
	
		// GAMEPAD_STICK
		static InputCallbackGamepadTrigger = function() { return gamepad_button_value(self.device, self.keyCode); }
		static InputCallbackGamepadJoystickPositive = function() { return max(gamepad_axis_value(self.device, self.keyCode), 0); }
		static InputCallbackGamepadJoystickNegative = function() { return abs(min(gamepad_axis_value(self.device, self.keyCode), 0)); }
		
	#endregion
	
	init(key, device);
}

function KeyTrueCode(key) {
	var realCode = -1;
		
	switch( key ) {
		// KEYBOARD
		case KEY.A: realCode = ord("A"); break;
		case KEY.B: realCode = ord("B"); break;
		case KEY.C: realCode = ord("C"); break;
		case KEY.D: realCode = ord("D"); break;
		case KEY.E: realCode = ord("E"); break;
		case KEY.F: realCode = ord("F"); break;
		case KEY.G: realCode = ord("G"); break;
		case KEY.H: realCode = ord("H"); break;
		case KEY.I: realCode = ord("I"); break;
		case KEY.J: realCode = ord("J"); break;
		case KEY.K: realCode = ord("K"); break;
		case KEY.L: realCode = ord("L"); break;
		case KEY.M: realCode = ord("M"); break;
		case KEY.N: realCode = ord("N"); break;
		case KEY.O: realCode = ord("O"); break;
		case KEY.P: realCode = ord("P"); break;
		case KEY.Q: realCode = ord("Q"); break;
		case KEY.R: realCode = ord("R"); break;
		case KEY.S: realCode = ord("S"); break;
		case KEY.T: realCode = ord("T"); break;
		case KEY.U: realCode = ord("U"); break;
		case KEY.V: realCode = ord("V"); break;
		case KEY.W: realCode = ord("W"); break;
		case KEY.X: realCode = ord("X"); break;
		case KEY.Y: realCode = ord("Y"); break;
		case KEY.Z: realCode = ord("Z"); break;
		case KEY.ZERO: realCode = ord("0"); break;
		case KEY.ONE: realCode = ord("1"); break;
		case KEY.TWO: realCode = ord("2"); break;
		case KEY.THREE: realCode = ord("3"); break;
		case KEY.FOUR: realCode = ord("4"); break;
		case KEY.FIVE: realCode = ord("5"); break;
		case KEY.SIX: realCode = ord("6"); break;
		case KEY.SEVEN: realCode = ord("7"); break;
		case KEY.EIGHT: realCode = ord("8"); break;
		case KEY.NINE: realCode = ord("9"); break;
		case KEY.LEFT_ARROW: realCode = vk_left; break;
		case KEY.RIGHT_ARROW: realCode = vk_right; break;
		case KEY.UP_ARROW: realCode = vk_up; break;
		case KEY.DOWN_ARROW: realCode = vk_down; break;
		case KEY.ENTER: realCode = vk_enter; break;
		case KEY.BACKSPACE: realCode = vk_backspace; break;
		case KEY.SPACE: realCode = vk_space; break;
		case KEY.TAB: realCode = vk_tab; break;
		case KEY.ESCAPE: realCode = vk_escape; break;
		case KEY.HOME: realCode = vk_home; break;
		case KEY.END: realCode = vk_end; break;
		case KEY.DELETE: realCode = vk_delete; break;
		case KEY.INSERT: realCode = vk_insert; break;
		case KEY.PAGEUP: realCode = vk_pageup; break;
		case KEY.PAGEDOWN: realCode = vk_pagedown; break;
		case KEY.PAUSE: realCode = vk_pause; break;
		case KEY.PRINTSCREEN: realCode = vk_printscreen; break;
		case KEY.F1: realCode = vk_f1; break;
		case KEY.F2: realCode = vk_f2; break;
		case KEY.F3: realCode = vk_f3; break;
		case KEY.F4: realCode = vk_f4; break;
		case KEY.F5: realCode = vk_f5; break;
		case KEY.F6: realCode = vk_f6; break;
		case KEY.F7: realCode = vk_f7; break;
		case KEY.F8: realCode = vk_f8; break;
		case KEY.F9: realCode = vk_f9; break;
		case KEY.F10: realCode = vk_f10; break;
		case KEY.F11: realCode = vk_f11; break;
		case KEY.F12: realCode = vk_f12; break;
		case KEY.NUMPAD0: realCode = vk_numpad0; break;
		case KEY.NUMPAD1: realCode = vk_numpad1; break;
		case KEY.NUMPAD2: realCode = vk_numpad2; break;
		case KEY.NUMPAD3: realCode = vk_numpad3; break;
		case KEY.NUMPAD4: realCode = vk_numpad4; break;
		case KEY.NUMPAD5: realCode = vk_numpad5; break;
		case KEY.NUMPAD6: realCode = vk_numpad6; break;
		case KEY.NUMPAD7: realCode = vk_numpad7; break;
		case KEY.NUMPAD8: realCode = vk_numpad8; break;
		case KEY.NUMPAD9: realCode = vk_numpad9; break;
		case KEY.MULTIPLY: realCode = vk_multiply; break;
		case KEY.DIVIDE: realCode = vk_divide; break;
		case KEY.ADD: realCode = vk_add; break;
		case KEY.SUBSTRACT: realCode = vk_subtract; break;
		case KEY.DECIMAL: realCode = vk_decimal; break;
		
		// KEYBOARD DIRECT
		case KEY.SHIFT_LEFT: realCode = vk_lshift; break;
		case KEY.CONTROL_LEFT: realCode = vk_lcontrol; break;
		case KEY.ALT_LEFT: realCode = vk_lalt; break;
		case KEY.SHIFT_RIGHT: realCode = vk_rshift; break;
		case KEY.CONTROL_RIGHT: realCode = vk_rcontrol; break;
		case KEY.ALT_RIGHT: realCode = vk_ralt; break;
			
		// MOUSE
		case KEY.LEFT_CLICK: realCode = mb_left; break;
		case KEY.RIGHT_CLICK: realCode = mb_right; break;
		case KEY.MIDDLE_CLICK: realCode = mb_middle; break;
			
		// GAMEPAD
		case KEY.FACE1: realCode = gp_face1; break;
		case KEY.FACE2: realCode = gp_face2; break;
		case KEY.FACE3: realCode = gp_face3; break;
		case KEY.FACE4: realCode = gp_face4; break;
		case KEY.LEFT_SHOULDER: realCode = gp_shoulderl; break;
		case KEY.RIGHT_SHOULDER: realCode = gp_shoulderr; break;
		case KEY.SELECT: realCode = gp_select; break;
		case KEY.START: realCode = gp_start; break;
		case KEY.LEFT_JOYSTICK_CLICK: realCode = gp_stickl; break;
		case KEY.RIGHT_JOYSTICK_CLICK: realCode = gp_stickr; break;
		case KEY.PAD_UP: realCode = gp_padu; break;
		case KEY.PAD_DOWN: realCode = gp_padd; break;
		case KEY.PAD_LEFT: realCode = gp_padl; break;
		case KEY.PAD_RIGHT: realCode = gp_padr; break;
		
		// ANALOGUE INPUT
		case KEY.LEFT_TRIGGER: realCode = gp_shoulderlb; break;
		case KEY.RIGHT_TRIGGER: realCode = gp_shoulderrb; break;
		
		case KEY.LEFT_JOYSTICK_UP: realCode = gp_axislv; break;
		case KEY.LEFT_JOYSTICK_DOWN: realCode = gp_axislv; break;
		case KEY.LEFT_JOYSTICK_LEFT: realCode = gp_axislh; break;
		case KEY.LEFT_JOYSTICK_RIGHT: realCode = gp_axislh; break;
		case KEY.RIGHT_JOYSTICK_UP: realCode = gp_axisrv; break;
		case KEY.RIGHT_JOYSTICK_DOWN: realCode = gp_axisrv; break;
		case KEY.RIGHT_JOYSTICK_LEFT: realCode = gp_axisrh; break;
		case KEY.RIGHT_JOYSTICK_RIGHT: realCode = gp_axisrh; break;
	}
		
	return realCode;
}

function KeyToString(key) {
	var str = "undefined";
		
	switch( key ) {
		// EMPTY INPUT
		case KEY.EMPTY: str = "---"; break;
		case KEY.ANY: str = "ANY"; break;
		case KEY.NONE: str = "NONE"; break;
		
		// KEYBOARD
		case KEY.A: str = "A"; break;
		case KEY.B: str = "B"; break;
		case KEY.C: str = "C"; break;
		case KEY.D: str = "D"; break;
		case KEY.E: str = "E"; break;
		case KEY.F: str = "F"; break;
		case KEY.G: str = "G"; break;
		case KEY.H: str = "H"; break;
		case KEY.I: str = "I"; break;
		case KEY.J: str = "J"; break;
		case KEY.K: str = "K"; break;
		case KEY.L: str = "L"; break;
		case KEY.M: str = "M"; break;
		case KEY.N: str = "N"; break;
		case KEY.O: str = "O"; break;
		case KEY.P: str = "P"; break;
		case KEY.Q: str = "Q"; break;
		case KEY.R: str = "R"; break;
		case KEY.S: str = "S"; break;
		case KEY.T: str = "T"; break;
		case KEY.U: str = "U"; break;
		case KEY.V: str = "V"; break;
		case KEY.W: str = "W"; break;
		case KEY.X: str = "X"; break;
		case KEY.Y: str = "Y"; break;
		case KEY.Z: str = "Z"; break;
		case KEY.ZERO: str = "ZERO"; break;
		case KEY.ONE: str = "ONE"; break;
		case KEY.TWO: str = "TWO"; break;
		case KEY.THREE: str = "THREE"; break;
		case KEY.FOUR: str = "FOUR"; break;
		case KEY.FIVE: str = "FIVE"; break;
		case KEY.SIX: str = "SIX"; break;
		case KEY.SEVEN: str = "SEVEN"; break;
		case KEY.EIGHT: str = "EIGHT"; break;
		case KEY.NINE: str = "NINE"; break;
		case KEY.LEFT_ARROW: str = "LEFT_ARROW"; break;
		case KEY.RIGHT_ARROW: str = "RIGHT_ARROW"; break;
		case KEY.UP_ARROW: str = "UP_ARROW"; break;
		case KEY.DOWN_ARROW: str = "DOWN_ARROW"; break;
		case KEY.ENTER: str = "ENTER"; break;
		case KEY.BACKSPACE: str = "BACKSPACE"; break;
		case KEY.SPACE: str = "SPACE"; break;
		case KEY.TAB: str = "TAB"; break;
		case KEY.ESCAPE: str = "ESCAPE"; break;
		case KEY.HOME: str = "HOME"; break;
		case KEY.END: str = "END"; break;
		case KEY.DELETE: str = "DELETE"; break;
		case KEY.INSERT: str = "INSERT"; break;
		case KEY.PAGEUP: str = "PAGEUP"; break;
		case KEY.PAGEDOWN: str = "PAGEDOWN"; break;
		case KEY.PAUSE: str = "PAUSE"; break;
		case KEY.PRINTSCREEN: str = "PRINTSCREEN"; break;
		case KEY.F1: str = "F1"; break;
		case KEY.F2: str = "F2"; break;
		case KEY.F3: str = "F3"; break;
		case KEY.F4: str = "F4"; break;
		case KEY.F5: str = "F5"; break;
		case KEY.F6: str = "F6"; break;
		case KEY.F7: str = "F7"; break;
		case KEY.F8: str = "F8"; break;
		case KEY.F9: str = "F9"; break;
		case KEY.F10: str = "F10"; break;
		case KEY.F11: str = "F11"; break;
		case KEY.F12: str = "F12"; break;
		case KEY.NUMPAD0: str = "NUMPAD0"; break;
		case KEY.NUMPAD1: str = "NUMPAD1"; break;
		case KEY.NUMPAD2: str = "NUMPAD2"; break;
		case KEY.NUMPAD3: str = "NUMPAD3"; break;
		case KEY.NUMPAD4: str = "NUMPAD4"; break;
		case KEY.NUMPAD5: str = "NUMPAD5"; break;
		case KEY.NUMPAD6: str = "NUMPAD6"; break;
		case KEY.NUMPAD7: str = "NUMPAD7"; break;
		case KEY.NUMPAD8: str = "NUMPAD8"; break;
		case KEY.NUMPAD9: str = "NUMPAD9"; break;
		case KEY.MULTIPLY: str = "MULTIPLY"; break;
		case KEY.DIVIDE: str = "DIVIDE"; break;
		case KEY.ADD: str = "ADD"; break;
		case KEY.SUBSTRACT: str = "SUBSTRACT"; break;
		case KEY.DECIMAL: str = "DECIMAL"; break;
		
		// KEYBOARD DIRECT
		case KEY.SHIFT_LEFT: str = "SHIFT_LEFT"; break;
		case KEY.CONTROL_LEFT: str = "CONTROL_LEFT"; break;
		case KEY.ALT_LEFT: str = "ALT_LEFT"; break;
		case KEY.SHIFT_RIGHT: str = "SHIFT_RIGHT"; break;
		case KEY.CONTROL_RIGHT: str = "CONTROL_RIGHT"; break;
		case KEY.ALT_RIGHT: str = "ALT_RIGHT"; break;
    
		// MOUSE
		case KEY.LEFT_CLICK: str = "LEFT_CLICK"; break;
		case KEY.RIGHT_CLICK: str = "RIGHT_CLICK"; break;
		case KEY.MIDDLE_CLICK: str = "MIDDLE_CLICK"; break;
		case KEY.WHEEL_UP: str = "WHEEL_UP"; break;
		case KEY.WHEEL_DOWN: str = "WHEEL_DOWN"; break;
    
		// GAMEPAD
		case KEY.FACE1: str = "FACE1"; break;
		case KEY.FACE2: str = "FACE2"; break;
		case KEY.FACE3: str = "FACE3"; break;
		case KEY.FACE4: str = "FACE4"; break;
		case KEY.LEFT_SHOULDER: str = "LEFT_SHOULDER"; break;
		case KEY.RIGHT_SHOULDER: str = "RIGHT_SHOULDER"; break;
		case KEY.SELECT: str = "SELECT"; break;
		case KEY.START: str = "START"; break;
		case KEY.LEFT_JOYSTICK_CLICK: str = "LEFT_JOYSTICK_CLICK"; break;
		case KEY.RIGHT_JOYSTICK_CLICK: str = "RIGHT_JOYSTICK_CLICK"; break;
		case KEY.PAD_UP: str = "PAD_UP"; break;
		case KEY.PAD_DOWN: str = "PAD_DOWN"; break;
		case KEY.PAD_LEFT: str = "PAD_LEFT"; break;
		case KEY.PAD_RIGHT: str = "PAD_RIGHT"; break;
		
		// ANALOGUE INPUT
		case KEY.LEFT_TRIGGER: str = "LEFT_TRIGGER"; break;
		case KEY.RIGHT_TRIGGER: str = "RIGHT_TRIGGER"; break;
		
		case KEY.LEFT_JOYSTICK_UP: str = "LEFT_JOYSTICK_UP"; break;
		case KEY.LEFT_JOYSTICK_DOWN: str = "LEFT_JOYSTICK_DOWN"; break;
		case KEY.LEFT_JOYSTICK_LEFT: str = "LEFT_JOYSTICK_LEFT"; break;
		case KEY.LEFT_JOYSTICK_RIGHT: str = "LEFT_JOYSTICK_RIGHT"; break;
		case KEY.RIGHT_JOYSTICK_UP: str = "RIGHT_JOYSTICK_UP"; break;
		case KEY.RIGHT_JOYSTICK_DOWN: str = "RIGHT_JOYSTICK_DOWN"; break;
		case KEY.RIGHT_JOYSTICK_LEFT: str = "RIGHT_JOYSTICK_LEFT"; break;
		case KEY.RIGHT_JOYSTICK_RIGHT: str = "RIGHT_JOYSTICK_RIGHT"; break;
	}
		
	return str;
}

function StringToKey(str) {
	switch(str) {
		// KEYBOARD
		case "A": return KEY.A; break;
		case "B": return KEY.B; break;
		case "C": return KEY.C; break;
		case "D": return KEY.D; break;
		case "E": return KEY.E; break;
		case "F": return KEY.F; break;
		case "G": return KEY.G; break;
		case "H": return KEY.H; break;
		case "I": return KEY.I; break;
		case "J": return KEY.J; break;
		case "K": return KEY.K; break;
		case "L": return KEY.L; break;
		case "M": return KEY.M; break;
		case "N": return KEY.N; break;
		case "O": return KEY.O; break;
		case "P": return KEY.P; break;
		case "Q": return KEY.Q; break;
		case "R": return KEY.R; break;
		case "S": return KEY.S; break;
		case "T": return KEY.T; break;
		case "U": return KEY.U; break;
		case "V": return KEY.V; break;
		case "W": return KEY.W; break;
		case "X": return KEY.X; break;
		case "Y": return KEY.Y; break;
		case "Z": return KEY.Z; break;
		case "ZERO": return KEY.ZERO; break;
		case "ONE": return KEY.ONE; break;
		case "TWO": return KEY.TWO; break;
		case "THREE": return KEY.THREE; break;
		case "FOUR": return KEY.FOUR; break;
		case "FIVE": return KEY.FIVE; break;
		case "SIX": return KEY.SIX; break;
		case "SEVEN": return KEY.SEVEN; break;
		case "EIGHT": return KEY.EIGHT; break;
		case "NINE": return KEY.NINE; break;
		case "LEFT_ARROW": return KEY.LEFT_ARROW; break;
		case "RIGHT_ARROW": return KEY.RIGHT_ARROW; break;
		case "UP_ARROW": return KEY.UP_ARROW; break;
		case "DOWN_ARROW": return KEY.DOWN_ARROW; break;
		case "ENTER": return KEY.ENTER; break;
		case "BACKSPACE": return KEY.BACKSPACE; break;
		case "SPACE": return KEY.SPACE; break;
		case "TAB": return KEY.TAB; break;
		case "ESCAPE": return KEY.ESCAPE; break;
		case "HOME": return KEY.HOME; break;
		case "END": return KEY.END; break;
		case "DELETE": return KEY.DELETE; break;
		case "INSERT": return KEY.INSERT; break;
		case "PAGEUP": return KEY.PAGEUP; break;
		case "PAGEDOWN": return KEY.PAGEDOWN; break;
		case "PAUSE": return KEY.PAUSE; break;
		case "PRINTSCREEN": return KEY.PRINTSCREEN; break;
		case "F1": return KEY.F1; break;
		case "F2": return KEY.F2; break;
		case "F3": return KEY.F3; break;
		case "F4": return KEY.F4; break;
		case "F5": return KEY.F5; break;
		case "F6": return KEY.F6; break;
		case "F7": return KEY.F7; break;
		case "F8": return KEY.F8; break;
		case "F9": return KEY.F9; break;
		case "F10": return KEY.F10; break;
		case "F11": return KEY.F11; break;
		case "F12": return KEY.F12; break;
		case "NUMPAD0": return KEY.NUMPAD0; break;
		case "NUMPAD1": return KEY.NUMPAD1; break;
		case "NUMPAD2": return KEY.NUMPAD2; break;
		case "NUMPAD3": return KEY.NUMPAD3; break;
		case "NUMPAD4": return KEY.NUMPAD4; break;
		case "NUMPAD5": return KEY.NUMPAD5; break;
		case "NUMPAD6": return KEY.NUMPAD6; break;
		case "NUMPAD7": return KEY.NUMPAD7; break;
		case "NUMPAD8": return KEY.NUMPAD8; break;
		case "NUMPAD9": return KEY.NUMPAD9; break;
		case "MULTIPLY": return KEY.MULTIPLY; break;
		case "DIVIDE": return KEY.DIVIDE; break;
		case "ADD": return KEY.ADD; break;
		case "SUBSTRACT": return KEY.SUBSTRACT; break;
		case "DECIMAL": return KEY.DECIMAL; break;
		
		// KETBOARD DIRECT
		case "SHIFT_LEFT": return KEY.SHIFT_LEFT; break;
		case "CONTROL_LEFT": return KEY.CONTROL_LEFT; break;
		case "ALT_LEFT": return KEY.ALT_LEFT; break;
		case "SHIFT_RIGHT": return KEY.SHIFT_RIGHT; break;
		case "CONTROL_RIGHT": return KEY.CONTROL_RIGHT; break;
		case "ALT_RIGHT": return KEY.ALT_RIGHT; break;
    
		// MOUSE
		case "LEFT_CLICK": return KEY.LEFT_CLICK; break;
		case "RIGHT_CLICK": return KEY.RIGHT_CLICK; break;
		case "MIDDLE_CLICK": return KEY.MIDDLE_CLICK; break;
		case "WHEEL_UP": return KEY.WHEEL_UP; break;
		case "WHEEL_DOWN": return KEY.WHEEL_DOWN; break;
    
		// GAMEPAD
		case "FACE1": return KEY.FACE1; break;
		case "FACE2": return KEY.FACE2; break;
		case "FACE3": return KEY.FACE3; break;
		case "FACE4": return KEY.FACE4; break;
		case "LEFT_SHOULDER": return KEY.LEFT_SHOULDER; break;
		case "RIGHT_SHOULDER": return KEY.RIGHT_SHOULDER; break;
		case "SELECT": return KEY.SELECT; break;
		case "START": return KEY.START; break;
		case "LEFT_JOYSTICK_CLICK": return KEY.LEFT_JOYSTICK_CLICK; break;
		case "RIGHT_JOYSTICK_CLICK": return KEY.RIGHT_JOYSTICK_CLICK; break;
		case "PAD_UP": return KEY.PAD_UP; break;
		case "PAD_DOWN": return KEY.PAD_DOWN; break;
		case "PAD_LEFT": return KEY.PAD_LEFT; break;
		case "PAD_RIGHT": return KEY.PAD_RIGHT; break;
		
		// ANALOGUE INPUT
		case "LEFT_TRIGGER": return KEY.LEFT_TRIGGER; break;
		case "RIGHT_TRIGGER": return KEY.RIGHT_TRIGGER; break;
		
		case "LEFT_JOYSTICK_UP": return KEY.LEFT_JOYSTICK_UP; break;
		case "LEFT_JOYSTICK_DOWN": return KEY.LEFT_JOYSTICK_DOWN; break;
		case "LEFT_JOYSTICK_LEFT": return KEY.LEFT_JOYSTICK_LEFT; break;
		case "LEFT_JOYSTICK_RIGHT": return KEY.LEFT_JOYSTICK_RIGHT; break;
		case "RIGHT_JOYSTICK_UP": return KEY.RIGHT_JOYSTICK_UP; break;
		case "RIGHT_JOYSTICK_DOWN": return KEY.RIGHT_JOYSTICK_DOWN; break;
		case "RIGHT_JOYSTICK_LEFT": return KEY.RIGHT_JOYSTICK_LEFT; break;
		case "RIGHT_JOYSTICK_RIGHT": return KEY.RIGHT_JOYSTICK_RIGHT; break;
	}
	return -1;
}

function Print(messsage) {
	if ( argument_count == 1 ) show_debug_message(messsage);
	else {
		var totalMessage = ""
		for ( var i=0; i < argument_count - 1 ; i++ ) totalMessage += string(argument[i]) + " ";
		totalMessage += string(argument[argument_count - 1]);
		
		show_debug_message(totalMessage);
	}
};

function StringSplit(str, delimiter) {
	// Splits a string at every point it finds the delimiter substring into a list.

	// Create a list of strings and add the whole string into the fist position
	var split_string = ds_list_create();
	ds_list_add(split_string, str);

	// If the length of the string is lesser than 3 just return the string
	if (string_length(str)<3) return 0; // Minimum length supported

	var idx = 0;
	var prev_str = str;

	// Until we dont find the delimiter character into the last position
	while(string_pos(delimiter, prev_str)) {
	
		// We save the position in the string of the delimiter character and the length of the whole string
		var pos = string_pos(delimiter, prev_str);
		var len = string_length(prev_str);
	
		// We split the string in two, ignoring the delimiter
		var part1 = string_copy(prev_str, 1, pos-1);
		var part2 = string_copy(prev_str, pos+1, len-pos+1);
	
		// We save both parts
		split_string[|idx] = part1;
		split_string[|idx + 1] = part2;
	
		// And now we are working with the right part after the cut
		idx++;
		prev_str = part2;
	}

	// Delete empty strings
	var sz = ds_list_size(split_string);
	for ( var i=0 ; i<sz ; i++ ) {
		if (split_string[|i] == "" ) {
			ds_list_delete(split_string, i);
			i--;
		}	
	}

	return split_string;
}

function ValueInArray(array, value) {
	var len = array_length(array);
	for( var i=0 ; i<len ; i++ ) {
		if ( array[i] == value ) return true;
	}
	return false;
}

function KeyboardGetKey() {
	if ( keyboard_check(vk_anykey) ) {
		if keyboard_check(ord("A")) return KEY.A;
		if keyboard_check(ord("B")) return KEY.B;
		if keyboard_check(ord("C")) return KEY.C;
		if keyboard_check(ord("D")) return KEY.D;
		if keyboard_check(ord("E")) return KEY.E;
		if keyboard_check(ord("F")) return KEY.F;
		if keyboard_check(ord("G")) return KEY.G;
		if keyboard_check(ord("H")) return KEY.H;
		if keyboard_check(ord("I")) return KEY.I;
		if keyboard_check(ord("J")) return KEY.J;
		if keyboard_check(ord("K")) return KEY.K;
		if keyboard_check(ord("L")) return KEY.L;
		if keyboard_check(ord("M")) return KEY.M;
		if keyboard_check(ord("N")) return KEY.N;
		if keyboard_check(ord("O")) return KEY.O;
		if keyboard_check(ord("P")) return KEY.P;
		if keyboard_check(ord("Q")) return KEY.Q;
		if keyboard_check(ord("R")) return KEY.R;
		if keyboard_check(ord("S")) return KEY.S;
		if keyboard_check(ord("T")) return KEY.T;
		if keyboard_check(ord("U")) return KEY.U;
		if keyboard_check(ord("V")) return KEY.V;
		if keyboard_check(ord("W")) return KEY.W;
		if keyboard_check(ord("X")) return KEY.X;
		if keyboard_check(ord("Y")) return KEY.Y;
		if keyboard_check(ord("Z")) return KEY.Z;
		if keyboard_check(ord("0")) return KEY.ZERO;
		if keyboard_check(ord("1")) return KEY.ONE;
		if keyboard_check(ord("2")) return KEY.TWO;
		if keyboard_check(ord("3")) return KEY.THREE;
		if keyboard_check(ord("4")) return KEY.FOUR;
		if keyboard_check(ord("5")) return KEY.FIVE;
		if keyboard_check(ord("6")) return KEY.SIX;
		if keyboard_check(ord("7")) return KEY.SEVEN;
		if keyboard_check(ord("8")) return KEY.EIGHT;
		if keyboard_check(ord("9")) return KEY.NINE;
		if keyboard_check(vk_left) return KEY.LEFT_ARROW;
		if keyboard_check(vk_right) return KEY.RIGHT_ARROW;
		if keyboard_check(vk_up) return KEY.UP_ARROW;
		if keyboard_check(vk_down) return KEY.DOWN_ARROW;
		if keyboard_check(vk_enter) return KEY.ENTER;
		if keyboard_check(vk_backspace) return KEY.BACKSPACE;
		if keyboard_check(vk_space) return KEY.SPACE;
		if keyboard_check_direct(vk_lshift) return KEY.SHIFT_LEFT;
		if keyboard_check_direct(vk_lcontrol) return KEY.CONTROL_LEFT;
		if keyboard_check_direct(vk_lalt) return KEY.ALT_LEFT;
		if keyboard_check_direct(vk_rshift) return KEY.SHIFT_RIGHT;
		if keyboard_check_direct(vk_rcontrol) return KEY.CONTROL_RIGHT;
		if keyboard_check_direct(vk_ralt) return KEY.ALT_RIGHT;
		if keyboard_check(vk_tab) return KEY.TAB;
		if keyboard_check(vk_escape) return KEY.ESCAPE;
		if keyboard_check(vk_home) return KEY.HOME;
		if keyboard_check(vk_end) return KEY.END;
		if keyboard_check(vk_delete) return KEY.DELETE;
		if keyboard_check(vk_insert) return KEY.INSERT;
		if keyboard_check(vk_pageup) return KEY.PAGEUP;
		if keyboard_check(vk_pagedown) return KEY.PAGEDOWN;
		if keyboard_check(vk_pause) return KEY.PAUSE;
		if keyboard_check(vk_printscreen) return KEY.PRINTSCREEN;
		if keyboard_check(vk_f1) return KEY.F1;
		if keyboard_check(vk_f2) return KEY.F2;
		if keyboard_check(vk_f3) return KEY.F3;
		if keyboard_check(vk_f4) return KEY.F4;
		if keyboard_check(vk_f5) return KEY.F5;
		if keyboard_check(vk_f6) return KEY.F6;
		if keyboard_check(vk_f7) return KEY.F7;
		if keyboard_check(vk_f8) return KEY.F8;
		if keyboard_check(vk_f9) return KEY.F9;
		if keyboard_check(vk_f10) return KEY.F10;
		if keyboard_check(vk_f11) return KEY.F11;
		if keyboard_check(vk_f12) return KEY.F12;
		if keyboard_check(vk_numpad0) return KEY.NUMPAD0;
		if keyboard_check(vk_numpad1) return KEY.NUMPAD1;
		if keyboard_check(vk_numpad2) return KEY.NUMPAD2;
		if keyboard_check(vk_numpad3) return KEY.NUMPAD3;
		if keyboard_check(vk_numpad4) return KEY.NUMPAD4;
		if keyboard_check(vk_numpad5) return KEY.NUMPAD5;
		if keyboard_check(vk_numpad6) return KEY.NUMPAD6;
		if keyboard_check(vk_numpad7) return KEY.NUMPAD7;
		if keyboard_check(vk_numpad8) return KEY.NUMPAD8;
		if keyboard_check(vk_numpad9) return KEY.NUMPAD9;
		if keyboard_check(vk_multiply) return KEY.MULTIPLY;
		if keyboard_check(vk_divide) return KEY.DIVIDE;
		if keyboard_check(vk_add) return KEY.ADD;
		if keyboard_check(vk_subtract) return KEY.SUBSTRACT;
		if keyboard_check(vk_decimal) return KEY.DECIMAL;
	}
	
	return -1;
}

function GamepadGetKey() {
	var gp_num = gamepad_get_device_count();
	for ( var dev=0 ; dev<gp_num ; dev++ ) {
		if ( gamepad_is_connected(dev) ) {
			if gamepad_button_check(dev, gp_face1) return [KEY.FACE1,dev];
			if gamepad_button_check(dev, gp_face2) return [KEY.FACE2,dev];
			if gamepad_button_check(dev, gp_face3) return [KEY.FACE3,dev];
			if gamepad_button_check(dev, gp_face4) return [KEY.FACE4,dev];
			if gamepad_button_check(dev, gp_shoulderl) return [KEY.LEFT_SHOULDER,dev];
			if gamepad_button_check(dev, gp_shoulderlb) return [KEY.LEFT_TRIGGER,dev];
			if gamepad_button_check(dev, gp_shoulderr) return [KEY.RIGHT_SHOULDER,dev];
			if gamepad_button_check(dev, gp_shoulderrb) return [KEY.RIGHT_TRIGGER,dev];
			if gamepad_button_check(dev, gp_select) return [KEY.SELECT,dev];
			if gamepad_button_check(dev, gp_start) return [KEY.START,dev];
			if gamepad_button_check(dev, gp_stickl) return [KEY.LEFT_JOYSTICK_CLICK,dev];
			if gamepad_button_check(dev, gp_stickr) return [KEY.RIGHT_JOYSTICK_CLICK,dev];
			if gamepad_button_check(dev, gp_padu) return [KEY.PAD_UP,dev];
			if gamepad_button_check(dev, gp_padd) return [KEY.PAD_DOWN,dev];
			if gamepad_button_check(dev, gp_padl) return [KEY.PAD_LEFT,dev];
			if gamepad_button_check(dev, gp_padr) return [KEY.PAD_RIGHT,dev];
			
			if ( gamepad_axis_value(dev, gp_axislh) > ANALOGUE_THRESHOLD ) return [KEY.LEFT_JOYSTICK_RIGHT,dev];
			if ( gamepad_axis_value(dev, gp_axislh) < -ANALOGUE_THRESHOLD ) return [KEY.LEFT_JOYSTICK_RIGHT,dev];
			if ( gamepad_axis_value(dev, gp_axislv) > ANALOGUE_THRESHOLD ) return [KEY.LEFT_JOYSTICK_DOWN,dev];
			if ( gamepad_axis_value(dev, gp_axislv) < -ANALOGUE_THRESHOLD ) return [KEY.LEFT_JOYSTICK_UP,dev];
			
			if ( gamepad_axis_value(dev, gp_axisrh) > ANALOGUE_THRESHOLD ) return [KEY.RIGHT_JOYSTICK_RIGHT,dev];
			if ( gamepad_axis_value(dev, gp_axisrh) < -ANALOGUE_THRESHOLD ) return [KEY.RIGHT_JOYSTICK_RIGHT,dev];
			if ( gamepad_axis_value(dev, gp_axisrv) > ANALOGUE_THRESHOLD ) return [KEY.RIGHT_JOYSTICK_DOWN,dev];
			if ( gamepad_axis_value(dev, gp_axisrv) < -ANALOGUE_THRESHOLD ) return [KEY.RIGHT_JOYSTICK_UP,dev];
		}
	}
	
	return -1;
}

function MouseGetKey() {
	if mouse_check_button(mb_left) return KEY.LEFT_CLICK;
	if mouse_check_button(mb_right) return KEY.RIGHT_CLICK;
	if mouse_check_button(mb_middle) return KEY.MIDDLE_CLICK;
	if mouse_wheel_up() return KEY.WHEEL_UP;
	if mouse_wheel_down() return KEY.WHEEL_DOWN;
	
	return -1;
}

function InputUpdateCallback() {
	if ( event_type == ev_draw && event_number == ev_gui_end ) { Input.Update(); }
}

#region SET THE UPDATE METHOD AS A LAYER SCRIPT IN EVERY LISTED ROOM
	var i = 0;
	while(room_exists(i)) {
		layer_set_target_room(i);
		layer_script_begin(layer_create(0, "InputLayer"), InputUpdateCallback);
		i++;
	}
	layer_reset_target_room();
#endregion