#### 		  	 su-27 electrical system    #### 
####  			 Yanes Bechir based on      ####
####				another model by Syd Adams. ####

###########TODO################
#** add support to battery 1&2 (currently only battery0 is supported).
#** cleanup the consumers list (currently contains unecessary and missing elements.
#** support power converters (alternators and airfield current are triphase 115/200 ac, passed to the converters(2 units)).
#**Implement the Power Channels for main and backup use as in the real aircraft .
######FURTHER REALISTIC#########
#** Implement consumers as objects and create each separately with a energy consumption (in Amperes) property.
#
##########TODO END#############
var ammeter_ave = 0.0;
var outPut = "systems/electrical/outputs/";
var BattVolts = props.globals.getNode("systems/electrical/batt-volts",1);
var Volts = props.globals.getNode("/systems/electrical/volts",1);
var Amps = props.globals.getNode("/systems/electrical/amps",1);
var EXT  = props.globals.getNode("/controls/electric/external-power",1); 
var switch_list=[];
var output_list=[];
var serv_list=[];
var servout_list=[];

strobe_switch = props.globals.getNode("controls/lighting/strobe", 1);

beacon_switch = props.globals.getNode("controls/lighting/beacon", 1);


#var battery = Battery.new(num,switch-prop,volts,amps,amp_hours,charge_percent,charge_amps);
Battery = {
    new : func(num,swtch,vlt,amp,hr,chp,cha){
    m = { parents : [Battery] };
            m.switch = props.globals.getNode(swtch,1);
            m.switch.setBoolValue(0);
            m.ideal_volts = vlt;
            m.ideal_amps = amp;
            m.amp_hours = hr;
            m.charge_percent = chp; 
            m.charge_amps = cha;
    return m;
    },
    apply_load : func(load,dt) {
        if(me.switch.getValue()){
        var amphrs_used = load * dt / 3600.0;
        var percent_used = amphrs_used / me.amp_hours;
        me.charge_percent -= percent_used;
        if ( me.charge_percent < 0.0 ) {
            me.charge_percent = 0.0;
        } elsif ( me.charge_percent > 1.0 ) {
        me.charge_percent = 1.0;
        }
        var output =me.amp_hours * me.charge_percent;
        return output;
        }else return 0;
    },

    get_output_volts : func {
        if(me.switch.getValue()){
            var x = 1.0 - me.charge_percent;
            var tmp = -(3.0 * x - 1.0);
            var factor = (tmp*tmp*tmp*tmp*tmp + 32) / 32;
            var output =me.ideal_volts * factor;
            return output;
        }else return 0;
    },

    get_output_amps : func {
        if(me.switch.getValue()){
            var x = 1.0 - me.charge_percent;
            var tmp = -(3.0 * x - 1.0);
            var factor = (tmp*tmp*tmp*tmp*tmp + 32) / 32;
            var output =me.ideal_amps * factor;
            return output;
        }else return 0;
    }
};

# var alternator = Alternator.new(num,switch,rpm_source,rpm_threshold,volts,amps);
Alternator = {
    new : func (num,switch,src,thr,vlt,amp){
        m = { parents : [Alternator] };
        m.switch =  props.globals.getNode(switch,1);
        m.switch.setBoolValue(1);
        m.meter =  props.globals.getNode("systems/electrical/gen-load["~num~"]",1);
        m.meter.setDoubleValue(0);
        m.gen_output =  props.globals.getNode("engines/engine["~num~"]/amp-v",1);
        m.gen_output.setDoubleValue(0);
        m.meter.setDoubleValue(0);
        m.rpm_source =  props.globals.getNode(src,1);
        m.rpm_threshold = thr;
        m.ideal_volts = vlt;
        m.ideal_amps = amp;
        return m;
    },

    apply_load : func(load) {
        var cur_volt=me.gen_output.getValue();
        var cur_amp=me.meter.getValue();
        if(cur_volt >1){
            var factor=1/cur_volt;
            gout = (load * factor);
            if(gout>1)gout=1;
        }else{
            gout=0;
        }
        if(cur_amp > gout)me.meter.setValue(cur_amp - 0.01);
        if(cur_amp < gout)me.meter.setValue(cur_amp + 0.01);
    },

    get_output_volts : func {
        var out = 0;
        if(me.switch.getBoolValue()){
            var factor = me.rpm_source.getValue() / me.rpm_threshold;
            if ( factor > 1.0 )factor = 1.0;
            var out = (me.ideal_volts * factor);
        }
        me.gen_output.setValue(out);
        return out;
    },

    get_output_amps : func {
        var ampout =0;
        if(me.switch.getBoolValue()){
            var factor = me.rpm_source.getValue() / me.rpm_threshold;
            if ( factor > 1.0 ) {
                factor = 1.0;
            }
            ampout = me.ideal_amps * factor;
        }
        return ampout;
    }
};

