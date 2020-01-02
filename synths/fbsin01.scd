SynthDef(\fbsin01, {
  | freq = 220,
  atk = 0.01, rel = 1,
  amp = 0.5, out = 0 |
  var envelope, source, feedback;

  source = SinOsc.ar(freq);
  8.do({|i| source = AllpassC.ar(source, 0.08, (i+1) * 0.001, 0.4)});
  envelope = EnvGen.ar(Env.perc(atk, rel), doneAction: Done.freeSelf);

  feedback = LocalIn.ar(2) * 0.9;
  feedback = AllpassC.ar(feedback, 0.001, 0.001, 0.01);
  feedback = OnePole.ar(feedback, 0.75);
  feedback = source + feedback;
  feedback = Limiter.ar(feedback);
  feedback = LeakDC.ar(feedback);

  LocalOut.ar(feedback);

  Out.ar(out, (feedback * envelope * amp));
}).add;
