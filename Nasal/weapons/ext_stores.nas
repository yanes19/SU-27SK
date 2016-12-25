print("*** LOADING ext_stores.nas ... ***");
################################################################################
#
#                     m2005-5's EXTERNAL STORES SETTINGS
#
################################################################################

# check then drop
var dropTanks = func()
{
    for(var i = 2 ; i < 5 ; i += 1)
    {
        var select = getprop("/sim/weight["~ i ~"]/selected");
        if(select == "1300 l Droptank" or select == "1700 l Droptank")
        {
            m2000_load.dropLoad(i);
        }
    }
}

# compile all load in a multiplay variable
var Encode_Load = func()
{
    var list = [
        "none",
        "R-73",
        "R-27R",
        "R-27ER",
        "R-27T",
        "R-27ET",
        "SmokeGenerator"
    ];
    var compiled = "";
    
    for(var i = 0 ; i < 10 ; i += 1)
    {
        # Load name
        var select = getprop("sim/weight["~ i ~"]/selected");
        
        # fireable or not : may displays the pylons if there a weight but fire = 0
        var released = getprop("controls/armament/station["~ i ~"]/release");
        
        # selection of the index load for each pylon
        # We get the children of the tree sim weight[actual]
        for(var y = 0 ; y < size(list) ; y += 1)
        {
            if(list[y] == select)
            {
                var select_Index = y;
            }
        }
        
        # now we select the index
        compiled = compiled ~"#"~ i ~ released ~ select_Index;
    }
    
    # we put it in a multiplay string
    setprop("sim/multiplay/generic/string[1]", compiled);
}

### Object decode
var Decode_Load = {
    new: func(mySelf, myString, updateTime)
    {
        var m = { parents: [Decode_Load] };
        m.mySelf = mySelf;
        m.myString = myString;
        m.updateTime = updateTime;
        m.running = 1;
        m.loadList = [
        "none",
        "R-73",
        "R-27R",
        "R-27ER",
        "R-27T",
        "R-27ET",
        "SmokeGenerator"
        ];
        return m;
    },
    
    decode: func()
    {
        #print("Upload On going");
        var myString = me.myString.getValue();
        var myIndexArray = [];
        
        if(myString != nil)
        {
            #print("the string :"~ myString);
            #print("test" ~ me.loadList[3]);
            # Here to detect each substring index
            for(i = 0 ; i < size(myString) ; i += 1)
            {
                #print(chr(myString[i]));
                if(chr(myString[i]) == '#')
                {
                    #print("We got one : " ~ i );
                    append(myIndexArray, i);
                }
                #print(size(myIndexArray));
            }
            
            # now we can split the substring
            for(i = 0 ; i < size(myIndexArray) ; i += 1)
            {
                if(i < size(myIndexArray) - 1)
                {
                    #print(substr(myString, myIndexArray[i], myIndexArray[i + 1] - myIndexArray[i]));
                    
                    # index of weight :
                    var myWeightIndex = substr(myString, myIndexArray[i] + 1, 1);
                    #print("myWeightIndex:"~ myWeightIndex);
                    
                    # has been fired (display pylons or not)
                    var myFired = substr(myString, myIndexArray[i] + 2, 1) == 1;
                    #print(myFired);
                    
                    # what to put in weight[]/selected index
                    var myWeightOptIndex = substr(myString, myIndexArray[i] + 3, (myIndexArray[i + 1] - 1) - (myIndexArray[i] + 2));
                    var myWeight = me.loadList[myWeightOptIndex];
                    #var myWeight = getprop("sim/weight["~ myWeightIndex ~"]/opt[" ~ myWeightOptIndex ~ "]/name");
                    #print("myWeight: " ~ myWeight);
                    
                    # rebuilt the property Tree
                    me.mySelf.getNode("sim/weight["~ myWeightIndex ~"]/selected", 1).setValue(myWeight);
                    me.mySelf.getNode("controls/armament/station["~ myWeightIndex ~"]/release", 1).setValue(myFired);
                }
                else
                {
                    #print(substr(myString, myIndexArray[i], size(myString) - myIndexArray[i]));
                    
                    # index of weight :
                    var myWeightIndex = substr(myString, myIndexArray[i] + 1, 1);
                    #print(myWeightIndex);
                    
                    # has been fired (display pylons or not)
                    var myFired = substr(myString, myIndexArray[i] + 2, 1) == 1;
                    #print(myFired);
                    
                    # what to put in weight[]/selected
                    var myWeightOptIndex = substr(myString, myIndexArray[i] + 3, size(myString) - (myIndexArray[i] + 2));
                    var myWeight = me.loadList[myWeightOptIndex];
                    #var myWeight = getprop("sim/weight["~ myWeightIndex ~"]/opt[" ~ myWeightOptIndex ~ "]/name");
                    #print(myWeight);
                    
                    # rebuilt the property Tree
                    me.mySelf.getNode("sim/weight["~ myWeightIndex ~"]/selected", 1).setValue(myWeight);
                    me.mySelf.getNode("controls/armament/station["~ myWeightIndex ~"]/release", 1).setValue(myFired);
                    
                    if(me.running == 1)
                    {
                        settimer(func(){ me.decode(); }, me.updateTime);
                    }
                }
            }
        }
        #print(me.mySelf.getName() ~ "["~ me.mySelf.getIndex() ~"]");
    },
    stop: func()
    {
        me.running = 0;
    },
};

