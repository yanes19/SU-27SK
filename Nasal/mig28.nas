# License: GPL 2.0
# Author: Nikolai V. Chr.
var TopGun = {
	# To start, type in nasal console: mig28.start(difficulty);
	# To stop, type in nasal console: mig28.stop();
	# Training floor is 10000ft, ceiling is 40000ft.
	# Collision is enabled.
	# Do not do this in mountainous or high ground areas. Best is flat and elevation below 5000ft above sealevel.
	# The mig-28 instructor will only fight you with cannon.
	# Do not pause the sim, that might mess up the mig-28.
	# There must be scenery and if you fly away from the mig28 so he get outside where there is scenery he might reset.
	# He will also reset if he stalls or hit the ground.
	new: func () {
		var obj = {parents: [TopGun]};
		obj.startHeading = rand()*360;
		obj.filterBearing = lowpass.new(1);
		obj.filterClock   = lowpass.new(1);
		return obj;
	},
	enabled: 0,
	warnTime: 0,
	runner: func {},
	start: func (opponents = nil, blufor = nil) {
		if (me.enabled) {
			print("TopGun: Already started, try stop() before starting again.");
			screen.log.write("Scenario is already started, try 'stop' before starting again.", 1.0, 1.0, 0.0);
			return;
		}
		if (opponents == nil) {
			opponents = [nil];
		}
		me.opponent = opponents[0];
		me.blufor = blufor==nil?(me.opponent!=nil):blufor;
		me.opponents = opponents;
		me.enabled = 1;
		var model = getprop("sim/model/path");
		var n = props.globals.getNode("models", 1);
		var i = 0;
		for (i = 0; 1==1; i += 1) {
			if (n.getChild("model", i, 0) == nil) {
				break;
			}
		}
		me.model = n.getChild("model", i, 1);

		n = props.globals.getNode("ai/models", 1);
		for (i = 0; 1==1; i += 1) {
			if (n.getChild(me.blufor?BLUFOR_AIRCRAFT_TYPE:OPFOR_AIRCRAFT_TYPE, i, 0) == nil) {
				break;
			}
		}
		me.ai = n.getChild(me.blufor?BLUFOR_AIRCRAFT_TYPE:OPFOR_AIRCRAFT_TYPE, i, 1);
		me.ai.getNode("valid", 1).setBoolValue(0);
		me.ai.getNode("name", 1).setValue("No-name");
		me.ai.getNode("sign", 1).setValue("Bandit");
		me.ai.getNode("type", 1).setValue(me.blufor?BLUFOR_AIRCRAFT_TYPE:OPFOR_AIRCRAFT_TYPE);
		me.ai.getNode("callsign", 1).setValue(me.callsign);
		#me.ai.getNode("sim/multiplay/generic/bool[2]",1).setBoolValue(0);#damage smoke
		#me.ai.getNode("sim/multiplay/generic/bool[40]",1).setBoolValue(1);
		#me.ai.getNode("sim/multiplay/generic/bool[41]",1).setBoolValue(1);#lights
		#me.ai.getNode("sim/multiplay/generic/bool[42]",1).setBoolValue(1);
		#me.ai.getNode("sim/multiplay/generic/bool[43]",1).setBoolValue(1);
		#me.ai.getNode("sim/multiplay/generic/bool[44]",1).setBoolValue(1);
		#me.ai.getNode("gear/gear[0]/position-norm",1).setDoubleValue(0);#gear
		#me.ai.getNode("gear/gear[1]/position-norm",1).setDoubleValue(0);#gear
		#me.ai.getNode("gear/gear[1]/position-norm",1).setDoubleValue(0);#gear
		#me.ai.getNode("sim/multiplay/generic/bool[39]",1).setDoubleValue(1);#aug
		me.lockNode = me.ai.getNode("sim/multiplay/generic/string[6]",1);
		me.lockNode.setValue("");#radar lock

		me.ai.getNode("sim/multiplay/generic/int[2]",1).setBoolValue(0);#radar standby
		me.model.getNode("path", 1).setValue(model);

		me.nodeLat   = me.ai.getNode("position/latitude-deg", 1);
		me.nodeLon   = me.ai.getNode("position/longitude-deg", 1);
		me.nodeAlt   = me.ai.getNode("position/altitude-ft", 1);
		me.nodeHeading   = me.ai.getNode("orientation/true-heading-deg", 1);
		me.nodePitch = me.ai.getNode("orientation/pitch-deg", 1);
		me.nodeRoll  = me.ai.getNode("orientation/roll-deg", 1);

		me.a16Coord = geo.aircraft_position();

		me.nodeLat.setDoubleValue(me.a16Coord.lat());
		me.nodeLon.setDoubleValue(me.a16Coord.lon());
		me.nodeAlt.setDoubleValue(25000);
		me.nodeHeading.setDoubleValue(me.startHeading);
		me.nodePitch.setDoubleValue(0);
		me.nodeRoll.setDoubleValue(0);

		me.model.getNode("latitude-deg-prop", 1).setValue(me.nodeLat.getPath());
		me.model.getNode("longitude-deg-prop", 1).setValue(me.nodeLon.getPath());
		me.model.getNode("elevation-ft-prop", 1).setValue(me.nodeAlt.getPath());
		me.model.getNode("heading-deg-prop", 1).setValue(me.nodeHeading.getPath());
		me.model.getNode("pitch-deg-prop", 1).setValue(me.nodePitch.getPath());
		me.model.getNode("roll-deg-prop", 1).setValue(me.nodeRoll.getPath());
		me.loadNode = me.model.getNode("load", 1);

		TopGun.mig28Score = 0;
		TopGun.a16Score = 0;

		#print("TopGun: starting");
		if(me.blufor) {
			screen.log.write(me.callsign~": Hello.", 0.0, 1.0, 0.0);
		} else {
			screen.log.write(me.callsign~": Hello.", 1.0, 1.0, 0.0);
		}
		me.spwn();
	},

	stop: func {
		if (me.enabled) {
			me.ai.getNode("valid", 1).setBoolValue(0);
			me.model.remove();
			me.ai.remove();
			screen.log.write(me.callsign~": I am returning to base, the score is (OPFOR "~TopGun.mig28Score~"- BLUFOR "~TopGun.a16Score~")", 1.0, 1.0, 0.0);
			print("TopGun: stopped.");
			setprop("ai/models/model-removed", me.ai.getPath());
		}
		me.enabled = 0;
	},

	spwn: func {
		me.ai.getNode("valid").setBoolValue(1);

		me.reset();
		if (me.blufor) {
			screen.log.write(me.callsign~": Hey, I'll be your wingman.", 0.0, 1.0, 0.0);
		} else {
			if (me.callsign == CS_0_enemy) {
				screen.log.write(me.callsign~": I will go easy on you, try to stay on my six. Have fun.", 1.0, 1.0, 0.0);
			} elsif (me.callsign == CS_1_enemy) {
				screen.log.write(me.callsign~": Nice weather for a fair fight, let's go.", 1.0, 1.0, 0.0);
			} elsif (me.callsign == CS_2_enemy) {
				screen.log.write(me.callsign~": Let's do this, don't make any mistakes.", 1.0, 1.0, 0.0);
			} elsif (me.callsign == CS_3_enemy) {
				screen.log.write(me.callsign~": Fight's on!", 1.0, 1.0, 0.0);
			} elsif (me.callsign == CS_4_enemy1) {
				screen.log.write(me.callsign~": This is the end-game...", 1.0, 1.0, 0.0);
			} elsif (me.callsign == CS_5_enemy1) {
				screen.log.write(me.callsign~": Lets do this.", 1.0, 1.0, 0.0);
			} elsif (me.callsign == CS_6_enemy1) {
				screen.log.write(me.callsign~": Bring it on.", 1.0, 1.0, 0.0);
			}
		}
		me.apply();
		me.loadNode.setBoolValue(1);
		setprop("ai/models/model-added", me.ai.getPath());
		print("TopGun: "~me.callsign~" spawned");
	},

	reset: func () {
		me.speed = 450*KT2MPS;
		me.mach = 1.0;
		me.heading = me.startHeading;
		me.coord = geo.Coord.new(geo.aircraft_position());
		me.lat = me.coord.lat();
		me.lon = me.coord.lon();
		me.alt = me.coord.alt()+500+rand()*10000*FT2M;
		me.coord.set_alt(me.alt);
		me.roll = 0;
		me.pitch = 0;
		me.think = GO_STRAIGHT;
		me.thinkLast = GO_STRAIGHT;
		me.thrust = 0.5;
		me.elapsed = systime();
		me.elapsed_last = systime()-UPDATE_RATE;
		me.dt = UPDATE_RATE;
		me.decisionTime = systime();
		me.specialTime = me.elapsed;
		me.scissorTime = systime();
		me.circleTime = 0;
		me.rollTarget = me.roll;
		me.pitchTarget = me.pitch;
		me.scissorTarget = -MAX_ROLL;
		me.a16Clock = 0;
		me.f16Clock = 0;
		me.keepDecisionTime = 0;
		me.sightTime = 0;
		me.killTime = 0;
		me.dist_nm = 0;
		me.turnStack = 0;
		me.Gf = 0;
		me.G  = 1;
		me.hisAim = 0;
		me.rollNorm = 0;
		me.turnSpeed = 0;
		me.a16Bearing = 0;
		me.f16Bearing = 0;
		me.altTarget_ft = nil;
		me.specialMove = 0;
		me.deadly = nil;
		me.switchTime = 0;

		#print("TopGun: deciding to RESET!");
	},

	decide: func {
		if (me.enabled == 0) {
			print("TopGun: interupted training session.");
			return;
		}
		me.elapsed = systime();
		me.dt = (me.elapsed - me.elapsed_last)*getprop("sim/speed-up");
		me.elapsed_last = me.elapsed;
		if(me.dt > 0.5) {
			me.dt = UPDATE_RATE;
		}
		me.random = rand();
		me.deadly = nil;

		if (size(me.opponents) > 1 and me.elapsed - me.switchTime > 45) {
			foreach(opp ; me.opponents) {
				if (opp == nil) continue;
				if (opp.deadly == me or (me.blufor and opp.deadly == "F-16")) {
					if (opp != me.opponent) {
						if (me.keepDecisionTime != -1) {
							me.keepDecisionTime = 0;
						}
						me.switchTime = me.elapsed;
						me.opponent = opp;
						if (me.blufor) {
							# he can actually also be in front, need to destinguish..
							screen.log.write(me.callsign~": "~opp.callsign~" is on my six!", 0.0, 1.0, 0.0);
						}
						break;
					}
				}
			}
		}
		if (me.elapsed - me.switchTime > 240) {
			# time to switch opponent to mix it up a bit
			me.opponent = me.opponents[me.clamp(int(me.random*(size(me.opponents))),0,size(me.opponents)-1)];
			me.switchTime = me.elapsed;
			if (me.keepDecisionTime != -1) {
				me.keepDecisionTime = 0;
			}
		}

		# we always need some info from the player:
		me.a16Coord = geo.aircraft_position();
		me.a16Pitch = vector.Math.getPitch(me.coord,me.a16Coord);
		me.a16Heading = getprop("orientation/heading-deg");
		#me.a16Elev  = me.a16Pitch-me.pitch;
		me.mig28Elev  = -me.a16Pitch-getprop("orientation/pitch-deg");
		#me.f16BearingOld = me.f16Bearing;
		me.f16Bearing = me.coord.course_to(me.a16Coord);
		#me.a16BearingRate = geo.normdeg180(me.f16Bearing-me.f16BearingOld)/me.dt;
		#me.f16ClockLast = me.a16Clock;
		#me.f16ClockOld = me.f16Clock;
		me.f16Clock = geo.normdeg180(me.f16Bearing-me.heading);
		#me.a16ClockRate = (me.f16Clock-me.f16ClockOld)/me.dt;
		#me.a16Range = me.coord.distance_to(me.a16Coord)*M2NM;
		#me.a16Speed = getprop("velocities/groundspeed-kt")*KT2MPS;
		#me.a16Roll  = getprop("orientation/roll-deg");
		me.hisBearing = me.a16Coord.course_to(me.coord);
		me.hisClock = geo.normdeg180(me.hisBearing-me.a16Heading);
		me.dist_f16_nm = me.a16Coord.direct_distance_to(me.coord)*M2NM;

		if (!me.blufor and me.elapsed - me.switchTime > 45 and me.opponent != nil and math.abs(me.f16Clock) > 140 and math.abs(me.a16Pitch)<15 and math.abs(me.hisClock) < 20 and me.dist_f16_nm < 2.0) {
			me.opponent = nil;
			me.switchTime = me.elapsed;
			#screen.log.write(me.callsign~": Going after F-16..", 1.0, 1.0, 0.0);
			if (me.keepDecisionTime != -1) {
				me.keepDecisionTime = 0;
			}
		}
		if (!me.blufor and me.elapsed - me.killTime > 4 and (math.abs(me.f16Clock) < 20 or math.abs(me.f16Clock) > 120) and math.abs(me.mig28Elev)<3 and math.abs(me.hisClock) < 3 and me.dist_f16_nm < MAX_CANNON_RANGE) {
			me.hisAim += me.dt;
		} else {
			me.hisAim = 0;
		}
		if (me.hisAim > 1) {
			me.hisAim = 0;
			TopGun.a16Score += 1;
			screen.log.write(me.callsign~": Good job! You have a firing solution..("~TopGun.mig28Score~"-"~TopGun.a16Score~")", 1.0, 1.0, 0.0);
			me.killTime = me.elapsed;
		}

		if (me.opponent != nil) {
#			print(me.callsign ~" chasing "~me.opponent.callsign);
		} else {
#			print(me.callsign ~" chasing player");
		}

		if (me.dist_f16_nm < 0.25) {
			# collision with player eminent
			me.think = GO_COLLISION_AVOID;
			me.keepDecisionTime = 0.15;
			me.tmp = me.a16Clock;
			me.a16Clock = me.f16Clock;
			me.decided();
			me.move();
			me.a16Clock = me.tmp;
			return;
		}

		# okay, lets get some info on the opponent
		me.dist_old_nm = me.dist_nm;
		if (me.opponent != nil and me.opponent["mach"] != nil) {
			me.a16Coord = me.opponent.coord;
			me.a16Pitch = vector.Math.getPitch(me.coord,me.a16Coord);
			me.a16Heading = me.opponent.heading;
			me.a16Elev  = me.a16Pitch-me.pitch;
			me.mig28Elev  = -me.a16Pitch-me.opponent.pitch;
			me.a16BearingOld = me.a16Bearing;
			me.a16Bearing = me.coord.course_to(me.a16Coord);
			#me.a16BearingRate = me.filterBearing.filter(geo.normdeg180(me.a16Bearing-me.a16BearingOld),me.dt)/me.dt;
			me.a16BearingRate = geo.normdeg180(me.a16Bearing-me.a16BearingOld)/me.dt;
			#if (me.callsign=="LtCol.Snuff") printf("%.1f %.1f", geo.normdeg180(me.a16Bearing-me.a16BearingOld)/me.dt, me.a16BearingRate);
			me.a16ClockLast = me.a16Clock;
			me.a16ClockOld = me.a16Clock;
			me.a16Clock = geo.normdeg180(me.a16Bearing-me.heading);
			#me.a16ClockRate = me.filterClock.filter(me.a16Clock-me.a16ClockOld,me.dt)/me.dt;
			me.a16ClockRate = (me.a16Clock-me.a16ClockOld)/me.dt;
			me.a16Range = me.coord.distance_to(me.a16Coord)*M2NM;
			me.a16Speed = me.opponent.speed;
			me.a16Roll  = me.opponent.roll;
			me.hisBearing = me.a16Coord.course_to(me.coord);
			me.hisClock = geo.normdeg180(me.hisBearing-me.a16Heading);
			me.dist_nm = me.a16Coord.direct_distance_to(me.coord)*M2NM;
#			printf("%s: %d NM, rel.bearing %d rate %d",me.callsign,me.a16Range,me.a16Clock,me.a16BearingRate);
		} else {
			me.a16Coord = geo.aircraft_position();
			me.a16Pitch = vector.Math.getPitch(me.coord,me.a16Coord);
			me.a16Heading = getprop("orientation/heading-deg");
			me.a16Elev  = me.a16Pitch-me.pitch;
			me.mig28Elev  = -me.a16Pitch-getprop("orientation/pitch-deg");
			me.a16BearingOld = me.a16Bearing;
			me.a16Bearing = me.coord.course_to(me.a16Coord);
			#me.a16BearingRate = me.filterBearing.filter(geo.normdeg180(me.a16Bearing-me.a16BearingOld),me.dt)/me.dt;
			me.a16BearingRate = geo.normdeg180(me.a16Bearing-me.a16BearingOld)/me.dt;
			me.a16ClockLast = me.a16Clock;
			me.a16ClockOld = me.a16Clock;
			me.a16Clock = geo.normdeg180(me.a16Bearing-me.heading);
			#me.a16ClockRate = me.filterClock.filter(me.a16Clock-me.a16ClockOld,me.dt)/me.dt;
			me.a16ClockRate = (me.a16Clock-me.a16ClockOld)/me.dt;
			me.a16Range = me.coord.distance_to(me.a16Coord)*M2NM;
			me.a16Speed = getprop("velocities/groundspeed-kt")*KT2MPS;
			me.a16Roll  = getprop("orientation/roll-deg");
			me.hisBearing = me.a16Coord.course_to(me.coord);
			me.hisClock = geo.normdeg180(me.hisBearing-me.a16Heading);
			me.dist_nm = me.a16Coord.direct_distance_to(me.coord)*M2NM;
		}

		if (!me.blufor and me.a16Range < 70 and math.abs(me.a16Elev)<25 and math.abs(me.a16Clock) < 55) {
			# Mig28 radar has lock on pilot
			me.lockNode.setValue(left(md5(getprop("sim/multiplay/callsign")), 4));
		} else {
			me.lockNode.setValue("");
		}

		if(!me.blufor and me.a16Coord.alt()*M2FT < FLOOR-3000 and me.elapsed - TopGun.warnTime > 15) {
			screen.log.write(me.callsign~": Stay above "~FLOOR~" feet.", 1.0, 1.0, 0.0);
			TopGun.warnTime = me.elapsed;
		}
		if(!me.blufor and me.a16Coord.alt()*M2FT > CEILING+3000 and me.elapsed - TopGun.warnTime > 15) {
			screen.log.write(me.callsign~": Stay below "~CEILING~" feet.", 1.0, 1.0, 0.0);
			TopGun.warnTime = me.elapsed;
		}



		if (me.keepDecisionTime != -1 and (me.elapsed - me.decisionTime) > me.keepDecisionTime) {
			if (me.alt < (FLOOR+2000)*FT2M and me.GStoKIAS(me.speed*MPS2KT) < 275) {
				# low speed at low alt, need to fly straight for 8 secs to get some speed
				me.think = GO_STRAIGHT;
				me.thrust = 1;
				me.keepDecisionTime = 8;
				me.decided();
			} elsif (me.alt > (CEILING-2000)*FT2M and me.GStoKIAS(me.speed*MPS2KT) > 700) {
				# high speed at high alt, need to turn hard for 6 secs to bleed some speed
				me.think = me.random>0.5?GO_LEFT:GO_RIGHT;
				me.thrust = -0.1;#speedbrakes enabled
				me.keepDecisionTime = 6;
				me.decided();
			} elsif (me.alt < FLOOR*FT2M) {
				# below training floor, go up for 5 secs
				me.think = GO_UP;
				me.thrust = 1;
				me.keepDecisionTime = 5;
				me.decided();
			} elsif (me.alt > CEILING*FT2M) {
				# above training ceiling go down to 36000
				me.think = GO_DOWN;
				me.thrust = 0;
				me.altTarget_ft = CEILING-4000;
				me.pitchTarget = 90;
				me.keepDecisionTime = -1;
				me.decided();
			} elsif (me.GStoKIAS(me.speed*MPS2KT) < 275 and me.a16Speed > me.speed and me.alt*M2FT>FLOOR+5000) {
				# too low speed, go 5000 ft down
				me.think = GO_DOWN;
				me.thrust = 1;
				me.altTarget_ft = math.max((FLOOR+1000), (me.alt)*M2FT-5000);
				me.pitchTarget = 90;
				me.keepDecisionTime = -1;
				me.decided();
			} elsif (me.GStoKIAS(me.speed*MPS2KT) < 200 and me.alt*M2FT>FLOOR+5000) {
				# too low speed, go 7500 ft down
				me.think = GO_DOWN;
				me.thrust = 1;
				me.altTarget_ft = math.max((FLOOR+1000), (me.alt)*M2FT-7500);
				me.pitchTarget = 90;
				me.keepDecisionTime = -1;
				me.decided();
			} elsif (me.GStoKIAS(me.speed*MPS2KT) < 200) {
				# too low speed, go straight for 12 secs
				me.think = GO_STRAIGHT;
				me.thrust = 1;
				me.pitchTarget = 0;
				me.keepDecisionTime = 12;
				me.decided();
			} elsif (me.GStoKIAS(me.speed*MPS2KT) > 750 or me.mach > 1.9) {
				# too high speed, go up for 4.5 secs
				me.think = GO_UP;
				me.thrust = 0;
				me.keepDecisionTime = 4.5;
				me.decided();
			} else {
				# here comes reaction to a16

				me.a16ClockAbs = math.abs(me.a16Clock);
				me.hisClockAbs = math.abs(me.hisClock);
				if (me.dist_nm < 0.25 and me.dist_old_nm > me.dist_nm and me.dist_nm > 0.05 and me.a16ClockAbs<100 and ((me.a16Clock<0 and me.a16ClockRate<-5)or(me.a16Clock>0 and me.a16ClockRate>5))) {
					# In-Close Overshoot, typically as result of lag pursuit. (crossing opponent flight path close to him)
					me.think = GO_STRAIGHT;
					me.keepDecisionTime = 1.5;
				} elsif (me.dist_nm < 0.25 and me.dist_old_nm > me.dist_nm and me.a16ClockAbs<100) {
					# Safety: anti collision
					me.think = GO_COLLISION_AVOID;
					me.keepDecisionTime = 0.15;
				} elsif (me.hisClockAbs > 160 and me.a16ClockAbs > 160 and me.a16Range > 0.15 and me.a16Range < 1.5 and math.abs(450-me.GStoKIAS(me.a16Speed)) > math.abs(450-me.GStoKIAS(me.speed))) {
					# Offensive: Two circle flow due to better turn rate after merge
					me.think = GO_FLOW_TWO_CIRCLE;
					me.a16RollFrozen = me.a16Roll;
					me.thrust = 1;
					me.keepDecisionTime = 4;
				} elsif (me.hisClockAbs > 155 and me.a16ClockAbs > 155 and me.a16Range > 0.15 and me.a16Range < 1.5 and me.a16Speed > me.speed) {
					# Offensive: One circle flow due to smaller turn radius after merge
					me.think = GO_FLOW_ONE_CIRCLE;
					me.a16RollFrozen = me.a16Roll;
					me.thrust = 0.75;
					me.keepDecisionTime = 4;
				} elsif (me.hisClockAbs > 155 and me.a16ClockAbs > 155 and me.a16Range > 0.15 and me.a16Range < 1.5) {
					# Defensive: After merge and being at disadvantage. Fly straight for some energy.
					me.think = GO_STRAIGHT;
					me.thrust = 1;
					me.keepDecisionTime = 7;
				} elsif (me.hisClockAbs > 155 and me.a16ClockAbs > 155 and me.a16Range < 1.5) {
					# Defensive: After merge fly straight until decide how to flow.
					me.think = GO_STRAIGHT;
					me.thrust = 1;
					me.keepDecisionTime = 0.15;
				} elsif (me.hisClockAbs > 75 and me.a16ClockAbs < 60 and me.a16Range > MAX_CANNON_RANGE+0.25 and me.a16Range < 3.5 and me.a16Speed > me.speed*1.125) {
					# Offensive: lower speed, out of range but behind bandit
					me.think = GO_LEAD_PURSUIT;
					me.thrust = 0.75;
					me.keepDecisionTime = 0.15;
				} elsif (me.hisClockAbs < 170 and me.hisClockAbs > 90 and me.a16ClockAbs < 60 and me.a16Range > MAX_CANNON_RANGE+0.25 and me.a16Range < 3.5) {
					# Offensive: behind bandit, but out of fire range, when reach lag point, do pure for cold-side lag attack.
					me.think = GO_LAG_PURSUIT;
					me.thrust = 1;
					me.keepDecisionTime = 0.15;
				} elsif ((me.hisClockAbs < 20 or me.hisClockAbs > 120) and math.abs(me.a16Elev)<5 and me.a16ClockAbs < 5) {
					# Offensive: has aim on the bandit, slow down a bit and keep that aim
					if (me.dist_nm < 2) {
						me.deadly = me.opponent==nil?"F-16":me.opponent;
					}
					me.think = GO_PURE_PURSUIT;
					me.circleTime = me.elapsed;
					me.thrust = 1;
					me.thrust = math.min(1.0,me.thrust*me.dist_nm/(0.25+MAX_CANNON_RANGE));
					if (me.elapsed - me.sightTime > 10 and me.dist_nm < MAX_CANNON_RANGE) {
						if (!me.blufor) {
							TopGun.mig28Score += 1;
							if (me.opponent == nil) {
								screen.log.write(me.callsign~": Hey! I have you in my gunsight..("~TopGun.mig28Score~"-"~TopGun.a16Score~")", 1.0, 1.0, 0.0);
							} else {
								me.opponent.switchTime = me.opponent.elapsed;#major hack :)
								screen.log.write(me.callsign~": Your wingman is in my gunsight..("~TopGun.mig28Score~"-"~TopGun.a16Score~")", 1.0, 1.0, 0.0);
							}
						} else {
							TopGun.a16Score += 1;
							screen.log.write(me.callsign~": Splash one! ("~TopGun.mig28Score~"-"~TopGun.a16Score~")", 0.0, 1.0, 0.0);
							me.opponent.switchTime = me.opponent.elapsed;#major hack :)
						}
						me.sightTime = me.elapsed;
					}
					me.keepDecisionTime = 0.15;
				} elsif (math.abs(me.a16Elev)<15 and me.a16ClockAbs <= 150 and ((me.a16Clock > 40 and me.hisClock < -2 and me.hisClock > -50 and me.a16Roll>0) or (me.a16Clock < 40 and me.hisClock > 2  and me.hisClock < 50 and me.a16Roll<0)) and me.a16Speed*1.25 < me.speed and me.a16Range<4) {
					# Defensive: bandit does lead pursuit but has lower speed. Gently turn opposite the lead and away with full thrust until range better.
					me.think = GO_LEAD_DEFEND_AWAY;
					me.thrust = 1;
					me.keepDecisionTime = 8;
				} elsif (me.elapsed - me.specialTime > 120 and me.alt*M2FT>15000 and me.alt*M2FT<20000 and me.speed*MPS2KT<600 and me.speed*MPS2KT>450 and (me.random<0.01 or me.elapsed - me.circleTime > 50 or (math.mod(TopGun.a16Score,2) > 0 and me.a16ClockAbs > 140 and math.abs(me.a16Pitch)<15 and me.hisClockAbs < 20 and me.dist_nm < MAX_CANNON_RANGE+1.0))) {
					# Defensive: bandit has aim on mig28 going medium in medium alt, do loop
					me.think = GO_LOOP;
					me.thrust = 1;
					me.specialMove = 0;
					me.specialTime = me.elapsed;
					me.keepDecisionTime = -1;
				} elsif (me.elapsed - me.specialTime > 120 and me.alt*M2FT<17500 and me.speed*MPS2KT<600 and me.speed*MPS2KT>450 and (me.random<0.01 or me.elapsed - me.circleTime > 50 or (math.mod(TopGun.a16Score,2) > 0 and me.a16ClockAbs > 140 and math.abs(me.a16Pitch)<15 and me.hisClockAbs < 20 and me.dist_nm < MAX_CANNON_RANGE+1.0))) {
					# Defensive: bandit has aim on mig28 going fast in low alt, do immelmann
					me.think = GO_IMMEL;
					me.thrust = 1;
					me.specialMove = 0;
					me.specialTime = me.elapsed;
					me.keepDecisionTime = -1;
				} elsif (me.elapsed - me.specialTime > 120 and me.alt*M2FT>30000 and me.speed*MPS2KT<600 and (me.random<0.01 or me.elapsed - me.circleTime > 50 or (math.mod(TopGun.a16Score,2) > 0 and me.a16ClockAbs > 140 and math.abs(me.a16Pitch)<15 and me.hisClockAbs < 20 and me.dist_nm < MAX_CANNON_RANGE+1.0))) {
					# Defensive: bandit has aim on mig28 going not fast in high alt, do split S
					me.think = GO_SPLIT_S;
					me.specialMove = 0;
					me.specialTime = me.elapsed;
					me.thrust = 0;
					me.keepDecisionTime = -1;
				} elsif (math.mod(TopGun.a16Score,2) > 0 and me.alt<9000 and me.a16ClockAbs > 140 and math.abs(me.a16Pitch)<15 and me.hisClockAbs < 20 and me.dist_nm < MAX_CANNON_RANGE+1.0) {
					# Defensive: bandit has aim on mig28, go up just to do something else
					me.think = GO_UP;
					me.thrust = 1;
					me.keepDecisionTime = 2.0;
				} elsif (me.a16ClockAbs > 130 and math.abs(me.a16Pitch)<15 and me.hisClockAbs < 20 and me.dist_nm < MAX_CANNON_RANGE+1.0) {
					# Defensive: bandit has aim on mig28, do some scissors to not be hit
					if (me.think != GO_SCISSOR) {
						me.scissorTime = me.elapsed;
					}
					me.think = GO_SCISSOR;
					me.thrust = -0.1; #speedbrakes
					me.scissorPeriod = 1.5;
					me.keepDecisionTime = 0.15;
				} elsif (me.a16ClockAbs < 115 and me.a16ClockAbs > 75 and me.hisClockAbs > 75 and me.hisClockAbs < 115 and me.dist_nm < 1.5 and math.abs(geo.normdeg180(me.heading-me.a16Heading))<30) {
					# Offensive: scissor response to parallel flight
					if (me.think != GO_SCISSOR) {
						me.scissorTime = me.elapsed;
					}
					me.scissorTarget = me.a16Clock < 0?-MAX_ROLL:MAX_ROLL;
					me.think = GO_SCISSOR;
					me.thrust = 0.75;
					me.scissorPeriod = me.a16Range;
					me.keepDecisionTime = me.a16Range*2;
				} elsif (me.think==GO_PURE_PURSUIT and me.elapsed - me.circleTime > 80 and me.dist_nm < 5) {
					# been in turn fight for 80 secs+ and not gaining aspect
					# turn fight going bad, break circle
					if (me.alt*M2FT < 25000) {
						me.think = GO_BREAK_UP;
						me.thrust = 1;
						me.keepDecisionTime = 7;
					} else {
						me.think = GO_BREAK_DOWN;
						me.thrust = 0.75;
						me.keepDecisionTime = 6;
					}
				} else {
					# turn fight to try and get bandit in sight
					if (me.think != GO_PURE_PURSUIT) {
						me.circleTime = me.elapsed;
					}
					me.think = GO_PURE_PURSUIT;
					me.corner = math.max(425, math.max(me.dist_nm*100,me.GStoKIAS(me.a16Speed)));
					if (me.GStoKIAS(me.speed*MPS2KT) > me.corner+300) {
						me.thrust = 0.25;
					} elsif (me.GStoKIAS(me.speed*MPS2KT) > me.corner+200) {
						me.thrust = 0.5;
					} elsif (me.GStoKIAS(me.speed*MPS2KT) > me.corner+100) {
						me.thrust = 0.75;
					} else {
						me.thrust = 1;
					}
					me.keepDecisionTime = 0.15;
				}
				me.decided();
			}
		}
		me.move();
	},

	decided: func {
		if(me.think == GO_STRAIGHT)me.prt="fly straight";
		if(me.think==GO_LEFT)me.prt="turn left";
		if(me.think==GO_RIGHT)me.prt="turn right";
		if(me.think==GO_UP)me.prt="go up";
		if(me.think==GO_DOWN)me.prt=sprintf("dive to %d ft",me.altTarget_ft);
		if(me.think==GO_PURE_PURSUIT)me.prt="do pure pursuit";
		else me.circleTime = me.elapsed;
		if(me.think==GO_SCISSOR)me.prt="do flat scissor";
		if(me.think==GO_BREAK_UP)me.prt="break up the circle";
		if(me.think==GO_BREAK_DOWN)me.prt="break down the circle";
		if(me.think==GO_LEAD_PURSUIT)me.prt="do lead pursuit";
		if(me.think==GO_LAG_PURSUIT)me.prt="do lag pursuit";
		if(me.think==GO_LEAD_DEFEND_AWAY)me.prt="does lead pursuit defense";
		if(me.think==GO_COLLISION_AVOID)me.prt="does collision avoidance";
		if(me.think==GO_IMMEL)me.prt="does an Immelmann";
		if(me.think==GO_SPLIT_S)me.prt="does a split S";
		if(me.think==GO_LOOP)me.prt="does a loop";
		if(me.think==GO_FLOW_ONE_CIRCLE)me.prt="flows into one circle";
		if(me.think==GO_FLOW_TWO_CIRCLE)me.prt="flows into two circles";
		#if (me.callsign==CS_6_friend) printf(me.callsign~" deciding to %s. Speed %d KIAS/M%.2f at %d ft. Roll %d, pitch %d. Thrust %.1f%%. %.1f NM. %.1f horz G",me.prt,me.GStoKIAS(me.speed*MPS2KT),me.mach,me.alt*M2FT,me.roll,me.pitch,me.thrust*100, me.dist_nm, me.rollNorm*(me.rollNorm<0?-1:1)*me.G*0.8888+1);
		me.view = getprop("sim/current-view/missile-view");
		if (me.thinkLast != me.think) {
			record[me.think] = record[me.think]+1;
			#if(getprop("sim/current-view/view-number")==8 and me.view != nil and find(me.callsign, me.view) != -1) {
			#	screen.log.write(me.callsign~" now "~me.prt, 1.0, 0.0, 0.0);
			#}
		}
		me.thinkLast = me.think;
		me.decisionTime = me.elapsed;
	},

	move: func {
		if (me.think == GO_STRAIGHT) {
			me.rollTarget = 0;
			me.pitchTarget = 0;
			me.step();
		} elsif (me.think == GO_LEFT) {
			me.rollTarget = -MAX_ROLL;
			me.pitchTarget = 0;
			me.step();
		} elsif (me.think == GO_RIGHT) {
			me.rollTarget =  MAX_ROLL;
			me.pitchTarget = 0;
			me.step();
		} elsif (me.think == GO_UP) {
			me.rollTarget = 0;
			me.pitchTarget = 45;
			me.step();
		} elsif (me.think == GO_FLOW_ONE_CIRCLE) {
			me.pitchTarget = me.a16Pitch;
			#me.rollTarget = me.a16BearingRate>=0?-MAX_ROLL:MAX_ROLL;
			me.rollTarget = me.a16RollFrozen>0?-MAX_ROLL:MAX_ROLL;
			me.step();
		} elsif (me.think == GO_FLOW_TWO_CIRCLE) {
			me.pitchTarget = me.a16Pitch;
			#me.rollTarget = me.a16BearingRate>=0?MAX_ROLL:-MAX_ROLL;
			me.rollTarget = me.a16RollFrozen>0?MAX_ROLL:-MAX_ROLL;
			me.step();
		} elsif (me.think == GO_LOOP) {
			if (me.specialMove == 1) {
				me.pitchTarget = 90;
				me.rollTarget = 0;
			} elsif (me.specialMove == 2) {
				me.pitchTarget = 0;
				me.rollTarget = 180;
			} elsif (me.specialMove == 3) {
				me.thrust = 0;
				me.pitchTarget = -90;
				me.rollTarget = 180;
			} elsif (me.specialMove == 4) {
				me.pitchTarget = 0;
				me.rollTarget = 0;
			} elsif (me.specialMove == 0) {
				# level before doing it
				me.thrust = 1;
				me.rollTarget = 0;
				me.pitchTarget = me.pitch;
			}
			me.step();
			if (me.roll == me.rollTarget and me.pitch == me.pitchTarget) {
				me.specialMove += 1;
				#print(me.specialMove~" "~me.pitch);
			}
			if (me.pitch == -90 and me.roll == 180) {
				me.roll = 0;
				me.heading = geo.normdeg(me.heading+180);
			} elsif (me.pitch == 90 and me.roll == 0) {
				me.roll = 180;
				me.heading = geo.normdeg(me.heading+180);
			}
			if (me.specialMove==5) {
				me.keepDecisionTime = 0;
			}
		} elsif (me.think == GO_SPLIT_S) {
			if (me.specialMove == 1) {#me.roll == 180
				me.pitchTarget = -90;
				me.rollTarget = 180;
			} elsif (me.specialMove == 2) {#me.roll == 0 and me.pitch < 0
				me.pitchTarget = 0;
				me.rollTarget = 0;
			} elsif (me.specialMove == 0) {
				# invert before doing it
				me.rollTarget = 180;
				me.pitchTarget = me.pitch;
			}
			me.step();
			if (me.roll == me.rollTarget and me.pitch == me.pitchTarget) {
				me.specialMove += 1;
			}
			if (me.pitch == -90 and me.roll == 180) {
				me.roll = 0;
				me.heading = geo.normdeg(me.heading+180);
			}
			if (me.specialMove==3) {#me.pitch >= 0 and me.roll == 0 and me.rollTarget == 0 and me.pitchTarget == 0
				me.keepDecisionTime = 0;
			}
		} elsif (me.think == GO_IMMEL) {
			if (me.specialMove == 1) {
				me.pitchTarget = 90;
				me.rollTarget = 0;
			} elsif (me.specialMove == 2) {
				me.pitchTarget = 0;
				me.rollTarget = 180;
			} elsif (me.specialMove == 0 or me.specialMove == 3) {
				# level before doing it
				me.thrust = 1;
				me.rollTarget = 0;
				me.pitchTarget = me.pitch;
			}
			me.step();
			if (me.roll == me.rollTarget and me.pitch == me.pitchTarget) {
				me.specialMove += 1;
				#print(me.specialMove~" "~me.pitch);
			}
			if (me.pitch == 90 and me.roll == 0) {
				me.roll = 180;
				me.heading = geo.normdeg(me.heading+180);
			}
			if (me.specialMove==4) {
				me.keepDecisionTime = 0;
			}
		} elsif (me.think == GO_DOWN) {
			me.pitchTargetOld = me.pitchTarget;
			me.maxPitch = me.clamp(MAX_DIVE_ANGLE*((me.alt*M2FT-me.altTarget_ft)/(me.ai.getNode("velocities/vertical-speed-fps").getValue()*MAX_DIVE_ANGLE/MAX_PITCH_UP_SPEED)),-MAX_DIVE_ANGLE,5);
			me.pitchTarget = math.max(-MAX_DIVE_ANGLE, (me.altTarget_ft-me.alt*M2FT)*0.010);
			#printf("max %d current %d target %d diff %d",me.maxPitch,me.pitch,me.pitchTarget,me.alt*M2FT-me.altTarget_ft);
			me.pitchTarget = math.min(me.pitchTarget,me.maxPitch);
			if (me.alt*M2FT < (FLOOR+1000)) {
				me.pitchTarget = 0;
			}
			me.rollTarget = (me.pitchTarget<=me.pitchTargetOld and me.pitchTarget<0)?(me.roll<0?-179:179):0;
			me.step();
			if (me.pitch > -1 and me.pitchTarget >= 0) {
				me.keepDecisionTime = 0;
				me.altTarget_ft = nil;
			}
		} elsif (me.think == GO_COLLISION_AVOID) {
			me.rollTarget = math.max(-1,math.min(1,-me.a16Clock*100))*MAX_ROLL;
			me.pitchTarget = me.clamp(-me.a16Pitch*5000,-90,90);
			me.step();
		} elsif (me.think == GO_PURE_PURSUIT) {
			me.turnrateTarget = (me.a16Clock*0.5+me.a16BearingRate);
			#if (me.blufor) printf("%s: %d target",me.callsign,me.turnrateTarget);
			me.pitchTarget = me.a16Pitch;
			me.rollTarget = nil;
			me.step();
		} elsif (me.think == GO_LEAD_DEFEND_AWAY) {
			me.rollTarget = math.max(-1,math.min(1,-me.a16Clock))*MAX_ROLL*0.75;
			me.pitchTarget = -10;
			me.step();
		} elsif (me.think == GO_LEAD_PURSUIT) {
			me.leadTarget = me.roll < 0?-15:15;
			me.turnrateTarget = (me.a16Clock+me.leadTarget)*0.5+me.a16BearingRate;
			me.pitchTarget = me.a16Pitch;
			me.rollTarget = nil;
			me.step();
		} elsif (me.think == GO_LAG_PURSUIT) {
			me.lagTarget = me.roll < 0?15:-15;
			me.turnrateTarget = (me.a16Clock+me.lagTarget)*0.5+me.a16BearingRate;
			me.pitchTarget = me.a16Pitch;
			me.rollTarget = nil;
			me.step();
		} elsif (me.think == GO_BREAK_UP) {
			me.rollTarget = math.max(-1,math.min(1,-me.a16Clock/15))*MAX_ROLL;
			me.pitchTarget = 50;
			me.step();
		} elsif (me.think == GO_BREAK_DOWN) {
			me.rollTarget = math.max(-1,math.min(1,-me.a16Clock/15))*MAX_ROLL;
			me.pitchTarget = -35;
			me.step();
		} elsif (me.think == GO_SCISSOR) {
			if (me.roll != MAX_ROLL and me.scissorTarget == MAX_ROLL) {
				me.rollTarget = MAX_ROLL;
			} elsif (me.roll != -MAX_ROLL and me.scissorTarget == -MAX_ROLL) {
				me.rollTarget = -MAX_ROLL;
			} elsif (math.abs(me.roll)==MAX_ROLL and me.elapsed - me.scissorTime > me.scissorPeriod) {
				me.scissorTarget = -me.scissorTarget;
				me.scissorTime = me.elapsed;
			}
			me.pitchTarget = 0;
			me.step();
		}
		me.apply();
	},

	step: func () {


		me.mach = me.machNow(me.speed*M2FT, me.alt*M2FT);
		me.turn = me.turnMax(me.mach,me.alt*M2FT);
		me.Gf        = math.min(1, me.extrapolate(me.turn[1], 3, 9, 1, math.max(0.11,(ENDURANCE*4.5*0.75)/math.max(0.00001,me.turnStack))));
		me.G         = me.Gf*me.turn[1];
		me.turnSpeed = me.Gf*me.turn[0];

		if (me.rollTarget == nil) {
			me.rollTarget = me.clamp(me.turnrateTarget/me.turnSpeed,-1,1)*MAX_ROLL;
		}
		if (me.altTarget_ft != nil or me.think==GO_IMMEL or me.think==GO_SPLIT_S or me.think==GO_LOOP) {
			if(me.rollTarget>me.roll) {
				me.roll += MAX_ROLL_RATE*me.dt;
				if (me.roll > me.rollTarget) {
					me.roll = me.rollTarget;
				}
			} elsif(me.rollTarget<me.roll) {
				me.roll -= MAX_ROLL_RATE*me.dt;
				if (me.roll < me.rollTarget) {
					me.roll = me.rollTarget;
				}
			}
			me.rollNorm = 0;
			if(me.pitchTarget>me.pitch) {
				me.pitch += MAX_PITCH_UP_SPEED*me.dt;
				if (me.pitch > me.pitchTarget) {
					me.pitch = me.pitchTarget;
				}
			} elsif(me.pitchTarget<me.pitch) {
				me.pitch -= MAX_PITCH_UP_SPEED*me.dt;
				if (me.pitch < me.pitchTarget) {
					me.pitch = me.pitchTarget;
				}
			}
		} else {
			if(me.rollTarget>me.roll) {
				me.roll += MAX_ROLL_SPEED*me.dt;
				if (me.roll > me.rollTarget) {
					me.roll = me.rollTarget;
				}
			} elsif(me.rollTarget<me.roll) {
				me.roll -= MAX_ROLL_SPEED*me.dt;
				if (me.roll < me.rollTarget) {
					me.roll = me.rollTarget;
				}
			}
			me.rollNorm = me.roll/MAX_ROLL;
			if(me.pitchTarget>me.pitch) {
				me.pitch += MAX_PITCH_UP_SPEED*me.dt;
				if (me.pitch > me.pitchTarget) {
					me.pitch = me.pitchTarget;
				}
			} elsif(me.pitchTarget<me.pitch) {
				me.pitch -= MAX_PITCH_DOWN_SPEED*me.dt;
				if (me.pitch < me.pitchTarget) {
					me.pitch = me.pitchTarget;
				}
			}
		}

		#printf("max turn %.1f  max G %.1f  stack %.1f  turn %.1f  G %.1f", me.turn[0],me.turn[1],me.turnStack,me.rollNorm*(me.rollNorm<0?-1:1)*me.turnSpeed,me.rollNorm*(me.rollNorm<0?-1:1)*me.G*0.8888+1);
		me.turnStack += (me.rollNorm*(me.rollNorm<0?-1:1)*me.G-4.5)*me.dt;
		me.turnStack = math.max(0,me.turnStack);
		me.heading = geo.normdeg(me.heading+me.rollNorm*me.turnSpeed*me.dt);
		me.speedHorz = math.cos(me.pitch*D2R)*me.speed;
		me.upFrac = math.sin(me.pitch*D2R);
		me.speedUp   = me.upFrac*me.speed;
		me.coord.apply_course_distance(me.heading, me.speedHorz*me.dt);
		me.alt += me.speedUp*me.dt;
		me.coord.set_alt(me.alt);
		me.lat = me.coord.lat();
		me.lon = me.coord.lon();
		me.turnNorm = me.rollNorm*me.turnSpeed/MAX_TURN_SPEED;

		me.deacc      = me.deaccMax();
		me.bleed      = me.extrapolate(me.turnNorm*(me.turnNorm<0?-1:1), 0, 1, 0, 0.75*math.abs(me.deacc*(me.rollNorm*me.turnSpeed))); # turn bleed  #math.abs((me.GStoKIAS(me.speed)*MPS2KT-450)/450)*me.deacc*BLEED_FACTOR+me.deacc*BLEED_FACTOR
		me.gravity    = 9.80665*me.upFrac;                                                       # gravity acc/deacc
		me.acc        = me.extrapolate(me.thrust, 0, 1, -me.deaccMax(), me.accMax());            # acc


		me.speed += (-me.gravity+me.acc-me.bleed)*me.dt; # the aircraft in level flight is unaffected by gravity drop.

		me.ground = geo.elevation(me.lat,me.lon);
		#printf("Max turn is %.1f deg/sec at this speed/altitude. Doing %.1f deg/sec at mach %.1f.", me.turnSpeed, me.rollNorm*me.turnSpeed,me.mach);
		if(me.ground == nil) {
			me.ground = 0;
		}
		if (me.GStoKIAS(me.speed) < (150*KT2MPS) or me.ground > me.alt) {
			print("s "~me.GStoKIAS(me.speed*MPS2KT));
			print("agl "~(me.ground == nil?"nil":(""~(me.alt-me.ground)*M2FT)));
			screen.log.write(me.callsign~": I hit ground, lost terrain or stalled, will reset. Sorry.", 1.0, 1.0, 0.0);
			me.reset();
		}
	},

	apply: func {
		me.nodeLat.setDoubleValue(me.lat);
		me.nodeLon.setDoubleValue(me.lon);
		me.nodeAlt.setDoubleValue(me.alt*M2FT);
		me.nodeHeading.setDoubleValue(me.heading);
		me.nodePitch.setDoubleValue(me.pitch);
		me.nodeRoll.setDoubleValue(me.roll);
		me.ai.getNode("velocities/true-airspeed-kt",1).setDoubleValue(me.speed*MPS2KT);
		me.ai.getNode("velocities/mach",1).setDoubleValue(me.mach);
		me.ai.getNode("accelerations/G",1).setDoubleValue(me.rollNorm*(me.rollNorm<0?-1:1)*me.G*0.8888+1);
		me.ai.getNode("orientation/turn-speed-dps",1).setDoubleValue(me.rollNorm*me.turnSpeed);
		me.ai.getNode("velocities/indicated-airspeed-kt",1).setDoubleValue(me.GStoKIAS(me.speed*MPS2KT));
		me.ai.getNode("instrumentation/transponder/transmitted-id",1).setIntValue(num_t);
		me.a16Coord = geo.aircraft_position();
		me.ai.getNode("radar/bearing-deg", 1).setDoubleValue(me.a16Coord.course_to(me.coord));
		me.ai.getNode("radar/elevation-deg", 1).setDoubleValue(vector.Math.getPitch(me.a16Coord, me.coord));
		me.ai.getNode("radar/range-nm", 1).setDoubleValue(me.a16Coord.distance_to(me.coord)*M2NM);
		me.ai.getNode("velocities/vertical-speed-fps",1).setDoubleValue(me.speed*M2FT*math.sin(me.pitch*D2R));
		me.ai.getNode("rotors/main/blade[3]/position-deg", 1 ).setDoubleValue(rand());#chaff
		me.ai.getNode("rotors/main/blade[3]/flap-deg", 1 ).setDoubleValue(rand());#flares
		#settimer(func {me.decide();}, UPDATE_RATE);
	},

	machNow: func (speed, altitude) {
		me.T = 0;
		if (altitude < 36152) {
			# curve fits for the troposphere
			me.T = 59 - 0.00356 * altitude;
		} elsif ( 36152 < altitude and altitude < 82345 ) {
			# lower stratosphere
			me.T = -70;
		} else {
			# upper stratosphere
			me.T = -205.05 + (0.00164 * altitude);
		}

		# calculate the speed of sound at altitude
		me.snd_speed = math.sqrt( 1.4 * 1716 * (me.T + 459.7));

		return speed/me.snd_speed;
	},

	turnMax: func (mach, altitude) {
		# Max turn rate
		# degs / sec , drag index 50
		# taken from Greek F-16 block 52 supplemental manual.
		if (mach>0.6) {#no cft
			me.a00 = me.extrapolate(mach, 0.6, 1.15, 22.5, 13);
			me.g00 = 9;
		} else {
			me.a00 = me.extrapolate(mach, 0.2, 0.6, 8, 22.5);
			me.g00 = me.extrapolate(mach, 0.2, 0.6, 1, 9);
		}
		if (mach>0.8) {#cft
			me.a10 = me.extrapolate(mach, 0.8, 1.3, 18, 12);
			me.g10 = 9;
		} else {
			me.a10 = me.extrapolate(mach, 0.2, 0.8, 6, 18);
			me.g10 = me.extrapolate(mach, 0.2, 0.8, 3, 9);
		}
		if (mach>1) {#cft
			me.a20 = me.extrapolate(mach, 1, 1.5, 16, 10);
			me.g20 = 9;
		} else {
			me.a20 = me.extrapolate(mach, 0, 1, 4, 16);
			me.g20 = me.extrapolate(mach, 0, 1, 3, 9);
		}
		if (mach>1.1) {#cft
			me.a30 = me.extrapolate(mach, 1.1, 1.7, 12.5, 9);
			me.g30 = 8;
		} else {
			me.a30 = me.extrapolate(mach, 0.5, 1.1, 6, 12.5);
			me.g30 = me.extrapolate(mach, 0.5, 1.1, 3, 8);
		}
		if (mach>1.1) {#cft
			me.a40 = me.extrapolate(mach, 1.1, 1.8, 8, 6);
			me.g40 = 5;
		} else {
			me.a40 = me.extrapolate(mach, 0.6, 1.1, 4, 8);
			me.g40 = me.extrapolate(mach, 0.6, 1.1, 3, 5);
		}
		if (altitude < 10000) {
			return [me.extrapolate(altitude,     0, 10000, me.a00, me.a10), me.extrapolate(altitude,     0, 10000, me.g00, me.g10)];
		} elsif (altitude < 20000) {
			return [me.extrapolate(altitude, 10000, 20000, me.a10, me.a20), me.extrapolate(altitude, 10000, 20000, me.g10, me.g20)];
		} elsif (altitude < 30000) {
			return [me.extrapolate(altitude, 20000, 30000, me.a20, me.a30), me.extrapolate(altitude, 20000, 30000, me.g20, me.g30)];
		} elsif (altitude < 40000) {
			return [me.extrapolate(altitude, 30000, 40000, me.a30, me.a40), me.extrapolate(altitude, 30000, 40000, me.g30, me.g40)];
		} else {
			return [me.a40,me.g40]
		}
	},

	accMax: func {
		# Max afterburner acceleration
		# mps / sec , drag index 50, 24000 lbm, f100-pw-229, no cft
		# taken from Greek F-16 block 52 supplemental manual.
		#
		# 00000:
		# 756/750 19 27  9  4 3 2 2 3 2 3 2 3 200
		#
		# 10000:
		# 775/750 50 20 10  8 5 4 4 3 4 3 4 4 200
		#
		# 20000
		# 757/750 39 46 17 12  9  8  7  5  6 6 6 7 200
		#
		#
		# 30000
		# 698/650 93 21 16 14 12 13 10 10 11 12 200
		#
		# 40000
		# 614/600 82 60 30 25 24 24 26 21 26 200
		me.kias = me.GStoKIAS(me.speed*MPS2KT);

		me.a00 = 0;
		if (me.kias > 750) {
			me.a00 = 158;#8.33 * 19
		} elsif (me.kias > 700) {
			me.a00 = 27;
		} elsif (me.kias > 650) {
			me.a00 = 9;
		} elsif (me.kias > 600) {
			me.a00 = 4;
		} elsif (me.kias > 550) {
			me.a00 = 3;
		} elsif (me.kias > 500) {
			me.a00 = 2;
		} elsif (me.kias > 450) {
			me.a00 = 2;
		} elsif (me.kias > 400) {
			me.a00 = 3;
		} elsif (me.kias > 350) {
			me.a00 = 2;
		} elsif (me.kias > 300) {
			me.a00 = 3;
		} elsif (me.kias > 250) {
			me.a00 = 2;
		} else {
			me.a00 = 3;
		}
		me.a00 = me.KIAStoGS(50)*KT2MPS/me.a00;

		me.a10 = 0;
		if (me.kias > 750) {
			me.a10 = 100;#50 * 2
		} elsif (me.kias > 700) {
			me.a10 = 20;
		} elsif (me.kias > 650) {
			me.a10 = 10;
		} elsif (me.kias > 600) {
			me.a10 = 8;
		} elsif (me.kias > 550) {
			me.a10 = 5;
		} elsif (me.kias > 500) {
			me.a10 = 4;
		} elsif (me.kias > 450) {
			me.a10 = 4;
		} elsif (me.kias > 400) {
			me.a10 = 3;
		} elsif (me.kias > 350) {
			me.a10 = 4;
		} elsif (me.kias > 300) {
			me.a10 = 3;
		} elsif (me.kias > 250) {
			me.a10 = 4;
		} else {
			me.a10 = 4;
		}
		me.a10 = me.KIAStoGS(50)*KT2MPS/me.a10;

		me.a20 = 0;
		if (me.kias > 750) {
			me.a20 = 279;#39*7.14
		} elsif (me.kias > 700) {
			me.a20 = 46;
		} elsif (me.kias > 650) {
			me.a20 = 17;
		} elsif (me.kias > 600) {
			me.a20 = 12;
		} elsif (me.kias > 550) {
			me.a20 = 9;
		} elsif (me.kias > 500) {
			me.a20 = 8;
		} elsif (me.kias > 450) {
			me.a20 = 7;
		} elsif (me.kias > 400) {
			me.a20 = 5;
		} elsif (me.kias > 350) {
			me.a20 = 6;
		} elsif (me.kias > 300) {
			me.a20 = 6;
		} elsif (me.kias > 250) {
			me.a20 = 6;
		} else {
			me.a20 = 7;
		}
		me.a20 = me.KIAStoGS(50)*KT2MPS/me.a20;

		me.a30 = 0;
		if (me.kias > 650) {
			me.a30 = 97;#93*1.04
		} elsif (me.kias > 600) {
			me.a30 = 21;
		} elsif (me.kias > 550) {
			me.a30 = 16;
		} elsif (me.kias > 500) {
			me.a30 = 14;
		} elsif (me.kias > 450) {
			me.a30 = 12;
		} elsif (me.kias > 400) {
			me.a30 = 13;
		} elsif (me.kias > 350) {
			me.a30 = 10;
		} elsif (me.kias > 300) {
			me.a30 = 10;
		} elsif (me.kias > 250) {
			me.a30 = 11;
		} else {
			me.a30 = 12;
		}
		me.a30 = me.KIAStoGS(50)*KT2MPS/me.a30;

		me.a40 = 0;
		if (me.kias > 600) {
			me.a40 = 293;#3.57*82
		} elsif (me.kias > 550) {
			me.a40 = 60;
		} elsif (me.kias > 500) {
			me.a40 = 30;
		} elsif (me.kias > 450) {
			me.a40 = 25;
		} elsif (me.kias > 400) {
			me.a40 = 24;
		} elsif (me.kias > 350) {
			me.a40 = 24;
		} elsif (me.kias > 300) {
			me.a40 = 26;
		} elsif (me.kias > 250) {
			me.a40 = 21;
		} else {
			me.a40 = 26;
		}
		me.a40 = me.KIAStoGS(50)*KT2MPS/me.a40;


		if (me.alt*M2FT > 30000) {
			return me.extrapolate(me.alt*M2FT, 30000, 40000, me.a30, me.a40);
		} elsif (me.alt*M2FT > 20000) {
			return me.extrapolate(me.alt*M2FT, 20000, 30000, me.a20, me.a30);
		} elsif (me.alt*M2FT > 10000) {
			return me.extrapolate(me.alt*M2FT, 10000, 20000, me.a10, me.a20);
		} else {
			return me.extrapolate(me.alt*M2FT,     0, 10000, me.a00, me.a10);
		}
	},

	deaccMax: func {
		# Idle engine deacceleration
		# mps / sec , drag index 50
		# taken from Greek F-16 block 52 supplemental manual.
		#
		# 20000:
		# 1.6M - 1.4M : 9s 1000-850 16.66 kt/sec
		# 1.4 - 1.2 : 12s   850-725 10.41
		# 1.2 - 1.0 : 12s   725-600 10.41
		# 1.0 - 0.8 : 30s   600-500  3.33
		# 0.8 - 0.6 : 48s   500-375  2.60

		# 30000:
		# 1.8M - 1.1M : 66s 1050-650  6.06
		# 1.1 - 0.8 : 78s    650-450  2.56

		# 40000:
		# 1.8M - 1.4M : 30s 1050-800  8.33
		# 1.4 - 1.0 : 60s    800-575  3.75
		# 1.0 - 0.8 : 60s    575-450  2.08

		me.a20 = 0;
		if (me.mach > 1.4) {
			me.a20 = 16.66*KT2MPS;
		} elsif (me.mach > 1.2) {
			me.a20 = 10.41*KT2MPS;
		} elsif (me.mach > 1.0) {
			me.a20 = 10.41*KT2MPS;
		} elsif (me.mach > 0.8) {
			me.a20 = 3.33*KT2MPS;
		} else {
			me.a20 = 2.60*KT2MPS;
		}
		me.a30 = 0;
		if (me.mach > 1.1) {
			me.a30 = 6.06*KT2MPS;
		} else {
			me.a30 = 2.56*KT2MPS;
		}
		me.a40 = 0;
		if (me.mach > 1.4) {
			me.a40 = 8.33*KT2MPS;
		} elsif (me.mach > 1.0) {
			me.a40 = 3.75*KT2MPS;
		} else {
			me.a40 = 2.08*KT2MPS;
		}
		if (me.alt*M2FT > 30000) {
			return me.extrapolate(me.alt*M2FT, 30000, 40000, me.a30, me.a40);
		} else {
			return me.extrapolate(me.alt*M2FT, 20000, 30000, me.a20, me.a30);
		}
	},

	KIAStoGS: func (kias) {
		return (0.02*(M2FT*me.alt*0.001)+1)*kias;
	},

	GStoKIAS: func (gs) {
		return gs/(0.02*(M2FT*me.alt*0.001)+1);
	},

	extrapolate: func (x, x1, x2, y1, y2) {
    	return y1 + ((x - x1) / (x2 - x1)) * (y2 - y1);
	},

	clamp: func(v, min, max) { v < min ? min : v > max ? max : v },
};

