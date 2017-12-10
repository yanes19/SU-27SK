var showRSBN_Dlg = func{
var (width,height) = (500,350);
var title = 'Su-27SK : PU-184 ARC Nav Radio inputs';
var window = canvas.Window.new([width,height],"dialog").set('title',title);
var myCanvas = window.createCanvas().set("background", canvas.style.getColor("bg_color"));
var root = myCanvas.createGroup();
var mainVBox = canvas.VBoxLayout.new();
myCanvas.setLayout(mainVBox);

var Hbox1 = canvas.HBoxLayout.new();
mainVBox.addItem(Hbox1);

var Hbox10 = canvas.HBoxLayout.new();
mainVBox.addItem(Hbox10);

var Hbox2 = canvas.HBoxLayout.new();
mainVBox.addItem(Hbox2);

var Hbox3 = canvas.HBoxLayout.new();
mainVBox.addItem(Hbox3);

var Hbox4 = canvas.HBoxLayout.new();
mainVBox.addItem(Hbox4);

var Hbox5 = canvas.HBoxLayout.new();
mainVBox.addItem(Hbox5);

var Hbox6 = canvas.HBoxLayout.new();
mainVBox.addItem(Hbox6);

var Hbox7 = canvas.HBoxLayout.new();
mainVBox.addItem(Hbox7);

var Hbox8 = canvas.HBoxLayout.new();
mainVBox.addItem(Hbox8);

var Hbox9 = canvas.HBoxLayout.new();
mainVBox.addItem(Hbox9);



var infos =	canvas.gui.widgets.Label.new(root, canvas.style, {} )
	.setText("PU-184 Nav radio settings ");
Hbox1.addItem(infos);

var NPN_Lbl =	canvas.gui.widgets.Label.new(root, canvas.style, {} )
	.setText("NPN Station (NPN) :");

var NPN_edit =	canvas.gui.widgets.LineEdit.new(root, canvas.style, {} )
	.setText(getprop("su-27/instrumentation/PU-184/NPN"))
	.setFixedSize(120,25);
	
var NPN_LblSpacer = canvas.gui.widgets.Label.new(root, canvas.style, {} )
	.setText("_________");


var NPN_btn = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("Set")
        #.move(300, 300)
        .setFixedSize(90, 25);
NPN_btn.listen("clicked", func {
        # add code here to react on click on button.
		#print(NPN_edit.text());
		setprop("su-27/instrumentation/PU-184/NPN",NPN_edit.text());
		navaid = findNavaidByFrequency(NPN_edit.text()/10);
		NPN_LblSpacer.setText(navaid.name);
		#pylons_update();
		});
Hbox10.addItem(NPN_Lbl);	
Hbox10.addItem(NPN_edit);
Hbox10.addItem(NPN_btn);
Hbox10.addItem(NPN_LblSpacer);	

var PPM1_Lbl =	canvas.gui.widgets.Label.new(root, canvas.style, {} )
	.setText("Station 1 (PPM1) :");

var PPM1_edit =	canvas.gui.widgets.LineEdit.new(root, canvas.style, {} )
	.setText(getprop("su-27/instrumentation/PU-184/PPM1"))
	.setFixedSize(120,25);
	
var PPM1_LblSpacer = canvas.gui.widgets.Label.new(root, canvas.style, {} )
	.setText("_________");


var PPM1_btn = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("Set")
        .setFixedSize(90, 25);
PPM1_btn.listen("clicked", func {
        # add code here to react on click on button.
		print(PPM1_edit.text());
		setprop("su-27/instrumentation/PU-184/PPM1",PPM1_edit.text());
		navaid = findNavaidByFrequency(PPM1_edit.text()/10);
		PPM1_LblSpacer.setText(navaid.name);
		});
Hbox2.addItem(PPM1_Lbl);	
Hbox2.addItem(PPM1_edit);
Hbox2.addItem(PPM1_btn);
Hbox2.addItem(PPM1_LblSpacer);

var PPM2_Lbl =	canvas.gui.widgets.Label.new(root, canvas.style, {} )
	.setText("Station 2 (PPM2) :");

var PPM2_edit =	canvas.gui.widgets.LineEdit.new(root, canvas.style, {} )
	.setText(getprop("su-27/instrumentation/PU-184/PPM2"))
	.setFixedSize(120,25);
	
var PPM2_LblSpacer = canvas.gui.widgets.Label.new(root, canvas.style, {} )
	.setText("_________");


var PPM2_btn = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("Set")
        .setFixedSize(90, 25);
PPM2_btn.listen("clicked", func {
        # add code here to react on click on button.
		setprop("su-27/instrumentation/PU-184/PPM2",PPM2_edit.text());
		navaid = findNavaidByFrequency(PPM2_edit.text()/10);
		PPM2_LblSpacer.setText(navaid.name);
		});
Hbox3.addItem(PPM2_Lbl);	
Hbox3.addItem(PPM2_edit);
Hbox3.addItem(PPM2_btn);
Hbox3.addItem(PPM2_LblSpacer);

var PPM3_Lbl =	canvas.gui.widgets.Label.new(root, canvas.style, {} )
	.setText("Station 3 (PPM3) :");

var PPM3_edit =	canvas.gui.widgets.LineEdit.new(root, canvas.style, {} )
	.setText(getprop("su-27/instrumentation/PU-184/PPM3"))
	.setFixedSize(120,25);
	
var PPM3_LblSpacer = canvas.gui.widgets.Label.new(root, canvas.style, {} )
	.setText("_________");


var PPM3_btn = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("Set")
        .setFixedSize(90, 25);
PPM3_btn.listen("clicked", func {
        # add code here to react on click on button.
		setprop("su-27/instrumentation/PU-184/PPM3",PPM3_edit.text());
		navaid = findNavaidByFrequency(PPM3_edit.text()/10);
		PPM3_LblSpacer.setText(navaid.name);
		});
Hbox4.addItem(PPM3_Lbl);	
Hbox4.addItem(PPM3_edit);
Hbox4.addItem(PPM3_btn);
Hbox4.addItem(PPM3_LblSpacer);

var PPM4_Lbl =	canvas.gui.widgets.Label.new(root, canvas.style, {} )
	.setText("Station 4 (PPM4) :");

var PPM4_edit =	canvas.gui.widgets.LineEdit.new(root, canvas.style, {} )
	.setText(getprop("su-27/instrumentation/PU-184/PPM4"))
	.setFixedSize(120,25);
	
var PPM4_LblSpacer = canvas.gui.widgets.Label.new(root, canvas.style, {} )
	.setText("_________");


var PPM4_btn = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("Set")
        .setFixedSize(90, 25);
PPM4_btn.listen("clicked", func {
        # add code here to react on click on button.
		setprop("su-27/instrumentation/PU-184/PPM4",PPM4_edit.text());
		navaid = findNavaidByFrequency(PPM4_edit.text()/10);
		PPM4_LblSpacer.setText(navaid.name);
		});
Hbox5.addItem(PPM4_Lbl);	
Hbox5.addItem(PPM4_edit);
Hbox5.addItem(PPM4_btn);
Hbox5.addItem(PPM4_LblSpacer);


var PPM5_Lbl =	canvas.gui.widgets.Label.new(root, canvas.style, {} )
	.setText("Station 5 (PPM5) :");

var PPM5_edit =	canvas.gui.widgets.LineEdit.new(root, canvas.style, {} )
	.setText(getprop("su-27/instrumentation/PU-184/PPM5"))
	.setFixedSize(120,25);
	
var PPM5_LblSpacer = canvas.gui.widgets.Label.new(root, canvas.style, {} )
	.setText("_________");


var PPM5_btn = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("Set")
        .setFixedSize(90, 25);
PPM5_btn.listen("clicked", func {
		setprop("su-27/instrumentation/PU-184/PPM5",PPM5_edit.text());
		navaid = findNavaidByFrequency(PPM5_edit.text()/10);
		PPM5_LblSpacer.setText(navaid.name);
		});
Hbox6.addItem(PPM5_Lbl);	
Hbox6.addItem(PPM5_edit);
Hbox6.addItem(PPM5_btn);
Hbox6.addItem(PPM5_LblSpacer);

var PPM6_Lbl =	canvas.gui.widgets.Label.new(root, canvas.style, {} )
	.setText("Station 6 (PPM6) :");

var PPM6_edit =	canvas.gui.widgets.LineEdit.new(root, canvas.style, {} )
	.setText(getprop("su-27/instrumentation/PU-184/PPM6"))
	.setFixedSize(120,25);
	
var PPM6_LblSpacer = canvas.gui.widgets.Label.new(root, canvas.style, {} )
	.setText("_________");


var PPM6_btn = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("Set")
        .setFixedSize(90, 25);
PPM6_btn.listen("clicked", func {
		setprop("su-27/instrumentation/PU-184/PPM6",PPM6_edit.text());
		navaid = findNavaidByFrequency(PPM6_edit.text()/10);
		PPM6_LblSpacer.setText(navaid.name);
		});
Hbox7.addItem(PPM6_Lbl);	
Hbox7.addItem(PPM6_edit);
Hbox7.addItem(PPM6_btn);
Hbox7.addItem(PPM6_LblSpacer);

var PPM7_Lbl =	canvas.gui.widgets.Label.new(root, canvas.style, {} )
	.setText("Station 7 (PPM7) :");

var PPM7_edit =	canvas.gui.widgets.LineEdit.new(root, canvas.style, {} )
	.setText(getprop("su-27/instrumentation/PU-184/PPM7"))
	.setFixedSize(120,25);
	
var PPM7_LblSpacer = canvas.gui.widgets.Label.new(root, canvas.style, {} )
	.setText("_________");


var PPM7_btn = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("Set")
        .setFixedSize(90, 25);
PPM7_btn.listen("clicked", func {
		setprop("su-27/instrumentation/PU-184/PPM7",PPM7_edit.text());
		navaid = findNavaidByFrequency(PPM7_edit.text()/10);
		PPM7_LblSpacer.setText(navaid.name);
		});
Hbox8.addItem(PPM7_Lbl);	
Hbox8.addItem(PPM7_edit);
Hbox8.addItem(PPM7_btn);
Hbox8.addItem(PPM7_LblSpacer);

var PPM8_Lbl =	canvas.gui.widgets.Label.new(root, canvas.style, {} )
	.setText("Station 8 (PPM8) :");

var PPM8_edit =	canvas.gui.widgets.LineEdit.new(root, canvas.style, {} )
	.setText(getprop("su-27/instrumentation/PU-184/PPM8"))
	.setFixedSize(120,25);
	
var PPM8_LblSpacer = canvas.gui.widgets.Label.new(root, canvas.style, {} )
	.setText("_________");


var PPM8_btn = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("Set")
        .setFixedSize(90, 25);
PPM8_btn.listen("clicked", func {
		setprop("su-27/instrumentation/PU-184/PPM8",PPM8_edit.text());
		navaid = findNavaidByFrequency(PPM8_edit.text()/10);
		PPM8_LblSpacer.setText(navaid.name);
		});
Hbox9.addItem(PPM8_Lbl);	
Hbox9.addItem(PPM8_edit);
Hbox9.addItem(PPM8_btn);
Hbox9.addItem(PPM8_LblSpacer);


}
