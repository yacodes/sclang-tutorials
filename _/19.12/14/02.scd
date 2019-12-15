"./01.scd".load;
s.boot;
Window.closeAll

s.options.memSize_(65536 * 4);
s.reboot;
s.reboot;

(
SynthDef(\soskick, {
  arg out, pan, amp = 1, freq = 50, pitch1 = 5, voice = 5, sustain = 1, nl = 0.025;

  var pitchContour, drumOsc, drumLpf, drumEnv, env;
  var beaterSource, beaterHpf, beaterLpf, lpfCutoffContour, beaterEnv;
  var kickMix, snd;

  pitchContour = Line.kr(freq * 2, freq, 0.02);
  drumOsc = PMOsc.ar(pitchContour, pitch1, voice / 1.3, mul: 1, add: 0);
  drumLpf = LPF.ar(in: drumOsc, freq: 1000, mul: 1, add: 0);
  env = EnvGen.kr(Env.perc(0.005, sustain), 1.0, doneAction: Done.freeSelf);
  drumEnv = drumLpf * env;

  beaterSource = WhiteNoise.ar(nl);
  beaterHpf = HPF.ar(in: beaterSource, freq: 500, mul: 1, add: 0);

  lpfCutoffContour = Line.kr(6000, 500, 0.03);

  beaterLpf = LPF.ar(in: beaterHpf, freq: lpfCutoffContour, mul: 1, add: 0);
  beaterEnv = beaterLpf * EnvGen.kr(Env.perc, 1.0);

  kickMix = ((drumEnv + beaterEnv) * amp)!2;

  // kickMix = (FreeVerb.ar(kickMix))!2;

  Out.ar(out, kickMix);
},
metadata: (
  credit: "Renick Bell",
  category: \drums,
  tags: [\pitched, \bass, \sos]
)).add;
);

(
  Pbindef(\kick,
    \instrument, \soskick,
    \dur, Prand.new([0.125, 0.25, 1, 2][2..3], inf),
    \out, 0,
    \freq, Prand.new(((Scale.minor.ratios * 30) + 30)[0..3], inf),
    \pitch1, 1,
    // \pitch1, Prand.new([1, 2, 3, 4, 5, 6, 7, 8], inf),
    \sustain, Prand.new([0.5, 1, 2, 3, 4][4..4], inf),
    // \voice, Prand.new([1, 2, 3, 4, 5, 6, 7, 8], inf),
    // \nl, Prand.new([0, 0.025], inf),
    \amp, 0.6
  ).stop;
)