# Here is where quick load management is managed...
# These 4 function can't be active when flying : This mean a little preparation for the mission
# It's an anti kiddo script
var Po = func()
{
    if(getprop("/gear/gear[2]/wow") == 1)
    {
        # pylon 0
        setprop("/sim/weight[0]/selected",                   "none");
        
        # pylon 1
        setprop("/sim/weight[1]/selected",                   "Matra R550 Magic 2");
        
        # pylon 2
        setprop("/sim/weight[2]/selected",                   "none");
        setprop("/consumables/fuel/tank[2]/selected",        0);
        setprop("/consumables/fuel/tank[2]/capacity-gal_us", 0);
        setprop("/consumables/fuel/tank[2]/level-gal_us",    0);
        
        # pylon 3
        setprop("/sim/weight[3]/selected",                   "1300 l Droptank");
        setprop("/consumables/fuel/tank[3]/selected",        1);
        setprop("/consumables/fuel/tank[3]/capacity-gal_us", 343);
        setprop("/consumables/fuel/tank[3]/level-gal_us",    342);
        
        # pylon 4
        setprop("/sim/weight[4]/selected",                   "none");
        setprop("/consumables/fuel/tank[4]/selected",        0);
        setprop("/consumables/fuel/tank[4]/capacity-gal_us", 0);
        setprop("/consumables/fuel/tank[4]/level-gal_us",    0);
        
        # pylon 5
        setprop("/sim/weight[5]/selected",                   "Matra R550 Magic 2");
        
        # pylon 6
        setprop("/sim/weight[6]/selected",                   "none");
        
        # pylon 7
        setprop("/sim/weight[7]/selected",                   "none");
        
        # pylon 8
        setprop("/sim/weight[8]/selected",                   "none");
        
        FireableAgain();
    }
}

