s.boot

s.meter
s.plotTree
FreqScope.new


(
  SynthDef.new(\kick, {|freq = 60, amp = 0.4, pan = 0.0|
    var sig, env;

    var osc = SinOsc.ar();

    env = EnvGen.kr(Env.perc(0.0001, 1, 1, -8), doneAction: Done.freeSelf);

    sig = osc;

    Out.ar(0, Pan2.ar(sig * env, pan))
  }).add(s)
)

(
  SynthDef.new(\kick, {|pan = 0.0, sustain = 2, n = 110|
    var env = EnvGen.kr(Env.perc(0.02, sustain, 1, -8), doneAction: Done.freeSelf);
    var noise = LPF.ar(WhiteNoise.ar(), Env.new([n * 10, n, 20], [0, sustain], -2).kr, mul: 5);
    var osc = Resonz.ar(SinOsc.ar(Env.new([n * 10, n, 20], [0, sustain], -1).kr), n, 0.9, mul: 1);
    var sig = Mix.new([noise, osc]);
    Out.ar(0, Pan2.ar(sig * env, pan));
  }).add(s)
)

s.reboot

(
  SynthDef(\ch3synth1, {arg freq=333, amp=0.4, pan=0.0, dur=0.41; // the arguments
    var signal, env;
    env = EnvGen.ar(Env.perc(0.001, dur), doneAction:2); // doneAction gets rid of the synth
    signal = LFTri.ar(freq, 0, amp) * env; // the envelope multiplies the signal
    signal = Pan2.ar(signal, pan);
    Out.ar(0, signal);
  }).add;
)

Env.perc(0.0001, 1, 1, -8).plot

Synth.new(\ch3synth1)

s.freeAll
