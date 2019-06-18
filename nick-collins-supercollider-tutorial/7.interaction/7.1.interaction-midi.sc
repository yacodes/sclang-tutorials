Server.local.boot;
Server.local.reboot;
Server.local.quit;
FreqScope();
Server.local.scope();
s.queryAllNodes();

// Interaction via MIDI, SoundIn, external controllers

/* MIDI
 *
 * To access your MIDI devices you first initialise:
 */
MIDIClient.init(); // Should post a list of available devices

/* There may be more than one source and destination device,
 * each containing different input and output ports.
 *
 * To react to incoming MIDI messages, the user sets up callback functions.
 */
MIDIIn.connect(0, MIDIClient.sources[0]); // First number is port number, second is device from sources list
MIDIIn.connect(); // Would work on its own but defaults to first port of first device
MIDIIn.connectAll(); // Connect to all attached input sources

/* Incoming MIDI messages can be easily handled
 * through some callback functions in MIDIIn.
 *
 * However, from SuperCollider 3.5, the use of MIDIFunc is much preferred.
 *
 * First, the old way:
 */
(
  // Set up callback for MIDI Note On message
  MIDIIn.noteOn = {|src, chan, num, vel|
    [chan, num, vel / 127].postln();
  };
)

/* MIDI messages typically have a 7-bit (2**7) value range,
 * so take on integers from 0 to 127.
 *
 * The vel/127 above converts from
 * this range to a 0.0 to 1.0 range befitting an amplitude control.
 */
(
  // Control change messages have a 7 bit value
  MIDIIn.control = {|src, chan, num, val|
    [chan, num, val / 127].postln();
  };
)

(
  /* Pitch bend has a 14 bit range
   * and is a bipolar signal
   * (so bend / 8192 will remap the range to -1.0 to 1.0)
   */
  MIDIIn.bend = {|src, chan, bend|
    [chan, bend / 8192].postln();
  };
)

// See the MIDIIn help file for further message types.
[MIDIIn];


/* Examples:
 *
 * Creating Synths with each new note on:
 */
(
  SynthDef(\sound, {|freq = 440, amp = 0.1|
    var saw, filter, env;
    saw = Saw.ar(freq);
    filter = Resonz.ar(saw, 1000, 0.1) * amp;
    env = EnvGen.ar(Env([0, 1, 0], [0.01, 0.1]), doneAction: 2);
    // dup(2) duplicates the mono signal onto two channels, giving instant stereo middle panned output
    Out.ar(0, (filter * env).dup(2));
  }).add();
)

// Create one Synth for every new note, Synths will be of finite duration because of the envelope
(
  MIDIIn.noteOn = {|src, chan, midinote, velocity|
    Synth(\sound, [\freq, midinote.midicps, \amp, velocity / 127.0]);
    [chan, midinote.midicps, velocity / 127].postln();
  };
)

// Turn off again
MIDIIn.noteOn = nil;



/* Keeping track of active (held-down, sustained)
 * notes can be a chore in MIDI.
 *
 * Here is an example of doing this using an array with 128 slots,
 * one for each possible MIDI note.
 *
 * Note the use of a gate; this will sustain until released
 */
(
  SynthDef(\sound, {|freq = 440, amp = 0.1, gate = 1|
    var saw, filter, env;
    saw = Saw.ar(freq);
    filter = Resonz.ar(saw, 1000, 0.1) * amp;
    env = EnvGen.ar(Env.asr(0.005, 1.0, 0.1), gate, doneAction: 2);
    Out.ar(0, (filter * env).dup(2));
  }).add();
)

(
  // Make Array of 128 slots, initially with nil objects in to represent nothing
  var activenotes = nil!128;
  var releasefunction = {|index|
		// Release existing note if present already
    if (activenotes[index].notNil) {
      activenotes[index].release; // Will send gate = 0
      activenotes[index] = nil; // Make sure now empty slot ready
    }
	};

  /* Create one Synth for every new note,
   * with logic to check existing notes
   * (though not MIDI channel sensitive)
   */
  MIDIIn.noteOn = {|src, chan, midinote, velocity|
    "received".postln();
    releasefunction.value(midinote);

    /* Put active note in array;
     * function above tidied any existing note on this key
     */
    activenotes[midinote] = Synth(\sound, [
      \freq, midinote.midicps,
      \amp, velocity / 127.0]);
  };

  // Must also look for note offs as indicated end of held note
  MIDIIn.noteOff = {|src, chan, midinote, velocity|
    releasefunction.value(midinote);
	};
)

