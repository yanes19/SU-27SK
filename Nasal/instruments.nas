

var ft2m = func(x){if(x!= nil){return x * 0.3048}else {return 0}};


 var init_instrumentation = func {
  #setlistener("su-27/instrumentation/electrical/v27", Instrumentation_voltage_handler,0,0 );
  #setlistener("su-27/instrumentation/electrical/v200", Instrumentation_voltage_handler,0,0 );
	
  PNK_DataUpdate();
  air_speed2kmh();
  alt_meters();
  RV_21();
  PNP_Bearing();
  PNP_SelectedCourseDirector();
  flasher05();
  print ("SU-27 instruments module loaded !");
}


var activeAERfreq = 0;
var PNK_Selectedradials = 0;
var currentWPT = getprop("autopilot/route-manager/current-wp");

var P_184PPMs = func {
	var FreqToSet = "";
	var ActiveFreq = getprop("su-27/instrumentation/PU-184/active-PPM");
	if(ActiveFreq == "9"){ActiveFreq = "su-27/instrumentation/PU-184/NPN"}
	else{ActiveFreq= "su-27/instrumentation/PU-184/PPM"~ActiveFreq}
	#print(ActiveFreq);
	setprop("instrumentation/adf/frequencies/selected-khz", getprop(ActiveFreq));
	}
	

var RSBN_PPMs = func {
	var FreqToSet = "";
	var ActiveFreq = getprop("su-27/instrumentation/RSBN/active-PPM");
	if(ActiveFreq == "9"){ActiveFreq = "su-27/instrumentation/RSBN/NPN"}
	else{ActiveFreq= "su-27/instrumentation/RSBN/PPM"~ActiveFreq}
	#print(ActiveFreq);
	setprop("instrumentation/nav/frequencies/selected-mhz", getprop(ActiveFreq));
	}

var PNK_DataUpdate = func{
	##Continuously update radials from selected navigation device :
	var NavRAdials = getprop("instrumentation/nav/radials/reciprocal-radial-deg");
	var NDBRadials = getprop("instrumentation/adf/indicated-bearing-deg")or 0.00;
	var Hdg = getprop("orientation/heading-deg")or 0.00;
	var WpBearingprop = "autopilot/route-manager/wp/true-bearing-deg";
	var WpBearing = 0;
	if (getprop(WpBearingprop)!= nil){WpBearing = getprop(WpBearingprop)} # if nil PNP12 or SDU fail light should register something !!!!!
	var PNK_Mode = getprop("su-27/instrumentation/PNK-10/active-mode" );
	# PROGRAM Route mode .
	if (PNK_Mode == 0){PNK_Selectedradials = WpBearing};	
	#NAVIG (radio nav ) mode .
	if (PNK_Mode == 1){PNK_Selectedradials = NavRAdials or 0.0;
		RSBN_PPMs()};
	#ARC PU-184 mode .
	if (PNK_Mode == 1.1){PNK_Selectedradials = NDBRadials + Hdg}; 
	#POSADKA/LAND mode should be activated from OC then set the LOC frequency in Nav1 by the selected AER button handler routine
	if (PNK_Mode == 2){
		getActiveAER();
		setprop("instrumentation/nav/frequencies/selected-mhz" ,activeAERfreq);
		#print("activeAERfreq " ~ activeAERfreq);
		PNK_Selectedradials = NavRAdials or 0.0;
		}; 

	setprop("su-27/instrumentation/PNK-10/radial" , PNK_Selectedradials); 
	
	## Read and provide WPT Num. for OnBoard Computer unit .
	var OC_ControllerWpt = getprop("autopilot/route-manager/current-wp") + 1 ;
	setprop("su-27/instrumentation/OC-controller/active-wpt",OC_ControllerWpt);
	# if Current wpt changed , update the desired course :
	if (getprop("autopilot/route-manager/current-wp") != currentWPT){
	setprop("instrumentation/nav/radials/selected-deg",getprop("instrumentation/gps/desired-course-deg"));
	currentWPT = getprop("autopilot/route-manager/current-wp")}
	
	#set PNK-10 altitude value source 
	var indicatedBarAltitude = getprop("su-27/instrumentation/UV-30-3/indicated-altitude-m")or 0;
	var indicatedRadarAltitude =getprop("su-27/instrumentation/Rdr.Altimeter/altitude")or 0;
	var PNK_Altitude = 0;
	var str_PNK_Altitude = "";
	
	if (indicatedRadarAltitude < 1500)
	{PNK_Altitude = indicatedRadarAltitude; 
	str_PNK_Altitude = sprintf("%2d",PNK_Altitude)~"p";
	}else{
	 PNK_Altitude= indicatedBarAltitude;
	 str_PNK_Altitude=sprintf("%2d", indicatedBarAltitude/10)~"0" ;
	 }
	setprop("su-27/instrumentation/PNK-10/str-PNK-Altitude",str_PNK_Altitude);
	setprop("su-27/instrumentation/PNK-10/PNK-Altitude",PNK_Altitude);
	#;
	
	
	settimer(PNK_DataUpdate, 0);
}

