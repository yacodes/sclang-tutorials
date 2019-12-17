"../14//01.scd".load;
s.boot;
s.quit;
Window.closeAll;

(
  // Configuration
  ~config = (
    \channels: 8,
    \out: 0,
  );
  Server.default.options.inDevice = "Scarlett 2i4 USB";
  Server.default.options.outDevice = "Scarlett 2i4 USB";
  Server.default.options.sampleRate = 44100;
  Server.default.options.blockSize = 2**9;
  Server.default.options.hardwareBufferSize = 2**9;
  Server.default.options.numBuffers = 2**18;
  Server.default.options.memSize = 2**18;
  Server.default.options.maxNodes = 2**18;
  Server.default.options.numOutputBusChannels = ~config.channels;
  Server.default.options.numInputBusChannels = 2;

  Server.default.waitForBoot({
    "Server booted".postln;
  });
)

// Andy Farell — Designing Sound; 14. Pure Data Essentials
// Signal Switch
(
  // Synth
  SynthDef(\noise, { | amp = 1 |
    var signal = WhiteNoise.ar;
    Out.ar(0, signal * amp);
  }).add;
  ~synth = Synth(\noise);

  // GUI
  ~gui = ();
  ~gui.bounds = Rect(32, 32, 128, 128);
  ~gui.win = Window.new("Signal Switch", ~gui.bounds, false, false);
  ~gui.win.view.background = Color.black;

  ~gui.toggle = Button(
    ~gui.win,
    Rect((~gui.bounds.width / 2) - 16, (~gui.bounds.height / 2) - 16, 32, 32)
  ).states_([
    ["", Color.white, Color.black],
    ["✕", Color.white, Color.black],
  ]).action_({
    ~synth.set(\amp, ~gui.toggle.value)
  }).value_(1);

  ~gui.win.onClose_({ ~synth.free });
  ~gui.win.front;
  ~gui;
)
~gui.win.close;

// Simple level control
(
  // Signal
  s.waitForBoot({
    SynthDef(\sin, { | amp = 1 |
      var signal = SinOsc.ar(440);
      signal = signal * amp;
      Out.ar(0, signal);
    }).add;
    s.sync;
    ~synth = Synth(\sin);
  });

  // GUI
  ~gui = ();
  ~gui.bounds = Rect(32, 32, 128, 128);
  ~gui.win = Window.new("Simple level control", ~gui.bounds, false, false);
  ~gui.win.view.background = Color.black;

  ~gui.slider = Slider(
    ~gui.win,
    Rect((~gui.bounds.width / 2) - 16, (~gui.bounds.height / 2) - 48, 32, 96)
  ).action_({
    var val = ~gui.slider.value.linexp(0, 1, 0.001, 1);
    val.postln;
    ~synth.set(\amp, val);
  }).value_(1);

  ~gui.win.onClose_({ ~synth.free });
  ~gui.win.front;
  ~gui;
)
~gui.win.close;
s.freeAll


// Mute Button and Smooth Fades
(
  // Signal
  s.waitForBoot({
    SynthDef(\sin, { | amp = 1 |
      var signal = SinOsc.ar(440);
      signal = signal * amp;
      Out.ar(0, signal);
    }).add;
    s.sync;
    ~synth = Synth(\sin);
  });

  // GUI
  ~gui = ();
  ~gui.bounds = Rect(32, 32, 128, 256);
  ~gui.win = Window.new("Simple level control", ~gui.bounds, false, false);
  ~gui.win.view.background = Color.black;

  ~gui.layout = ~gui.win.addFlowLayout(((128 / 2) - (32 / 2))@12, 8@8);

  ~gui.toggle = Button(
    ~gui.win.view,
    Rect((~gui.bounds.width / 2) - 16, (~gui.bounds.height / 2) - 16, 32, 32)
  ).states_([
    ["", Color.white, Color.black],
    ["✕", Color.white, Color.black],
  ]).action_({
    var val = ~gui.toggle.value;
    if (val === 0, {
      ~synth.set(\amp, 0);
    }, {
      ~synth.set(\amp, ~gui.slider.value.linexp(0, 1, 0.001, 1))
    });
  }).value_(1);
  ~gui.layout.nextLine;

  ~gui.slider = Slider(
    ~gui.win.view,
    Rect((~gui.bounds.width / 2) - 16, (~gui.bounds.height / 2) - 48, 32, 192)
  ).action_({
    var val = ~gui.slider.value.linexp(0, 1, 0.001, 1);
    val.postln;
    if (~gui.toggle.value == 1, { ~synth.set(\amp, val) });
  }).value_(1);

  ~gui.win.onClose_({ ~synth.free });
  ~gui.win.front;
  ~gui;
)
~gui.win.close;
s.freeAll
Window.closeAll


