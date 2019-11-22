// Chapter 5 - Additive Synthesis
s.boot;
FreqScope.new;
s.meter;

// we add 500 oscillators together and the CPU is less than 20%
{({SinOsc.ar(4444.4.rand, 0, 0.005)}!500).sum}.play;
s.freeAll;

// Adding waves
// Adding two waves of 440Hz together
{[SinOsc.ar(440), SinOsc.ar(440), SinOsc.ar(440) + SinOsc.ar(440)]}.plot;
// try this as well
{a = SinOsc.ar(440, 0, 0.5); [a, a, a+a]}.plot;

// Adding a 440Hz and a 220Hz wave together
{[SinOsc.ar(440), SinOsc.ar(220), SinOsc.ar(440) + SinOsc.ar(220)]}.plot;

// Clipping and becoming a squarewave
{SinOsc.ar(440, 0, 10).clip(-0.75, 0.75)}.scope;
{SinOsc.ar(440, 0, 10).clip(-0.75, 0.75)}.plot;
s.freeAll;

// In the example below we mix ten sine waves of frequencies between 200 and 2000.
{Mix.fill(10, {SinOsc.ar(rrand(200,2000), 0, 0.1)})}.freqscope;
s.freeAll;

{Saw.ar(880)}.freqscope;

// adding two waves - the second is the octave (second harmonic) of the first
{(SinOsc.ar(440, 0, 0.4) + SinOsc.ar(880, 0, 0.4))!2}.play;
s.freeAll;

// here we add four harmonics (of equal amplitude) together
(
  {
    var freq = 200;
    SinOsc.ar(freq, 0, 0.2) +
    SinOsc.ar(freq * 2, 0, 0.2) +
    SinOsc.ar(freq * 3, 0, 0.2) +
    SinOsc.ar(freq * 4, 0, 0.2)
    !2;
  }.play;
);

{Blip.ar(440, MouseX.kr(1, 20))}.scope; // using the Mouse
{Blip.ar(440, MouseX.kr(1, 20))}.freqscope;
{Blip.ar(440, Line.kr(1, 22, 3) )}.play;

s.freeAll;


// Creating wave forms out of sinusoids
// a) here is an array with 5 items:
Array.fill(5, {arg i; i.postln;});
// b) this is the same as (using a shortcut):

{arg i; i.postln;}.dup(5);
// c) or simply (using another shortcut):
{arg i; i.postln;}!5;
// d) we can then sum the items in the array (add them together):
Array.fill(5, {arg i; i.postln;}).sum;
// e) we could do it this way as well:
sum({arg i; i.postln;}.dup(5));
// f) or this way:
({arg i; i.postln;}.dup(5)).sum;
// g) or this way:
({arg i; i.postln;}!5).sum;
// h) or simply this way:
sum({arg i; i.postln;}!5);

// The Saw UGen is “band-limited” which
// means that it does not alias and mirror back into the audible range.
// Compare with LFSaw which will alias
// you can both hear and see the harmonics mirror back into the audio range.
{Saw.ar(MouseX.kr(100, 1000))}.freqscope;
{LFSaw.ar(MouseX.kr(100, 1000))}.freqscope;
s.freeAll;

// SAW
// A ‘Saw’ wave with 30 harmonics:
(
  f = {
    ({arg i;
      var j = i + 1;
      SinOsc.ar(300 * j, 0, j.reciprocal * 0.5);
    } ! 30).sum // we sum this function 30 times
    !2
  }; // and we make it a stereo signal
)
f.plot; // let's plot the wave form
f.play; // listen to it
f.freqscope; // view and listen to it
s.freeAll;

// By inverting the phase (using pi), we get an inverted wave form.
(
  f = {
    Array.fill(30, {arg i;
      var j = i + 1;
      SinOsc.ar(300 * j, pi, j.reciprocal * 0.5) // note pi
    }).sum // we sum this function 30 times
    !2
  }; // and we make it a stereo signal
)
f.plot; // let's plot the wave form
f.play; // listen to it
f.freqscope; // view and listen to it
s.freeAll;


// SQUARE
// The square wave can be created by sine waves
// if we ignore all the even harmonics and only add
// the odd ones.
(
  f = {
    ({arg i;
      var j = i * 2 + 1; // the odd harmonics (1,3,5,7,etc)
      SinOsc.ar(300 * j, 0, 1/j)
    } ! 20).sum;
  };
)
f.plot;
f.play;
f.freqscope;
s.freeAll;

