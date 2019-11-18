// Chapter 12 - Time Domain Audio Effects
s.freeAll;

(
  s.boot;
  s.meter;
  // FreqScope.new(512, 512);
  FreqScope.new(368, 256);
  s.scope;
)

// Delay
// When we delay a signal, we can achieve various effects, from a simple echo to a more complex reverb.
// Typical variables are delay time (how long it takes before the sound appears again) and decay time (how
// long it will repeat). In SuperCollider, there are three main type of delays: Delay, Comb and Allpass:

// • DelayN/DelayL/DelayC are simple echos with no feedback.
// • CombN/CombL/CombC are comb delays with feedback (decaytime)
// • AllpassN/AllpassL/AllpassC die out faster than the comb, but have feedback as well

// Interpolation is about what happens between two discrete
// values, for example samples. Will you get a jump when the next value appears (N), a line from one value to
// the next (L) or a curvy shape between the two (C), simulating better analogue signal behaviour.

// Generally, we can talk about three types of time when using Delays, resulting in different types of effects:
// 1. Short ( < 10 ms)
// 2. Medium ( 10 - 50 ms)
// 3. Long ( > 50 ms)

// A short delay (1-2 samples) can create a FIR (Finite Impulse Response) lowpass filter. Increase the delay
// time (1-10 ms) and a comb filter materialises. Medium delays result in a thin signal but could also an
// ambience and width in the sound. Long delays create discrete echo which imitates sound bouncing of
// hard walls

// Delays can also have variable delay time which can result in the following effects:
// Phase Shifting Flanging Chorus


// Short Delays (< 10 ms)
// Let’s explore what a short delay means. This is a delay that’s hardly perceivable by the human ear if you
// would for example delay a click sound or an impulse.
(
  {
    x = Impulse.ar(1);
    d = DelayN.ar(x, 0.001, MouseX.kr(s.sampleRate.reciprocal, 0.001).poll);
    (x + d)!2
  }.play
)
s.freeAll
// When you move the mouse from the left to the right
// of the screen you will probably perceive the sound as one event, but you will notice that the sound
// changes slightly in timbre. It is filtered. And indeed, as we will see in the filter chapter, most filters work
// by way of delaying samples and multiplying the feedback or feedforward samples by different values.
(
  {
    x = Saw.ar(440, 0.4);
    d = DelayC.ar(x, 0.001, MouseX.kr(s.sampleRate.reciprocal, 0.001).poll);
    (x + d)!2
  }.play
)
s.freeAll

(
  {
    x = WhiteNoise.ar(0.1);
    d = DelayL.ar(x, 0.001, MouseX.kr(s.sampleRate.reciprocal, 0.001));
    (x + d)!2
  }.play
)
s.freeAll

// In the examples above we have been adding the two signals together (the original and the delayed signal)
// and then duplicating it (!2) into two arrays, for a two-speaker output. Adding the signals create the filtering
// effect, but if we simply put each signal in each speaker, we get a completely different effect, namely
// spatialisation:
(
  {
    x = WhiteNoise.ar(0.1);
    d = DelayC.ar(x, 0.006, MouseX.kr(s.sampleRate.reciprocal, 0.006));
    [x, d]
  }.play
)
s.freeAll

// We have now entered the realm of psychoacoustics, but this can be explained quickly by the fact that
// sound travels around 343 metres per second, or 34cm per millisecond, roughly 0.6 millisecond difference
// in arrival to the ears of a normal head, if the sound is coming from one side direction. This is called
// Interaural Time Difference (ITD) and is one of they key factors for sound localisation. We could explore
// this in the following example, where we have a signal that is “delayed” from 0.001 ms before to 0.001
// ms after the original signal. Try this with headphones, you should get some impression of sound moving
// from the left to the right ear.
(
  {
    x = Impulse.ar(1);
    l = DelayC.ar(x, 1.001, 1+MouseX.kr(-0.001, 0.001));
    r = DelayC.ar(x, 1.001, 1+MouseX.kr(0.001, -0.001));
    [l, r] // left and right channels
  }.play
)
s.freeAll

