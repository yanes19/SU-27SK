#print("LOADING radar2.nas .");
################################################################################
#
#           Customized version of radar2 for the Su-27SK
#
################################################################################

# Radar
# Fabien BARBIER (5H1N0B1) September 2015
# fitted to the Su-27SK by Yanes Bechir 2016
# inspired by Alexis Bory (xiii)

var UPDATE_PERIOD = 0.1; # update interval for engine init() functions

var ElapsedSec        = props.globals.getNode("sim/time/elapsed-sec");
var DisplayRdr        = props.globals.getNode("instrumentation/radar/display-rdr");
var AzField           = props.globals.getNode("instrumentation/radar/az-field");
var RangeSelected     = props.globals.getNode("instrumentation/radar/range-selected");
var RadarStandby      = props.globals.getNode("instrumentation/radar/radar-standby");
var RadarStandbyMP    = props.globals.getNode("sim/multiplay/generic/int[2]");
var SwpMarker         = props.globals.getNode("instrumentation/radar2/sweep-marker-norm", 1);
var SwpDisplayWidth   = props.globals.getNode("instrumentation/radar2/sweep-width-m");
var RngDisplayWidth   = props.globals.getNode("instrumentation/radar2/range-width-m");
var PpiDisplayRadius  = props.globals.getNode("instrumentation/radar2/radius-ppi-display-m");
var HudEyeDist        = props.globals.getNode("instrumentation/radar2/hud-eye-dist-m");
var HudRadius         = props.globals.getNode("instrumentation/radar2/hud-radius-m");
var HudVoffset        = props.globals.getNode("instrumentation/radar2/hud-vertical-offset-m", 1);
var HudTgtHDisplay    = props.globals.getNode("instrumentation/radar2/hud/target-display", 1);
var HudTgt            = props.globals.getNode("instrumentation/radar2/hud/target", 1);
var HudTgtTDev        = props.globals.getNode("instrumentation/radar2/hud/target-total-deviation", 1);
var HudTgtTDeg        = props.globals.getNode("instrumentation/radar2/hud/target-total-angle", 1);
var HudTgtClosureRate = props.globals.getNode("instrumentation/radar2/hud/closure-rate", 1);
var OurAlt            = props.globals.getNode("position/altitude-ft");
var OurHdg            = props.globals.getNode("orientation/heading-deg");
var OurRoll           = props.globals.getNode("orientation/roll-deg");
var OurPitch          = props.globals.getNode("orientation/pitch-deg");
var EcmOn             = props.globals.getNode("instrumentation/ecm/on-off", 1);
var EcmAlert1         = props.globals.getNode("instrumentation/ecm/alert-type1", 1);
var EcmAlert2         = props.globals.getNode("instrumentation/ecm/alert-type2", 1);

var az_fld            = AzField.getValue();
var l_az_fld          = 0;
var r_az_fld          = 0;
var swp_marker        = nil; # scan azimuth deviation, normalized(-1 --> 1).
var swp_deg           = nil; # scan azimuth deviation, in degree.
var swp_deg_last      = 0; # used to get sweep direction.
var swp_spd           = 1.7;
var swp_dir           = nil; # sweep direction, 0 to left, 1 to right.
var swp_dir_last      = 0;
var swp_diplay_width  = SwpDisplayWidth.getValue();  # length of the max azimuth  range on the screen.
                                                     # used for the B-scan display and sweep markers.
var rng_diplay_width  = SwpDisplayWidth.getValue();  # length of the max range vertical width on the
                                                     # screen. used for the B-scan display.
var ppi_diplay_radius = PpiDisplayRadius.getValue(); # length of the radial size
# of the PPI like display.
var hud_eye_dist      = HudEyeDist.getValue() ; # distance eye <-> HUD plane.
var hud_radius        = HudRadius.getValue() ; # used to clamp the nearest target marker.
var hud_voffset       = 0 ; # used to verticaly offset the clamp border.

var wcs_mode          = "rws" ; # FIXME should handled as properties choice, not harcoded.
var tmp_nearest_rng   = nil;
var tmp_nearest_u     = nil;
var nearest_rng       = 0;
var nearest_u         = nil;

var our_true_heading  = 0;
var our_alt           = 0;

var Mp = props.globals.getNode("ai/models");
var tgts_list         = [];
var Target_Index      = 0 ; # for Target Selection
var cnt               = 0 ; # counter used for the scan sweep pattern
var cnt_hud           = 0 ; # counter used for the HUD update

# ECM warnings.
var ecm_alert1        = 0;
var ecm_alert2        = 0;
var ecm_alert1_last   = 0;
var ecm_alert2_last   = 0;
var u_ecm_signal      = 0;
var u_ecm_signal_norm = 0;
var u_radar_standby   = 0;
var u_ecm_type_num    = 0;

# global Range
var rangeTab = [];
var rangeIndex = 0;

