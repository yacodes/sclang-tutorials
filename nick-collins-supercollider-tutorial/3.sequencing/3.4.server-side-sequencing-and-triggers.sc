Server.local.boot;
Server.local.reboot;
Server.local.quit;
FreqScope.new();

/* Server-side Sequencing and Triggers
 *
 * Exploring some UGens that let you sequence on the server,
 * without any language intervention;
 * timing patterns all within a Synth.
 * Like analogue sequencing modules...
 */

// Clocking UGens:

/* Impulse
 * A sequence of isochronous clicks, can make a good clock signal:
 */

// From rhythmic to audio rate
{Impulse.ar(MouseX.kr(1, 100))}.play


/* Dust
 * Rather than evenly spaced clicks,
 * the opposite is randomly occurring (stochastic) clicks.
 */

/* From rhythmic to audio rate;
 * the Mouse is controlling the average number
 * of clicks per second, they are not evenly spaced!
 */

{Dust.ar(MouseX.kr(1, 100))}.play

// Types of LFNoise for linear random noise between -1 and 1 at a certain rate
(
  {
    [
      LFNoise0.ar(100),	// Step
      LFNoise1.ar(100),	// Linear interpolation
      LFNoise2.ar(100)	// Quadratic interpolation
    ]
  }.plot(0.1);
)


/* Triggers
 *
 * When a signal crosses from a nonpositive value to a positive value,
 * the transition can act as a trigger in the input of some UGens.
 *
 * There are rounding errors to watch out for, and you need to avoid positive zero;
 * usually safer to force a transition from -0.01 to 1, for example, rather than 0 to 1
 *
 * The clock signals often make good trigger sources, for instance, Impulse.
 *
 * Stepper responds to triggers to go through a sequence:
 * Stepper.ar(trig, reset, min, max, step, resetval);
 *
 * We'll trigger it with an Impulse and make it go between 1 and 10 in steps of 1 (values must be integers).
 */

// Plot it out
{Stepper.ar(Impulse.ar(100), 0, 1, 10, 1)}.plot(0.3, minval: 0, maxval: 10);

// Slowed down and used to control a SinOsc frequency
{SinOsc.ar(Stepper.ar(Impulse.ar(10), 0, 1, 10, 1) * 100, 0, 0.1)}.play;


/* To get arbitrary pitches (rather than just a monotonic sequence),
 * Stepper can be combined with Select:
 */

// Impulse frequency of 4 is 4 events per second
// kr used since slow rates and Select works with array data second input if kr but not ar
{
  Saw.ar(
    Select.kr(
      Stepper.kr(
        Impulse.kr(4, 0.1),
        0, 0, 7,
      ),
      [72, 63, 67, 72, 55, 62, 63, 60].midicps
    ),
    0.1
  );
}.play();

// Speed control
{
  Saw.ar(
    Select.kr(
      Stepper.kr(
        Impulse.kr(
          MouseX.kr(1, 40),
          0.1
        ),
        0, 0, 7, 1
      ),
      [75, 63, 67, 72, 55, 62, 63, 60].midicps
    ),
    0.1
  );
}.play

/* As well as this sort of sequencing,
 * Select can also be used to dynamically
 * choose between UGens in a single running Synth)
 */




/* Any signal can be turned into triggers.
 *
 * The Trig and Trig1 UGens give 'spiky' signals as output
 * (they hold for a user-specified duration when triggered;
 * Trig1 always outputs a 1, Trig follows the stimulus value).
 */

/* Trigger at start of every sinusoidal cycle
 * (where sine goes from negative to positive)
 */
(
  {
    var source = SinOsc.ar(100);
    // Plot both original signal, and the trigger pattern
    [source, Trig1.ar(source, 0.001)];
	}.plot(0.1);
)


/* In the following examples we'll show going
 * from LFNoise UGens to the trigger points.
 */