// In the example below, explore the difference algorithms implemented in Delay, Comb and Allpass. The
// Delay does not have the decay time, therefore not resulting in the Karplus-Strong type of sound that we
// get with the other two. The details of the difference in the internal implementation of Comb and Allpass
// are too complex for this book, but it has to do with the how gain coefficients are calculated, where a
// combined feedback and feedforward combs equal an allpass
// load some sound files into buffers (use your own)
d = Buffer.read(s, Platform.resourceDir +/+ "sounds/drums.wav");
e = Buffer.read(s, Platform.resourceDir +/+ "sounds/drums2.wav"); // this one is in the SC sounds folder

(
  {
    var signal, delaytime = MouseX.kr(0.00022675, 0.01, 1);
    signal = PlayBuf.ar(1, e.bufnum, BufRateScale.kr(e.bufnum), loop:1);
    // signal = Saw.ar(440,0.3);
    // signal = WhiteNoise.ar(0.3);
    // d = DelayC.ar(signal, 0.6, delaytime);
    d = AllpassC.ar(signal, 0.6, delaytime, MouseY.kr(0.001,1, 1));
    // d = CombC.ar(signal, 0.6, delaytime, MouseY.kr(0.001,1, 1));
    (signal + d).dup
  }.play
)
s.freeAll

{CombC.ar(SoundIn.ar(0), 0.6, LFPulse.ar(0.25).range(0.0094,0.013), 0.9)!2}.play

(
  {
    var signal, delay, delaytime = MouseX.kr(0.00022675, 0.02, 1);
    signal = PlayBuf.ar(1, e, 1, loop:1);
    delay = DelayC.ar(signal, 0.2, delaytime);
    [signal, delay]
  }.play
)
s.freeAll

// Any amount of Delays can be added together to create the desired sound of course, something we will
// explore when we discuss reverbs:
(
  {
    var signal;
    var delaytime = MouseX.kr(0.1,0.4, 1);
    signal = Impulse.ar(1);
    Mix.fill(14, {arg i; DelayL.ar(signal, 1, delaytime*(1+(i/10))) });
  }.play
)
s.freeAll

// The old Karplus-Strong in its most basic form:
(
  {
    var delaytime = MouseX.kr(0.001,0.2, 1);
    var decaytime = MouseY.kr(0.1,2, 1);
    var signal = Impulse.ar(1);
    CombL.ar(signal, 0.6, delaytime, decaytime)!2
  }.play
)
s.freeAll


// Medium Delay time (10 - 50 ms)
{x=Impulse.ar(1); y=DelayC.ar(x, 0.04, MouseX.kr(0.005, 0.04).poll); (x+y)!2}.play
s.freeAll

// Longer delays can also generate a spatialisation effect,
// although this is not modelling the interaural time
// difference (ITD), but rather creating the sensation of a wide sonic image.
e = Buffer.read(s, Platform.resourceDir +/+ "sounds/drums2.wav"); // this one is in the SC sounds folder
(
  {
    var signal, delay, delaytime = MouseX.kr(0.00022675, 0.05, 1).poll;
    signal = PlayBuf.ar(1, e, 1, loop:1);
    delay = DelayC.ar(signal, 0.2, delaytime);
    [signal, delay]
  }.play
)
(
  // Using microphone input
  {
    var signal, delay, delaytime = MouseX.kr(0.00022675, 0.05, 1).poll;
    signal = SoundIn.ar(0);
    delay = DelayC.ar(signal, 0.2, delaytime);
    [signal, delay]
  }.play
)
s.freeAll


// Longer Delays (> 50 ms)
(
  {
    var signal;
    var delaytime = MouseX.kr(0.05, 2, 1); // between 50 ms and 2 seconds - exponential.
    signal = PlayBuf.ar(1, e.bufnum, BufRateScale.kr(e.bufnum), loop:1);
    // compare DelayL, CombL and AllpassL
    d = DelayL.ar(signal, 0.6, delaytime);
    // d = CombL.ar(signal, 0.6, delaytime, MouseY.kr(0.1, 10, 1)); // decay using mouseY
    // d = AllpassL.ar(signal, 0.6, delaytime, MouseY.kr(0.1,10, 1));
    (signal+d).dup
  }.play(s)
)
s.freeAll

