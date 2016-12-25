print("*** LOADING weapons.nas ... ***");
################################################################################
#
#                        m2005-5's WEAPONS SETTINGS
#
################################################################################

var dt = 0;
var isFiring = 0;
var splashdt = 0;
var MPMessaging = props.globals.getNode("/controls/armament/mp-messaging", 1);

fire_MG = func(b) {
    var time = getprop("/sim/time/elapsed-sec");
    
    # Here is the gun things : the firing should last 0,5 sec or 1 sec, and in
    # the future should be selectionable
    if(getprop("/controls/armament/stick-selector") == 1
        and getprop("/ai/submodels/submodel/count") > 0
        and isFiring == 0)
    {
        isFiring = 1;
        setprop("/controls/armament/Gun_trigger", 1);
        settimer(stopFiring, 0.5);
    }
    if(getprop("/controls/armament/stick-selector") == 2)
    {
        if(b == 1)
        {
            # To limit: one missile/second
            # var time = getprop("/sim/time/elapsed-sec");
            if(time - dt > 1)
            {
                dt = time;
                var pylon = getprop("/controls/armament/missile/current-pylon");
                m2000_load.dropLoad(pylon);
                print("Should fire Missile");
            }
        }
    }
}

var stopFiring = func() {
    setprop("/controls/armament/Gun_trigger", 0);
    isFiring = 0;
}

reload_Cannon = func() {
    setprop("/ai/submodels/submodel/count",    120);
    setprop("/ai/submodels/submodel[1]/count", 120);
    setprop("/ai/submodels/submodel[2]/count", 120);
    setprop("/ai/submodels/submodel[3]/count", 120);
}

# This is to detect collision when balistic are shooted.
# The goal is to put an automatic message for gun splash
var Mp = props.globals.getNode("ai/models");
var Impact = func() {
    var splashOn = "Nothing";
    var numberOfSplash = 0;
    var raw_list = Mp.getChildren();
    # Running threw ballistic list
    foreach(var c ; raw_list)
    {
        # FIXED, with janitor. 5H1N0B1
        var type = c.getName();
        if(! c.getNode("valid", 1).getValue())
        {
            continue;
        }
        var HaveImpactNode = c.getNode("impact", 1);
        # If there is an impact and the impact is terrain then
        if(type == "ballistic" and HaveImpactNode != nil)
        {
            var type = HaveImpactNode.getNode("type", 1);
            if(type != "terrain")
            {
                var elev = HaveImpactNode.getNode("elevation-m", 1).getValue();
                var lat = HaveImpactNode.getNode("latitude-deg", 1).getValue();
                var lon = HaveImpactNode.getNode("longitude-deg", 1).getValue();
                if(lat != nil and lon != nil and elev != nil)
                {
                    #print("lat"~ lat~" lon:"~ lon~ "elev:"~ elev);
                    ballCoord = geo.Coord.new();
                    ballCoord.set_latlon(lat, lon, elev);
                    var tempo = findmultiplayer(ballCoord);
                    if(tempo != "Nothing")
                    {
                        splashOn = tempo;
                        numberOfSplash += 1;
                    }
                }
            }
        }
    }
    var time = getprop("/sim/time/elapsed-sec");
    if(splashOn != "Nothing" and (time - splashdt) > 1)
    {
        var phrase = "Gun Splash On :" ~ splashOn~". "~ numberOfSplash ~" hits";
        if(MPMessaging.getValue() == 1)
        {
            setprop("/sim/multiplay/chat", phrase);
        }
        else
        {
            setprop("/sim/messages/atc", phrase);
        }
        splashdt = time;
    }
}

# Nb of impacts
var Nb_Impact = func() {
    var mynumber = 0;
    var raw_list = Mp.getChildren();
    foreach(var c ; raw_list)
    {
        # FIXED, with janitor. 5H1N0B1
        var type = c.getName();
        if(! c.getNode("valid", 1).getValue())
        {
            continue;
        }
        var HaveImpactNode = c.getNode("impact", 1);
        if(type == "ballistic")
        {
            mynumber +=1;
        }
    }
    return mynumber;
}

# We mesure the minimum distance to all contact. This allow us to deduce who is the MP
var findmultiplayer = func(targetCoord) {
    var raw_list = Mp.getChildren();
    var dist  = 1000;
    var SelectedMP = "Nothing";
    foreach(var c ; raw_list)
    {
        # FIXED, with janitor. 5H1N0B1
        var type = c.getName();
        if(! c.getNode("valid", 1).getValue())
        {
            continue;
        }
        var HavePosition = c.getNode("position", 1);
        var name = c.getNode("callsign", 1);
        
        if(type == "multiplayer" and HavePosition != nil and targetCoord != nil and name != nil)
        {
            var elev = HavePosition.getNode("altitude-m", 1).getValue();
            var lat = HavePosition.getNode("latitude-deg", 1).getValue();
            var lon = HavePosition.getNode("longitude-deg", 1).getValue();
            
            elev = (elev == nil) ? HavePosition.getNode("altitude-ft", 1).getValue() * FT2M : elev;
            
            #print("name:"~name.getValue());
            #print("lat"~ lat.getValue()~" lon:"~ lon.getValue()~ "elev:"~ elev.getValue());
            
            MpCoord = geo.Coord.new();
            MpCoord.set_latlon(lat, lon, elev);
            var tempoDist = MpCoord.direct_distance_to(targetCoord);
            #print("TempoDist:"~tempoDist);
            if(dist > tempoDist)
            {
                dist = tempoDist;
                SelectedMP = name.getValue();
                #print("That worked");
            }
        }
    }
    #print("Splash on : Callsign:"~SelectedMP);
    return SelectedMP;
}
