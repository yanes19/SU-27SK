var smoke_launcher = func {
	var pylon8ld ="sim/weight[7]/selected";
	var pylon7ld ="sim/weight[6]/selected";
	var pylon8Launch  = "su-27/WCS/pylon8/launch";
	var pylon7Launch  = "su-27/WCS/pylon7/launch";
	setprop("sim/multiplay/generic/int[0]" ,1);
	if (getprop(pylon8ld) == "smoke-blue" or getprop(pylon8ld) == "smoke-red" or getprop(pylon8ld) == "smoke-yellow")
		{if (getprop(pylon8Launch) == 0) { setprop(pylon8Launch ,1)}
		elsif (getprop(pylon8Launch) == 1) {setprop(pylon8Launch ,0)}
	}
	
	if (getprop(pylon7ld) == "smoke-blue" or getprop(pylon7ld) == "smoke-red" or getprop(pylon7ld) == "smoke-yellow")
	{if (getprop(pylon7Launch) == 0) {setprop(pylon7Launch ,1)}
	elsif (getprop(pylon7Launch) == 1) {setprop(pylon7Launch ,0)}
	}
}