var Fox = func()
{
    if(getprop("/gear/gear[2]/wow") == 1)
    {
        # pylon 0
        setprop("/sim/weight[0]/selected",                   "Matra MICA");
        
        # pylon 1
        setprop("/sim/weight[1]/selected",                   "Matra R550 Magic 2");
        
        # pylon 2
        setprop("/sim/weight[2]/selected",                   "none");
        setprop("/consumables/fuel/tank[2]/selected",        0);
        setprop("/consumables/fuel/tank[2]/capacity-gal_us", 0);
        setprop("/consumables/fuel/tank[2]/level-gal_us",    0);
        
        # pylon 3
        setprop("/sim/weight[3]/selected",                   "1300 l Droptank");
        setprop("/consumables/fuel/tank[3]/selected",        1);
        setprop("/consumables/fuel/tank[3]/capacity-gal_us", 343);
        setprop("/consumables/fuel/tank[3]/level-gal_us",    342);
        
        # pylon 4
        setprop("/sim/weight[4]/selected",                   "none");
        setprop("/consumables/fuel/tank[4]/selected",        0);
        setprop("/consumables/fuel/tank[4]/capacity-gal_us", 0);
        setprop("/consumables/fuel/tank[4]/level-gal_us",    0);
        
        # pylon 5
        setprop("/sim/weight[5]/selected",                   "Matra R550 Magic 2");
        
        # pylon 6
        setprop("/sim/weight[6]/selected",                   "Matra MICA");
        
        # pylon 7
        setprop("/sim/weight[7]/selected",                   "Matra MICA");
        
        # pylon 8
        setprop("/sim/weight[8]/selected",                   "Matra MICA");
        
        FireableAgain();
    }
}

var Bravo = func()
{
    if(getprop("/gear/gear[2]/wow") == 1)
    {
        # pylon 0
        setprop("/sim/weight[0]/selected",                   "Matra MICA");
        
        # pylon 1
        setprop("/sim/weight[1]/selected",                   "Matra R550 Magic 2");
        
        # pylon 2
        setprop("/sim/weight[2]/selected",                   "1700 l Droptank");
        setprop("/consumables/fuel/tank[2]/selected",        1);
        setprop("/consumables/fuel/tank[2]/capacity-gal_us", 448.50);
        setprop("/consumables/fuel/tank[2]/level-gal_us",    447);
        
        # pylon 3
        setprop("/sim/weight[3]/selected",                   "none");
        setprop("/consumables/fuel/tank[3]/selected",        0);
        setprop("/consumables/fuel/tank[3]/capacity-gal_us", 0);
        setprop("/consumables/fuel/tank[3]/level-gal_us",    0);
        
        # pylon 4
        setprop("/sim/weight[4]/selected",                   "1700 l Droptank");
        setprop("/consumables/fuel/tank[4]/selected",        1);
        setprop("/consumables/fuel/tank[4]/capacity-gal_us", 448.50);
        setprop("/consumables/fuel/tank[4]/level-gal_us",    447);
        
        # pylon 5
        setprop("/sim/weight[5]/selected",                   "Matra R550 Magic 2");
        
        # pylon 6
        setprop("/sim/weight[6]/selected",                   "Matra MICA");
        
        # pylon 7
        setprop("/sim/weight[7]/selected",                   "Matra MICA");
        
        # pylon 8
        setprop("/sim/weight[8]/selected",                   "Matra MICA");
        
        FireableAgain();
    }
}

var Kilo = func()
{
    if(getprop("/gear/gear[2]/wow") == 1)
    {
        # pylon 0
        setprop("/sim/weight[0]/selected",                   "Matra MICA");
        
        # pylon 1
        setprop("/sim/weight[1]/selected",                   "Matra MICA");
        
        # pylon 2
        setprop("/sim/weight[2]/selected",                   "1700 l Droptank");
        setprop("/consumables/fuel/tank[2]/selected",        1);
        setprop("/consumables/fuel/tank[2]/capacity-gal_us", 448.50);
        setprop("/consumables/fuel/tank[2]/level-gal_us",    447);
        
        # pylon 3
        setprop("/sim/weight[3]/selected",                   "1300 l Droptank");
        setprop("/consumables/fuel/tank[3]/selected",        1);
        setprop("/consumables/fuel/tank[3]/capacity-gal_us", 343);
        setprop("/consumables/fuel/tank[3]/level-gal_us",    342);
        
        # pylon 4
        setprop("/sim/weight[4]/selected",                   "1700 l Droptank");
        setprop("/consumables/fuel/tank[4]/selected",        1);
        setprop("/consumables/fuel/tank[4]/capacity-gal_us", 448.50);
        setprop("/consumables/fuel/tank[4]/level-gal_us",    447);
        
        # pylon 5
        setprop("/sim/weight[5]/selected",                   "Matra MICA");
        
        # pylon 6
        setprop("/sim/weight[6]/selected",                   "Matra MICA");
        
        # pylon 7
        setprop("/sim/weight[7]/selected",                   "Matra MICA");
        
        # pylon 8
        setprop("/sim/weight[8]/selected",                   "Matra MICA");
        
        FireableAgain();
    }
}

