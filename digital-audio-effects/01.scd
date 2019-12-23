s.queryAllNodes
s.plotTree;
s.freeAll

b = Bus.audio(s, 1)

{Out.ar(b, SinOsc.ar)}.play
s.freeAll
s.reboot

// Groups - Order of Operations
~g0 = Group.new(s);
~g1 = Group.after(~g0);
~g2 = Group.after(~g1);

// Audio busses
~b0 = Bus.audio(s, 1);
~b1 = Bus.audio(s, 1);

// Synth Def
(
  SynthDef(\micin, {
    arg micCh = 0, out = 0;
    var source;
    source = SoundIn.ar(micCh);
    Out.ar(out, source);
  }).add;
)

// Synth
a = Synth(\micin, [\out, 0], ~g0);
a.set(\out, 0); // left
a.set(\out, 1); // right
a.set(\out, ~b0);

// Router
(
  SynthDef(\router, {
    arg in, out;
    var source = In.ar(in);
    Out.ar(out, source);
  }).add;
)
b = Synth(\router, [\in, ~b0, \out, 0], ~g1);
b.set(\out, 0); // left
b.set(\out, 1); // right
b.set(\out, ~b0);


// Template
(
  SynthDef(\template, {
    | in, out, amp = 0.5,
      atk = 0.01, rel = 0.1, crv = -2,
      gate = 1 |
    var source, signal, envelope;
    envelope = EnvGen.ar(Env.asr(atk, 1, rel, crv), gate);
    source = In.ar(in);
    signal = FX(source);
    Out.ar(out, signal * amp * envelope);
  }).add;
)

// Reverb
(
  SynthDef(\verb, {
    | in, out, amp = 0.5,
      atk = 0.01, rel = 0.1, crv = -2,
      t60 = 1, damp = 0, sz = 1, dif = 0.707,
      gate = 1 |
    var source, signal, envelope;
    envelope = EnvGen.ar(Env.asr(atk, 1, rel, crv), gate);
    source = In.ar(in);
    signal = JPverb.ar(source, t60, damp, sz, dif);
    Out.ar(out, signal * amp * envelope);
  }).add;
)

(
  SynthDef(\bitcrush, {
    | in, out, amp = 0.5,
      atk = 0.01, rel = 0.1, crv = -2,
      rate = 44100, bit = 8,
      gate = 1 |
    var source, signal, envelope;
    envelope = EnvGen.ar(Env.asr(atk, 1, rel, crv), gate);
    source = In.ar(in);
    signal = Decimator(source, rate, bit);
    Out.ar(out, signal * amp * envelope);
  }).add;
)

(
  SynthDef(\micin, {
    arg micCh = 0, out = 0;
    var source;
    source = SoundIn.ar(micCh);
    Out.ar(out, source);
  }).add;
)

// Synth
a = Synth(\micin, [\out, 0], ~g0);
a.set(\out, 0); // left
a.set(\out, 1); // right
a.set(\out, ~b0);

b = Synth(\verb, [\in, ~b1, \out, 0], ~g2);
b.set(\out, 0); // left
b.set(\out, 1); // right
b.set(\out, ~b0);
b.set(\gate, 1);

c = Synth(\bitcrush, [\in, ~b0, \out, 0], ~g1);
c.set(\out, ~b1);
s.freeAll;
