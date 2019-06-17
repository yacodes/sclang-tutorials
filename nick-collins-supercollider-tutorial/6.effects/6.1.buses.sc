Server.local.boot;
Server.local.reboot;
Server.local.quit;
FreqScope.new();

/* Buses
 * When instantiating Synths we've begun to worry about audio buses,
 * because we're now starting to use the Out UGen (and there is also an In UGen).
 */

/* First a note about Audio inputs and outputs.
 * The scsynth server application has 128 buses by default.
 *
 * These can be thought of as mixer channels
 * or tracks within which independent audio can be running.
 *
 * One quirk is that the inputs and outputs for
 * your soundcard always reserve the first contiguous run of these.
 *
 * You set how many ins and outs your machine has in the ServerOptions class,
 * and that depends on the capabilities of your soundcard. The critical lines are:
 */
Server.local.options.numOutputBusChannels = 8;
Server.local.options.numInputBusChannels = 8;

/* You might change this to 2 in 2 out for a straight stereo setup
 *
 * This code has to be run before you boot the server in question —
 * it won't change anything in a current running server, just the next time you start up
 *
 * 8 in, 8 out is the default btw, and probably best if you stick with that.
 */

/* Assuming we have 8 out, 8 in, I know that of the 128 buses, indices
 *
 * 0-7 are the 8 outs
 *
 * 8-15 are the 8 ins
 *
 * 16-127 are for whatever rendering purposes I desire.
 *
 * These numbers are precisely those you see when you use the Out and In unit generators in SynthDefs.
 *
 * mono sound, just plays in left ear because that's the first audio out on my soundcard
 */
{Out.ar(0, SinOsc.ar(440, 0, 0.1))}.play();

// Mono sound, in right ear
{Out.ar(1, SinOsc.ar(440, 0, 0.1))}.play();

// Can't hear it, though its playing, because my machine only has stereo out capability
{Out.ar(2, SinOsc.ar(440, 0, 0.1))}.play();


/* You'll see it if you use the scope
 *
 * Remember to boot and -> default the internal server on the Mac,
 * or just use .jscope with SwingOSC
 *
 * Get the first audio input, route to the left ear
 */
{Out.ar(0, In.ar(8, 1))}.play();



/* A critical point is that if you have an n-channel sound,
 * which you put onto bus x, it will overlap onto buses x to x+n-1.
 *
 * Stereo sound put onto bus 0 plays first channel on 0, second on 1: so stereo out
 */
{Out.ar(0, SinOsc.ar([440, 880], 0, 0.1))}.play();

/* This would work if I had 8 ins and 8 outs...
 *
 * I get all 8 inputs and route to all 8 outputs.
 */
{Out.ar(0, In.ar(8, 8))}.play();

/* Similar, will output this 16 channel
 * sound to buses 16-31 (you won't hear anything)
 */
{Out.ar(16, SinOsc.ar(Array.series(16, 400, 100), 0, 0.1))}.play();

// This gets them back to hearing, mixing to central field
{Out.ar(0, Pan2.ar(Mix.ar(InFeedback.ar(16, 16)), 0.0))}.play();

// The InFeedback is necessary to avoid execution order problems we will only cover soon
