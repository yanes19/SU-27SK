# Radar2 and RWR routines.

# Alexis Bory (xiii)

# Every 0.05 seconde:
# [1] Scans /AI/models for (aircrafts), (carriers), multiplayers. Creates a list of
#     these targets, whenever they are in radar overall range and are valid.
# [2] RWR (Radar Warning Receiver) signals are then computed. RWR signal values
#     are writen under /instrumentation/radar2/targets for interoperabilty purposes.
# [3] At each loop the targets list is scanned and each target bearing is checked
#     against the radar beam heading. If the target is within the radar beam, its
#     display properties are updated. Two different displays are possible:
#     B-scan like and PPI like.
#     The target distance is then scored so the radar system can autotrack the
#     nearest target.
# Every 0.1 seconde:
# [4] Computes HUD marker position for the nearest target.

var OurAlt            = props.globals.getNode("position/altitude-ft");
var OurHdg            = props.globals.getNode("orientation/heading-deg");
var EcmOn             = props.globals.getNode("instrumentation/ecm/on-off", 1);
var EcmAlert1         = props.globals.getNode("instrumentation/ecm/alert-type1", 1);
var EcmAlert2         = props.globals.getNode("instrumentation/ecm/alert-type2", 1);
var power             = props.globals.getNode("/systems/electrical/outputs/SPO-15LM");

var our_alt           = 0;
var Mp = props.globals.getNode("ai/models");
var tgts_list         = [];
var ecm_alert1        = 0;
var ecm_alert2        = 0;
var ecm_alert1_last   = 0;
var ecm_alert2_last   = 0;
var u_ecm_signal      = 0;
var u_ecm_signal_norm = 0;
var u_radar_standby   = 0;
var u_ecm_type_num    = 0;

init = func() {
	radardist.init();
	settimer(rwr_loop, 0.5);
}

var type_unknow = nil;
var type_C = 1;
var type_F = 2;
var type_H = 3;
var type_X = 4;
var type_3 = 5;
var type_fighter = 6;