/* Using control change for continuous variation;
 * run one block/line at a time here
 *
 * No envelope this time, permanent sound
 */
(
  SynthDef(\sound, {|freq = 440, amp = 0.1|
    var saw, filter, env;
    saw = Saw.ar(freq);
    filter = Resonz.ar(saw, 1000, 0.1) * amp;
    Out.ar(0, filter.dup(2));
  }).add();
)

// Create running synth
a = Synth(\sound, [\freq, 77, \amp, 0.9]);

// Use the set message to update the control inputs of the running synth
(
  MIDIIn.control = {|src, chan, num, val|
    a.set(\amp, val / 127);
    [chan, num, val / 127].postln();
  };
)

// When you're finished twiddling MIDI controllers
a.free();


// For sending MIDI messages out see the MIDIOut help file:
[MIDIOut];

/* WARNING:
 * by default there is a long latency to messages sent out,
 * to allow it to match with other default latencies in the system.
 */

// Quick way to access device 0, port 0
m = MIDIOut(0);

// Use this to remove all latency and send messages immediately
m.latency = 0.0;

// Arguments: channel, note, velocity
m.noteOn(1, 60, 127);
m.noteOff(1, 60, 0);

/* There are also some helper classes to allow you to more
 * easily set up multiple independent callbacks for the same type of message:
 */
[MIDIFunc];
[MIDIdef];

// To make a callback for when receiving note on messages:
MIDIIn.connect(0, MIDIClient.sources[1]); // Second source device

(
  b = MIDIFunc.noteOn({|velocity, midipitch, channel|
    [\velocity, velocity, \midinote, midipitch, \channel, channel].postln();
  });
)

// Make a separate callback, also for MIDI note on triggers
(
  c = MIDIFunc.noteOn({|velocity, midipitch, channel|
    "note on!".postln();
  });
)

// Remove first callback and keep second
b.free();

// See the [Using MIDI] helpfile for more information
c.free(); // Remove second

/* Note that by default,
 * cmd+period will remove any MIDIFuncs that haven't been made permanent
 */


/* SoundIn
 *
 * To obtain an audio input stream,
 * use the simple SoundIn UGen
 */

// Stereo through patching from 2 inputs to output
{SoundIn.ar([0, 1], 0.1)}.play();

/* Mono on input channel 1;
 * won't work if you don't have at least 2 inputs!
 */
{SoundIn.ar(1, 0.1)}.play();

/* So it's easy to build
 * effects processors for live audio:
 *
 * Ring Modulator
 */
(
  {
    // Stereo through patching from input to output
    SinOsc.ar(MouseX.kr(0.001, 110, 'exponential' )) * SoundIn.ar(0, 0.5);
  }.play();
)


/* SuperCollider comes with an amplitude tracker
 * and pitch tracker for realtime audio
 *
 * Use input amplitude to control Pulse amplitude -
 * use headphones to prevent feedback.
 */
(
  {
    Pulse.ar(90, 0.3, Amplitude.kr(SoundIn.ar(0)));
  }.play();
)

/* You can threshold the input
 * to avoid picking up background noise
 */
(
  {
    var input, inputAmp, threshhold, gate;
    var basefreq;
    input = SoundIn.ar(0, 0.1);
    inputAmp = Amplitude.kr(input);
    threshhold = 0.02;	// Noise gating threshold
    gate = Lag.kr(inputAmp > threshhold, 0.01);
    (input * gate);
  }.play();
)


/* The Pitch follower has many input arguments,
 * though you usually take the defaults
 * without worrying.
 *
 * It returns two outputs:
 * the tracked frequency and a signal indicating
 * whether it has locked onto any periodicity or not
 *
 * If on a Mac you'll need to swap back to internal server for using .scope
 * you can have both the internal and localhost server on at once,
 * but you might need to press the -> default button
 */
Server.internal.boot();

/* Showing the outputs:
 * K2A makes sure control rate signals
 * are converted to audio rate,
 * because the final output of a Synth has to be audio rate
 */
