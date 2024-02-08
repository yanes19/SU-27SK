
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
	var myRadar = nil;
	
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
		"su-27/instrumentation/RSBN/AER",	#To save lastest landing freqs For lazy people ;)
		"instrumentation/nav/radials/selected-deg",
	
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
	    myRadar = radar.Radar.new();
		myRadar.init();
		crash.repairMe();
		var hyd_fc = compat_failure_modes.set_unserviceable("systems/hydraulic");
		FailureMgr.add_failure_mode("systems/hydraulic", "Hydraulic", hyd_fc);
		var fire_fc = compat_failure_modes.set_unserviceable("damage/fire");# will make smoke trail when damaged
		FailureMgr.add_failure_mode("damage/fire", "Fire", fire_fc);
		var wcs_fc = compat_failure_modes.set_unserviceable("systems/wcs");# will make smoke trail when damaged
		FailureMgr.add_failure_mode("systems/wcs", "WCS", wcs_fc);
		if  (getprop("fdm/jsbsim/gear/wow")== 0 ) {
			if (getprop ("engines/engine/running") != 1){
			misc.autostart();
			setprop ("systems/SAU/active", 1);
			ACS.SAU_AutoLevel();
			setprop ("controls/gear/gear-down", 0);
			setprop ("autopilot/locks/speed", "speed-with-throttle");
			setprop ("autopilot/settings/target-speed-kt", 350);}
		    print("	-In Air startup detected : \n 	- Autostarting engines. \n	- Engaging Autoleveller. ");
		}else{
			setprop ("controls/gear/gear-down", 1);
			setprop("controls/ctrl/gear-down",1);
		}
		#eno.init();
		auxloop.start();
		hydraulic_loop();
		
	}
	
	
	###
	# Difficulty
	var diffprop = props.globals.getNode( diff_root~"/difficult-mode",1 );
	if ( diffprop.getBoolValue() ) { difficulty = 1 };
	diffprop.setBoolValue(difficulty);
	
	###
	# Maintenance
    
	###
	# Hydraulic
	# TODO: Enhance this!
	var hydraulic_loop=func{
		if(getprop("/sim/failure-manager/systems/hydraulic/failure-level"))setprop("/systems/hydraulic/pump/serviceable",0);
		else setprop("/systems/hydraulic/pump/serviceable",1);
		if(getprop("/systems/hydraulic/pump/switch") and (getprop("/systems/electrical/VDC-bus[0]")>20) and getprop("/systems/hydraulic/pump/serviceable")){
			setprop("/systems/hydraulic/pump/run",1);
		}else{
			setprop("/systems/hydraulic/pump/run",0);
		}
		if(getprop("/systems/hydraulic/pump/run")){
			var n2sum = getprop("/engines/engine[0]/n2") + getprop("/engines/engine[1]/n2");
			setprop("/systems/hydraulic/pump/pressure",math.min(100, n2sum * 5.0));
		}else setprop("/systems/hydraulic/pump/pressure",0);
		settimer(hydraulic_loop,0.5);
	};

	
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

	setlistener("sim/crashed",func{if(getprop("sim/crashed")){setprop("sim/explode","true");settimer(func{setprop("sim/explode","false");},2)}});
	
	#settimer(hydraulic_loop,2);

var flares = func{
	var flarerand = rand();
props.globals.getNode("/rotors/main/blade[3]/flap-deg").setValue(flarerand);
props.globals.getNode("/rotors/main/blade[3]/position-deg").setValue(flarerand);
settimer(func   {
    props.globals.getNode("/rotors/main/blade[3]/flap-deg").setValue(0);
    props.globals.getNode("/rotors/main/blade[3]/position-deg").setValue(0);
                },1);

}