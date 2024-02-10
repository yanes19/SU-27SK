var showPylonsDlg = func{
	if(getprop("/payload/armament/msg")){
		if(getprop("/gear/gear/compression-ft")<0.01){
			screen.log.write("Payload Dialog disabled at the moment!",1,0,0);
			return;
		}
	}
var (width,height) = (980,640);
var title = 'Su-27 pylons loads editor :';
 
# create a new window, dimensions are WIDTH x HEIGHT, using the dialog decoration (i.e. titlebar)
var window = canvas.Window.new([width,height],"dialog").set('title',title);
 
# adding a canvas to the new window and setting up background colors/transparency
var myCanvas = window.createCanvas().set("background", canvas.style.getColor("bg_color"));
 
# creating the top-level/root group which will contain all other elements/group
var root = myCanvas.createGroup();
 
# create a new layout for the dialog:
var mainVBox = canvas.VBoxLayout.new();
# assign the layout to the Canvas

myCanvas.setLayout(mainVBox);

var pylonsMap = canvas.gui.widgets.Label.new(root, canvas.style, {} )
	.setImage("Aircraft/SU-27SK/Dialogs/Su-27-Pylons.png")
	.setFixedSize(697,197); # image dimensions
mainVBox.addItem(pylonsMap);



var Hbox2 = canvas.HBoxLayout.new();
mainVBox.addItem(Hbox2);

var P8Ctls = canvas.VBoxLayout.new();
Hbox2.addItem(P8Ctls);

var P6Ctls = canvas.VBoxLayout.new();
Hbox2.addItem(P6Ctls);

var P4Ctls = canvas.VBoxLayout.new();
Hbox2.addItem(P4Ctls);

var P10Ctls = canvas.VBoxLayout.new();
Hbox2.addItem(P10Ctls);

var P2Ctls = canvas.VBoxLayout.new();
Hbox2.addItem(P2Ctls);

var P1Ctls = canvas.VBoxLayout.new();
Hbox2.addItem(P1Ctls);

var P9Ctls = canvas.VBoxLayout.new();
Hbox2.addItem(P9Ctls);

var P3Ctls = canvas.VBoxLayout.new();
Hbox2.addItem(P3Ctls);

var P5Ctls = canvas.VBoxLayout.new();
Hbox2.addItem(P5Ctls);

var P7Ctls = canvas.VBoxLayout.new();
Hbox2.addItem(P7Ctls);


var Lbl_pyln8 = canvas.gui.widgets.Label.new(root, canvas.style, {} )
	.setText("P8:"~getprop("sim/weight[7]/selected"));
P8Ctls.addItem(Lbl_pyln8);

var Lbl_pyln6 = canvas.gui.widgets.Label.new(root, canvas.style, {} )
	.setText("P6:"~getprop("sim/weight[5]/selected"));
P6Ctls.addItem(Lbl_pyln6);

var Lbl_pyln4 = canvas.gui.widgets.Label.new(root, canvas.style, {} )
	.setText("P4:"~getprop("sim/weight[3]/selected"));
P4Ctls.addItem(Lbl_pyln4);

var Lbl_pyln10 = canvas.gui.widgets.Label.new(root, canvas.style, {} )
	.setText("P10:"~getprop("sim/weight[9]/selected"));
P10Ctls.addItem(Lbl_pyln10);

var Lbl_pyln2 = canvas.gui.widgets.Label.new(root, canvas.style, {} )
	.setText("P2:"~getprop("sim/weight[1]/selected"));
P2Ctls.addItem(Lbl_pyln2);

var Lbl_pyln1 = canvas.gui.widgets.Label.new(root, canvas.style, {} )
	.setText("P1:"~getprop("sim/weight/selected"));
P1Ctls.addItem(Lbl_pyln1);

var Lbl_pyln9 = canvas.gui.widgets.Label.new(root, canvas.style, {} )
	.setText("P9:"~getprop("sim/weight[8]/selected"));
P9Ctls.addItem(Lbl_pyln9);

var Lbl_pyln3 = canvas.gui.widgets.Label.new(root, canvas.style, {} )
	.setText("P3:"~getprop("sim/weight[2]/selected"));
P3Ctls.addItem(Lbl_pyln3);

var Lbl_pyln5 = canvas.gui.widgets.Label.new(root, canvas.style, {} )
	.setText("P5:"~getprop("sim/weight[4]/selected"));
P5Ctls.addItem(Lbl_pyln5);

var Lbl_pyln7 = canvas.gui.widgets.Label.new(root, canvas.style, {} )
	.setText("P7:"~getprop("sim/weight[6]/selected"));
P7Ctls.addItem(Lbl_pyln7);


var pylons_update = func{
	Lbl_pyln8.setText("P8: "~getprop("sim/weight[7]/selected"));
	Lbl_pyln6.setText("P6: "~getprop("sim/weight[5]/selected"));
	Lbl_pyln4.setText("P4: "~getprop("sim/weight[3]/selected"));
	Lbl_pyln10.setText("P10: "~getprop("sim/weight[9]/selected"));
	Lbl_pyln2.setText("P2: "~getprop("sim/weight[1]/selected"));
	Lbl_pyln1.setText("P1: "~getprop("sim/weight/selected"));
	Lbl_pyln9.setText("P9: "~getprop("sim/weight[8]/selected"));
	Lbl_pyln3.setText("P3: "~getprop("sim/weight[2]/selected"));
	Lbl_pyln5.setText("P5: "~getprop("sim/weight[4]/selected"));
	Lbl_pyln7.setText("P7: "~getprop("sim/weight[6]/selected"));
	}
###############################
######### Pylon8 ##############	
###############################

# click button P8:None
var btn_P8_empty = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("None")
        #.move(300, 300)
        .setFixedSize(90, 25);

btn_P8_empty.listen("clicked", func {
        # add code here to react on click on button.
		print("P8: None");
		setprop("sim/weight[7]/selected","None");
		setprop("fdm/jsbsim/inertia/pointmass-weight-lbs[7]",0.0);
		pylons_update();
		});
P8Ctls.addItem(btn_P8_empty);

# click button P8:R-73
var btn_P8_R_73 = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("R-73")
        #.move(300, 300)
        .setFixedSize(90, 25);

btn_P8_R_73.listen("clicked", func {
        # add code here to react on click on button.
		print("P8: R-73");
		setprop("sim/weight[7]/selected","R-73");
		setprop("/controls/armament/station[7]/release","false");
		setprop("fdm/jsbsim/inertia/pointmass-weight-lbs[7]",231.48); # R-73 = 105KG
		pylons_update();
		});
P8Ctls.addItem(btn_P8_R_73);

# click button P8:smoke-red
var btn_P8_smk_red = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("smoke: red")
        #.move(300, 300)
        .setFixedSize(90, 25);

btn_P8_smk_red.listen("clicked", func {
        # add code here to react on click on button.
		print("P8: smoke-red");
		setprop("sim/weight[7]/selected","smoke-red");
		setprop("/controls/armament/station[7]/release","false");
		setprop("fdm/jsbsim/inertia/pointmass-weight-lbs[7]",33); # WEIGHT HERE IS A GUESS !
		pylons_update();
		});
P8Ctls.addItem(btn_P8_smk_red);

# click button P8:smoke-yellow
var btn_P8_smk_yellw = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("smoke: yellow")
        #.move(300, 300)
        .setFixedSize(90, 25);

btn_P8_smk_yellw.listen("clicked", func {
        # add code here to react on click on button.
		print("P8: smoke-yellow");
		setprop("sim/weight[7]/selected","smoke-yellow");
		setprop("/controls/armament/station[7]/release","false");
		setprop("fdm/jsbsim/inertia/pointmass-weight-lbs[7]",33); # WEIGHT HERE IS A GUESS !
		pylons_update();
		});
P8Ctls.addItem(btn_P8_smk_yellw);

# click button P8:smoke-blue
var btn_P8_smk_blue = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("smoke: blue")
        #.move(300, 300)
        .setFixedSize(90, 25);

btn_P8_smk_blue.listen("clicked", func {
        # add code here to react on click on button.
		print("P8: smoke-blue");
		setprop("sim/weight[7]/selected","smoke-blue");
		setprop("/controls/armament/station[7]/release","false");
		setprop("fdm/jsbsim/inertia/pointmass-weight-lbs[7]",33); # WEIGHT HERE IS A GUESS !
		pylons_update();
		});
P8Ctls.addItem(btn_P8_smk_blue);
###############################
######### Pylon6 ##############	
###############################

# click button P6:None
var btn_P6_empty = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("None")
        #.move(300, 300)
        .setFixedSize(90, 25);

btn_P6_empty.listen("clicked", func {
        # add code here to react on click on button.
		print("P6: None");
		setprop("sim/weight[5]/selected","None");
		setprop("fdm/jsbsim/inertia/pointmass-weight-lbs[5]",0.0);
		pylons_update();
		});
P6Ctls.addItem(btn_P6_empty);

# click button P6:R-27R
var btn_P6_R27R = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("R-27R")
        #.move(300, 300)
        .setFixedSize(90, 25);

btn_P6_R27R.listen("clicked", func {
        # add code here to react on click on button.
		print("P6: R-27R");
		setprop("sim/weight[5]/selected","R-27R");
		setprop("/controls/armament/station[5]/release","false");
		setprop("fdm/jsbsim/inertia/pointmass-weight-lbs[5]",557.769); # R-27R = 253 KG
		pylons_update();
		});
P6Ctls.addItem(btn_P6_R27R);

# click button P6:R-27T
var btn_P6_R27T = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("R-27T")
        #.move(300, 300)
        .setFixedSize(90, 25);

btn_P6_R27T.listen("clicked", func {
        # add code here to react on click on button.
		print("P6: R-27T");
		setprop("sim/weight[5]/selected","R-27T");
		setprop("/controls/armament/station[5]/release","false");
		setprop("fdm/jsbsim/inertia/pointmass-weight-lbs[5]",559.974); # R-27T = 254 KG
		pylons_update();
		});
P6Ctls.addItem(btn_P6_R27T);

# click button P6:R-27ER
var btn_P6_R27ER = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("R-27ER")
        #.move(300, 300)
        .setFixedSize(90, 25);

btn_P6_R27ER.listen("clicked", func {
        # add code here to react on click on button.
		print("P6: R-27ER");
		setprop("sim/weight[5]/selected","R-27ER");
		setprop("/controls/armament/station[5]/release","false");
		setprop("fdm/jsbsim/inertia/pointmass-weight-lbs[5]",771.617); # R-27ER = 350 KG
		pylons_update();
		});
P6Ctls.addItem(btn_P6_R27ER);

# click button P6:R-27ET
var btn_P6_R27ET = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("R-27ET")
        #.move(300, 300)
        .setFixedSize(90, 25);

btn_P6_R27ET.listen("clicked", func {
        # add code here to react on click on button.
		print("P6: R-27ET");
		setprop("sim/weight[5]/selected","R-27ET");
		setprop("/controls/armament/station[5]/release","false");
		setprop("fdm/jsbsim/inertia/pointmass-weight-lbs[5]",756.185); # R-27ET = 343  KG
		pylons_update();
		});
P6Ctls.addItem(btn_P6_R27ET);

###############################
######### Pylon4 ##############	
###############################

# click button P4:None
var btn_P4_empty = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("None")
        #.move(300, 300)
        .setFixedSize(90, 25);

btn_P4_empty.listen("clicked", func {
        # add code here to react on click on button.
		print("P4: None");
		setprop("sim/weight[3]/selected","None");
		setprop("fdm/jsbsim/inertia/pointmass-weight-lbs[3]",0.0);
		pylons_update();
		});
P4Ctls.addItem(btn_P4_empty);

# click button P4:R-27R
var btn_P4_R27R = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("R-27R")
        #.move(300, 300)
        .setFixedSize(90, 25);

btn_P4_R27R.listen("clicked", func {
        # add code here to react on click on button.
		print("P4: R-27R");
		setprop("sim/weight[3]/selected","R-27R");
		setprop("/controls/armament/station[3]/release","false");
		setprop("fdm/jsbsim/inertia/pointmass-weight-lbs[3]",557.769); # R-27R = 253 KG
		pylons_update();
		});
P4Ctls.addItem(btn_P4_R27R);

# click button P4:R-27T
var btn_P4_R27T = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("R-27T")
        #.move(300, 300)
        .setFixedSize(90, 25);

btn_P4_R27T.listen("clicked", func {
        # add code here to react on click on button.
		print("P4: R-27T");
		setprop("sim/weight[3]/selected","R-27T");
		setprop("/controls/armament/station[3]/release","false");
		setprop("fdm/jsbsim/inertia/pointmass-weight-lbs[3]",559.974); # R-27T = 254 KG
		pylons_update();
		});
P4Ctls.addItem(btn_P4_R27T);

# click button P4:R-27ER
var btn_P4_R27ER = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("R-27ER")
        #.move(300, 300)
        .setFixedSize(90, 25);

btn_P4_R27ER.listen("clicked", func {
        # add code here to react on click on button.
		print("P4: R-27ER");
		setprop("sim/weight[3]/selected","R-27ER");
		setprop("/controls/armament/station[3]/release","false");
		setprop("fdm/jsbsim/inertia/pointmass-weight-lbs[3]",771.617); # R-27ER = 350 KG
		pylons_update();
		});
P4Ctls.addItem(btn_P4_R27ER);

# click button P4:R-27ET
var btn_P4_R27ET = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("R-27ET")
        #.move(300, 300)
        .setFixedSize(90, 25);

btn_P4_R27ET.listen("clicked", func {
        # add code here to react on click on button.
		print("P4: R-27ET");
		setprop("sim/weight[3]/selected","R-27ET");
		setprop("/controls/armament/station[3]/release","false");
		setprop("fdm/jsbsim/inertia/pointmass-weight-lbs[3]",756.185); # R-27ET = 343  KG
		pylons_update();
		});
P4Ctls.addItem(btn_P4_R27ET);

###############################
######### Pylon10 #############	
###############################

# click button P10:None
var btn_P10_empty = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("None")
        #.move(300, 300)
        .setFixedSize(90, 25);

btn_P10_empty.listen("clicked", func {
        # add code here to react on click on button.
		print("P10: None");
		setprop("sim/weight[9]/selected","None");
		setprop("fdm/jsbsim/inertia/pointmass-weight-lbs[9]",0.0);
		pylons_update();
		});
P10Ctls.addItem(btn_P10_empty);

# click button P10:R-27R
var btn_P10_R27R = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("R-27R")
        #.move(300, 300)
        .setFixedSize(90, 25);

btn_P10_R27R.listen("clicked", func {
        # add code here to react on click on button.
		print("P10: R-27R");
		setprop("sim/weight[9]/selected","R-27R");
		setprop("/controls/armament/station[9]/release","false");
		setprop("fdm/jsbsim/inertia/pointmass-weight-lbs[9]",557.769); # R-27R = 253 KG
		pylons_update();
		});
P10Ctls.addItem(btn_P10_R27R);

# click button P10:R-27T
var btn_P10_R27T = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("R-27T")
        #.move(300, 300)
        .setFixedSize(90, 25);

btn_P10_R27T.listen("clicked", func {
        # add code here to react on click on button.
		print("P10: R-27T");
		setprop("sim/weight[9]/selected","R-27T");
		setprop("/controls/armament/station[9]/release","false");
		setprop("fdm/jsbsim/inertia/pointmass-weight-lbs[9]",559.974); # R-27T = 254 KG
		pylons_update();
		});
P10Ctls.addItem(btn_P10_R27T);

# click button P10:R-27ER
var btn_P10_R27ER = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("R-27ER")
        #.move(300, 300)
        .setFixedSize(90, 25);

btn_P10_R27ER.listen("clicked", func {
        # add code here to react on click on button.
		print("P10: R-27ER");
		setprop("sim/weight[9]/selected","R-27ER");
		setprop("/controls/armament/station[9]/release","false");
		setprop("fdm/jsbsim/inertia/pointmass-weight-lbs[9]",771.617); # R-27ER = 350 KG
		pylons_update();
		});
P10Ctls.addItem(btn_P10_R27ER);

# click button P10:R-27ET
var btn_P10_R27ET = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("R-27ET")
        #.move(300, 300)
        .setFixedSize(90, 25);

btn_P10_R27ET.listen("clicked", func {
        # add code here to react on click on button.
		print("P10: R-27ET");
		setprop("sim/weight[9]/selected","R-27ET");
		setprop("/controls/armament/station[9]/release","false");
		setprop("fdm/jsbsim/inertia/pointmass-weight-lbs[9]",756.185); # R-27ET = 343  KG
		pylons_update();
		});
P10Ctls.addItem(btn_P10_R27ET);

var btn_P10_KH23 = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("Kh-23")
        #.move(300, 300)
        .setFixedSize(90, 25);

btn_P10_KH23.listen("clicked", func {
        # add code here to react on click on button.
		print("P10: Kh-23");
		setprop("sim/weight[9]/selected","Kh-23");
		setprop("/controls/armament/station[9]/release","false");
		setprop("fdm/jsbsim/inertia/pointmass-weight-lbs[9]",637.136); # R-27ET = 343  KG
		pylons_update();
		});
P10Ctls.addItem(btn_P10_KH23);

###############################
######### Pylon2 ##############	
###############################

# click button P2:None
var btn_P2_empty = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("None")
        #.move(300, 300)
        .setFixedSize(90, 25);

btn_P2_empty.listen("clicked", func {
        # add code here to react on click on button.
		print("P2: None");
		setprop("sim/weight[1]/selected","None");
		setprop("fdm/jsbsim/inertia/pointmass-weight-lbs[1]",0.0);
		pylons_update();
		});
P2Ctls.addItem(btn_P2_empty);

# click button P2:R-27R
var btn_P2_R27R = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("R-27R")
        #.move(300, 300)
        .setFixedSize(90, 25);

btn_P2_R27R.listen("clicked", func {
        # add code here to react on click on button.
		print("P2: R-27R");
		setprop("sim/weight[1]/selected","R-27R");
		setprop("/controls/armament/station[1]/release","false");
		setprop("fdm/jsbsim/inertia/pointmass-weight-lbs[1]",557.769); # R-27R = 253 KG
		pylons_update();
		});
P2Ctls.addItem(btn_P2_R27R);

# click button P2:R-27T
var btn_P2_R27T = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("R-27T")
        #.move(300, 300)
        .setFixedSize(90, 25);

btn_P2_R27T.listen("clicked", func {
        # add code here to react on click on button.
		print("P2: R-27T");
		setprop("sim/weight[1]/selected","R-27T");
		setprop("/controls/armament/station[1]/release","false");
		setprop("fdm/jsbsim/inertia/pointmass-weight-lbs[1]",559.974); # R-27T = 254 KG
		pylons_update();
		});
P2Ctls.addItem(btn_P2_R27T);

# click button P2:R-27ER
var btn_P2_R27ER = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("R-27ER")
        #.move(300, 300)
        .setFixedSize(90, 25);

btn_P2_R27ER.listen("clicked", func {
        # add code here to react on click on button.
		print("P2: R-27ER");
		setprop("sim/weight[1]/selected","R-27ER");
		setprop("/controls/armament/station[1]/release","false");
		setprop("fdm/jsbsim/inertia/pointmass-weight-lbs[1]",771.617); # R-27ER = 350 KG
		pylons_update();
		});
P2Ctls.addItem(btn_P2_R27ER);

# click button P2:R-27ET
var btn_P2_R27ET = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("R-27ET")
        #.move(300, 300)
        .setFixedSize(90, 25);

btn_P2_R27ET.listen("clicked", func {
        # add code here to react on click on button.
		print("P2: R-27ET");
		setprop("sim/weight[1]/selected","R-27ET");
		setprop("/controls/armament/station[1]/release","false");
		setprop("fdm/jsbsim/inertia/pointmass-weight-lbs[1]",756.185); # R-27ET = 343  KG
		pylons_update();
		});
P2Ctls.addItem(btn_P2_R27ET);

###############################
######### Pylon1 ##############	
###############################

# click button P1:None
var btn_P1_empty = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("None")
        #.move(300, 300)
        .setFixedSize(90, 25);

btn_P1_empty.listen("clicked", func {
        # add code here to react on click on button.
		print("P1: None");
		setprop("sim/weight/selected","None");
		setprop("fdm/jsbsim/inertia/pointmass-weight-lbs",0.0);
		pylons_update();
		});
P1Ctls.addItem(btn_P1_empty);

# click button P1:R-27R
var btn_P1_R27R = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("R-27R")
        #.move(300, 300)
        .setFixedSize(90, 25);

btn_P1_R27R.listen("clicked", func {
        # add code here to react on click on button.
		print("P1: R-27R");
		setprop("sim/weight/selected","R-27R");
		setprop("/controls/armament/station[0]/release","false");
		setprop("fdm/jsbsim/inertia/pointmass-weight-lbs",557.769); # R-27R = 253 KG
		pylons_update();
		});
P1Ctls.addItem(btn_P1_R27R);

# click button P1:R-27T
var btn_P1_R27T = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("R-27T")
        #.move(300, 300)
        .setFixedSize(90, 25);

btn_P1_R27T.listen("clicked", func {
        # add code here to react on click on button.
		print("P1: R-27T");
		setprop("sim/weight/selected","R-27T");
		setprop("/controls/armament/station[0]/release","false");
		setprop("fdm/jsbsim/inertia/pointmass-weight-lbs",559.974); # R-27T = 254 KG
		pylons_update();
		});
P1Ctls.addItem(btn_P1_R27T);

# click button P1:R-27ER
var btn_P1_R27ER = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("R-27ER")
        #.move(300, 300)
        .setFixedSize(90, 25);

btn_P1_R27ER.listen("clicked", func {
        # add code here to react on click on button.
		print("P1: R-27ER");
		setprop("sim/weight/selected","R-27ER");
		setprop("/controls/armament/station[0]/release","false");
		setprop("fdm/jsbsim/inertia/pointmass-weight-lbs",771.617); # R-27ER = 350 KG
		pylons_update();
		});
P1Ctls.addItem(btn_P1_R27ER);

# click button P1:R-27ET
var btn_P1_R27ET = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("R-27ET")
        #.move(300, 300)
        .setFixedSize(90, 25);

btn_P1_R27ET.listen("clicked", func {
        # add code here to react on click on button.
		print("P1: R-27ET");
		setprop("sim/weight/selected","R-27ET");
		setprop("/controls/armament/station[0]/release","false");
		setprop("fdm/jsbsim/inertia/pointmass-weight-lbs",756.185); # R-27ET = 343  KG
		pylons_update();
		});
P1Ctls.addItem(btn_P1_R27ET);

###############################
######### Pylon9 ##############	
###############################

# click button P9:None
var btn_P9_empty = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("None")
        #.move(300, 300)
        .setFixedSize(90, 25);

btn_P9_empty.listen("clicked", func {
        # add code here to react on click on button.
		print("P9: None");
		setprop("sim/weight[8]/selected","None");
		setprop("fdm/jsbsim/inertia/pointmass-weight-lbs[8]",0.0);
		pylons_update();
		});
P9Ctls.addItem(btn_P9_empty);

# click button P9:R-27R
var btn_P9_R27R = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("R-27R")
        #.move(300, 300)
        .setFixedSize(90, 25);

btn_P9_R27R.listen("clicked", func {
        # add code here to react on click on button.
		print("P9: R-27R");
		setprop("sim/weight[8]/selected","R-27R");
		setprop("/controls/armament/station[8]/release","false");
		setprop("fdm/jsbsim/inertia/pointmass-weight-lbs[8]",557.769); # R-27R = 253 KG
		pylons_update();
		});
P9Ctls.addItem(btn_P9_R27R);

# click button P9:R-27T
var btn_P9_R27T = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("R-27T")
        #.move(300, 300)
        .setFixedSize(90, 25);

btn_P9_R27T.listen("clicked", func {
        # add code here to react on click on button.
		print("P9: R-27T");
		setprop("sim/weight[8]/selected","R-27T");
		setprop("/controls/armament/station[8]/release","false");
		setprop("fdm/jsbsim/inertia/pointmass-weight-lbs[8]",559.974); # R-27T = 254 KG
		pylons_update();
		});
P9Ctls.addItem(btn_P9_R27T);

# click button P9:R-27ER
var btn_P9_R27ER = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("R-27ER")
        #.move(300, 300)
        .setFixedSize(90, 25);

btn_P9_R27ER.listen("clicked", func {
        # add code here to react on click on button.
		print("P9: R-27ER");
		setprop("sim/weight[8]/selected","R-27ER");
		setprop("/controls/armament/station[8]/release","false");
		setprop("fdm/jsbsim/inertia/pointmass-weight-lbs[8]",771.617); # R-27ER = 350 KG
		pylons_update();
		});
P9Ctls.addItem(btn_P9_R27ER);

# click button P9:R-27ET
var btn_P9_R27ET = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("R-27ET")
        #.move(300, 300)
        .setFixedSize(90, 25);

btn_P9_R27ET.listen("clicked", func {
        # add code here to react on click on button.
		print("P9: R-27ET");
		setprop("sim/weight[8]/selected","R-27ET");
		setprop("/controls/armament/station[8]/release","false");
		setprop("fdm/jsbsim/inertia/pointmass-weight-lbs[8]",756.185); # R-27ET = 343  KG
		pylons_update();
		});
P9Ctls.addItem(btn_P9_R27ET);

var btn_P9_KH23 = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("Kh-23")
        #.move(300, 300)
        .setFixedSize(90, 25);

btn_P9_KH23.listen("clicked", func {
        # add code here to react on click on button.
		print("P9: Kh-23");
		setprop("sim/weight[8]/selected","Kh-23");
		setprop("/controls/armament/station[8]/release","false");
		setprop("fdm/jsbsim/inertia/pointmass-weight-lbs[8]",637.136); # R-27ET = 343  KG
		pylons_update();
		});
P9Ctls.addItem(btn_P9_KH23);

###############################
######### Pylon3 ##############	
###############################

# click button P3:None
var btn_P3_empty = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("None")
        #.move(300, 300)
        .setFixedSize(90, 25);

btn_P3_empty.listen("clicked", func {
        # add code here to react on click on button.
		print("P3: None");
		setprop("sim/weight[2]/selected","None");
		setprop("fdm/jsbsim/inertia/pointmass-weight-lbs[2]",0.0);
		pylons_update();
		});
P3Ctls.addItem(btn_P3_empty);

# click button P3:R-27R
var btn_P3_R27R = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("R-27R")
        #.move(300, 300)
        .setFixedSize(90, 25);

btn_P3_R27R.listen("clicked", func {
        # add code here to react on click on button.
		print("P3: R-27R");
		setprop("sim/weight[2]/selected","R-27R");
		setprop("/controls/armament/station[2]/release","false");
		setprop("fdm/jsbsim/inertia/pointmass-weight-lbs[2]",557.769); # R-27R = 253 KG
		pylons_update();
		});
P3Ctls.addItem(btn_P3_R27R);

# click button P3:R-27T
var btn_P3_R27T = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("R-27T")
        #.move(300, 300)
        .setFixedSize(90, 25);

btn_P3_R27T.listen("clicked", func {
        # add code here to react on click on button.
		print("P3: R-27T");
		setprop("sim/weight[2]/selected","R-27T");
		setprop("/controls/armament/station[2]/release","false");
		setprop("fdm/jsbsim/inertia/pointmass-weight-lbs[2]",559.974); # R-27T = 254 KG
		pylons_update();
		});
P3Ctls.addItem(btn_P3_R27T);

# click button P3:R-27ER
var btn_P3_R27ER = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("R-27ER")
        #.move(300, 300)
        .setFixedSize(90, 25);

btn_P3_R27ER.listen("clicked", func {
        # add code here to react on click on button.
		print("P3: R-27ER");
		setprop("sim/weight[2]/selected","R-27ER");
		setprop("/controls/armament/station[2]/release","false");
		setprop("fdm/jsbsim/inertia/pointmass-weight-lbs[2]",771.617); # R-27ER = 350 KG
		pylons_update();
		});
P3Ctls.addItem(btn_P3_R27ER);

# click button P3:R-27ET
var btn_P3_R27ET = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("R-27ET")
        #.move(300, 300)
        .setFixedSize(90, 25);

btn_P3_R27ET.listen("clicked", func {
        # add code here to react on click on button.
		print("P3: R-27ET");
		setprop("sim/weight[2]/selected","R-27ET");
		setprop("/controls/armament/station[2]/release","false");
		setprop("fdm/jsbsim/inertia/pointmass-weight-lbs[2]",756.185); # R-27ET = 343  KG
		pylons_update();
		});
P3Ctls.addItem(btn_P3_R27ET);

###############################
######### Pylon5 ##############	
###############################

# click button P5:None
var btn_P5_empty = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("None")
        #.move(300, 300)
        .setFixedSize(90, 25);

btn_P5_empty.listen("clicked", func {
        # add code here to react on click on button.
		print("P5: None");
		setprop("sim/weight[4]/selected","None");
		setprop("fdm/jsbsim/inertia/pointmass-weight-lbs[4]",0.0);
		pylons_update();
		});
P5Ctls.addItem(btn_P5_empty);

# click button P5:R-27R
var btn_P5_R27R = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("R-27R")
        #.move(300, 300)
        .setFixedSize(90, 25);

btn_P5_R27R.listen("clicked", func {
        # add code here to react on click on button.
		print("P5: R-27R");
		setprop("sim/weight[4]/selected","R-27R");
		setprop("/controls/armament/station[4]/release","false");
		setprop("fdm/jsbsim/inertia/pointmass-weight-lbs[4]",557.769); # R-27R = 253 KG
		pylons_update();
		});
P5Ctls.addItem(btn_P5_R27R);

# click button P5:R-27T
var btn_P5_R27T = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("R-27T")
        #.move(300, 300)
        .setFixedSize(90, 25);

btn_P5_R27T.listen("clicked", func {
        # add code here to react on click on button.
		print("P5: R-27T");
		setprop("sim/weight[4]/selected","R-27T");
		setprop("/controls/armament/station[4]/release","false");
		setprop("fdm/jsbsim/inertia/pointmass-weight-lbs[4]",559.974); # R-27T = 254 KG
		pylons_update();
		});
P5Ctls.addItem(btn_P5_R27T);

# click button P5:R-27ER
var btn_P5_R27ER = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("R-27ER")
        #.move(300, 300)
        .setFixedSize(90, 25);

btn_P5_R27ER.listen("clicked", func {
        # add code here to react on click on button.
		print("P5: R-27ER");
		setprop("sim/weight[4]/selected","R-27ER");
		setprop("/controls/armament/station[4]/release","false");
		setprop("fdm/jsbsim/inertia/pointmass-weight-lbs[4]",771.617); # R-27ER = 350 KG
		pylons_update();
		});
P5Ctls.addItem(btn_P5_R27ER);

# click button P5:R-27ET
var btn_P5_R27ET = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("R-27ET")
        #.move(300, 300)
        .setFixedSize(90, 25);

btn_P5_R27ET.listen("clicked", func {
        # add code here to react on click on button.
		print("P5: R-27ET");
		setprop("sim/weight[4]/selected","R-27ET");
		setprop("/controls/armament/station[4]/release","false");
		setprop("fdm/jsbsim/inertia/pointmass-weight-lbs[4]",756.185); # R-27ET = 343  KG
		pylons_update();
		});
P5Ctls.addItem(btn_P5_R27ET);

###############################
######### Pylon7 ##############	
###############################

# click button P7:None
var btn_P7_empty = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("None")
        #.move(300, 300)
        .setFixedSize(90, 25);

btn_P7_empty.listen("clicked", func {
        # add code here to react on click on button.
		print("P7: None");
		setprop("sim/weight[6]/selected","None");
		setprop("fdm/jsbsim/inertia/pointmass-weight-lbs[6]",0.0);
		pylons_update();
		});
P7Ctls.addItem(btn_P7_empty);
	
# click button P7:R-73
var btn_P7_R_73 = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("R-73")
        #.move(300, 300)
        .setFixedSize(90, 25);

btn_P7_R_73.listen("clicked", func {
        # add code here to react on click on button.
		print("P7: R-73");
		setprop("sim/weight[6]/selected","R-73");
		setprop("/controls/armament/station[6]/release","false");
		setprop("fdm/jsbsim/inertia/pointmass-weight-lbs[6]",231.48); # R-73 = 105KG
		pylons_update();
		});
P7Ctls.addItem(btn_P7_R_73);

# click button P7:smoke-red
var btn_P7_smk_red = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("smoke: red")
        #.move(300, 300)
        .setFixedSize(90, 25);

btn_P7_smk_red.listen("clicked", func {
        # add code here to react on click on button.
		print("P7: smoke-red");
		setprop("sim/weight[6]/selected","smoke-red");
		setprop("/controls/armament/station[6]/release","false");
		setprop("fdm/jsbsim/inertia/pointmass-weight-lbs[6]",33); # WEIGHT HERE IS A GUESS !
		pylons_update();
		});
P7Ctls.addItem(btn_P7_smk_red);

# click button P7:smoke-yellow
var btn_P7_smk_yellw = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("smoke: yellow")
        #.move(300, 300)
        .setFixedSize(90, 25);

btn_P7_smk_yellw.listen("clicked", func {
        # add code here to react on click on button.
		print("P7: smoke-yellow");
		setprop("sim/weight[6]/selected","smoke-yellow");
		setprop("/controls/armament/station[6]/release","false");
		setprop("fdm/jsbsim/inertia/pointmass-weight-lbs[6]",33); # WEIGHT HERE IS A GUESS !
		pylons_update();
		});
P7Ctls.addItem(btn_P7_smk_yellw);

# click button P7:smoke-blue
var btn_P7_smk_blue = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("smoke: blue")
        #.move(300, 300)
        .setFixedSize(90, 25);

btn_P7_smk_blue.listen("clicked", func {
        # add code here to react on click on button.
		print("P7: smoke-blue");
		setprop("sim/weight[6]/selected","smoke-blue");
		setprop("/controls/armament/station[6]/release","false");
		setprop("fdm/jsbsim/inertia/pointmass-weight-lbs[6]",33); # WEIGHT HERE IS A GUESS !
		pylons_update();
		});
P7Ctls.addItem(btn_P7_smk_blue);


var statusbar =canvas.HBoxLayout.new();
mainVBox.addItem(statusbar);

var version=canvas.gui.widgets.Label.new(root, canvas.style, {wordWrap: 0});
version.setText("FlightGear v" ~ getprop("/sim/version/flightgear"));
statusbar.addItem(version);

var Acversion=canvas.gui.widgets.Label.new(root, canvas.style, {wordWrap: 0});
Acversion.setText("Su-27 v0.2                            Yanes Bechir 2016");
statusbar.addItem(Acversion);

}
