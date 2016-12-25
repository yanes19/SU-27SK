# =======================
# Multiplayer Quirks
# =======================
# =======================
# Edited by Yanes
# =======================
var RadarStandby      = props.globals.getNode("instrumentation/radar/radar-standby");
var RadarEmitting    	= props.globals.getNode("su-27/instrumentation/N010-radar/emitting");
var RadarRange      = props.globals.getNode("instrumentation/radar/range");

MPjoin = func(n) {
   #print(n.getValue(), " added");
   setprop("instrumentation/radar",n.getValue(),"radar/y-shift",0);
   setprop("instrumentation/radar",n.getValue(),"radar/x-shift",0);
   setprop("instrumentation/radar",n.getValue(),"radar/rotation",0);
   setprop("instrumentation/radar",n.getValue(),"radar/in-range",0);
   setprop("instrumentation/radar",n.getValue(),"radar/h-offset",180);
   setprop("instrumentation/radar",n.getValue(),"joined",1);
}
MPleave= func(n) {
   #print(n.getValue(), " removed");
   setprop("instrumentation/radar",n.getValue(),"radar/in-range",0);
   setprop("instrumentation/radar",n.getValue(),"joined",0);
}
N010= func() {
   #print(" N010 invoked");
  var i = 0;
  var Emitting = RadarEmitting.getValue();
  if ( Emitting == 1 ) {
  targetList = props.globals.getNode("ai/models/").getChildren("Targets");#====> To create an empty list 
  foreach (d; props.globals.getNode("ai/models/").getChildren("aircraft")) {
				if (d.getNode("radar/in-range") != nil) # Ensure we dont access an empty node(a non object) .
				{
          if (d.getNode("radar/in-range").getValue()or 0 >0 and
							d.getNode("radar/h-offset").getValue() >-70 and
							d.getNode("radar/h-offset").getValue() < 70 and
							d.getNode("radar/v-offset").getValue() < 60 and
							d.getNode("radar/v-offset").getValue() >-60 )
         {
         append(targetList,d);
         #print (d.getNode("callsign").getValue());
         }
        }
      }
      
  foreach (d; props.globals.getNode("ai/models/").getChildren("multiplayer")) {
				if (d.getNode("radar/in-range") != nil) # Ensure we dont access an empty node .
				{
          if (d.getNode("radar/in-range").getValue()or 0 >0 and
							d.getNode("radar/h-offset").getValue() >-70 and
							d.getNode("radar/h-offset").getValue() < 70 and
							d.getNode("radar/v-offset").getValue() < 60 and
							d.getNode("radar/v-offset").getValue() >-60 )
         {
         append(targetList,d);
         #print (d.getNode("callsign").getValue());
         }
        }
      }
      
		foreach (m; targetList) {
			 var string = "instrumentation/radar/ai/models/"~"aircraft"~"["~m.getIndex()~"]/";
			 #print (string,"-------");
			 if (m.getName()=="aircraft"or m.getName()=="multiplayer") {
							i = i +1 ;
							#print (string);
	            factor = getprop("instrumentation/radar/range-factor"); ## if (factor == nil) { factor=0.001888};
	            setprop(string,"radar/y-shift",m.getNode("radar/y-shift").getValue() * factor);
	            setprop(string,"radar/x-shift",m.getNode("radar/x-shift").getValue() * factor);
	            setprop(string,"radar/rotation",m.getNode("radar/rotation").getValue());
	            setprop(string,"radar/h-offset",m.getNode("radar/h-offset").getValue());
	            setprop(string,"radar/v-offset",m.getNode("radar/v-offset").getValue());
	            setprop(string,"radar/elevation-deg",m.getNode("radar/elevation-deg").getValue());
						#Verify if in-range Horizontally :
	            if (getprop("instrumentation/radar/selected")==2){
	               if (getprop(string~"radar/x-shift") < -0.013 or 
	                   getprop(string~"radar/x-shift") > 0.013 or
	                   getprop(string~"radar/h-offset") > 70 or
	                   getprop(string~"radar/h-offset") < -70 or
	                   getprop(string~"radar/v-offset") > 60 or
	                   getprop(string~"radar/v-offset") < -60 ){
	                  setprop(string,"radar/in-range",0);
	               } else {
	                  setprop(string,"radar/in-range",m.getNode("radar/in-range").getValue());
	               }
	            } else {
	               setprop(string,"radar/in-range",m.getNode("radar/in-range").getValue());
	            }
			 } 
         
      }
  }
   settimer(N010,0.05);
}



# ===================
# Boresight Detecting
# ===================
locking=0;
found=-1;

boreSightLock = func {
   var Estado = RadarStandby.getValue();

   if ( Estado != 1 ) {

   if(getprop("instrumentation/radar/selected") == 1){

      targetList= props.globals.getNode("ai/models/").getChildren("multiplayer");
      foreach (d; props.globals.getNode("ai/models/").getChildren("aircraft")) {
         append(targetList,d);
      }

      foreach (m; targetList) {
          var string = "instrumentation/radar/ai/models/"~m.getName()~"["~m.getIndex()~"]";
          var string1 = "ai/models/"~m.getName()~"["~m.getIndex()~"]";
          if (getprop(string1~"radar/in-range")) {

            hOffset = getprop(string1~"radar/h-offset");
            vOffset = getprop(string1~"radar/v-offset");

            #really should be a cone, but is a square pyramid to avoid trigonemetry
            if(hOffset < 3 and hOffset > -3 and vOffset < 3 and vOffset > -3) {
               if (locking == 11){
                  setprop(string~"radar/boreLock",2);
                  setprop("instrumentation/radar/lock",2);
                  # setprop("sim[0]/hud/current-color",1);
                  locking -= 1;
               }
               elsif (locking ==1 or locking ==3 or locking ==5 or locking ==7 or locking ==9 ) {
                  setprop("instrumentation/radar/lock",1);
                  setprop(string1~"radar/boreLock",1);
               }
               else {
                  setprop("instrumentation/radar/lock",0);
                  setprop(string~"radar/boreLock",1);
               }

               if (found != m.getIndex()) {
                  found=m.getIndex();
                  locking=0;
               }
               else {
                  locking += 1;
               }
               settimer(boreSightLock, 0.2);
               return;
            }
         }
      }
      setprop(string~"radar/boreLock",0);
      locking=0;
      # setprop("sim[0]/hud/current-color",0);
   } # from getprop
   } # from Estado

   locking=0;
   # setprop("sim[0]/hud/current-color",0);
   found =-1;
   setprop("instrumentation/radar/lock",0);

   settimer(boreSightLock, 0.2);
}


setlistener("ai/models/model-added", MPjoin);
setlistener("ai/models/model-removed", MPleave);
setlistener("ai/models/model-added", N010);
var N010Loop = setlistener("ai/models/model-added", func() {
	N010();
  removelistener(N010Loop); # only call once
  });

#var init = setlistener("ai/models/model-added", func() {
#	MPradarProperties();
#  removelistener(init); # only call once
#  });
#settimer(MPradarProperties,0.5);
#settimer(boreSightLock, 0.5);

