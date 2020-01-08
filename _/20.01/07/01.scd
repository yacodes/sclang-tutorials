"../../19.12/14//01.scd".load;
s.boot;
s.quit;
s.plotTree;
Window.closeAll;
s.meter
s.scope;

Platform.resourceDir()
PlayBufFree.generateSynthDef
Platform.userExtensionDir

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
  Server.default.options.numBuffers = 2**20;
  Server.default.options.memSize = 2**20;
  Server.default.options.maxNodes = 2**20;
  Server.default.options.numOutputBusChannels = ~config.channels;
  Server.default.options.numInputBusChannels = 2;

  Server.default.waitForBoot({
    "Server booted".postln;
  });
)


// MIDI Fighter
(
  MIDIClient.init;
  MIDIIn.connectAll();
  ~twister = Twister(TwisterDevice(\primary, MIDIClient.sources[5]));
  ~control = ControlValueEnvir(BusControlValue);
  ~control.use {
    ~amp.spec = [0, 1]; ~amp.value = 1;
    ~reverb.spec = [0, 1]; ~reverb.value = 1;
    ~phaser.spec = [0, 1]; ~phaser.value = 1;
  };

  // Gain
  ~twister.knobs[0].cv = ~control.amp;
  ~twister.knobs[0].ledColor = Color.green;

  // Reverb
  ~twister.knobs[1].cv = ~control.reverb;
  ~twister.knobs[1].ledColor = Color.blue;

  // Phaser
  ~twister.knobs[2].cv = ~control.phaser;
  ~twister.knobs[2].ledColor = Color.blue;
)

// GUI
(
  QtGUI.palette = QPalette.dark;
  ~gui = ();
  ~gui.bounds = Rect(0, Window.screenBounds.height - 500, 500, 500);
  ~gui.win = Window.new("BASSX", ~gui.bounds);
  ~gui.meter = CustomMeterView.new(s, ~gui.win, 0@0, 2, 2);

  ~gui.freqscopes = ();
  ~gui.freqscopes.left = FreqScopeView(~gui.win, Rect(~gui.meter.view.bounds.width, 0, 256, 200));
  ~gui.freqscopes.left.inBus = 0;
  ~gui.freqscopes.right = FreqScopeView(~gui.win, Rect(~gui.meter.view.bounds.width + 256, 0, 256, 200));
  ~gui.freqscopes.right.inBus = 1;

  ~gui.freqscopes.left.background = Color.black;
  ~gui.freqscopes.left.active_(true).freqMode_(1);
  ~gui.freqscopes.right.background = Color.black;
  ~gui.freqscopes.right.active_(true).freqMode_(1);

  ~gui.layout = HLayoutView(~gui.win, Rect(8, 256, 500, 256));
  ~gui.resize = 5;

  // Amplitude
  ~vlayout1 = VLayoutView(~gui.layout, Rect(0, 0, 30, 100));
  StaticText(~vlayout1, Rect(0, 0, 55, 20)).string_("Amp").align(\center);
  StaticText(~vlayout1, Rect(0, 0, 55, 5)).string_("").align(\center);
  ~slider1 = Slider(~vlayout1, Rect(0, 0, 20, 200))
    .orientation_(\vertical)
    .value_(~control.amp.value)
    .knobColor_(Color.white)
    .background_(Color.black);

  ~vlayout2 = VLayoutView(~gui.layout, Rect(50, 0, 30, 100));
  StaticText(~vlayout2, Rect(0, 0, 55, 20)).string_("Reverb").align(\center);
  StaticText(~vlayout2, Rect(0, 0, 55, 5)).string_("").align(\center);
  ~slider2 = Slider(~vlayout2, Rect(0, 0, 20, 200))
    .orientation_(\vertical)
    .value_(~control.reverb.value)
    .knobColor_(Color.white)
    .background_(Color.black);

  ~vlayout3 = VLayoutView(~gui.layout, Rect(50, 0, 30, 100));
  StaticText(~vlayout3, Rect(0, 0, 55, 20)).string_("Phaser").align(\center);
  StaticText(~vlayout3, Rect(0, 0, 55, 5)).string_("").align(\center);
  ~slider3 = Slider(~vlayout3, Rect(0, 0, 20, 200))
    .orientation_(\vertical)
    .value_(~control.phaser.value)
    .knobColor_(Color.white)
    .background_(Color.black);

  ~gui.win.onClose_({
    ~gui.freqscopes.left.kill;
    ~gui.freqscopes.right.kill;
  });
  ~gui.win.view.background = Color(0, 0, 0, 1);
  ~gui.win.front;
)
Window.closeAll;

