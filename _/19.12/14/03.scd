// ************************************
// Additive Synthesis Demo with QuNEO
// based on patch by http://sccode.org/1-4UO Bruno Ruviaro, 2013-07-22
// this version, blueprint@poetaster.de
// tested in SC 3.6 and 3.9 (including on the pi prynth platform)
// ************************************

/*
Use QuNEO default preset #1

Pads play 16 first partials of the harmonic series:

13 14 15 16
09 10 11 12
05 06 07 08
01 02 03 04

Long Slider controls fundamental frequency
Vertical Sliders control ADSR envelope
Top two horizontal sliders control the frequency and the resonance of a filter.

The pad note and velocity control the usual factors, freq. and amplitude.
The pad x / y control values control the frequency and depth of modulation.
The pad pressure controls the add amount of the lfo from x/y
and also the resonance of the filter.
*/

s.waitForBoot({

	// Some variables

	var notes = Array.newClear(64);
	var ints = Array.series(16, 36, 1);

	~att = 0.01;
	~dec = 0.3;
	~sus = 0.5;
	~rel = 1.0;
	~lpfFreq = 0.5;
	~lpfRes = 0.5;
	~fundamental = 110;
	~quNeoChannel = 0;

	MIDIIn.connectAll;

	//MIDIdef.freeAll;

	MIDIdef.noteOn(
		key: \noteOn,
		func: { arg vel, note;
			var node, partial;
	        node = notes.at(note);
			if ( node.notNil, { node.set(\gate,0); notes.put(note, nil) } );
			partial = note - 35; // start from 1
			notes[note] = Synth("addsynth", [
				\freq, ~fundamental * partial,
				\amp, vel.linlin(0, 127, 0.1,0.8),
				\att, ~att,
				\dec, ~dec,
				\sus, ~sus,
				\rel, ~rel,
				\lpfFreq, ~lpfFreq,
				\lpfRes, ~lpfRes])},
		noteNum: (29..127), // Ignore notes lower than 24 (= 46Hz)
		chan: ~quNeoChannel);

	MIDIdef.noteOff(
		key: \noteOff,
		func: {arg vel, note;
			notes[note].set(\gate,0);
			notes.put(note, nil);
		//("Note OFF "++ note).postln;
		},
		chan: ~quNeoChannel);

	MIDIdef.cc(
		key: \adsr,
		func: {arg val, ccnum;
			case
			{ccnum==6} {~att = val.linlin(0, 127, 0.01, 2)}
			{ccnum==7} {~dec = val.linlin(0, 127, 0.05, 1)}
			{ccnum==8} {~sus = val.linlin(0, 127, 0.25, 1)}
			{ccnum==9} {~rel = val.linlin(0, 127, 0.5, 2)}
			{ccnum==0} {~lpfFreq = val.linlin(0, 127, 0.1, 1.0)}
			{ccnum==1} {~lpfRes = val.linlin(0, 127, 0.0, 2.0)};
			[~att, ~dec, ~sus, ~rel, ~lpfFreq, ~lpfRes].round(0.01).postln},
		ccNum: [6,7,8,9,0,1]); // Vertical Sliders

	//pad controllers for various factors

   // vibrato add value + amplitude
	MIDIdef.cc(
		key: \synAmp,
		func: {arg val, ccnum, n;
			n = (ccnum - 23).linlin(1,48,1,16).round ; // map the pressure controller to it's note.
			n = n + 35 ; // offset to 36
			//("cc is "++ ccnum).postln;
			notes[n].set(\vibAdd,  val.linlin(0, 127, 0.1, 0.6));
			notes[n].set(\lpfRes,  val.linlin(0, 127, 0.1, 0.9));
		},
		ccNum: Array.series(50,23,3));

	// vibrato frequency
	MIDIdef.cc(
		key: \vibF,
		func: {arg val, ccnum, n;
			n = (ccnum - 23).linlin(1,48,1,16).round ; // map the x controller to vibrato freq
			n = n + 35 ; // offset to 36
			//("Note is "++ n).postln;
			notes[n].set(\vibFreq,  val.linlin(0, 127, 0.05, 0.99));
		},
		ccNum: Array.series(50,24,3));

       // vibrato amplitude
		MIDIdef.cc(
		key: \vibA,
		func: {arg val, ccnum, n;
			n = (ccnum - 23).linlin(1,48,1,16).round ; // map the y controller to the vibrato depth
			n = n + 35 ; // offset to 36
			//a("note is " ++ n).postln;
			notes[n].set(\vibAmp, val.linlin(0, 127, 0.1, 0.5));
		},
		ccNum: Array.series(50,25,3));


	MIDIdef.cc(
		key: \fundamental,
		func: {arg val, ccnum;
			~fundamental = val.linexp(0, 127, 55, 220);
			("Fundamental is "++~fundamental.round(0.1)++" Hz").postln},
		ccNum: 10);  // Long Slider

	// A synth

	SynthDef("addsynth", { arg freq = 440, amp = 0.1, gate = 1, att = 0.01, dec = 0.3, sus = 0.5, rel = 1,vibFreq=7, vibAmp=0,vibAdd=0.5,lpfFreq = 0.5, lpfRes = 0.5;
		var snd, env;
		lpfFreq = lpfFreq * (freq * 3) + ~fundamental;
		lpfRes = 1 - lpfRes * 0.9 + 0.1;
		env = EnvGen.ar(Env.adsr(att, dec, sus, rel, amp), gate, doneAction: 2);
		snd = SinOscFB.ar(freq, vibAmp, amp);
		snd = snd * SinOsc.kr(vibFreq*15, mul:vibAmp, add:vibAdd);
		snd = snd * env;
		//snd = snd * doneActionEnv * 0.5;
		Out.ar([0,1], RLPF.ar(snd, lpfFreq,lpfRes));
	}).add;

});

