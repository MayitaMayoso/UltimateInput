random_set_seed(current_second);
image_alpha = 0;
// The port struct keeps all the properties and methods
// of everything related to displaying the game in the
// different platforms. Here we change the resolution,
// the parameters of the window, etc...
port = {
	// Properties
	/* 
    width : 1920,
    height : 1080,
    fullscreen : true,
    
    /*/ 
    width : 1280,
    height : 720,
    fullscreen : false,
    //*/
    
    // Variables
    aspect : 1,
    center : false,
    
    // Update the canvas every step
    Update : function() {
    	// Calculating the aspect ratio
        aspect = width / height;
        
        // Centering the canvas
        if ( center ) {
            window_center();
            center = false;
        }
        
        // Resizing the desktop canvas
        if ( DESKTOP ) {
            if ( window_get_width() != width || window_get_height() != height ) {
                window_set_size(width, height);
                surface_resize(application_surface, width, height);
                center = true;
            }
            
            if (window_get_fullscreen() != fullscreen) {
            	window_set_fullscreen(fullscreen);
            }
        }
        
        // Resizing the browser canvas
        if ( BROWSER ) {
            if ( browser_width != width || browser_width != height ) {
                width = browser_width; height = browser_height;
                window_set_size(width, height);
                surface_resize(application_surface, width, height);
                center = true;
            }
        }
    }
};

// The view is the portion of the room displayed on the
// port. In this struct we can change the position, size,
/// rotation, scaling, etc...
view = {
	// Properties
    x : room_width/2,
    y : room_height/2,
    z : -room_width/2,
    width : 480,
    height : 270,
    aspect : 1,
    scale : 1,
    fov : radtodeg(2*arctan(144/256)),
	enablePerspective : true,
	xto : 0,
	yto : 0,
	zto : 0,
	xup : 0,
	yup : 1,
	zup : 0,
	
	// Variables
	fixedWidth : 1,
	fixedHeight : 1,
    
    // Update the view every step
    Update : function() {
        // Resize the view
        aspect = Camera.port.width / Camera.port.height;
        if ( aspect > 1 ) {
            fixedWidth = width;
            fixedHeight = width / aspect;
        } else {
            fixedHeight = height;
            fixedWidth = height * aspect;
        }
        
        
        var cam = view_camera[0];
        
        var lookMat, projMat;
        if (!enablePerspective) {
	        lookMat = matrix_build_lookat(x, y, z, xto, yto, zto, 0, -1, 0);
	        projMat = matrix_build_projection_ortho(-fixedWidth * scale, -fixedHeight * scale, 0.01, 10000);
        } else {
        	lookMat = matrix_build_lookat(x, y, z, xto, yto, zto, xup, yup, zup);
			projMat = matrix_build_projection_perspective_fov(-fov, -aspect, 0.01, 10000);
        }
        camera_set_view_mat(cam, lookMat);
        camera_set_proj_mat(cam, projMat);
        camera_apply(cam);
    }
};

// Shake parameters
shake = 0;
damp = .1;

// Scenes camera situations
var s2 = 512;
var s = 256;
sceneCam[0] = [s,	s,	0,		0,	1,	0];
sceneCam[1] = [s2,	s,	-s,		0,	1,	0];
sceneCam[2] = [s,	s2,	-s,		-1,	0,	0];
sceneCam[3] = [s,	s,	-s2,	-1,	0,	0];
sceneCam[4] = [0,	s,	-s,		0,	0,	1];
sceneCam[5] = [s,	0,	-s,		0,	0,	1];
scene = 0;