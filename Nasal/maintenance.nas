
# Maintenance.nas

    print("Loading Maintenance");

    var rm_root = "sim/maintenance";
	
	var airframe_load_speed = 100; # Speed in Kt at which airframe is under load, i.e. (simply) rotate speed
	
	var airframe_seconds = aircraft.timer.new(rm_root~"/airframe-seconds", 60, 0);
	var engine0_seconds = aircraft.timer.new(rm_root~"/engine[0]/operating-seconds", 60, 0);
	var engine1_seconds = aircraft.timer.new(rm_root~"/engine[1]/operating-seconds", 60, 0);
	
	var rm_loop = func {
		 airframe_load();    
		 airframe_hours();
		 engine_hours();
		}	     
		
	var init = func {
	     #props.globals.initNode(rm_root~"/maintenance-enabled",0,"BOOL");
	     foreach (a; props.globals.getNode("engines").getChildren()) {
		     var index = a.getIndex();
			 props.globals.getNode(rm_root~"/engine["~index~"]/operating-seconds",1).setValue(0);
			 
			};
		}
		
    var engine_hours = func {
         foreach ( var e ; props.globals.getNode(rm_root).getChildren("engine") ) {
		     var i = e.getIndex();
			}			 
	}	

	var airframe_hours = func {
		 var afh_prop = props.globals.getNode(rm_root~"/airframe-seconds",1);
		 var speedup = props.globals.getNode("sim/speed-up").getValue();
		 var hrs =  ( ( afh_prop.getValue() / 3600 ) * speedup );
         var hrs_f = sprintf("%5.2f",hrs);
         props.globals.getNode(rm_root~"/airframe-hours",1).setValue(hrs);
		}	
	
	var airframe_load = func {
	     if ( props.globals.getNode("velocities/airspeed-kt").getValue() > airframe_load_speed ) {
		     airframe_seconds.start();
			}
		 else {
		     airframe_seconds.stop();
			}
		}
		
	var report = func {
	     var rep = {};
		 rep.afhours = "Airframe Hours: "~sprintf("%5.1f",getprop(rm_root~"/airframe-hours"));
		 var out = rep.afhours;
		 return out;
		}
		
	
