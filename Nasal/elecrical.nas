#Elecrical helper routines


var GndPowerToggle = func {
	var GndPower = getprop("controls/electric/external-power");
	if (GndPower == 1){GndPowerOFF();}
	else{GndPowerON();}
	}
	
var GndPowerON =func{
	setprop("systems/electrical/suppliers/external[0]" , 220);
	setprop("controls/electric/external-power" , 1);
	gui.popupTip("Ground power ON");
	}
var GndPowerOFF =func{
	setprop("systems/electrical/suppliers/external[0]" , 0);
	setprop("controls/electric/external-power" , 0);
	gui.popupTip("Ground power OFF");
	}
	
	#Ground power comes as "AC:220v" , we want some of it converted to "DC:24v"
var GndPowerConverter = func {
	var GndPower = getprop("controls/electric/external-power");
	var GndPowerVoltage = getprop("systems/electrical/suppliers/external[0]");
	if (GndPower == 1 and GndPowerVoltage > 215)
	{
		#ffgfg
	}
	}
	