# radar class
var Radar = {
    new: func(){
        var m = { parents : [Radar]};
        m.loop_running  = 0;
        m.rangeTab      = [10, 20, 40, 60, 160]; # radar Ranges in nm
        m.rangeIndex    = 1; # tab starts at index 1 so here it's 20
        m.RangeSelected = props.globals.getNode("instrumentation/radar/range-selected", 1);
        m.MyCoord       = geo.aircraft_position(); # this is when the radar is on our own aircraft. This part have to change if we want to put the radar on a missile/AI
        m.radarHeading  = 0;                       # in this we fix the radar position in the nose. We will change it to make rear radar or RWR etc
        m.az_fld        = props.globals.getNode("instrumentation/radar/az-field", 1);
        m.vt_az_fld     = m.az_fld;
        m.fieldazCenter = props.globals.getNode("instrumentation/radar/az-fieldCenter", 1);
        m.fieldazCenter.setDoubleValue(0);
        
        m.OurHdg        = props.globals.getNode("orientation/heading-deg");
        m.OurRoll       = props.globals.getNode("orientation/roll-deg");
        m.OurPitch      = props.globals.getNode("orientation/pitch-deg");
        m.our_alt       = props.globals.getNode("position/altitude-ft");
        m.ourNorthSpeed = props.globals.getNode("velocities/speed-north-fps");
        m.ourEastSpeed  = props.globals.getNode("velocities/speed-east-fps");
        m.ourDownSpeed  = props.globals.getNode("velocities/speed-down-fps");
        
        m.HaveDoppler       = 1;
        m.DopplerSpeedLimit = 50; # in Knot
        m.MyTimeLimit       = 2; # in seconds
        
        m.Check_List  = [];
        m.janitorTime = 5;
        
        # sweep :
        m.SwpMarker         = props.globals.getNode("instrumentation/radar2/sweep-marker-norm", 1);
        m.sweep_frequency   = m.MyTimeLimit / 4; # in seconds
        m.haveSweep         = 1;
        
        # option
        m.showAI =1;
        # return our new object
        #screen.log.write("Radar created.");
        return m;
    },

    ############### LOOP MANAGEMENT ##################
    # creates an engine update loop (optional)
    ##################################################
    init: func(){
        if(me.loop_running)
        {
            return;
        }
        me.loop_running = 1;
        
        # init Radar Distance
        rangeTab = me.rangeTab;
        rangeIndex = me.rangeIndex;
        me.RangeSelected.setValue(rangeTab[rangeIndex]);
        
        # launch only On time : this is an auto updated loop.
        me.maj_sweep();
        
        var loop_Update = func(){
            var radarWorking = #getprop("/systems/electrical/outputs/radar");
            27;
            radarWorking = (radarWorking == nil) ? 0 : radarWorking;
            if(radarWorking > 21)
            {
                #screen.log.write("loop");
                me.update();
            }else{
                #screen.log.write("radar isn't running!");
            }
            me.janitor();
            settimer(loop_Update, UPDATE_PERIOD);
        };
        settimer(loop_Update, 0);
        
        var loop_Sweep = func(){
            me.maj_sweep();
            settimer(loop_Sweep, 0);
        };
        settimer(loop_Sweep, 0);
        #screen.log.write("radar inited.");
        #settimer(loop, 0);
    },

    ############
    #  UPDATE  #
    ############
    update: func(){
        me.MyCoord = geo.aircraft_position();
        
        #screen.log.write("updating");
        var raw_list = Mp.getChildren();
        foreach(var c ; raw_list)
        {
            # FIXME: At that time a multiplayer node may have been deleted while still
            # existing as a displayable target in the radar targets nodes.
            # FIXED, with janitor. 5H1N0B1
            var type = c.getName();
            if(! c.getNode("valid", 1).getValue())
            {
                continue;
            }
            
            # the 2 following line are needed : If not, it would detects our own missiles...
            # this will come soon
            var HaveRadarNode = c.getNode("radar");
            if(type == "multiplayer"
                or (type == "tanker" and HaveRadarNode != nil)
                or (type == "aircraft" and me.showAI == 1)
                or type == "carrier"
                or type == "ship"
                or (type == "missile" and HaveRadarNode != nil)
                or type == "Mig-28")
            {
                # creation of the tempo object Target
                var u = Target.new(c);
                #screen.log.write("New target detected.",255,255,0);
                
                #print("Testing "~ u.get_Callsign()~"Type: " ~ type);
                
                # set Check_List to void
                me.Check_List = [];
                # this function do all the checks and put all result of each
                # test on an array[] named Check_List
                me.go_check(u);
                
                # then a function just check it all
                if(me.get_check(u))
                {
                    #screen.log.write("checked!");
                    var HaveRadarNode = c.getNode("radar");
                    var u_rng = me.targetRange(u);
                    

        
                    var beardeg = me.targetBearing(u) - me.OurHdg.getValue();
                    #screen.log.write(beardeg);
                    if(beardeg < -180)beardeg = beardeg + 180;
                    if(beardeg > 180)beardeg = beardeg - 180;
                    #screen.log.write(sprintf("%.2f  %.2f",beardeg,me.targetBearing(u)));
                    var altdist = (u.get_altitude() - me.our_alt.getValue()) * 0.3048;
                    var hdist = math.sqrt((u_rng * u_rng * NM2M * NM2M) - (altdist * altdist));
                    var vtgt_x = math.sin(beardeg*D2R) * hdist;
                    var vtgt_y = math.cos(beardeg*D2R) * hdist;
                    var vtgt_z = altdist;
                    #screen.log.write(sprintf("%.2f, %.2f, %.2f",altdist,hdist,beardeg));
                    var ourd_x = 0;
                    var ourd_y = math.cos(me.OurPitch.getValue()*D2R);
                    var ourd_z = math.sin(me.OurPitch.getValue()*D2R);
                    var ourd_l = ourd_y * vtgt_y + ourd_z * vtgt_z;
                    ourd_y = ourd_y * ourd_l;
                    ourd_z = ourd_z * ourd_l;
                    var o_x = vtgt_x - ourd_x;
                    var o_y = vtgt_y - ourd_y;
                    var o_z = vtgt_z - ourd_z;
                    var h_dt = o_x;
                    var v_dt = math.sqrt(o_y * o_y + o_z * o_z);
                    if(o_z < 0)v_dt = -1 * v_dt;
                    h_dt = h_dt * (HudEyeDist.getValue() / ourd_l) * 52;
                    v_dt = v_dt * (HudEyeDist.getValue() / ourd_l) * 52;
                    #v_ang = math.arccos();
                    
                    u.HOffset = h_dt;
                    u.VOffset = v_dt;

                    var x_dt = (vtgt_x * M2NM * 0.068) / (me.RangeSelected.getValue());
                    var y_dt = (vtgt_y * M2NM * 0.068) / (me.RangeSelected.getValue());
                    #screen.log.write(sprintf("%.5f  %.5f  %.2f  %.2f",x_dt,y_dt,vtgt_x,vtgt_y));
                    var rtcenter_x = x_dt + 0.068 * math.sin((u.Heading.getValue() - me.OurHdg.getValue())*D2R);
                    var rtcenter_y = y_dt + 0.068 * math.cos((u.Heading.getValue() - me.OurHdg.getValue())*D2R);
                    var brx = rtcenter_x;
                    var bry = rtcenter_y - 0.068;
                    u.XShift = brx;
                    u.YShift = bry;
                    u.Rotation = u.Heading.getValue() - me.OurHdg.getValue();
                    

                    
                    u.create_tree(me.MyCoord);
                    u.set_all(me.MyCoord);
                    me.calculateScreen(u);
                    # for Target Selection
                    # here we disable the capacity of targeting a missile. But 's possible.
                    if(type != "missile")
                    {
                        me.TargetList_AddingTarget(u);
                    }
                    if(me.az_fld.getValue() == 60)
                    {
                        # change to Make it more dynamic
                        me.displayTarget();
                    }
                }
                else
                {
                    if(u.get_Validity() == 1)
                    {
                        if(getprop("sim/time/elapsed-sec") - u.get_TimeLast() > me.MyTimeLimit)
                        {
                            # call Janitor
                            u.set_nill();
                            me.TargetList_RemovingTarget(u);
                        }
                    }
                }
            }
        }
    },

    calculateScreen: func(SelectedObject){
        # swp_diplay_width = Global
        # az_fld = Global
        # ppi_diplay_radius = Global
        var u_rng=me.targetRange(SelectedObject);
        
        SelectedObject.check_carrier_type();
        mydeviation = SelectedObject.get_deviation(me.OurHdg.getValue(), me.MyCoord);
        
        
        # compute mp position in our B-scan like display. (Bearing/horizontal + Range/Vertical).
        SelectedObject.set_relative_bearing(swp_diplay_width / az_fld * mydeviation);
        var factor_range_radar = rng_diplay_width / me.RangeSelected.getValue(); # length of the distance range on the B-scan screen.
        SelectedObject.set_ddd_draw_range_nm(factor_range_radar * u_rng);
        u_fading = 1;
        u_display = 1;
        
        # Compute mp position in our PPI like display.
        factor_range_radar = ppi_diplay_radius / me.RangeSelected.getValue(); # Length of the radius range on the PPI like screen.
        SelectedObject.set_tid_draw_range_nm(factor_range_radar * u_rng);
        
        # Compute first digit of mp altitude rounded to nearest thousand. (labels).
        SelectedObject.set_rounded_alt(rounding1000(SelectedObject.get_altitude()) / 1000);
        
        # Compute closure rate in Kts.
        #SelectedObject.get_closure_rate_from_Coord(me.MyCoord) * MPS2KT;
        
        # Check if u = nearest echo.
        if(SelectedObject.get_Callsign() == getprop("/ai/closest/callsign"))
        {
            #print(u.get_Callsign());
            tmp_nearest_u = SelectedObject;
            tmp_nearest_rng = u_rng;
        }
        SelectedObject.set_display(u_display);
        SelectedObject.set_fading(u_fading);
    },

    isNotBehindTerrain: func(SelectedObject){
        isVisible = 0;
        
        # As the script is relatively ressource consuming, then, we do a maximum of test before doing it
        if(me.get_check(SelectedObject))
        {
            SelectCoord = SelectedObject.get_Coord();
            # Because there is no terrain on earth that can be between these 2
            if(me.our_alt.getValue() < 8900 and SelectCoord.alt() < 8900)
            {
                # Temporary variable
                # A (our plane) coord in meters
                a = me.MyCoord.x();
                b = me.MyCoord.y();
                c = me.MyCoord.z();
                # B (target) coord in meters
                d = SelectCoord.x();
                e = SelectCoord.y();
                f = SelectCoord.z();
                x = 0;
                y = 0;
                z = 0;
                RecalculatedL = 0;
                difa = d - a;
                difb = e - b;
                difc = f - c;
                # direct Distance in meters
                myDistance = SelectCoord.direct_distance_to(me.MyCoord);
                Aprime = geo.Coord.new();
                
                # Here is to limit FPS drop on very long distance
                L = 500;
                if(myDistance > 50000)
                {
                    L = myDistance / 15;
                }
                step = L;
                maxLoops = int(myDistance / L);
                
                isVisible = 1;
                # This loop will make travel a point between us and the target and check if there is terrain
                for(var i = 0 ; i < maxLoops ; i += 1)
                {
                    L = i * step;
                    K = (L * L) / (1 + (-1 / difa) * (-1 / difa) * (difb * difb + difc * difc));
                    DELTA = (-2 * a) * (-2 * a) - 4 * (a * a - K);
                    
                    if(DELTA >= 0)
                    {
                        # So 2 solutions or 0 (1 if DELTA = 0 but that 's just 2 solution in 1)
                        x1 = (-(-2 * a) + math.sqrt(DELTA)) / 2;
                        x2 = (-(-2 * a) - math.sqrt(DELTA)) / 2;
                        # So 2 y points here
                        y1 = b + (x1 - a) * (difb) / (difa);
                        y2 = b + (x2 - a) * (difb) / (difa);
                        # So 2 z points here
                        z1 = c + (x1 - a) * (difc) / (difa);
                        z2 = c + (x2 - a) * (difc) / (difa);
                        # Creation Of 2 points
                        Aprime1  = geo.Coord.new();
                        Aprime1.set_xyz(x1, y1, z1);
                        
                        Aprime2  = geo.Coord.new();
                        Aprime2.set_xyz(x2, y2, z2);
                        
                        # Here is where we choose the good
                        if(math.round((myDistance - L), 2) == math.round(Aprime1.direct_distance_to(SelectCoord), 2))
                        {
                            Aprime.set_xyz(x1, y1, z1);
                        }
                        else
                        {
                            Aprime.set_xyz(x2, y2, z2);
                        }
                        AprimeLat = Aprime.lat();
                        Aprimelon = Aprime.lon();
                        AprimeTerrainAlt = geo.elevation(AprimeLat, Aprimelon);
                        if(AprimeTerrainAlt == nil)
                        {
                            AprimeTerrainAlt = 0;
                        }
                        
                        if(AprimeTerrainAlt > Aprime.alt())
                        {
                            isVisible = 0;
                        }
                    }
                }
            }
            else
            {
                isVisible = 1;
            }
        }
        return isVisible;
    },

    NotBeyondHorizon: func(SelectedObject){
        # if distance is beyond the earth curve
        var horizon = SelectedObject.get_horizon(me.our_alt.getValue());
        var u_rng = me.targetRange(SelectedObject);
        #print("u_rng : " ~ u_rng ~ ", Horizon : " ~ horizon);
        var InHorizon = (u_rng < horizon);
        return InHorizon;
    },

    doppler: func(SelectedObject){
        # Test to check if the target can hide bellow us
        # Or Hide using anti doppler movements
        
        var InDoppler = 0;
        var groundNotbehind = me.isGroundNotBehind(SelectedObject);
        if(groundNotbehind)
        {
            InDoppler = 1;
        }
        if(me.HaveDoppler and (abs(SelectedObject.get_closure_rate_from_Coord(me.MyCoord)) > me.DopplerSpeedLimit))
        {
            InDoppler = 1;
        }
        if(SelectedObject.get_Callsign() == "GROUND_TARGET" or SelectedObject.check_carrier_type())
        {
            InDoppler = 1;
        }
        return InDoppler;
    },

    isGroundNotBehind: func(SelectedObject){
        var myPitch = SelectedObject.get_Elevation_from_Coord(me.MyCoord);
        var GroundNotBehind = 1; # sky is behind the target (this don't work on a valley)
        if(myPitch < 0 and me.NotBeyondHorizon(SelectedObject))
        {
            # the aircraft is bellow us, the ground could be bellow
            # Based on earth curve. Do not work with mountains
            # The script will calculate what is the ground distance for the line (us-target) to reach the ground,
            # If the earth was flat. Then the script will compare this distance to the horizon distance
            # If our distance is greater than horizon, then sky behind
            # If not, we cannot see the target unless we have a doppler radar
            var distHorizon = me.MyCoord.alt() / math.tan(abs(myPitch * D2R)) * M2NM;
            var horizon = SelectedObject.get_horizon( me.our_alt.getValue());
            var TempBool = (distHorizon > horizon);
            GroundNotBehind = (distHorizon > horizon);
        }
        return GroundNotBehind;
    },

    inAzimuth: func(SelectedObject){
        # Check if it's in Azimuth.
        # first we check our heading+ center az deviation + the sweep if the radar is mechanical
        tempAz = me.az_fld.getValue();
        var inMyAzimuth = 0;
        
        var myHeading = math.mod(me.fieldazCenter.getValue() + me.OurHdg.getValue(), 360);
        if(me.haveSweep)
        {
            myHeading = math.mod(myHeading + me.SwpMarker.getValue() * (0.0844 / swp_diplay_width) * tempAz / 4, 360);
            mydeviation = SelectedObject.get_deviation(myHeading, me.MyCoord);
            #print("Heading:"~ myHeading ~" My deviation:"~ mydeviation);
            inMyAzimuth = (abs(mydeviation) < (tempAz / 4));
        }
        else
        {
            mydeviation = SelectedObject.get_deviation(myHeading, me.MyCoord);
            inMyAzimuth = (abs(mydeviation)<(tempAz/2));
        }
        return inMyAzimuth;
    },

    inElevation: func(SelectedObject){
        # Moving the center of this field will be ne next option
        var tempAz = me.vt_az_fld.getValue();
        var myElevation = SelectedObject.get_total_elevation_from_Coord(me.OurPitch.getValue(), me.MyCoord);
        var IsInElevation = (abs(myElevation) < (tempAz / 2));
        return IsInElevation;
    },

    InRange: func(SelectedObject){
        # Check if it's in range
        IsInRange = 0;
        var myRange = me.targetRange(SelectedObject);
        if(myRange != 0)
        {
            #print(SelectedObject.get_Callsign() ~": Range (NM) : " ~myRange);
            IsInRange = ( myRange <= me.RangeSelected.getValue());
        }
        return IsInRange;
    },

    heat_sensor: func(SelectedObject){
        myEngineTree = SelectedObject.get_engineTree();
        # If MP or AI has an engine tree, we will check for each engine n1>30 or rpm>1000
        if(myEngineTree != nil)
        {
            var engineList = myEngineTree.getChildren();
            foreach(var currentEngine ; engineList)
            {
                var HaveN1node = currentEngine.getNode("n1");
                var HaveRPMnode = currentEngine.getNode("rpm");
                if(HaveN1node != nil)
                {
                    n1value = HaveN1node.getValue();
                    if(n1value != nil and n1value > 30)
                    {
                        #print("N1 detected");
                        return 1;
                    }
                }
                if(HaveRPMnode != nil)
                {
                    RpMvalue = HaveRPMnode.getValue();
                    if(RpMvalue != nil and RpMvalue > 1000)
                    {
                        #print("RPM detected");
                        return 1;
                    }
                }
            }
        }
        # Here we could add a velocity test : if speed >mach 1, we can imagine that friction provides heat
    },

    maj_sweep:func(){
        var x = (getprop("sim/time/elapsed-sec") / (me.sweep_frequency)) * (0.0844 / swp_diplay_width); # shorten the period time when illuminating a target
        #print("SINUS (X) = "~math.sin(x);
        me.SwpMarker.setValue(math.sin(3.14 * x) * (swp_diplay_width / 0.0844)); # shorten the period amplitude when illuminating
    },

    targetRange: func(SelectedObject){
        # This is a way to shortcurt the issue that some of node have : in-range =0
        # So by giving the second fucntion our coord, we just have to calculate it
        var myRange = 0;
        #myRange = SelectedObject.get_range();
        if(myRange == 0)
        {
            myRange = SelectedObject.get_range_from_Coord(me.MyCoord);
        }
        return myRange;
    },

    targetBearing: func(SelectedObject){
        # This is a way to shortcurt the issue that some of node have : bearing =0
        # So by giving the second fucntion our coord, we just have to calculate it
        var myBearing = 0;
        myBearing = SelectedObject.get_bearing();
        if(myBearing == 0)
        {
            myBearing = SelectedObject.get_bearing_from_Coord(me.MyCoord);
        }
        return myBearing;
    },

    TargetList_AddingTarget: func(SelectedObject){
        # This is selectioned target management.
        if(me.TargetList_LookingForATarget(SelectedObject) == 0)
        {
            append(tgts_list, SelectedObject);
        }
    },

    TargetList_RemovingTarget: func(SelectedObject){
        # This is selectioned target management.
        if(me.TargetList_LookingForATarget(SelectedObject) > 5)
        {
            # Then kill it
            var TempoTgts_list = [];
            foreach(var TempTarget ; tgts_list)
            {
                if(TempTarget.get_shortring() != SelectedObject.get_shortring())
                {
                    append(TempoTgts_list, TempTarget);
                }
            }
            tgts_list = TempoTgts_list;
        }
    },

    TargetList_LookingForATarget: func(SelectedObject){
        # This is selectioned target management.
        # Target list janitor
        foreach(var TempTarget ; tgts_list)
        {
            if(TempTarget.get_shortring() == SelectedObject.get_shortring())
            {
                return TempTarget.get_TimeLast();
            }
        }
        return 0;
    },

    get_check: func(){
        # This function allow to display multi check
        var checked = 1;
        #var CheckTable = ["InRange:", "inAzimuth:", "inElevation:", "Horizon:", "Doppler:", "NotBtBehindTerrain:"];
        #var i = 0;
        foreach(myCheck ; me.Check_List)
        {
            #print(CheckTable[i] ~ " " ~ myCheck);
            #i +=1;
            checked = (myCheck and checked);
        }
        return checked;
    },

    go_check: func(SelectedObject){
        #if radar : check : InRange, inAzimuth, inElevation, NotBeyondHorizon, doppler, isNotBehindTerrain
        #if Rwr   : check : InhisRange (radardist), inHisElevation, inHisAzimuth, NotBeyondHorizon, isNotBehindTerrain
        #if heat  : check : InRange, inAzimuth, inElevation, NotBeyondHorizon, heat_sensor, isNotBehindTerrain
        #if laser : check : InRange, inAzimuth, inElevation, NotBeyondHorizon, isNotBehindTerrain
        #if cam  : check : InRange, inAzimuth, inElevation, NotBeyondHorizon, isNotBehindTerrain
        # Need to add the fonction flare_sensivity : is there flare near aircraft and should we get fooled by it
    
        append(me.Check_List, me.InRange(SelectedObject));
        if(me.Check_List[0] == 0)
        {
            return;
        }
        append(me.Check_List, me.inAzimuth(SelectedObject));
        if(me.Check_List[1] == 0)
        {
            return;
        }
        append(me.Check_List, me.inElevation(SelectedObject));
        if(me.Check_List[2] == 0)
        {
            return;
        }
        append(me.Check_List, me.NotBeyondHorizon(SelectedObject));
        if(me.Check_List[3] == 0)
        {
            return;
        }
        #me.heat_sensor(SelectedObject);
        append(me.Check_List, me.doppler(SelectedObject));
        if(me.Check_List[4] == 0)
        {
            return;
        }
        
        # Has to be last coz it will call the get_checked function
        append(me.Check_List, me.isNotBehindTerrain(SelectedObject));
    },

    janitor: func(){
        # This function is made to remove all persistent non relevant data on radar2 tree
        var myRadarNode = props.globals.getNode("instrumentation/radar2/targets", 1);
        var raw_list = myRadarNode.getChildren();
        foreach(var Tempo_TgtsFiles ; raw_list)
        {
            #print(Tempo_TgtsFiles.getName());
            if(Tempo_TgtsFiles.getNode("display", 1).getValue() != nil)
            {
                var myTime = Tempo_TgtsFiles.getNode("closure-last-time", 1);
                if(getprop("sim/time/elapsed-sec") - myTime.getValue() > me.janitorTime)
                {
                    var Property_list = Tempo_TgtsFiles.getChildren();
                    foreach(var myProperty ; Property_list )
                    {
                        # print(myProperty.getName());
                        if(myProperty.getName() != "closure-last-time")
                        {
                            myProperty.setValue("");
                        }
                    }
                }
            }
        }
        #screen.log.write("janitor(); done.");
    },

    displayTarget: func(){
        if(size(tgts_list) != 0)
        {
            if(Target_Index < 0)
            {
                Target_Index = size(tgts_list) - 1;
            }
            if(Target_Index > size(tgts_list) - 1)
            {
                Target_Index = 0;
            }
            var MyTarget = tgts_list[Target_Index];
            closeRange   = me.targetRange(MyTarget);
            heading      = MyTarget.get_heading();
            altitude     = MyTarget.get_altitude();
            speed        = MyTarget.get_Speed();
            callsign     = MyTarget.get_Callsign();
            longitude    = MyTarget.get_Longitude();
            latitude     = MyTarget.get_Latitude();
            bearing      = me.targetBearing(MyTarget);
            if(speed == nil)
            {
                speed = 0;
            }
            setprop("/ai/closest/range", closeRange);
            setprop("/ai/closest/bearing", bearing);
            setprop("/ai/closest/heading", heading);
            setprop("/ai/closest/altitude", altitude);
            setprop("/ai/closest/speed", speed);
            setprop("/ai/closest/callsign", callsign);
            setprop("/ai/closest/longitude", longitude);
            setprop("/ai/closest/latitude", latitude);
        }
    },

    myRadarList : [],
};

