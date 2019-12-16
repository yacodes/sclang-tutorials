"../14//01.scd".load;
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
    "Starting main Routine".postln;

    Routine({
      "1".postln;
      2.wait;
      "2".postln;
    }).play(AppClock);
  });
)

(
  SynthDef(\pad, {
    | att = 2, sus = 0, rel = 3,
      freq = 440, detune = 0.2,
      ffmin = 500, ffmax = 2000,
      rqmin = 0.1, rqmax = 0.2,
      ffhzmin = 0.1, ffhzmax = 0.3,
      lsf = 200, ldb = 0,
      amp = 1, pan = 0, out = 0 |
    var signal, envelope;

    envelope = EnvGen.kr(
      Env([0, 1, 1, 0], [att, sus, rel], [1, 0, -1]),
      doneAction: Done.freeSelf,
    );

    signal = Saw.ar(freq * {LFNoise1.kr(0.5, detune).midiratio}!2);
    signal = Resonz.ar(
      signal,
      {LFNoise1.kr(
        LFNoise1.kr(4).exprange(ffhzmin, ffhzmax),
      ).exprange(ffmin, ffmax)}!2,
      {LFNoise1.kr(0.1).exprange(rqmin, rqmax)}!2,
    );
    signal = BLowShelf.ar(signal, lsf, 0.5, ldb);
    signal = FreeVerb.ar(signal, 0.5, 1, 1);
    // Stereo
    // signal = Balance2.ar(signal[0], signal[1], pan);

    // Multichannel
    // signal = Mix(signal);
    // signal = PanAz.ar(8, signal, LFNoise1.kr(0.5));
    signal = signal * envelope * amp;

    Out.ar(out, signal);
  }).add;
)

// @TODO Map MIDI Twister
(
  ~pad = Pbindef(\ppad,
    \instrument, \pad,
    \dur, 2,
    \midinote, Pxrand([
      [23, 35, 54, 63, 64],
      [45, 52, 54, 59, 61, 64],
      [28, 40, 47, 56, 59, 63],
      [42, 52, 57, 61, 63],
    ], inf),
    \detune, 0.2,
    \ffmin, 100,
    \ffmax, 12000,
    \rqmin, 0.005,
    \rqmax, 0.0075,
    \atk, 5,
    \ldb, 12,
    \amp, 0.75,
    \out, ~config.out,
  ).play;
)
s.freeAll
