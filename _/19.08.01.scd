Quarks.gui

s.boot

VSTPlugin.search(Server.default)

VSTPlugin.plugins(s)

VSTPluginGUI

VSTPluginGui.gui

(
// create a Window large enough to hold two VSTPluginGuis per row (see below).
~view = Window.new(bounds: 850@450, scroll: true);
~view.view.decorator = FlowLayout(w.view.bounds);
~view.front;
)

(
// a simple insert FX:
SynthDef.new(\insert, {arg bus = 0;
    ReplaceOut.ar(bus, VSTPlugin.ar(In.ar(bus, 2), 2));
}).add;
)
​
(
// create 2 VSTPlugins
~fx1 = VSTPluginController(Synth(\insert));
~fx2 = VSTPluginController(Synth(\insert));
)
​
// show each GUI in its own window
~fx1.gui;

~fx2.gui;
​
// close the windows
