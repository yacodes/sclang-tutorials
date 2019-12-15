"../14//01.scd".load;
s.boot;
s.reboot;

(
  SynthDef(\perc, {
    arg freq = 440, amp = 1, sustain = 1, out = 0;

    var signal = SinOsc.ar(freq);
    var env = EnvGen.ar(Env.perc, timeScale: sustain, doneAction: Done.freeSelf);

    signal = signal * env * amp;
    Out.ar(out, Pan2.ar(signal));
  }).add;
)

Synth(\perc)

Signal.sineFill(2**12, [1]).size;
Signal.sineFill(2**12, [1]).asWavetable.size;
Wavetable.sineFill(512, 1.0/[1, 2, 3, 4, 5, 6]).size;

s.freeAll

(
  b.free;
  ~amps = [1] ++ ({[0, exprand(0.05, 0.5)].choose}!31);
  b = Buffer.alloc(s, 2**12*2);
  ~sig = Wavetable.sineFill(
    size: 2**12,
    amplitudes: ~amps,//[1, 1/4, 1/6, 1/2],
    phases: 0!32,
  );

  b.loadCollection(~sig);
)

b.plot

{Osc.ar(b, MouseX.kr(100, 1000, 1), mul: 0.2!2)}.play
s.freeAll

2**13

b.plot

s.scope
~amps = [1] ++ ({[0, exprand(0.05, 0.5)].choose}!31);

// Shaper
(
  ~wt0 = Signal.sineFill(2**10, 1/(1..8), 0!8).asWavetable;
  ~wt1 = Signal.sineFill(2**10, [1, 0, 1/2, 1, 1/4], [0, 0, pi, 0, pi]).asWavetable;
)
~wt0.plot; ~wt1.plot;

(
  ~b0 = Buffer.loadCollection(s, ~wt0);
  ~b1 = Buffer.loadCollection(s, ~wt0);
)

(
  {
    var sig;
    sig = VOsc.ar();
  }.play
)
s.freeAll;
