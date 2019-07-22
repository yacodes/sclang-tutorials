Server.local.boot;
Server.local.reboot;
Server.local.quit;

{SinOsc.ar(440,0,0.1)}.scope

{SinOsc.ar(440,0,Line.kr(0.1,0.0,1.0))}.scope

// doneAction:2 causes the Synth to be terminated once the line generator gets to the end of its line
{SinOsc.ar(440, 0, Line.kr(0.1, 0, 1, doneAction: 2))}.scope

// ———————
// Envelopes
/* This makes an Envelope with three control points,
* at y positions given by the first array,
* and separated in x by the values in the second (see the Env help file).
* The curve drawn out should actually look like a letter envelope!
*/
Env([1, 0, 1], [1, 1]).plot

// One second 0 to 1 then half a second 1 to 0
Env([0, 1, 0], [1.0, 0.5]).plot

// Linen has attackTime, sustainTime, releaseTime, level, curve
(
Env.linen(0.03, 0.5, 0.1).plot
)

/* attackTime, decayTime, sustainLevel, releaseTime, peakLevel, curve
* note that the sustain portion is not shown in time;
* this particular envelope type deals with variable hold times,
* and the hold is missed out in the plot
*/
(
Env.adsr(0.01, 0.5, 0.5, 0.1, 1.0, 0).plot;
)


// Arguments attackTime, releaseTime, level, curve: good for percussive hit envelopes
(
  Env.perc(0.05, 0.5, 1.0, 0).plot;
)

// ———————
// Envelopes for Synthesis
// Amplitude Envelope
Env([1, 0], [1.0]).plot
{EnvGen.ar(Env([1, 0], [1.0]))}.scope
{SinOsc.ar(440, 0, 0.1) * EnvGen.kr(Env([1, 0], [1.0]))}.scope

// Frequency Envelope
Env([1000, 20], [1.0]).plot
{Saw.ar(EnvGen.ar(Env([1000, 20], [1.0])), 0.1)}.scope
// A fast frequency sweep is called a chirp in engineering literature, btw).
{Saw.ar(EnvGen.ar(Env([10000, 20], [0.5])), EnvGen.ar(Env([0.1, 0], [2.0])))}.scope

(
  {
    Saw.ar(
      // Frequency input
      EnvGen.kr(Env([10000, 20], [0.5])),
      // Amplitude Input
      EnvGen.kr(Env([0.1, 0], [2.0]))
    )
  }.scope
)

// FM sound
(
  {
    SinOsc.ar(
      SinOsc.ar(10, 0, 10, 440),
      0.0,
      // doneAction:2 appears again, the deallocation operation
      EnvGen.kr(Env([0.5, 0.0], [1.0]), doneAction: 2)
    )
  }.scope
)

{Saw.ar(EnvGen.kr(Env([500, 100], [1.0]), doneAction:2), 0.1)}.scope

{Saw.ar(SinOsc.ar(1, 0, 10, 440), Line.kr(0, 1, 1, doneAction:2))}.scope
{Saw.ar(SinOsc.ar(1, 0, 10, 440), XLine.kr(0.0001, 1, 1, doneAction:2))}.scope

// ———————
// Releasing Envelopes
{EnvGen.ar(Env([0, 0.1, 0], [0.1, 0.9]), doneAction: 2) * SinOsc.ar(330)}.play

// Sound continues
a = {EnvGen.ar(Env.asr(0.1,0.1,1.0),doneAction:2)*SinOsc.ar(330)}.play
// Let it finish, taking 2.0 seconds to fade out (it then deallocates, due to the doneAction:2)
a.release(2.0);

// Similar, but explicitly using gate argument, which holds the envelope at the releaseNode
a = {arg gate = 1; EnvGen.ar(Env.asr(0.1, 0.1, 0.9), gate, doneAction:2) * SinOsc.ar(330) }.play
// When gate is set to 0, the envelope can finish, and takes 0.9 seconds to fade out (releaseTime argument to Env.asr set above)
a.set(\gate, 0);

// ReleaseNode at node 1, which is the pair of 0.0 level in the first array and 3.0 seconds in the second
(
  e = Env([0.2, 1.0, 0.0], [0.1, 3.0], 0, 1);
  a = {arg gate = 1; EnvGen.ar(e, gate, doneAction: 2) * SinOsc.ar(550, 0, 0.1)}.play;
  // Takes 3.0 seconds to fade out
  a.set(\gate, 0);
)

// ———————
// Looping Envelopes
// ReleaseNode at 2, loopNode at 0
(
  e = Env([0.0, 0.0, 1.0, 0.0], [0.5, 1.0, 2.0], 0, 2, 0);
  a = {arg gate=1; EnvGen.ar(e, gate, doneAction: 2) * SinOsc.ar(550, 0, 0.1)}.play;
)
// Takes 2.0 seconds to fade out
a.set(\gate, 0);

/* If you set the envelope looping fast enough,
* you can get interesting control signals and even head towards audio rate waveforms.
*/
// releaseNode at 2, loopNode at 0
(
  e = Env([0.0, 1.0, -1.0, 0.0], [0.01, 0.01, 2.0], 0, 2, 0);
  e.plot;
  a = {arg gate=1; EnvGen.ar(e, gate, timeScale: MouseX.kr(0.1, 2.0), doneAction: 2)}.play;
)
/* Stops immediately since release transition to 0.0 occurs over 2 seconds,
 * too slow to be a pitched oscillation
 */
a.set(\gate, 0);