var lowpass = {
	new: func(coeff) {
		var m = { parents: [lowpass] };
		m.coeff = coeff >= 0 ? coeff : die("lowpass(): coefficient must be >= 0");
		m.value = nil;
		return m;
	},
	# filter(raw_value)    -> push new value, returns filtered value
	filter: func(v,dt) {
		me.filter = me._filter_;
		me.value = v;
	},
	# get()                -> returns filtered value
	get: func {
		me.value;
	},
	# set()                -> sets new average and returns it
	set: func(v) {
		me.value = v;
	},
	_filter_: func(v,dt) {
		var c = dt / (me.coeff + dt);
		me.value = v * c + me.value * (1 - c);
	},
};

var GO_STRAIGHT   = 0;
var GO_LEFT    = 1;
var GO_RIGHT   = 2;
var GO_UP      = 3;
var GO_DOWN    = 4;
var GO_IMMEL   = 5;
var GO_SPLIT_S = 6;
var GO_PURE_PURSUIT = 7;
var GO_SCISSOR = 8;
var GO_BREAK_UP = 9;
var GO_BREAK_DOWN = 10;
var GO_LEAD_PURSUIT = 11;
var GO_LAG_PURSUIT = 12;
var GO_LEAD_DEFEND_AWAY = 13;
var GO_LEAD_DEFEND_INTO = 14;#a16 does lead pursuit and has higher speed, turn aggressively into his lead in narrow turn.
var GO_COLLISION_AVOID = 15;
var GO_LOOP = 16;
var GO_FLOW_ONE_CIRCLE = 17;
var GO_FLOW_TWO_CIRCLE = 18;

