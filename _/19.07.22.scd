s.boot

(
  SynthDef.new(\test, {
    arg freq = 110, sustain = 1;

    var freqPartials = [0.5, 1, 1.19, 1.56, 2, 2.51, 2.66, 3.01, 4.1];
    var ampPartials = [0.25, 1, 0.8, 0.5, 0.9, 0.4, 0.3, 0.6, 0.1];

    var sig = Mix(freqPartials.collect({|v, i|
      SinOsc.ar(
        freq: freq * v,
        mul: (1 / ampPartials.size) * ampPartials[i],
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

Synth.new(\test, [\freq, 880, \sustain, 2])

4.collect({|i|
(150*10^i + 3)/9
})

[1, 2, 4, 8, 9, 16, 18, 27, 32, 36, 54, 64, 72, 81].collect({|i, val|
  1 / val
})
