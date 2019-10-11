(
  s.quit;
  s.options.inDevice = "Scarlett 2i4 USB";
  s.options.outDevice = "Scarlett 2i4 USB";
  s.options.memSize = 262144;
  s.options.sampleRate = 44100;
  s.options.blockSize = 128;
  s.options.hardwareBufferSize = 128;
  s.options.numBuffers = 1024 * 256;
  s.options.memSize = 8192 * 32;
  s.options.maxNodes = 1024 * 32;
  s.boot;
)

FreqScope.new;
s.meter;

(
// Moog bass
SynthDef(\SOSkick,
	{ arg out = 0, freq = 50, mod_freq = 5, mod_index = 5, sustain = 0.4, amp = 0.8, beater_noise_level = 0.025;
	var pitch_contour, drum_osc, drum_lpf, drum_env;
	var beater_source, beater_hpf, beater_lpf, lpf_cutoff_contour, beater_env;
	var kick_mix;
	pitch_contour = Line.kr(freq*2, freq, 0.02);
	drum_osc = PMOsc.ar(	pitch_contour,
				mod_freq,
				mod_index/1.3,
				mul: 1,
				add: 0);
	drum_lpf = LPF.ar(in: drum_osc, freq: 1000, mul: 1, add: 0);
	drum_env = drum_lpf * EnvGen.ar(Env.perc(0.005, sustain), 1.0, doneAction: 2);
	beater_source = WhiteNoise.ar(beater_noise_level);
	beater_hpf = HPF.ar(in: beater_source, freq: 500, mul: 1, add: 0);
	lpf_cutoff_contour = Line.kr(6000, 500, 0.03);
	beater_lpf = LPF.ar(in: beater_hpf, freq: lpf_cutoff_contour, mul: 1, add: 0);
	beater_env = beater_lpf * EnvGen.ar(Env.perc, 1.0, doneAction: 2);
	kick_mix = Mix.new([drum_env, beater_env]) * 2 * amp;
	Out.ar(out, [kick_mix, kick_mix])
	}

//DrumSynths SC Example - SOS Drums by Renick Bell, renick_at_gmail.com
// recipes from Gordon Reid in his Sound on Sound articles
// SOSkick -------
// http://www.soundonsound.com/sos/jan02/articles/synthsecrets0102.asp
// increase mod_freq and mod_index for interesting electronic percussion
	).add;
)

~x = Synth(\SOSkick, [\freq, 50])
s.freeAll

"./01.scd".load


(
PathName.new(".").entries {|f|
  f.fullPath.asString.load;
}
)

Require("./01.scd", always: true)

(
SynthDef(\kick_electro, {
    |out = 0, pan = 0, amp = 0.3|
    var body, bodyFreq, bodyAmp;
    var pop, popFreq, popAmp;
    var click, clickAmp;
    var snd;

    // body starts midrange, quickly drops down to low freqs, and trails off
    bodyFreq = EnvGen.ar(Env([261, 120, 51], [0.035, 0.08], curve: \exp));
    bodyAmp = EnvGen.ar(Env.linen(0.005, 0.1, 0.3), doneAction: 2);
    body = SinOsc.ar(bodyFreq) * bodyAmp;
    // pop sweeps over the midrange
    popFreq = XLine.kr(750, 261, 0.02);
    popAmp = EnvGen.ar(Env.linen(0.001, 0.02, 0.001)) * 0.15;
    pop = SinOsc.ar(popFreq) * popAmp;
    // click is spectrally rich, covering the high-freq range
    // you can use Formant, FM, noise, whatever
    clickAmp = EnvGen.ar(Env.perc(0.001, 0.01)) * 0.15;
    click = LPF.ar(Formant.ar(910, 4760, 2110), 3140) * clickAmp;

    snd = body + pop + click;
    snd = snd.tanh;

    Out.ar(out, Pan2.ar(snd, pan, amp));
//By Nathan Ho aka Snappizz
//http://sccode.org/1-523
}).add;
)

Synth(\kick_electro, [\amp, 1])

s.boot

Env([261, 120, 51], [0.035, 0.08], curve: \exp).plot



