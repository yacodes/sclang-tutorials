s.boot

(
  SynthDef.new(\test, {
    arg freq = 110, sustain = 1;

    var freqPartials = [0.5, 1, 1.19, 1.56, 2, 2.51, 2.66, 3.01, 4.1];
    var ampPartials = [0.25, 1, 0.8, 0.5, 0.9, 0.4, 0.3, 0.6, 0.1];

    var sig = Mix(freqPartials.collect({|index|
      SinOsc.ar(
        freq: freq * freqPartials[index],
        mul: (1 / ampPartials.size) * ampPartials[index],
      );
    }));

    var env = EnvGen.kr(
      Env.new(levels: [0, 1, 0], times: [0.02, 1], curve: -4),
      timeScale: sustain,
      doneAction: Done.freeSelf,
    );
    Out.ar(0, Pan2.ar(sig * env, 0));
  }).add;
)

Synth.new(\test, [\freq, 440, \sustain, 8])
