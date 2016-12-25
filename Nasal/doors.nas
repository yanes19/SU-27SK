# =====
# Doors
# =====

Doors = {};

Doors.new = func {
   obj = { parents : [Doors],
           crew : aircraft.door.new("instrumentation/doors/crew", 8.0),
           passenger : aircraft.door.new("instrumentation/doors/passenger", 8.0),
           parachute : aircraft.door.new("instrumentation/doors/parachute", 1.0),
           wings : aircraft.door.new("instrumentation/doors/wings", 1.0)
         };
   return obj;
};

Doors.crewexport = func {
   me.crew.toggle();
}

Doors.passengerexport = func {
   me.passenger.toggle();
}

Doors.parachuteexport = func {
   me.parachute.toggle();
}

Doors.wingsexport = func {
   me.wings.toggle();
}

# ==============
# Initialization
# ==============

# objects must be here, otherwise local to init()
doorsystem = Doors.new();

