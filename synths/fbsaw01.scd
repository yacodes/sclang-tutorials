SynthDef(\fbsaw01, {
  | freq = 220,
    atk = 0.01, rel = 1,
    amp = 0.5, out = 0 |
  var envelope, source, local;
  envelope = EnvGen.ar(Env.perc(atk, rel), doneAction: Done.freeSelf);

  source = Saw.ar(freq);
  4.do({ |i| source = AllpassC.ar(source, 0.03, (i + 1) * 0.01, (i + 1) * 0.25); });

  local = LocalIn.ar(2) * 0.98;
  local = LeakDC.ar(local);
  local = source + local;

  LocalOut.ar(local);

  local = LPF.ar(local, freq * 4);

  Out.ar(out, (local * envelope * amp).tanh);
}).add;
