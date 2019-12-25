(
  r = Routine({
    "abcde".yield;
    "fghij".yield;
    "klmno".yield;
    "pqrst".yield;
    "uvwxy".yield;
    "z{|}~".yield;
  });
)

r.next; // get the next value from the Routine
6.do({ r.next.postln });


// Scheduling routines
(
  r = Routine({
    var delta;
    loop {
      delta = rrand(1, 3) * 0.5;
      "Will wait ".post; delta.postln;
      delta.yield;
    }
  });
)
r.next;
TempoClock.default.sched(0, r);
r.stop;

(
  SynthDef(\singrain, { |freq = 440, amp = 0.2, sustain = 1|
    var sig;
    sig = SinOsc.ar(freq, 0, amp) * EnvGen.kr(Env.perc(0.01, sustain), doneAction: Done.freeSelf);
    Out.ar(0, sig ! 2);    // sig ! 2 is the same as [sig, sig]
  }).add;

  r = Routine({
    var delta;
    loop {
      delta = rrand(1, 3) * 0.5;
      Synth(\singrain, [freq: exprand(200, 800), amp: rrand(0.1, 0.5), sustain: delta * 0.8]);
      delta.yield;
    }
  });
)
r.play;
r.stop;

// Pause and resume: Task
// Routines have one sticky little characteristic that can limit their usefulness as musical objects.
// Once you stop a routine, you can only start it over again from the beginning.
// There is no way to replay the routine from the point where it was stopped.

// Task is a variation that can be paused and resumed at will.
// For example, let's iterate over a C major scale.
// Note that all of SuperCollider's control structures are valid inside a Routine or Task.
// Note also that we can use 'wait' as a synonym for 'yield'.

(
  t = Task({
    loop {
      [60, 62, 64, 65, 67, 69, 71, 72].do({ |midi|
        Synth(\singrain, [freq: midi.midicps, amp: 0.2, sustain: 0.1]);
        0.5.wait;
      });
    }
  }).play;
)

t.stop; // probably stops in the middle of the scale
t.play; // should pick up with the next note
t.free;

// When do you want to start
// By default, play applied to a Task starts the Task immediately.
// Play takes several arguments to control its behavior:
aRoutine.play(clock, quant)
aTask.play(argClock, doReset, quant)

clock (Routine) or argClock (Task)
Which clock should handle scheduling for this sequence
doReset (Task only)
If true, reset the sequence to the beginning before playing; if false (default), resume
quant
A specification of the exact starting time


// quant: Corresponds roughly to bar length;
// the current time is rounded up to the next multiple of this number phase:
// Position within the bar (0 = beginning of the bar)

// For convenience, if you just want to start at the beginning of the bar,
// you can give the bar length as a number.
// An array of two numbers tells SuperCollider the bar length and the phase.

// To see how this works in practice, let's take the C major scale above and play two copies of it slightly offset.
// We'll slow the rhythm down to 16th-notes (0.25) and start the second one 8th-note into the bar.
// We will need two tasks to do this, which will be manufactured in a function.
(
  f = {
    Task({
      loop {
        [60, 62, 64, 65, 67, 69, 71, 72].do({ |midi|
          Synth(\singrain, [freq: midi.midicps, amp: 0.2, sustain: 0.1]);
          0.5.wait;
        });
      }
    });
  };
)

t = f.value.play(quant: 4); // start on next 4-beat boundary
u = f.value.play(quant: [4, 2]); // next 4-beat boundary + a half-beat

t.stop; u.stop;

// Using data routines in note sequencing
(
  var midi, dur;
  midi = Routine({ [60, 72, 71, 67, 69, 71, 72, 60, 69, 67].do({ |midi| midi.yield }); });
  dur = Routine({ [2, 2, 1, 0.5, 0.5, 1, 1, 2, 2, 3].do({ |dur| dur.yield }); });

  SynthDef(\smooth, { |freq = 440, sustain = 1, amp = 0.5|
    var sig;
    sig = SinOsc.ar(freq, 0, amp) * EnvGen.kr(Env.linen(0.05, sustain, 0.1), doneAction: Done.freeSelf) * amp;
    Out.ar(0, sig ! 2)
  }).add;

  r = Task({
    var delta;
    while {
      delta = dur.next;
      delta.notNil
    } {
      Synth(\smooth, [freq: midi.next.midicps, sustain: delta]);
      delta.yield;
    }
  }).play(quant: TempoClock.default.beats + 1.0);
)

(
  t = Task({
    loop {
      Synth(\singrain, [freq: exprand(400, 1200), sustain: 0.08]);
      0.05.wait;
    }
  }).play;
)

t.stop;

// Fixes late messages
s.latency;
(
  t = Task({
    loop {
      s.makeBundle(s.latency, {
        Synth(\singrain, [freq: exprand(400, 1200), sustain: 0.08]);
      });
      0.1.wait;
    }
  }).play;
)

t.stop;
