s.boot;

(
  SynthDef(\perc, {
    | freq = 220,
      attack = 0.005, sustain = 1,
      pan = 0, out = 0 |
    var envelope, source;

    source = LocalIn.ar(2);
    source = AllpassC.ar(source, 0.01, XLine.ar(0.01, 0.001, 0.01), 0.01);
    source = OnePole.ar(source);
    source = SinOsc.ar(freq) + source;
    LocalOut.ar(source);

    envelope = Env.perc(attack, sustain).ar(doneAction: Done.freeSelf);

    source = Limiter.ar(source);
    OffsetOut.ar(out, source * envelope);
  }).add;
)

Synth(\perc, [\freq, 200])

(
Pbindef(\perc,
  \instrument, \perc,
  \dur, 0.25,
  \freq, Pexprand(40, 1000, inf),
).stop
)
