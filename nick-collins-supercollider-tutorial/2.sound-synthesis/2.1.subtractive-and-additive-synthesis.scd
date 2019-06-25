Server.local.reboot;
Server.local.quit;
s.queryAllNodes();

(
  Server.local.boot;
  Server.local.scope;
  FreqScope.new;
  Server.local.plotTree;
)


/* Sound Synthesis in SuperCollider: Subtractive and Additive Synthesis
 *
 * Note that sounds will at first be in mono, in the left ear. Later on we will sort out stereo position.
 *
 * We are going to use the scope with many of these tutorials, to see the sound waveform.
 * We'll get oscilloscope views of the sounds we synthesise, which assists with explaining some concepts.
 *
 * On SC3.6, use of the scope requires no special treatment.
 * But for SC3.5 or earlier, you need the internal Server for this tutorial:
 */
Server.default = s = Server.internal; // Run this line first, SC3.5

/* Or you may turn on the internal server via the graphical window;
 * make sure the default button is pressed and highlighted;
 * this tells the system which synthesizer to send instructions to
 */
s.boot();


/* For our convenience we will be using a certain shortcut construction for practising sound synthesis.
 * Later we will see another way of doing this that is a more recommended method,
 * but we shall begin with the notation below because it avoids some issues for the moment,
 * and allows us to get going straight away.
 */

//The construct looks like the following, but don't try and run this code:
(
  {
    // Some synthesis code
  }.scope()
)

/* Run the following line though:
 * this will create a frequency analysizer
 * which we will continue to run in the background
 * for spectral plotting of the sounds we explore.
 */
FreqScope.new();


/* Unit Generators
 *
 * SuperCollider follows the Unit Generator paradigm also used
 * in other synthesis languages like Csound, Max/MSP, Pd, Reaktor and others.
 *
 * There are many primitive building blocks, like types of tone generator,
 * filter or spatialiser, that are the unit generators.
 * These are connected together in a processing graph
 * to make more complicated synthesisers and sound processors.
 * These primitives are referred to as UGens.
 */

/* Each UGen has some set of inputs and outputs.
 * Most UGens have just one output, an audio stream or some sort of control signal.
 * The inputs vary a lot depending on the function of the UGen.
 *
 * You will get used to the typical parameter values expected
 * as inputs or outputs as you learn about the different UGens.
 *
 * There are certain ways to program connections which
 * are part of the syntax of the SuperCollider language,
 * and particular names for units that you will encounter as you learn this system.
 */


/* Subtractive Synthesis
 *
 * This is a good way to start learning SuperCollider.
 *
 * In subtractive synthesis, we start with a complex source,
 * and we subtract parts from this raw sound to make a more sculpted sound.
 * This is also termed a source+filter model.
 */

/* This line will make a pure white noise source,
 * equal energy at all spectral frequencies;
 * it can be unpleasant to listen to- the 0.1 makes sure its not too loud,
 * but be careful playing this
 */
{WhiteNoise.ar(0.1)}.scope();

/* That was just the source alone.
 * Now I have to filter it to make a less raw sound.
 */
{LPF.ar(WhiteNoise.ar(0.1), 1000)}.scope();

s.freeAll

/* The LPF is a Low Pass Filter which tails off energy above its cutoff frequency,
 * which is 1000Hz in this example
 */

/* In SuperCollider, to plug the white noise generator WhiteNoise
 * into the filter LPF I nest one within the other.
 * You can think of a UGen's inputs being the list of slots within the parentheses
 *
 * LPF.ar(input signal, cutoff frequency, ... )
 *
 * and in the example above, the thing to plug into the input signal slot is a white noise source,
 * so that's where the WhiteNoise generator goes.
 * The cutoff frequency is a fixed number, 1000, the second argument.
 *
 * Say that we now want a varying filter cutoff over time.
 * One UGen we could use here is the line generator, Line:
 */

// Take ten seconds to go from 10000 to 1000: inputs to Line are start, end, duration
Line.kr(10000, 1000, 10);

// So instead of the fixed value 1000, the Line UGen goes in that second slot
{LPF.ar(WhiteNoise.ar(0.1), Line.kr(10000,  1000, 10))}.scope() // Listen for ten seconds at least to hear the full effect

s.freeAll


/* There are lots of possible sources and lots of possible filters (try these help files)
 *
 * Some example sources:
 */

// Oscillators:
[Saw];
[Blip];

// Noise Sources:
[PinkNoise];
[LFNoise0];

// Some example filters:
[HPF];
[BPF];
[Resonz];

// Example of plugging one source into a filter:
{Resonz.ar(LFNoise0.ar(400), 1000, 0.1)}.scope();

s.freeAll;
s.boot

// Again using the Line generator to change the filter centre frequency over time
{Resonz.ar(LFNoise0.ar(400), Line.kr(10000, 1000, 10), 0.1)}.scope();

// An explicit and neater way to write this (we'll come back to this formulation)
(
  {
    // Local variables to hold objects as we build the patch up
    var source, line, filter;
    source = LFNoise0.ar(400);
    line = Line.kr(10000, 1000, 10);

    // The filtered output is the input source filtered by Resonz with a line control for the resonant frequency
    filter = Resonz.ar(source, line, 0.0005);

    // Last thing is returned from function in curly brackets, i.e. this is the final sound we hear
    filter;
  }.scope();
)


/* Additive Synthesis
 *
 * Rather than starting with something complex and taking energy away to sculpt a sound,
 * we can start with simple building blocks and add many of them together to create more involved sounds
 *
 * The classic building block in computer music is the sine tone
 */
{SinOsc.ar}.scope(); // Defaults to a concert A (440Hz)
s.freeAll