// Panning
(
  // Signal
  s.waitForBoot({
    SynthDef(\sin, { | pan = 0 |
      var signal = SinOsc.ar(440);
      signal = Pan2.ar(signal, pan);
      Out.ar(0, signal);
    }).add;
    s.sync;
    ~synth = Synth(\sin);
  });

  // GUI
  ~gui = ();
  ~gui.bounds = Rect(32, 32, 256, 128);
  ~gui.win = Window.new("Panning", ~gui.bounds, false, false);
  ~gui.win.view.background = Color.black;

  ~gui.slider = Slider(
    ~gui.win.view,
    Rect((~gui.bounds.width / 2) - 96, (~gui.bounds.height / 2) - 16, 192, 32)
  ).action_({
    var val = ~gui.slider.value.linlin(0, 1, -1, 1);
    val.postln;
    ~synth.set(\pan, val);
  }).value_(0.5);

  ~gui.win.onClose_({ ~synth.free });
  ~gui.win.front;
  ~gui;
)
~gui.win.close;
s.freeAll
Window.closeAll

// Crossfader
(
  s.waitForBoot({
    SynthDef(\sin, { | out = 0, freq = 440, amp = 0.5 |
      Out.ar(out, SinOsc.ar(freq) * amp);
    }).add;
    SynthDef(\crossfade, { | position = 0.5 |
      [ReplaceOut.ar(0, In.ar(0, 1) * (1 - position)), ReplaceOut.ar(1, In.ar(1, 2) * position)];
    }).add;
    s.sync;

    ~group = Group.new;
    ~synths = 2.do{|i| Synth.head(~group, \sin, [\freq, 220*(i+1), \out, i])};
    ~crossfade = Synth.tail(~group, \crossfade);

    // GUI
    ~gui = ();
    ~gui.bounds = Rect(32, 32, 256, 128);
    ~gui.win = Window.new("Panning", ~gui.bounds, false, false);
    ~gui.win.view.background = Color.black;

    ~gui.slider = Slider(
      ~gui.win.view,
      Rect((~gui.bounds.width / 2) - 96, (~gui.bounds.height / 2) - 16, 192, 32)
    ).action_({
      var val = ~gui.slider.value;
      val.postln;
      ~crossfade.set(\position, val);
    }).value_(0.5);

    ~gui.win.onClose_({ ~group.free });
    ~gui.win.front;
    ~gui;
  });
)

~gui.win.close;
s.plotTree
s.freeAll
Window.closeAll


// Monophonic sampler
(
  s.waitForBoot({
    ~buffer = Buffer.alloc(s, s.sampleRate * 2.0, 1);
    SynthDef(\recorder, { | amp = 0.5, bufnum = 0 |
      var signal = SoundIn.ar(0);
      RecordBuf.ar(signal, bufnum, doneAction: Done.freeSelf, loop: 0);
    }).add;
    s.sync;
    ~sampler = nil;

    // GUI
    ~gui = ();
    ~gui.bounds = Rect(32, 32, 104, 224);
    ~gui.win = Window.new("Sampler", ~gui.bounds, false, false);
    ~gui.win.view.background = Color.black;

    ~gui.rec = Button(
      ~gui.win.view,
      Rect(16, 16, 32, 32)
    ).states_([
      ["◯", Color.white, Color.black],
      ["◯", Color.white, Color.red],
    ]).action_({
      var val = ~gui.rec.value;
      val.postln;
      ~sampler = Synth(\recorder);
      ~buffer.onEnd({ ~gui.rec.value_(0) });
    }).value_(0);

    ~gui.gain = Slider(
      ~gui.win.view,
      Rect(56, 16, 32, 192)
    ).action_({
      var val = ~gui.gain.value.linexp(0, 1, 0.001, 1);
      val.postln;
    }).value_(1);

    ~gui.play = Button(
      ~gui.win.view,
      Rect(16, 56, 32, 32)
    ).states_([
      ["▶", Color.white, Color.black],
      ["■", Color.white, Color.black],
    ]).action_({
      var val = ~gui.rec.value;
      val.postln;
    }).value_(0);

    ~gui.win.onClose_({ ~sampler.free });
    ~gui.win.front;
    ~gui;
  });
)
~gui.win.close;
s.freeAll;
s.plotTree;

~sampler.isRunning

~buffer.play