// same as above, here using AudioIn for the signal instead of the NASA irritation
(
  {
    var signal;
    var delaytime = MouseX.kr(0.05, 2, 1); // between 50 ms and 2 seconds - exponential.
    signal = AudioIn.ar(1);
    // compare DelayL, CombL and AllpassL
    //d = DelayL.ar(signal, 0.6, delaytime);
    //d = CombL.ar(signal, 0.6, delaytime, MouseY.kr(0.1, 10, 1)); // decay using mouseY
    d = AllpassL.ar(signal, 0.6, delaytime, MouseY.kr(0.1,10, 1));
    (signal+d).dup
  }.play(s)
)

// Random experiments
{CombL.ar(Impulse.ar(10), 6, 1, 1)}.play(s)
s.freeAll

(
  {
    var signal;
    var delaytime = MouseX.kr(0.01,6, 1);
    var decaytime = MouseY.kr(1,2, 1);
    signal = Impulse.ar(1);
    d = CombL.ar(signal, 6, delaytime, decaytime);
    d!2
  }.play(s)
)
s.freeAll

// we can see the Comb effect by plotting the signal.
(
  {
    a = Impulse.ar(1);
    d = CombL.ar(a, 1, 0.001, 0.9);
    d
  }.plot(0.1)
)

// a little play with AudioIn
(
  {
    var signal;
    var delaytime = MouseX.kr(0.001,2, 1);
    signal = AudioIn.ar(1);
    a = Mix.fill(10, {arg i; var dt;
      dt = delaytime*(i/10+0.1).postln;
      DelayL.ar(signal, 3.2, dt);
    });
    (signal+a).dup
  }.play(s)
)

/*
TIP: if you get this line printed ad infinitum:
exception in real time: alloc failed
You could go into the ServerOptions.sc (source file) and change
var <>memSize = 8192;
to
var <>memSize = 32768;
which allows the server to use up more memory (RAM)
*/
(
  { // watch your ears !!! Use headphones and lower the volume !!!
    var signal;
    var delaytime = MouseX.kr(0.001,2, 1);
    signal = AudioIn.ar(1);
    a = Mix.fill(13, {arg i; var dt;
      dt = delaytime*(i/10+0.1).postln;
      CombL.ar(signal, 3.2, dt);
    });
    (signal+a).dup
  }.play(s)
)

// A source code for a Comb filter might look something like this:
int i, j, s;
for(i=0; i <= delay_size;i++) {
  if (i >= delay) {
    j = i - delay; // work out the buffer position
  } else {
    j = i - delay + delay_size + 1;
    // add the delayed sample to the input sample
    s = input + delay_buffer[j]*decay;
    // store the result in the delay buffer, and output
    delay_buffer[i] = s;
    output = s;
  }
}


// Phaser (phase shifting)
// In a phaser, a signal is sent through an allpass filter,
// not filtering out any frequencies, but simply shifting
// the phase of the sound by delaying it.
// This sound is then added to the original signal.
// If the phase is 180 degrees, the sound is cancelled out,
// but if it is less than that, it will create variations in the spectra
// phaser with a soundfile
e = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");
(
  {
    var signal;
    var phase = MouseX.kr(0.000022675,0.01, 1); // from a sample resolution to 10 ms delay line
    var ph;
    signal = PlayBuf.ar(1, e.bufnum, BufRateScale.kr(e.bufnum), loop:1);
    // ph = AllpassL.ar(PlayBuf.ar(1, e.bufnum, BufRateScale.kr(e.bufnum), loop:1), 4, phase+(0.01.rand), 0);
    // try 4 phasers
    ph = Mix.ar(Array.fill(4,
      { AllpassL.ar(PlayBuf.ar(1, e.bufnum, BufRateScale.kr(e.bufnum), loop:1), 4, phase+(0.01.rand), 0)}
    ));
    (signal + ph).dup
  }.play
)
s.freeAll

// try it with a sinewave (the mouse is shifting the phase of the input signal
(
  {
    var signal;
    var phase = MouseX.kr(0.000022675,0.01); // from a sample to 10 ms delay line
    var ph;
    signal = SinOsc.ar(444,0,0.5);
    //signal = PlayBuf.ar(1, e.bufnum, BufRateScale.kr(e.bufnum), loop:1);
    ph = AllpassL.ar(SinOsc.ar(444,0,0.5), 4, phase, 0);
    (signal + ph).dup
  }.play
)
s.freeAll

