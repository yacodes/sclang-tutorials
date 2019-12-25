// Musical sequencing will usually use TempoClock,
// because you can change its tempo and it is also aware of meter changes.
TempoClock

// Always runs in seconds
SystemClock

// which also runs in seconds but has a lower system priority
// (so it is better for graphic updates and other activities that are not time critical)
AppClock


SystemClock.sched(5, { "hello".postln });


// *sched* does relative scheduling
// *schedAbs* handles absolute scheduling
(
  var timeNow = TempoClock.default.beats;
  "Time is now: ".post;
  timeNow.postln;

  "Scheduling for: ".post;
  (timeNow + 5).postln;

  TempoClock.default.schedAbs(timeNow + 5, {
    "Time is later: ".post; thisThread.clock.beats.postln; nil
  });
)

// Note that we have moved to TempoClock, since this is the most commonly used.
// While there is only one SystemClock, there can be many TempoClocks all running at different speeds, if need be.
// One TempoClock is the default, accessed by TempoClock.default -- we will use this throughout.

(
  var timeNow;
  TempoClock.default.tempo = 2; // 2 beats/sec, or 120 BPM
  timeNow = TempoClock.default.beats;
  "Time is now: ".post; timeNow.postln;
  "Scheduling for: ".post; (timeNow + 5).postln;
  TempoClock.default.schedAbs(timeNow + 5, { "Time is later: ".post; thisThread.clock.beats.postln; nil });
)

// Inside a scheduled function, you might want to know
// which clock is running the function. thisThread.clock tells you this
SystemClock.beats;
TempoClock.default.beats;
AppClock.beats;
thisThread.clock.beats;

// Caution!
// If you schedule function that returns a number,
// the clock will treat that number as the amount of time
// before running the function again.

// fires many times (but looks like it should fire just once)
TempoClock.default.sched(1, { rrand(1, 3).postln; });

// fires once
TempoClock.default.sched(1, { rrand(1, 3).postln; nil });
