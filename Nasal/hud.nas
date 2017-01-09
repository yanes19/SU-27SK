#==============================================================================
# Su-27 Head up display
#==============================================================================
 
var pow2 = func(x) { return x * x; };
var vec_length = func(x, y) { return math.sqrt(pow2(x) + pow2(y)); };
var round0 = func(x) { return math.abs(x) > 0.01 ? x : 0; };
var clamp = func(x, min, max) { return x < min ? min : (x > max ? max : x); };
var Kts2KmH = func(x){if(x!= nil){return x * 1.85283} else {return 0} };
var KmH2Kts = func(x){return x * 0.53995};
var ft2m = func(x){if(x!= nil){return x * 0.3048}else {return 0}};
var m2ft = func(x){return x * 3.2808};
var HUD = {
  canvas_settings: {
    "name": "HUD",
    "size": [1024,1024],
    "view": [256,256],
    "mipmapping": 1
  },
  new: func(placement)
  {
    var m = {
      parents: [HUD],canvas: canvas.new(HUD.canvas_settings)};
      
    
 
    m.canvas.addPlacement(placement);
    m.canvas.setColorBackground(0.36, 1, 0.3, 0.02);
 
    m.root =
      m.canvas.createGroup()
              .setScale(1, 1/math.cos(25 * math.pi/180))
              .setTranslation(0, 0)
              .set("font", "lucida.txf")
              .setDouble("character-size", 18)
              .setDouble("character-aspect-ration", 0.9)
              .set("stroke", "rgba(0,255,0,0.9)");
              
    #######################
    var filename = "Aircraft/SU-27SK/Models/Interior/Instruments/hud/Su-27SK-HUD.svg";
    # Create a group for the parsed elements
    
    m.svg = m.canvas.createGroup();
    canvas.parsesvg(m.svg, filename);
    m.svg.setTranslation(9,0);
	m.svg.setScale(1);
	#m.EnRouteGroup = m.get_element("EnRoute");
	m.attitudeInd =m.get_element("Attitude");
    m.HdgScale = m.get_element("heading-scale"); 
    m.NavDirector = m.get_element("Nav-director");
    m.Rdr_Indicator = m.get_element("Rdr-Indicator");
    m.accel_pointer = m.get_element("accel-pointer");
    m.tgt1Marker = m.get_element("tgt1-marker");
    m.tgt2Marker = m.get_element("tgt2-marker");
    m.tgt3Marker = m.get_element("tgt3-marker");
    m.tgt4Marker = m.get_element("tgt4-marker");
    m.tgt5Marker = m.get_element("tgt5-marker");
    m.tgt6Marker = m.get_element("tgt6-marker");
    m.tgt7Marker = m.get_element("tgt7-marker");
    m.tgt8Marker = m.get_element("tgt8-marker");
    m.tgt9Marker = m.get_element("tgt9-marker");
    m.tgt10Marker = m.get_element("tgt10-marker");
  
    #########################################    
    m.text =
      m.root.createChild("group")
            .set("fill", "rgba(0,255,0,0.9)");
        


 #Coordinares are from top left .setTranslation(left,Top)
    # Airspeed
    m.airspeed =
      m.text.createChild("text")
            .setAlignment("center-top")
            .setTranslation(30,30)#(left,Top)
            #.setFont("Liberation Sans Narrow")
            .setFontSize(16,1.5);
            
    #AP Airspeed Setting
    m.APairspeed =
      m.text.createChild("text")
            .setAlignment("center-top")
            .setTranslation(30,15)#(left,Top)
            #.setFont("Liberation Sans Narrow")
            .setFontSize(12,1.4);
 
#    # Altitude
    m.altitude =
      m.text.createChild("text")
            .setAlignment("center-top")
            .setTranslation(220,30) #(left,Top)
            .setFontSize(16,1.5);
            
    #AP Altitude Setting
    m.APaltitude =
      m.text.createChild("text")
            .setAlignment("center-top")
            .setTranslation(220,15)#(left,Top)
            #.setFont("Liberation Sans Narrow")
            .setFontSize(12,1.4);

		# Pitch
    m.pitch =
      m.text.createChild("text")
            .setFontSize(8, 0.9)
            .setAlignment("right-center")
            .setTranslation(180, -5);
            
#    # Remaining LEG/Nav distance
    m.DistTo =
      m.text.createChild("text")
            .setAlignment("center-bottom")
            .setTranslation(140,200)
            .setFontSize(14,1.0);
 
    # Radar altidude
    m.rad_alt =
      m.text.createChild("text")
            .setAlignment("right-center")
            .setTranslation(220, 70);
 
    # Horizon
    m.horizon_group = m.root.createChild("group");
    m.h_trans = m.horizon_group.createTransform();
    m.h_rot   = m.horizon_group.createTransform();
 
  
 
    # Horizon line
    m.horizon_group.createChild("path")
                   .moveTo(51, 0)
                   .horizTo(200)
                   .setStrokeLineWidth(1.0);
                   

    m.input = {
		pitch:      "/orientation/pitch-deg",
		roll:       "/orientation/roll-deg",
		hdg:        "/orientation/heading-deg",
		speed_n:    "velocities/speed-north-fps",
		speed_e:    "velocities/speed-east-fps",
		speed_d:    "velocities/speed-down-fps",
		alpha:      "/orientation/alpha-deg",
		beta:       "/orientation/side-slip-deg",
		ias:        "su-27/instrumentation/ASI/airspeed-kmh",
		altitude:   "su-27/instrumentation/UV-30-3/indicated-altitude-m",
		vs:         "/velocities/vertical-speed-fps",
		rad_alt:    "/instrumentation/radar-altimeter/radar-altitude-ft",
		airspeed:   "su-27/instrumentation/ASI/airspeed-kmh",
		target_spd: "/autopilot/settings/target-speed-kt",
		target_alt: "/autopilot/settings/target-altitude-ft",
		acc:        "/fdm/jsbsim/accelerations/udot-ft_sec2",
		route_active 		 :	"autopilot/route-manager/active",
		route_deflection :	"instrumentation/gps/cdi-deflection",
		DistanceToWP 	  	 :	"autopilot/route-manager/wp/dist",
		DME_Distance 	  	 :	"instrumentation/dme/indicated-distance-nm",
		DME_InRange			 :	"instrumentation/dme/in-range",
		wp_alt					 :	"instrumentation/gps/wp/wp/altitude-ft",
		radar_on 			 	 :	"su-27/instrumentation/N010-radar/emitting",
		target_0x  			 :	"/instrumentation/radar/ai/models/aircraft/radar/x-shift",
		target_0z  			 :	"instrumentation/radar/ai/models/aircraft/radar/h-offset",
		target_0_inrange :	"instrumentation/radar/ai/models/aircraft/radar/in-range",
		targetvalid			 :	"ai/modcels/aircraft/valid",		# Unused for now !!
    };
 
    foreach(var name; keys(m.input))
      m.input[name] = props.globals.getNode(m.input[name], 1);
 
    return m;
  },
  
 # Get an element from the SVG; handle errors; and apply clip rectangle
# if found (by naming convention : addition of _clip to object name).
    get_element : func(id) {
        var el = me.svg.getElementById(id);
        if (el == nil)
        {
            print("Failed to locate ",id," in SVG");
            return el;
        }
        var clip_el = me.svg.getElementById(id ~ "_clip");
        if (clip_el != nil)
        {
            clip_el.setVisible(0);
            var tran_rect = clip_el.getTransformedBounds();

            var clip_rect = sprintf("rect(%d,%d, %d,%d)", 
                                   tran_rect[1], # 0 ys
                                   tran_rect[2],  # 1 xe
                                   tran_rect[3], # 2 ye
                                   tran_rect[0]); #3 xs
#            print(id," using clip element ",clip_rect, " trans(",tran_rect[0],",",tran_rect[1],"  ",tran_rect[2],",",tran_rect[3],")");
#   see line 621 of simgear/canvas/CanvasElement.cxx
#   not sure why the coordinates are in this order but are top,right,bottom,left (ys, xe, ye, xs)
            el.set("clip", clip_rect);
            el.set("clip-frame", canvas.Element.PARENT);
        }
        return el;
    },

  update: func()
  {
    me.airspeed.setText(sprintf("%d", me.input.ias.getValue()));
    me.altitude.setText(sprintf("%2d", me.input.altitude.getValue()));
    me.APairspeed.setText(sprintf("%2d", Kts2KmH(me.input.target_spd.getValue())));
    me.APaltitude.setText(sprintf("%2d", ft2m(me.input.target_alt.getValue())));

##    var rad_alt = me.input.rad_alt.getValue();
##    if( rad_alt and rad_alt < 5000 ) # Only show below 5000AGL
##      rad_alt = sprintf("R %4d", rad_alt);
##    else
##      rad_alt = nil;
##    me.rad_alt.setText(rad_alt);
 
##    #me.hdg.setText(sprintf("%03d", me.input.hdg.getValue()));
    
    me.HdgScale.setTranslation(0, me.input.hdg.getValue()/180);
    
    #heading tape
    if (me.input.hdg.getValue() < 180)
				me.heading_tape_position = -me.input.hdg.getValue()*54/10;
    else
				me.heading_tape_position = (360-me.input.hdg.getValue())*54/10;
    me.HdgScale.setTranslation (me.heading_tape_position,0);
            
    me.h_trans.setTranslation(0, 1.8 * me.input.pitch.getValue()+100);
 
    var rot = -me.input.roll.getValue() * math.pi / 180.0;
    me.pitch.setText(sprintf("%d", me.input.pitch.getValue()));
    me.pitch.setTranslation(180, 1.8 * me.input.pitch.getValue()+90);
    me.attitudeInd.setRotation(-rot);
    #Acceleration cue
    if (me.input.acc.getValue() < -1){me.accel_pointer.setTranslation(-13,0)};
    if (me.input.acc.getValue() > 1) {me.accel_pointer.setTranslation(13,0)};
    
    if (me.input.route_active.getValue() ==1)
						me.NavDirector.setTranslation(me.input.route_deflection.getValue()*10,-150);
						
	if (me.input.route_active.getValue() ==1)
		me.DistTo.setText(sprintf("%2.1f", me.input.DistanceToWP.getValue()*1.852));
		
	if (me.input.DME_InRange.getValue() ==1 and me.input.route_active.getValue() == 0)
		me.DistTo.setText(sprintf("%2.1f", me.input.DME_Distance.getValue()*1.852));
			
			
		var radarON= getprop("su-27/instrumentation/N010-radar/emitting");
		if (radarON == 0)
		{
			#print("Radar off ");
			me.tgt1Marker.setVisible(0);
			me.tgt2Marker.setVisible(0);
			me.tgt3Marker.setVisible(0);
			me.tgt4Marker.setVisible(0);
			me.tgt5Marker.setVisible(0);
			me.tgt6Marker.setVisible(0);
			me.tgt7Marker.setVisible(0);
			me.tgt8Marker.setVisible(0);
			me.tgt9Marker.setVisible(0);
			me.tgt10Marker.setVisible(0);
		}
		if (radarON == 0){me.Rdr_Indicator.setVisible(0);}else {me.Rdr_Indicator.setVisible(1);}
		
#		#**************TARGET1 MARKER *********************#
		var target1_x = getprop("instrumentation/radar2/targets/aircraft/h-offset");
		var target1_z = getprop("instrumentation/radar2/targets/aircraft/v-offset");
		if (target1_x or 0 > 0 and radarON ==1)
		{
			if (radarON == 1){
						me.tgt1Marker.setVisible(1);
						me.tgt1Marker.setTranslation(target1_x*18, -145+ -target1_z*15);}
		}
#		#**************TARGET2 MARKER *********************#
		var target2_x = getprop("instrumentation/radar2/targets/aircraft[1]/h-offset");
		var target2_z = getprop("instrumentation/radar2/targets/aircraft[1]/v-offset");
		if (target2_x or 0 > 0 and radarON ==1)
		{
			if (radarON == 1){
						me.tgt2Marker.setVisible(1);
						me.tgt2Marker.setTranslation(target2_x*20, -145+ -target2_z*15);}
		}
#		#**************TARGET3 MARKER *********************#
		var target3_x = getprop("instrumentation/radar2/targets/aircraft[2]/h-offset");
		var target3_z = getprop("instrumentation/radar2/targets/aircraft[2]/v-offset");
		if (target3_x or 0 > 0 and radarON ==1)
		{
			if (radarON == 1){
						me.tgt3Marker.setVisible(1);
						me.tgt3Marker.setTranslation(target3_x*20, -145+ -target3_z*15);}
		}
#		#**************TARGET4 MARKER *********************#
		var target4_x = getprop("instrumentation/radar2/targets/aircraft[3]/h-offset");
		var target4_z = getprop("instrumentation/radar2/targets/aircraft[3]/v-offset");
		if (target4_x or 0 > 0 and radarON ==1)
		{
			if (radarON == 1){
						me.tgt4Marker.setVisible(1);
						me.tgt4Marker.setTranslation(target4_x*15, -145+ -target4_z*15);}
		}
#		#**************TARGET5 MARKER *********************#
		var target5_x = getprop("instrumentation/radar2/targets/aircraft[4]/h-offset");
		var target5_z = getprop("instrumentation/radar2/targets/aircraft[4]/v-offset");
		if (target5_x or 0 > 0 and radarON ==1)
		{
			if (radarON == 1){
						me.tgt5Marker.setVisible(1);
						me.tgt5Marker.setTranslation(target5_x*20, -145+ -target5_z*15);}
		}
#		#**************TARGET6 MARKER *********************#
		var target6_x = getprop("instrumentation/radar2/targets/aircraft[5]/h-offset");
		var target6_z = getprop("instrumentation/radar2/targets/aircraft[5]/v-offset");
		if (target6_x or 0 > 0 and radarON ==1)
		{
			if (radarON == 1){
						me.tgt6Marker.setVisible(1);
						me.tgt6Marker.setTranslation(target6_x*20, -145+ -target6_z*15);}
		}
#		#**************TARGET7 MARKER *********************#
		var target7_x = getprop("instrumentation/radar2/targets/aircraft[6]/h-offset");
		var target7_z = getprop("instrumentation/radar2/targets/aircraft[6]/v-offset");
		if (target7_x or 0 > 0 and radarON ==1)
		{
			if (radarON == 1){
						me.tgt7Marker.setVisible(1);
						me.tgt7Marker.setTranslation(target7_x*15, -145+ -target7_z*15);}
		}
#		#**************TARGET8 MARKER *********************#
		var target8_x = getprop("instrumentation/radar2/targets/aircraft[7]/h-offset");
		var target8_z = getprop("instrumentation/radar2/targets/aircraft[7]/v-offset");
		if (target8_x or 0 > 0 and radarON ==1)
		{
			if (radarON == 1){
						me.tgt8Marker.setVisible(1);
						me.tgt8Marker.setTranslation(target8_x*20, -145+ -target8_z*15);}
		}
#		#**************TARGET9 MARKER *********************#
		var target9_x = getprop("instrumentation/radar2/targets/aircraft[8]/h-offset");
		var target9_z = getprop("instrumentation/radar2/targets/aircraft[8]/v-offset");
		if (target9_x or 0 > 0 and radarON ==1)
		{
			if (radarON == 1){
						me.tgt9Marker.setVisible(1);
						me.tgt9Marker.setTranslation(target9_x*20, -145+ -target9_z*15);}
		}
#		#**************TARGET10 MARKER *********************#
		var target10_x = getprop("instrumentation/radar2/targets/aircraft[9]/h-offset");
		var target10_z = getprop("instrumentation/radar2/targets/aircraft[9]/v-offset");
		if (target10_x or 0 > 0 and radarON ==1)
		{
			if (radarON == 1){
						me.tgt10Marker.setVisible(1);
						me.tgt10Marker.setTranslation(target10_x*20, -145+ -target10_z*15);}
		}
 
    var speed_error = 0;
    if( me.input.target_spd.getValue() != nil )
      speed_error = 4 * clamp(
        me.input.target_spd.getValue() - me.input.airspeed.getValue(),
        -15, 15
      );

 
    settimer(func me.update(), 0);
  },
		# Get an element from the SVG; handle errors; and apply clip rectangle
		# if found (by naming convention : addition of _clip to object name).
     get_element : func(id) {
        var el = me.svg.getElementById(id);
        if (el == nil)
        {
            print("Failed to locate ",id," in SVG");
            return el;
        }
        var clip_el = me.svg.getElementById(id ~ "_clip");
        if (clip_el != nil)
        {
            clip_el.setVisible(0);
            var tran_rect = clip_el.getTransformedBounds();

            var clip_rect = sprintf("rect(%d,%d, %d,%d)", 
                                   tran_rect[1], # 0 ys
                                   tran_rect[2],  # 1 xe
                                   tran_rect[3], # 2 ye
                                   tran_rect[0]); #3 xs
#            print(id," using clip element ",clip_rect, " trans(",tran_rect[0],",",tran_rect[1],"  ",tran_rect[2],",",tran_rect[3],")");
#   see line 621 of simgear/canvas/CanvasElement.cxx
#   not sure why the coordinates are in this order but are top,right,bottom,left (ys, xe, ye, xs)
            el.set("clip", clip_rect);
            el.set("clip-frame", canvas.Element.PARENT);
        }
        return el;
    }
};


 
 
var init = setlistener("/sim/signals/fdm-initialized", func() {
  removelistener(init); # only call once
  var hud_pilot = HUD.new({"node": "hudglass"});
  hud_pilot.update();
});
