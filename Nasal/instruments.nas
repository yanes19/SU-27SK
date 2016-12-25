



 var init_instrumentation = func {
  #setlistener("su-27/instrumentation/electrical/v27", Instrumentation_voltage_handler,0,0 );
  #setlistener("su-27/instrumentation/electrical/v200", Instrumentation_voltage_handler,0,0 );

  air_speed2kmh();
  alt_meters();
  RV_21();
  PNP_Bearing();
  PNP_SelectedCourseDirector();
  print ("*SU-27 instruments module loaded !");

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
  var bar_altitude_m = (bar_altitude_ft * 0.3048);
  setprop("su-27/instrumentation/UV-30-3/indicated-altitude-m", bar_altitude_m);
  settimer(alt_meters, 0)
}

var current_altitude_ft = 0;
var current_altitude_m = 0;
var danger_altitude = 0;

 var RV_21 = func {
 #******* Yanes:TODO: Make all the above features working ! ********************
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
	var RawTargetBearing =getprop("instrumentation/nav/radials/reciprocal-radial-deg")or 0.00;
	var CurrentHeading =getprop("orientation/heading-deg")or 0.00;
	var IndicatedTargetBearing  = RawTargetBearing - CurrentHeading ;
	#if (IndicatedTargetBearing > 359){IndicatedTargetBearing = IndicatedTargetBearing - 360}
	setprop("su-27/instrumentation/HSI/IndicatedTrgtourse", IndicatedTargetBearing);
	settimer(PNP_Bearing, 0.0);
 }
var CourseDirectorDeg  =0 ;
var SelectedCourse =0 ;
var SelCourseDirDegree = 0;

  var PNP_SelectedCourseDirector = func {
	var SelectedCourse =getprop("instrumentation/nav/radials/selected-deg")or 0.00;
	var CurrentHeading =getprop("orientation/heading-deg")or 0.00;
	var SelCourseDirDegree  = SelectedCourse - CurrentHeading ;
	setprop("su-27/instrumentation/HSI/SelectedCourseDirector", SelCourseDirDegree);
	settimer(PNP_SelectedCourseDirector, 0.0);
 }
 ### Launch Module Loop
 
init_instrumentation();

