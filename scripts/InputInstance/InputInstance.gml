function InputInstance(name, long_press_time, double_tap_time, repeated_time) constructor {
	self.name = name;
	self.keys = [];
	self.long_press_time = long_press_time;
	self.double_tap_time = double_tap_time;
	self.repeated_time = repeated_time;
	
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
		
		// REGULAR TAP			
		var previous_state = self.hold;
		self.hold = self.value > 0;
			
		self.pressed = ( self.hold && !previous_state );
		self.released = ( !self.hold && previous_state );
			
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
	};

	static AddKey = function(key, device) {
        for (var i=0; i<array_length(self.keys); i++) {
            if ( self.keys[i].key == key ) return -1;
        }
		
		var newKey = new InputKey(key, device);
		newKey.par = self;
		self.keys[array_length(self.keys)] = newKey;
	};
		
	static FreeKeys = function() {
		for( var i = 0 ; i < array_length(self.keys) ; i++ ) {
			delete self.keys[i];
		}
		array_resize(self.keys,0);
	};
		
	static toString = function(tab="") {
		var str = tab + "Instance " + self.name + " (" + (self.value ? "true" : "false") + ") [ ";
		
		for(var i=0 ; i<array_length(self.keys); i++) {
			str += self.keys[i].toString() + (i<array_length(self.keys)-1 ? ", ": " ");
		}
		
		str += "]"
		return str;
	};

	static Save = function(file) {
		file_text_write_string(file, "i;" + self.name + ";" + string(self.long_press_time) + ";" + string(self.double_tap_time) + ";" + string(self.repeated_time) + "\n");
		for( var i = 0 ; i < array_length(self.keys) ; i++ ) {
			self.keys[i].Save(file);
		}
	};
};