var NoLoad = func()
{
    if(getprop("/gear/gear[2]/wow") == 1)
    {
        # pylon 0
        setprop("/sim/weight[0]/selected",                   "none");
        
        # pylon 1
        setprop("/sim/weight[1]/selected",                   "none");
        
        # pylon 2
        setprop("/sim/weight[2]/selected",                   "none");
        setprop("/consumables/fuel/tank[2]/selected",        0);
        setprop("/consumables/fuel/tank[2]/capacity-gal_us", 0);
        setprop("/consumables/fuel/tank[2]/level-gal_us",    0);
        
        # pylon 3
        setprop("/sim/weight[3]/selected",                   "none");
        setprop("/consumables/fuel/tank[3]/selected",        0);
        setprop("/consumables/fuel/tank[3]/capacity-gal_us", 0);
        setprop("/consumables/fuel/tank[3]/level-gal_us",    0);
        
        # pylon 4
        setprop("/sim/weight[4]/selected",                   "none");
        setprop("/consumables/fuel/tank[4]/selected",        0);
        setprop("/consumables/fuel/tank[4]/capacity-gal_us", 0);
        setprop("/consumables/fuel/tank[4]/level-gal_us",    0);
        
        # pylon 5
        setprop("/sim/weight[5]/selected",                   "none");
        
        # pylon 6
        setprop("/sim/weight[6]/selected",                   "none");
        
        # pylon 7
        setprop("/sim/weight[7]/selected",                   "none");
        
        # pylon 8
        setprop("/sim/weight[8]/selected",                   "none");
        FireableAgain();
    }
}

var AirToGround = func()
{
    if(getprop("/gear/gear[2]/wow") == 1)
    {
        # pylon 0
        setprop("/sim/weight[0]/selected",                   "GBU16");
        
        # pylon 1
        setprop("/sim/weight[1]/selected",                   "Matra MICA");
        
        # pylon 2
        setprop("/sim/weight[2]/selected",                   "1700 l Droptank");
        setprop("/consumables/fuel/tank[2]/selected",        1);
        setprop("/consumables/fuel/tank[2]/capacity-gal_us", 448.50);
        setprop("/consumables/fuel/tank[2]/level-gal_us",    447);
        
        # pylon 3
        setprop("/sim/weight[3]/selected",                   "SCALP");
        setprop("/consumables/fuel/tank[3]/selected",        0);
        setprop("/consumables/fuel/tank[3]/capacity-gal_us", 0);
        setprop("/consumables/fuel/tank[3]/level-gal_us",    0);
        
        # pylon 4
        setprop("/sim/weight[4]/selected",                   "1700 l Droptank");
        setprop("/consumables/fuel/tank[4]/selected",        1);
        setprop("/consumables/fuel/tank[4]/capacity-gal_us", 448.50);
        setprop("/consumables/fuel/tank[4]/level-gal_us",    447);
        
        # pylon 5
        setprop("/sim/weight[5]/selected",                   "Matra MICA");
        
        # pylon 6
        setprop("/sim/weight[6]/selected",                   "GBU16");
        
        # pylon 7
        setprop("/sim/weight[7]/selected",                   "GBU16");
        
        # pylon 8
        setprop("/sim/weight[8]/selected",                   "GBU16");
        
        FireableAgain();
    }
}