(
  SynthDef(\in, {
    | out = 0, pan = 0 |
    var freq, hasFreq;
    var source = SoundIn.ar(0);
    var amplitude = Amplitude.ar(source);
    # freq, hasFreq = Pitch.kr(source);

    // source = SinOsc.ar(freq * 0.5) * source + source;

    source = LPF.ar(HPF.ar(source, 40), 12000);
    source = BLowShelf.ar(source, freq, 1.0, 6);
    source = LeakDC.ar(source);

    OffsetOut.ar(out, Pan2.ar(source, pan, amplitude));
  }).add;
)

// Effects
(
  SynthDef(\reverb, {
    | mix = 0.5,
      in = 0, out = 0 |
    var source, processed, signal;
    source = In.ar(in, 2);
    processed = FreeVerb.ar(source, 1, 1, 1);
    signal = ((source * (1 - mix)) + (processed * mix));
    ReplaceOut.ar(out, signal);
  }).add;

  SynthDef(\chorus, {
    | in=0, out=0, mix=0.5, predelay=0.08, speed=0.05, depth=0.1, ph_diff=0.5 |
    var source, modulators, processed, signal;
    source = In.ar(in, 2) * 12.reciprocal;
    modulators = Array.fill(12, {arg i; LFPar.kr(speed * rrand(0.94, 1.06), ph_diff * i, depth, predelay);});
    processed = Mix(DelayC.ar(source, 0.5, modulators));
    signal = ((source * (1 - mix)) + (processed * mix));
    ReplaceOut.ar(out, signal);
  }).add;

  SynthDef(\delay, {| mix = 0.5, in = 0, out = 0 |
    var source, processed, signal;
    source = In.ar(in, 2);
    processed = AllpassL.ar(source, 0.6, MouseX.kr(0.05, 2, 1), MouseY.kr(0.1, 10, 1));
    signal = ((source * (1 - mix)) + (processed * mix));
    ReplaceOut.ar(out, signal);
  }).add;
  SynthDef(\amp, {| amp = 1, in = 0, out = 0 | ReplaceOut.ar(out, In.ar(in, 2) * amp * 40)}).add;
  SynthDef(\limiter, { | in = 0, out = 0 | ReplaceOut.ar(out, Limiter.ar(In.ar(in, 2), 0.5)); }).add;
)

(
  ~groups = ();
  ~groups.root = Group.new(s);
  ~groups.sources = Group.new(~groups.root, \addToHead);
  ~groups.effects = Group.new(~groups.root, \addToTail);
  ~groups.processing = Group.new(~groups.root, \addToTail);

  ~busses = ();
  ~busses.hardware = 0;
  ~busses.effects = Bus.audio(s, 2);
  ~busses.processing = Bus.audio(s, 2);

  ~synths = ();
  ~synths.source = Synth(\in, [\out, ~busses.effects], ~groups.sources);

  ~synths.effects = ();
  ~synths.effects.reverb = Synth(\reverb, [\in, ~busses.effects, \out, ~busses.effects], ~groups.effects, \addToTail);
  ~synths.effects.phaser = Synth(\chorus, [\in, ~busses.effects, \out, ~busses.effects], ~groups.effects, \addToTail);
  ~synths.effects.delay = Synth(\delay, [\in, ~busses.effects, \out, ~busses.processing], ~groups.effects, \addToTail);

  ~synths.processing = ();
  ~synths.processing.amp = Synth(\amp, [\in, ~busses.processing, \out, ~busses.processing], ~groups.processing, \addToTail);

  ~synths.processing.limiter = Synth(\limiter, [\in, ~busses.processing, \out, ~busses.hardware], ~groups.processing, \addToTail);
)
~groups.root.free;

~synths.effects.phaser.set(\depth, 0.01);
~synths.effects.phaser.set(\decay, 0.02);

(
~control.amp.signal(\value).connectToUnique({
  ~synths.processing.amp.set(\amp, ~control.amp.value.linexp(0.00001, 1, 0.00001, 1));
  {~slider1.value_(~control.amp.value)}.defer;
});

~control.reverb.signal(\value).connectToUnique({
  ~synths.effects.reverb.set(\mix, ~control.reverb.value.linlin(0.01, 1, 0.01, 1));
  {~slider2.value_(~control.reverb.value)}.defer;
});

~control.phaser.signal(\value).connectToUnique({
  ~synths.effects.phaser.set(\mix, ~control.phaser.value.linlin(0.01, 1, 0.01, 1));
  {~slider3.value_(~control.phaser.value)}.defer;
});
)
