// Create an instance of the input manager 
inputManager = new InputManager();

// Bind the input manager to a macro so we can avoid calling System making it less verbose
#macro Input System.inputManager

// Load the Configuration of inputs
ConfigurationOfInputs();