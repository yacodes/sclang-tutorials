// Chapter 11 - - Physical Modelling
s.freeAll;

(
  s.boot;
  s.meter;
  FreqScope.new(512, 512);
  s.scope;
)

// In physical modelling, as opposed to traditional synthesis types (AM, FM, granular,
// etc), we are not imitating the sound of an instrument, but rather simulating the instrument itself and the
// physical laws that are involved in the creation of a sound.In physical modelling of sound we typically
// operate with excitation and a resonant body.

// For a good text on physical modelling, check Julius O. Smith’s “Physical Audio Signal Processing”:
// http://ccrma.stanford.edu/∼jos/pasp/pasp.html

// Karplus-Strong synthesis (named after its authors)
// is a precursor of physical modelling and is good for synthesising strings and percussion sounds.
// we generate a short burst (the excitation)
{ Decay.ar(Impulse.ar(1), 0.1, WhiteNoise.ar) }.play
// we then wrap that noise in a fast repeating delay
{ CombL.ar(Decay.ar(Impulse.ar(1), 0.1, WhiteNoise.ar), 0.02, 0.005, 3) }.play
s.freeAll

// The repeat rate of the delay becomes the pitch of the string, so 0.001 is 1000 Hz, or in a reciprocal
// relationship. We could therefore write 440.reciprocal in the delayTime argument of the CombL, and
// it would give us a string sound of 440 Hz. The duration of the string is controlled by the decayTime
// argument. This is the basic ingredient of a string synthesizer, but for further development, you might
// want to consider applying filters to the noise, or perhaps use another type of noise. Also, the time of the
// burst (above 100 ms) will affect the sound heavily
{ RLPF.ar(CombL.ar(Decay.ar(Impulse.ar(2), 0.1, BrownNoise.ar), 0.02, 100.reciprocal, 3), 400, 1)!2 }.play
s.freeAll


