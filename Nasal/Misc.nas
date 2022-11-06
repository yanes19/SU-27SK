
var autostart = func {
	
	#Engines
	if (getprop ("engines/engine/running") == 1){
		engines.StopAuto();
		su27.canopy.open();}
	else {engines.StartAuto();
	#Canopy
	su27.canopy.close();};
	
	
	#Lights
	if (getprop("controls/lighting/nav-lights-switch")==1){setprop("controls/lighting/nav-lights-switch",0);}
		
	else {setprop("controls/lighting/nav-lights-switch",1)}
		
	if (getprop("controls/lighting/beacon-switch")==1){setprop("controls/lighting/beacon-switch",0);}
		
	else {setprop("controls/lighting/beacon-switch",1)};
	
	if (getprop("/controls/lighting/landing-lights")==1){setprop("/controls/lighting/landing-lights",0);}
		
	else {setprop("/controls/lighting/landing-lights",1)};

}

var operateAntiIce = func{
	if (getprop("su-27/instrumentation/Energy-Engines-panel/Anti-ice-switch-pos")== -1){
	setprop("controls/anti-ice/wing-heat",1);
	setprop("controls/anti-ice/pitot-heat",1);
	setprop("controls/anti-ice/engine/inlet-heat",1);
	setprop("controls/anti-ice/engine[1]/inlet-heat",1);
	}else{
	setprop("controls/anti-ice/wing-heat",0);
	setprop("controls/anti-ice/pitot-heat",0);
	setprop("controls/anti-ice/engine/inlet-heat",0);
	setprop("controls/anti-ice/engine[1]/inlet-heat",0);
	
	}
}