// Trigger whenever crossing from negative to positive
(
  {
    var source, trigger;
    source = LFNoise0.ar(100);
    trigger = Trig1.ar(source, 0.001); // 0.001 is duration of trigger signal output
    [source, trigger];
  }.plot(0.2);
)

// Trigger on all ups
(
  {
    var source, trigger;
    source = LFNoise0.ar(100);
    trigger = Trig1.ar(source - Delay1.ar(source), 0.001); // 0.001 is duration of trigger signal output
    [source, trigger];
  }.plot(0.2);
)

// Trigger on any change
(
  {
    var source, trigger;
    source = LFNoise0.ar(100);
    trigger = Trig1.ar(abs(source - Delay1.ar(source)), 0.001); // 0.001 is duration of trigger signal output
    [source, trigger];
  }.plot(0.2);
)



/* Latch: on a trigger, hold an input value
 * Latch.ar(in, trig)
 * Allows resampling and triggered rendering
 */

// Grab the sine's current value 100 times a second
{Latch.ar(SinOsc.ar(133), Impulse.ar(100))}.plot(0.5);

// Removes smoothing!
{Latch.ar(LFNoise2.ar(100), Impulse.ar(100))}.plot(0.1);

// Could be used to create sequencing patterns!
{SinOsc.ar(300 + (200 * Latch.ar(SinOsc.ar(13.3), Impulse.ar(10)))) * 0.2}.play;



// Non-sustaining envelopes can be retriggered via the gate input to an EnvGen
{EnvGen.ar(Env([0, 1, 0], [0.01, 0.01]), Impulse.kr(50))}.plot(0.1);

// If you set the envelope up carefully, this could be used like a more flexible Stepper
{EnvGen.ar(Env([0, 1, 0, 0.5, -0.4], 0.01!4), Impulse.kr(25))}.plot(0.1);

// Slowed down by factor of 10 to be heard as held pitches
{SinOsc.ar(400 * (1 + EnvGen.ar(Env([0, 1, 0, 0.5, -0.4], 0.1!4, curve:\step), Impulse.kr(2.5))))}.play;

// Use midicps on output to get scales
{SinOsc.ar(EnvGen.ar(Env([63, 63, 60, 55, 60], 0.125!4, curve:\step), Impulse.kr(2)).midicps)}.play;

/* The Impulse's rate acts like a beats per second here,
 * and the envelope timings are in beats (0.125 per transition)
 */

// Percussive sound retriggered 3 times a second
(
  {
    var sound, env, trig;
    trig = Impulse.ar(3); // Trigger source
    sound = Mix(LFPulse.ar(110 * [1, 5/2], 0.0, 0.5, 0.2));
    env = EnvGen.ar(Env.perc(0.02, 0.2), trig); // With retriggering controlled by impulse
    Pan2.ar(sound * env, 0.0);
  }.play();
)

/* Note that if the envelope has a release node,
 * the gate input to an EnvGen is used instead as
 * a control which keeps the envelope held open (gate = 1)
 * until released (gate = 0); see the EnvGen and Env help files)
 */




/* Triggers can be set up in SynthDefs with a shortcut;
 * they appear in SynthDefs as t_xxxx arguments or as
 * specified as an explicit \tr in SynthDef rates argument.
 *
 * This is useful when you want to manually force
 * a trigger via a .set message to a Synth
 */
(
  SynthDef(\mytriggersynth, {|trig = 0|
    var env;

    /* Must have additional starting level in envelope,
     * else no nodes to go back to
     */
    env = EnvGen.ar(Env([2, 2, 1], [0.0, 0.5], 'exponential'), trig);
    Out.ar(0, Pan2.ar(Resonz.ar(Saw.ar(env * 440), 1000, 0.1), 0.0));
  }, [\tr]).add();
)

a = Synth(\mytriggersynth);

/* If this wasn't an explicit trigger input,
 * this wouldn't reset the envelope
 */
a.set(\trig, 1);
a.free();