(
SynthDef("combs", {
	arg
	//Standard Arguments
	out = 0, pan = 0, amp = 0.1, freq = 440, gate = 1, att = 0.01, dec = 0.1, sus = 0.7, rel = 0.5,
	//Other Controls
	rate = 6, depth = 0.2, regen = -3, sweep = 16, rq = 0.5, harmonic = 1.5;

	var max, min, vibrato, snd, env, filterenv;

	// Setting some values for the filters:
	max = ((1 + depth) / freq);
	min = (1 / (freq * (1 + depth)));
	vibrato = LFNoise1.ar(rate).range(min, max);

	// Amplitude and filter cutoff envelopes
	env = Env.adsr(att, dec, sus, rel).kr(gate: gate, doneAction: 2);
	filterenv = Env.perc(att, rel).kr;
	filterenv = ((filterenv * sweep) + 1) * freq;

	// The core noise:
	snd = BrownNoise.ar(1);
	snd = CombL.ar(snd, max, vibrato, regen);
	snd = CombN.ar(snd, harmonic / freq, harmonic / freq, regen, env);

	// More filters and output stuff:
	snd = RHPF.ar(snd, freq * 4, rq);
	snd = RLPF.ar(snd, filterenv, rq, amp);
	snd = Limiter.ar(snd, amp);
	Out.ar(out, Pan2.ar(snd, pan));
},
metadata: (
	credit: "Josh Mitchell",
	category: \bass,
	tags: [\metallic, \bass, \synth, \pitched]
	)
).add
)

Synth(\combs, [\freq, 100])
s.freeAll

(
SynthDef("bassWarsaw", {
	arg
	//Standard Values:
	out = 0, freq = 440, gate = 1, amp = 0.5, pan = 0, att = 0.01, dec = 0.3, sus = 0.4, rel = 0.1,
	//Other Controls:
	slideTime = 0.17, cutoff = 1100, width = 0.15, detune = 1.005, preamp = 4;

	var snd, env;

	env = Env.adsr(att, dec, sus, rel).kr(gate: gate, doneAction: 2);
	freq = Lag.kr(freq, slideTime);
	snd = VarSaw.ar(freq: [freq, freq * detune], width: width, mul: preamp);
	snd = Mix(snd).distort;
	snd = snd * env;
	snd = LPF.ar(snd, cutoff, amp);

	Out.ar(out, Pan2.ar(snd, pan));
},
metadata: (
	credit: "James Harkins",
	category: \bass,
	tags: [\bass, \synth, \pitched]
	)
).add;
)

Synth(\bassWarsaw, [\freq, 60])
s.freeAll

(
SynthDef(\rhodey_sc, {
    |
    // standard meanings
    out = 0, freq = 440, gate = 1, pan = 0, amp = 0.1,
    // all of these range from 0 to 1
    vel = 0.8, modIndex = 0.2, mix = 0.2, lfoSpeed = 0.4, lfoDepth = 0.1
    |
    var env1, env2, env3, env4;
    var osc1, osc2, osc3, osc4, snd;

    lfoSpeed = lfoSpeed * 12;

    freq = freq * 2;

    env1 = EnvGen.ar(Env.adsr(0.001, 1.25, 0.0, 0.04, curve: \lin));
    env2 = EnvGen.ar(Env.adsr(0.001, 1.00, 0.0, 0.04, curve: \lin));
    env3 = EnvGen.ar(Env.adsr(0.001, 1.50, 0.0, 0.04, curve: \lin));
    env4 = EnvGen.ar(Env.adsr(0.001, 1.50, 0.0, 0.04, curve: \lin));

    osc4 = SinOsc.ar(freq * 0.5) * 2pi * 2 * 0.535887 * modIndex * env4 * vel;
    osc3 = SinOsc.ar(freq, osc4) * env3 * vel;
    osc2 = SinOsc.ar(freq * 15) * 2pi * 0.108819 * env2 * vel;
    osc1 = SinOsc.ar(freq, osc2) * env1 * vel;
    snd = Mix((osc3 * (1 - mix)) + (osc1 * mix));
    snd = snd * (SinOsc.ar(lfoSpeed) * lfoDepth + 1);

    // using the doneAction: 2 on the other envs can create clicks (bc of the linear curve maybe?)
    snd = snd * EnvGen.ar(Env.asr(0, 1, 0.1), gate, doneAction: 2);
    snd = Pan2.ar(snd, pan, amp);

    Out.ar(out, snd);
}).add;
)

Synth(\rhodey_sc, [\freq, 60, \modIndex, 0.3, \mix, 0.5, \lfoSpeed, 0.5, \lfoDepth, 0.5])
