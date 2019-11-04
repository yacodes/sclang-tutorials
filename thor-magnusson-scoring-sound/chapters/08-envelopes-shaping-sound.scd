// Chapter 8 - Envelopes and shaping sound
s.freeAll;

(
  s.boot;
  s.meter;
  FreqScope.new(512, 512);
  s.scope;
)

// The way we shape these sounds in both analog and digital synthesis is to use so-called “envelopes.”
// They wrap around our sound and give it the desired shape we’re after.
// Most people have for example heard about the ADSR envelope
// (where the shape is Attack, Decay, Sustain, and Release)
// which is one of the available envelopes in SuperCollider

// Envelopes in SuperCollider come in two types, sustaining (un-timed) and non-sustaining (timed)
// envelopes. A gate is a trigger (a positive number) that holds the envelope open until it gets a message
// to close it (such as 0 or less). This is like a finger pressing down a key on a MIDI keyboard. If we were
// using an ADSR envelope, when the finger presses the key, we would run the A (attack) and the D (decay),
// but then the S (sustain) would last as long as the finger is pressed. On R (release), when the finger releases
// the key, the R argument defines how long it takes for the sound to fade out. Synths with gated envelopes
// are can therefore be of un-definite time, i.e., its time is not set at the point of initialising the synth.

// However, using a non-gated envelope, or a timed one, we set the duration of the sound at the time of
// triggering the synth. Here we don’t need to use a gate to trigger and release a synth.


// Envelope types
Env.linen(1, 2, 3, 0.6).test.plot;
Env.triangle(1, 1).test.plot;
Env.sine(1, 1).test.plot;
Env.perc(0.05, 1, 1, -4).test.plot;
Env.adsr(0.2, 0.2, 0.5, 1, 1, 1).test.plot;
Env.asr(0.2, 0.5, 1, 1).test.plot;
Env.cutoff(1, 1).test(2).plot;
// using .new you can define your own envelope with as many points as you like
Env.new([0, 1, 0.3, 0.8, 0], [2, 3, 1, 4],'sine').test.plot;
Env.new([0,1, 0.3, 0.8, 0], [2, 3, 1, 4],'linear').test.plot;
Env.new({1.0.rand}!10, {2.0.rand}!9).test.plot;
Env.new({1.0.rand}!100, {2.0.rand}!99).test.plot;
s.freeAll;

// Different sounds require different envelopes.
// For example, if we wanted to synthesise a snare sound, we might choose to use the .perc method of Env.
{ LPF.ar(WhiteNoise.ar(0.5), 2000) * EnvGen.ar(Env.perc(0.001, 0.5)) ! 2 }.play;

// And more bespoke envelopes can be created with the .new method:
{Saw.ar(EnvGen.ar(Env.sine(0.3).range(140, 120))) * EnvGen.ar(Env.new([0, 1, 0, 0.5, 0], [0.3, 0, 0.1,0])) ! 2}.play;
// Note that above we are using a .sine envelope to modulate the frequency argument of the Saw UGen.

// Envelopes define points in time that have a target value, duration and shape. So we can define the value,
// length and shape of each of the nodes. The .new method expects arrays for the value, duration and shape
// arguments. This can be very useful, as through a very simple syntax you can create complex transitions
// of value through time:
Env.new([0, 1, 0.5, 1, 0], [1, 2, 3, 2], \welch).plot;
Env.new([0, 1, 0.5, 1, 0], [1, 2, 3, 2], \step).plot;
Env.new([0, 1, 0.5, 1, 0], [1, 2, 3, 2], \sqr).plot;
Env.new([0, 1, 0.5, 1, 0], [1, 2, 3, 2], [2, 0, 5, 3]).plot;
Env.new([0, 1, 0.5, 1, 0], [1, 2, 3, 2], [0, 0, 0, 0]).plot;
Env.new([0, 1, 0.5, 1, 0], [1, 2, 3, 2], [5, 5, 5, 5]).plot;
Env.new([0, 1, 0.5, 1, 0], [1, 2, 3, 2], [20, -20, 20, 20]).plot;
// The last array defines the curve where 0 is linear, positive number curves the segment up, and a negative
// number curves it down. Check the Env documentation for further explanation.


// The EnvGen - Envelope Generator
// The envelope itself does nothing. It is simply a description of a form; of values in time and the shape of
// the line between those values. If we want to apply this envelope to a signal, we need to use the EnvGen
// UGen to play the envelope within a synth graph. You note that the EnvGen has an .ar or a .kr argument,
// so it works either in audio rate or control rate. The envelope arguments are the following:
EnvGen.ar(envelope, gate, levelScale, levelBias, timeScale, doneAction);

// doneActions
// The doneActions are an important aspect of how the SC-server works. One of the key strengths of
// SuperCollider is how a synth can be created and removed very effectively, making it useful for granular
// synthesis, or playback of notes. Here a grain or a note can be a synth that exists for 20 milliseconds or
// 20 minutes. Users of data flow languages, such as Pure Data, will appreciate how useful this is, as synths
// can be spawned at wish, and don’t need to be hard wired beforehand.

// The doneActions are the following:
// • 0 - Do nothing when the envelope has ended.
// • 1 - Pause the synth running, it is still resident.
// • 2 - Remove the synth and deallocate it.
// • 3 - Remove and deallocate both this synth and the preceding node.
// • 4 - Remove and deallocate both this synth and the following node.
// • 5 - Same as 3. If the preceding node is a group then free all members of the group.
// • 6 - Same as 4. If the following node is a group then free all members of the group.
// • 7 - Same as 3. If the synth is part of a group, free all preceding nodes in the group.
// • 8 - Same as 4. If the synth is part of a group, free all following nodes in the group.
// • 9 - Same as 2, but pause the preceding node.
// • 10 - Same as 2, but pause the following node.
// • 11 - Same as 2, but if the preceding node is a group then free its synths.
// • 12 - Same as 2, but if the following node is a group then free its synths.
// • 13 - Frees the synth and all preceding and following nodes.


// The doneActions are used in the EnvGen UGen all the time and it is important not to forget it. However
// there are other UGens in SuperCollider that also can free their enclosing synth when an event has
// happened - such as finishing playing a sample buffer. The other UGens are the following:
// • PlayBuf and RecordBuf - doneAction when the buffer has been played or recorded.
// • Line and XLine - doneAction when a line has ended.
// • Linen - doneAction when the envelope is finished.
// • LFGauss - doneAction after the completion of a cycle.
// • DemandEnvGen - Similar to EnvGen.
// • DetectSilence - doneAction when the UGen detects silence below a threshold.
// • Duty and TDuty - doneAction evaluated when a duty stream ends.
