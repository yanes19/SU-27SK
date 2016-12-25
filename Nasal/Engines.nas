

print("Loading engines module...");

var StartAuto = func {
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
