

print("Loading engines module...");

var StartAuto = func {
		setprop("controls/electric/external-power",1);

		var start1 = func { setprop("/controls/engines/engine/cutoff", 0) };
		var start2 = func { setprop("/controls/engines/engine[1]/cutoff", 0) };
		
		setprop ("controls/engines/engine/starter", 1);
		setprop ("controls/engines/engine[1]/starter", 1);
		
		setprop ("controls/engines/engine/fuel-pump", 1);
		setprop ("controls/engines/engine[1]/fuel-pump", 1);
		
		gui.popupTip("Autostarting...");
		print("engines.autostart executed");
		settimer(start1, 3);
		settimer(start2, 16);
}

var StopAuto = func {
		var stop1 = func { setprop("/controls/engines/engine/cutoff", 1) };
		var stop2 = func { setprop("/controls/engines/engine[1]/cutoff", 1) };
		gui.popupTip("Autoshutdown...");
		print("engines.autostop executed");
		settimer(stop1, 3);
		settimer(stop2, 7);
}

var autostart = func {
			if (getprop ("engines/engine/running") == 1){StopAuto();}
			else {StartAuto()};
			

}




var startEngine1_Button = func {
# TO DO : The fuel pumps and cutoffs are put here !
#they should be moved to their respective contorl areas as their switches 
#get modeled and installed in the cockpit.
# TO DO -2-:move the throttle to startup position in order to start
var VDCBus1volts = getprop("systems/electrical/VDC-bus");
var VDCBus4volts = getprop("systems/electrical/VDC-bus[4]");
var startSwitch_1_Pos = getprop("su-27/instrumentation/Energy-Engines-panel/Crank-Start-APU-Left-pos");
if (VDCBus1volts>23 or VDCBus4volts> 23){	
	if (startSwitch_1_Pos == 0){
	var cutoffFalse = func { setprop("/controls/engines/engine[0]/cutoff", 0) };	
	setprop("controls/engines/engine[0]/cutoff", 1);
	setprop ("controls/engines/engine[0]/fuel-pump", 1);	
	setprop ("controls/engines/engine[0]/starter", 1);
	settimer(cutoffFalse, 3);
	}
	if (startSwitch_1_Pos == 1){
	setprop("controls/engines/engine[0]/cutoff", 1);
	setprop ("controls/engines/engine[0]/starter", 1);
	}
	if (startSwitch_1_Pos == -1){
	setprop("controls/engines/engine[0]/cutoff", 1);
	setprop ("controls/engines/engine[0]/starter", 1);
	}
	}
}


var startEngine2_Button = func {
# TO DO : The fuel pumps and cutoffs are put here !
#they should be moved to their respective contorl areas as their switches 
#get modeled and installed in the cockpit.
# TO DO -2-:move the throttle to startup position in order to start
var VDCBus1volts = getprop("systems/electrical/VDC-bus");
var VDCBus4volts = getprop("systems/electrical/VDC-bus[4]");
var startSwitch_2_Pos = getprop("su-27/instrumentation/Energy-Engines-panel/Crank-Start-APU-Right-pos");
if (VDCBus1volts>23 or VDCBus4volts> 23){	
	if (startSwitch_2_Pos == 0){
	var cutoffFalse = func { setprop("/controls/engines/engine[1]/cutoff", 0) };	
	setprop("controls/engines/engine[1]/cutoff", 1);
	setprop ("controls/engines/engine[1]/fuel-pump", 1);	
	setprop ("controls/engines/engine[1]/starter", 1);
	settimer(cutoffFalse, 3);
	}
	if (startSwitch_2_Pos == 1){
	setprop("controls/engines/engine[1]/cutoff", 1);
	setprop ("controls/engines/engine[1]/starter", 1);
	}
	if (startSwitch_2_Pos == -1){
	setprop("controls/engines/engine[1]/cutoff", 1);
	setprop ("controls/engines/engine[1]/starter", 1);
	}
	}
}

var fuelpumpcheck = func{
	if(getprop ("engines/engine/running")){
		setprop("controls/engines/engine/fuel-pump", 1);
	}
	if(getprop ("engines/engine[1]/running")){
		setprop("controls/engines/engine[1]/fuel-pump", 1);
	}
}

settimer(fuelpumpcheck,3);