(
  SynthDef(\ks_string, { arg note, pan, rand, delayTime;
    var x, y, env;
    env = Env.new(#[1, 1, 0],#[2, 0.001]);
    // A simple exciter x, with some randomness.
    x = Decay.ar(Impulse.ar(0, 0, rand), 0.1+rand, WhiteNoise.ar);
    x = CombL.ar(x, 0.05, note.reciprocal, delayTime, EnvGen.ar(env, doneAction:2));
    x = Pan2.ar(x, pan);
    Out.ar(0, LeakDC.ar(x));
  }).add;
)
(
  { // and play the synthdef
    20.do({
      Synth(\ks_string,
        [\note, [48, 50, 53, 58].midicps.choose,
        \pan, 1.0.rand2,
        \rand, 0.1+0.1.rand,
        \delayTime, 2+1.0.rand]
      );
      [0.125, 0.25, 0.5].choose.wait;
    });
  }.fork;
)
// here using patterns
(
  Pdef(\kspattern,
    Pbind(\instrument, \ks_string, // using our sine synthdef
      \note, Pseq.new([60, 61, 63, 66], inf).midicps, // freq arg
      \dur, Pseq.new([0.25, 0.5, 0.25, 1], inf), // dur arg
      \rand, Prand.new([0.2, 0.15, 0.15, 0.11], inf), // dur arg
      \pan, 1.0.rand2,
      \delayTime, 2+1.0.rand; // envdur arg
    )
  ).play;
)

// Compare using white noise and pink noise as an exciter,
// as well as using a resonant filter to filter the burst:
// white noise
(
  {
    var burstEnv, burst;
    burstEnv = EnvGen.kr(Env.perc(0, 0.01), gate: Impulse.kr(1.5));
    burst = WhiteNoise.ar(burstEnv);
    CombL.ar(burst, 0.2, 0.003, 1.9, add: burst);
  }.play;
)
// pink noise
(
  {
    var burstEnv, burst;
    burstEnv = EnvGen.kr(Env.perc(0, 0.01), gate: Impulse.kr(1.5));
    burst = PinkNoise.ar(burstEnv);
    CombL.ar(burst, 0.2, 0.003, 1.9, add: burst);
  }.play;
)
(
  // here we use RLPF (resonant low pass filter) to filter the white noise burst
  {
    var burstEnv, burst;
    burstEnv = EnvGen.kr(Env.perc(0, 0.01), gate: Impulse.kr(1.5));
    burst = RLPF.ar(WhiteNoise.ar(burstEnv), MouseX.kr(100, 12000), MouseY.kr(0.001, 0.999));
    CombL.ar(burst, 0.2, 0.003, 1.9, add: burst);
  }.play;
)
s.freeAll

// SuperCollider comes with a plug called Pluck which is an implementation of the Karplus-Strong synthesis.
// This should be more effective than the examples above, but of similar sound.
{Pluck.ar(WhiteNoise.ar(0.1), Impulse.kr(2), MouseY.kr(220, 880).reciprocal, MouseY.kr(220,880).reciprocal, 10, coef:MouseX.kr(-0.1, 0.5)) !2 }.play(s)
s.freeAll

(
  SynthDef(\pluck, {arg freq=440, trig=1, time=2, coef=0.1, cutoff=2, pan=0;
    var pluck, burst;
    burst = LPF.ar(WhiteNoise.ar(0.5), freq*cutoff);
    pluck = Pluck.ar(burst, trig, freq.reciprocal, freq.reciprocal, time, coef:coef);
    Out.ar(0, Pan2.ar(pluck, pan));
  }).add;
)
Synth(\pluck);
Synth(\pluck, [\coef, 0.01]);
Synth(\pluck, [\coef, 0.3]);
Synth(\pluck, [\coef, 0.7]);
Synth(\pluck, [\coef, 0.3, \time, 0.1]);
Synth(\pluck, [\coef, 0.3, \time, 5]);
Synth(\pluck, [\coef, 0.2, \time, 5, \cutoff, 1]);
Synth(\pluck, [\coef, 0.2, \time, 5, \cutoff, 2]);
Synth(\pluck, [\coef, 0.2, \time, 5, \cutoff, 5]);
Synth(\pluck, [\coef, 0.2, \time, 5, \cutoff, 15]);
(
  // A guitar that might need a little distortion
  Pbind(\instrument, \pluck,
    \freq, Pseq([72, 70, 67,65, 63, 60, 48], inf).midicps,
    \dur, Pseq([0.5, 0.5, 0.375, 0.125, 0.5, 2], 1),
    \cutoff, Pseq([15, 10, 5, 2, 10, 10, 15], 1)
  ).play
)

// Biquad filter
// In SuperCollider, the SOS UGen is a second order biquad filter that can be used to create various
// interesting sounds. We could start with simple glass-like sound:
{SOS.ar(Impulse.ar(2), 0.0, 0.05, 0.0, MouseY.kr(1.45, 1.998, 1), MouseX.kr(-0.999, -0.9998, 1))!2}.play
s.freeAll

// And with slight changes we have a more woody type of sound:
(
  SynthDef(\marimba, {arg out=0, amp=0.1, t_trig=1, freq=100, rq=0.006;
    var env, signal;
    var rho, theta, b1, b2;
    b1 = 1.987 * 0.9889999999 * cos(0.09);
    b2 = 0.998057.neg;
    signal = SOS.ar(K2A.ar(t_trig), 0.3, 0.0, 0.0, b1, b2);
    signal = RHPF.ar(signal*0.8, freq, rq) + DelayC.ar(RHPF.ar(signal*0.9, freq*0.99999, rq*0.999), 0.02, 0.01223);
    signal = Decay2.ar(signal, 0.4, 0.3, signal);
    DetectSilence.ar(signal, 0.01, doneAction:2);
    Out.ar(out, signal*(amp*0.4)!2);
  }).add;
)
Synth(\marimba, [\freq, 220])

(
  Pbind(
    \instrument, \marimba,
    \midinote, Prand([[1,5], 2, [3, 5], 7, 9, 3], inf) + 48,
    \dur, 0.2
  ).play;
)

// Or perhaps
(
  SynthDef(\wood, {arg out=0, amp=0.3, pan=0, sustain=0.5, t_trig=1, freq=100, rq=0.06;
    var env, signal;
    var rho, theta, b1, b2;
    b1 = 2.0 * 0.97576 * cos(0.161447);
    b2 = 0.9757.squared.neg;
    signal = SOS.ar(K2A.ar(t_trig), 1.0, 0.0, 0.0, b1, b2);
    signal = Decay2.ar(signal, 0.4, 0.8, signal);
    signal = Limiter.ar(Resonz.ar(signal, freq, rq*0.5), 0.9);
    env = EnvGen.kr(Env.perc(0.00001, sustain, amp), doneAction:2);
    Out.ar(out, Pan2.ar(signal, pan)*env);
  }).add;
)
Synth(\wood, [\freq, 1201]);
(
  Pbind(
    \instrument, \wood,
    \midinote, Prand([[1,5], 2, [3, 5], 7, 9, 3], inf) + 48,
    \dur, 0.2
  ).play;
)

// Waveguide synthesis
