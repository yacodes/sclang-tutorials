// (
//   s.quit;
//   s.options.inDevice = "Scarlett 2i4 USB";
//   s.options.outDevice = "Scarlett 2i4 USB";
//   s.options.memSize = 262144;
//   s.options.sampleRate = 44100;
//   s.options.blockSize = 128;
//   s.options.hardwareBufferSize = 128;
//   s.options.numBuffers = 1024 * 256;
//   s.options.memSize = 8192 * 32;
//   s.options.maxNodes = 1024 * 32;
//   s.boot;
// )

100 + 320

(
  100 + 100;

  SynthDef(\sin, {
	SinOsc.ar(440);
  }).add;
)

{SinOsc.ar}.play

s.freeAll

// Moog bass
(
  SynthDef(\moogbass, {
    arg out, sustain = 1, pan, freq = 440, n, chor = 0.7, lagamount = 0.01, coff = 1000;
    var osc, filter, env, filterenv, snd, chorusfx;

    osc = Mix(
      VarSaw.ar(
        freq: freq.lag(lagamount) * [1.0, 1.001, 2.0],
        iphase: Rand(0.0, 1.0)!3,
        width: Rand(0.5, 0.75)!3, mul: 0.5
      )
    );

    filterenv = EnvGen.ar(
      envelope: Env.new(levels: [0, 1, 0], times: [0.2, 0.2, 0.2], curve: -4),
      timeScale: sustain,
      doneAction: Done.freeSelf
    );

    filter =  MoogFF.ar(
      in: osc,
      freq: 1000 * (1.0 + (0.5 * filterenv)),
      gain: 2
    );

    env = EnvGen.ar(
      envelope: Env.new(levels: [0, 1, 1, 0.9, 0], times: [0.001, 0.001, 0.25, 0.2], curve: -4),
      timeScale: sustain,
      doneAction: Done.freeSelf
    );

    snd = (0.7 * filter + (0.3 * filter.distort)) * env;

    chorusfx = Mix.fill(7, {
      var maxdelaytime = rrand(0.005, 0.02);
      DelayC.ar(
        in: snd,
        maxdelaytime: maxdelaytime,
        delaytime: LFNoise1.kr(
          freq: Rand(4.5, 10.5),
          mul: 0.25 * maxdelaytime,
          add: 0.75 * maxdelaytime
        )
      )
    });

    snd = snd + (chorusfx * chor);

    OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan, env));
  }).add;
)


// ~z = Synth.new(\moogbass, [\freq, 960])
// ~z.free

// Env.adsr(0.001, 0.3, 0.9, 0.2, 0.1).plot
// Env.linen(0.001, 0.3, 0.9, 0.2, 0.1).plot
// Env.sine(0.001, 0.3, 0.9, 0.2, 0.1).plot
// Env.adsr()

// (
// Env.new(
//   levels: [0, 1, 1, 0.9, 0],
//   times: [0.001, 0.001, 0.25, 0.2],
//   curve: -4
// ).plot
// )

// Env.asr(0.2, 1, 0.2).plot

// (
// Env.new(levels: [0, 1, 0], times: [0.2, 0.2, 0.2], curve: -4).plot
// )