var battery = Battery.new(0,"/controls/electric/battery-switch",27,30,37,1.0,7.0);
var battery1 = Battery.new(1,"/controls/electric/battery1-switch",27,30,37,1.0,7.0);
var battery2 = Battery.new(2,"/controls/electric/battery2-switch",27,30,37,1.0,7.0);
#we pretend that AC/DC converter is directly included in alternators values until imlemented separately 
var alternator1 = Alternator.new(0,"controls/electric/engine[0]/generator","/engines/engine[0]/n1",15.1,28,60.0);
var alternator2 = Alternator.new(1,"controls/electric/engine[1]/generator","/engines/engine[1]/n1",15.1,28,60.0);

#####################################
setlistener("/sim/signals/fdm-initialized", func {
    BattVolts.setDoubleValue(0);
    init_switches();
    settimer(update_electrical,5);
    print("Electrical System ... ok");

});

init_switches = func() {
    var tprop=props.globals.getNode("controls/electric/ammeter-switch",1);
    tprop.setBoolValue(1);
    tprop=props.globals.getNode("controls/cabin/fan",1);
    tprop.setBoolValue(0);
    tprop=props.globals.getNode("controls/cabin/heat",1);
    tprop.setBoolValue(0);
    tprop=props.globals.getNode("controls/electric/external-power",1);
    tprop.setBoolValue(0);

    setprop("controls/lighting/instruments-norm",0.8);
    setprop("controls/lighting/engines-norm",0.8);
    setprop("controls/lighting/efis-norm",0.8);
    setprop("controls/lighting/panel-norm",0.8);

    append(switch_list,"controls/anti-ice/prop-heat");
    append(output_list,"prop-heat");
    append(switch_list,"controls/anti-ice/pitot-heat");
    append(output_list,"pitot-heat");
    append(switch_list,"controls/lighting/landing-lights");
    append(output_list,"landing-lights");
    append(switch_list,"controls/lighting/beacon-state/state");
    append(output_list,"beacon");
    append(switch_list,"controls/lighting/nav-lights");
    append(output_list,"nav-lights");
    append(switch_list,"controls/lighting/cabin-lights");
    append(output_list,"cabin-lights");
    append(switch_list,"controls/lighting/wing-lights");
    append(output_list,"wing-lights");
    append(switch_list,"controls/lighting/recog-lights");
    append(output_list,"recog-lights");
    append(switch_list,"controls/lighting/logo-lights");
    append(output_list,"logo-lights");
    append(switch_list,"controls/lighting/strobe-state/state");
    append(output_list,"strobe");
    append(switch_list,"controls/lighting/taxi-lights");
    append(output_list,"taxi-lights");

    append(serv_list,"instrumentation/adf/serviceable");
    append(servout_list,"adf");
    append(serv_list,"instrumentation/dme/serviceable");
    append(servout_list,"dme");
    append(serv_list,"instrumentation/gps/serviceable");
    append(servout_list,"gps");
    append(serv_list,"instrumentation/heading-indicator/serviceable");
    append(servout_list,"DG");
    append(serv_list,"instrumentation/transponder/inputs/serviceable");
    append(servout_list,"transponder");
    append(serv_list,"instrumentation/mk-viii/serviceable");
    append(servout_list,"mk-viii");
    append(serv_list,"instrumentation/tacan/serviceable");
    append(servout_list,"tacan");
    append(serv_list,"instrumentation/turn-indicator/serviceable");
    append(servout_list,"turn-coordinator");
    append(serv_list,"instrumentation/comm/serviceable");
    append(servout_list,"comm");
    append(serv_list,"instrumentation/comm[1]/serviceable");
    append(servout_list,"comm[1]");
    append(serv_list,"instrumentation/nav/serviceable");
    append(servout_list,"nav");
    append(serv_list,"instrumentation/nav[1]/serviceable");
    append(servout_list,"nav[1]");
#    Su-27SK specific systems
    append(serv_list,"controls/switches/PNK-10");
    append(servout_list,"PNK-10");
    append(serv_list,"controls/switches/ILS-31HUD");
    append(servout_list,"ILS-31HUD");
    append(serv_list,"controls/switches/OC-controller");
    append(servout_list,"OC-controller");
    append(serv_list,"controls/switches/WarnLeds");
    append(servout_list,"WarnLeds");
    append(serv_list,"controls/switches/IPV-MFD");
    append(servout_list,"IPV-MFD");

    for(var i=0; i<size(serv_list); i+=1) {
        var tmp = props.globals.getNode(serv_list[i],1);
        tmp.setBoolValue(1);
    }

    for(var i=0; i<size(switch_list); i+=1) {
        var tmp = props.globals.getNode(switch_list[i],1);
        tmp.setBoolValue(0);
    }
}

