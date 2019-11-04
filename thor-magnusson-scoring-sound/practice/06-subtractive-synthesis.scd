// Chapter 6 - Suptractive Synthesis
s.freeAll;

(
  s.boot;
  s.meter;
  FreqScope.new(512, 400);
  s.scope;
)

{WhiteNoise.ar(0.4)}.play;
{PinkNoise.ar(1)}.play;
{BrownNoise.ar(1)}.play;
{Crackle.ar(XLine.kr(0.99, 2, 10), 0.4)!2}.play;
{LFDNoise0.ar(XLine.kr(1000, 20000, 10), 0.1)!2}.play;
{LFClipNoise.ar(XLine.kr(1000, 20000, 10), 0.1)!2}.play;
{Impulse.ar(80, 0.7)!2}.play;
{Impulse.ar(4, 0.7)}.play;
// Dust (random impulses)
{Dust.ar(80)}.play;
{Dust.ar(4)}.play;
s.freeAll;

{WhiteNoise.ar(1) * EnvGen.ar(Env.perc(0.001,0.3), doneAction:2)!2}.play;
{LPF.ar(WhiteNoise.ar(1), 3300) * EnvGen.ar(Env.perc(0.001,0.5), doneAction:2)!2}.play;

(
  fork{
    100.do({
      {LPF.ar(WhiteNoise.ar(1), MouseX.kr(200,20000, 1))
      * EnvGen.ar(Env.perc(0.00001, MouseY.kr(1, 0.1, 1)), doneAction:2)}.play;
      1.wait;
    });
  }
)

{LPF.ar(WhiteNoise.ar(0.4), MouseX.kr(100, 20000).poll(20, "cutoff"))}.play;
{RLPF.ar(WhiteNoise.ar(0.4), MouseX.kr(100, 20000).poll(20, "cutoff"), MouseY.kr(0.01, 1).poll(20, "quality"))}.play;
s.freeAll;

(
  {
    var signal;
    var delaytime = MouseX.kr(0.000022675, 0.001); // from a sample
    signal = Saw.ar(220, 0.5);
    d = DelayC.ar(signal, 0.6, delaytime);
    (signal + d).dup
  }.play
)
s.freeAll;

// low pass filter
{LPF.ar(WhiteNoise.ar(0.4), MouseX.kr(40,20000,1)!2) }.play;
// low pass filter with XLine
{LPF.ar(WhiteNoise.ar(0.4), XLine.kr(40,20000, 3, doneAction:2)!2) }.play;
// high pass filter
{HPF.ar(WhiteNoise.ar(0.4), MouseX.kr(40,20000,1)!2) }.play;
// band pass filter (the Q is controlled by the MouseY)
{BPF.ar(WhiteNoise.ar(0.4), MouseX.kr(40,20000,1), MouseY.kr(0.01,1)!2) }.play;
// Mid EQ filter attenuates or boosts a frequency band
{MidEQ.ar(WhiteNoise.ar(0.024), MouseX.kr(40,20000,1), MouseY.kr(0.01,1), 24)!2 }.play;
// what's happening here?
(
  {
    var signal = MidEQ.ar(WhiteNoise.ar(0.4), MouseX.kr(40,20000,1), MouseY.kr(0.01,1), 24);
    BPF.ar(signal, MouseX.kr(40,20000,1), MouseY.kr(0.01,1)) !2
  }.play;
)
s.freeAll;

(
  {
    BPF.ar(
      WhiteNoise.ar(0.4),
      MouseX.kr(100, 10000).poll(20, "cutoff"),
      MouseY.kr(0.01, 0.9999).poll(20, "rQ")
    )
  }.play
)
s.freeAll;

// resonant low pass filter
(

  {
    RLPF.ar(
      Saw.ar(222, 0.4),
      MouseX.kr(100, 12000).poll(20, "cutoff"),
      MouseY.kr(0.01, 0.9999).poll(20, "rQ")
    )
  }.play;
)
s.freeAll;
// resonant high pass filter
(
  {
    RHPF.ar(
      Saw.ar(222, 0.4),
      MouseX.kr(100, 12000).poll(20, "cutoff"),
      MouseY.kr(0.01, 0.9999).poll(20, "rQ")
    )
  }.play;
)

