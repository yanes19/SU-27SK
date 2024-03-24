#==============================================================================
					# Su-27SK Head up display
#==============================================================================
 
var pow2 = func(x) { return x * x; };
var vec_length = func(x, y) { return math.sqrt(pow2(x) + pow2(y)); };
var round0 = func(x) { return math.abs(x) > 0.01 ? x : 0; };
var clamp = func(x, min, max) { return x < min ? min : (x > max ? max : x); };
var Kts2KmH = func(x){if(x!= nil){return x * 1.85283} else {return 0} };
var KmH2Kts = func(x){return x * 0.53995};
var ft2m = func(x){if(x!= nil){return x * 0.3048}else {return 0}};
var m2ft = func(x){return x * 3.2808};
var OurRoll           = props.globals.getNode("orientation/roll-deg");
var HUD = {
  canvas_settings: {
    "name": "HUD",
    "size": [1024,1024],
    "view": [256,256],
    "mipmapping": 0
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
    m.NavDirector= m.get_element("NavDirector");
    m.Glidingpath = m.get_element("Glidingpath");
    m.locIndicator = m.get_element("Localizer-sign");
    m.GSIndicator = m.get_element("GS-sign");
    m.modeEnRte = m.get_element("Rte-Mode-indic");
    m.modeRtn = m.get_element("Rtn-Mode-indic");
    m.modeLndg = m.get_element("Ldng-Mode-indic");
    
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
    m.lockMarker = m.get_element("lock-marker");
  
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
            .setTranslation(140,180)
            .setFontSize(12,0.80);
 
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
		altitude:   "su-27/instrumentation/PNK-10/str-PNK-Altitude",	#PNK altitude
		vs:         "/velocities/vertical-speed-fps",
		rad_alt:    "/instrumentation/radar-altimeter/radar-altitude-ft",
		airspeed:   "su-27/instrumentation/ASI/airspeed-kmh",
		target_spd  : "/autopilot/settings/target-speed-kt",
		target_alt  : "/autopilot/settings/target-altitude-ft",
		PNK_Mode	: "su-27/instrumentation/PNK-10/active-mode",
		NavInRange  : "instrumentation/nav/in-range",
		Is_LOC	    : "instrumentation/nav/frequencies/is-localizer-frequency",
		NavCrossTrackErr : "instrumentation/nav/crosstrack-error-m",
		Gs_InRange  : "instrumentation/nav/gs-in-range",
		GS_Deflection : "instrumentation/nav/gs-needle-deflection-norm",
		acc:        "/fdm/jsbsim/accelerations/udot-ft_sec2",
		route_active 		 :	"autopilot/route-manager/active",
		route_deflection	 :	"instrumentation/gps/cdi-deflection",
		DistanceToWP 	  	 :	"autopilot/route-manager/wp/dist",
		DME_Distance 	  	 :	"instrumentation/dme/indicated-distance-nm",
		DME_InRange			 :	"instrumentation/dme/in-range",
	wp_alt					 :	"instrumentation/gps/wp/wp/altitude-ft",
	radar_on 			 	 :	"su-27/instrumentation/N010-radar/emitting",
		target_0x  			 :	"/instrumentation/radar/ai/models/aircraft/radar/x-shift",
		target_0z  			 :	"instrumentation/radar/ai/models/aircraft/radar/h-offset",
		target_0_inrange 	 :	"instrumentation/radar/ai/models/aircraft/radar/in-range",
		targetvalid			 :	"ai/models/aircraft/valid",		# Unused for now !!
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
  var HudPower = getprop("systems/electrical/outputs/ILS-31HUD") or 0;
  var hudSwitch = getprop("controls/switches/ILS-31HUD") or 0;
  
 if (HudPower < 18){
		me.root.hide();
		me.svg.hide();
#		print ("No hud");
#		return;
}
	else{
		me.root.show();
		me.svg.show();
#	print ("SEE hud");
		}
		
    me.airspeed.setText(sprintf("%d", me.input.ias.getValue()/10)~"0");
    me.altitude.setText( me.input.altitude.getValue());
    if (me.input.target_spd.getValue()!= nil){
    me.APairspeed.setText(sprintf("%2d", Kts2KmH(me.input.target_spd.getValue())/10)~"0");}
    if(me.input.target_alt.getValue()!= nil){
    me.APaltitude.setText(sprintf("%2d", ft2m(me.input.target_alt.getValue())/10)~"0");}


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
##########################
		#ROUTE MODE :#
##########################	    
	if (me.input.PNK_Mode.getValue() == 0)
		{
	    if (me.input.route_active.getValue() ==1)
				me.NavDirector.setTranslation(me.input.route_deflection.getValue()*10,-150);
		}			
	if (me.input.route_active.getValue() ==1)
		me.DistTo.setText(sprintf("%2.1f", me.input.DistanceToWP.getValue()*1.852));
		
	if (me.input.DME_InRange.getValue() ==1 and me.input.route_active.getValue() == 0)
		me.DistTo.setText(sprintf("%2.1f", me.input.DME_Distance.getValue()*1.852));
		
	if (me.input.PNK_Mode.getValue() == 0 or me.input.PNK_Mode.getValue() == 1)
	{ me.modeEnRte.setVisible(1);}else{me.modeEnRte.setVisible(0);}
			
##########################
		#LANDING MODE :#
##########################
	if (me.input.PNK_Mode.getValue() == 2 and me.input.Is_LOC.getValue() == 1 and me.input.NavInRange.getValue() == 1)
		{ 
		me.modeLndg.setVisible(1);
		me.NavDirector.setVisible(1);
		me.Glidingpath.setVisible(1);
		me.locIndicator.setVisible(1);
		me.Glidingpath.setTranslation(me.input.NavCrossTrackErr.getValue() * 0.056, me.input.GS_Deflection.getValue() * -12.2) ;
		me.NavDirector.setTranslation(getprop("instrumentation/nav/heading-needle-deflection")*4.4,me.input.GS_Deflection.getValue() * -3.6) ;
		if (me.input.Gs_InRange.getValue() == 1){me.GSIndicator.setVisible(1);}else {me.GSIndicator.setVisible(0)}
		#me.GSIndicator.setVisible(1);
		
		}else
		{
		me.locIndicator.setVisible(0);
		me.GSIndicator.setVisible(0);
		me.modeLndg.setVisible(0);
		me.NavDirector.setVisible(0);
		me.Glidingpath.setVisible(0);
		}
		
		me.modeRtn.setVisible(0);	# Until implemented , this should be hidden unconditionnally	
			
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
      me.lockMarker.setVisible(0);
		}
		if (radarON == 0){me.Rdr_Indicator.setVisible(0);}else {me.Rdr_Indicator.setVisible(1);}
		
#**************LOCK MARKER *********************#
		if(radar.GetTarget() != nil){
      var target1_x = radar.tgts_list[radar.Target_Index].TgtsFiles.getNode("h-offset",1).getValue();
      var target1_z = radar.tgts_list[radar.Target_Index].TgtsFiles.getNode("v-offset",1).getValue();
      if (target1_x or 0 > 0 and radarON ==1)
      {
        var dist_O = math.sqrt(math.pow(target1_x, 2)+math.pow(target1_z, 2));
        var oriAngle = math.asin(target1_x / dist_O);
        if(target1_z < 0){
          oriAngle = 3.141592654 - oriAngle;
        }
        var Rollrad = (OurRoll.getValue() / 180) * 3.141592654;
        target1_x = dist_O * math.sin(oriAngle - Rollrad);
        target1_z = dist_O * math.cos(oriAngle - Rollrad);
        var kx = math.abs(target1_x/7.25);
        var kz = math.abs(target1_z/6);
        if((kx > 1) or (kz > 1)){
          if(kx > kz){
            target1_x = target1_x / kx;
            target1_z = target1_z / kx;
          }else{
            target1_z = target1_z / kz;
            target1_x = target1_x / kz;
          }
        }
        if (radarON == 1){
              me.lockMarker.setVisible(1);
              #screen.log.write(sprintf("%.2f %.2f %.2f %.2f %.2f %.2f %.2f %.2f", target1_x, target1_z, kx, kz, target1_x / kx, target1_x / kz, target1_z / kx, target1_z / kz));
              me.lockMarker.setTranslation(target1_x*18 - 10, -145+ -target1_z*15);}
      }
    }

#		#**************TARGET1 MARKER *********************#
		var target1_x = getprop("instrumentation/radar2/targets/multiplayer/h-offset");
		var target1_z = getprop("instrumentation/radar2/targets/multiplayer/v-offset");
		if (target1_x or 0 > 0 and radarON ==1)
		{
			var dist_O = math.sqrt(math.pow(target1_x, 2)+math.pow(target1_z, 2));
      var oriAngle = math.asin(target1_x / dist_O);
      if(target1_z < 0){
        oriAngle = 3.141592654 - oriAngle;
      }
      var Rollrad = (OurRoll.getValue() / 180) * 3.141592654;
      target1_x = dist_O * math.sin(oriAngle - Rollrad);
      target1_z = dist_O * math.cos(oriAngle - Rollrad);
      var kx = math.abs(target1_x/7.25);
      var kz = math.abs(target1_z/6);
      if((kx > 1) or (kz > 1)){
        if(kx > kz){
            target1_x = target1_x / kx;
            target1_z = target1_z / kx;
          }else{
            target1_z = target1_z / kz;
            target1_x = target1_x / kz;
          }
      }
      if (radarON == 1){
						me.tgt1Marker.setVisible(1);
						me.tgt1Marker.setTranslation(target1_x*18 - 10, -145+ -target1_z*15);}
		}
#		#**************TARGET2 MARKER *********************#
		var target2_x = getprop("instrumentation/radar2/targets/multiplayer[1]/h-offset");
		var target2_z = getprop("instrumentation/radar2/targets/multiplayer[1]/v-offset");
		if (target2_x or 0 > 0 and radarON ==1)
		{
			var dist_O = math.sqrt(math.pow(target2_x, 2)+math.pow(target2_z, 2));
      var oriAngle = math.asin(target2_x / dist_O);
      if(target2_z < 0){
        oriAngle = 3.141592654 - oriAngle;
      }
      var Rollrad = (OurRoll.getValue() / 180) * 3.141592654;
      target2_x = dist_O * math.sin(oriAngle - Rollrad);
      target2_z = dist_O * math.cos(oriAngle - Rollrad);
      var kx = math.abs(target2_x/7.25);
      var kz = math.abs(target2_z/6);
      if((kx > 1) or (kz > 1)){
        if(kx > kz){
            target2_x = target2_x / kx;
            target2_z = target2_z / kx;
          }else{
            target2_z = target2_z / kz;
            target2_x = target2_x / kz;
          }
      }
      if (radarON == 1){
						me.tgt2Marker.setVisible(1);
            #screen.log.write(sprintf("%.2f %.2f %.2f %.2f %.2f %.2f %.2f %.2f", target2_x, target2_z, kx, kz, target2_x / kx, target2_x / kz, target2_z / kx, target2_z / kz));
						me.tgt2Marker.setTranslation(target2_x*18 - 10, -145+ -target2_z*15);}
		}
#		#**************TARGET3 MARKER *********************#
		var target3_x = getprop("instrumentation/radar2/targets/multiplayer[2]/h-offset");
		var target3_z = getprop("instrumentation/radar2/targets/multiplayer[2]/v-offset");
		if (target3_x or 0 > 0 and radarON ==1)
		{
			var dist_O = math.sqrt(math.pow(target3_x, 2)+math.pow(target3_z, 2));
      var oriAngle = math.asin(target3_x / dist_O);
      if(target3_z < 0){
        oriAngle = 3.141592654 - oriAngle;
      }
      var Rollrad = (OurRoll.getValue() / 180) * 3.141592654;
      target3_x = dist_O * math.sin(oriAngle - Rollrad);
      target3_z = dist_O * math.cos(oriAngle - Rollrad);
      var kx = math.abs(target3_x/7.25);
      var kz = math.abs(target3_z/6);
      if((kx > 1) or (kz > 1)){
        if(kx > kz){
          target3_x = target3_x / kx;
          target3_z = target3_z / kx;
        }else{
          target3_z = target3_z / kz;
          target3_x = target3_x / kz;
        }
      }
      if (radarON == 1){
						me.tgt3Marker.setVisible(1);
						me.tgt3Marker.setTranslation(target3_x*18 - 10, -145+ -target3_z*15);}
		}
#		#**************TARGET4 MARKER *********************#
		var target4_x = getprop("instrumentation/radar2/targets/multiplayer[3]/h-offset");
		var target4_z = getprop("instrumentation/radar2/targets/multiplayer[3]/v-offset");
		if (target4_x or 0 > 0 and radarON ==1)
		{
			var dist_O = math.sqrt(math.pow(target4_x, 2)+math.pow(target4_z, 2));
      var oriAngle = math.asin(target4_x / dist_O);
      if(target4_z < 0){
        oriAngle = 3.141592654 - oriAngle;
      }
      var Rollrad = (OurRoll.getValue() / 180) * 3.141592654;
      target4_x = dist_O * math.sin(oriAngle - Rollrad);
      target4_z = dist_O * math.cos(oriAngle - Rollrad);
      var kx = math.abs(target4_x/7.25);
      var kz = math.abs(target4_z/6);
      if((kx > 1) or (kz > 1)){
        if(kx > kz){
          target4_z = target4_z / kx;
          target4_x = target4_z / kx;
        }else{
          target4_z = target4_z / kz;
          target4_x = target4_x / kz;
        }
      }
      if (radarON == 1){
						me.tgt4Marker.setVisible(1);
						me.tgt4Marker.setTranslation(target4_x*18 - 10, -145+ -target4_z*15);}
		}
#		#**************TARGET5 MARKER *********************#
		target1_x = getprop("instrumentation/radar2/targets/multiplayer[4]/h-offset");
		target1_z = getprop("instrumentation/radar2/targets/multiplayer[4]/v-offset");
		if (target1_x or 0 > 0 and radarON ==1)
		{
			var dist_O = math.sqrt(math.pow(target1_x, 2)+math.pow(target1_z, 2));
      var oriAngle = math.asin(target1_x / dist_O);
      if(target1_z < 0){
        oriAngle = 3.141592654 - oriAngle;
      }
      var Rollrad = (OurRoll.getValue() / 180) * 3.141592654;
      target1_x = dist_O * math.sin(oriAngle - Rollrad);
      target1_z = dist_O * math.cos(oriAngle - Rollrad);
      var kx = math.abs(target1_x/7.25);
      var kz = math.abs(target1_z/6);
      if((kx > 1) or (kz > 1)){
        if(kx > kz){
            target1_x = target1_x / kx;
            target1_z = target1_z / kx;
          }else{
            target1_z = target1_z / kz;
            target1_x = target1_x / kz;
          }
      }
			if (radarON == 1){
						me.tgt5Marker.setVisible(1);
						me.tgt5Marker.setTranslation(target1_x*18 - 10, -145+ -target1_z*15);}
		}
#		#**************TARGET6 MARKER *********************#
		target1_x = getprop("instrumentation/radar2/targets/multiplayer[5]/h-offset");
		target1_z = getprop("instrumentation/radar2/targets/multiplayer[5]/v-offset");
		if (target1_x or 0 > 0 and radarON ==1)
		{
			var dist_O = math.sqrt(math.pow(target1_x, 2)+math.pow(target1_z, 2));
      var oriAngle = math.asin(target1_x / dist_O);
      if(target1_z < 0){
        oriAngle = 3.141592654 - oriAngle;
      }
      var Rollrad = (OurRoll.getValue() / 180) * 3.141592654;
      target1_x = dist_O * math.sin(oriAngle - Rollrad);
      target1_z = dist_O * math.cos(oriAngle - Rollrad);
      var kx = math.abs(target1_x/7.25);
      var kz = math.abs(target1_z/6);
      if((kx > 1) or (kz > 1)){
        if(kx > kz){
            target1_x = target1_x / kx;
            target1_z = target1_z / kx;
          }else{
            target1_z = target1_z / kz;
            target1_x = target1_x / kz;
          }
      }
			if (radarON == 1){
						me.tgt6Marker.setVisible(1);
						me.tgt6Marker.setTranslation(target1_x*18 - 10, -145+ -target1_z*15);}
		}
#		#**************TARGET7 MARKER *********************#
		var target7_x = getprop("instrumentation/radar2/targets/tanker[0]/h-offset");
		var target7_z = getprop("instrumentation/radar2/targets/tanker[0]/v-offset");
		if (target7_x or 0 > 0 and radarON ==1)
		{
			if (radarON == 1){
						me.tgt7Marker.setVisible(1);
						me.tgt7Marker.setTranslation(target7_x*18 - 10, -145+ -target7_z*15);}
		}
#		#**************TARGET8 MARKER *********************#
		target1_x = getprop("instrumentation/radar2/targets/Mig-28[2]/h-offset");
		target1_z = getprop("instrumentation/radar2/targets/Mig-28[2]/v-offset");
		if (target1_x or 0 > 0 and radarON ==1)
		{
			var dist_O = math.sqrt(math.pow(target1_x, 2)+math.pow(target1_z, 2));
      var oriAngle = math.asin(target1_x / dist_O);
      if(target1_z < 0){
        oriAngle = 3.141592654 - oriAngle;
      }
      var Rollrad = (OurRoll.getValue() / 180) * 3.141592654;
      target1_x = dist_O * math.sin(oriAngle - Rollrad);
      target1_z = dist_O * math.cos(oriAngle - Rollrad);
      var kx = math.abs(target1_x/7.25);
      var kz = math.abs(target1_z/6);
      if((kx > 1) or (kz > 1)){
        if(kx > kz){
            target1_x = target1_x / kx;
            target1_z = target1_z / kx;
          }else{
            target1_z = target1_z / kz;
            target1_x = target1_x / kz;
          }
      }
			if (radarON == 1){
						me.tgt8Marker.setVisible(1);
						me.tgt8Marker.setTranslation(target1_x*18 - 10, -145+ -target1_z*15);}
		}
#		#**************TARGET9 MARKER *********************#
		target1_x = getprop("instrumentation/radar2/targets/Mig-28[1]/h-offset");
		target1_z = getprop("instrumentation/radar2/targets/Mig-28[1]/v-offset");
		if (target1_x or 0 > 0 and radarON ==1)
		{
			var dist_O = math.sqrt(math.pow(target1_x, 2)+math.pow(target1_z, 2));
      var oriAngle = math.asin(target1_x / dist_O);
      if(target1_z < 0){
        oriAngle = 3.141592654 - oriAngle;
      }
      var Rollrad = (OurRoll.getValue() / 180) * 3.141592654;
      target1_x = dist_O * math.sin(oriAngle - Rollrad);
      target1_z = dist_O * math.cos(oriAngle - Rollrad);
      var kx = math.abs(target1_x/7.25);
      var kz = math.abs(target1_z/6);
      if((kx > 1) or (kz > 1)){
        if(kx > kz){
            target1_x = target1_x / kx;
            target1_z = target1_z / kx;
          }else{
            target1_z = target1_z / kz;
            target1_x = target1_x / kz;
          }
      }
      if (radarON == 1){
						me.tgt9Marker.setVisible(1);
						me.tgt9Marker.setTranslation(target1_x*18 - 10, -145+ -target1_z*15);}
		}
#		#**************TARGET10 MARKER *********************#
		target1_x = getprop("instrumentation/radar2/targets/Mig-28[0]/h-offset");
		target1_z = getprop("instrumentation/radar2/targets/Mig-28[0]/v-offset");
		if (target1_x or 0 > 0 and radarON ==1)
		{
			var dist_O = math.sqrt(math.pow(target1_x, 2)+math.pow(target1_z, 2));
      var oriAngle = math.asin(target1_x / dist_O);
      if(target1_z < 0){
        oriAngle = 3.141592654 - oriAngle;
      }
      var Rollrad = (OurRoll.getValue() / 180) * 3.141592654;
      target1_x = dist_O * math.sin(oriAngle - Rollrad);
      target1_z = dist_O * math.cos(oriAngle - Rollrad);
      var kx = math.abs(target1_x/7.25);
      var kz = math.abs(target1_z/6);
      if((kx > 1) or (kz > 1)){
        if(kx > kz){
            target1_x = target1_x / kx;
            target1_z = target1_z / kx;
          }else{
            target1_z = target1_z / kz;
            target1_x = target1_x / kz;
          }
      }
			if (radarON == 1){
						me.tgt10Marker.setVisible(1);
						me.tgt10Marker.setTranslation(target1_x*18 - 10, -145+ -target1_z*15);}
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