update_virtual_bus = func( dt ) {
    var PWR = getprop("systems/electrical/serviceable");
    var battery_volts = battery.get_output_volts();
    BattVolts.setValue(battery_volts);
    var alternator1_volts = alternator1.get_output_volts();
    var alternator2_volts = alternator2.get_output_volts();
    var external_volts = 24.0;

    load = 0.0;
    bus_volts = 0.0;
    power_source = nil;
        
        bus_volts = battery_volts;
        power_source = "battery";

    if (alternator1_volts > bus_volts) {
        bus_volts = alternator1_volts;
        power_source = "alternator1";
        }

    if (alternator2_volts > bus_volts) {
        bus_volts = alternator2_volts;
        power_source = "alternator2";
        }
    if ( EXT.getBoolValue() and ( external_volts > bus_volts) ) {
        bus_volts = external_volts;
        }

    bus_volts *=PWR;

    load += electrical_bus(bus_volts);
    load += avionics_bus(bus_volts);

    ammeter = 0.0;
#    if ( bus_volts > 1.0 )load += 15.0;

    if ( power_source == "battery" ) {
        ammeter = -load;
        } else {
        ammeter = battery.charge_amps;
    }

    if ( power_source == "battery" ) {
        battery.apply_load( load, dt );
        } elsif ( bus_volts > battery_volts ) {
        battery.apply_load( -battery.charge_amps, dt );
        }

    ammeter_ave = 0.8 * ammeter_ave + 0.2 * ammeter;

   Amps.setValue(ammeter_ave);
   Volts.setValue(bus_volts);
    alternator1.apply_load(load);
    alternator2.apply_load(load);

return load;
}

electrical_bus = func(bv) {
    var bus_volts = bv;
    var load = 0.0;
    var srvc = 0.0;
    var starter_volts = 0.0;

    var starter_switch = getprop("controls/engines/engine[0]/starter");
    var starter_switch1 = getprop("controls/engines/engine[1]/starter"); 

    starter_volts = bus_volts * starter_switch;
    load += starter_switch *5;
    starter_volts = bus_volts * starter_switch1;
    load += starter_switch *5;

    setprop(outPut~"starter",starter_volts); 

    for(var i=0; i<size(switch_list); i+=1) {
        var srvc = getprop(switch_list[i]);
        load +=srvc;
        setprop(outPut~output_list[i],bus_volts * srvc);
    }
    setprop(outPut~"flaps",bus_volts);

    return load;
}

#### used in Instruments/source code 
# adf : dme : encoder : gps : DG : transponder  
# mk-viii : MRG : tacan : turn-coordinator
# nav[0] : nav [1] : comm[0] : comm[1]
####

avionics_bus = func(bv) {
    var bus_volts = bv;
    var load = 0.0;
    var srvc = 0.0;
INSTR_DIMMER = getprop("controls/lighting/instruments-norm");
#EFIS_DIMMER = getprop("controls/lighting/efis-norm");
#ENG_DIMMER = getprop("controls/lighting/engines-norm");
#PANEL_DIMMER = getprop("controls/lighting/panel-norm");
var dim =
setprop(outPut~"instrument-lights",(bus_volts * INSTR_DIMMER));
setprop(outPut~"instrument-lights-norm",(0.0357 * (bus_volts * INSTR_DIMMER)));
#setprop(outPut~"eng-lights",(bus_volts * ENG_DIMMER));
#setprop(outPut~"panel-lights",(bus_volts * PANEL_DIMMER));

    for(var i=0; i<size(serv_list); i+=1) {
        var srvc = getprop(serv_list[i]);
        load +=srvc;
        setprop(outPut~servout_list[i],bus_volts * srvc);
    }

    return load;
}

update_electrical = func {
    var scnd = getprop("sim/time/delta-sec");
    update_virtual_bus( scnd );
settimer(update_electrical, 0);
}
