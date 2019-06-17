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
