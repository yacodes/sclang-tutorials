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