(
SynthDef(\perc, {
  arg amp = 1, pan = 0, out = 0, freq = 440, sustain = 1;

  var ratios = Scale.minor.ratios;
  var size = ratios.size;
  var freqs = ratios * freq;

  var env = EnvGen.ar(Env.perc, timeScale: sustain, doneAction: Done.freeSelf);
  var signal = DynKlang.ar(`[ratios * freq, Array.fill(size, {rrand(0.3, 1)}), Array.fill(size, pi)]);
  signal = GVerb.ar(signal);
  signal = signal * 0.05;
  // signal = Resonz.ar(signal, XLine.ar(freqs[freqs.size - 1], freqs[0], 1), 0.01);
  signal = Resonz.ar(signal, XLine.ar(freqs[freqs.size - 1] * 16, freqs[0], sustain / 32), XLine.ar(1, 0.001, sustain / 32));
  // Ringz.ar(in: 0.0,  freq: 440.0,  decaytime: 1.0,  mul: 1.0,  add: 0.0)
  // Resonz.ar(in: 0.0,  freq: 440.0,  bwr: 1.0,  mul: 1.0,  add: 0.0)

  // XLine.ar(start: 1.0,  end: 2.0,  dur: 1.0,  mul: 1.0,  add: 0.0,  doneAction: 0)

  Out.ar(out, (signal * amp * env)!2);
}).add;
)


(
SynthDef(\perc, {
  arg amp = 1, pan = 0, out = 0, freq = 440, sustain = 1;

  var env = EnvGen.ar(Env.perc, timeScale: sustain, doneAction: Done.freeSelf);
  var signal = WhiteNoise.ar;
  signal = Resonz.ar(signal, XLine.ar(freq * 2, freq, sustain / 512), LFSaw.ar(64).range(0.0001, 0.1));
  signal = Resonz.ar(signal, freq, 0.01);
  signal = GVerb.ar(signal) * 8;
  // GVerb.ar(in: nil,  roomsize: 10,  revtime: 3,  damping: 0.5,  inputbw: 0.5,  spread: 15,  drylevel: 1,  earlyreflevel: 0.7,  taillevel: 0.5,  maxroomsize: 300,  mul: 1,  add: 0)
  signal = signal * 4;
  signal = signal.distort.softclip;
  signal = signal.distort.softclip;

  Out.ar(out, (signal * amp * env)!2);
}).add;
)

// LFPar.ar(8).range(0.0001, 0.1)) * 8;

{ LFGauss.ar(0.01, 0.6) }.plot;

{LFPar.ar(440, 0, 1, 0) / 2 + 0.5}.plot(minval: -1, maxval: 1);

(
  Pbindef(\perc,
    \instrument, \perc,
    \dur, Prand.new([0.125, 0.25, 1, 2][0..2], inf),
    \out, 0,
    \freq, Prand.new(((Scale.minor.ratios * 500) + 500), inf),
    \sustain, 1,
    \amp, 0.9
  ).play;
)
s.freeAll

(
SynthDef.new("bd", {
    arg  n=0.8, nl = 0.02, start=110, end=1, l1=0.1, l2=0.3, exp=1.7;
    var boom;
    e = pow(Line.ar(0.9,0,l2),exp);

    boom = BBandPass.ar(WhiteNoise.ar(),freq:Line.ar(100,10,nl))*Line.ar(1,0,nl)*n+ SinOsc.ar(Line.ar(start, end, l1))*e;
    Out.ar(0,[boom,boom])

}).add;
)
Synth(\bd)

Scale.directory()

rand

1.rand
rrand(0.01, 1)

[1,2,3,4][[1, 2, 3, 4].size - 1]

(
SynthDef("sn", {
    arg startPitch = 6000, endPitch=60, clickLevel=0.7, pitchRel = 0.11, noiseLevel=1, noiseRel= 0.3;
    var pitchEnv = EnvGen.ar(Env([startPitch,410,endPitch],[0.005,0.01], curve:\exp));
    var clickOsc = SinOsc.ar(pitchEnv);
    var clickEnv = EnvGen.ar(Env.perc(0.001, pitchRel))*clickLevel;
    var noiseOsc = PinkNoise.ar();
    var noiseEnv = EnvGen.ar(Env.perc(0.01, noiseRel))*noiseLevel;
    var snd = clickOsc *clickEnv + noiseOsc * noiseEnv;
    Out.ar(0,Pan2.ar(snd, 0, 1));
}).add;
)

(
SynthDef("tom", {
    arg startPitch = 6000, endPitch=60, clickLevel=0.7, pitchRel = 0.11, noiseLevel=1, noiseRel= 0.3;
    var pitchEnv = EnvGen.ar(Env.perc(0.01, pitchRel));

    var clickOsc = SinOsc.ar(pitchEnv*(startPitch-endPitch)+endPitch);
    var clickEnv = EnvGen.ar(Env.perc(0.001, pitchRel))*clickLevel;
    var noiseOsc = PinkNoise.ar();
    var noiseEnv = EnvGen.ar(Env.perc(0.01, noiseRel))*noiseLevel;
    var snd =  noiseOsc * noiseEnv +clickOsc *clickEnv;
    Out.ar(0,Pan2.ar(snd, 0, 1));
}).add;
)

Synth(\tom)
