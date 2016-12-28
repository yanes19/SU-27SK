var showHelpDlg = func{
var (width,height) = (800,450);
var title = 'Su-27SK fighter Soviet/Russianaircraft ';
var window = canvas.Window.new([width,height],"dialog").set('title',title);
var myCanvas = window.createCanvas().set("background", canvas.style.getColor("bg_color"));
var root = myCanvas.createGroup();
var myVBox = canvas.VBoxLayout.new();
myCanvas.setLayout(myVBox);
 
var DlgBody = canvas.VBoxLayout.new();
myVBox.addItem(DlgBody);

var mfd = canvas.gui.widgets.Label.new(root, canvas.style, {} )
	# this could also be another Canvas: http://wiki.flightgear.org/Howto:Using_raster_images_and_nested_canvases#Example:_Loading_a_Canvas_dynamically
	.setImage("Aircraft/SU-27SK/Dialogs/Su-27-intro.png");
myVBox.addItem(mfd);

	
var infos =	canvas.gui.widgets.Label.new(root, canvas.style, {} )
	.setText("Su-27 inline help : \n\n"~
			"Su-27 is spawn with 50% of maximum carried fuel \n"~
			"FCS implemented and almost fully working . \n" ~
			"Autopilot supports several navigation modes in addition to autolanding mode. \n" ~
			"Direct input mode :FBW off , allowing arobatic manoeuvers especially the Cobra.");
	
	
myVBox.addItem(infos);
}
