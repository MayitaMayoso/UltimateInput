// Create an instance of the input manager
inputManager = new InputManager();

// Bind the input manager to a macro so we can avoid calling System making it less verbose
#macro Input System.inputManager

// Configure the inputs next frame so gamepads are propperly detected
// You can use Alarms, Time sources, or any method you want.
alarm[0] = 1;