var rwr_data={
	"F-15C":          type_X,
	"F-15D":          type_X,
	"F-16":           type_X,
	"f-14b":          type_X,
	"m2000-5":        type_X,
	"SU-27":          type_X,
	"a4":             type_H,
	"A6-E":           type_X,
	"B-1B":           type_3,
	"B-2":            type_3,
	"b29":            type_H,
	"B-52F":          type_3,
	"SR-71-Blackbird":type_X,
};
# Main loop ###############
var rwr_loop = func() {
	ecm_on = EcmOn.getBoolValue();
	#screen.log.write("rwr-loop");
	if ( ecm_on and power.getBoolValue()) {
		our_alt = OurAlt.getValue();
		tgts_list = [];
		var raw_list = Mp.getChildren();
		var L10 = 0;
		var L30 = 0;
		var L60 = 0;
		var L90 = 0;
		var L6  = 0;
		var R10 = 0;
		var R30 = 0;
		var R60 = 0;
		var R90 = 0;
		var R6  = 0;
		var T_C = 0;
		var T_F = 0;
		var T_H = 0;
		var T_X = 0;
		var T_3 = 0;
		var T_N = 0;
		var ecm_signal_max = 0;
		foreach( var c; raw_list ) {
			
			var type = c.getName();
			if (!c.getNode("valid", 1).getValue()) {
				continue;
			}
			var HaveRadarNode = c.getNode("radar");
			if (type == "multiplayer" or type == "tanker" and HaveRadarNode != nil or type == "Mig-28") {
				var u = Threat.new(c);
				u_ecm_signal      = 0;
				u_ecm_signal_norm = 0;
				u_radar_standby   = 0;
				u_ecm_type_num    = 0;
				#screen.log.write("found threat.");
				if ( u.Range != nil) {
					# Test if target has a radar. Compute if we are illuminated. This propery used by ECM
					# over MP, should be standardized, like "ai/models/multiplayer[0]/radar/radar-standby".
					var u_name = radardist.get_aircraft_name(u.string);
					#the u_name is "something.xml", we should remove the ".xml"
					var split_name = nil;
					if(u_name != 0){ #get_aircraft_name() returns zero if sim/model/path is nil
						split_name = split(".", u_name);
						u_name=split_name[0];
					}
					var u_maxrange = radardist.my_maxrange(u_name); # in kilometer, 0 is unknown or no radar.
					if(type=="Mig-28"){u_maxrange=100;}#for training scenario
					var horizon = u.get_horizon( our_alt );
					var u_rng = u.get_range();
					if(u_rng == 0 and rwr_data[u_name] != type_unknow)u_rng=200;
					var u_carrier = u.check_carrier_type();
					var threatdeg = -9999.9;
					#if(u_maxrange == 0){
					#	u_maxrange = 100;
					#}
					if ( u.get_rdr_standby() == 0 and u_maxrange > 0  and u_rng < horizon ) {
						# Test if we are in its radar field (hard coded 74°) or if we have a MPcarrier.
						# Compute the signal strength.
						var our_deviation_deg = deviation_normdeg(u.get_heading(), u.get_reciprocal_bearing());
						threatdeg = u.get_reciprocal_bearing() - OurHdg.getValue() - 180;
						if(threatdeg<0){
							threatdeg += 360;
						}
						if(threatdeg<0){
							threatdeg += 360;
						}
						if ( our_deviation_deg < 0 ) { our_deviation_deg *= -1 }
						if ( our_deviation_deg < 37 or u_carrier == 1 ) {
							u_ecm_signal = (((-our_deviation_deg/20)+2.5)*(!u_carrier )) + (-u_rng/20) + 2.6 + (u_carrier*1.8);
							u_ecm_type_num = radardist.get_ecm_type_num(u_name);
						}
					} else {
						u_ecm_signal = 0;
					}	
					# Compute global threat situation for undiscriminant warning lights
					# and discrete (normalized) definition of threat strength.
					if ( u_ecm_signal > 1 and u_ecm_signal < 3 ) {
						EcmAlert1.setBoolValue(1);
						ecm_alert1 = 1;
						u_ecm_signal_norm = 2;
					} elsif ( u_ecm_signal >= 3 ) {
						EcmAlert2.setBoolValue(1);
						ecm_alert2 = 1;
						u_ecm_signal_norm = 1;
					}
					u.EcmSignal.setValue(u_ecm_signal);
					u.EcmSignalNorm.setIntValue(u_ecm_signal_norm);
					u.EcmTypeNum.setIntValue(u_ecm_type_num);
					if(u_ecm_signal > 0){
						#setprop("/mig29/instrumentation/SPO-15LM/azimut_M-norm",threatdeg);
						if(threatdeg>=345 or threatdeg <=5)L10=1;
						if(threatdeg>=315 and threatdeg <=345)L30=1;
						if(threatdeg>=285 and threatdeg <=315)L60=1;
						if(threatdeg>=255 and threatdeg <= 285)L90 = 1;
						if(threatdeg>170 and threatdeg<255)L6=1;
						if(threatdeg>=355 or threatdeg <=15)R10=1;
						if(threatdeg>=15 and threatdeg <=45)R30=1;
						if(threatdeg>=45 and threatdeg <=75)R60=1;
						if(threatdeg>=75 and threatdeg <= 105)R90 = 1;
						if(threatdeg<190 and threatdeg>105)R6=1;
						if(u_ecm_signal>ecm_signal_max)ecm_signal_max = u_ecm_signal;
						if(rwr_data[u_name] == type_X) T_X = 1;
						if(rwr_data[u_name] == type_C) T_C = 1;
						if(rwr_data[u_name] == type_3) T_3 = 1;
						if(rwr_data[u_name] == type_H) T_H = 1;
						if(rwr_data[u_name] == type_F) T_F = 1;
						if(rwr_data[u_name] == type_N) T_N = 1;
					}
					#screen.log.write("done.");
				}
			}
		}

		# Summarize ECM alerts.
		if ( ecm_alert1 == 0 and ecm_alert1_last == 0 ) { EcmAlert1.setBoolValue(0);}
		if ( ecm_alert2 == 0 and ecm_alert1_last == 0 ) { EcmAlert2.setBoolValue(0); }
		if(ecm_signal_max > 0){
			#setprop("/mig29/instrumentation/SPO-15LM/azimut_M-norm",-9999);
			if(L10)setprop("/mig29/instrumentation/SPO-15LM/M10L",1);
			else setprop("/mig29/instrumentation/SPO-15LM/M10L",0);
			if(L30)setprop("/mig29/instrumentation/SPO-15LM/M30L",1);
			else setprop("/mig29/instrumentation/SPO-15LM/M30L",0);
			if(L60)setprop("/mig29/instrumentation/SPO-15LM/M60L",1);
			else setprop("/mig29/instrumentation/SPO-15LM/M60L",0);
			if(L90)setprop("/mig29/instrumentation/SPO-15LM/M90L",1);
			else setprop("/mig29/instrumentation/SPO-15LM/M90L",0);
			if(L6)setprop("/mig29/instrumentation/SPO-15LM/M6L",1);
			else setprop("/mig29/instrumentation/SPO-15LM/M6L",0);
			if(R10)setprop("/mig29/instrumentation/SPO-15LM/M10R",1);
			else setprop("/mig29/instrumentation/SPO-15LM/M10R",0);
			if(R30)setprop("/mig29/instrumentation/SPO-15LM/M30R",1);
			else setprop("/mig29/instrumentation/SPO-15LM/M30R",0);
			if(R60)setprop("/mig29/instrumentation/SPO-15LM/M60R",1);
			else setprop("/mig29/instrumentation/SPO-15LM/M60R",0);
			if(R90)setprop("/mig29/instrumentation/SPO-15LM/M90R",1);
			else setprop("/mig29/instrumentation/SPO-15LM/M90R",0);
			if(R6)setprop("/mig29/instrumentation/SPO-15LM/M6R",1);
			else setprop("/mig29/instrumentation/SPO-15LM/M6R",0);
			if(T_3)setprop("/mig29/instrumentation/SPO-15LM/Tp3",1);
			else setprop("/mig29/instrumentation/SPO-15LM/Tp3",0);
			if(T_C)setprop("/mig29/instrumentation/SPO-15LM/TpC",1);
			else setprop("/mig29/instrumentation/SPO-15LM/TpC",0);
			if(T_F)setprop("/mig29/instrumentation/SPO-15LM/TpF",1);
			else setprop("/mig29/instrumentation/SPO-15LM/TpF",0);
			if(T_H)setprop("/mig29/instrumentation/SPO-15LM/TpH",1);
			else setprop("/mig29/instrumentation/SPO-15LM/TpH",0);
			if(T_N)setprop("/mig29/instrumentation/SPO-15LM/TpN",1);
			else setprop("/mig29/instrumentation/SPO-15LM/TpN",0);
			if(T_X)setprop("/mig29/instrumentation/SPO-15LM/TpX",1);
			else setprop("/mig29/instrumentation/SPO-15LM/TpX",0);
		}else{
			
			setprop("/mig29/instrumentation/SPO-15LM/M10L",0);
			setprop("/mig29/instrumentation/SPO-15LM/M30L",0);
			setprop("/mig29/instrumentation/SPO-15LM/M60L",0);
			setprop("/mig29/instrumentation/SPO-15LM/M90L",0);
			setprop("/mig29/instrumentation/SPO-15LM/M6L",0);
			setprop("/mig29/instrumentation/SPO-15LM/M30R",0);
			setprop("/mig29/instrumentation/SPO-15LM/M60R",0);
			setprop("/mig29/instrumentation/SPO-15LM/M90R",0);
			setprop("/mig29/instrumentation/SPO-15LM/M6R",0);
			setprop("/mig29/instrumentation/SPO-15LM/TpC",0);
			setprop("/mig29/instrumentation/SPO-15LM/TpX",0);
			setprop("/mig29/instrumentation/SPO-15LM/Tp3",0);
			setprop("/mig29/instrumentation/SPO-15LM/TpF",0);
			setprop("/mig29/instrumentation/SPO-15LM/TpN",0);
			setprop("/mig29/instrumentation/SPO-15LM/TpH",0);
		}
		ecm_alert1_last = ecm_alert1; # And avoid alert blinking at each loop.
		ecm_alert2_last = ecm_alert2;
		ecm_alert1 = 0;
		ecm_alert2 = 0;
	} else{
			if ( size(tgts_list) > 0 ) {
				foreach( u; tgts_list ) {
					u.EcmSignal.setValue(0);
					u.EcmSignalNorm.setIntValue(0);
					u.EcmTypeNum.setIntValue(0);
				}
			}
		setprop("/mig29/instrumentation/SPO-15LM/M10L",0);
		setprop("/mig29/instrumentation/SPO-15LM/M30L",0);
		setprop("/mig29/instrumentation/SPO-15LM/M60L",0);
		setprop("/mig29/instrumentation/SPO-15LM/M90L",0);
		setprop("/mig29/instrumentation/SPO-15LM/M6L",0);
		setprop("/mig29/instrumentation/SPO-15LM/M30R",0);
		setprop("/mig29/instrumentation/SPO-15LM/M60R",0);
		setprop("/mig29/instrumentation/SPO-15LM/M90R",0);
		setprop("/mig29/instrumentation/SPO-15LM/M6R",0);
		setprop("/mig29/instrumentation/SPO-15LM/TpC",0);
		setprop("/mig29/instrumentation/SPO-15LM/TpX",0);
		setprop("/mig29/instrumentation/SPO-15LM/Tp3",0);
		setprop("/mig29/instrumentation/SPO-15LM/TpF",0);
		setprop("/mig29/instrumentation/SPO-15LM/TpN",0);
		setprop("/mig29/instrumentation/SPO-15LM/TpH",0);
	}
	settimer(rwr_loop, 0.05);
}



