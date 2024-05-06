global.system_defined = false;

function Component() constructor {

    #region EVENTS
    
        static Create = function() {};
        
        static Destroy = function() {};
        
        static Step = function() {};
        
        static StepBegin = function() {};
        
        static StepEnd = function() {};
        
        static FixedStep = function() {};
        
        static Draw = function() {};
        
        static DrawBegin = function() {};
        
        static DrawEnd = function() {};
        
        static DrawGUI = function() {};
        
        static DrawGUIBegin = function() {};
        
        static DrawGUIEnd = function() {};
        
        static DrawPre = function() {};
        
        static DrawPost = function() {};
        
        static RoomStart = function() {};
        
        static RoomEnd = function() {};
        
        static CleanUp = function() {};
        
    #endregion
    
    #region PUBLIC METHODS
    
        static Remove = function() {
			// if (global.system_defined) {
		 //           System.destroyedQueue.Push(id);
			// }
        }
    
        static toString = function() {
            return "Component " + type + "(" + string(id) + ")";
        }
    
    #endregion

	/* I use this code when I have other managers (Camera, Time, Input, etc...) controlled by the same 
	*/
	
	// if (global.system_defined) {
	//     static totalComponents = 0;
	//     id = totalComponents++;

	//     type = instanceof(self);
	//     enabled = true;
    
	//     // Register the component on the system
	//     System.components.Push(self);
	// 	System.createdQueue.Push(id);
	// }
}
