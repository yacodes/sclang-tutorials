"../../_/19.12/14//01.scd".load;
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
    | rate = 1, amount = 0.1, out = 0 |
    var signal = In.ar(0, 2);
    var effect = SinOsc.kr(rate, add: amount);
    signal = signal * effect;
    ReplaceOut.ar(out, signal);
  }).add;
)

~group = Group.new
Synth.head(~group, \saw, [\rel, 4])
Synth.tail(~group, \tremolo, [\amount, 1, \rate, 10])
~group.free
s.freeAll
{SinOsc.ar(10, mul: 10)}.plot(0.1)