Synth(\addsynth)
s.freeAll


(
SynthDef(\kick,
	{
		|gate=1,t_trig=1,out=0,pan=0,amp=0.1,boost=4,attenuation=1,fmlevel = 0.5, noiselevel = 0.5, thumplevel=0.5,revlevel=0.1,revroomsize=0.8,revdamping=0.5,
		fmenvatttime=0.001,fmenvattcurve=0,fmenvdectime=0.1,fmenvdeccurve=0.3,
		noiseenvatttime=0.001,noiseenvattcurve=1,noiseenvdectime=0.1,noiseenvdeccurve=0.3,
		thumpenvatttime=0.001,thumpenvattcurve=1,thumpenvdectime=0.1,thumpenvdeccurve=0.3,
		fm1freq=292,fm2freq=838,fm3freq=393,fm1amt = 0.8,fm2amt=0.8,fmenvtofreq=0,
		noiselpf=20000,noisehpf=400,thumpenvtofreq=1,thumpcutoffmin=80,thumpcutoffmax=300,thumpfreqmultiplier=25,thumpfreqoffset=18|
		var audio, switch, fmenv, fm1, fm2, fm3, noise, noiseenv, thump, thumpenv;
		switch = Env.cutoff.kr(Done.freeSelf, gate);
		fmenv = Env([0,1,0],[fmenvatttime,fmenvdectime],[fmenvattcurve,fmenvdeccurve]).kr(Done.none, t_trig, 1, amp * fmlevel);
		fm1 = SinOsc.ar(fm1freq) * fm1amt.clip(0,1);
		fm2 = SinOsc.ar(fm2freq * fm1.exprange(0.1,10)) * fm2amt.clip(0,1);
		fm3 = SinOsc.ar(fm3freq * (fmenv * fmenvtofreq + 1) * fm2.exprange(0.1,10));
		noiseenv = Env([0,1,0],[noiseenvatttime,noiseenvdectime],[noiseenvattcurve,noiseenvdeccurve]).kr(Done.none, t_trig, 1, amp * noiselevel);
		noise = WhiteNoise.ar(noiseenv);
		noise = LPF.ar(noise,noiselpf.clip(100,20000));
		noise = HPF.ar(noise,noisehpf.clip(100,20000));
		thumpenv = Env([0,1,0],[thumpenvatttime,thumpenvdectime],[thumpenvattcurve,thumpenvdeccurve]).kr(Done.none, t_trig, 1, amp * thumplevel);
		thump = Mix((1..5).collect({
			|num|
			SinOsc.ar(0, Phasor.ar(t_trig, (thumpfreqmultiplier * num * 2 * pi + thumpfreqoffset) * (thumpenv * thumpenvtofreq + 1)/SampleRate.ir, 0, 2*pi));
		}));
		thump = LPF.ar(thump, thumpenv * (thumpcutoffmax - thumpcutoffmin) + thumpcutoffmin);
		audio = (fm3 * fmenv) + noise + (thump * thumpenv);
		audio = (audio * boost).tanh * attenuation;
		audio = FreeVerb.ar(audio,revlevel,revroomsize,revdamping);
		audio = Pan2.ar(audio,pan);
		Out.ar(out,audio);
	}
).add;
)

