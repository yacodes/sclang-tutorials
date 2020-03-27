"../../_/19.12/14/01.scd".load;
s.boot;
s.quit;
s.plotTree;
Window.closeAll;

(
  // Create groups
  ~groups = ();
  ~groups.root = Group.new(s);
  ~groups.sources = Group.new(~groups.root, \addToHead);
  ~groups.effects = Group.new(~groups.root, \addToTail);

  // Create busses
  ~busses = ();
  ~busses.hardware = 0;
  ~busses.effects = Bus.audio(s, 1);
)

(
  SynthDef(\saw, {
    | freq = 110,
	  atk = 0.01, rel = 0.5,
	  amp = 0.5, out = 0 |
    var signal = Saw.ar(freq);
    var env = EnvGen.kr(Env.perc(atk, rel), gate: LFSaw.kr(1));
    Out.ar(out, signal * env * amp);
  }).add;
)

(
  SynthDef(\rev, {
    | mix = 0.5,
      in = 0, out = 0 |
    var signal;

    signal = In.ar(in, 1);
	signal = DelayN.ar(signal, 0.048, 0.048);
	signal = Mix.fill(10, { CombL.ar(signal, 0.1, rrand(0.01, 0.1), 5) });
	10.do({ signal = AllpassC.ar(signal, 0.051, [rrand(0.01, 0.05), rrand(0.01, 0.05), 1]) });

    Out.ar(out, signal * 0.2);
  }).add;
)

(
  SynthDef(\schroeder, {
	| mix = 0.5,
	  in = 0, out = 0 |
	var input, sig, delrd, output, deltimes;

	input = In.ar(in, 2);
	delrd = LocalIn.ar(4);

	output = input + delrd[[0, 1]];

	sig = [
	  output[0] + output[1],
	  output[0] - output[1],
	  delrd[2] + delrd[3],
	  delrd[2] - delrd[3],
	];
	sig = [
	  sig[0] + sig[2],
	  sig[1] + sig[3],
	  sig[0] - sig[2],
	  sig[1] - sig[3],
	];
	sig = sig * [0.4, 0.37, 0.33, 0.3];

	deltimes = [101, 143, 165, 177] * 0.001 - ControlDur.ir;

	LocalOut.ar(DelayC.ar(sig, deltimes, deltimes));

	Out.ar(out, output);
  }).add;
)

s.meter
FreqScope.new

~busses;
~groups;

~signal = Synth(\saw, [\rel, 0.5, \out, ~busses.effects], ~groups.sources);
~effect = Synth(\rev, [\in, ~busses.effects, \out, ~busses.hardware], ~groups.effects);
~effect = Synth(\schroeder, [\in, ~busses.effects, \out, ~busses.hardware], ~groups.effects);
~groups.sources.freeAll;
~groups.effects.freeAll;
s.freeAll;

// References
// * https://composerprogrammer.com/teaching/supercollider/sctutorial/6.4%20Effects%201.html
// * https://en.wikibooks.org/wiki/Designing_Sound_in_SuperCollider/Schroeder_reverb
