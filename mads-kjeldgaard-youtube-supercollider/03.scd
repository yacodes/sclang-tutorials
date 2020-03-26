// Quarantine Live Stream #3: Let's make a SynthDef and play it using patterns!
// Part 1: https://youtu.be/4x-v0UHDL9g
// Part 2: https://youtu.be/QjTSynHkH_4

(
  SynthDef.new(\q, {
	| attack = 0.1, release = 0.9,
	  dur = 1,
	  freq = 440,
	  amp = 0.25, pan = 0, out = 0 |

	var signal;
	var envelope;

	envelope = EnvGen.ar(Env.perc(attack, release), timeScale: dur);

	signal = LFTri.ar(freq);
	signal = Pan2.ar(signal, pan, envelope * amp);

	Out.ar(out, signal);
  }).add;
)

Synth(\q, [\freq, 110, \amp, 1, \dur, 2]);
s.scope
FreqScope.new