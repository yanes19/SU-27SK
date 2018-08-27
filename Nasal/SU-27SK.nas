
    ################################
    ## English Electric Lightning F6
    ## Master Nasal
	
	################################
	## Settings
	
	###
	# Owner Options
	var difficulty         = 0; # Set to 1 for advanced handling options e.g. engine overspeed, mach trim etc.
	var real_maintenance   = 1; # Set to 1 for real maintenance conditions
	var maintenance_report = 1; # Set to 1 for a console maintenance report at startup
	
	###
	# Propery Roots - usually no need to change these
	var diff_root = "sim/difficulty";
	var rm_root   = "sim/maintenance";
    
	var doorpath = "canopy";
	var doorpos = 1; 
	
	###
	# Presets 
	
	var acname = "SU-27SK"; # Script Display Name
	var main_loop_interval = 1; # Main loop update period in seconds
	var aux_loop_interval = 60; # Auxiliary loop update period in seconds
	
	################################
	## Objects	
	
	###
	# Doors ( & Canopies )
	
	# Arguments: ( property path, seconds, start position )
	var canopy = aircraft.door.new(doorpath, 5, 1);
			
	###Instrumentation (by Yanes)
	#instrumentation.init_instrumentation();
	
	###
	# Lights
	var lightpath = "sim/model/lights";
	
	

	
	###
	# Airbrakes
	
	
	
	###
	# Saved Data
	
	aircraft.data.load();
	
	var savedata = [
	     # This is a list of properties saved to disk every 60 seconds
		"sim/maintenance/airframe-seconds",
		"sim/maintenance/engine[0]/operating-seconds",
		"sim/maintenance/engine[1]/operating-seconds",
	
	];
	aircraft.data.add(savedata);
	
	################################
	## Initialisation & Internals
	
	### 
	# Loading Message
	print("Loading "~acname~" Master Nasal");
	
	# Check installed modules
	#var rm_loaded = props.globals.getNode("nasal/maintenance/loaded").getBoolValue();
	var el_loaded = 0;
	
	###
    # Main Initialise Function
    var init = func {
	   
		print("Initialising "~acname~" Master Nasal...");
		
		var diff_status = "Easy";
		var rm_status = "Off";
		
		if ( props.globals.getNode(diff_root~"/difficult-mode",1).getBoolValue() ) {
		     difficulty = 1;
			}
		
		if ( difficulty ) {	var diff_status = "Difficult" };
		
		# Check loaded modules
		
#		if ( rm_loaded ) { 
		
#		     print("Maintenance module loaded");
			 
#			 if ( real_maintenance ) {
#		         var rm_status = "On"; 
#			    #print("  - Airframe Hours: " ~afhours);
#		         maintenance.init();
#			     maintenance.airframe_hours();	
				
#				if ( maintenance_report ) {
#				     print("\nMaintenance Report:\n==================\n");
#                     var mrep = maintenance.report();
#                     print (mrep);					 
#				    }
#				}
#			}
			
		 if  ( el_loaded ) {
		     print("Electrical System module loaded");
			}
		
		print("  - Difficulty setting: "~diff_status);
		print("  - Maintenance Mode: "~rm_status);
		
		props.globals.getNode(diff_root~"/difficult-mode",1).setBoolValue(difficulty);
		props.globals.getNode(rm_root~"/enabled",1).setBoolValue(real_maintenance);
	  var myRadar = radar.Radar.new();
		myRadar.init();
		if  (getprop("fdm/jsbsim/gear/wow")== 0 ) {
			if (getprop ("engines/engine/running") != 1){
			misc.autostart();
			setprop ("systems/SAU/active", 1);
			ACS.SAU_AutoLevel();
			setprop ("controls/gear/gear-down", 0);
			setprop ("autopilot/locks/speed", "speed-with-throttle");
			setprop ("autopilot/settings/target-speed-kt", 350);}
		    print("	-In Air startup detected : \n 	- Autostarting engines. \n	- Engaging Autoleveller. ");
			}
		#eno.init();
		auxloop.start();
		
	}
	
	
	###
	# Difficulty
	var diffprop = props.globals.getNode( diff_root~"/difficult-mode",1 );
	if ( diffprop.getBoolValue() ) { difficulty = 1 };
	diffprop.setBoolValue(difficulty);
	
	###
	# Maintenance
    
	
	###
	# Loops
	
	var loops = {
	     main: func {
		     
			},
	     aux: func {
		     # print("Aux Loop Looping!"); #Debug
		     if ( props.globals.getNode(rm_root~"/enabled",1).getBoolValue() ) { maintenance.rm_loop(); }
			 
			 # Save
			 aircraft.data.save();
		    },
	};
	
	###
	# Timers
	
	var auxloop = maketimer(aux_loop_interval,loops.aux);
	
	###
	# Go!
	
	setlistener("sim/signals/fdm-initialized", func {
	     settimer( init, 2);
	    });
