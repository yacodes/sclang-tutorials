Server.local.boot;
Server.local.reboot;
Server.local.quit;
FreqScope.new();

/* Granular Synthesis
 * In Granular Synthesis sounds are modelled
 * out of microscopic particles of sound,
 * short grains in the region of 10-100 milliseconds long.
 */

/* There are lots of choices for these grains,
 * they might be enveloped sine tones,
 * or tiny extracts of sampled sound:
 */
b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");

// Three different possible grains
(
  {
    var singrain1, singrain2, sfgrain;
    singrain1 = SinOsc.ar(440, 0, XLine.kr(1.0, 0.0001, 0.05));
    singrain2 = FSinOsc.ar(800, 0.0, Line.kr(1.0, 0, 0.05).squared);
    sfgrain = (PlayBuf.ar(1, b.bufnum, BufRateScale.kr(b.bufnum))) * EnvGen.kr(Env([0, 1, 1, 0], [0.01, 0.01, 0.01], -4));
    [singrain1, singrain2, sfgrain];
  }.plot(0.1, s);
)


/* When lots of these microsounds are combined into big swarms,
 * we can make macroscopic soundscapes.
 *
 * We can control the swarms by scheduling grains over time, forming clouds of events.
 *
 * Simple sine grain synthdef - note the all important doneAction
 */
(
  SynthDef(\sinegrain, {|pan, freq, amp|
    var grain;
    grain = SinOsc.ar(freq, 0, amp) * (XLine.kr(1.001, 0.001, 0.1, doneAction: 2) - 0.001);
    Out.ar(0, Pan2.ar(grain, pan));
  }).add();
)

// Listen to a single grain;
Synth(\sinegrain, [\freq, rrand(100, 10000), \amp, exprand(0.05, 0.1), \pan, 1.0.rand2]);

// Schedule 100 random grains over 1 second
(
  {
    100.do({|i|
      Synth(\sinegrain, [\freq, rrand(100, 10000), \amp,exprand(0.05, 0.1), \pan, 1.0.rand2]);
      0.01.wait
    });
  }.fork()
)

/* Over time, we can change the characteristics of the swarm,
 * for example, playing with its density,
 * and control individual parameters of grains
 * within tendency masks or following certain paths
 *
 * schedule 200 random grains over time,
 * decreasing the range of allowed random frequencies and lowering the density over time
 */
(
  {
    200.do({|i|
      var timeprop = (i / 199.0) ** 3;
      Synth(\sinegrain, [\freq, exprand(100, 5000 - (20 * i)), \amp, exprand(0.05, 0.1), \pan, 1.0.rand2]);
      rrand((timeprop * 0.1).max(0.01), timeprop * 0.3).wait();
    });
  }.fork();
)



// Simple playbuf grain synthdef - note the all important doneAction
(
  SynthDef(\sfgrain, {|bufnum = 0, pan = 0.0, startPos = 0.0, amp = 0.1, dur = 0.04|
    var grain;
    grain = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum), 1, BufFrames.ir(bufnum) * startPos, 0) * (EnvGen.kr(Env.perc(0.01, dur), doneAction: 2) - 0.001);
    Out.ar(0, Pan2.ar(grain, pan));
  }).add();
)

b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");

// Individual grain
Synth(\sfgrain, [\bufnum, b.bufnum, \startPos, rrand(0.0, 1.0), \amp, exprand(0.005, 0.1), \pan, 1.0.rand2]);

/* Schedule 200 random soundfile playback grains over time,
 * with random offset positions into the soundfile and lowering the density over time
 */
(
  {
    200.do({|i|
      var timeprop = (i / 199.0) ** 3;
      Synth(\sfgrain, [\bufnum, b.bufnum, \startPos, rrand(0.0, timeprop), \amp, exprand(0.005, 0.1), \pan, 1.0.rand2]);
      rrand((timeprop * 0.1).max(0.01), timeprop * 0.4).wait();
    });
  }.fork();
)



/* Each grain might have many different parameters attached to it;
 * some salient ones might be the pitch, the duration of the envelope,
 * the pan position in the stereo field or the amplitude.
 * The overall cloud can also have some sort of distribution for these parameters,
 * which might lead to a tendency mask determining the range of frequencies
 * of the particles allowed at differnet points in time,
 * or control of the evolving density of the cloud.
 *
 * The composer's work is to both specify the grains,
 * and also control how they are used over time to make an interesting compositional structure.
 *
 * These techniques were first conceptualised and explored in instrumental
 * and electronic music by Iannis Xenakis (late 50s),
 * and further investigated in computer implementation,
 * notably by Curtis Roads and Barry Truax, from the early 1970s on.
 *
 * Real-time systems became plausible in the 1980s.
 *
 * Because you can take tiny slices of sound,
 * granular processing allows one to perform quite dramatic transformations on sound sources.
 * The sound can be made to disappear into a stream of tiny quanta and reappear,
 * coalescing out of distinct particles:
 */
(
  var w, slid, lastval;
  lastval = 0.0;

  // A 200 by 200 window appears at screen co-ordinates (100, 500)
  w = Window("My Window", Rect(100, 500, 200, 200));

  // A basic slider object
  slid = Slider(w, Rect(10, 10, 150, 40));

  // This is the callback- the function is called whenever you move the slider
  slid.action_({
    lastval = slid.value;
  });

  {
    inf.do({|i|
    var prop, timestart, timeend;
    prop = (i % 300) / 300;
    timestart = prop * 0.8;
    timeend = prop * (0.8 + (0.1 * lastval));
      Synth(\sfgrain,
        [\bufnum, b.bufnum,
         \startPos, rrand(timestart, timeend),
         \amp, exprand(0.005, 0.1),
         \pan, lastval.rand2,
         \dur, 0.1 + (lastval * 0.5)]
      );

      // Max in this to avoid ever going near 0.0 wait time, which would crash the computer!
      (((lastval * 0.2) + 0.01).max(0.01)).wait()
    });
  }.fork();

  w.front();
)


// Some classes to explore:
[PitchShift]; // A granular pitchshifter
[TGrains];	// Efficient granular synthesis on a buffer, from a single UGen

/* Also see various granular UGens by Josh Parmenter added for SC3.2:
 * GrainSin, GrainFM, GrainBuf, GrainIn, Warp1
 *
 * To read more on these techniques,
 * Curtis Roads's Computer Music Tutorial is a good introduction,
 * and his Microsound book explores many more possibilities.
 */
