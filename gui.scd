s.boot;

(
  SynthDef(\simplebuf, {|freq = 440|
    var sig;
    sig = PinkNoise.ar(1!2);
    sig = BPF.ar(sig, freq.lag(0.5), 0.2);
    Out.ar(0, sig);
  }).add;
)

(
  w = Window("gui", Rect(
    Window.screenBounds.width / 2 - 100,
    Window.screenBounds.height / 2 - 100,
    500,
    200
  ))
  .front
  .alwaysOnTop_(true);

  ~slider = Slider(w, Rect(20, 20, 30, 150))
    .orientation_(\veritcal)
    .action_({|obj|
      var cf = obj.value.linexp(0, 1, 100, 4000).postln;
      if (x.isPlaying, {x.set(\freq, cf)});
    });

  ~button = Button(w, Rect(430, 20, 50, 30))
    .states_([
      ["OFF", Color.black, Color.gray(0.8)],
      ["ON", Color.white, Color(0.2, 0.75, 0.95)]
    ])
    .font_(Font("Roboto", 14))
    .action_({|obj|
      if (obj.value == 1, {
        x = Synth.new(
          \simplebuf,
          [\freq, ~slider.value.linexp(0, 1, 100, 4000)]
        ).register; // Read NODE.register
      }, {
        x.free;
      });
    });
)


x.free;

GUI.current;

GUI.cocoa;

Window.closeAll;

w.bounds;