// resonant filter
{ Resonz.ar(WhiteNoise.ar(0.5), MouseX.kr(40,20000,1), 0.1)!2 }.play
// a short impulse won't resonate
{ Resonz.ar(Dust.ar(0.5), 2000, 0.1) }.play
// for that we use Ringz
{ Ringz.ar(Dust.ar(2, 0.6), MouseX.kr(200,6000,1), 2) }.play
// X is frequency and Y is ring time
{ Ringz.ar(Impulse.ar(4, 0, 0.3), MouseX.kr(200,6000,1), MouseY.kr(0.04,6,1)) }.play
{ Ringz.ar(Impulse.ar(LFNoise2.ar(2).range(0.5, 4), 0, 0.3), LFNoise2.ar(0.1).range(200,3000), LFNoise2.ar(2).range(0.04,6,1)) }.play
{ Mix.fill(10, {Ringz.ar(Impulse.ar(LFNoise2.ar(rrand(0.1, 1)).range(0.5, 1), 0, 0.1), LFNoise2.ar(0.1).range(200,12000), LFNoise2.ar(2).range(0.04,6,1)) })}.play
{ Formlet.ar(Impulse.ar(4, 0.9), MouseX.kr(300,2000), 0.006, 0.1) }.play;
{ Formlet.ar(LFNoise0.ar(4, 0.2), MouseX.kr(300,2000), 0.006, 0.1) }.play;
s.freeAll;

{ Ringz.ar(Dust.ar(3, 0.3), 440, 2) + Ringz.ar(Dust.ar(3, 0.3), 880, 2) }.play;
s.freeAll;

