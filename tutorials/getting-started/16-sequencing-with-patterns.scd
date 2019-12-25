// Patterns greatly simplify the use of data streams.
// A pattern is essentially a factory for a stream.
// The pattern objects includes the data you want to come out of the stream,
// and the type of pattern determines how the data will be streamed.
(
  r = Routine({
    [60, 72, 71, 67, 69, 71, 72, 60, 69, 67].do({ |midi| midi.yield });
  });

  while { (m = r.next).notNil } { m.postln };
)

p = Pseq([60, 72, 71, 67, 69, 71, 72, 60, 69, 67], 1);
r = p.asStream;
while { (m = r.next).notNil } { m.postln };


(
  var midi, dur;
  midi = Pseq([60, 72, 71, 67, 69, 71, 72, 60, 69, 67], 1).asStream;
  dur = Pseq([2, 2, 1, 0.5, 0.5, 1, 1, 2, 2, 3], 1).asStream;

  SynthDef(\smooth, { |out, freq = 440, sustain = 1, amp = 0.2|
    var sig;
    sig = SinOsc.ar(freq, 0, amp) * EnvGen.kr(Env.linen(0.05, sustain, 0.1), doneAction: Done.freeSelf);
    Out.ar(out, sig ! 2)
  }).add;

  r = Task({
    var delta;
    while {
      delta = dur.next;
      delta.notNil
    } {
      Synth(\smooth, [freq: midi.next.midicps, sustain: delta]);
      delta.yield;
    }
  }).play(quant: TempoClock.default.beats + 1.0);
)

p = Pwhite(0.0, Pseries(0.01, 0.01, inf), 100).asStream;
// .all pulls from the stream until it returns nil
// obviously you don't want to do this for an 'inf' length stream!
p.all.plot;

p = Pn(Pshuf([1, 2, 3, 4, 5], 1), inf).asStream;
p.nextN(15); // get 15 values from the pattern's stream

// Playing notes with a pattern: Pbind
(
  SynthDef(\smooth, { |out, freq = 440, sustain = 1, amp = 0.5|
    var sig;
    sig = SinOsc.ar(freq, 0, amp) * EnvGen.kr(Env.linen(0.05, sustain, 0.1), doneAction: Done.freeSelf);
    Out.ar(out, sig ! 2)
  }).add;
)

(
  p = Pbind(
    // the name of the SynthDef to use for each note
    \instrument, \smooth,
    // MIDI note numbers -- converted automatically to Hz
    \midinote, Pseq([60, 72, 71, 67, 69, 71, 72, 60, 69, 67], 1),
    // rhythmic values
    \dur, Pseq([2, 2, 1, 0.5, 0.5, 1, 1, 2, 2, 3], 1)
  ).play;
)


(
  SynthDef(\bass, { |out, freq = 440, gate = 1, amp = 0.5, slideTime = 0.17, ffreq = 1100, width = 0.15,
    detune = 1.005, preamp = 4|
    var sig,
    env = Env.adsr(0.01, 0.3, 0.4, 0.1);
    freq = Lag.kr(freq, slideTime);
    sig = Mix(VarSaw.ar([freq, freq * detune], 0, width, preamp)).distort * amp * EnvGen.kr(env, gate, doneAction: Done.freeSelf);
    sig = LPF.ar(sig, ffreq);
    Out.ar(out, sig ! 2)
  }).add;

  TempoClock.default.tempo = 132/60;

  p = Pxrand([
    Pbind(
      \instrument, \bass,
      \midinote, 36,
      \dur, Pseq([0.75, 0.25, 0.25, 0.25, 0.5], 1),
      \legato, Pseq([0.9, 0.3, 0.3, 0.3, 0.3], 1),
      \amp, 0.5, \detune, 1.005
    ),
    Pmono(\bass,
      \midinote, Pseq([36, 48, 36], 1),
      \dur, Pseq([0.25, 0.25, 0.5], 1),
      \amp, 0.5, \detune, 1.005
    ),
    Pmono(\bass,
      \midinote, Pseq([36, 42, 41, 33], 1),
      \dur, Pseq([0.25, 0.25, 0.25, 0.75], 1),
      \amp, 0.5, \detune, 1.005
    ),
    Pmono(\bass,
      \midinote, Pseq([36, 39, 36, 42], 1),
      \dur, Pseq([0.25, 0.5, 0.25, 0.5], 1),
      \amp, 0.5, \detune, 1.005
    )
  ], inf).play(quant: 1);
)

// totally cheesy, but who could resist?
(
  SynthDef(\kik, { |out, preamp = 1, amp = 1|
    var freq = EnvGen.kr(Env([400, 66], [0.08], -5)),
    sig = SinOsc.ar(freq, 0.5pi, preamp).distort * amp * EnvGen.kr(Env([0, 1, 0.8, 0], [0.01, 0.1, 0.2]), doneAction: Done.freeSelf);
    Out.ar(out, sig ! 2);
  }).add;

  // before you play:
  // what do you anticipate '\delta, 1' will do?
  k = Pbind(\instrument, \kik, \delta, 1, \preamp, 4.5, \amp, 0.32).play(quant: 1);
)

p.stop;
k.stop;
