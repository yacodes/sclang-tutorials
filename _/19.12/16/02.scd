(
SynthDef(\dxkBd1, {|t_trig = 1, basefreq = 45, overdrive = 2, len=0.5, att = 0.002, fgprop =0.3, fgdprop = 0.9, noisiness=0.2, lop = 1250, amp = 1, pan = 0, out = 0|

	//fgprop = frequency glide in proportion to freq
	//fgdprop = freq glide duration in proportion to dur
	//freq = fundamental
	var freqenv, noise, main, fgdur, fgact, env;
	fgdur = Clip.ir(len * fgdprop, 0, len); //real value of fgdprop
	fgact = fgprop*basefreq; //actual hz to glide over
	freqenv = EnvGen.ar(Env.perc(att, fgdur, fgact, -4),t_trig);
	freqenv = (freqenv + basefreq) + PinkNoise.ar(noisiness);
	main = SinOsc.ar(freqenv);
	main = LPF.ar(main, lop);
	env = EnvGen.ar(Env.perc(att, len, amp, -4), t_trig, doneAction: 2);
	main = main * env;
	main = (main * overdrive).tanh;
	main = Pan2.ar(main, pan);
	Out.ar(out, main);
}).add;
)

Synth(\dxkBd1)

(
  SynthDef(\perc, {
    | freq = 110, amp = 1, out = 0 |
    var envelope = EnvGen.kr(Env.perc, doneAction: Done.freeSelf);

    var ff = freq * LFNoise1.kr(2, 1).midiratio;
    var signal = Saw.ar(ff);
    signal = Ringz.ar(signal, XLine.ar(freq * 4, freq, 0.0001), 1, -64.dbamp)!2;
    signal = LPF.ar(signal, freq);
    signal = Resonz.ar(signal, {LFNoise1.ar(2).exprange(ff, ff * 2)}!2, 0.1);
    signal = Balance2.ar(signal[0], signal[1]);
    signal = (signal * amp * envelope).tanh;

    Out.ar(out, signal);
  }).add
)

Synth(\perc, [\amp, 1, \freq, 440]);

(
SynthDef(\dxkGong1, {|t_trig = 1, freq = 100, amp = 1, dr = 1, out = 0, pan = 0|

	var modsig, modf = freq * [1.16, 3.14, 1.005];
	var idx = [[0.01, 0.3],[0.01,0.38], [0.01, 0.5]] * modf;
	var idxscaler = Array.fill(idx.size, {|i| idx[i][1] - idx[i][0]});
	var modenv = Array.newClear(modf.size);
	var ampenv, carsig, lfo, output;

	lfo = SinOsc.ar(3, 0, XLine.kr(freq*0.005, freq*0.05, dr));

	modenv[0] = EnvGen.kr(
		Env(levels: [0,1,1,0], times: [0.75*dr, 0.24*dr, 0.01*dr]), t_trig,
		doneAction: 2);

	modenv[1] = EnvGen.kr(
		Env(levels: [0,1,0], times: [0.02*dr, 0.98*dr]), t_trig,
		doneAction: 2);

	modenv[2] = EnvGen.kr(
		Env(levels: [ 0, 0.3, 1, 0.5, 0], times: [0.15 * dr, 0.15 *dr, 0.45*dr, 0.25*dr]), t_trig,
		doneAction: 2);

	// Exp curve...
	ampenv = EnvGen.kr(
		Env(levels: [ 0, 1, 0.001], times: [0.002, dr - 0.002], curve: \exp), t_trig,
		doneAction: 2);

	modsig = Mix.new(SinOsc.ar(modf) * ((idx + idxscaler)*modenv));
	carsig = SinOsc.ar(freq + lfo + modsig)*modf.size.reciprocal;
	output = carsig * ampenv * amp;
	output = Pan2.ar(output, pan);
	Out.ar(out, output);

}).add;
)
