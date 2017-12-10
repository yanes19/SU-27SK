#########################################
## SDU-10 FLY BY WIRE SYSTEM FOR SU-27 ##
#########################################
##       Designed by Yanes Bechir      ##
#########################################

# CONSTANTS

var RAD2DEG = 57.2957795;
var DEG2RAD = 0.0174532925;
var INCREMENT = 0.001;

# helpers:

##
# a wrapper to determine if a value is within a certain range
# usage:in_range(1,[min,max] );
# e.g.: in_range(1, [-1,+1] );
#
var in_range = func(value, range) {
 var min=range[0];
 var max=range[1];
 return ((value <= min) and (value >= max));
}

var fbw = {
	init : func { 
        me.UPDATE_INTERVAL = INCREMENT; 
        me.loopid = 0; 
		me.throttle = 0;
		me.throttlefix = 0;
		me.throttleinit = 0;
		me.targetthrottle = 0;
		me.turnthrottlefix = 0;
# Yanes experimental fcs test vars  :
		me.CurAileron = 0;
		me.CurElevator = 0;
		me.CurRudder = 0;
#ENDOF  Yanes experimental fcs test vars  :
		me.targetaileron = 0;
		me.targetelevator = 0;
		me.targetrudder = 0;
		me.adjustelevators = 0;
		me.stabilize = 0;

		me.stabpitch = 0;
		me.stabroll = 0;

		me.disconnectannounce = 0;
		# use a vector of throttles, this can be later on used to support more than
		# just two engines
		me.throttles = [nil,nil]; 



## Initialize with FBW Activated

setprop("/controls/fbw-fcs/active", 1);

## Initialize Control Surfaces

setprop("/fdm/jsbsim/fcs/aileron-fbw-output", 0);
setprop("/fdm/jsbsim/fcs/rudder-fbw-output", 0);
setprop("/fdm/jsbsim/fcs/elevator-fbw-output", 0);

        me.reset(); 
}, 
	update : func {

var fcs = "/fdm/jsbsim/fcs/";

## This is where the FBW actually does its job ;)

me.check_if_active();

if (getprop("/controls/fbw-fcs/active")) {
me.disconnectannounce = 0;
var ElevTrimFix = 0;
var AoALimiterFix = 0;
var GLoadLimiterFix =0;
var RollTrimFix =0;

var airspeedkt = getprop("/velocities/airspeed-kt");
var Currentpitch = getprop("orientation/pitch-deg");
var PitchCtrl = getprop("controls/flight/elevator");
var ElevTrim = getprop("/controls/flight/elevator-trim");
var PitchRateDeg = getprop("orientation/pitch-rate-degps");

var pitchFix = airspeedkt/Currentpitch/100;

var LoadFactor = getprop("fdm/jsbsim/forces/load-factor");
var Rollctrl = getprop("controls/flight/aileron");
var CurrentRoll = getprop("orientation/roll-deg");
var Rollctrl = getprop("controls/flight/aileron");
var APhdgMode = getprop("autopilot/locks/heading");

#PITCH AXIS

#Anti-stall helper 
#if((PitchRateDeg != nil)and(PitchRateDeg > 0)){
#	AoALimiterFix = PitchRateDeg /80;
#	}
#	GLoadLimiterFix = -LoadFactor/20;
#	ElevTrimFix	= GLoadLimiterFix + AoALimiterFix;
#setprop("controls/flight/elevator-trim",ElevTrimFix);

#---------> commented to test jsb pitch limiter
##if ((PitchCtrl > me.CurElevator + 0.01)or (PitchCtrl < me.CurElevator - 0.01)) {
##	setprop("systems/SDU-10-fcs/pitch-stab" , 0);
##	me.CurElevator = PitchCtrl ;
##	#print("Elevator trim ");
##}	
##else{setprop("systems/SDU-10-fcs/pitch-stab" , 1);}

#ROLL AXIS :

#if ((Rollctrl > me.CurAileron + 0.01)or (Rollctrl < me.CurAileron - 0.01)) {
#	setprop("systems/SDU-10-fcs/roll-stab" , 0);
#	me.CurAileron = Rollctrl ;
#	#print("Aileron trim ");
#}	
#else{setprop("systems/SDU-10-fcs/roll-stab" , 1);}
	
#}

##End of update() routine  
},


check_if_active : func {
### The Fly-by--wire only works when it is active.Pilot have the option to disable fly-by-wire and use power-by-wire* in case of emergencies. The Fly By Wire Configuration includes: On/Off, Bank Limit and Rudder Control.

## Turn on Fly By Wire only if we have power
	
	if (getprop("/systems/electrical/outputs/efis") != nil) {
	  if (getprop("/systems/electrical/outputs/efis") < 9) {
	  print("check_if_active");
	  setprop("/controls/fbw-fcs/active", 0);
	  if (me.disconnectannounce == 0) {
	  
	    screen.log.write("Fly By Wire Disconnected!", 1, 0, 0);
	    me.disconnectannounce = 1;
	  }
	}
	}
},

    reset : func {
        me.loopid += 1;
        me._loop_(me.loopid);
    },
    _loop_ : func(id) {
        id == me.loopid or return;
        me.update();
        settimer(func { me._loop_(id); }, me.UPDATE_INTERVAL);
    }

};

#fbw.init();
#print("SDU-10 Fly-By-Wire system Initialized");