// using an oscillator to control the phase instead of MouseX
// here using the .range trick:
{SinOsc.ar(SinOsc.ar(0.3).range(440, 660), 0, 0.5) }.play
s.freeAll

(
  {
    var signal;
    var ph;
    // base signal
    signal = PlayBuf.ar(1, e.bufnum, BufRateScale.kr(e.bufnum), loop:1);
    // phased signal
    ph = AllpassC.ar(
      PlayBuf.ar(1, e.bufnum, BufRateScale.kr(e.bufnum), loop:1),
      4,
      LFPar.kr(0.1, 0, 1).range(0.000022675,0.01), // a circle every 10 seconds
      0 // experiment with what happens if you increase the decay length
    );
    (signal + ph).dup // we add them together and route to two speakers
  }.play
)
s.freeAll

/*
NOTE: Theoretically you could use DelayC or CombC instead of AllpassC.
In the case of DelayC, you would have to delete the last argument (0)
(as DelayC doesn't have decay argument).
*/



// Flanger

// In a Flanger, a delayed signal is added to the original signal with a continuously-variable delay
// (usually smaller than 10 ms) creating a phasing effect.
// The term comes from times where tapes were used in studios
// and an operator would place the finger on the flange of one of the tapes to slow it down,
// thus causing the flanging effect.
// Flanger is like a Phaser with dynamic delay filter (allpass), but it usually has a feedback loop
(
  SynthDef(\flanger, { arg out=0, in=0, delay=0.1, depth=0.08, rate=0.06, fdbk=0.0, decay=0.0 ;
    var input, maxdelay, maxrate, dsig, mixed, local;
    maxdelay = 0.013;
    maxrate = 10.0;
    input = In.ar(in, 1);
    local = LocalIn.ar(1);
    dsig = AllpassL.ar( // the delay (you could use AllpassC (put 0 in decay))
    input + (local * fdbk),
    maxdelay * 2,
    LFPar.kr( // very similar to SinOsc (try to replace it) - Even use LFTri
    rate * maxrate,
    0,
    depth * maxdelay,
    delay * maxdelay),
    decay);
    mixed = input + dsig;
    LocalOut.ar(mixed);
    Out.ar([out, out+1], mixed);
  }).add;
)
// audioIn on audio bus nr 10
{Out.ar(10, AudioIn.ar(1))}.play(s, addAction:\addToHead)
a = Synth(\flanger, [\in, 10], addAction:\addToTail)
a.set(\delay, 0.04)
a.set(\depth, 0.04)
a.set(\rate, 0.01)
a.set(\fdbk, 0.08)
a.set(\decay, 0.01)

// or if you prefer a buffer:
b = Buffer.read(s, Platform.resourceDir +/+ "sounds/drums.wav"); // replace this sound with a nice sounding one !!!
{Out.ar(10, PlayBuf.ar(1, b.bufnum, BufRateScale.kr(b.bufnum), loop:1))}.play(addAction:\addToHead)
a = Synth(\flanger, [\in, 10], addAction:\addToTail)
s.freeAll
a.set(\delay, 0.04)
a.set(\depth, 0.04)
a.set(\rate, 1)
a.set(\fdbk, 0.08)
a.set(\decay, 0.01)
// a parameter explosion results in a Chorus like effect:
a.set(\decay, 0)
a.set(\delay, 0.43)
a.set(\depth, 0.2)
a.set(\rate, 0.1)
a.set(\fdbk, 0.08)
// or just go mad:
a.set(\delay, 0.93)
a.set(\depth, 0.9)
a.set(\rate, 0.8)
a.set(\fdbk, 0.8)
s.freeAll



// Chorus
// The chorus effect happens when we add a delayed signal with the original with a time-varying delay.
// The delay has to be short in order not to be perceived as echo, but above 5 ms to be audible. If the delay
// is too short, it will destructively interfere with the un-delayed signal and create a flanging effect. Often,
// the delayed signals will be pitch shifted to create a harmony with the original signal.
// There is no definite algorithm to create a chorus. There are many different ways to achieve it. As opposed
// to the Flanger above, this chorus does not have a feedback loop. But you could create a chorus effect out
// of a Flanger by using longer delay time (20-30 ms instead of 1-10 ms in the Flanger)