// using only one Dust UGen to trigger all the filters:
(
  {
    var trigger, freq;
    trigger = Dust.ar(3, 0.3);
    freq = 440;
    Ringz.ar(trigger, 440, 2, 0.3) +
    Ringz.ar(trigger, freq*2, 2, 0.3) +
    Ringz.ar(trigger, freq*3, 2, 0.3) !2
  }.play
)
// but there is a better way:
// Klank is a bank of resonators like Ringz, but the frequency is fixed. (there is DynKlank)
{ Klank.ar(`[[800, 1071, 1153, 1723], nil, [1, 1, 1, 1]], Impulse.ar(2, 0, 0.1)) }.play;
// whitenoise input
{ Klank.ar(`[[440, 980, 1220, 1560], nil, [2, 2, 2, 2]], WhiteNoise.ar(0.005)) }.play;
// AudioIn input
{ Klank.ar(`[[220, 440, 980, 1220], nil, [1, 1, 1, 1]], AudioIn.ar([1])*0.001) }.play;


s.freeAll;
{ DynKlank.ar(`[[800, 1071, 1353, 1723], nil, [1, 1, 1, 1]], Dust.ar(8, 0.1)) }.play;
{ DynKlank.ar(`[[200, 671, 1153, 1723], nil, [1, 1, 1, 1]], PinkNoise.ar([0.007,0.007])) }.play;
{ DynKlank.ar(`[[200, 671, 1153, 1723]*XLine.ar(1, [1.2, 1.1, 1.3, 1.43], 5), nil, [1, 1, 1, 1]], PinkNoise.ar([0.007,0.007])) }.play;
(
  SynthDef(\dynklanks, {arg freqs = #[200, 671, 1153, 1723];
  Out.ar(0,
    DynKlank.ar(`[freqs, nil, [1, 1, 1, 1]], PinkNoise.ar([0.007,0.007]))
  )
}).add
)
a = Synth(\dynklanks)
a.set(\freqs, [333, 444, 555, 666])
a.set(\freqs, [333, 444, 555, 666].rand)
s.freeAll;

{ BPF.ar(Saw.ar(440), 440+(3000* SinOsc.kr(2, 0, 0.9, 1))) ! 2 }.play;
{ BPF.ar(WhiteNoise.ar(0.5), 1440+(300* SinOsc.kr(2, 0, 0.9, 1)), 0.2) ! 2}.play;

(
  {
    var chime, freqSpecs, burst, harmonics = 10;
    var burstEnv, burstLength = 0.001;
    freqSpecs = `[
      {rrand(100, 1200)}.dup(harmonics), //freq array
      {rrand(0.3, 1.0)}.dup(harmonics).normalizeSum, //amp array
      {rrand(2.0, 4.0)}.dup(harmonics)
    ]; //decay rate array
    burstEnv = Env.perc(0, burstLength); //envelope times
    burst = PinkNoise.ar(EnvGen.kr(burstEnv, gate: Dust.kr(1)) * 0.4); // Noise burst
    Klank.ar(freqSpecs, burst)!2
  }.play
)
s.freeAll;

{MoogFF.ar(Saw.ar(440), MouseX.kr(400, 16000), MouseY.kr(0.01, 4))}.play;
s.freeAll;

// here we add two Saws and split the signal into two channels
{ MoogFF.ar(Saw.ar(440, 0.4) + Saw.ar(442, 0.4), 4000 ) ! 2 }.play;
// like this:
{ ( SinOsc.ar(220, 0, 0.4) + SinOsc.ar(330, 0, 0.4) ) ! 2 }.play;

// here we "expand" the input of the filter into two channels (the array)
{ MoogFF.ar([Saw.ar(440, 0.4), Saw.ar(442, 0.4)], 4000 ) }.play
// like this - so different frequencies in each speaker:
{ [ SinOsc.ar(220, 0, 0.4), SinOsc.ar(330, 0, 0.4) ] }.play
// here we "expand" the saw into two channels, but sum them and then split into two
{ MoogFF.ar(Saw.ar([440, 442], 0.4).sum, 4000 ) ! 2 }.play
// like this - and this is the one we'll use, although they're all fine:
{ SinOsc.ar( [220, 333], 0, 0.4) ! 2 }.play
s.freeAll;

(
  { arg out=0, freq = 440, amp = 0.3, pan = 0, cutoff = 2, gain = 2, detune=2;
    var signal, filter;
    signal = Saw.ar([freq, freq+detune], amp).sum;
    filter = MoogFF.ar(signal, freq * cutoff, gain );
    Out.ar(out, Pan2.ar(filter, pan));
  }.play
)
s.freeAll;

(
  SynthDef(\moog, { arg out=0, freq = 440, amp = 0.3, pan = 0, cutoff = 2, gain = 2, gate=1;
    var signal, filter, env;
    signal = Saw.ar(freq, amp);
    env = EnvGen.ar(Env.adsr(0.01, 0.3, 0.6, 1), gate: gate, doneAction:2);
    filter = MoogFF.ar(signal * env, freq * cutoff, gain );
    Out.ar(out, Pan2.ar(filter, pan));
  }).add;
)

a = Synth(\moog);
a.set(\freq, 222); // set the frequency of the synth
a.set(\cutoff, 4); // set the cutoff (this would cut of at the 4th harmonic. Why?)
a.set(\gate, 0); // kill the synth

MIDIClient.init;
MIDIIn.connectAll;

// Monophonic
(
  c = 4;
  MIDIdef.noteOn(\myOndef, {arg vel, key, channel, device;
    a.release;
    a = Synth(\moog, [\freq, key.midicps, \amp, vel/127, \cutoff, c]);
    [key, vel].postln;
  });
  MIDIdef.noteOff(\myOffdef, {arg vel, key, channel, device;
    a.release;
    //a = nil;
    [key, vel].postln;
  });
)
c = 10; // change the cutoff frequency at a later point
// the 'c' variable could be set from a GUI or a MIDI controller

// Polyphonic
(
  a = Array.fill(127, { nil });
  MIDIIn.connectAll;
  MIDIdef.noteOn(\myOndef, {arg vel, key, channel, device;
    // we use the key as index into the array as well
    a[key] = Synth(\moog, [\freq, key.midicps, \amp, vel/127, \cutoff, 4]);
  });
  MIDIdef.noteOff(\myOffdef, {arg vel, key, channel, device;
    a[key].release;
  });
)
