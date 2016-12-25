print("*** LOADING missile_GroundTargeting.nas ... ***");
################################################################################
#
#                     m2005-5's ADDING GROUND TARGET
#
################################################################################

var dt       = 0;
var isFiring = 0;

var targetingGround = func()
{
    var myGroundTarget = groud_target.new();
    myGroundTarget.init();
}

# this object create an AI object where is the last click
var groud_target = {
    new: func()
    {
        var m = { parents : [groud_target]};
        m.coord = geo.Coord.new();
        
        # Find the next index for "models/model" and create property node.
        # Find the next index for "ai/models/aircraft" and create property node.
        # (M. Franz, see Nasal/tanker.nas)
        var n = props.globals.getNode("models", 1);
        for(var i = 0 ; 1 ; i += 1)
        {
            if(n.getChild("model", i, 0) == nil)
            {
                break;
            }
        }
        m.model = n.getChild("model", i, 1);
        var n = props.globals.getNode("ai/models", 1);
        for(var i = 0 ; 1 ; i += 1)
        {
            if(n.getChild("aircraft", i, 0) == nil)
            {
                break;
            }
        }
        m.ai = n.getChild("aircraft", i, 1);
        m.ai.getNode("valid", 1).setBoolValue(1);
        
        m.id_model = "Models/Military/humvee-pickup-odrab-low-poly.xml";
        #m.model.getNode("path", 1).setValue(m.id_model);
        m.life_time = 0;
        
        m.life_time = 600;
        
        m.id = m.ai.getNode("id", 1);
        m.callsign = m.ai.getNode("callsign", 1);
        
        m.lat = m.ai.getNode("position/latitude-deg", 1);
        m.long = m.ai.getNode("position/longitude-deg", 1);
        m.alt = m.ai.getNode("position/altitude-ft", 1);
        
        m.hdgN   = m.ai.getNode("orientation/true-heading-deg", 1);
        m.pitchN = m.ai.getNode("orientation/pitch-deg", 1);
        m.rollN  = m.ai.getNode("orientation/roll-deg", 1);
        
        m.radarRangeNM = m.ai.getNode("radar/range-nm", 1);
        m.radarbearingdeg = m.ai.getNode("radar/bearing-deg", 1);
        m.radarInRange = m.ai.getNode("radar/in-range", 1);
        m.elevN = m.ai.getNode("radar/elevation-deg", 1);
        m.hOffsetN = m.ai.getNode("radar/h-offset", 1);
        m.vOffsetN = m.ai.getNode("radar/v-offset", 1);
        
        # Speed
        m.ktasN = m.ai.getNode("velocities/true-airspeed-kt", 1);
        m.vertN = m.ai.getNode("velocities/vertical-speed-fps", 1);
        
        return m;
    },
    del: func()
    {
        me.model.remove();
        me.ai.remove();
    },
    init: func()
    {
        me.coord = geo.click_position();
        var tempLat = me.coord.lat();
        var tempLon = me.coord.lon();
        var tempAlt = me.coord.alt();
        
        # there must be value in it
        me.lat.setValue(tempLat);
        me.long.setValue(tempLon);
        me.alt.setValue(tempAlt*M2FT);
        
        me.callsign.setValue("GROUND_TARGET");
        me.id.setValue(-2);
        me.hdgN.setValue(0);
        me.pitchN.setValue(0);
        me.rollN.setValue(0);
        me.radarRangeNM.setValue(10);
        me.radarbearingdeg.setValue(0);
        me.radarInRange.setBoolValue(1);
        me.elevN.setValue(0);
        me.hOffsetN.setValue(0);
        me.vOffsetN.setValue(0);
        me.ktasN.setValue(0);
        me.vertN.setValue(0);
        
        # put value in model
        # beware : No absolute value here but the way to find the property
        me.model.getNode("path", 1).setValue(me.id_model);
        me.model.getNode("latitude-deg-prop", 1).setValue(me.lat.getPath());
        me.model.getNode("longitude-deg-prop", 1).setValue(me.long.getPath());
        me.model.getNode("elevation-ft-prop", 1).setValue(me.alt.getPath());
        me.model.getNode("heading-deg-prop", 1).setValue(me.hdgN.getPath());
        me.model.getNode("pitch-deg-prop", 1).setValue(me.pitchN.getPath());
        me.model.getNode("roll-deg-prop", 1).setValue(me.rollN.getPath());
        me.model.getNode("load", 1).remove();
        
        me.update();
#        settimer(func me.del(), me.life_time);
        settimer(func(){ me.del(); }, me.life_time);
    },
    update: func()
    {
        # update me.coord : Could be a selectionnable option. The goal should to select multiple ground target
        me.coord = geo.click_position();
        
        # update Position of the Object
        var tempLat = me.coord.lat();
        var tempLon = me.coord.lon();
        var tempAlt = me.coord.alt();
        me.lat.setValue(tempLat);
        me.long.setValue(tempLon);
        me.alt.setValue(tempAlt*M2FT);
        
        # update Distance to aircaft
        me.ac = geo.aircraft_position();
        var alt = me.coord.alt();
        me.distance = me.ac.distance_to(me.coord);
        
        # update bearing
        me.bearing = me.ac.course_to(me.coord);
        
        # update Radar Stuff
        var dalt = alt - me.ac.alt();
        var ac_hdg = getprop("/orientation/heading-deg");
        var ac_pitch = getprop("/orientation/pitch-deg");
        var ac_contact_dist = getprop("/systems/refuel/contact-radius-m");
        var elev = math.atan2(dalt, me.distance) * R2D;
        
        me.radarRangeNM.setValue(me.distance * M2NM);
        me.radarbearingdeg.setValue(me.bearing);
        me.elevN.setDoubleValue(elev);
        me.hOffsetN.setDoubleValue(view.normdeg(me.bearing - ac_hdg));
        me.vOffsetN.setDoubleValue(view.normdeg(elev - ac_pitch));
        
#        settimer(func me.update(), 0);
        settimer(func(){ me.update(); }, 0);
    }
};
