Server.local.boot;
Server.local.reboot;
Server.local.quit;
FreqScope();
Server.local.scope();
s.queryAllNodes();

/* Further effects examples: spatialization and other processing
 *
 * Spatialization
 *
 * We'll pan some PinkNoise
 * (which has some energy across the spectrum,
 * without being the full equal power harshness of WhiteNoise),
 * rather than a much harder to localise sine tone
 *
 * Stereo panners equal power:
 */
{Pan2.ar(PinkNoise.ar(0.2), MouseX.kr(-1, 1))}.scope();

/* Compare linear crossfade, equal amplitude
 *
 * Drops in power in the middle
 */
{LinPan2.ar(PinkNoise.ar(0.2), MouseX.kr(-1, 1))}.scope();

/* Multichannel:
 *
 * Sending to any loudspeaker
 *
 * Direct to speaker
 * Straight to right/second speaker
 */
{Out.ar(1, PinkNoise.ar(0.1))}.scope();

/* Between speakers:
 *
 * PanAz main arguments:
 * numchannels, signal to pan,
 * pan position from 0 to 2 around the ring of speakers
 */
{PanAz.ar(8, PinkNoise.ar(0.2), MouseX.kr(0, 2))}.scope();

// See Also:
Pan4; // Quad panning
Balance2; // Adjust stereo mix to bias towards left or right speaker
Rotate2; // Rotate stereo mix circularly around two speakers


/* Ambisonics UGens
 *
 * Ambisonics is a special format for representing spatial sound,
 * modeling a sound and its strength on three dimensional axes
 * (more generally, in higher order spherical co-ordinate systems).
 *
 * We go:
 *
 * sound -> encode Ambisonics format signal -> decode Ambisonics signal to a given speaker set-up.
 *
 * The Ambisonics format is speaker set-up independent,
 * so you can design a piece in terms of intended spatial positioning,
 * and (in theory) smoothly cope with different concert playback conditions.
 *
 * Basic in-built SuperCollider support for 'B-format' Ambisonics:
 *
 * Demo in stereo, but could work with many more speakers
 */
(
  {
    var w, x, y; // a, b, c, d;

    // B-format encode for 2 dimensional sound; PanB would work in three dimensions
    #w, x, y = PanB2.ar(PinkNoise.ar(0.2), MouseX.kr(-1, 1));

    // Stereo decode
    DecodeB2.ar(2, w, x, y);

    // JMC example: B-format decode to quad
    // #a, b, c, d = DecodeB2.ar(4, w, x, y);
    // [a, b, d, c] // reorder to my speaker arrangement: Lf Rf Lr Rr
  }.play();
)

/* See also
 *
 * The Ambisonics extension libraries of Josh Parmenter
 */

/* in BEAST UGens, vector based amplitude panning,
 * used for positioning sounds in an arbitrary 3D speaker configuration:
 * works by considering triangles of speakers (like triangularization in computer graphics)
 */
VBAP;


/* Simulation of space
 *
 * Modeling air absorption: high frequencies drop off more quickly in air.
 * Filter the high frequencies more with distance,
 * e.g. low pass filter where decrease cutoff frequency with distance.
 *
 * Also amplitude inversely proportional to distance
 * (because intensity inversely proportional to distance squared)
 *
 * Exaggerated a bit from reality, no doubt
 */
(
  {
    var distance = MouseX.kr(1, 100); // 1 to 100 metres
    LPF.ar(WhiteNoise.ar(0.5), 10000 - (distance * 80)) / distance;
  }.scope();
)


/* Doppler effect:
 * Pitch shift due to change of radial distance of object from observer
 *
 * Reference sound
 */
{Saw.ar(440, 0.2)}.play();

/* Starts above pitch, ends below pitch,
 * due to cycle starts being closer together
 * when approaching (reducing delay),
 * and further apart when retreating (increasing delay)
 */
(
  {
    var radialdistance = Line.kr(10, -10, 5, doneAction: 2);
    DelayC.ar(Saw.ar(440, 0.2), 1.0, radialdistance.abs / 340.0);
  }.scope();
)

/* Doppler effect: pitch shift proportional to radial distance:
 *
 * Path straight towards, through and away; get clear discontinuity
 * Approximate speed of sound as 340 m/s
 * No frequency dependent filtering effects
 */
(
  {
    var source, radialdistance, absoluterd, dopplershift, amplitude;

    // Nee-naw emergency vehicle simulation
    source = Saw.ar(Demand.kr(Impulse.kr(LFNoise0.kr(0.5, 0.1, 2)), 0, Dseq([63, 60].midicps, inf)));

    // In metres, moving at 6.8 metres per second
    radialdistance = EnvGen.ar(Env([34, -34], [10]), doneAction: 2);

    absoluterd = radialdistance.abs;

    /* If something is 340 metres away,
     * takes 1 second to get there;
     * so make delay depend on distance away in metres
     */
    dopplershift = DelayC.ar(source, 1.0, absoluterd / 340.0);

    // Inversely proportional
    amplitude = (absoluterd.max(1.0)).reciprocal;

    Pan2.ar(amplitude * dopplershift, 0.0);
  }.play();
)

/* More complicated:
 * Object will move past 5 metres to your right,
 * on a line vertically down the page (as per ICM figure)
 *
 * Could add position dependent filtering
 * for head shadow and separate delay to two ears...
 */
