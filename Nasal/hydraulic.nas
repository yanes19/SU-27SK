############################################
# CUSTOM HYDRAULIC SYSTEM FOR SU-27SK
# BY Wang Jianlin (Developer0607, Ghost)
############################################

var MAXSPEED = 0;
var dt=0;

var ELElast = props.globals.getNode("/controls/ctrl/elevator",1);
var LAILlast = props.globals.getNode("/controls/ctrl/l-aileron",1);
var RAILlast = props.globals.getNode("/controls/ctrl/r-aileron",1);
var Rudlast = props.globals.getNode("/controls/ctrl/rudder-pos-rad",1);
var ELEout = props.globals.getNode("/controls/ctrl/output/elevator",1);
var LAILout = props.globals.getNode("/controls/ctrl/output/l-aileron",1);
var RAILout = props.globals.getNode("/controls/ctrl/output/r-aileron",1);
var Rudout = props.globals.getNode("/controls/ctrl/output/rudder-pos-rad",1);
var ELEin = props.globals.getNode("/fdm/jsbsim/fcs/elevator-pos-rad");
var LAILin = props.globals.getNode("/fdm/jsbsim/fcs/left-aileron-pos-rad");
var RAILin = props.globals.getNode("/fdm/jsbsim/fcs/right-aileron-pos-rad");
var Rudin = props.globals.getNode("/fdm/jsbsim/fcs/rudder-pos-rad",1);

ELEout.setValue(0);
LAILout.setValue(0);
RAILout.setValue(0);
ELElast.setValue(0);
LAILlast.setValue(0);
RAILlast.setValue(0);
Rudout.setValue(0);
Rudlast.setValue(0);

var loop=func{
    MAXSPEED = math.min(6.283, getprop("/systems/hydraulic/pump/pressure") * 0.07654);
    var time=getprop("/sim/time/elapsed-sec");
    if(getprop("/systems/hydraulic/pump/pressure")>30){
        var rmax=MAXSPEED*(time-dt);
        var elelast = ELElast.getValue();
        var elein   = ELEin.getValue();
        var laillast = LAILlast.getValue();
        var lailin   = LAILin.getValue();
        var raillast = RAILlast.getValue();
        var railin   = RAILin.getValue();
        var rudin    = Rudin.getValue();
        var rudlast  = Rudlast.getValue();
        if(elein > elelast){
            if(math.abs(elein - elelast) > rmax){
                ELEout.setValue(elelast + rmax);
            }else{
                ELEout.setValue(elein);
            }
            ELElast.setValue(ELEout.getValue());
        }else{
            if(math.abs(elein - elelast) > rmax){
                ELEout.setValue(elelast - rmax);
            }else{
                ELEout.setValue(elein);
            }
            ELElast.setValue(ELEout.getValue());
        }
        if(lailin > laillast){
            if(math.abs(lailin - laillast) > rmax){
                LAILout.setValue(laillast + rmax);
            }else{
                LAILout.setValue(lailin);
            }
            LAILlast.setValue(LAILout.getValue());
        }else{
            if(math.abs(lailin - laillast) > rmax){
                LAILout.setValue(laillast - rmax);
            }else{
                LAILout.setValue(lailin);
            }
            LAILlast.setValue(LAILout.getValue());
        }
        if(railin > raillast){
            if(math.abs(railin - raillast) > rmax){
                RAILout.setValue(raillast + rmax);
            }else{
                RAILout.setValue(railin);
            }
            RAILlast.setValue(RAILout.getValue());
        }else{
            if(math.abs(railin - raillast) > rmax){
                RAILout.setValue(raillast - rmax);
            }else{
                RAILout.setValue(railin);
            }
            RAILlast.setValue(RAILout.getValue());
        }
        if(rudin > rudlast){
            if(math.abs(rudin - rudlast) > rmax){
                Rudout.setValue(rudlast + rmax);
            }else{
                Rudout.setValue(rudin);
            }
            Rudlast.setValue(Rudout.getValue());
        }else{
            if(math.abs(rudin - rudlast) > rmax){
                Rudout.setValue(rudlast - rmax);
            }else{
                Rudout.setValue(rudin);
            }
            Rudlast.setValue(Rudout.getValue());
        }
    }
    dt=time;
    settimer(loop,0.01);
};

var gearlistener=func{
    if(getprop("/controls/ctrl/gear-down")!=getprop("/controls/gear/gear-down")){
        if(getprop("/systems/hydraulic/pump/pressure")>50){
            setprop("/controls/gear/gear-down",getprop("/controls/ctrl/gear-down"));
        }
    }
};

var flapslistener=func{
    if(getprop("/controls/ctrl/flaps")!=getprop("/controls/flight/flaps")){
        if(getprop("/systems/hydraulic/pump/pressure")>50){
            setprop("/controls/flight/flaps",getprop("/controls/ctrl/flaps"));
        }
    }
};

var airbrklistener=func{
    if(getprop("/controls/ctrl/airbrk")!=getprop("/controls/flight/speedbrake")){
        if(getprop("/systems/hydraulic/pump/pressure")>50){
            setprop("/controls/flight/speedbrake",getprop("/controls/ctrl/airbrk"));
        }
    }
};

loop();
setlistener("/controls/ctrl/gear-down",gearlistener);
setlistener("/controls/ctrl/flaps",flapslistener);
setlistener("/controls/ctrl/airbrk",airbrklistener);