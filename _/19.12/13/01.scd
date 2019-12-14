// Andy Farell — Designing Sound; 13. Shaping Sound

s.boot;
s.meter;

// Scaling signal
{SinOsc.ar(640)}.plot(maxval: 1, minval: -1);
{SinOsc.ar(640) * 0.5}.plot(maxval: 1, minval: -1);

// Shifting signal
{SinOsc.ar(640) * 0.5}.plot(maxval: 1, minval: -1);
{SinOsc.ar(640) * 0.5 + 0.5}.plot(maxval: 1, minval: -1);

// Inverting signal
{SinOsc.ar(640)}.plot(maxval: 1, minval: -1);
{SinOsc.ar(640) * -1}.plot(maxval: 1, minval: -1);

// Signal complement
{LFSaw.ar(640, 1, 0.5, 0.5)}.plot(maxval: 1, minval: -1);
{1 - LFSaw.ar(640, 1, 0.5, 0.5)}.plot(maxval: 1, minval: -1);

// Signal reciprocal
{LFSaw.ar(640, 1, 0.5, 0.5)}.plot(maxval: 1, minval: -1);
{1 / (LFSaw.ar(640, 1, 0.5, 0.5) + 1)}.plot(maxval: 1, minval: -1);
{((1 / (LFSaw.ar(640, 1, 0.5, 0.5) + 1)) * 2) - 1.5}.plot(maxval: 1, minval: -1);

// Min/max
{SinOsc.ar(640).min(0)}.plot(maxval: 1, minval: -1);
{SinOsc.ar(640).max(0)}.plot(maxval: 1, minval: -1);
{SinOsc.ar(640).clip(-0.5, 0.5)}.plot(maxval: 1, minval: -1);

// Square wave
{(SinOsc.ar(640) * 1e+09).clip(-0.9, 0.9)}.plot(maxval: 1, minval: -1);

// Triangle wave #1
(
  {
    var sig = LFSaw.ar(1290, 1, 0.5, 0.5) - 0.5;
    ((sig.clip(-0.5, 0) * -2) + (sig - 0.25)) * 4;
  }.plot(minval: -1, maxval: 1);
)

// Triangle wave #2
(
  {
    var sig = LFSaw.ar(1290, 1, 0.5, 0.5);
    min(sig, sig * -1 + 1) - 0.25 * 4;
  }.plot(minval: -1, maxval: 1);
)

// Square roots
(
  {
    // var sig = LFSaw.ar(1290, 1, 0.5, 0.5);
    var sig = SinOsc.ar(1290);
    // sig * sig;
    sig.sqrt;
  }.plot(minval: -1, maxval: 1);
)

// Curved envelopes
Env.new([1, 0, 0], [1, 0]).plot;
(Env.new([1, 0, 0], [1, 0], curve: -1)).plot;
(Env.new([1, 0, 0], [1, 0], curve: -2)).plot;

// Periodic functions
// Wrapping ranges
{LFSaw.ar(670, 1, 0.5, 0.5)}.plot(minval: -1, maxval: 1);
{(LFSaw.ar(670, 1, 0.5, 0.5) * 2).wrap(0, 1)}.plot(minval: -1, maxval: 1);

{EnvGen.ar(Env.new([0, 1], [1])).wrap(0, 1)}.plot

// Polynomials
(
  {
    // x * 2x
    var x = LFSaw.ar(670, 1, 0.5, 0.5);
    ((x) * (x * 2)) * 0.5;
  }.plot(minval: -1, maxval: 1);
)

(
  {
    // -18x^3 + 23x^2 - 5x
    var x = LFSaw.ar(670, 1, 0.5, 0.5);
    ((-18 * x.pow(3)) + (23 * x.pow(2)) - (5 * x)) * 0.45;
  }.plot(minval: -1, maxval: 1);
)

// Time-Dependent Signal Shaping
// Phase cancellation
{SinOsc.ar(440.0, 0.0) + SinOsc.ar(440, pi)}.plot(minval: -1, maxval: 1)
{SinOsc.ar(440.0, 0.0)}.plot(minval: -1, maxval: 1)
{SinOsc.ar(440.0, pi)}.plot(minval: -1, maxval: 1)


