s.boot;
s.quit;
s.plotTree;
Window.closeAll;
s.meter
s.scope;

(
  // Configuration
  ~config = (
    \device: "Scarlett 2i4 USB",
    \channels: 2,
    \out: 0,
  );

  // Configure and run audio server
  Server.default.options.inDevice = ~config.device;
  Server.default.options.outDevice = ~config.device;
  Server.default.options.sampleRate = 44100;
  Server.default.options.blockSize = 2**9;
  Server.default.options.hardwareBufferSize = 2**9;
  Server.default.options.numBuffers = 2**20;
  Server.default.options.memSize = 2**20;
  Server.default.options.maxNodes = 2**20;
  Server.default.options.numOutputBusChannels = ~config.channels;
  Server.default.options.numInputBusChannels = 0; // We do not need inputs here
  s.boot;
)


(
SynthDef(\perc, {
  | freq = 220,
    atk = 0.01, rel = 1,
    gate = 1,
    pan = 0, amp = 0.1, out = 0 |
  var envelope, source, feedback;

  source = Saw.ar(freq * {LFNoise1.kr(0.5, 0.1).midiratio}!2);
  // 2.do({|i| source = AllpassC.ar(source, 0.08, Rand(0.001, 0.08), 1)});
  envelope = EnvGen.ar(Env.adsr(atk, rel), gate: gate, doneAction: Done.freeSelf);

  feedback = LocalIn.ar(2) * 0.99;
  feedback = OnePole.ar(feedback, 0.75);
  feedback = source + feedback;
  feedback = LeakDC.ar(feedback);
  LocalOut.ar(feedback);
  feedback = FreeVerb.ar(feedback, 1) * 6;
  feedback = LeakDC.ar(feedback);
  feedback = Limiter.ar(Mix(feedback * envelope * amp), 0.5);
  feedback = PanAz.ar(~config.channels, feedback, pan);
  OffsetOut.ar(out, feedback);
}).add;
)

MIDIClient.init;
MIDIIn.connectAll();

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
  MIDIdef.noteOn(\fbsinON, { arg vel, nn, chan, src;
    if (vel > 0, {
      ~notes[nn] = Synth(\perc, [
        \freq, nn.midicps,
        \amp, vel.linexp(1, 127, 0.01, 0.9),
        \gate, 1,
      ]);
      "noteon".postln;
    });
  });
)
s.meter
s.freeAll
s.plotTree
Synth(\perc);