Synth(\kick)

s.plotTree


(
SynthDef.new("bd", {
    arg  n=0.8, nl = 0.02, start=110, end=1, l1=0.1, l2=0.3, exp=1.7;
    var boom;
    e = pow(Line.ar(0.9,0,l2),exp);

    boom = BBandPass.ar(WhiteNoise.ar(),freq:Line.ar(100,10,nl))*Line.ar(1,0,nl)*n+ SinOsc.ar(Line.ar(start, end, l1))*e;
    Out.ar(0,[boom,boom])

}).add;
)

(
  SynthDef(\perc, {
    arg freq = 40;
    var signal;
    var env = EnvGen.ar(Env.perc, doneAction: Done.freeSelf);

    var signal1 = SinOsc.ar(XLine.ar(freq * 16, freq, 0.01));
    var signal2 = Saw.ar(freq);
    signal2 = Resonz.ar(
      signal2,
      LFSaw.ar(2).range(freq, freq * 4),
      Line.ar(1, 0.001, 0.5),
    );

    signal2 = LPF.ar(signal2 * 16, freq * 2);

    signal = (signal1 + signal2) * env;
    signal = Pan2.ar(signal, 0);
    Out.ar(0, signal);
  }).add;
)

Synth(\perc, [\freq, 40]);
Synth(\bd);


(
	// cello like sound
	SynthDef(\cello, {
		|
		freq=440, amp=1.0, out=0, pan=0.0, rq=0.1,
		atk=0.01, dcy=0.1, sus=0.5, rls=0.4,
		gate=1, dur=2,
		aux=0, auxsend=0.1
		|
		var sig, env,width;
		env = EnvGen.ar(Env.adsr(atk, dcy, sus, rls), gate, doneAction:2);
		width = LFNoise2.kr(1).range(0.001, 0.01);
		sig = VarSaw.ar(freq+ SinOsc.ar(6,mul:Line.kr(0.0, 1, dur,doneAction:2)), width:width);
		sig = RLPF.ar(sig, freq*1, rq);
		sig = Decimator.ar(sig, 22050,2);
		sig = sig *env* amp;
		Out.ar(out, Pan2.ar(sig, pan));
		Out.ar(aux, sig*auxsend);
	}).add;
)


