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
  Server.default.options.inDevice = "BVA";
  Server.default.options.outDevice = "BVA";
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
  SynthDef(\fbsaw01, {
    | freq = 220,
    atk = 0.01, rel = 1,
    amp = 0.5, out = 0 |
    var envelope, source, local;
    envelope = EnvGen.ar(Env.perc(atk, rel), doneAction: Done.freeSelf);

    source = Saw.ar(freq * LFNoise0.kr(1));
    4.do({ |i| source = AllpassC.ar(source, 0.03, (i + 1) * 0.01, (i + 1) * 0.25); });

    local = LocalIn.ar(2) * 0.98;
    local = LeakDC.ar(local);
    local = source + local;

    LocalOut.ar(local);

    local = LPF.ar(local, freq * 4);
    local = HPF.ar(local, 20);

    Out.ar(out, (local * envelope * amp).tanh);
  }).add;
)

{SinOsc.ar}.play
s.freeAll

Synth(\fbsaw01, [\atk, 10, \rel, 10])

(
  SynthDef(\fbsin01, {
    | freq = 220,
    atk = 3, rel = 5,
    gate = 1,
    amp = 0.1, out = 0 |
    var envelope, source, feedback;

    source = SinOsc.ar(freq * {LFNoise1.kr(0.5, 10).midiratio}!2);
    8.do({|i| source = AllpassC.ar(source, 0.08, (i+1) * 0.01, 10)});
    envelope = EnvGen.ar(Env.adsr(attackTime: atk, releaseTime: rel), gate, doneAction: Done.freeSelf);

    feedback = LocalIn.ar(2) * 0.9;
    feedback = AllpassC.ar(feedback, 0.001, 0.001, 0.01);
    feedback = OnePole.ar(feedback, 0.75);
    feedback = source + feedback;
    feedback = Limiter.ar(feedback);
    feedback = LeakDC.ar(feedback);
    LocalOut.ar(feedback);
    feedback = Mix.ar(GVerb.ar(feedback));
    feedback = BLowShelf.ar(feedback, 200, 0.5, 12);
    Out.ar(out, (feedback * envelope * Lag.kr(amp, 20)).tanh);
  }).add;
)

x = Synth(\fbsin01, [\freq, 110, \atk, 10, \rel, 10])
x.set(\amp, 0.001)
s.freeAll
s.latency = 1;

MIDIClient.init;
MIDIIn.connectAll;

~notes = Array.newClear(128);
(
  MIDIdef.noteOff(\fbsinOFF, {
    arg vel, nn;
    if (~notes[nn] != nil, {
      ~notes[nn].set(\gate, 0);
      ~notes[nn].release;
      ~notes[nn] = nil;
    });
  });
  // MIDIdef.noteOn(\fbsinON, { arg vel, nn, chan, src;
  //   if (vel > 0, {
  //     ~notes[nn] = Synth(\fbsin01, [
  //       \freq, nn.midicps,
  //       \amp, vel.linexp(1, 127, 0.001, 0.1),
  //       \gate, 1,
  //     ]);
  //     ["note on", vel, nn].postln;
  //   });
  // });
  MIDIdef.polytouch(\fbsinTOUCH, {
    arg vel, nn, aa, bb;
    if (vel == 0, {
      if (~notes[nn] != nil, {
        ~notes[nn].set(\gate, 0);
        ~notes[nn].release;
        ~notes[nn] = nil;
      });
    }, {
      if (~notes[nn] != nil, {
        ~notes[nn].set(\amp, vel.linexp(1, 127, 0.001, 0.05));
      }, {
        ~notes[nn] = Synth(\fbsin01, [
          \freq, nn.midicps,
          \amp, vel.linexp(1, 127, 0.001, 0.05),
          \gate, 1,
        ]);
      });
    });
  });
)
MIDIdef.freeAll
s.freeAll
