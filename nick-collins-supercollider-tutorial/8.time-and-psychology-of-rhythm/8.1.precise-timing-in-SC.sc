Server.local.boot;
Server.local.reboot;
Server.local.quit;
FreqScope();
Server.local.scope();
s.queryAllNodes();


/* Precise timing in SC: latency, bundles, OffsetOut
 *
 * See also [ServerTiming] — http://doc.sccode.org/Guides/ServerTiming.html
 *
 * In usual operation, when you ask for a Synth,
 * SuperCollider tries to instantiate it as fast as possible:
 */
Synth(\makemenow); // Won't do anything unless you had a \makemenow SynthDef :)

// There is a slight latency, of some milliseconds.

/* -------------------------------------------------
 * Optional partial explanation:
 * This is caused by the block boundary of calculation
 * (SC works internally by default at 64 samples at a time,
 * the control rate, and can only create new synths
 * on the control period boundaries) and message passing overheads.
 *
 * There is a network connection between the localhost server
 * and the language with communication by Open Sound Control protocol messages;
 * this network communication takes some time
 * (perhaps a few milliseconds on the same machine).
 *
 * If you control a synthesis server somewhere
 * else on the internet outside a local area, it can take much longer!
 * -------------------------------------------------
 */

/* This almost-immediate instantiation is fine
 * for reactive response when you want to minimise delay,
 * say to an incoming MIDI message, a GUI button press,
 * an onset trigger from audio...
 */


/* BUT, it can lead to ragged timing within sequencing.
 * Since expert percussionists can reputedly hear inaccuracies
 * in timing on the order of milliseconds, a little jitter in
 * realisation time for supposedly isochronous sequences
 * is noticeable in some circumstances.
 *
 * Investigation of complex rhythmic structures
 * only realisable by machine may also depend on really accurate timing.
 *
 * To get very accurate timing, instructions to
 * the sound synthesis server can be time-stamped,
 * where they are given a strongly marked future time of occurrence.
 *
 * This is at the cost of not having them happen immediately,
 * but at some known delay, the latency.
 *
 * SuperCollider has a latency setting, which defaults to 0.2 seconds
 */
s.latency; // s global variable points to the default server

/* You can change this;
 * I often go more for 50 milliseconds or so
 */
s.latency = 0.05;

/* BTW, if you set the latency too small,
 * so messages don't get through before their
 * future time required, you may see 'late' messages in the post window which look like:
 *
 * late 0.009407656
 * late 0.014832689
 * late 0.005836474
 * ...
 */

/* In order to use the latency rather
 * than have an 'as soon as possible' Synth,
 * you wrap the message to make the Synth in a bundle
 * (essentially, you make a time stamped packet,
 * which in general use can contain multiple instructions
 * for things that have to happen at exactly the same time,
 * such as coincident musical events).
 *
 * The shortcut way is to write:
 */
s.bind {Synth(\makemesoon);};

// If you had two things which had to happen simultaneously:
s.bind {Synth(\makemesoon); Synth(\makemesoontooatthesametime);};

/* Let's try and compare.
 * We may find it difficult to hear the difference
 * with the example next unless you concentrate,
 * but as you make more complicated rhythmic structures
 * and have more and more going on under control
 * (for example, granulation effects),
 * you may need to be careful about this.
 */

// Sound recipe, required
(
  SynthDef(\testbleep, {
    Out.ar(0,
      Pan2.ar(Line.kr(1, 0, 0.1, doneAction: 2) * SinOsc.ar(440) * 0.1, 0.0)
    )
  }).add();
)

// No use of latency, immediate, timing slightly more ragged
(
  {
    inf.do {|i|
      Synth(\testbleep);
      [0.5, 0.25, 0.02].wrapAt(i).wait;
    }
  }.fork();
)

(
  {
    inf.do {|i|
      s.bind { Synth(\testbleep); };
      [0.5, 0.25, 0.02].wrapAt(i).wait();
    }
  }.fork();
)

/* Try changing latency with the later loop
 * to see the effect (the first loop would not be affected)
 */
s.latency = 0.2;
s.latency = 0.01;

/* See also this help file for more on bundles
 * and alternative ways to create Bundles like makeBundle:
 * [bundledCommands] —> http://doc.sccode.org/Guides/Bundled-Messages.html
 */

/* Even with time stamps,
 * there may be issues with acheiving
 * absolute sample accuracy on the server.
 *
 * If you want to schedule two Synths,
 * one to follow the other at an arbitrary
 * position measured in samples (rather than relative time),
 * you will find this is impossible;
 * the synthesis server does not share a sample clock with the language
 * (sampling rates are advertised as immutable,
 * but sample clocks on audio interface hardware
 * drift a little each second,
 * so sample accuracy can be very difficult to achieve).
 *
 * (It is possible to acheive sample-based timing within Synths,
 * using server-side scheduling;
 * see the Server-side Sequencing and Triggers tutorial for some examples.)
 *
 * However, you can do better than the control period boundary for starting new Synths,
 * if you use the OffsetOut UGen rather than Out.
 *
 * This makes sure that the scheduled start position of
 * a Synth leads to an accurate sample start position
 * within a control period, by adding a fixed delay in samples as needed.
 */
[OffsetOut];

// OffsetOut is used exactly like Out, and just does its stuff for you.

// Sound recipe; only difference is OffsetOut instead of Out
(
  SynthDef(\testbleep2, {
    OffsetOut.ar(0,
      Pan2.ar(Line.kr(1, 0, 0.1, doneAction: 2) * SinOsc.ar(440) * 0.1, 0.0)
    )
  }).add();
)

// With OffsetOut
(
  {
    inf.do {|i|
      s.bind { Synth(\testbleep2); };
      [0.5, 0.25, 0.001].wrapAt(i).wait();
      // Note 0.001 milliseconds wait is under control period size, 64/44100 = 0.0014512471655329
    }
  }.fork();
)

// Without
(
  {
    inf.do {|i|
      s.bind { Synth(\testbleep2); };
      [0.5, 0.25, 0.001].wrapAt(i).wait();
      // Note 0.001 milliseconds wait is under control period size, 64/44100 = 0.0014512471655329
    }
  }.fork();
)