(
  {
    var freq, hasFreq;
    #freq, hasFreq = Pitch.kr(SoundIn.ar(1, 0.1));
    [K2A.ar(freq * 0.001), K2A.ar(hasFreq)];
  }.scope();
)

/* Detected fundamental frequency used
 * to control some oscillators with allpass reverberation
 *
 * Amplitude detector also used to make
 * the control track the input more effectively
 */
(
  {
    var in, amp, freq, hasFreq, out;
    in = Mix.ar(SoundIn.ar([0, 1]));
    amp = Amplitude.kr(in, mul: 0.4);
    #freq, hasFreq = Pitch.kr(in);
    out = Mix.ar(LFTri.ar(freq * [0.5, 1, 2]) ) * amp;
    6.do({
      out = AllpassN.ar(out, 0.040, [0.040.rand, 0.040.rand], 2);
    });
    out;
  }.play();
)

// Also switch waveform based on hasFreq output
(
  {
    var in, amp, freq, hasFreq, out;
    in = SoundIn.ar(1);
    amp = Amplitude.kr(in, mul: 0.4);
    #freq, hasFreq = Pitch.kr(in);
    out = if(hasFreq, Pulse.ar(freq, 0.5, 0.1), SinOsc.ar(freq, 0, 0.1));
    6.do({
      out = AllpassN.ar(out, 0.040, [0.040.rand, 0.040.rand], 2)
    });
    out;
  }.play();
)


/* There are various other machine listening capabilities in SuperCollider.
 * Machine listening is getting the computer
 * to extract perceptually and musically meaingful
 * attributes by analyzing an input sound.
 *
 * Here are some onset detectors which might be helpful:
 */
[Onsets];
[PV_HainsworthFoote];
[PV_JensenAndersen];

/* They rely on using the FFT UGen
 * in the front end to go from time domain to frequency domain.
 *
 * You can trust the code examples for now
 * and we'll investigate FFT properly later on
 * (or explore the help file yourself).
 *
 * Example triggering TGrains UGen:
 */
b = Buffer.read(s,Platform.resourceDir +/+ "sounds/a11wlk01.wav");

(
  {
    var source, detect;
    source = SoundIn.ar(0);

    // Second argument is detection threshold
    detect = Onsets.kr(FFT(LocalBuf(2048), source), 0.1);

    // detect = PV_HainsworthFoote.ar(FFT(LocalBuf(2048),source), 1.0, 0.0, 0.7, 0.01);
    TGrains.ar(2, detect, b, LFNoise0.kr(10, 0.2, 1.0), MouseX.kr(0, BufDur.kr(b)), MouseY.kr(0.1, 0.5), LFNoise0.kr(10, 1.0), 0.5, 2);
  }.play();
)


/* RecordBuf
 *
 * If you'd like to capture live sound, the RecordBuf UGen is your friend.
 *
 * You need to set up a buffer to store the recorded sample data.
 */
(
  var b;

	// 1 second mono buffer allocated on local server
  b = Buffer.alloc(s, 44100, 1);
  {
    /* Continuously record in a loop,
     * recording to the buffer we just declared
     *
     * Each record cycle multiplies the old data
     */
    RecordBuf.ar(SoundIn.ar(0), b, 0, 1.0, MouseX.kr(0.0, 1.0), 1, 1, 1);

    // Playback the captured buffer in a loop, backwards
    PlayBuf.ar(1, b, MouseY.kr(0.0, -1.0), 1, 0, 1);
  }.play();
)

/* You might sync captured buffers to tempo for dance music,
 * and add refinements like a user interface to choose when to rerecord the buffer...
 *
 * There are also facilities for control from graphics tablets and joysticks:
 */
[SC2DTabletSlider];
[HIDDeviceService];
[GeneralHID];

/* You might also like to try
 *
 * Serial port (via USB usually these days) for talking to certain external devices
 */
[SerialPort];

/* Another standard way is to communicate
 * with other applications using Open Sound Control,
 * a network music protocol;
 * we'll cover this in a later week in this course.
 */


/* @TODO Week 7 exercise:
 * Try out MIDI control of sound using MIDI keyboards,
 * or audio input feature control.
 *
 * You might trigger new short-lived Synths based on input,
 * or modulate parameters of an existing sustained Synth
 */
