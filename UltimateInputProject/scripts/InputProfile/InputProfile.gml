function InputProfile(name) constructor {
	// General variables
	self.name = name;
	self.instances = [];

	static GetInstance = function(name) {
		for (var i = 0; i < array_length(self.instances); i++) {
			if (self.instances[i].name == name) {
				return self.instances[i];
			}
		}
		return -1;
	};

	static Check = function(input, type) {
		var inst = GetInstance(input);

		if (inst != -1) {
			switch (type) {
				case "hold":
					return inst.hold;
					break;
				case "pressed":
					return inst.pressed;
					break;
				case "released":
					return inst.released;
					break;
				case "long":
					return inst.long;
					break;
				case "longpressed":
					return inst.longPressed;
					break;
				case "longreleased":
					return inst.longReleased;
					break;
				case "double":
					return inst.double;
					break;
				case "repeated":
					return inst.repeated;
					break;
				case "repeatedlong":
					return inst.repeatedLong;
					break;
				case "value":
					return inst.value;
					break;
			}
		}

		return -1;
	};

	static Update = function() {
		for (var i = 0; i < array_length(self.instances); i++) {
			self.instances[i].Update();
		}
	};

	static AddInstance = function(name, long_press_time, double_tap_time, repeated_time) {
		if (GetInstance(name) != -1) {
			return -1;
		}
		self.instances[array_length(self.instances)] = new InputInstance(
			name,
			long_press_time,
			double_tap_time,
			repeated_time
		);
	};

	static AddKey = function(input, key, device) {
		var newInst = self.GetInstance(input);
		if (newInst == -1) {
			return -1;
		}
		newInst.AddKey(key, device);
	};

	static FreeInstances = function() {
		for (var i = 0; i < array_length(self.instances); i++) {
			self.instances[i].FreeKeys();
		}
	};

	static toString = function(tab = "") {
		var str = tab + "Configuration " + self.name + " [\n";
		for (var i = 0; i < array_length(self.instances); i++) {
			str += tab + self.instances[i].toString(tab + "\t") + "\n";
		}
		str += tab + "]";
		return str;
	};

	static Save = function(file) {
		file_text_write_string(file, "c;" + self.name + "\n");
		for (var i = 0; i < array_length(self.instances); i++) {
			self.instances[i].Save(file);
		}
	};

	static GetKeys = function() {
		var arr = [];
		for (var i = 0; i < array_length(self.instances); i++) {
			for (var j = 0; j < array_length(self.instances[i].keys); j++) {
				arr[array_length(arr)] = self.instances[i].keys[j].key;
			}
		}
		return arr;
	};
}
