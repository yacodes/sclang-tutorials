Server.local.boot;
Server.local.reboot;
Server.local.quit;
FreqScope.new();

// One fork appears inside the other:
(
  {
    4.do{|j|
      // Nested sequence, create another fork
      {
        8.do{|i|
          Synth(\event, [\freq, (48 + (i * 3.3) + j).midicps, \amp, (1.0 - (i / 8))]);
          0.5.wait();
        }
      }.fork();
      4.0.wait(); // Outer fork must wait for inner fork to do its work
    }
  }.fork();
)


/* Two quickly created sounds;
 * they click because of the
 * line generators being quite crude
 */
(
  SynthDef(\sound1, {|freq = 440, amp = 0.1|
    var sound;
    sound = LPF.ar(Saw.ar(freq), 2000) * Line.kr(1, 0, 0.1, doneAction: 2) * amp;
    Out.ar(0, Pan2.ar(sound, 0.0));
  }).add();

  SynthDef(\sound2, {|freq = 440, amp = 0.1|
    var sound;
    sound = HPF.ar(LFPar.ar(freq), 1000) * Line.kr(0, 1, 0.5, doneAction: 2) * amp;
    Out.ar(0, Pan2.ar(sound, 0.0));
  }).add();
)

// Test SynthDefs
a = Synth(\sound1);
b = Synth(\sound2);
a.free();
b.free();


/* Nested scheduling;
 * each bar has a different length,
 * and uses one of two sounds
 */
(
  var barlengths = [4.0, 3.5, 5.0];
  var t = TempoClock(2.5);

  {
    inf.do({|i|
      var barnow = barlengths.wrapAt(i);
      "new bar".postln;
      {
        var whichsound;
        whichsound = [\sound1, \sound2].choose;

        ((barnow / 0.25) - 2).floor.do{|j|
          Synth(whichsound, [\freq, 300 + (100 * j), \amp, 0.3]);
          0.25.wait();
        };
      }.fork(t);

      barnow.wait();
    })
  }.fork(t)
)

// Another example
(
  var t = TempoClock(2);
  {
    4.do{
      "bar".postln;

      {
        [1.0, 1.0, 0.5, 0.5, 0.5, 0.25, 0.25].do({|val|
          Synth(\sound1, [\freq, rrand(48, 84).midicps, \amp, rrand(0.0, 0.3)]);
          "event".postln;
          val.wait();
        });
      }.fork(t);

      4.0.wait();
    }
  }.fork(t);
)

/* Demonstration of a simple structure for
 * a piece where different sections appear in a desired order
 *
 * Note if you were extending this to some large-scale form
 * with sectional repeats, that repeated materials could be
 * put into functions, to avoid repetition through encapsulation.
 */
(
  {
    SynthDef(\bleep, {|out = 0, note = 60, amp = 0.5, pan = 0.0|
      var freq, env;
      freq = note.midicps;
      env = EnvGen.ar(
        Env([0, 1, 1, 0], [0.01, 0.1, 0.2]),
        levelScale: amp,
        doneAction: 2
      );
      Out.ar(out, Pan2.ar(Blip.ar(freq) * env, pan));
    }).add();

    SynthDef(\bleep2, {|out = 0, note = 60, amp = 0.5, pan = 0.0|
      var freq, env;
      freq = note.midicps;
      env = EnvGen.ar(
      Env([0, 1, 1, 0], [0.1, 0.1, 0.02]),
        levelScale: amp,
        doneAction: 2
      );
      Out.ar(out, Pan2.ar(Blip.ar(freq, Line.kr(10, 1, 1)) * env, pan));
    }).add();

    SynthDef(\mlpitch, {
      var soundin, amp, freq, hasFreq;
      soundin = SoundIn.ar;
      amp = Amplitude.kr(soundin);
      #freq, hasFreq = Pitch.kr(soundin);
      Out.ar(0, amp * SinOsc.ar(freq));
    }).add();

    // Won't proceed until server confirms it has the SynthDefs ready
    s.sync();

    /* Make buffers;
     * Three sections
     * 1.
     */
    10.do({|i|
      Synth([\bleep, \bleep2].choose());
      0.15.wait();
    });
    1.0.wait();

    // 2.
    a = Synth(\mlpitch);
    1.0.wait();
    a.free();
    1.0.wait();

    /* 3. two sequences of actions happen simultaneously
     * (note no gap between the two)
     */
    {
      100.do({|i|
        Synth([\bleep, \bleep2].choose,[\note, ([60, 62, 64, 66, 67, 69, 71] - 12).choose()]);
        rrand(0.05, 0.15).wait();
      });
    }.fork();

    /* Though process has just been forked off,
     * straight to do further things in this thread too!
     */
    100.do({|i|
      Synth([\bleep, \bleep2].choose(), [\note, [60, 62, 64, 66, 67, 69, 71].choose()]);
      0.1.wait();
    });
  }.fork;
)

/* Week 3 exercise:
 *
 * Practice creating some SynthDefs
 * (which should have a doneAction: 2 in them),
 * and make simple sequences where you schedule
 * Synths over time in an entertaining way
 */