var air_speed = 0; 

 var air_speed2kmh = func{
  var air_speed = getprop("instrumentation/airspeed-indicator/indicated-speed-kt" )or 0.00;
#  if (getprop("su-27/instrumentation/ASI/serviceable") == 1)
#   { 
   setprop("su-27/instrumentation/ASI/airspeed-kmh" , air_speed * 1.852 ); 
   
#   }
#  else { 
#  setprop("su-27/instrumentation/ASI/airspeed-kmh" , 0); 
#  }
  settimer(air_speed2kmh, 0);
}

var bar_altitude_ft = 0;
var bar_altitude_m = 0;

 var alt_meters = func {
 
  var bar_altitude_ft = getprop("/instrumentation/altimeter/indicated-altitude-ft") or 0.00;
  var bar_altitude_m = ft2m(bar_altitude_ft);
  setprop("su-27/instrumentation/UV-30-3/indicated-altitude-m", bar_altitude_m);
  settimer(alt_meters, 0)
}

var current_altitude_ft = 0;
var current_altitude_m = 0;
var danger_altitude = 0;

 var RV_21 = func {
 #******* Yanes:TODO: Make all the features below working ! ********************
#  if (getprop("mig29/systems/RV-21/on") == 1 and getprop("mig29/instrumentation/RV-21/serviceable") == 1)
#   {
    var current_altitude_ft = getprop("position/altitude-agl-ft")or 0.00;
    var current_altitude_m = (current_altitude_ft * 0.3048);
#    var danger_altitude = getprop("mig29/instrumentation/RV-21/DAMarker");
#    if (getprop("mig29/systems/RV-21/test") == 0)
#     {
#      if ( current_altitude_m <= danger_altitude )  { setprop("mig29/instrumentation/RV-21/danger_altitude", 1); }
#      else { setprop("mig29/instrumentation/RV-21/danger_altitude", 0); }
#      if ( current_altitude_m > 1500 ) { setprop("mig29/instrumentation/RV-21/indicated-altitude-m", 1510); }
#      else { setprop("mig29/instrumentation/RV-21/indicated-altitude-m", current_altitude_m);}
#     }
    setprop("su-27/instrumentation/Rdr.Altimeter/altitude", current_altitude_m);
#   }
  settimer(RV_21, 0.0);
}

var RawTargetBearing = 0;
var CurrentHeading =0 ;
var IndicatedTargetBearing  =0 ;

 var PNP_Bearing = func {
	var RawTargetBearing =getprop("su-27/instrumentation/PNK-10/radial")or 0.00;
	var CurrentHeading =getprop("orientation/heading-deg")or 0.00;
	var IndicatedTargetBearing  = RawTargetBearing - CurrentHeading ;
	#if (IndicatedTargetBearing > 359){IndicatedTargetBearing = IndicatedTargetBearing - 360}
	setprop("su-27/instrumentation/HSI/IndicatedTrgtourse", IndicatedTargetBearing);
	settimer(PNP_Bearing, 0.0);
 }
var CourseDirectorDeg  =0;
var SelectedCourse =0 ;
var SelCourseDirDegree = 0;

  var PNP_SelectedCourseDirector = func {
	var SelectedCourse =getprop("instrumentation/nav/radials/selected-deg")or 0.00;
	var CurrentHeading =getprop("orientation/heading-deg")or 0.00;
	var SelCourseDirDegree  = SelectedCourse - CurrentHeading ;
	setprop("su-27/instrumentation/HSI/SelectedCourseDirector", SelCourseDirDegree);
	settimer(PNP_SelectedCourseDirector, 0.0);
 }
 
 var flasher05 = func{
 if (getprop("su-27/instrumentation/flasher-anim") == 0){setprop("su-27/instrumentation/flasher-anim", 1)}
 else{setprop("su-27/instrumentation/flasher-anim", 0)}
 settimer(flasher05, 0.5);}
 ### Launch Module Loop
 