var FireableAgain = func()
{
    for(var i = 0 ; i < 9 ; i += 1)
    {
        # to make it fireable again
        setprop("/controls/armament/station["~ i ~"]/release", 0);
        
        # To add weight to pylons
        var select = getprop("/sim/weight["~ i ~"]/selected");
        
        if(select == "Matra MICA")
        {
            setprop("/sim/weight["~ i ~"]/weight-lb", 246.91);
        }
        elsif(select == "Matra R550 Magic 2")
        {
            setprop("/sim/weight["~ i ~"]/weight-lb", 196.21);
        }
        elsif(select == "GBU16")
        {
            setprop("/sim/weight["~ i ~"]/weight-lb", 1000);
        }
        elsif(select == "SCALP")
        {
            setprop("/sim/weight["~ i ~"]/weight-lb", 2866);
        }
        elsif(select == "1700 l Droptank")
        {
            setprop("/sim/weight["~ i ~"]/weight-lb", 280);
        }
        elsif(select == "1300 l Droptank")
        {
            setprop("/sim/weight["~ i ~"]/weight-lb", 220);
        }
    }
    setprop("controls/armament/name", getprop("sim/weight[0]/selected"));
}

# Begining of the dropable function.
# It has to be simplified and generic made
# Need to know how to make a table
dropLoad = func(number)
{
    var select = getprop("/sim/weight["~ number ~"]/selected");
    if(select != "none")
    {
        if(select == "1300 l Droptank" or select == "1700 l Droptank")
        {
            tank_submodel(number, select);
            setprop("/consumables/fuel/tank["~ number ~"]/selected", 0);
            setprop("/consumables/fuel/tank["~ number ~"]/capacity-m3", 0);
            setprop("/consumables/fuel/tank["~ number ~"]/level-kg", 0);
            setprop("/controls/armament/station["~ number ~"]/release", 1);
            setprop("/sim/weight["~ number ~"]/weight-lb", 0);
        }
        else
        {
            if(getprop("/controls/armament/station["~ number ~"]/release") == 0)
            {
                m2000_load.dropMissile(number);
                print("firing load at : "  ,number);
            }
        }
    }
}

# Need to be changed
dropLoad_stop = func(n)
{
    #setprop("/controls/armament/station["~ n ~"]/release", 0);
}

dropMissile = func(number)
{
   var target = radar.GetTarget();

    var typeMissile = getprop("/sim/weight["~ number ~"]/selected");
    var isMissile = missile.Loading_missile(typeMissile);
    if(isMissile != 0)
    {
        if(target == nil)
        {
            return;
        }
        Current_missile = missile.MISSILE.new(number);
        Current_missile.status = 0;
        Current_missile.search(target);
        Current_missile.release();
        setprop("/sim/weight["~ number ~"]/weight-lb", 0);
    }
    setprop("/controls/armament/station["~ number ~"]/release", 1);
    after_fire_next();
}

var tank_submodel = func(pylone, select)
{
    # 1300 Tanks
    var release = 0;
    if(pylone == 2 and select == "1300 l Droptank")
    {
        release = "/controls/armament/station[2]/release-L1300";
    }
    if(pylone == 3 and select == "1300 l Droptank")
    {
        release = "/controls/armament/station[3]/release-C1300";
    }
    if(pylone == 4 and select == "1300 l Droptank")
    {
        release ="/controls/armament/station[4]/release-R1300";
    }
    # 1700 Tanks
    if(pylone == 2 and select == "1700 l Droptank")
    {
        release ="/controls/armament/station[2]/release-L1700";
    }
    if(pylone == 4 and select == "1700 l Droptank")
    {
        release ="/controls/armament/station[4]/release-R1700";
    }
    setprop(release, 1);
    settimer(func{setprop(release, 0);}, 0, 5);
}

var inscreased_selected_pylon = func()
{
    var SelectedPylon = getprop("/controls/armament/missile/current-pylon");
    var out = 0;
    var mini = loadsmini();
    var max = loadsmaxi();
    
    if(SelectedPylon == max)
    {
        SelectedPylon=-1;
    }
    
    for(var i = SelectedPylon + 1 ; i < 9 ; i += 1)
    {
        if(getprop("/sim/weight["~ i ~"]/selected"))
        {
            if(getprop("/sim/weight["~ i ~"]/weight-lb") > 1)
            {
                if(mini == -1)
                {
                    mini = i;
                }
                max = i;
                if(out == 0)
                {
                    SelectedPylon = i;
                    out = 1;
                }
            }
        }
    }
    if(SelectedPylon == getprop("/controls/armament/missile/current-pylon"))
    {
        SelectedPylon = mini;
    }
    setprop("/controls/armament/name", getprop("/sim/weight["~ SelectedPylon ~"]/selected"));
    setprop("/controls/armament/missile/current-pylon", SelectedPylon);
}

