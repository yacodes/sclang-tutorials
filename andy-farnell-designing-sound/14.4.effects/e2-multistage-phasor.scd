"../../_/19.12/14/01.scd".load;
s.boot;
s.quit;
s.plotTree;
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

  // 8 stage phaser + sin lfo
  SynthDef(\phaser, {
    | mix = 0.5,
      depth = 0.005, rate = 0.5,
      in = 0, out = 0 |
    var source, processed, lfo, signal;
    source = In.ar(in, 1);
    lfo = SinOsc.kr(rate).range(depth / 2, depth * 2);
    processed = Mix.ar(Array.fill(8, {|i|
      AllpassC.ar(source, 4, (i + 1) * depth * lfo, 0);
    }));
    signal = ((source * (1 - mix)) + (processed * mix));
    Out.ar(out, signal);
  }).add;
)
~busses;
~groups;

~signal = Synth(\saw, [\rel, 20, \out, ~busses.effects], ~groups.sources);
~effect = Synth(\phaser, [\in, ~busses.effects, \out, ~busses.hardware], ~groups.effects);
~effect.set(\mix, 0.9);
~effect.set(\depth, 0.1);
~effect.set(\rate, 0.2);
~groups.effects.freeAll;


// References
// * gspot.com/2009/05/simple-phaser-effect.html
// * http://ecmc.rochester.edu/ecmc/docs/supercollider/scbook/Ch21_Interface_Investigations/ixi%20SC%20tutorial/ixi_SC_tutorial_12.html
// * https://en.wikipedia.org/wiki/Phaser_(effect)