var FLOOR = 10000;
var CEILING = 40000;
var UPDATE_RATE = 0.05;#was 0.025
var MAX_ROLL = 80;# visual only
var MAX_ROLL_SPEED =  25;#special
var MAX_ROLL_RATE  = 160;#real average roll rate
var MAX_PITCH_UP_SPEED = 15;
var MAX_PITCH_DOWN_SPEED = 4;
var MAX_DIVE_ANGLE = 45;
var MAX_TURN_SPEED = 22.5;#do not mess with this number unless porting the system to another aircraft.
var MAX_CANNON_RANGE = 1.0;#nm
var OPFOR_AIRCRAFT_TYPE = "Mig-28";
var BLUFOR_AIRCRAFT_TYPE = "F-16";

var num_t = "0000";
var ENDURANCE = 10;

var tg1 = TopGun.new();
var tg2 = TopGun.new();
var tg3 = TopGun.new();
var tg4 = TopGun.new();

var record = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];#0-20
var recordText = ["straight","left","right","up","down","immelmann","split-s","pure pursuit","flat scissors","break up", "break down","lead pursuit","lag pursuit","lead defend #1","lead defend #2","anti-collision","loop","flow one circle","flow two circles"];

var resetRecord = func {
	record = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];#0-20
}

var printRecord = func {
	print ();
	for (var i = 0;i<=GO_FLOW_TWO_CIRCLE;i+=1) {
		printf("%04d %s",record[i],recordText[i]);
	}
	print();
}