// Let’s quickly look at the regular Pulse wave in SuperCollider:
{Pulse.ar(440, MouseX.kr(0, 1), 0.5)}.scope;
// we could also recreate this with an algorithm on a sine wave:
{if (SinOsc.ar(122) > 0, 1, -1)}.scope; // a square wave
{if (SinOsc.ar(122) > MouseX.kr(0, 1), 1, -1)}.scope; // MouseX controls the period
{if (SinOsc.ar(122) > MouseX.kr(0, 1), 1, -1) * 0.1}.scope; // amplitude down
s.freeAll;


// TRIANGLE
// A triangle wave is a wave form,
// similar to the pulse wave in that it ignores the even harmonics,
// but it has a different algorithm for the phase and the amplitude:
(
  f = {
    ({arg i;
      var j = i * 2 + 1;
      SinOsc.ar(300 * j, pi/2, 0.7/j.squared) // cosine wave (phase shift)
    } ! 20).sum;
  };
)
f.plot;
f.play;
f.freqscope;


// We have now created various wave forms using sine waves,
// and here is how to wrap them up in a
// SynthDef for future use:
(
  SynthDef(\triwave, {arg freq=400, pan=0, amp=1;
    var wave;
    wave = ({arg i;
      var j = i * 2 + 1;
      SinOsc.ar(freq * j, pi/2, 0.6 / j.squared);
    } ! 20).sum;
    Out.ar(0, Pan2.ar(wave * amp, pan));
  }).add;
)
a = Synth(\triwave, [\freq, 300]);
a.set(\amp, 0.3, \pan, -1);
b = Synth(\triwave, [\freq, 900]);
b.set(\amp, 0.4, \pan, 1);
s.freqscope; // if the freqscope is not already running
b.set(\freq, 1400); // not band limited as we can see
s.freeAll;


// We have created various typical wave forms above
// in order to show how they are sums of sinusoidal waves.
// A good idea is to play with this further and create your own waveforms:
(
  f = {
    ({arg i;
      var j = i * 2.cubed + 1;
      SinOsc.ar(MouseX.kr(20, 800) * j, 0, 1/j)
    } ! 20).sum;
  };
)
f.plot;
f.play;
s.freeAll;

(
  f = {
    ({arg i;
      var j = i * 2.squared.distort + 1;
      SinOsc.ar(MouseX.kr(20, 800) * j, 0, 0.31/j)
    } ! 20).sum;
  };
)
f.plot;
f.play;
s.freeAll;


// Bell Synthesis
{ ({ SinOsc.ar(rrand(80, 800), 0, 0.1)} ! 15).sum }.play;
s.freeAll;

// What we hear is a wave form that might be quite similar to a bell at first, but
// then the resemblance disappears, because the partials do not fade out.
// If we add an envelope to each of
// these sinusoids, we get a different sound:
(
  {
    Mix.fill(10, {
      SinOsc.ar(rrand(200, 700), 0, 0.1) * EnvGen.kr(Env.perc(0.0001, rrand(2, 6)), doneAction: Done.freeSelf)
    });
  }.play
)

// Static bell
(
  {
    var freq = [333, 412, 477, 567, 676, 890, 900, 994];
    var dur = [4, 3.5, 3.6, 3.1, 2, 1.4, 2.4, 4.1];
    var amp = [0.4, 0.2, 0.1, 0.4, 0.33, 0.22, 0.13, 0.4];
    Mix.fill( 8, { arg i;
      SinOsc.ar(freq[i], 0, 0.1)
      * EnvGen.ar(Env.perc(0.0001, dur[i]), doneAction: Done.freeSelf)
    });
  }.play
)

// Generating a SynthDef using a non-deterministic algorithms (such as random)
// in the SC-lang will also
// generate a SynthDef that is the “same” bell.
// Why? This is because the values (430.rand) are defined when
// the synth definition is compiled.
// Try to recompile the SynthDef and you get a new sound:
(
  SynthDef(\mybell, {arg freq=333, amp=0.4, dur=2, pan=0.0;
    var signal;
    signal = Mix.fill(10, {
      SinOsc.ar(freq +(430.rand), 1.0.rand, 10.reciprocal) * EnvGen.ar(Env.perc(0.0001, dur), doneAction: 2);
    });

    signal = Pan2.ar(signal * amp, pan);
    Out.ar(0, signal);
  }).add;
)
// let's try our bell
Synth(\mybell) // same sound all the time
Synth(\mybell, [\freq, 444 + (400.rand)]) // new frequency, but same sound
// try to redefine the SynthDef above and you will now get a different bell:
Synth(\mybell) // same sound all the time