################################################################
#####################   Target class  ##########################
################################################################

var Target = {
    new: func(c){
        var obj             = { parents : [Target]};
        obj.RdrProp         = c.getNode("radar");
        obj.Heading         = c.getNode("orientation/true-heading-deg");
        obj.Alt             = c.getNode("position/altitude-ft");
        obj.lat             = c.getNode("position/latitude-deg");
        obj.lon             = c.getNode("position/longitude-deg");
        obj.pitch           = c.getNode("orientation/pitch-deg");
        obj.Speed           = c.getNode("velocities/true-airspeed-kt");
        obj.VSpeed          = c.getNode("velocities/vertical-speed-fps");
        obj.Callsign        = c.getNode("callsign");
        obj.name            = c.getNode("name");
        obj.validTree       = 0;
        
        obj.engineTree      = c.getNode("engines");
        
        obj.AcType          = c.getNode("sim/model/ac-type");
        obj.type            = c.getName();
        obj.index           = c.getIndex();
        obj.string          = "ai/models/" ~ obj.type ~ "[" ~ obj.index ~ "]";
        obj.shortstring     = obj.type ~ "[" ~ obj.index ~ "]";
        #obj.shortstring     = "aircraft" ~ "[" ~ obj.num ~ "]";
        
        obj.InstrString     = "instrumentation/radar2/targets";
        obj.InstrTgts       = props.globals.getNode(obj.InstrString, 1);
        
        obj.TgtsFiles       =   0; #obj.InstrTgts.getNode(obj.shortstring, 1);
        
        obj.Range           = obj.RdrProp.getNode("range-nm");
        obj.Bearing         = obj.RdrProp.getNode("bearing-deg");
        obj.Elevation       = obj.RdrProp.getNode("elevation-deg");
        obj.HOffset					= -9999.0;
        obj.VOffset					= -9999.0;
				obj.XShift					= -9999.0;
				obj.YShift					= -9999.0;
				obj.Rotation				= -9999.0;
        
        obj.MyCallsign      = 0;
        obj.BBearing        = 0; #obj.TgtsFiles.getNode("bearing-deg", 1);
        obj.BHeading        = 0; #obj.TgtsFiles.getNode("true-heading-deg", 1);
        obj.RangeScore      = 0; #obj.TgtsFiles.getNode("range-score", 1);
        obj.RelBearing      = 0; #obj.TgtsFiles.getNode("ddd-relative-bearing", 1);
        obj.Carrier         = 0; #obj.TgtsFiles.getNode("carrier", 1);
        obj.EcmSignal       = 0; #obj.TgtsFiles.getNode("ecm-signal", 1);
        obj.EcmSignalNorm   = 0; #obj.TgtsFiles.getNode("ecm-signal-norm", 1);
        obj.EcmTypeNum      = 0; #obj.TgtsFiles.getNode("ecm_type_num", 1);
        obj.Display         = 0; #obj.TgtsFiles.getNode("display", 1);
        obj.Fading          = 0; #obj.TgtsFiles.getNode("ddd-echo-fading", 1);
        obj.DddDrawRangeNm  = 0; #obj.TgtsFiles.getNode("ddd-draw-range-nm", 1);
        obj.TidDrawRangeNm  = 0; #obj.TgtsFiles.getNode("tid-draw-range-nm", 1);
        obj.RoundedAlt      = 0; #obj.TgtsFiles.getNode("rounded-alt-ft", 1);
        obj.TimeLast        = 0; #obj.TgtsFiles.getNode("closure-last-time", 1);
        obj.RangeLast       = 0; #obj.TgtsFiles.getNode("closure-last-range-nm", 1);
        obj.ClosureRate     = 0; #obj.TgtsFiles.getNode("closure-rate-kts", 1);
        
        #obj.TimeLast.setValue(ElapsedSec.getValue());
        
        obj.RadarStandby    = c.getNode("sim/multiplay/generic/int[2]");
        
        obj.deviation       = nil;
        
        return obj;
    },

    create_tree: func(MyAircraftCoord){
        me.TgtsFiles      = me.InstrTgts.getNode(me.shortstring, 1);
        
        me.MyCallsign     = me.TgtsFiles.getNode("callsign", 1);
        me.BBearing       = me.TgtsFiles.getNode("bearing-deg", 1);
        me.BHeading       = me.TgtsFiles.getNode("true-heading-deg", 1);
        me.RangeScore     = me.TgtsFiles.getNode("range-score", 1);
        me.RelBearing     = me.TgtsFiles.getNode("ddd-relative-bearing", 1);
        me.Carrier        = me.TgtsFiles.getNode("carrier", 1);
        me.EcmSignal      = me.TgtsFiles.getNode("ecm-signal", 1);
        me.EcmSignalNorm  = me.TgtsFiles.getNode("ecm-signal-norm", 1);
        me.EcmTypeNum     = me.TgtsFiles.getNode("ecm_type_num", 1);
        me.Display        = me.TgtsFiles.getNode("display", 1);
        me.Fading         = me.TgtsFiles.getNode("ddd-echo-fading", 1);
        me.DddDrawRangeNm = me.TgtsFiles.getNode("ddd-draw-range-nm", 1);
        me.TidDrawRangeNm = me.TgtsFiles.getNode("tid-draw-range-nm", 1);
        me.RoundedAlt     = me.TgtsFiles.getNode("rounded-alt-ft", 1);
        me.TimeLast       = me.TgtsFiles.getNode("closure-last-time", 1);
        me.RangeLast      = me.TgtsFiles.getNode("closure-last-range-nm", 1);
        me.ClosureRate    = me.TgtsFiles.getNode("closure-rate-kts", 1);
        
        me.Hoffset				= me.TgtsFiles.getNode("h-offset", 1);
        me.Voffset				= me.TgtsFiles.getNode("v-offset", 1);
	      me.Xshift					= me.TgtsFiles.getNode("x-shift", 1);
	      me.Yshift					= me.TgtsFiles.getNode("y-shift", 1);
	      me.rotation				= me.TgtsFiles.getNode("rotation", 1);
        
        #if(getprop(me.InstrString ~ "/" ~ me.shortstring ~ "/closure-last-time") == nil)
        #{
            me.TimeLast.setDoubleValue(ElapsedSec.getValue());
            me.RangeLast.setValue(me.get_range_from_Coord(MyAircraftCoord));
            me.Carrier.setBoolValue(0);
        #    print("update-once");
        #}
        
        #if(me.Range != nil)  if getproperty does not exist, it return nil. GetNode return NaN
        #if(getprop(me.string ~ "/range-nm") != nil)
        #{
        #    me.RangeLast.setValue(me.Range.getValue());
        #}
        #else
        #{
        #    me.RangeLast.setValue(0);
        #}
    },
    getRangeFactor :func(rng){
    var rangeFactor =0;
    if(rng == 10){RangeFactor = 0.002}
    elsif  (rng == 20){RangeFactor = 0.003246}
    elsif  (rng == 40){RangeFactor = 0.001623}
    elsif  (rng == 60){RangeFactor = 0.001023} 	# a mental guess !!! TOFIX
    elsif  (rng == 100){RangeFactor = 0.000523}	# a mental guess !!! TOFIX
    else{RangeFactor = 0.000123};
    
    },

    set_all: func(myAircraftCoord){
				var rangeFactorFix =0;
        me.RdrProp.getNode("in-range",1).setValue("true");
        me.MyCallsign.setValue(me.get_Callsign());
        me.BHeading.setValue(me.Heading.getValue());
        me.BBearing.setValue(me.get_bearing_from_Coord(myAircraftCoord));
        if (me.HOffset != nil){
        me.Hoffset.setValue(me.HOffset);
        me.Voffset.setValue(me.VOffset);
        if(me.XShift!=nil)me.Xshift.setValue(me.XShift);#this value should be dynamically calculated  
        if(me.YShift!=nil)me.Yshift.setValue(me.YShift);#this value should be dynamically calculated 
        if(me.Rotation!=nil)me.rotation.setValue(me.Rotation);
        }
    },

    remove: func(){
        me.validTree = 0;
        me.InstrTgts.removeChild(me.type, me.index);
    },

    set_nill: func(){
        # Suppression of the HUD display :
        # The property is initialised when the target is in range of "instrumentation/radar/range"
        # But nothing is done when "It's no more in range"
        # So this is a little hack for HUD.
        me.RdrProp.getNode("in-range",1).setValue("false");
        
        var Tempo_TgtsFiles = me.InstrTgts.getNode(me.shortstring, 1);
        var Property_list   = Tempo_TgtsFiles.getChildren();
        foreach(var myProperty ; Property_list)
        {
            #print(myProperty.getName());
            if(myProperty.getName() != "closure-last-time")
            {
                myProperty.setValue("");
            }
        }
    },

    get_Validity: func(){
        var n = 0;
        if(getprop(me.InstrString ~ "/" ~ me.shortstring ~ "/closure-last-time") != nil)
        {
            n = 1;
        }
        return n;
    },

    get_TimeLast: func(){
        var n = 0;
        if(getprop(me.InstrString ~ "/" ~ me.shortstring ~ "/closure-last-time") != nil )
        {
            #print(me.InstrString ~ "/" ~ me.shortstring ~ "/closure-last-time");
            #print(getprop(me.InstrString ~ "/" ~ me.shortstring ~ "/closure-last-time"));
            n = getprop(me.InstrString ~ "/" ~ me.shortstring ~ "/closure-last-time");
        }
        return n;
    },

    get_Coord: func(){
        TgTCoord  = geo.Coord.new();
        TgTCoord.set_latlon(me.lat.getValue(), me.lon.getValue(), me.Alt.getValue() * FT2M);
        return TgTCoord;
    },

    get_Callsign: func(){
        var n = me.Callsign.getValue();
        if(size(n) < 1)
        {
            n = me.name.getValue();
        }
        if(n == nil or size(n) < 1)
        {
            n = "UFO";
        }
        return n;
    },

    get_Speed: func(){
        var n = me.Speed.getValue();
        #var alt = me.Alt.getValue();
        #n = n / (0.632 ^ (-(alt / 25066))); # Calcul of Air Speed based on ground speed. the function ^ doesn't work !!
        return n;
    },

    get_Longitude: func(){
        var n = me.lon.getValue();
        return n;
    },

    get_Latitude: func(){
        var n = me.lat.getValue();
        return n;
    },

    get_Pitch: func(){
        var n = me.pitch.getValue();
        return n;
    },

    get_heading : func(){
        var n = me.Heading.getValue();
        if(n == nil)
        {
            n = 0;
        }
        return n;
    },

    get_bearing: func(){
        var n = 0;
        n = me.Bearing.getValue();
        if(n == nil)
        {
            n = 0;
        }
        return n;
    },

    get_bearing_from_Coord: func(MyAircraftCoord){
        var myCoord = me.get_Coord();
        var myBearing = 0;
        if(myCoord.is_defined())
        {
            myBearing = MyAircraftCoord.course_to(myCoord);
        }
        #print("get_bearing_from_Coord :" ~ myBearing);
        return myBearing;
    },

    set_relative_bearing: func(n){
        if(n == nil)
        {
            n = 0;
        }
        me.RelBearing.setValue(n);
    },

    get_reciprocal_bearing: func(){
        return geo.normdeg(me.get_bearing() + 180);
    },

    get_deviation: func(true_heading_ref, coord){
        me.deviation =  - deviation_normdeg(true_heading_ref, me.get_bearing_from_Coord(coord));
        #print(me.deviation);
        return me.deviation;
    },

    get_altitude: func(){
        return me.Alt.getValue();
    },

    get_Elevation_from_Coord: func(MyAircraftCoord){
        var myCoord = me.get_Coord();
        var myPitch = math.asin((myCoord.alt() - MyAircraftCoord.alt()) / myCoord.direct_distance_to(MyAircraftCoord)) * R2D;
        return myPitch;
    },

    get_total_elevation_from_Coord: func(own_pitch, MyAircraftCoord){
        var myTotalElevation =  - deviation_normdeg(own_pitch, me.get_Elevation_from_Coord(MyAircraftCoord));
        return myTotalElevation;
    },
    
    get_total_elevation: func(own_pitch){
        me.deviation =  - deviation_normdeg(own_pitch, me.Elevation.getValue());
        return me.deviation;
    },

    get_range: func(){
        #print("me.Range.getValue() :" ~ me.Range.getValue());
        return me.Range.getValue();
    },

    get_range_from_Coord: func(MyAircraftCoord){
        var myCoord = me.get_Coord();
        var myDistance = 0;
        if(myCoord.is_defined())
        {
            myDistance = MyAircraftCoord.direct_distance_to(myCoord) * M2NM;
        }
        #print("get_range_from_Coord :" ~ myDistance);
        return myDistance;
    },

    get_horizon: func(own_alt){
        var tgt_alt = me.get_altitude();
        if(debug.isnan(tgt_alt))
        {
            return(0);
        }
        if(tgt_alt < 0 or tgt_alt == nil)
        {
            tgt_alt = 0;
        }
        if(own_alt < 0 or own_alt == nil)
        {
            own_alt = 0;
        }
        # Return the Horizon in NM
        return(2.2 * ( math.sqrt(own_alt * FT2M) + math.sqrt(tgt_alt * FT2M)));
    },

    get_engineTree: func(){
        return me.engineTree;
    },

    check_carrier_type: func(){
        var type = "none";
        var carrier = 0;
        if(me.AcType != nil)
        {
            type = me.AcType.getValue();
        }
        if(type == "MP-Nimitz"
            or type == "MP-Eisenhower"
            or type == "MP-Vinson"
            or type == "Nimitz"
            or type == "Eisenhower"
            or type == "Vinson"
        )
        {
            carrier = 1;
        }
        if(me.type == "carrier")
        {
            carrier = 1;
        }
        # This works only after the mp-carrier model has been loaded. Before that it is seen like a common aircraft.
        if(me.get_Validity())
        {
            setprop(me.InstrString ~ "/" ~ me.shortstring ~ "/carrier", carrier);
        }
        return carrier;
    },

    get_rdr_standby: func(){
        var s = 0;
        if(me.RadarStandby != nil)
        {
            s = me.RadarStandby.getValue();
            if(s == nil)
            {
                s = 0;
            }
            elsif(s != 1)
            {
                s = 0;
            }
        }
        return s;
    },

    get_display: func(){
        return me.Display.getValue();
    },

    set_display: func(n){
        me.Display.setBoolValue(n);
    },

    get_fading: func(){
        var fading = me.Fading.getValue();
        if(fading == nil)
        {
            fading = 0;
        }
        return fading;
    },

    set_fading: func(n){
        me.Fading.setValue(n);
    },

    set_ddd_draw_range_nm: func(n){
        me.DddDrawRangeNm.setValue(n);
    },

    set_hud_draw_horiz_dev: func(n){
        me.HudDrawHorizDev.setValue(n);
    },

    set_tid_draw_range_nm: func(n){
        me.TidDrawRangeNm.setValue(n);
    },

    set_rounded_alt: func(n){
        me.RoundedAlt.setValue(n);
    },

    get_closure_rate: func(){
        var dt = ElapsedSec.getValue() - me.TimeLast.getValue();
        var rng = me.Range.getValue();
        var lrng = me.RangeLast.getValue();
        if(debug.isnan(rng) or debug.isnan(lrng))
        {
            print("####### get_closure_rate(): rng or lrng = nan ########");
            me.ClosureRate.setValue(0);
            me.RangeLast.setValue(0);
            return(0);
        }
        var t_distance = lrng - rng;
        var cr = (dt > 0) ? t_distance / dt * 3600 : 0;
        me.ClosureRate.setValue(cr);
        me.RangeLast.setValue(rng);
        return(cr);
    },

    get_closure_rate_from_Coord: func(MyAircraftCoord) {
        # First step : find the target heading.
        var myHeading = me.Heading.getValue();
        
        # Second What would be the aircraft heading to go to us
        var myCoord = me.get_Coord();
        var projectionHeading = myCoord.course_to(MyAircraftCoord);
        
        # Calculate the angle difference
        var myAngle = myHeading - projectionHeading; #Should work even with negative values
        
        # take the "ground speed"
        # velocities/true-air-speed-kt
        var mySpeed = me.Speed.getValue();
        var myProjetedHorizontalSpeed = mySpeed*math.cos(myAngle*D2R); #in KTS
        
        #print("Projetted Horizontal Speed:"~ myProjetedHorizontalSpeed);
        
        # Now getting the pitch deviation
        var myPitchToAircraft = - me.Elevation.getValue();
        #print("My pitch to Aircraft:"~myPitchToAircraft);
        
        # Get V speed
        if(me.VSpeed.getValue() == nil)
        {
            return 0;
        }
        var myVspeed = me.VSpeed.getValue()*FPS2KT;
        # This speed is absolutely vertical. So need to remove pi/2
        
        var myProjetedVerticalSpeed = myVspeed * math.cos(myPitchToAircraft-90*D2R);
        
        # Control Print
        #print("myVspeed = " ~myVspeed);
        #print("Total Closure Rate:" ~ (myProjetedHorizontalSpeed+myProjetedVerticalSpeed));
        
        # Total Calculation
        var cr = myProjetedHorizontalSpeed+myProjetedVerticalSpeed;
        
        # Setting Essential properties
        var rng = me. get_range_from_Coord(MyAircraftCoord);
        var newTime= ElapsedSec.getValue();
        if(me.get_Validity())
        {
            setprop(me.InstrString ~ "/" ~ me.shortstring ~ "/closure-last-range-nm", rng);
            setprop(me.InstrString ~ "/" ~ me.shortstring ~ "/closure-rate-kts", cr);
        }
        
        return cr;
    },

    get_shortring:func(){
        return me.shortstring;
    },

    list : [],
};

