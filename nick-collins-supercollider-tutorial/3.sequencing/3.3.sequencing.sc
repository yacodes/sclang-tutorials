Server.local.boot;
Server.local.reboot;
Server.local.quit;

FreqScope.new();

// Sequencing events in SuperCollider

/* There are various mechanisms in SuperCollider to cause events to play over time.
 * Popularly known as sequencing, this is also called scheduling in the computer music literature.
 * In computer science speak, an event might be scheduled for a certain future occurrence time;
 * the scheduler takes care of makng this happen.
 */

/* At this stage, we'll learn some code mechanisms that get us
 * going quickly with placing events in time
 * (more technical detail can be discussed later in the course).
 * We've already learnt two essential adjuncts to doing this;
 * using envelope and doneAction:2 to create time-limited self-deallocating Synths,
 * and packaging reusable synthesis code as a SynthDef
 * so multiple Synths can be made from one recipe.
 */

/* In a separate file, we'll explore a few mechanisms to do scheduling
 * on the server alone, but here we'll look at sequencing Synths from the language.
 */

// Let's start with a SynthDef we can use for our experiments:
(
  SynthDef(\event, {|freq = 440, amp = 0.5, pan = 0.0|
    var env;
    env = EnvGen.ar(
      Env([0, 1, 1, 0], [0.01, 0.1, 0.2]),
      doneAction: 2
    );
    Out.ar(0, Pan2.ar(Blip.ar(freq) * env * amp, pan));
  }).add();
)


// Test event sound
// Accepts defaults. Event shouldn't hang around once envelope finished due to doneAction:2
Synth(\event);

// Specifying values
// Pan 1.0 should send to right ear
Synth(\event, [\freq, 880, \amp, 0.2, \pan, 1.0]);


// Let's go straight to seeing some code to schedule/sequence 2 events, evenly spaced:
(
  {
    // Wait for 1 time unit of default tempo, will probably work out to 1 second
    Synth(\event);
    1.0.wait;
    Synth(\event);
    // .fork is a computer science term for setting a new process (sequence) in action
  }.fork();
)

// Now 4 events, all evenly spaced
(
  {
    Synth(\event);
    1.0.wait;
    Synth(\event);
    1.0.wait;
    Synth(\event);
    1.0.wait;
    Synth(\event);
  }.fork;
)

// Which could be more concisely written using encapsulation:
(
  {
    4.do {
      Synth(\event);
      1.0.wait;
    };
  }.fork;
)

// Now 8 events, all evenly spaced, but with a random frequency each time
(
  {
    8.do {
      // rrand(low, hi) gets a uniform random number in that range
      Synth(\event, [\freq, rrand(440, 880)]);
      0.2.wait();
    };
  }.fork();
)

// Now 8 events, unevenly spaced
(
  {
    8.do {
      Synth(\event, [\freq, rrand(440, 880)]);
      rrand(0.2, 0.6).wait();
    };
  }.fork();
)

// Now 8 events, unevenly spaced, followed by 4 quick evenly spaced events
(
  {
    8.do {
      Synth(\event, [\freq, rrand(110, 220)]);
      rrand(0.2, 0.6).wait();
    };

    4.do {
      Synth(\event);
      0.25.wait();
    };
  }.fork();
)


/* Got the idea yet?
 * Write your list of instructions of code to schedule, down the page.
 * The scheduler will deal with calling them in order with the correct time gaps.
 */

/* In many cases you'd prefer to work relative to some tempo,
 * for instance, if you want to schedule events in terms of beats and measures.
 *
 * SuperCollider measures tempo in beats per second (bps) rather than beats per minute, i.e
 * 1 bps = 60 bpm
 * 1.6666667 bps = 100 bpm
 * 2 bps = 120 bpm
 * 2.4 bps = 144 bpm
 * 3 bps = 180 bpm
 *
 * (multiply by 60 to go from bps to bpm, divide by 60 in the other direction)
 */


