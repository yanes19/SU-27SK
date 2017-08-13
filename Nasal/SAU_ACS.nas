#ACS SAU and AP helper functions 

var HoldBaroAlt = func {
	var SAU_Active = getprop("systems/SAU/active");
	var SAU_Ready = getprop("systems/SAU/ready");
	var SAU_serviceable = getprop("systems/SAU/serviceable");
	var Current_BarAlt = getprop("position/altitude-ft");
	if (SAU_Ready == 1 and SAU_Active == 1 and Current_BarAlt > 0)  # and SAU_serviceable == "true"
	   { 
	   setprop("autopilot/settings/target-altitude-ft" , Current_BarAlt);
	   setprop("autopilot/locks/altitude" , "altitude-hold"); 
	   print ("SAU:Hold BarAltitude engaged ! Altitude set : " , Current_BarAlt );
	   }   
}

var SAUNavigHold = func {
	var SAU_Active = getprop("systems/SAU/active");
	var SAU_Ready = getprop("systems/SAU/ready");
	var SAU_serviceable = getprop("systems/SAU/serviceable");
	var Current_BarAlt = getprop("position/altitude-ft");
	var RoutMgrActive = getprop("autopilot/route-manager/active");
	var PNK_Mode = getprop("su-27/instrumentation/PNK-10/active-mode");
	if (SAU_Ready == 1 and SAU_Active == 1 and Current_BarAlt > 0)  # and SAU_serviceable == "true"
	   {
#	   if (RoutMgrActive == 1) {
#	   setprop("autopilot/locks/heading" , "true-heading-hold");
#	   print ("SAU:Navig mode engaged ! Route: Active");
#	   }
#	   else {setprop("systems/SAU/ready" , 0);
#	   print ("SAU:Navig mode NOT engaged ! No active route !");
#	   }
#	   }   
	if (RoutMgrActive == 1){
		if(PNK_Mode == 0){
			setprop("autopilot/locks/heading" , "true-heading-hold");
		print ("SAU engaged : Following PNK-10 'PROGRAM' route mode ")
		}
		if (PNK_Mode == 1){setprop("autopilot/locks/heading" ,"nav1-hold");
		setprop("autopilot/locks/altitude" , "altitude-hold"); 
		print ("SAU engaged : Following PNK-10 'RSBN NAVIG' mode ")}
	}
	}	
	print ("end of SAUNavigHold Proc"); 
}


var SAU_Reset = func {
    setprop("autopilot/locks/heading" , "");
    setprop("autopilot/locks/altitude" , "");
	  setprop("autopilot/locks/speed" , "");
		setprop("systems/SAU/ready", 1);
}

var SAU_Auto =func {
	var SAU_Active = getprop("systems/SAU/active");
	var SAU_Ready = getprop("systems/SAU/ready");
	var SAU_serviceable = getprop("autopilot/SAU/serviceable");
	var Current_Pitch = getprop("orientation/pitch-deg");
	var Current_roll = getprop("orientation/roll-deg"); 
	var Current_BarAlt = getprop("position/altitude-ft");
	if (SAU_Ready == 1 and SAU_Active == 1 and Current_BarAlt > 0)  # and SAU_serviceable == "true"
	{
	setprop("autopilot/settings/target-pitch-deg" , Current_Pitch);
	setprop("autopilot/locks/altitude" , "pitch-hold");
	setprop("autopilot/internal/target-roll-deg" , Current_roll);
	setprop("autopilot/locks/heading" , "roll-hold");

	print ("SAU:Auto Mode engaged ! pitch set : " , Current_Pitch ,"Roll set : " ,Current_roll);
	}
}

var gs_follow =func{
	var SAU_Active = getprop("systems/SAU/active");
	var SAU_Ready = getprop("systems/SAU/ready");
	var SAU_LOC = getprop("autopilot/locks/heading");
	if (SAU_Ready == 1 and SAU_Active == 1 and SAU_LOC =="LOC")
	{
	if (getprop("instrumentation/nav/gs-in-range")==1){setprop("autopilot/locks/altitude" ,"gs1-hold");}
	}
	settimer(gs_follow, 1.0);
}

var SAU_Land =func {
	var SAU_Active = getprop("systems/SAU/active");
	var SAU_Ready = getprop("systems/SAU/ready");
	print ("SAU:LOC Mode requested ! ");
	if (SAU_Ready == 1 and SAU_Active == 1)  # and SAU_serviceable == "true"<-- removed cause verif shloud be done on "SAU active" switching>
	{
	setprop("autopilot/locks/heading" ,"LOC");
	setprop("autopilot/settings/target-altitude-ft",2800);
	setprop("autopilot/locks/altitude","altitude-hold");
	
	gs_follow();
	print ("SAU:LOC Mode engaged ! ");

	}
	
}

var SAU_Nav1Follow =func {
	var SAU_Active = getprop("systems/SAU/active");
	var SAU_Ready = getprop("systems/SAU/ready");
	if (SAU_Ready == 1 and SAU_Active == 1)  # and SAU_serviceable == "true"<-- removed cause verif shloud be done on "SAU active" switching>
	{
	setprop("autopilot/locks/heading" ,"nav1-hold");


	print ("SAU:Nav1 follow Mode engaged ! ");

	}
	
}

var SAU_AutoLevel =func {
#This does what expected from the stick Leveller button(Called sometimes "dont panic button")
	var SAU_Active = getprop("systems/SAU/active");
	var SAU_Ready = getprop("systems/SAU/ready");
	if (SAU_Ready == 1 and SAU_Active == 1)  # and SAU_serviceable == "true"<-- removed cause verif shloud be done on "SAU active" switching>
	{
	if (getprop("autopilot/locks/heading")!="wing-leveler"){
	setprop("autopilot/settings/target-pitch-deg" ,1);
	setprop("autopilot/locks/heading" ,"wing-leveler");
	setprop("autopilot/locks/altitude" ,"pitch-hold");
	print ("SAU:Wings leveller Mode engaged ! ");
	}
	else{
	setprop("autopilot/locks/heading" ,"");
	setprop("autopilot/locks/altitude" ,"");	
	}
	}
	
}

