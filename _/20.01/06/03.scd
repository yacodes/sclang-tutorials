"../../19.12/14//01.scd".load;
s.boot;
s.plotTree;
s.scope;
Window.closeAll;

(
  // Configuration
  ~config = (
    \channels: 8,
    \out: 0,
  );
  Server.default.options.inDevice = "JAM";
  Server.default.options.outDevice = "JAM";
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

(
  SynthDef(\kick, {
    | freq = 45,
      atk = 0.002, sus = 0.5,
      sweep = 0.3, sweepDur = 0.9,
      noise = 0.1, overdrive = 0,
      amp = 0.2, pan = 0, out = 0 |
    var freqEnv, feedback, source, env;

    freqEnv = EnvGen.ar(Env.perc(atk, Clip.ir(sus * sweepDur, 0, sus), sweep * freq, -4));
    freqEnv = (freqEnv + freq) + PinkNoise.ar(Clip.ir(noise * 100, 0, 100));
    env = EnvGen.ar(Env.perc(atk, sus, 1, -4), doneAction: 2);

    source = DPW3Tri.ar(freqEnv * LFNoise1.ar(1, 0.5).midiratio);
    source = (source * Clip.ir(10 * overdrive, 1, 10)).tanh;
    // 4.do({ |i| source = AllpassC.ar(source, 0.01, Rand(0.001, 0.01), 0); });

    feedback = LocalIn.ar(2) * 0.99;
    feedback = LeakDC.ar(feedback);
    // 4.do({ |i| feedback = AllpassC.ar(feedback, 0.01, Rand(0.001, 0.01), 0); });
    feedback = (feedback + source);

    LocalOut.ar(feedback);

    feedback = BLowShelf.ar(feedback, freq, 0.5, 12);
    feedback = HPF.ar(feedback, 20);
    feedback = LPF.ar(feedback, freq * 16);

    feedback = feedback * (1/2);
    feedback = Pan2.ar(feedback, pan, amp);
    Out.ar(out, (feedback * env).tanh);
  }).add;
)

(
  SynthDef(\perc, {
    | freq = 220,
    atk = 0.01, rel = 1,
    gate = 1, pan = 0, amp = 0.1, out = 0 |
    var envelope, source, feedback;

    source = Saw.ar(freq * {LFNoise1.kr(0.5, 10).midiratio}!2);
    8.do({|i| source = AllpassC.ar(source, 0.08, Rand(0.001, 0.08), 1)});
    envelope = EnvGen.ar(Env.adsr(attackTime: atk, releaseTime: rel), gate, doneAction: Done.freeSelf);

    feedback = LocalIn.ar(2) * 0.9;
    feedback = AllpassC.ar(feedback, 0.001, 0.001, 0);
    8.do({|i| feedback = AllpassC.ar(feedback, 0.08, Rand(0.001, 0.08), 0)});
    feedback = OnePole.ar(feedback, 0.75);
    feedback = source + feedback;
    feedback = Limiter.ar(feedback);
    feedback = LeakDC.ar(feedback);
    LocalOut.ar(feedback);
    feedback = Pan2.ar(Mix.ar(feedback), pan, (1/4));
    Out.ar(out, (feedback * envelope * amp).tanh);
  }).add;
)

(
  ~bpm = 128;
  Pdef(
    \kick,
    Pbind(
      \instrument, Prand([\kick], inf),
      \dur, Prand([1/16], inf),
      \stretch, 60 / ~bpm * 4,
      \freq, Pexprand(80, 82, inf),
      \sus, Pkey(\dur) * 2,
      \amp, Pseq([
        1,
        Pexprand(0.01, 0.8, 7),
      ], inf),
    ),
  ).play(quant: 60 / ~bpm * 4);
  Pdef(
    \perc,
    Pbind(
      \instrument, Prand([\perc], inf),
      \dur, Prand([1/4, 1/2, 1/16, 1/8], inf),
      \stretch, 60 / ~bpm * 4,
      \freq, Pexprand(440, 880, inf),
      \rel, Pkey(\dur) * 2,
      \amp, Pwrand([0.6, 0.2, 0] * (1), [10, 4, 5].normalizeSum, inf),
      \pan, Pwhite(-0.5, 0.5, inf),
    ),
  ).play(quant: 60 / ~bpm * 4);
)
Pdef(\kick).stop;
Pdef(\perc).stop;
s.freeAll