(
  {
    var source, distance, radialdistance, absoluterd, dopplershift, amplitude;
    var side, angle;

    // nee-naw emergency vehicle simulation
    source = Saw.ar(Demand.kr(Impulse.kr(LFNoise0.kr(0.5, 0.1, 2)), 0, Dseq([63, 60].midicps, inf)));

    side = 5;

    /* Central side marker,
     * placed 5 metres directly right of observer,
     * observer facing ahead
     *
     * in metres, moving at 6.8 metres per second
     */
    distance = EnvGen.ar(Env([34, -34], [10]), doneAction: 2);
    angle = atan(distance / side);

    // Radial distance by
    absoluterd = (distance.squared + side.squared).sqrt;

    dopplershift = DelayC.ar(source, 1.0, absoluterd / 340.0);

    // Inversely proportional
    amplitude = (absoluterd.max(1.0)).reciprocal;
    Pan2.ar(amplitude * dopplershift, 1.0);
  }.play();
)


/* Further sound transformation facilities
 *
 * Frequency shifting moves all frequency components of a sound,
 * distorts harmonic relationships to inharmonic
 * e.g. 100, 200, 300, 400, 500, 600 Hz components, all moved by 70 Hz gives
 * 170, 270, 370, 470, 570, 670 which are no longer in any simple harmonic relationship
 *
 * We know that we can get frequency shifting by using ring modulation,
 * though there are two sidebands.
 *
 * As well as low pass filtering out the lower band in ring modulation,
 * there is aso a technique called 'single side band modulation'
 * via a technical device called the Hilbert transform.
 *
 * There are UGens for this:
 * FreqShift.ar(input, amount of shift in Hz, phase shift)
 */

/* Shift the harmonic set detailed above.
 * No audible effect of phase shifts on sines
 */
{FreqShift.ar(Mix(SinOsc.ar(100 * (1..6))) * 0.1, MouseX.kr(0, 1000), MouseY.kr(0, 2pi))}.scope();

// Unless you wibble phase quickly enough
{FreqShift.ar(Mix(SinOsc.ar(100 * (1..6))) * 0.1, MouseX.kr(0, 1000), SinOsc.ar(MouseY.kr(0, 100)))}.scope();

// Fun effects on audio input
{FreqShift.ar(SoundIn.ar(0, 0.1), MouseX.kr(0, 3000), SinOsc.ar(MouseY.kr(0, 100)))}.scope();



/* We mentioned the granular pitch shifter
 * UGens PitchShift and Warp1 in passing
 * back in the granular synthesis materials.
 *
 * Let's take a closer look at Warp1,
 * which accomplishes granular time stretching and pitch shifting of the grains.
 */
b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");

// Overlaps eight windows of 0.1 seconds, so one window every 0.1/8 = 0.0125 seconds
{Warp1.ar(1, b, pointer: MouseX.kr, freqScale: (2 ** (MouseY.kr(-2, 2))), windowSize: 0.1)}.scope();

// Increasingly randomise window shape to avoid rough repetition sounds
{Warp1.ar(1, b, pointer: MouseX.kr, freqScale: 1.0, windowSize: 0.1, windowRandRatio: MouseY.kr(0.0, 0.9))}.scope();



/* Building your own basic Overlap Add stretcher
 * (requires Buffer b from above):
 *
 * Define the windowed grains
 */
(
  SynthDef(\windowofsound, {|out = 0 dur = 0.0 bufnum = 0 amp = 0.1 rate = 1.0 pos = 0.0 pan = 0.0|
    var env, source;
    env = EnvGen.ar(Env([0, 1, 0], [0.5, 0.5] * dur, 'sine'), doneAction: 2);

    // Env([0,1,0],[0.1,0.1],'sine').plot

    source = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum) * rate, 1.0, pos * BufFrames.ir(bufnum), loop: 0); // Don't allow loop

    // OffsetOut for sample accurate starts of grains
    OffsetOut.ar(out, Pan2.ar(source * env, pan));
  }).add();
)

/* Language side grain scheduling: accurate timing via s.bind
 *
 * Will move through the source file in the time given
 *
 * Small randomisations to grain size,
 * amplitude and spacing used to avoid too much modulation noise from really strict window overlaps
 */
(
  var playbacktime = 10.0;
  var grainsize = 0.1;
  var grainspersecond = 100; // Overlap factor of 10
  var grainspacing = grainspersecond.reciprocal;
  var timedone;
  var proportion;
  var startrate = 1.75;
  var endrate = 0.25;
  var ratenow;

  {
    timedone = 0.0;
    while({timedone < playbacktime}, {

      // How far through the playback as a number from 0 to 1
      proportion = timedone / playbacktime;

      // proportion.postln;
      // linear interpolation (can make exponential etc)
      ratenow = ((1.0 - proportion) * startrate) + (proportion * endrate);

      // ratenow.postln;
      s.bind({
        Synth(\windowofsound, [
          \dur, grainsize*rrand(1.0, 1.1),
          \bufnum, b,
          \amp, rrand(0.09, 0.11),
          \rate, ratenow,
          \pos, proportion]);
      });

      timedone = timedone + grainspacing + rrand(0.0, 0.01);
      grainspacing.wait();
    });
  }.fork();
)

/* The PitchShift and Warp1 UGens just do this more efficiently under the hood.
 *
 * More complicated effects arise from particular sound analysis models.
 */

/* Week 6 exercise:
 * Build an example patch with a global effects unit (such as a reverb or distortion).
 *
 * You should construct the effects unit using a separate Synth;
 * this effect should be applied to any other Synths
 * (which might use any of the SynthDefs you've built so far on the course).
 *
 * Execution order is critical here and you will need to understand 6.3 to achieve this.
 */
