"../../19.12/14//01.scd".load;
s.boot;
s.quit;
s.plotTree;
Window.closeAll;
s.scope;

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

(
  SynthDef(\feedback, {
    | freq = 220,
      atk = 0.01, rel = 1,
      amp = 0.5, out = 0 |
    var envelope, source, local;
    envelope = EnvGen.ar(Env.perc(atk, rel), doneAction: Done.freeSelf);

    source = Saw.ar(freq);
    4.do({ |i| source = AllpassC.ar(source, 0.03, (i + 1) * 0.01, (i + 1) * 0.25); });

    local = LocalIn.ar(2) * 0.98;
    local = LeakDC.ar(local);
    local = source + local;

    LocalOut.ar(local);

    local = LPF.ar(local, freq * 4);

    Out.ar(out, (local * envelope * amp).tanh);
  }).add;
)
Synth(\feedback, [\freq, 110]);