init_instrumentation();

### Non looped routines :

var P_184PPMs = func {
	var FreqToSet = "";
	var ActiveFreq = getprop("su-27/instrumentation/PU-184/active-PPM");
	if(ActiveFreq == "9"){ActiveFreq = "su-27/instrumentation/PU-184/NPN"}
	else{ActiveFreq= "su-27/instrumentation/PU-184/PPM"~ActiveFreq}
	#print(ActiveFreq);
	setprop("instrumentation/adf/frequencies/selected-khz", getprop(ActiveFreq));
	}
	
#var ProgramKnob = func{
#	var activeMode = getprop("su-27/instrumentation/PNK-10/active-mode" );
#	if activeMode = 0 ;
#	setprop();
	
#}

##### On-Board computer control unit handler routines

var PPM1btnPress = func{
	#OC ready , so we put it in "wait for ppm" status .
	if(getprop("su-27/instrumentation/OC-controller/status") == 1){
	setprop("su-27/instrumentation/OC-controller/status",3);
	return;}
	#Waiting for PPM ,thus set PPM1 as active
	if(getprop("su-27/instrumentation/OC-controller/status") == 3){
	setprop("su-27/instrumentation/RSBN/active-PPM",1);
	setprop("su-27/instrumentation/OC-controller/status",1);
	RSBN_PPMs();
	return;	}
	#Waiting for AER ,thus set AER1 as active
	if(getprop("su-27/instrumentation/OC-controller/status") == 5){
	setprop("su-27/instrumentation/RSBN/active-AER",1);
	setprop("su-27/instrumentation/OC-controller/status",1);
	return;	}
	#Waiting for WPT ,thus set WPT1 (wpt0) as active
	if(getprop("su-27/instrumentation/OC-controller/status") == 7){
	setprop("autopilot/route-manager/current-wp",0);
	setprop("su-27/instrumentation/OC-controller/status",1);
	return;	}
	}
var AER2btnPress = func{
	#OC ready , so we put it in "wait for AER" status .
	if(getprop("su-27/instrumentation/OC-controller/status") == 1){
	setprop("su-27/instrumentation/OC-controller/status",5);
	return;}
	#Waiting for PPM ,thus set PPM2 as active
	if(getprop("su-27/instrumentation/OC-controller/status") == 3){
	setprop("su-27/instrumentation/RSBN/active-PPM",2);
	setprop("su-27/instrumentation/OC-controller/status",1);
	RSBN_PPMs();
	return;}
	#Waiting for AER ,thus set AER2 as active
	if(getprop("su-27/instrumentation/OC-controller/status") == 5){
	setprop("su-27/instrumentation/RSBN/active-AER",2);
	setprop("su-27/instrumentation/OC-controller/status",1);
	return;}
	#Waiting for WPT ,thus set WPT2 (wpt1) as active
	if(getprop("su-27/instrumentation/OC-controller/status") == 7){
	setprop("autopilot/route-manager/current-wp",1);
	setprop("su-27/instrumentation/OC-controller/status",1);
	return;	}
	}
var RM3btnPress = func{
#	OC ready , so we put it in "wait for WP" status .
	if(getprop("su-27/instrumentation/OC-controller/status") == 1){
	setprop("su-27/instrumentation/OC-controller/status",7);
	return;}
	#Waiting for PPM ,thus set PPM3 as active
	if(getprop("su-27/instrumentation/OC-controller/status") == 3){
	setprop("su-27/instrumentation/RSBN/active-PPM",3);
	setprop("su-27/instrumentation/OC-controller/status",1);
	RSBN_PPMs();
	return;}
	#Waiting for AER ,thus set AER3 as active
	if(getprop("su-27/instrumentation/OC-controller/status") == 5){
	setprop("su-27/instrumentation/RSBN/active-AER",3);
	setprop("su-27/instrumentation/OC-controller/status",1);
	return;}
	#Waiting for WPT ,thus set WPT3 (wpt2) as active
	if(getprop("su-27/instrumentation/OC-controller/status") == 7){
	setprop("autopilot/route-manager/current-wp",2);
	setprop("su-27/instrumentation/OC-controller/status",1);
	return;	}
	}
