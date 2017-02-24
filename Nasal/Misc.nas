
var autostart = func {
	
	#Engines
	if (getprop ("engines/engine/running") == 1){engines.StopAuto();}
	else {engines.StartAuto()};
	#Canopy
	su27.canopy.toggle();
	#Lights
	if (getprop("controls/lighting/nav-lights-switch")==1){setprop("controls/lighting/nav-lights-switch",0);}
		
	else {setprop("controls/lighting/nav-lights-switch",1)}
		
	if (getprop("controls/lighting/beacon-switch")==1){setprop("controls/lighting/beacon-switch",0);}
		
	else {setprop("controls/lighting/beacon-switch",1)};
	
	if (getprop("/controls/lighting/landing-lights")==1){setprop("/controls/lighting/landing-lights",0);}
		
	else {setprop("/controls/lighting/landing-lights",1)};

}