# Utilities.
var deviation_normdeg = func(our_heading, target_bearing){
    var dev_norm = our_heading - target_bearing;
    while(dev_norm < -180)
    {
        dev_norm += 360;
    }
    while(dev_norm > 180)
    {
        dev_norm -= 360;
    }
    return(dev_norm);
}

var rounding1000 = func(n){
    var a = int(n / 1000);
    var l = (a + 0.5) * 1000;
    n = (n >= l) ? ((a + 1) * 1000) : (a * 1000);
    return(n);
}

# Controls
radar_mode_sel = func(mode){
    # FIXME: Modes props should provide their own data instead of being hardcoded.
    foreach(var n ; props.globals.getNode("instrumentation/radar/mode").getChildren())
    {
        n.setBoolValue(n.getName() == mode);
        wcs_mode = mode;
    }
    if(wcs_mode == "rws")
    {
        AzField.setValue(120);
        swp_diplay_width = 0.0844;
    }
    else
    {
        AzField.setValue(60);
        swp_diplay_width = 0.0422;
    }
}

radar_mode_toggle = func(){
    # FIXME: Modes props should provide their own data instead of being hardcoded.
    # Toggles between the available modes.
    foreach(var n ; props.globals.getNode("instrumentation/radar/mode").getChildren())
    {
        if(n.getBoolValue())
        {
            wcs_mode = n.getName();
        }
    }
    if(wcs_mode == "rws")
    {
        setprop("instrumentation/radar/mode/rws", 0);
        setprop("instrumentation/radar/mode/tws-auto", 1);
        wcs_mode = "tws-auto";
        AzField.setValue(60);
        swp_diplay_width = 0.0422;
        tgts_list = [];
    }
    elsif(wcs_mode == "tws-auto")
    {
        setprop("instrumentation/radar/mode/tws-auto", 0);
        setprop("instrumentation/radar/mode/rws", 1);
        wcs_mode = "pulse-srch";
        AzField.setValue(120);
        swp_diplay_width = 0.0844;
    }
}

next_Target_Index = func(){
    Target_Index += 1;
    #print(size(tgts_list));
    if(Target_Index > size(tgts_list) - 1)
    {
        Target_Index = 0;
    }
    if(GetTarget()!=nil)screen.log.write("Radar: Locked "~tgts_list[Target_Index].Callsign.getValue(),1,1,0);
}

previous_Target_Index = func(){
    Target_Index -= 1;
    #print(size(tgts_list));
    if(Target_Index < 0)
    {
        Target_Index = size(tgts_list) - 1;
    }
}

GetTarget = func(){
    if(size(tgts_list) == 0)
    {
        return nil;
    }
    if(Target_Index < 0)
    {
        Target_Index = size(tgts_list) - 1;
    }
    if(Target_Index > size(tgts_list) - 1)
    {
        Target_Index = 0;
    }
    return tgts_list[Target_Index];
}

var switch_distance = func(){
    rangeTab = me.rangeTab;
    rangeIndex = math.mod(rangeIndex + 1, size(rangeTab));
    RangeSelected.setValue(rangeTab[rangeIndex]);
    setprop("instrumentation/radar/range", rangeTab[rangeIndex]);
}

