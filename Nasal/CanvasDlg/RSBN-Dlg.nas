var showRSBN_Dlg = func{
var (width,height) = (500,450);
var title = 'Su-27SK : RSBN Nav Radio inputs';
var window = canvas.Window.new([width,height],"dialog").set('title',title);
var myCanvas = window.createCanvas().set("background", canvas.style.getColor("bg_color"));
var root = myCanvas.createGroup();
var mainVBox = canvas.VBoxLayout.new();
myCanvas.setLayout(mainVBox);

var Hbox1 = canvas.HBoxLayout.new();
mainVBox.addItem(Hbox1);

var Hbox10 = canvas.HBoxLayout.new();
mainVBox.addItem(Hbox10);

var Hbox11 = canvas.HBoxLayout.new();
mainVBox.addItem(Hbox11);

var Hbox12 = canvas.HBoxLayout.new();
mainVBox.addItem(Hbox12);

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

var navaid = nil;

var infos =	canvas.gui.widgets.Label.new(root, canvas.style, {} )
	.setText("RSBN Nav radio settings ");
Hbox1.addItem(infos);
###RSBN dialog need fix problem indentified in AER1 container ,
### removing NPN widgets  from the script make it normal
var AER1_Lbl =	canvas.gui.widgets.Label.new(root, canvas.style, {} )
	.setText("Main dest. airfield (AER1):      ");

var AER1_edit =	canvas.gui.widgets.LineEdit.new(root, canvas.style, {} )
	.setText(getprop("su-27/instrumentation/RSBN/AER"))
	.setFixedSize(120,25);
	
var AER1_LblSpacer = canvas.gui.widgets.Label.new(root, canvas.style, {} )
	.setText("_________");


var AER1_btn = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("Set")
        #.move(300, 300)
        .setFixedSize(90, 25);
AER1_btn.listen("clicked", func {
        # add code here to react on click on button.
		#print(AER1_edit.text());
		setprop("su-27/instrumentation/RSBN/AER",AER1_edit.text());
		navaid = findNavaidByFrequency(AER1_edit.text()/10);
		AER1_LblSpacer.setText(navaid.name);
		#pylons_update();
		});
Hbox10.addItem(AER1_Lbl);	
Hbox10.addItem(AER1_edit);
Hbox10.addItem(AER1_btn);
Hbox10.addItem(AER1_LblSpacer);	
# AER2 AREA :
var AER2_Lbl =	canvas.gui.widgets.Label.new(root, canvas.style, {} )
	.setText("Alternate dest. airfield (AER2):");

var AER2_edit =	canvas.gui.widgets.LineEdit.new(root, canvas.style, {} )
	.setText(getprop("su-27/instrumentation/RSBN/AER-alt"))
	.setFixedSize(120,25);
	
var AER2_LblSpacer = canvas.gui.widgets.Label.new(root, canvas.style, {} )
	.setText("_________");


var AER2_btn = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("Set")
        #.move(300, 300)
        .setFixedSize(90, 25);
AER2_btn.listen("clicked", func {
        # add code here to react on click on button.
		#print(AER2_edit.text());
		setprop("su-27/instrumentation/RSBN/AER-alt",AER2_edit.text());
		navaid = findNavaidByFrequency(AER2_edit.text()/10);
		AER2_LblSpacer.setText(navaid.name);
		#pylons_update();
		});
Hbox11.addItem(AER2_Lbl);	
Hbox11.addItem(AER2_edit);
Hbox11.addItem(AER2_btn);
Hbox11.addItem(AER2_LblSpacer);	
##AER3 AREA :
var AER3_Lbl =	canvas.gui.widgets.Label.new(root, canvas.style, {} )
	.setText("Backup dest. airfield (AER3):   ");

var AER3_edit =	canvas.gui.widgets.LineEdit.new(root, canvas.style, {} )
	.setText(getprop("su-27/instrumentation/RSBN/AER-alt2"))
	.setFixedSize(120,25);
	
var AER3_LblSpacer = canvas.gui.widgets.Label.new(root, canvas.style, {} )
	.setText("_________");


var AER3_btn = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("Set")
        #.move(300, 300)
        .setFixedSize(90, 25);
AER3_btn.listen("clicked", func {
        # add code here to react on click on button.
		#print(AER3_edit.text());
		setprop("su-27/instrumentation/RSBN/AER-alt2",AER3_edit.text());
		navaid = findNavaidByFrequency(AER3_edit.text()/10);
		AER3_LblSpacer.setText(navaid.name);
		#pylons_update();
		});
Hbox12.addItem(AER3_Lbl);	
Hbox12.addItem(AER3_edit);
Hbox12.addItem(AER3_btn);
Hbox12.addItem(AER3_LblSpacer);	
##### NOW THE PPMS :
var PPM1_Lbl =	canvas.gui.widgets.Label.new(root, canvas.style, {} )
	.setText("Station 1 (PPM1) :");

var PPM1_edit =	canvas.gui.widgets.LineEdit.new(root, canvas.style, {} )
	.setText(getprop("su-27/instrumentation/RSBN/PPM1"))
	.setFixedSize(120,25);

var PPM1_LblSpacer = canvas.gui.widgets.Label.new(root, canvas.style, {} )
	.setText("_________");


var PPM1_btn = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("Set")
        .setFixedSize(90, 25);
PPM1_btn.listen("clicked", func {
        # add code here to react on click on button.
		print(PPM1_edit.text());
		setprop("su-27/instrumentation/RSBN/PPM1",PPM1_edit.text());
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
	.setText(getprop("su-27/instrumentation/RSBN/PPM2"))
	.setFixedSize(120,25);
	
var PPM2_LblSpacer = canvas.gui.widgets.Label.new(root, canvas.style, {} )
	.setText("_________");


var PPM2_btn = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("Set")
        .setFixedSize(90, 25);
PPM2_btn.listen("clicked", func {
        # add code here to react on click on button.
		setprop("su-27/instrumentation/RSBN/PPM2",PPM2_edit.text());
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
	.setText(getprop("su-27/instrumentation/RSBN/PPM3"))
	.setFixedSize(120,25);
	
var PPM3_LblSpacer = canvas.gui.widgets.Label.new(root, canvas.style, {} )
	.setText("_________");


var PPM3_btn = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("Set")
        .setFixedSize(90, 25);
PPM3_btn.listen("clicked", func {
        # add code here to react on click on button.
		setprop("su-27/instrumentation/RSBN/PPM3",PPM3_edit.text());
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
	.setText(getprop("su-27/instrumentation/RSBN/PPM4"))
	.setFixedSize(120,25);
	
var PPM4_LblSpacer = canvas.gui.widgets.Label.new(root, canvas.style, {} )
	.setText("_________");


var PPM4_btn = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("Set")
        .setFixedSize(90, 25);
PPM4_btn.listen("clicked", func {
        # add code here to react on click on button.
		setprop("su-27/instrumentation/RSBN/PPM4",PPM4_edit.text());
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
	.setText(getprop("su-27/instrumentation/RSBN/PPM5"))
	.setFixedSize(120,25);
	
var PPM5_LblSpacer = canvas.gui.widgets.Label.new(root, canvas.style, {} )
	.setText("_________");


var PPM5_btn = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("Set")
        .setFixedSize(90, 25);
PPM5_btn.listen("clicked", func {
		setprop("su-27/instrumentation/RSBN/PPM5",PPM5_edit.text());
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
	.setText(getprop("su-27/instrumentation/RSBN/PPM6"))
	.setFixedSize(120,25);
	
var PPM6_LblSpacer = canvas.gui.widgets.Label.new(root, canvas.style, {} )
	.setText("_________");


var PPM6_btn = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("Set")
        .setFixedSize(90, 25);
PPM6_btn.listen("clicked", func {
		setprop("su-27/instrumentation/RSBN/PPM6",PPM6_edit.text());
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
	.setText(getprop("su-27/instrumentation/RSBN/PPM7"))
	.setFixedSize(120,25);
	
var PPM7_LblSpacer = canvas.gui.widgets.Label.new(root, canvas.style, {} )
	.setText("_________");


var PPM7_btn = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("Set")
        .setFixedSize(90, 25);
PPM7_btn.listen("clicked", func {
		setprop("su-27/instrumentation/RSBN/PPM7",PPM7_edit.text());
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
	.setText(getprop("su-27/instrumentation/RSBN/PPM8"))
	.setFixedSize(120,25);
	
var PPM8_LblSpacer = canvas.gui.widgets.Label.new(root, canvas.style, {} )
	.setText("_________");


var PPM8_btn = canvas.gui.widgets.Button.new(root, canvas.style, {})
        .setText("Set")
        .setFixedSize(90, 25);
PPM8_btn.listen("clicked", func {
		setprop("su-27/instrumentation/RSBN/PPM8",PPM8_edit.text());
		navaid = findNavaidByFrequency(PPM8_edit.text()/10);
		PPM8_LblSpacer.setText(navaid.name);
		});
Hbox9.addItem(PPM8_Lbl);	
Hbox9.addItem(PPM8_edit);
Hbox9.addItem(PPM8_btn);
Hbox9.addItem(PPM8_LblSpacer);


}
