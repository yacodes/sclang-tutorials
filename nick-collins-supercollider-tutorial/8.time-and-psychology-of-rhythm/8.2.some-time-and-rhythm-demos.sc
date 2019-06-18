Server.local.boot;
Server.local.reboot;
Server.local.quit;
FreqScope();
Server.local.scope();
s.queryAllNodes();


/* Demoes on the perception of rhythm
 *
 * s.bind and OffsetOut will be used in these demoes
 * to get accurate timing of events;
 * see the 'Precise Timing in SC' tutorial
 */
(
  SynthDef(\beep, {|freq = 440, amp = 0.1, pan = 0.0, dur = 0.1|
    OffsetOut.ar(0, Pan2.ar(SinOsc.ar(freq, 0, amp) * Line.kr(1, 0, dur, doneAction: 2), pan));
  }).add();
)

// Test
Synth(\beep, [\freq, 440, \amp, 1]);


/* Example of timing sensitivity in spatialization
 *
 * An event is sent at equal volume to both ears
 * but arrives at the right ear 1 millisecond ahead of the left.
 * You will hear it coming from the right
 *
 * (demo works best over headphones)
 */
(
  {
    s.bind{Synth(\beep, [\freq, 440, \amp, 0.1, \pan, 1])};
    0.001.wait();
    s.bind{Synth(\beep, [\freq, 440,\amp, 0.1, \pan, -1])};
  }.fork();
)

// Which came first? 30 msec difference between two tones (try different values)
(
  {
    s.bind{Synth(\beep, [\freq, 440, \amp, 0.1, \pan, 0, \dur, 0.1 + 0.03])};
    0.03.wait();
    s.bind{Synth(\beep, [\freq, 560, \amp, 0.1, \pan, 0, \dur, 0.1])};
  }.fork();
)

/* How many events in these tuplets?
 * You may need to get someone else to test you,
 * or add a randomising function like rrand(3,9)
 */
(
  var n, delay;
  n = 4; // Start increasing by 1
  delay = 0.4 / n;

  {
    n.do {
      s.bind{Synth(\beep, [\freq, 440, \amp, 0.1, \pan, 0])};
      delay.wait();
    }
  }.fork();
)

// How many duration categories?
(
  var categories, n;
  n = 7;
  categories = [0.25, 0.33, 0.4, 0.5, 0.6, 0.67, 0.75, 0.8, 1, 1.25, 1.5, 1.75];
  n = min(n, categories.size);

  {
    inf.do {
      s.bind{Synth(\beep, [\freq, 440, \amp, 0.1, \pan, 0])};
      (categories.wrapAt(n.rand)).wait();
    }
  }.fork();
)

// Limits of tempo
(
  var tempo;

  // bps 0.5 (2 second period), 4 (0.25 second period)
  tempo = 0.5;

  {
    inf.do {
      s.bind{Synth(\beep, [\freq, 440, \amp, 0.1, \pan, 0])};
      1.wait();
    }
  }.fork(TempoClock(tempo));
)

// Tempo discrimination test
t = TempoClock(2);
(
  {
    inf.do {
      s.bind{Synth(\beep, [\freq, 440, \amp, 0.1, \pan, 0])};
      1.wait();
    }
  }.fork(t);
)

// Try different values like 1.01, 1.04, 1.1 for the multiplier in brackets
t.tempo = 2 * (1.01);


/* Swing
 *
 * Variable to hold amount of swing in seconds
 */
w = 0.1;
(
  {
    inf.do {|i|
      s.bind{Synth(\beep, [\freq, 440, \amp, 0.1, \pan, 0])};
      ([1, -1]@@(i) * w + 0.25).wait(); // @@ is wrapAt
    }
  }.fork(TempoClock(2));
)

w = 0.08; // Try 0.0, 0.2


/* Metric modulation
 *
 * quintuplets become new pulsation level
 * as tempo increases by 5/4
 */
(
  var clock = TempoClock(1);
  {
    5.do{|i|
      ("iteration"+i).postln();

      // Pulse beats
      {
        8.do {
          Synth(\beep, [\freq, 100, \amp, 0.5]);
          1.0.wait();
        };
      }.fork(clock);

      {
        (4 * 6).do {
          Synth(\beep, [\freq, 100, \amp, 0.5]);
          0.25.wait();
        };

        (5 * 2).do {
          Synth(\beep, [\freq, 100, \amp, 0.5]);
          0.2.wait();
        };
      }.fork(clock);

      8.wait();

      clock.tempo = clock.tempo * (5 / 4);
    };
  }.fork(clock);
)

/* @TODO Week 8 exercise:
 * explore, and vary, the examples of psychology of rhythm.
 *
 * Can you also implement any more advanced compositional
 * rhythmic structures (such as multiple simultanous tempi, or metric modulation)?
 */
