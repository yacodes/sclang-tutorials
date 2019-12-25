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

~buffer = Buffer.alloc(s, s.sampleRate * 4);

(
  SynthDef(\saw, {
    | freq = 110,
    atk = 0.01, rel = 0.5,
    amp = 0.5, out = 0 |
    var signal = Saw.ar(freq);
    var env = EnvGen.kr(Env.perc(atk, rel), gate: LFSaw.kr(0.1));
    Out.ar(out, signal * env * amp);
  }).add;

  // @TODO
  // 1. Tempo-sync with sequencer from Exercise 1
  // 2. Props for steps (4/4, 3/4, 7/8, 9/8...)
  // 3. Props for tap amps
  SynthDef(\multitapdelay, {
    | mix = 0.5,
      in = 0, out = 0 |
    var source, processed, lfo, signal;
    source = In.ar(in, 1);
    processed = Mix.ar(8.collect({ |i|
      DelayN.ar(source, (i + 1) * 0.2, (i + 1) * 0.2);
    }));
    signal = ((source * (1 - mix)) + (processed * mix));
    Out.ar(out, signal);
  }).add;
)
~busses;
~groups;

~signal = Synth(\saw, [\rel, 0.5, \out, ~busses.effects], ~groups.sources);
~effect = Synth(\multitapdelay, [\in, ~busses.effects, \out, ~busses.hardware], ~groups.effects);
~effect.set(\mix, 0.9);
~effect.set(\depth, 0.1);
~effect.set(\rate, 0.2);
~groups.effects.freeAll;
~groups.sources.freeAll;

// References
// + https://www.sweetwater.com/insync/multi-tap-delay/
// + https://www.youtube.com/watch?v=QUD4aA2RQk0
// + http://doc.sccode.org/Classes/MultiTap.html
// + https://www.soundonsound.com/techniques/creating-using-custom-delay-effects