(
SynthDef(\prayer_bell, { |outbus, t_trig = 1, sing_switch = 0, freq = 2434, amp = 0.5, decayscale = 1, lag = 10, i_doneAction = 0|
  var sig, input, first, freqscale, mallet, sing;
  freqscale = freq / 2434;
  freqscale = Lag3.kr(freqscale, lag);
  decayscale = Lag3.kr(decayscale, lag);

  mallet = LPF.ar(Trig.ar(t_trig, SampleDur.ir)!2, 10000 * freqscale);
  sing = LPF.ar(
    LPF.ar(
      {
        PinkNoise.ar * Integrator.kr(sing_switch * 0.001, 0.999).linexp(0, 1, 0.01, 1) * amp
      } ! 2,
      2434 * freqscale
    ) + Dust.ar(0.1), 10000 * freqscale
  ) * LFNoise1.kr(0.5).range(-45, -30).dbamp;
  input = mallet + (sing_switch.clip(0, 1) * sing);


  sig = DynKlank.ar(`[
    [
      (first = LFNoise1.kr(0.5).range(2424, 2444)) + Line.kr(20, 0, 0.5),
      first + LFNoise1.kr(0.5).range(1,3),
      LFNoise1.kr(1.5).range(5435, 5440) - Line.kr(35, 0, 1),
      LFNoise1.kr(1.5).range(5480, 5485) - Line.kr(10, 0, 0.5),
      LFNoise1.kr(2).range(8435, 8445) + Line.kr(15, 0, 0.05),
      LFNoise1.kr(2).range(8665, 8670),
      LFNoise1.kr(2).range(8704, 8709),
      LFNoise1.kr(2).range(8807, 8817),
      LFNoise1.kr(2).range(9570, 9607),
      LFNoise1.kr(2).range(10567, 10572) - Line.kr(20, 0, 0.05),
      LFNoise1.kr(2).range(10627, 10636) + Line.kr(35, 0, 0.05),
      LFNoise1.kr(2).range(14689, 14697) - Line.kr(10, 0, 0.05)
    ],
    [
      LFNoise1.kr(1).range(-10, -5).dbamp,
      LFNoise1.kr(1).range(-20, -10).dbamp,
      LFNoise1.kr(1).range(-12, -6).dbamp,
      LFNoise1.kr(1).range(-12, -6).dbamp,
      -20.dbamp,
      -20.dbamp,
      -20.dbamp,
      -25.dbamp,
      -10.dbamp,
      -20.dbamp,
      -20.dbamp,
      -25.dbamp
    ],
    [
      20 * freqscale.pow(0.2),
      20 * freqscale.pow(0.2),
      5,
      5,
      0.6,
      0.5,
      0.3,
      0.25,
      0.4,
      0.5,
      0.4,
      0.6
    ] * freqscale.reciprocal.pow(0.5)
  ], input, freqscale, 0, decayscale);
  DetectSilence.ar(sig, doneAction: i_doneAction);
  Out.ar(outbus, sig);
}).add;
)

Synth(\prayer_bell)
s.freeAll

(
SynthDef(\flute, {
        | out = 0, freq = 440, amp = 1.0, a = 0.1, r = 0.1|
        //var fmod = 1; // clean
        //var fmod = LFCub.kr(freq:1/12).range(1, LFNoise2.kr(freq:12.0).range(1,1.1)); // tone deaf flute
        var fmod = LFCub.kr(freq:1/12).range(1, LFNoise2.kr(freq:12.0).range(1,1.02)); // flute-like sound
        var env = EnvGen.ar(Env.perc(a, r), levelScale:0.5, doneAction:2);
        var snd = SinOsc.ar(freq * fmod)!2;
        Out.ar(bus:out, channelsArray:(env*(amp*snd).tanh));
    }).add;
)

Synth(\flute)

(
SynthDef(\star, { arg out=0, amp=0.1, gate=1, pan=0, spread=0.8, freq=200, doneAction=2;
	var sig, sig1, sig2, sig3;
	var env1;
	var fspread;
	env1 = EnvGen.kr(Env([1,2,1],[1.7,0.8]), 1);
	fspread = 0.0007 + Rand(0,0.007);
	sig = SinOsc.ar(freq * ((0..7)/7 - 0.5 * fspread + 1));
	sig = sig * ( sig/(sig+1.1)*50 * env1 ).clip(0.5);
	sig1 = sig * (sig.abs > Rand(0.1,0.7));
	sig = SelectX.ar( EnvGen.kr(Env([0,1,0],[0.1+Rand(0,2.0),0.1+Rand(0,2.0)]), 1), [sig, sig1]);
	sig = sig * 2;
	sig = sig * EnvGen.ar(\adsr.kr(Env.adsr(1.01,0.1,1,1.1)),gate,doneAction:doneAction);
	sig = sig /10;
	sig = Splay.ar(sig, spread, amp, pan);
	Out.ar(out, sig);
}).add;
)

Synth(\star, [\freq, 200, \spread, 2, \amp, 0.4])
s.freeAll

(
SynthDef(\starlet, { arg out=0, amp=0.1, gate=1, pan=0, spread=0.8, freq=200, doneAction=2;
	var sig, sig1, sig2, sig3;
	var env1;
	var fspread;
	env1 = EnvGen.kr(Env([1,20,1],[1.7,0.8]), 1);
	fspread = 0.0007 + Rand(0,0.007)* env1;
	sig = SinOsc.ar(freq * ((0..7)/7 - 0.5 * fspread + 1) );
	sig1 = sig * ( sig/(sig+1.1)*50 * env1 ).clip(0.5);
	sig = SelectX.ar(\mix.kr(0.5), [sig, sig1]);
	sig = sig * 2;
	sig = sig * EnvGen.ar(\adsr.kr(Env.adsr(1.01,0.1,1,1.1)),gate,doneAction:doneAction);
	sig = sig /10;
	sig = Splay.ar(sig, spread, amp, pan);
	Out.ar(out, sig);
}).add;
)

Synth(\starlet, [\freq, 500, \amp, 0.4])
s.freeAll