// Another way of generating this bell sound would be
// to use the SynthDef from last tutorial, but here
// adding a duration to the envelope:
(
  SynthDef(\sine, {arg freq=333, amp=0.4, dur, pan=0.0;
    var signal, env;
    env = EnvGen.ar(Env.perc(0.01, dur), doneAction: 2);
    signal = SinOsc.ar(freq, 0, amp) * env;
    signal = Pan2.ar(signal, pan);
    Out.ar(0, signal);
  }).add
);

(
  var numberOfSynths;
  numberOfSynths = 15;
  Array.fill(numberOfSynths, {
    Synth(\sine, [
      \freq, 300+(430.rand),
      \phase, 1.0.rand,
      \amp, numberOfSynths.reciprocal, // reciprocal here means 1/numberOfSynths
      \dur, 2+(1.0.rand)
    ]);
  });
)


// The Klang Ugen
// Another interesting way of achieving this is to use the Klang UGen.
// Klang is a bank of sine oscillators that takes arrays of frequencies,
// amplitudes and phase as arguments.
{Klang.ar(`[ [430, 810, 1050, 1220], [0.23, 0.13, 0.23, 0.13], [pi, pi, pi, pi]], 1, 0)}.play;
s.freeAll;

// And we create a SynthDef with the Klang Ugen:
(
  SynthDef(\saklangbell, {arg freq=400, amp=0.4, dur=2, pan=0.0; // we add a new argument
    var signal, env;
    env = EnvGen.ar(Env.perc(0.01, dur), doneAction: 2); // doneAction gets rid of the synth
    signal = Klang.ar(`[freq * [1.2, 2.1, 3.0, 4.3], [0.25, 0.25, 0.25, 0.25], nil]) * env;
    signal = Pan2.ar(signal, pan);
    Out.ar(0, signal);
  }).add;
)
Synth(\saklangbell, [\freq, 110]);


// Xylophone Synthesis
// Additive synthesis is good for various types of sound, but it suites very well for xylophones, bells and
// other metallic instruments (typically inharmonic sounds) as we saw with the bell example above. Using
// harmonic wave forms, such as a Saw wave, Square wave or Triangle wave would not be useful here as
// those are harmonic wave forms (as we know from the section above).
(
  {
    ({
      // the partial
      // each partial gets its own envelope of 0.5 to 5 seconds
      SinOsc.ar(rrand(180, 1200), 0.5 * pi, 0.1) * EnvGen.ar(Env.perc(rrand(0.00001, 0.01), rrand(0.5, 5)))
    } ! 12).sum
  }.play
)

// Analyzing spectogram
(
  {
    SinOsc.ar(220, 0, 0.1) +
    SinOsc.ar(440, 0, 0.1) +
    SinOsc.ar(880, 0, 0.1) +
    SinOsc.ar(1100, 0, 0.1) +
    SinOsc.ar(1250, 0, 0.1) +
    SinOsc.ar(1400, 0, 0.1)
  }.play
)
s.freeAll;

// Varying amplitudes
(
  {
    SinOsc.ar(220, 0, 0.5) +
    SinOsc.ar(440, 0, 0.3) +
    SinOsc.ar(880, 0, 0.2) +
    SinOsc.ar(1100, 0, 0.1) +
    SinOsc.ar(1250, 0, 0.1) +
    SinOsc.ar(1400, 0, 0.1)
  }.play
)
s.freeAll;


// Some of the partials have a bit of vibration
// and we could simply turn the oscillator into a ‘detuned’
// oscillator by adding two sines together:
// a regular 880 Hz wave at full amplitude
{SinOsc.ar(880)!2}.play
// a vibrating 880Hz wave (vibration at 3 Hz), where each is amp 0.5
{SinOsc.ar([880, 883], 0, 0.5).sum!2}.play
// the above is the same as (note the .sum):
{(SinOsc.ar(880, 0, 0.5) + SinOsc.ar(883, 0, 0.5))!2}.play

{
  SinOsc.ar([xxx, xxx], 0, xxx).sum+
  SinOsc.ar([xxx, xxx], 0, xxx).sum+
  SinOsc.ar([xxx, xxx], 0, xxx).sum+
  SinOsc.ar([xxx, xxx], 0, xxx).sum+
  SinOsc.ar([xxx, xxx], 0, xxx).sum+
  SinOsc.ar([xxx, xxx], 0, xxx).sum
}.play;

