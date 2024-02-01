print("LOADING weapons.nas .");
################################################################################
#
#                        Su-27SK WEAPONS SETTINGS
#							Thanks to the m2005-5's developpers
################################################################################

var dt = 0;
var isFiring = 0;
var splashdt = 0;
var MPMessaging = props.globals.getNode("/payload/armament/msg", 1);
var rplock = 0;

fire_MG = func(b) {
    var time = getprop("/sim/time/elapsed-sec");
    if(getprop("/sim/failure-manager/systems/wcs/failure-level"))return;
    
    # Here is the gun things : the firing should last 0,5 sec or 1 sec, and in
    # the future should be selectionable
    if(getprop("/controls/armament/stick-selector") == 1
        and getprop("/ai/submodels/submodel/count") > 0
        and isFiring == 0)
    {
        isFiring = 1;
        setprop("/controls/armament/Gun_trigger", 1);
        #settimer(stopFiring, 0.1);
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
                m2000_load. SelectNextPylon();## TEST
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

var getlock=func{
    if(rplock)return 0;
    rplock=1;
    return 1;
}
var unlock=func{
    if(rplock){
        rplock=0;
    }
}
# This is to detect collision when balistic are shooted.
# The goal is to put an automatic message for gun splash
var Mp = props.globals.getNode("ai/models");
var Hit={
    new:func(callsign, number, wptype, wpid){
        var _Hit = {parents:[Hit]};
        _Hit.Callsign   = callsign;
        _Hit.Number     = number;
        _Hit.Name       = wptype;
        _Hit.ID         = wpid;
        return _Hit;
    },
    report:func{
        
            var phrase = me.Name ~ " hit: " ~ me.Callsign ~ ": " ~ me.Number ~ " hits";
            if (getprop("/payload/armament/msg")) {
                #armament.defeatSpamFilter(phrase);
                var msg = notifications.ArmamentNotification.new("mhit", 4, 
                #-1*(damage.shells["GSh-30"][0]+1)
                            me.ID);
                        msg.RelativeAltitude = 0;
                        msg.Bearing = 0;
                        msg.Distance = me.Number;
                        msg.RemoteCallsign = me.Callsign;
                notifications.hitBridgedTransmitter.NotifyAll(msg);
                damage.damageLog.push("You hit "~me.Callsign~" with "~me.Name~", "~me.Number~" times.");
            } else {
                setprop("/sim/messages/atc", phrase);
            }
            return;
        
    },
    cmp:func(x){
        if(     me.Callsign == x.Callsign
           #and  me.Name     == x.Name
           and  me.ID       == x.ID){
            return 1;
        }
        else return 0;
    }
};
var hits = [];
var front = 0;
var rear  = 0;
var Impact = func() {
    var splashOn = "Nothing";
    var numberOfSplash = 0;
    var raw_list = Mp.getChildren();
    var bn = Mp.getNode("model-impact");
    # Running threw ballistic list
        c = Mp.getNode(bn.getValue());
        # FIXED, with janitor. 5H1N0B1
        var type = c.getName();
        #if(! c.getNode("valid", 1).getValue())
        #{
        #    continue;
        #}
        var HaveImpactNode = c.getNode("impact", 1);
        #if(HaveImpactNode == nil)HaveImpactNode = c.getNode("position",1);
        if(type == "ballistic" and HaveImpactNode != nil)
        {
            var type = HaveImpactNode.getNode("type", 1);
            printf("hit %s",type.getValue());
            if(type.getValue() != "terrain")
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
                        var cur = Hit.new(tempo,1,"GSh-30",-1*(damage.shells["GSh-30"][0]+1));
                        append(hits,cur);
                        rear=rear+1;
                        Reporter();
                    }
                }
            }
        }else{
            print("weapons.nas line 116: nil impact Node!");
        }
    
    var time = getprop("/sim/time/elapsed-sec");
    if(splashOn != "Nothing")
    {
        if(time - splashdt < 0.1){
            settimer(Impact,0.1);
            return;
        }
        #var phrase = "GSh-30 hit: " ~ splashOn~". "~ numberOfSplash ~" hits";
        #if(MPMessaging.getValue() == 1)
        #{
        #    setprop("/sim/multiplay/chat", phrase);
        #}
        #else
        #{
        #    setprop("/sim/messages/atc", phrase);
        #}
        #splashdt = time;
        
        splashdt=time;
    }
}

var Reporter=func{
    while(front<rear-1 and hits[front].cmp(hits[front+1])){
        hits[front+1].Number=hits[front+1].Number;
        front=front+1;
    }
    if(getlock()){
        hits[front].report();
        settimer(unlock,0.1);
        if(rear-front>0)settimer(Reporter,0.1);
    }else{
        settimer(Reporter,0.1);
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
    var dist  = 80;
    var SelectedMP = "Nothing";
    foreach(var c ; raw_list)
    {
        # FIXED, with janitor. 5H1N0B1
        var type = c.getName();
        if(! c.getNode("valid", 1).getValue())
        {
            continue;
        }
        var HavePosition = c.getNode("position");
        var name = c.getNode("callsign", 1);
        
        if(type == "multiplayer" and HavePosition != nil and targetCoord != nil and name != nil)
        {
            var elev = HavePosition.getNode("altitude-ft",1).getValue() * FT2M;
            var lat = HavePosition.getNode("latitude-deg", 1).getValue();
            var lon = HavePosition.getNode("longitude-deg", 1).getValue();
            
            #elev = (elev == nil) ? HavePosition.getNode("altitude-m", 1).getValue() : elev;
            
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
setlistener("ai/models/model-impact",Impact,0);

var stickreporter = func(){
    if(getprop("/controls/armament/stick-selector") == 1)screen.log.write("Selected GSh-30 Cannon.",1,0.4,0.4);
    else{screen.log.write("Selected missiles.",1,0.4,0.4);}
}
setlistener("/controls/armament/stick-selector",stickreporter);