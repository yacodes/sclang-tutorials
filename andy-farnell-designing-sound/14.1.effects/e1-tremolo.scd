"../../_/19.12/14/01.scd".load;
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

// Exercise 1
// Create any one of the following effects:
// • Guitar tremolo effect
// • Multistage phaser
// • Multitap tempo-sync delay
// • A high quality vocal reverb
(
  SynthDef(\saw, {
    | freq = 110,
      atk = 0.01, rel = 0.5,
      amp = 0.5, out = 0 |
    var signal = Saw.ar(freq);
    var env = EnvGen.kr(Env.perc(atk, rel), doneAction: Done.freeSelf);
    signal = Pan2.ar(signal);
    Out.ar(out, signal * env * amp);
  }).add;
)

(
  // @TODO
  // 1. dry/wet
  // 2. amount should not drastically increase signal's amplitude
  SynthDef(\tremolo, {
    | rate = 1, amount = 0.1, wet = 0.5, in = 0, out = 0 |
    var signal, effect;
    signal = In.ar(in, 2);
    ReplaceOut.ar(in, signal * (1 - wet));

    effect = SinOsc.kr(rate, amount);
    signal = signal * effect * wet;
    Out.ar(out, signal);
  }).add;
)

~bus = Bus.audio(s, 2);
x = Synth.new(\tremolo, [\in, ~bus.index, \out, 0, \wet, 0, \amount, 0.5]);
y = Synth.before(x, \saw, [\out, ~bus.index, \rel, 4]);

s.freeAll
s.plotTree;

(
  Synth(\router, {
    | in, out = 0, wet = 0.5 |
  }).add;
)

~groups = ();
~groups.root = Group.new(s);
~groups.sources = Group.new(~groups.root, \addToHead);
~groups.effects = Group.new(~groups.root, \addToTail);

~busses = ();
~busses.hardware = 0;
~busses.effects = Bus.audio(s, 1);

(
  SynthDef(\saw, {
    | freq = 110,
      atk = 0.01, rel = 0.5,
      amp = 0.5, out = 0 |
    var signal = Saw.ar(freq);
    var env = EnvGen.kr(Env.perc(atk, rel), doneAction: Done.freeSelf);
    Out.ar(out, signal * env * amp);
  }).add;

  SynthDef(\reverb, {
    | wet = 0.5,
      in = 0, out = 0 |
    var source, processed, signal;
    source = In.ar(in, 1);
    processed = FreeVerb.ar(source, 1, 1, 1);
    signal = ((source * (1 - wet)) + (processed * wet));
    Out.ar(out, signal);
  }).add;

  SynthDef(\tremolo, {
    | wet = 0.5,
      depth = 0.5, rate = 10,
      in = 0, out = 0 |
    var source, processed, signal;
    source = In.ar(in, 1);
    processed = source * SinOsc.kr(rate, mul: Clip.kr(depth, 0, 1));
    signal = ((source * (1 - wet)) + (processed * wet));
    Out.ar(out, signal);
  }).add;
)
~busses;
~groups;

~signal = Synth(\saw, [\rel, 20, \out, ~busses.effects], ~groups.sources);
~effect = Synth(\reverb, [\in, ~busses.effects, \out, ~busses.hardware], ~groups.effects);
~effect = Synth(\tremolo, [\in, ~busses.effects, \out, ~busses.hardware, \wet, 1], ~groups.effects);
~effect.set(\wet, 0.9);
~effect.set(\depth, 1);
~effect.set(\rate, 2);
~groups.effects.freeAll;