/* For sequencing, you can change the clock with respect to which the timings are worked out.
 * There is a default (which was being used above)
 */

// Default clock
TempoClock.default;

// Get tempo in beats per second.
TempoClock.default.tempo;

// Note that 1 bps means 1 beat = 1 second, so the wait timings above are in seconds if 1 bps
// Set tempo, now 2 beats per second, e.g. 120 beats per minute
TempoClock.default.tempo = 2;


// You can also make your own clock:
(
  // 3 beats per second
  var tempoclock = TempoClock(3);
  {
    8.do {
      // rrand(low, hi) gets a uniform random number in that range
      Synth(\event, [\freq, rrand(440, 880)]);
      1.0.wait();
    };

  // Make sure the fork knows to use this clock rather than the default
  }.fork(tempoclock);
)

(
  // 1 beat per second
  var tempoclock = TempoClock(1);
  {
    /* inf.do does something forever.
     * Make very sure that there is a .wait of some duration inside the loop!
     */
    inf.do {
      Synth(\event, [\freq, rrand(440, 880)]);
      1.0.wait();
    };
  }.fork(tempoclock);
)

/* This sequence will keep going
 * until you press cmd+period to stop it.
 * You could also have written
 * a = {  ...somestuff... }.fork
 * and later called:
 * a.stop();
 * which shows the importance of keeping a handle on active processes;
 * variable a is used to store the forked process here.
 */

/* Exercises @TODO:
 * 1. Create an isochronous (evenly spaced) sequence of 16 events, separated by waiting 0.25 time units
 * 2. At 126 bpm create four events separated by beats (a four to the floor, so to speak)
 *    followed by 16 events separated by 0.25 beat gaps.
 *    The four inital events should all be a middle C (hint: try 60.midicps).
 *    The 16 faster paced events should go up in frequency over their course.
 *    Remember that 'do' is passed the iteration count as an argument.
 */

// 1. Create an isochronous (evenly spaced) sequence of 16 events, separated by waiting 0.25 time units
(
  var clock = TempoClock(1);
  {
    16.do {
      Synth(\event);
      0.25.wait();
    };
  }.fork();
)

/* 2. At 126 bpm create four events separated by beats (a four to the floor, so to speak)
 *    followed by 16 events separated by 0.25 beat gaps.
 *    The four inital events should all be a middle C (hint: try 60.midicps).
 *    The 16 faster paced events should go up in frequency over their course.
 *    Remember that 'do' is passed the iteration count as an argument.
 */
(
  var clock = TempoClock(126 / 60);
  {
    4.do {
      Synth(\event, [\freq, 60.midicps]);
      1.wait();
    };
    16.do {|i|
      Synth(\event, [\freq, (60 + i).midicps]);
      0.25.wait();
    };
  }.fork();
)


/* Further mechanisms for sequencing
 * There are many other ways to schedule events in SuperCollider.
 * Basics of server-side sequencing is covered next, in another file.
 * There is a library called Patterns that comes with SC
 * that provides its own ways to explore
 * the notion of algorithmically placing events in time.
 * We'll look more at this later.
 * You can explicitly schedule things in the future
 * using functionality provided by clocks.
 * For example, using the actual computer system clock:
 */
(
  // Start at 1.0 second from now
  SystemClock.sched(1.0, {
      // A function which states what you wish to schedule
      Synth(\event);

      // Return nil to do just once
      nil;

      // Return 1 to repeat every second
      // 1
    }
  )
)

/* The {}.fork construction here is a fast way to get going
 * (and is a wrapper for some other code we may discuss later;
 * but you can just use it without worrying for now).
 *
 * We haven't solved the full problems of having hierarchical
 * time structures like bars/measures here. 3.5 explores nested scheduling,
 * where one sequence causes other sequences to be triggered;
 * this is like having a higher level time unit, such as a measure,
 * within which inner events are scheduled on their own independent sequences.
 */
