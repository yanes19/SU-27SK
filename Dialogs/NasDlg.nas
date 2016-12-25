<![CDATA[
 
gui.popupTip("Nasal DLG");
print("Nasal DLG");
# create a new window, dimensions are 400 x 200, using the dialog decoration (i.e. titlebar)
var window = canvas.Window.new([800,400],"dialog");

# adding a canvas to the new window and setting up background colors/transparency
var myCanvas = window.createCanvas().set("background", canvas.style.getColor("bg_color"));

# Using specific css colors would also be possible:
# myCanvas.set("background", "#ffaac0");

# creating the top-level/root group which will contain all other elements/group
var root = myCanvas.createGroup();


# path now a URL
var path = "Aircraft/SU-27SK/Dialogs/Su-27-Pylons.png";

# create an image child for the texture
var child=root.createChild("image")
    .setFile(path) 
    .setTranslation(45,22) # centered, in relation to dialog coordinates
    .setSize(773,281); # image dimensions


 ]]>
