var DemoDialog = {
  new: func(width=140,height=160)
  {
    var m = {
      parents: [DemoDialog],
      _dlg: canvas.Window.new([width, height], "dialog")
                         .set("title", "VBoxLayout")
                         .set("resize", 1),
    };

    m._dlg.getCanvas(1)
          .set("background", canvas.style.getColor("bg_color"));
    m._root = m._dlg.getCanvas().createGroup();
 
    var vbox = canvas.VBoxLayout.new();
    m._dlg.setLayout(vbox);

    # this is where you can add widgets from $FG_ROOT/Nasal/canvas/gui/widgets, e.g.:
    for(var i = 0; i < 5; i += 1 )
      vbox.addItem(
        canvas.gui.widgets.Button.new(m._root, canvas.style, {})
                                 .setText("Button #" ~ i)
      );

    var hint = vbox.sizeHint();
    hint[0] = math.max(width, hint[0]);
    m._dlg.setSize(hint);

    return m;
  },
};

var demo = DemoDialog.new();
