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

(
SynthDef(\soshats, {
  arg out = 0, pan = 0, freq = 220, pitch1 = 238.5, resonance = 1, sustain = 0.5;
  var source, envelope, bpf, hpf;

  source = Mix(PMOsc.ar(Pulse.ar(freq), freq * [1.34, 2.405, 3.09, 1.309], pitch1 * [1, 0.22, 0.014, 0.0038]));

  bpf = BPF.ar(
    source,
    XLine.kr(15000, 9000, sustain),
    Clip.ir(resonance, 0, 1),
    Env.perc(0.005, sustain, curve: -4).ar
  );

  hpf = HPF.ar(
    source,
    XLine.kr(9000, 12000, sustain),
    Env.perc(0.005, sustain, curve: -4).ar
  );

  envelope = Env.perc(0.005, sustain).ar(Done.freeSelf);

  OffsetOut.ar(out, DirtPan.ar((bpf + hpf) * (-5).dbamp, ~dirt.numChannels, pan, envelope));
},
metadata: (
  credit: "Renick Bell",
  category: \drums,
  tags: [\pitched, \hihats, \sos]
)).add;
);