var UD4btnPress = func{
	
	if(getprop("su-27/instrumentation/OC-controller/status") == 3){
	setprop("su-27/instrumentation/RSBN/active-PPM",4);
	setprop("su-27/instrumentation/OC-controller/status",1);
	RSBN_PPMs();
	return;}
	#Waiting for WPT ,thus set WPT4 (wpt3) as active
	if(getprop("su-27/instrumentation/OC-controller/status") == 7){
	setprop("autopilot/route-manager/current-wp",3);
	setprop("su-27/instrumentation/OC-controller/status",1);
	return;	}
	else{return}
	}
var UPR5btnPress = func{
	#Waiting for PPM ,thus set PPM5 as active
	if(getprop("su-27/instrumentation/OC-controller/status") == 3){
	setprop("su-27/instrumentation/RSBN/active-PPM",5);
	setprop("su-27/instrumentation/OC-controller/status",1);
	RSBN_PPMs();
	return;}
	#Waiting for WPT ,thus set WPT5 (wpt4) as active
	if(getprop("su-27/instrumentation/OC-controller/status") == 7){
	setprop("autopilot/route-manager/current-wp",4);
	setprop("su-27/instrumentation/OC-controller/status",1);
	return;	}
	else{return}
	}
var oc6btnPress = func{
	#Waiting for PPM ,thus set PPM6 as active
	if(getprop("su-27/instrumentation/OC-controller/status") == 3){
	setprop("su-27/instrumentation/RSBN/active-PPM",6);
	setprop("su-27/instrumentation/OC-controller/status",1);
	RSBN_PPMs();
	return;}
	#Waiting for WPT ,thus set WPT6 (wpt5) as active
	if(getprop("su-27/instrumentation/OC-controller/status") == 7){
	setprop("autopilot/route-manager/current-wp",5);
	setprop("su-27/instrumentation/OC-controller/status",1);
	RSBN_PPMs();
	return;	}
	else{return}
	}
var oc7btnPress = func{
	#Waiting for PPM ,thus set PPM7 as active
	if(getprop("su-27/instrumentation/OC-controller/status") == 3){
	setprop("su-27/instrumentation/RSBN/active-PPM",7);
	setprop("su-27/instrumentation/OC-controller/status",1);
	RSBN_PPMs();
	return;}
	#Waiting for WPT ,thus set WPT7 (wpt6) as active
	if(getprop("su-27/instrumentation/OC-controller/status") == 7){
	setprop("autopilot/route-manager/current-wp",6);
	setprop("su-27/instrumentation/OC-controller/status",1);
	return;	}
	else{return}
	}
var oc8btnPress = func{
	#Waiting for PPM ,thus set PPM8 as active
	if(getprop("su-27/instrumentation/OC-controller/status") == 3){
	setprop("su-27/instrumentation/RSBN/active-PPM",8);
	setprop("su-27/instrumentation/OC-controller/status",1);
	RSBN_PPMs();
	return;}
	#Waiting for WPT ,thus set WPT8 (wpt7) as active
	if(getprop("su-27/instrumentation/OC-controller/status") == 7){
	setprop("autopilot/route-manager/current-wp",7);
	setprop("su-27/instrumentation/OC-controller/status",1);
	return;	}
	else{return}
	}
var oc9btnPress = func{
	#Waiting for PPM ,thus set PPM9 as active
	if(getprop("su-27/instrumentation/OC-controller/status") == 3){
	setprop("su-27/instrumentation/RSBN/active-PPM",9);
	setprop("su-27/instrumentation/OC-controller/status",1);
	RSBN_PPMs();
	return;}
	#Waiting for WPT ,thus set WPT9 (wpt8) as active
	if(getprop("su-27/instrumentation/OC-controller/status") == 7){
	setprop("autopilot/route-manager/current-wp",8);
	setprop("su-27/instrumentation/OC-controller/status",1);
	return;	}
	else{return}
	}
	
var getActiveAER = func{
	var activeAERNum = getprop("su-27/instrumentation/RSBN/active-AER");
	if(activeAERNum == 1){activeAERfreq = getprop("su-27/instrumentation/RSBN/AER" )or 0.00}
	if(activeAERNum == 2){activeAERfreq = getprop("su-27/instrumentation/RSBN/AER-alt" )or 0.00}
	if(activeAERNum == 3){activeAERfreq = getprop("su-27/instrumentation/RSBN/AER-alt2" )or 0.00}

	}

