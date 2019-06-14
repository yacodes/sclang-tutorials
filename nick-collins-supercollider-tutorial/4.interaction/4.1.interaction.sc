Server.local.boot;
Server.local.reboot;
Server.local.quit;
FreqScope.new();

/* MouseX/Y
 * Using the mouse as a controller is a quick
 * and easy way of interacting with a patch
 *
 * MouseX.kr(leftscreenval, rightscreenval, warp, lag)
 * MouseY.kr(topscreenval, bottomscreenval, warp, lag)
 *
 * warp can be \linear or \exponential
 *
 * lag is a smoothing factor to avoid sudden jumps
 * in value if you move the mouse really quickly across the screen
 *
 * Compare these hearing tests (be careful, they're piercing)
 */

{SinOsc.ar(MouseX.kr(20, 20000, 'linear'), 0, 0.1)}.play();

{SinOsc.ar(MouseY.kr(20, 20000, 'exponential'), 0, 0.1)}.play();

/* The exponential mapping is far more comforting
 * as a proportion of screen space than the linear one!
 */


/* Since it crops up a lot in SuperCollider,
 * let's illustrate linear and exponential mappings as mathematical functions.
 *
 * 100 points are plotted (try (0..99) in isolation
 * if you're not sure what that part of the code does).
 * The original points have been remapped, first with
 * a linear mapping (via linlin, transforming a linear
 * input range to a linear output range) and secondly
 * via an exponential (via linexp for linear to exponential)
 *
 * (0..99).linlin(0, 100, 10, 1000).plot2
 * (0..99).linexp(0, 100, 10, 1000).plot2
 *
 * We'll see more of this with GUIs in the use of ControlSpec objects.
 * By the way, there are also UGen equivalents for these language side mapping functions:
 *
 * linlin language side = LinLin server side
 * linexp language side = LinExp server side
 *
 * (You'll also see shortcuts used on UGens like:
 * range (for linear) and exprange (for linear to exponential),
 * and there are explin and expexp too)
 *
 * For those curious, the mappings as mathematics are:
 * to convert number input x in range [a, b] to output y in [c,d]
 *
 * Linear:
 * y = ((x - a) / (b - a)) * (d - c) + c;
 *
 * Exponential (power operator is **) note that c can't be zero
 * y = c * ((d / c) ** ((x - a) / (b - a)));
 */



/* If you'd like to restrict a controller
 * to a discrete range, you can use the Index UGen
 *
 * Index.kr(array, indexing signal)
 * the indexing signal is clipped to keep it in range;
 * it points to an array of data in the first input.
 * Note that an array can't be used directly in this slot
 * (because it would confuse multi-channel expansion)
 * so a Buffer of data is used via the LocalBuf UGen
 *
 * There are three distinct states:
 */
(
  var vals;
  // Change me and the code should adapt
  vals = [100, 200, 880];
  {SinOsc.ar(Index.ar(LocalBuf.newFrom(vals), MouseX.kr(0, vals.size - 0.001))) * 0.2}.play()
)

(
  var vals;
  var numharm, basefreq;
 	// Number of harmonics
  numharm = 11;
	// Base frequency of series
  basefreq = 66;
  vals = basefreq * (Array.series(numharm, 1, 1));
  {SinOsc.ar(Index.kr(LocalBuf.newFrom(vals), MouseX.kr(0, numharm - 0.001)), 0, 0.1)}.play();
)



// The Mouse might also be used as a trigger:
(
  {
    var trig, mx;
    mx = MouseX.kr(0.0, 1.0);

    // This is a UGen which compares mx to the constant signal 0.5 at krate
    trig = mx > 0.5;
    SinOsc.ar(440, 0, 0.1 * trig);
  }.play();
)

// Trigger in a given region
(
  {
    var trig, mx, my;
    mx = MouseX.kr(0.0, 1.0);
    my = MouseY.kr(0.0, 1.0);
    trig = if ((mx > 0.3) * (mx < 0.5) * (my > 0.3) * (my < 0.7), 1, 0);

    // If is a UGen here, * is equivalent to logical AND
    SinOsc.ar(440, 0, 0.1 * trig);
  }.play();
)


/* To show a more involved example of the principle,
 * here's one of my favourite
 *
 * SuperCollider example patches (by James McCartney):
 *
 * Strummable guitar
 * Use mouse to strum strings
 */
(
  {
    var pitch, mousex, out;
    pitch = [52, 57, 62, 67, 71, 76]; // e a d g b e
    mousex = MouseX.kr;
    out = Mix.fill(pitch.size, {|i|
      var trigger, pluck, period, string;
      // Place trigger points from 0.25 to 0.75
      trigger = HPZ1.kr(mousex > (0.25 + (i * 0.1))).abs;
      pluck = PinkNoise.ar(Decay.kr(trigger, 0.05));
      period = pitch.at(i).midicps.reciprocal;
      string = CombL.ar(pluck, period, period, 4);
      Pan2.ar(string, i * 0.2 - 0.5);
    });
    LPF.ar(out, 12000);
    LeakDC.ar(out);
  }.play();
)

/* There is also a MouseButton UGen that can be used
 * as a trigger (it usually works better to use GUIs here, see the next tutorial)
 *
 * first argument to MouseButton is the off value,
 * second on on, when pressed button
 */
{SinOsc.ar(MouseButton.kr(400, 440), 0, 0.1)}.play();


/* Keyboard
 * You can also use the keyboard to trigger things.
 *
 * key code 0 = 'a' key
 */
{SinOsc.ar(800, 0, KeyState.kr(0, 0, 0.1))}.play(); // Server-side

/* On the language side, this is usually done with GUIs
 * which respond to certain keys, to trigger action functions
 * (also known in computer science as callbacks,
 * a function that gets called when a certain action is taken by the user or system).
 * The view that responds to the key must be in focus (see the GUI tutorial).
 *
 * For SC3.5 or earlier with the Document class,
 * you can work by setting action functions in the text documents themselves.
 * Here is an example of a callback from the Document as you type:
 */
(
  var doc;
  SynthDef("typeofsound", {
    Out.ar(0, Line.kr(1, 0, 0.1, doneAction: 2) * VarSaw.ar(Rand(100, 1000), 0, Rand(0.1, 0.8), 0.1));
  }).add();

  doc = Document.current; // This text window you're reading from!
  doc.keyDownAction_({arg ...args;
    [args[1],args[3]].postln;
    Synth("typeofsound");
  });
)

// Turn this off
(
  Document.current.keyDownAction_(nil);
)

[Document] // The Document help file has other examples of this
