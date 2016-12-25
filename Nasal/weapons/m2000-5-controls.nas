print("*** LOADING m2000-5-controls.nas ... ***");
################################################################################
#
#                        m2005-5's CONTROLS SETTINGS
#
################################################################################
# The goal is to overwrite some controls in order of put it on a stick (and
# even perhaps multiplex command on stick...)

# First Brakes
# Allow, on flight to put in the same button, the brakes and airbrakes, using
# defaults function, and put it on the joystick, and be able to accelerate and
# decelerate without put hand of the stick and search the keyboard.

# AirBrake handling.
var fullAirBrakeTime = 1;
var applyAirBrakes = func(v)
{
    interpolate("/controls/flight/spoilers", v, fullAirBrakeTime);
}

# Brake handling.
var fullBrakeTime = 0.5;
var applyBrakes = func(v, which = 0)
{
    if(getprop("/controls/gear/gear-down") != 0)
    {
        if(which <= 0)
        {
            interpolate("/controls/gear/brake-left", v, fullBrakeTime);
        }
        if(which >= 0)
        {
            interpolate("/controls/gear/brake-right", v, fullBrakeTime);
        }
    }
    else
    {
        controls.applyAirBrakes(v);
    }
}

# Trigger
var trigger = func(b)
{
    setprop("/controls/armament/trigger", b);
    if(getprop ("/gear/gear[2]/position-norm") == 0)
    {
        guns.fire_MG(b);
    }
}


##
# Gear handling.
#
var gearUp = func(v) {
    #print("gears... wow:"~getprop("/gear/gear[1]/wow")~" v:"~v);
    if(v == 1)
    {
        if((getprop("/gear/gear[1]/wow") == 0)
            and (getprop("/gear/gear[2]/wow") == 0))
        {
            #print("gears up");
            setprop("/controls/gear/gear-down", 0);
        }
    }
    elsif(v == 0)
    {
        #print("gears down");
        setprop("/controls/gear/gear-down", 1);
        setprop("/controls/flight/flaps", 0);
    }
}
#var gearToggle = func() {
#    gearUp(getprop("/controls/gear/gear-down") > 0 ? -1 : 1);
#}