// And finally, we need to create envelopes for each of the partials:
{
  (SinOsc.ar([xxx, xxx], 0, xxx).sum * EnvGen.ar(Env.perc(0.00001, xxx))) +
  (SinOsc.ar([xxx, xxx], 0, xxx).sum * EnvGen.ar(Env.perc(0.00001, xxx))) +
  (SinOsc.ar([xxx, xxx], 0, xxx).sum * EnvGen.ar(Env.perc(0.00001, xxx))) +
  (SinOsc.ar([xxx, xxx], 0, xxx).sum * EnvGen.ar(Env.perc(0.00001, xxx))) +
  (SinOsc.ar([xxx, xxx], 0, xxx).sum * EnvGen.ar(Env.perc(0.00001, xxx)))
}.play;

// And let’s listen to that. You will note that parenthesis have been put around each sine wave and its
// envelope multiplication. This is because SuperCollider calculates from left to right, and not giving + and
// - operators precedence, like in common maths and many other programming languages.
// TIP: Operator Precedence - explore how these equations result in different outcomes
2 + 2 * 8; // you would expect 18 as the result, but SC returns what?
100 / 2 - 10; // here you would expect to get 40, and you get the same in SC. Why?
// now, for this reason it's a good practice to use parenthesis, e.g.,
2 + (2 * 8);
100 / (2 - 10); // if that's what you were trying to do

// @FIXME
SynthDef(\bell, xxxx)
// and we can play our new bell
Synth(\bell)


// Some Additive SynthDefs with routines playing them
// Note the # in front of the arrays in the arguments.
// It means that they are literal (fixed size) arrays.
(
  SynthDef(\addSynthArray, {
    arg freq=300, dur=0.5, mul=100, addDiv=8,
    partials = #[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15],
    amps = #[ 0.30, 0.15, 0.10, 0.07, 0.06, 0.05, 0.04, 0.03, 0.03, 0.03, 0.02, 0.02, 0.02, 0.02, 0.02 ];
    var signal, env;

    env = EnvGen.ar(Env.perc(0.01, dur), doneAction: 2);
    signal = Mix.arFill(partials.size, {arg i;
      SinOsc.ar(
        freq * partials[i],
        0,
        amps[i]
      )
    });
    Out.ar(0, signal.dup * env)
  }).add
)
// a saw wave sounding wave with 15 harmonics
Synth(\addSynthArray, [\freq, 200])
Synth(\addSynthArray, [\freq, 300])
Synth(\addSynthArray, [\freq, 400])

Synth(\addSynthArray, [\freq, 400, \partials, {|i| (i+1)+rrand(-0.2, 0.2)}!15])

// What happened here? Let’s scrutinize the partials argument.
{|i| (i+1)+rrand(-0.2, 0.2)}!15
// breaks down to
{|i|i}!15
// or
{arg i; i } ! 15
// but we don't want a frequency of zero, so we add 1
{|i| (i+1) }!15
// and then we add random values from -0.2 to 0.2
{|i| (i+1) + rrand(-0.2, 0.2) }!15
// resulting in frequencies such as
{|i| (i+1) + rrand(-0.2, 0.2) * 440 }!15

// test the routine here below. uncommend and comment the variables f and a
(
  fork { // fork is basically a Routine
    100.do({
      // partial frequencies:
      // f = Array.fill(15, {arg i; i=i+1; i}).postln; // harmonic spectra (saw wave)
      f = Array.fill(15, {10.0.rand}); // inharmonic spectra (a bell?)
      // partial amplitudes:
      // a = Array.fill(15, {arg i; i=i+1; 1/i;}).normalizeSum.postln; // saw wave amps
      a = Array.fill(15, {1.0.rand}).normalizeSum.postln; // random amp on each harmonic
      Synth(\addSynthArray).set(\harmonics, f, \amps, a);
      1.wait;
    });
  }
)
(
  n = rrand(10, 15);
  { Mix.arFill(n , {
    SinOsc.ar( [67.0.rrand(2000), 67.0.rrand(2000)], 0, n.reciprocal)
    *
    EnvGen.kr(Env.sine(rrand(2.0, 10) ) )
  }) * EnvGen.kr(Env.perc(11, 6), doneAction: 2, levelScale: 0.75)
}.play;
)
(
  fork { // fork is basically a Routine
    100.do({
      n = rrand(10, 45);
      "Number of UGens: ".post; n.postln;
      { Mix.fill(n , {
        SinOsc.ar( [67.0.rrand(2000), 67.0.rrand(2000)], 0, n.reciprocal)
        *
        EnvGen.kr(Env.sine(rrand(4.0, 10) ) )
      }) * EnvGen.kr(Env.perc(11, 6), doneAction: 2, levelScale: 0.75)
    }.play;
    rrand(5, 10).wait;
  })
}
)
s.freeAll;