var decreased_selected_pylon = func()
{
}

# smallest index of load
var loadsmini = func()
{
    var out = 0;
    for(var i = 0 ; i < 9 ; i += 1)
    {
        if(getprop("/sim/weight["~ i ~"]/weight-lb") > 1)
        {
            if(out == 0)
            {
                var mini = i;
                out = 1;
            }
            var maxi = i;
        }
    }
    return mini;
}

# Biggest index of load
var loadsmaxi = func()
{
    var out = 0;
    for(var i = 0 ; i < 9 ; i += 1)
    {
        if(getprop("/sim/weight["~ i ~"]/weight-lb") > 1)
        {
            if(out == 0)
            {
                var mini = i;
                out = 1;
            }
            var maxi = i;
        }
    }
    return maxi;
}

# next missile after fire
var after_fire_next = func()
{
    var SelectedPylon = getprop("/controls/armament/missile/current-pylon");
#    if(SelectedPylon == "nil")
		SelectNextPylon();
    if(SelectedPylon == nil)
    {
        SelectedPylon = 0;
    }
    var out = 0;
    
    # pylons 2 and 4
    if(SelectedPylon == 4)
    {
        SelectedPylon = 2;
    }
    elsif(SelectedPylon == 2)
    {
        SelectedPylon = 4;
    }
    
    # pylons 1 and 5
    if(SelectedPylon == 5)
    {
        SelectedPylon = 1;
    }
    elsif(SelectedPylon == 1)
    {
        SelectedPylon = 5;
    }
    
    # pylons 0 and 6
    if(SelectedPylon == 6)
    {
        SelectedPylon = 0;
    }
    elsif(SelectedPylon == 0)
    {
        SelectedPylon = 6;
    }
    
    # pylons 7 and 8
    if(SelectedPylon == 8)
    {
        SelectedPylon = 7;
    }
    elsif(SelectedPylon == 7)
    {
        SelectedPylon = 8;
    }
    
    if(getprop("/sim/weight["~ SelectedPylon ~"]/weight-lb") < 1)
    {
        for(var i = 0 ; i < 9 ; i += 1)
        {
            if(getprop("/sim/weight["~ i ~"]/weight-lb") > 1)
            {
                if(out == 0)
                {
                    SelectedPylon = i;
                    out = 1;
                }
            }
        }
        setprop("/controls/armament/name", getprop("/sim/weight["~ SelectedPylon ~"]/selected"));
        setprop("/controls/armament/missile/current-pylon", SelectedPylon);
    }
    else
    {
        setprop("/controls/armament/name", getprop("/sim/weight["~ SelectedPylon ~"]/selected"));
        setprop("/controls/armament/missile/current-pylon", SelectedPylon);
    }
}

# next missile selection after fire
var SelectNextPylon = func()
{
		var leftPylons = [0,2,4,6,8];
		var RightPylons = [1,3,5,7,9];

		var SelectedPylon		 = props.globals.getNode("controls/armament/missile/current-pylon", 1);
		var Selectedweapon	 = getprop("controls/armament/selected-weapon");
		
		for(var i = 0 ; i < 9 ; i += 1)
        {
					if(getprop("sim/weight["~ i ~"]/selected") == Selectedweapon and getprop("controls/armament/station["~ i ~"]/release") == 0)
					{
							SelectedPylon.setValue(i);
							print("Next selected = pylon",i);
							setprop("/sim/messages/atc", "Next selected = pylon"~i);
							break;
					}
        }
}
