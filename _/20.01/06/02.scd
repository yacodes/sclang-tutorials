"../../19.12/14//01.scd".load;

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
    SynthDef(\fbsaw, {
      | freq = 220,
      atk = 0.01, rel = 1,
      gate = 1, pan = 0, amp = 0.5, out = 0 |
      var envelope, source, local;
      envelope = EnvGen.ar(Env.adsr(attackTime: atk, releaseTime: rel), gate: gate, doneAction: Done.freeSelf);

      source = Saw.ar(freq * {LFNoise1.kr(1, 4).midiratio}!2);
      8.do({ |i| source = AllpassC.ar(source, 0.02, Rand(0.001, 0.02), envelope); });

      local = LocalIn.ar(2) * 0.99;
      local = LeakDC.ar(local);
      local = source + local;

      LocalOut.ar(local);

      local = LPF.ar(local, freq * 4);
      local = HPF.ar(local, 20);
      local = BLowShelf.ar(local, 200, 0.5, 12);
      local = Mix(local);
      local = Pan2.ar(local, pan, 0.5);

      Out.ar(out, (local * envelope * Lag.kr(amp, 20)).tanh);
    }).add;
    Server.default.sync;

    Pdef(
      \pat,
      Pbind(
        \instrument, \fbsaw,
        \dur, Pwhite(0.15, 4, inf),
        \freq, Pexprand(40, 2000, inf),
        \atk, Pwhite(1, 2, inf),
        \rel, Pwhite(5, 10, inf),
        \amp, Pwhite(0.05, 0.075, inf),
        \pan, Pwhite(-0.5, 0.5, inf),
      ),
    ).play;
  });
)

Pdef(\pat).stop;

s.freeAll