// Using Control to set multiple parameters
// There is another way to store and control arrays within a SynthDef.
// This is using the Control class.
// The controls are good for passing arrays into running Synths.
// In order to do this we use the Control UGen inside our SynthDef.
(
  SynthDef("manySines", {arg out=0;
    var sines, control, numsines;
    numsines = 20;
    control = Control.names(\array).kr(Array.rand(numsines, 400.0, 1000.0));
    sines = Mix(SinOsc.ar(control, 0, numsines.reciprocal));
    Out.ar(out, sines ! 2);
  }).add;
)

b = Synth("manySines");
b.free;

// our control name is "array"
b.setn(\array, Array.rand(20, 200, 1600));
b.setn(\array, {rrand(200, 1600)}!20);
b.setn(\array, {rrand(200, 1600)}.dup(20));
// NOTE: All three lines above do exactly the same, just different syntax

// Here below we use DynKlang (dynamic Klang) in order to change the synth in runtime:
(
  SynthDef(\dynklang, { arg out=0, freq=110;
    var klank, n, harm, amp;
    n = 9;
    // harmonics
    harm = Control.names(\harm).kr(Array.series(4,1,4));
    // amplitudes
    amp = Control.names(\amp).kr(Array.fill(4,0.05));
    klank = DynKlang.ar(`[harm,amp], freqscale: freq);
    Out.ar(out, klank);
  }).add;
)
a = Synth(\dynklang, [\freq, 230]);
a.set(\harm, Array.rand(4, 1.0, 4.7))
a.set(\freq, rrand(30, 120))
a.set(\amp, Array.rand(4, 0.005, 0.1))
a.free;


// Klang and Dynklang
// It can be laborious to build an array of synths and set the frequencies and amplitudes of each.
// For this we have a UGen called Klang.
// Klang is a bank of sine oscillators. It is more efficient than the DynKlang, but less flexible.
// (Don’t confuse with Klank and DynKlank which we will explore in the next chapter).
// bank of 12 oscillators of frequencies between 600 and 1000
{ Klang.ar(`[ Array.rand(12, 600.0, 1000.0), nil, nil ], 1, 0) * 0.05 }.play;
s.freeAll;
(
  {
    loop({
      { Pan2.ar(
        Klang.ar(`[ Array.rand(12, 200.0, 2000.0), nil, nil ], 0.5, 0)
        * EnvGen.kr(Env.sine(4), 1, 0.02, doneAction: 2), 1.0.rand2)
      }.play;
      2.wait;
    })
  }.fork;
)
s.freeAll;
s.boot;

(
  {
    DynKlang.ar(`[
      [800, 1000, 1200] + SinOsc.kr([2, 3, 0.2], 0, [130, 240, 1200]),
      [0.6, 0.4, 0.3],
      [pi,pi,pi]
    ]) * 0.1
  }.freqscope;
)
// amplitude modulation
(
  {
    DynKlang.ar(`[
      [800, 1600, 2400, 3200],
      [0.1, 0.1, 0.1, 0.1] + SinOsc.kr([0.1, 0.3, 0.8, 0.05], 0, [1, 0.8, 0.8, 0.6]),
      [pi,pi,pi]
    ]
  ) * 0.1
}.freqscope;
)


// The following patch shows how a GUI is used to control the amplitudes
// of the DynKlang oscillator array
( // create controls directly with literal arrays:
  SynthDef(\dynsynth, {| freqs = #[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
  amps = #[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
  rings = #[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]|
  Out.ar(0, DynKlang.ar(`[freqs, amps, rings]))
}).add
)
(
  var bufsize, ms, slid, cspec, rate;
  var harmonics = 20;
  // GUI.qt;
  x = Synth(\dynsynth).setn(
    \freqs, Array.fill(harmonics, {|i| 110*(i+1)}),
    \amps, Array.fill(harmonics, {0})
  );
  // GUI :
  w = Window("harmonics", Rect(200, 470, 20*harmonics+40,140)).front;
  ms = MultiSliderView(w, Rect(20, 10, 20*harmonics, 110));
  ms.value_(Array.fill(harmonics,0.0));
  ms.isFilled_(true);
  ms.indexThumbSize_(10.0);
  ms.strokeColor_(Color.blue);
  ms.fillColor_(Color.blue(alpha: 0.2));
  ms.gap_(10);
  ms.action_({
    x.setn(\amps, ms.value*harmonics.reciprocal);
  });
)
