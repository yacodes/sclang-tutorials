// Quarantine Live Stream #1: Livecoding using Ndefs in SuperCollider
// https://youtu.be/PJdyTTZERYs

(
  Ndef(\q3, {
	| freq = 444, pan = 0, amp = 0.5 |
	var signal;
	signal = SinOsc.ar(freq);
	signal = Pan2.ar(signal, pan, amp);
  }).play;
)

Ndef(\q3).set(\freq, 110);
Ndef(\q3).set(\freq, 444);
Ndef(\q3).play;
Ndef(\q3).stop;
Ndef(\q3).clear;
s.freeAll
s.reboot

// Abruptly freq change
Ndef(\q3).set(\freq, 444);

// Respect fadeTime
Ndef(\q3).fadeTime = 2;
Ndef(\q3).xset(\freq, 110);
Ndef(\q3).xset(\freq, 440);
Ndef(\q3).xset(\pan, -1);
Ndef(\q3).xset(\pan, 1);
Ndef(\q3).xset(\freq, rrand(80, 500), \pan, rrand(-1.0, 1.0));

s.freeAll

(
  // Adding FX
  Ndef(\q3)[1] = \filter -> {
	| in, freqShift = 1 |
	FreqShift.ar(in, freqShift);
  };
)

// Using NodeProxyRole (?)
Ndef(\q3).xset(\freqShift, 100);
Ndef(\q3).xset(\freqShift, 100, \wet1, 0.5);

(
  // Adding FX
  Ndef(\q3)[1] = \filter -> {
	| in, pitch = 0.5, pitchDispersion = 0.1, timeDispersion = 0.1 |
	// This thingy kinda fun
	PitchShift.ar(in, 0.25, pitch, pitchDispersion, timeDispersion);
  };
)

Ndef(\q3).fadeTime = 2;
Ndef(\q3).xset(\pitch, 0.1, \pitchDispersion, 0.5, \timeDispersion, 0.1);
Ndef(\q3).xset(\wet1, 0); // Remove the effect
Ndef(\q3).clear;

Ndef(\q3).gui;

// Change the range of the pitch argument from 0.25 to 10.0
Spec.specs[\freq]; // Default spec for \freq. Example

Spec.add(\pitchy, [0.25, 10.0, \lin, 0.0, 0.5, " piii"]);

Spec.specs[\pitchy];

(
  // Adding FX
  Ndef(\q3)[1] = \filter -> {
	| in, pitchy = 0.5, pitchDispersion = 0.1, timeDispersion = 0.1 |
	// This thingy kinda fun
	PitchShift.ar(in, 0.25, pitchy, pitchDispersion, timeDispersion);
  };
)

// Local specifications
Ndef(\q3).addSpec( /*...*/ );


Ndef(\q3).play;
Ndef(\q3).copy(\q4); // Copying Ndefs

(
  // Setting pattern (Pbind)
  Ndef(\q3)[999] = \pset -> Pbind(
	\dur, 4,
	\freq, Pwhite(500, 2000),
	\amp, 0.5
  );
)

Ndef(\q3).fadeTime = 2;
(
  // xset respects fadeTime
  Ndef(\q3)[999] = \xset -> Pbind(
	\dur, 4,
	\freq, Pwhite(500, 2000),
	\amp, 0.5,
	\pan, Pwhite(-1.0, 1.0),
  );
)

// Mapping Ndefs
Ndef(\squank, {| lfofreq = 1 | LFSaw.kr(lfofreq) });
Ndef(\squank2, {| lfofreq = 1 | LFSaw.kr(lfofreq).linlin(-1.0, 1.0, 40, 2500) });

// .map or .xmap
Ndef(\q3).map(\pan, Ndef(\squank));
Ndef(\q3).map(\pan, nil); // unmap
Ndef(\q3).map(\freq, Ndef(\squank2));
Ndef(\q3).play;
Ndef(\q3).gui;
Ndef(\q3).stop;

// We can map anything to each other just like in modular synths.
// And don't forget about `[999] = \xset -> Pbind` patterns.