# Utilities.
var deviation_normdeg = func(our_heading, target_bearing) {
	var dev_norm = our_heading - target_bearing;
	while (dev_norm < -180) dev_norm += 360;
	while (dev_norm > 180) dev_norm -= 360;
	return(dev_norm);
}


setlistener("sim/signals/fdm-initialized", init);

# Target class
var Threat = {
	new : func (c) {
		var obj = { parents : [Threat]};
		obj.RdrProp = c.getNode("radar");
		obj.Heading = c.getNode("orientation/true-heading-deg");
		obj.Alt = c.getNode("position/altitude-ft");
		obj.AcType = c.getNode("sim/model/ac-type");
		obj.type = c.getName();
		obj.index = c.getIndex();
		obj.string = "ai/models/" ~ obj.type ~ "[" ~ obj.index ~ "]";
		obj.shortstring = obj.type ~ "[" ~ obj.index ~ "]";
		obj.InstrTgts = props.globals.getNode("instrumentation/radar2/targets", 1);
		obj.TgtsFiles = obj.InstrTgts.getNode(obj.shortstring, 1);

		obj.Range          = obj.RdrProp.getNode("range-nm");
		obj.Bearing        = obj.RdrProp.getNode("bearing-deg");
		obj.Elevation      = obj.RdrProp.getNode("elevation-deg");
		obj.BBearing       = obj.TgtsFiles.getNode("bearing-deg", 1);
		obj.BHeading       = obj.TgtsFiles.getNode("true-heading-deg", 1);
		obj.RangeScore     = obj.TgtsFiles.getNode("range-score", 1);
		obj.RelBearing     = obj.TgtsFiles.getNode("ddd-relative-bearing", 1);
		obj.Carrier        = obj.TgtsFiles.getNode("carrier", 1);
		obj.EcmSignal      = obj.TgtsFiles.getNode("ecm-signal", 1);
		obj.EcmSignalNorm  = obj.TgtsFiles.getNode("ecm-signal-norm", 1);
		obj.EcmTypeNum     = obj.TgtsFiles.getNode("ecm_type_num", 1);

		obj.RadarStandby = c.getNode("sim/multiplay/generic/int[6]");
		obj.deviation = nil;

		return obj;
	},
	get_heading : func {
		var n = me.Heading.getValue();
		me.BHeading.setValue(n);
		return n;
	},
	get_bearing : func {
		var n = me.Bearing.getValue();
		me.BBearing.setValue(n);
		return n;
	},
	set_relative_bearing : func(n) {
		me.RelBearing.setValue(n);
	},
	get_reciprocal_bearing : func {
		return geo.normdeg(me.get_bearing() + 180);
	},
	get_deviation : func(true_heading_ref) {
		me.deviation =  - deviation_normdeg(true_heading_ref, me.get_bearing());
		return me.deviation;
	},
	get_altitude : func {
		return me.Alt.getValue();
	},
	get_range : func {
		return me.Range.getValue();
	},
	get_horizon : func(own_alt) {
		var tgt_alt = me.get_altitude();
		if ( tgt_alt != nil ) {
			if ( own_alt < 0 ) { own_alt = 0.001 }
			if ( debug.isnan(tgt_alt)) {
				return(0);
			}
			if ( tgt_alt < 0 ) { tgt_alt = 0.001 }
			return radardist.radar_horizon( own_alt, tgt_alt );
		} else {
			return(0);
		}
	},
	check_carrier_type : func {
		var type = "none";
		var carrier = 0;
		if ( me.AcType != nil ) { type = me.AcType.getValue() }
		if ( type == "MP-Nimitz" or type == "MP-Eisenhower"  or type == "MP-Vinson") { carrier = 1 }
		# This works only after the mp-carrier model has been loaded. Before that it is seen like a common aircraft.
		me.Carrier.setBoolValue(carrier);
		return carrier;
	},
	get_rdr_standby : func {
		var s = 0;
		if ( me.RadarStandby != nil ) {
			s = me.RadarStandby.getValue();
			if (s == nil) { s = 0 } elsif (s != 1) { s = 0 }
		}
		return s;
	},
	list : [],
};