// a simple chorus
(
  SynthDef(\chorus, { arg inbus=10, outbus=0, predelay=0.08, speed=0.05, depth=0.1, ph_diff=0.5;
    var in, sig, modulators, numDelays = 12;
    in = In.ar(inbus, 1) * numDelays.reciprocal;
    modulators = Array.fill(numDelays, {arg i;
      LFPar.kr(speed * rrand(0.94, 1.06), ph_diff * i, depth, predelay);
    });

    sig = DelayC.ar(in, 0.5, modulators);
    sig = sig.sum; //Mix(sig);
    Out.ar(outbus, sig!2); // output in stereo
  }).add
)

// try it with audio in
{Out.ar(10, AudioIn.ar(1))}.play(addAction:\addToHead)
// or a buffer:
b = Buffer.read(s, Platform.resourceDir +/+ "sounds/drums.wav"); // replace this sound with a nice sounding one !!!
{Out.ar(10, PlayBuf.ar(1, b.bufnum, BufRateScale.kr(b.bufnum), loop:1))}.play(addAction:\addToHead)
a = Synth(\chorus, addAction:\addToTail)
a.set(\predelay, 0.02);
a.set(\speed, 0.22);
a.set(\depth, 0.5);
a.set(\pd_diff, 0.7);
a.set(\predelay, 0.2);
s.freeAll



// Reverb
// Achieving realistic reverb is a science on its own, to deep to delve into here. The most common reverb
// technique in digital acoustics is to use parallel comb delays that are fed into few Allpass delays.

// Reverb can be analysed into 3 stages:
// * Direct sound (from the soundsource)
// * Early reflections (discrete 1st generation reflections from walls)
// * Reverberation (Nth generation reflections that take time to build up, and fade out slowly)
(
  SynthDef(\reverb, {arg inbus=0, outbus=0, predelay=0.048, combdecay=15, allpassdecay=1, revVol=0.31;
    var sig, y, z;
    sig = In.ar(inbus, 1);
    // predelay
    z = DelayN.ar(sig, 0.1, predelay); // max 100 ms predelay
    // 7 length modulated comb delays in parallel :
    y = Mix.ar(Array.fill(7,{ CombL.ar(z, 0.05, rrand(0.03, 0.05), combdecay) }));
    6.do({ y = AllpassN.ar(y, 0.050, rrand(0.03, 0.05), allpassdecay) });
    Out.ar(outbus, sig + (y * revVol) ! 2); // as fxlevel is 1 then I lower the vol a bit
  }).add;
)
{Out.ar(10, AudioIn.ar(1))}.play(addAction:\addToHead)
b = Buffer.read(s, Platform.resourceDir +/+ "sounds/drums.wav"); // replace this sound with a nice sounding one !!!
{Out.ar(10, PlayBuf.ar(1, b.bufnum, BufRateScale.kr(b.bufnum), loop:1))}.play(addAction:\addToHead)
a = Synth(\reverb, [\inbus, 10], addAction:\addToTail)
a.set(\predelay, 0.048)
a.set(\combdecay, 2.048)
a.set(\allpassdecay, 1.048)
a.set(\revVol, 0.048)
s.freeAll


// Tremolo
// Tremolo is fluctuating amplitude of a signal, well known from analogue guitar amplifiers, and heard in
// surf music, or garage punk such as The Cramps.
(
  SynthDef(\tremolo, {arg inbus=0, outbus=0, freq=1, strength=1;
    var fx, sig;
    sig = In.ar(inbus, 1);
    fx = sig * SinOsc.ar(freq, 0, strength, 0.5, 2);
    Out.ar(outbus, (fx+ sig).dup )
  }).add;
)
{Out.ar(10, AudioIn.ar(1))}.play(addAction:\addToHead)
b = Buffer.read(s, Platform.resourceDir +/+ "sounds/drums.wav"); // replace this sound with a nice sounding one !!!
{Out.ar(10, PlayBuf.ar(1, b.bufnum, BufRateScale.kr(b.bufnum), loop:1))}.play(addAction:\addToHead)
a = Synth(\tremolo, [\inbus, 10], addAction:\addToTail)
a.set(\freq, 4.8)
a.set(\strength, 0.8)
s.freeAll
