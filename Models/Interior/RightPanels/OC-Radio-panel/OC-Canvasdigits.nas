
print ("OC Digits display loaded!!");

# create the AER digits canvas
var AERdigits_canvas= canvas.new({
                "name": "AER-Digits",
                    "size": [256,256], 
                    "view": [256,256],                        
                    "mipmapping": 0     
                    });
   AERdigits_canvas.addPlacement({"node": "AER.Digits"});
   AERdigits_canvas.setColorBackground(0,0,0,0);
   var root = AERdigits_canvas.createGroup();

# create AER digits text
   var AERdigits = root.createChild("text")
   .setText("000")
   .setColor(1,0.5,0.1)
   .setFontSize(24)
   .setScale(2.5,6)
   .setFont("DSEG/DSEG7/Classic-MINI/DSEG7ClassicMini-Bold.ttf")
   .setAlignment("center-bottom")
   .setTranslation(130, 210);
   
# create AER digits Shading text
   var AERdigitsSHADE = root.createChild("text")
   .setText("0")
   .setColor(1,0.5,0.1)
   .setFontSize(24)
   .setScale(2.5,6)
   .setFont("DSEG/DSEG7/Classic-MINI/DSEG7ClassicMini-Bold.ttf")
   .setAlignment("center-bottom")
   .setTranslation(130, 210)
   .set("fill", "rgba(255,127,25,0.5)");



var PPMdigits_canvas= canvas.new({
                "name": "PPM-Digits",
                    "size": [256,256], 
                    "view": [256,256],                        
                    "mipmapping": 0     
                    });


   PPMdigits_canvas.addPlacement({"node": "PPM-Digits"});	# assign the canvas to the surface in the 3d model
   PPMdigits_canvas.setColorBackground(0,0,0,0);	# set background color
   var root = PPMdigits_canvas.createGroup();	# create a group to add elements to the canvas
   var PPMDigits = root.createChild("text")	# create PPM digits text
   .setText("0")
   .setColor(1,0.5,0.1)
   .setFontSize(24)
   .setScale(2.5,6)
   .setFont("DSEG/DSEG7/Classic-MINI/DSEG7ClassicMini-Bold.ttf")
   .setAlignment("center-bottom")
   .setTranslation(130, 210);
   
# create PPM digits Shading text

   var PPMDigitsShade = root.createChild("text")
   .setText("0")
   .setColor(1,0.5,0.1)
   .setFontSize(24)
   .setScale(2.5,6)
   .setFont("DSEG/DSEG7/Classic-MINI/DSEG7ClassicMini-Bold.ttf")
   .setAlignment("center-bottom")
   .setTranslation(130, 210)
   .set("fill", "rgba(255,127,25,0.5)");
	

# create the WPTs RM canvas
var RMdigits_canvas= canvas.new({
                "name": "RM-Digits",
                    "size": [256,256], 
                    "view": [256,256],                        
                    "mipmapping": 0     
                    });
   RMdigits_canvas.addPlacement({"node": "WPT-RM-Digits"});
   RMdigits_canvas.setColorBackground(0,0,0,0);
   var root = RMdigits_canvas.createGroup();

# create RM digits text
   var RMDigits = root.createChild("text")
   .setText("000")
   .setColor(1,0.5,0.1)
   .setFontSize(24)
   .setScale(2.5,6)
   .setFont("DSEG/DSEG7/Classic-MINI/DSEG7ClassicMini-Bold.ttf")
   .setAlignment("center-bottom")
   .setTranslation(130, 210);
   
# create RM digits Shading text
   var RMDigitsShade = root.createChild("text")
   .setText("000")
   .setColor(1,0.5,0.1)
   .setFontSize(24)
   .setScale(2.5,6)
   .setFont("DSEG/DSEG7/Classic-MINI/DSEG7ClassicMini-Bold.ttf")
   .setAlignment("center-bottom")
   .setTranslation(130, 210)
   .set("fill", "rgba(255,127,25,0.5)");
	


var loop = func() {
	 var ActivePPM = getprop("su-27/instrumentation/RSBN/active-PPM");
	    PPMDigits.setText(sprintf("%d",ActivePPM));
	    if(getprop("su-27/instrumentation/OC-controller/status") == 3)
	    {
			PPMDigits.setVisible(getprop("su-27/instrumentation/flasher-anim"));
	    }	    else {(PPMDigits.setVisible(1));}
	 var ActiveWPT = getprop("su-27/instrumentation/OC-controller/active-wpt");
	    RMDigits.setText(sprintf("%03d",ActiveWPT));
	    if(getprop("su-27/instrumentation/OC-controller/status") == 7)
	    {
			RMDigits.setVisible(getprop("su-27/instrumentation/flasher-anim"));
	    }	else{(RMDigits.setVisible(1));}
	    
	 var ActiveAER = getprop("su-27/instrumentation/RSBN/active-AER");
	    AERdigits.setText(sprintf("%d",ActiveAER));
	    if(getprop("su-27/instrumentation/OC-controller/status") == 5)
	    {
#			setprop("su-27/instrumentation/flasher-anim",1);
			AERdigits.setVisible(getprop("su-27/instrumentation/flasher-anim"));
	    }	else{(AERdigits.setVisible(1))}
	}

var myTimer = maketimer(0.2, loop);
myTimer.start();

