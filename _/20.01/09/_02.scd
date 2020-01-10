(
//1. server config
s = Server.local;
s.options.outDevice_(
	"Built-in Output"
	//"Soundflower (2ch)"
	//"MOTU UltraLite mk3 Hybrid"
);
s.options.numOutputBusChannels_(2);
s.options.inDevice_("Built-in Microph");
s.options.numInputBusChannels_(2);
s.options.sampleRate_(44100);
s.options.memSize_(2.pow(20));
s.newBusAllocators;
ServerBoot.removeAll;
ServerTree.removeAll;
ServerQuit.removeAll;

//2. initialize global variables
~out = 0;
~path = PathName(thisProcess.nowExecutingPath).parentPath++"buffers/";

//3. define piece-specific functions
~makeBuffers = {
	b = Dictionary.new;
	PathName(~path).entries.do{
		arg subfolder;
		b.add(
			subfolder.folderName.asSymbol ->
			Array.fill(
				subfolder.entries.size,
				{
					arg i;
					Buffer.read(s, subfolder.entries[i].fullPath);
				}
			)
		);
	};
};

~makeBusses = {
	~bus = Dictionary.new;
	~bus.add(\reverb -> Bus.audio(s,2));
};

~cleanup = {
	s.newBusAllocators;
	ServerBoot.removeAll;
	ServerTree.removeAll;
	ServerQuit.removeAll;
};

~makeNodes = {
	s.bind({
		~mainGrp = Group.new;
		~reverbGrp = Group.after(~mainGrp);
		~reverbSynth = Synth.new(
			\reverb,
			[
				\amp, 1,
				\predelay, 0.1,
				\revtime, 1.8,
				\lpf, 4500,
				\mix, 0.35,
				\in, ~bus[\reverb],
				\out, ~out,
			],
			~reverbGrp
		);
	});
};

~makeEvents = {
	MIDIIn.connectAll;
	e = Dictionary.new;

	e.add(\event1 -> {
		~shakerSustain = Pbind(
			\instrument, \bpfbuf,
			\dur, Pwhite(0.2,0.7),
			\atk, Pexprand(2,4),
			\rel, Pexprand(3,5),
			\buf, b[\shakers][13].bufnum,
			\rate, Pwhite(-7.0,-4.0).midiratio,
			\spos, Pwhite(0, b[\shakers][13].numFrames/2),
			\amp, Pexprand(0.17,0.25),
			\freq, {rrand(85.0,105.0).midicps}!3,
			\rq, 0.005,
			\bpfmix, 0.97,
			\group, ~mainGrp,
			\out, ~bus[\reverb],
		).play;

		~drone = Pbind(
			\instrument, \bpfsaw,
			\dur, 1,
			\freq, 26.midicps,
			\detune, Pwhite(0.03,0.2),
			\rqmin, 0.08,
			\rqmax, 0.12,
			\cfmin, 50,
			\cfmax, 400,
			\atk, 2,
			\sus, 0.1,
			\rel, 2,
			\amp, 0.5,
			\group, ~mainGrp,
			\out, ~bus[\reverb],
		).play;
	});

	e.add(\event2 -> {
		Routine({
			~bellCloud = Pbind(
				\instrument, \bpfbuf,
				\dur, Pexprand(0.2,2),
				\atk, Pexprand(0.5,2),
				\rel, Pexprand(2,6),
				\buf, b[\deskBells][0],
				\rate, Pwhite(-7.5,-5.5).midiratio,
				\spos, Pwhite(5000,80000),
				\amp, Pexprand(2,5),
				\bpfmix, 0,
				\group, ~mainGrp,
				\out, ~bus[\reverb],
			).play;

			~bubbles = Pbind(
				\instrument, \bpfsaw,
				\dur, Pwhite(0.1,0.5),
				\freq, Pexprand(1,25),
				\detune, Pwhite(0.03, 0.2, inf),
				\rqmin, 0.1,
				\rqmax, 0.5,
				\cfmin, 50,
				\cfmax, 2000,
				\atk, 2,
				\sus, 0,
				\rel, Pexprand(3,8),
				\pan, Pwhite(-0.9,0.9),
				\amp, Pexprand(0.05,0.1),
				\group, ~mainGrp,
				\out, ~bus[\reverb],
			).play;

			4.wait;

			~shakerSustain.stop;
			~drone.stop;
		}).play(AppClock);
	});

	e.add(\event3 -> {
		~bellCloud.stop;
		~bubbles.stop;

		~bellTone = Pbind(
			\instrument, \bpfbuf,
			\dur, Pexprand(0.5,3),
			\atk, 2,
			\rel, 2,
			\buf, b[\deskBells][11],
			\rate, Pwhite(-0.08,0.08).midiratio,
			\spos, Pwhite(5000,20000),
			\amp, Pexprand(2,3.5),
			\bpfmix, 0,
			\group, ~mainGrp,
			\out, ~bus[\reverb],
		).play;

		~simpleMarimba = Pbind(
			\instrument, \bpfsaw,
			\dur, Prand([0.5,1,2,3],inf),
			\freq, Prand([1/2,3/4,1,3/2,2], inf),
			\detune, Pwhite(0,0.002),
			\rqmin, 0.005,
			\rqmax, 0.008,
			\cfmin, Prand([61,71,78,85,95].midicps,inf),
			\cfmax, Pkey(\cfmin) * Pwhite(1.008,1.025,inf),
			\atk, 3,
			\sus, 1,
			\rel, 5,
			\amp, 1,
			\group, ~mainGrp,
			\out, ~bus[\reverb],
		).play;
	});

	e.add(\event4 -> {
		~bellTone.stop;
		~simpleMarimba.stop;

		~chords = Pbind(
			\instrument, \bpfsaw,
			\dur, Pwhite(4.5,7.0),
			\midinote, Pxrand([
				[23,35,54,63,64],
				[45,52,54,59,61,64],
				[28,40,47,56,59,63],
				[42,52,57,61,63]
			], inf),
			\detune, Pexprand(0.05,0.2),
			\cfmin, 100,
			\cfmax, 1500,
			\rqmin, Pexprand(0.01,0.15),
			\atk, Pwhite(2.0,2.5),
			\rel, Pwhite(6.5,10.0),
			\ldb, 6,
			\amp, 0.2,
			\group, ~mainGrp,
			\out, ~bus[\reverb],
		).play;

		~marimba = Pbind(
			\instrument, \bpfsaw,
			\dur, Prand([1,0.5],inf),
			\freq, Prand([1/2,2/3,1,4/3,2,5/2,3,4,6,8],inf),
			\detune, Pwhite(0,0.1),
			\rqmin, 0.005,
			\rqmax, 0.008,
			\cfmin, Prand((Scale.major.degrees+64).midicps,inf) * Prand([0.5,1,2,4],inf),
			\cfmax, Pkey(\cfmin) * Pwhite(1.008,1.025),
			\atk, 3,
			\sus, 1,
			\rel, 5,
			\amp, 1,
			\group, ~mainGrp,
			\out, ~bus[\reverb],
		).play;
	});

	e.add(\event5 -> {
		~marimba.stop;
		~chords.stop;
	});

	e.add(\oneshot1 -> {
		12.do{
			Synth(
				\bpfsaw,
				[
					\atk, exprand(0.5,1.5),
					\rel, exprand(2.0,8.0),
					\c1, exprand(4,10.0),
					\c2, exprand(2.0,5).neg,
					\freq, exprand(8,60),
					\detune, rrand(0.1,4),
					\cfmin, 30,
					\cfmax, 400,
					\rqmin, 0.02,
					\rqmax, 0.08,
					\amp, exprand(0.5,0.9),
					\pan, rrand(-0.5,0.5),
					\out, ~bus[\reverb],
				],
				~mainGrp
			);
		};
	});

	e.add(\oneshot2 -> {
		15.do{
			Synth(
				\bpfbuf,
				[
					\atk, rrand(0.2,3.0),
					\sus, rrand(0.2,2.0),
					\rel, exprand(1.0,6.0),
					\c1, exprand(1,8),
					\c2, exprand(-8,-1),
					\buf, b[\shakers][13].bufnum,
					\rate, exprand(0.4,2.0),
					\bpfmix, 0,
					\amp, exprand(0.2,0.5),
					\pan, rrand(-0.9,0.9),
					\spos, rrand(0,100000),
					\out, ~bus[\reverb]
				],
				~mainGrp
			);
		};
	});

	e.add(\oneshot3 -> {
		15.do{
			Synth(
				\bpfbuf,
				[
					\atk, rrand(0.1,2.0),
					\sus, rrand(2.5,6.0),
					\rel, exprand(1.0,5.0),
					\c1, exprand(1,8),
					\c2, exprand(-8,-1),
					\buf, b[\shakers][13].bufnum,
					\rate, exprand(0.3,1.2),
					\freq, (Scale.major.degrees.choose+64 + [-12,0,12,24].choose).midicps,
					\rq, exprand(0.002,0.02),
					\bpfmix, 1,
					\amp, exprand(0.2,1.5),
					\pan, rrand(-0.9,0.9),
					\spos, rrand(0,100000),
					\out, ~bus[\reverb],
				],
				~mainGrp
			);
		};
	});

	MIDIdef.cc(\controller, {
		arg val, num;
		case
		{num==73 && val==127} {e[\event1].value;"event1".postln;}
		{num==74 && val==127} {e[\event2].value;"event2".postln;}
		{num==75 && val==127} {e[\event3].value;"event3".postln;}
		{num==76 && val==127} {e[\event4].value;"event4".postln;}
		{num==77 && val==127} {e[\event5].value;"event5".postln;}
		{num==82 && val==127} {e[\oneshot1].value;"oneshot1".postln;}
		{num==83 && val==127} {e[\oneshot2].value;"oneshot2".postln;}
		{num==84 && val==127} {e[\oneshot3].value;"oneshot3".postln;}
		{true} {nil};
	});
};

//4. register functions with ServerBoot/Quit/Tree
ServerBoot.add(~makeBuffers);
ServerBoot.add(~makeBusses);
ServerQuit.add(~cleanup);

//5. boot server
s.waitForBoot({

	s.sync;

	//6a. SynthDefs
	SynthDef(\bpfsaw, {
		arg atk=2, sus=0, rel=3, c1=1, c2=(-1),
		freq=500, detune=0.2, pan=0, cfhzmin=0.1, cfhzmax=0.3,
		cfmin=500, cfmax=2000, rqmin=0.1, rqmax=0.2,
		lsf=200, ldb=0, amp=1, out=0;
		var sig, env;
		env = EnvGen.kr(Env([0,1,1,0],[atk,sus,rel],[c1,0,c2]),doneAction:2);
		sig = Saw.ar(freq * {LFNoise1.kr(0.5,detune).midiratio}!2);
		sig = BPF.ar(
			sig,
			{LFNoise1.kr(
				LFNoise1.kr(4).exprange(cfhzmin,cfhzmax)
			).exprange(cfmin,cfmax)}!2,
			{LFNoise1.kr(0.1).exprange(rqmin,rqmax)}!2
		);
		sig = BLowShelf.ar(sig, lsf, 0.5, ldb);
		sig = Balance2.ar(sig[0], sig[1], pan);
		sig = sig * env * amp;
		Out.ar(out, sig);
	}).add;

	SynthDef(\bpfbuf, {
		arg atk=0, sus=0, rel=3, c1=1, c2=(-1),
		buf=0, rate=1, spos=0, freq=440, rq=1, bpfmix=0,
		pan=0, amp=1, out=0;
		var sig, env;
		env = EnvGen.kr(Env([0,1,1,0],[atk,sus,rel],[c1,0,c2]),doneAction:2);
		sig = PlayBuf.ar(1, buf, rate*BufRateScale.ir(buf),startPos:spos);
		sig = XFade2.ar(sig, BPF.ar(sig, freq, rq, 1/rq.sqrt), bpfmix*2-1);
		sig = sig * env;
		sig = Pan2.ar(sig, pan, amp);
		Out.ar(out, sig);
	}).add;

	SynthDef(\reverb, {
		arg in, predelay=0.1, revtime=1.8,
		lpf=4500, mix=0.15, amp=1, out=0;
		var dry, wet, temp, sig;
		dry = In.ar(in,2);
		temp = In.ar(in,2);
		wet = 0;
		temp = DelayN.ar(temp, 0,2, predelay);
		16.do{
			temp = AllpassN.ar(temp, 0.05, {Rand(0.001,0.05)}!2, revtime);
			temp = LPF.ar(temp, lpf);
			wet = wet + temp;
		};
		sig = XFade2.ar(dry, wet, mix*2-1, amp);
		Out.ar(out, sig);
	}).add;

	s.sync;

	//6b. register remaining functions
	ServerTree.add(~makeNodes);
	ServerTree.add(~makeEvents);
	s.freeAll;

	s.sync;

	"done".postln;
});
)
