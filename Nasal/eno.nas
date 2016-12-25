
#### Eno ####

    ###
	# Settings
	     var door =  "canopy/position-norm";
	     var max = 0.85; # Maximum volume when internal and door open
	     var min = 0.2; # Volume when internal and door closed (what makes it through the door)
	     var multiplier = 6; # How quickly volume reaches maximum as door opens

var init = func {

     print("Initialising Eno");
	 props.globals.initNode("sim/sound/eno/initialised",1,"BOOL");
	 props.globals.initNode("sim/sound/eno/volume-out",1,"DOUBLE");
	 var mpvol = props.globals.getNode("sim/sound/aimodels/volume").getValue();
	 props.globals.getNode("sim/sound/eno/masters/aimodels",1).setValue(0.8);
	 timer.start();
	
	}
	
var loop = func() {
	 var doorpos = props.globals.getNode(door).getValue();
	 var view = props.globals.getNode("sim/current-view/internal").getBoolValue();
	 var out = ( doorpos * multiplier );
	 var mplevel = props.globals.getNode("sim/sound/eno/masters/aimodels",1).getValue();
	 if ( out > max ) { out = max };
	 if ( out < min ) { out = min };
	 if ( !view ) { out = 1 };
	 setprop("sim/sound/eno/volume-out", out);
	 setprop("sim/sound/aimodels/volume", ( out * mplevel ));
	}

var timer = maketimer(0.05, loop);