# Max 7 chars in each callsign:
var CS_0_friend = "Pump";
var CS_0_enemy  = "Slice";

var CS_1_enemy  = "Slice";

var CS_2_enemy  = "Steel";

var CS_3_enemy  = "Fuel";

var CS_4_enemy1 = "Guts";
var CS_4_enemy2 = "Steel";

var CS_5_enemy1 = "SWAT";
var CS_5_enemy2 = "Guts";

var CS_6_friend = "Bear";
var CS_6_enemy1 = "Rock";
var CS_6_enemy2 = "SWAT";
var CS_6_enemy3 = "Fuel";

var CS_7_enemy1 = "RED";
var CS_7_enemy2 = "SWAT";
var CS_7_friend1= "HAS";
var CS_7_friend2= "Bear";

var start = func (diff = 1) {
	if (diff < 0 or diff > 6.5) {
		print("TopGun: Difficulty goes from 1 (easy), 2 (normal), 3 (hard), 4 (veteran), 5 (master) to 6 (supreme), try again.");
		return;
	}
	if (tg1.enabled) {
		print("TopGun: Stop it before starting new.");
		screen.log.write("Scenario is already started, try 'stop' before starting again.", 1.0, 1.0, 0.0);
		return;
	}
	print("TopGun: Difficulty set to: "~diff);
	if (diff == 0) {
		# 1 enemy, 1 friendly
		MAX_ROLL_SPEED = 25;
		num_t = "0000";
		ENDURANCE = 10;
		tg1.callsign = CS_0_enemy;
		tg2.callsign = CS_0_friend;
		setprop("link16/wingman-4", CS_0_friend);
		tg1.start([nil,tg2]);
		tg2.start([tg1], 1);
		TopGun.runner = func {
			tg1.decide();
			tg2.decide();
			settimer(TopGun.runner, 0);
		};
		TopGun.runner();
	} elsif (diff == 1) {
		# 1 enemy
		MAX_ROLL_SPEED = 25;
		num_t = "0000";
		ENDURANCE = 10;
		tg1.callsign = CS_1_enemy;
		tg1.start();
		TopGun.runner = func {
			tg1.decide();
			settimer(TopGun.runner, 0);
		};
		TopGun.runner();
	} elsif (diff == 2) {
		# 1 enemy
		MAX_ROLL_SPEED = 25;
		num_t = "0000";
		ENDURANCE = 20;
		tg1.callsign = CS_2_enemy;
		tg1.start();
		TopGun.runner = func {
			tg1.decide();
			settimer(TopGun.runner, 0);
		};
		TopGun.runner();
	} elsif (diff == 3) {
		# 1 enemy, no transponder.
		MAX_ROLL_SPEED = 30;
		num_t = "-9999";
		ENDURANCE = 30;
		tg1.callsign = CS_3_enemy;
		tg1.start();
		TopGun.runner = func {
			tg1.decide();
			settimer(TopGun.runner, 0);
		};
		TopGun.runner();
	} elsif (diff == 4) {
		# 2 enemies
		MAX_ROLL_SPEED = 25;
		num_t = "0000";
		ENDURANCE = 10;
		tg1.callsign = CS_4_enemy1;
		tg2.callsign = CS_4_enemy2;
		tg1.start();
		tg2.start();
		TopGun.runner = func {
			tg1.decide();
			tg2.decide();
			settimer(TopGun.runner, 0);
		};
		TopGun.runner();
	} elsif (diff == 5) {
		# 2 enemies, no transponder.
		MAX_ROLL_SPEED = 30;
		num_t = "-9999";
		ENDURANCE = 15;
		tg1.callsign = CS_5_enemy1;
		tg2.callsign = CS_5_enemy2;
		tg1.start();
		tg2.start();
		TopGun.runner = func {
			tg1.decide();
			tg2.decide();
			settimer(TopGun.runner, 0);
		};
		TopGun.runner();
	} elsif (diff == 6) {
		# 3 enemies, 1 friendly, no transponder.
		MAX_ROLL_SPEED = 30;
		num_t = "-9999";
		ENDURANCE = 30;
		tg1.callsign = CS_6_enemy1;
		tg2.callsign = CS_6_friend;
		tg3.callsign = CS_6_enemy2;
		tg4.callsign = CS_6_enemy3;
		setprop("link16/wingman-4", CS_6_friend);
		tg1.start([nil,tg2]);
		tg2.start([tg1,tg3,tg4]);
		tg3.start([nil,tg2]);
		tg4.start([nil,tg2]);
		TopGun.runner = func {
			tg1.decide();
			tg2.decide();
			tg3.decide();
			tg4.decide();
			settimer(TopGun.runner, 0);
		};
		TopGun.runner();
	} elsif (diff == 6.5) {
		# 2 teams of 2, fight each other, ignore pilot, no transponder.
		MAX_ROLL_SPEED = 30;
		num_t = "-9999";
		ENDURANCE = 30;
		tg1.callsign = CS_7_enemy1;
		tg2.callsign = CS_7_friend1;
		tg3.callsign = CS_7_enemy2;
		tg4.callsign = CS_7_friend2;
		tg1.start([tg4,tg2],0);
		tg2.start([tg1,tg3],1);
		tg3.start([tg4,tg2],0);
		tg4.start([tg1,tg3],1);
		TopGun.runner = func {
			tg1.decide();
			tg2.decide();
			tg3.decide();
			tg4.decide();
			settimer(TopGun.runner, 0);
		};
		TopGun.runner();
	}
}

var stop = func {
	tg1.stop();
	tg2.stop();
	tg3.stop();
	tg4.stop();
	TopGun.runner = func {};
	setprop("link16/wingman-4", "");
}


# TODO:
#  make him switch on and off his radar in hard mode.
#  lower floor
#  make mig28 fire fox2/fox3
#  invert to level out after GO_UP
#  lag filter on the bearing/clock rates. nope is fixed.
#  land/take-off

var fix = 0.05;
var last = 0;

var test = func {
	e = systime();
	printf("fix %02.2f  real %02.2f  diff %02.2f",fix,e-last, (e-last)-fix);
	last = e;
	fix = rand()+0.05;
	settimer(test,fix);
}