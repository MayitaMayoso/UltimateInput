function InputManager() : Component() constructor {

	#region PRIVATE ATTRIBUTES AND METHODS TO MANAGE THE STRUCT

	static DrawGUIEnd = function() {
		// Last checked input was keyboard or mouse
		if (
			keyboard_check_pressed(vk_anykey)
			|| point_distance(
				mouse_screen_x_previous,
				mouse_screen_y_previous,
				mouse_screen_x,
				mouse_screen_y
			)
			|| MouseGetKey() != -1
		) {
			keyboard_or_gamepad = 0;
		}

		// Last checked input was a gamepad
		if (GamepadGetKey() != -1) {
			keyboard_or_gamepad = 1;
		}

		// Update the mouse_x_previous and mouse_y_previous macros
		mouse_x_previous = mouse_x;
		mouse_y_previous = mouse_y;
		mouse_screen_x_previous = mouse_screen_x;
		mouse_screen_y_previous = mouse_screen_y;
	};

	static StepBegin = function() {
		// Update every input
		for (var i = 0; i < array_length(profiles); i++) {
			profiles[i].Update();
		}
	};

	static GetProfile = function(profile) {
		for (var i = 0; i < array_length(profiles); i++) {
			if (profiles[i].name == profile) {
				return profiles[i];
			}
		}
		return -1;
	};

	static GetKeys = function(profile) {
		var newConf = GetProfile(profile);

		if (newConf != -1) {
			return newConf.GetKeys();
		}
		return -1;
	};

	static toString = function(tab = "") {
		var str = tab + "InputManager [\n";
		for (var i = 0; i < array_length(profiles); i++) {
			str += tab + profiles[i].toString(tab + "\t") + "\n";
		}
		str += tab + "]";

		return str;
	};

	#endregion

	#region MODIFIERS

	static AddProfile = function(profile) {
		var newConf = GetProfile(profile);
		if (newConf == -1) {
			profiles[array_length(profiles)] = new InputProfile(profile);
		}
		currentProfile = profile;
	};

	static SetProfile = function(profile) {
		var newConf = GetProfile(profile);
		if (newConf != -1) {
			currentProfile = profile;
		}
	};

	static AddInstance = function(
		input,
		long_press_time = LONG_PRESS_TIME,
		double_tap_time = DOUBLE_TAP_TIME,
		repeated_time = REPEATED_TIME
	) {
		var profile = GetProfile(currentProfile);
		if (profile != -1) {
			profile.AddInstance(input, long_press_time, double_tap_time, repeated_time);
		}
	};

	static AddKey = function(input, key, device = -1) {
		if (device == -1) {
			for (var i = 0; i < gamepad_get_device_count(); i++) {
				if (gamepad_is_connected(i)) {
					device = i;
					break;
				}
			}
		}
		var profile = GetProfile(currentProfile);
		if (profile != -1) {
			profile.AddKey(input, key, device);
		}
	};

	static DeleteProfile = function(input) {
		var len = array_length(profiles);
		for (var i = 0; i < len; i++) {
			var profile = profiles[i];
			if (profile.name == input) {
				profile.FreeInstances();
				delete profile;
				for (var j = i + 1; j < len; j++) {
					profiles[j - 1] = profiles[j];
				}
				array_resize(profiles, len - 1);
				return;
			}
		}
	};

	static ClearProfiles = function() {
		for (var i = array_length(profiles) - 1; i >= 0; i--) {
			DeleteProfile(profiles[i].name);
		}
	};

	static Save = function() {
		var file = file_text_open_write(INPUT_CONFIGURATION_SAVE_FILE);

		for (var i = 0; i < array_length(profiles); i++) {
			profiles[i].Save(file);
		}

		file_text_close(file);
	};

	static Load = function() {
		if (!file_exists(INPUT_CONFIGURATION_SAVE_FILE)) {
			return -1;
		}

		var file = file_text_open_read(INPUT_CONFIGURATION_SAVE_FILE);

		while (!file_text_eof(file)) {
			var line = StringSplit(file_text_read_string(file), ";");
			file_text_readln(file);

			var lastInst;

			switch (line[0]) {
				case "c":
					SetProfile(line[1]);
					break;
				case "i":
					AddInstance(line[1], real(line[2]), real(line[3]));
					lastInst = line[1];
					break;
				case "k":
					AddKey(lastInst, StringToKey(line[1]), real(line[2]));
					break;
			}
		}

		file_text_close(file);
		return 1;
	};

	static ChangeKey = function(key, accept, cancel, bannedKeys = []) {
		if (!listening) {
			if (accept) {
				listening = true;
				keysReleased = false;
			}
		} else {
			if (cancel) {
				listening = false;
			} else {
				var newKey = GetCurrentKey();
				if (newKey == -1) {
					keysReleased = true;
				} else {
					if (keysReleased && !IsIn(newKey[0], bannedKeys)) {
						key.init(newKey[0], newKey[1]);
						listening = false;
					}
				}
			}
		}
	};

	#endregion

	#region CHECKERS

	static _CheckGeneral = function(input, profile, type) {
		if (!is_array(profile)) {
			profile = [profile];
		}

		var inputVal = false;

		for (var c = 0; c < array_length(profile); c++) {
			var newConf = GetProfile(profile[c]);
			if (newConf != -1) {
				inputVal = max(inputVal, newConf.Check(input, type));
			}
		}

		return inputVal;
	};

	static Check = function(input, profile = currentProfile) {
		return _CheckGeneral(input, profile, "hold");
	};

	static CheckPressed = function(input, profile = currentProfile) {
		return _CheckGeneral(input, profile, "pressed");
	};

	static CheckReleased = function(input, profile = currentProfile) {
		return _CheckGeneral(input, profile, "released");
	};

	static CheckLong = function(input, profile = currentProfile) {
		return _CheckGeneral(input, profile, "long");
	};

	static CheckLongPressed = function(input, profile = currentProfile) {
		return _CheckGeneral(input, profile, "longpressed");
	};

	static CheckLongReleased = function(input, profile = currentProfile) {
		return _CheckGeneral(input, profile, "longreleased");
	};

	static CheckDouble = function(input, profile = currentProfile) {
		return _CheckGeneral(input, profile, "double");
	};

	static CheckRepeated = function(input, profile = currentProfile) {
		return _CheckGeneral(input, profile, "repeated");
	};

	static CheckRepeatedLong = function(input, profile = currentProfile) {
		return _CheckGeneral(input, profile, "repeatedlong");
	};

	static CheckValue = function(input, profile = currentProfile) {
		return _CheckGeneral(input, profile, "value");
	};

	#endregion

	profiles = [];
	currentProfile = "Default";
	listening = false;
	keysReleased = false;
	
	_InputConfigurationCallbackTimeSource = time_source_create(time_source_game, 1, time_source_units_frames, InputConfiguration);
	time_source_start(_InputConfigurationCallbackTimeSource);
}
