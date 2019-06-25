Server.local.reboot;
Server.local.quit;
s.queryAllNodes();

(
  Server.local.boot;
  Server.local.scope;
  FreqScope.new;
  Server.local.plotTree;
)

/* Some useful ways to use Synths
 *
 * When we run code like
 */
{SinOsc.ar}.play();

/* We make a Synth (which you see counted on the synthesizer graphic under Synths).
 * We'll see soon enough ways to make reusable recipes for synthesis (SynthDefs)
 * but we'll stick with the quick {}.play formulation for now.
 * But let's just show a few things you can do here.
 *
 * We can store a reference to a running Synth to send messages to it later.
 */
a = {SinOsc.ar(440) * 0.1}.play();
a.run(false); // Turn off synthesis (saving CPU) without freeing the Synth
a.run(); // Restore (defaults to a.run(true)
/* Stop it explicitly:
 * note that I didn't need to use the 'stop all' cmd+. or alt+.
 * key command, and can individual kill specific Synths this way
 */
a.free();

/* Arguments
 *
 * An argument to the function {} is turned by the SuperCollider language into a control,
 * a way for you to change a parameter of your Synth later on.
 */
a = {|freq = 440| SinOsc.ar(freq) * 0.1}.play();
a.set(\freq, 330); // Change frequency!

// A common mistake is to try to pass a UGen as an argument:
a.set(\freq, MouseX.kr(220, 440)); // WON'T WORK, WILL CRASH 'ERROR: can't set a control to a UGen'
s.freeAll

/* You must have plugged together all the UGens earlier on within the {}.
 * More explanation of this later on
 * it's really to do with the language being separate to the synthesizer
 * and the Synth mechanism having to be used in certain ways.
 */

// Two arguments at once:
a = {|freq = 440, amp = 0.1| SinOsc.ar(freq) * amp}.play();

/* Change frequency and amplitude randomly within a uniform range;
 * run this line multiple times
 */
a.set(\freq, rrand(220, 440), \amp, rrand(0.05, 0.2));
s.freeAll