// Here is one way to get two sine tones at once:
{SinOsc.ar(400, 0, 0.1) + SinOsc.ar(660, 0, 0.1)}.scope();

// And here is a much easier way
{SinOsc.ar([400, 660], 0, 0.1)}.scope();

/* Something special just happened to the stereo field,
 * and I'll explain this in a moment.
 *
 * Let me first introduce a panning UGen:
 * Pan2.ar(input signal, pan position)
 *
 * pan position goes from -1 (hard left) to 1 (hard right)
 */
{Pan2.ar(WhiteNoise.ar(0.1), MouseX.kr(-1, 1))}.scope();

// So the panner takes a mono signal, and places it in the stereo field.

/* Now, multichannel sound is really straight forward
 * to create in SuperCollider, just by using an array
 *
 * We'll look at arrays more closely in a later week,
 * but for now just think of them as lists of data
 */
[100, 200, 300, 400, 500]; // 5 numbers in a list

// Each successive element in the list will be placed on one channel:
{SinOsc.ar([400], 0, 0.1)}.scope(); // One channel sound (see the scope)

s.freeAll

{SinOsc.ar(400, 0, 0.1)}.scope(); // Also one channel sound no array brackets are needed for a single number

{SinOsc.ar([400, 660], 0, 0.1)}.scope(); // Two channel sound (see the scope)

/* Three channel sound - you may only hear two,
 * because you probably have a stereo output on your computer,
 * not a three channel out
 */
{SinOsc.ar([400, 660, 870], 0, 0.1)}.scope();

/* We need a way to take multiple channels of sound and turn them into a mono or stereo signal
 *
 * One method is to wrap the multichannel sound with a Mix UGen:
 */
{Mix(SinOsc.ar([400, 660], 0, 0.1))}.scope(); // A two channel signal put through Mix turns into mono

s.freeAll

// And then, of course, Pan2 allows me to place this in the stereo field:
{Pan2.ar(Mix(SinOsc.ar([400, 660], 0, 0.1)), MouseX.kr(-1, 1))}.scope(); // A two channel signal put through Mix turns into mono

/* You are now equipped to explore additive synthesis via sine tones.
 *
 * In additive synthesis,
 * if we know a recipe for the spectrum (frequency content) of a sound,
 * we can synthesise it by adding up sine tones for each component frequency.
 *
 * Recipes for common waveforms are known from the Fourier theory of sound
 * (sinusoids at which frequencies and amplitudes to add up to create certain waveform shapes).
 *
 * Sawtooth wave: Add up n harmonics with amplitude falling off as 1/harmonicnumber, sign alternates between +1 and -1
 */
(
  {
    var n = 10;
    var wave = Mix.fill(10, {|i|
      var mult = ((-1) ** i) * (0.5 / ((i + 1)));
      SinOsc.ar(440 * (i + 1)) * mult;
    });
    Pan2.ar(wave / n, 0.0); // Stereo, panned centre
  }.scope();
)

s.freeAll

/* Square wave: Sum of odd harmonics, no even,
 * amplitude falls as off 1/harmonicnumber;
 * closest 'real' waveform is a clarinet tone
 */
(
  {
    var n = 10;
    var wave = Mix.fill(10, {|i|
      var harmonicnumber = 2 * i + 1; // Odd harmonics only
      SinOsc.ar(440 * harmonicnumber) / harmonicnumber;
    }) * 0.25;

    Pan2.ar(wave, 0.0); // Stereo, panned centre
  }.scope();
)

/* Triangle wave:
 * also odd harmonics only,
 * falls off as 1 over harmonicnumber squared with alternating sign
 */
(
  {
    var n = 10;
    var wave = Mix.fill(10, {|i|
      var harmonicnumber = 2 * i + 1; // Odd harmonics only
      var mult = ((-1) ** ((harmonicnumber - 1) / 2)) * (1.0 / (harmonicnumber * harmonicnumber));
      SinOsc.ar(440 * i) * mult;
    }) / n;
    Pan2.ar(wave, 0.0); // Stereo, panned centre
  }.scope();
)

s.freeAll

/* Bell sound example:
 *
 * This is a spectral recipe for a minor third bell,
 * at a base frequency of 500 run this line of code to see
 * how the frequencies are calculated from the multipliers
 */
500 * [0.5, 1, 1.19, 1.56, 2, 2.51, 2.66, 3.01, 4.1];

s.freeAll

// Bell spectra, all partials the same volume
{Mix(SinOsc.ar(500 * [0.5, 1, 1.19, 1.56, 2, 2.51, 2.66, 3.01, 4.1], 0, 0.1))}.scope();

/* I can also give each partial its own amplitude in the mix, rather than defaulting them all to 0.1
 *
 * Bell spectra, different volumes for partials
 */
{Mix(SinOsc.ar(500 * [0.5, 1, 1.19, 1.56, 2, 2.51, 2.66, 3.01, 4.1], 0, 0.1 * [0.25, 1, 0.8, 0.5, 0.9, 0.4, 0.3, 0.6, 0.1]))}.scope();

s.freeAll

/* Here is a generalisable patch that uses the variable n
 * to hold the number of sine tones desired for each run of the code:
 */
(
  var n = 10;
  {Mix(SinOsc.ar(250 * (1..n), 0, 1 / n))}.scope();
)

// If you're unsure what something is in code, investigate it in isolation:
(1..10); // Run this line and see what comes up in the post window

/* There are lots of ways of dealing with arrays of data in SuperCollider,
 * that we'll investigate as we go.
 */
