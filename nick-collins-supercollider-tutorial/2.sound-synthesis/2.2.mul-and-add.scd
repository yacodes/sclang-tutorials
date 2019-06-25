Server.local.reboot;
Server.local.quit;
s.queryAllNodes();

(
  Server.local.boot;
  Server.local.scope;
  FreqScope.new;
  Server.local.plotTree;
)


/* Mul and Add (and arguments to UGens)
 *
 * Two arguments recur in many UGens,
 * and its worth describing them separately in this tutorial file.
 *
 * They're useful because they provide a way of keeping signals
 * scaled appropriately to be used as inputs to other UGens.
 *
 * The audio output of the system expects numbers in the range -1 to 1,
 * but a frequency might require numbers from 20 to 20000,
 * and these different sorts of scale are dealt with through the mul and add arguments.
 */

/* If you check help files for UGens you'll
 * often see mul and add as the final arguments:
 * check the SinOsc help file now:
 */
[SinOsc]; // Cmd+d to bring up after double clicking anywhere on SinOsc, or on the brackets

/* Notice that mul is the third and add is the fourth.
 * You can directly address those inputs to the oscillator
 * (those 'arguments') by using the colon syntax:
 */
{SinOsc.ar(mul: 0.1)}.scope();
s.freeAll

/* For audio outputs
 * which this ar rate SinOsc is,
 * for it is the last thing going out to the soundcard
 * the values must be kept between -1 and 1
 * with mul:0.1, the previous sound was kept between -0.1 and 0.1,
 * safely within bounds.
 */

// Here is an overloaded sound (be careful listening to this):
{SinOsc.ar(mul: 2.0)}.scope();	// Loud! defaults are 440 Hz, amplitude multiplier 2.0

// and here is a sound whose amplitude is at a more reasonable volume:
{SinOsc.ar(mul: 0.1)}.scope();	// Loud! defaults are 440 Hz, amplitude multiplier 2.0
s.freeAll

/* You can see that the mul: part of the code is setting up an amplitude multiplier,
 * that is, it scales the signal on the y axis.
 */
{SinOsc.ar(mul: MouseY.kr(1.0, 0.1))}.scope(); // Demo of amplitude scaling
s.freeAll

/* There is another standard thing you will see happening to signals,
 * and that is offsetting (translating) on the y axis.
 * I use the add input of the UGen for this.
 */
{SinOsc.ar(mul: 0.1, add: MouseY.kr(0.9, -0.9))}.scope(); // Demo of offsetting

/* The mul and add controls help when you need to set one signal
 * as an input to another and need to scale the input signal
 * appropriately to the expected input values required.
 */
{SinOsc.ar(mul: MouseX.kr(0.1, 1.0), add: MouseY.kr(0.9, -0.9))}.scope();
s.freeAll

(
  {
    // Cutoff values need to be sensible frequencies in Hz; here sine output turned from -1 to 1 into 2000+-1700
    var cutoff =	SinOsc.ar(1, mul: MouseX.kr(0.0, 1700.0), add: 2000.0);
    // var cutoff = SinOsc.ar(1) * 1700.0 + 2000.0; // Same thing
    LPF.ar(WhiteNoise.ar, freq: cutoff);
  }.scope();
)
s.freeAll

// There is a shortcut for the mul and add inputs given by using the * and + symbols.
{0.1 * SinOsc.ar}.scope();

// Is the same as
{SinOsc.ar(mul: 0.1)}.scope();

// And
{0.1 * SinOsc.ar + 0.5}.scope();

// Is the same as
{SinOsc.ar(mul: 0.1, add: 0.5)}.scope();

// Filter example rewritten:
(
  {
    // Cutoff values need to be sensible frequencies in Hz; here sine output turned from -1 to 1 into 2000+-1700
    // var cutoff = 	SinOsc.ar(1, mul: MouseX.kr(0.0, 1700.0), add: 2000.0);
    var cutoff = SinOsc.ar(1) * 1700.0 + 2000.0; // Same thing
    LPF.ar(WhiteNoise.ar, freq: cutoff);
  }.scope();
)

/* I have used the : syntax to put values into particular inputs of the SinOsc UGen.
 * How do I know about these inputs, and are there other ways to utilise them?
 *
 * The arguments to a SinOsc are freq, phase, mul, add.
 *
 * How do I know that? Select SinOsc and hit cmd+d for the help file
 */
SinOsc; // Double click on SinOsc and press cmd+d for help
SinOsc; // Or select SinOsc and do cmd+J for the source code definition of this UGen

/* So if I make all the UGen's inputs explicit:
 *
 * SinOsc.ar(freq, phase, mul, add)
 *
 * Expected input values might be:
 * freq- 20 to 10000 (Hz)
 * phase- 0.0 to 1.0 through the cycle
 * mul: 0.0 to 1.0 from silence to full amplitude
 * add: 0.0 no offset
 *
 * (and the output of the SinOsc is between +1 and -1)
 */


/* In using the SinOsc UGen in code I must substitute
 * appropriate values into these inputs.
 * These values could be fixed constants, or they could be other UGens,
 * in which case they will probably be time varying values.
 *
 * If I don't specify a given input, a default value will be taken,
 * and that is what you heard happening above.
 */

// Explicit use of constants in all inputs:
{SinOsc.ar(440, 0.0, 0.1, 0.0)}.scope();
s.freeAll

// Plugging a UGen, a MouseX control, into the frequency input:
{SinOsc.ar(MouseX.kr(440, 880), 0.0, 0.1, 0.0)}.scope();
s.freeAll

/* Having the frequency argument as before (it is the first input, remember),
 * using the colon to refer to a particular input, and accepting defaults for the rest:
 */
{SinOsc.ar(MouseX.kr(440, 880), mul: 0.1)}.scope();

/* There are often many ways of accomplishing something.
 * For instance, to limit the volume of a single SinOsc, we might write:
 */
{SinOsc.ar(440, 0.0, 0.1)}.scope(); // Provide freq and mul arguments directly
{SinOsc.ar(mul: 0.1)}.scope(); // Provide just the multiplier argument explicitly
{0.1 * SinOsc.ar}.scope(); // Multiply the SinOsc UGen by a constant
{SinOsc.ar(440, mul: -20.dbamp)}.scope(); // Use dBs! The conversion calculation is done just once at the initialisation of the UGen

/* A note on modulation (you may find it useful to reread this later):
 *
 * mul and add are very useful in setting up modulators,
 * sometimes via the * and + versions.
 * The mul input in particular gets used for explicit modulation,
 * that is, multiplying different signals together.
 *
 * Using one SinOsc to modulate the frequency of another:
 */
{SinOsc.ar(SinOsc.ar(3, mul: 40, add: 440), 0, 0.1)}.scope();
s.freeAll

/* The inner SinOsc is the modulator.
 * 3 times per second, it varies between +-40 (mul scaling).
 * I add 440 to make this output value go between 400 and 480.
 * This is a suitable input varying frequency control for the outer SinOsc.
 */
