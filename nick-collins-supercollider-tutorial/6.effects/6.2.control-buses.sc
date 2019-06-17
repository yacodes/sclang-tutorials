Server.local.boot;
Server.local.reboot;
Server.local.quit;
FreqScope.new();


/* Control Buses
 * Just like .kr is control rate and .ar audio rate,
 * there are Control Buses as well as the Audio Buses.
 */
a = Bus.audio(s, 1); // Makes a 1-channel (mono) virtual audio bus
c = Bus.control(s, 1); // Makes a 1-channel (mono) virtual control bus
a.index; // Index of this bus
c.index; // And of the control bus


/* When you set a value you are setting
 * the current value held by the bus.
 *
 * You can also write to and from any bus using In and Out:
 */
c.set(9); // Set current value to 9


// If in a SynthDef I used
Out.kr(c.index, SinOsc.kr)  // Any other .kr UGen other than SinOsc could go here


/* I would be writing at control rate
 * to the control bus over time,
 * and might read it somewhere else:
 */
In.kr(c.index, 1); // Read 1 channel from this control bus location


/* This is a standard method of inter-Node communication —
 * different Synths can read or write to the same bus.
 *
 * Any argument of a Synth can be mapped to by control buses:
 */
(
  SynthDef(\mapexample, {|freq = 440|
    Out.ar(0, SinOsc.ar(freq, 0, 0.1));
  }).add()
)

g = Synth(\mapexample);
c.set(660);
g.map(\freq, c.index);
c.set(770);
h = {Out.kr(c.index, SinOsc.ar(550, 0, 100, 1000))}.play();
h.free();
g.set(\freq, 550);
g.free();


// Here is an additional example involving PlayBuf
(
  /* This loads into a buffer the default sound that comes with SuperCollider
   *
   * .read brings in the whole sound at once
   */
  b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");

  SynthDef(\playbuf, {|out = 0, bufnum = 0, rate = 1, trigger = 1, startPos = 0, loop = 1|
    Out.ar(out,
      Pan2.ar(PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum) * rate, trigger, BufFrames.ir(b.bufnum) * startPos, loop), 0.0)
    )
  }).add();
)

// Make a new control Synth, playing on control buses
(
  SynthDef(\playbufcontrols, {
    // Control for retrigger (impulse with modulated rate)
    Out.kr(0, Impulse.kr(LFNoise0.kr(0.5, 5, 6)));

    // Control for jump position in sample (any random frame)
    Out.kr(1, LFNoise0.kr(0.25, 0.5, 0.5));
  }).play(s);
)

a = Synth(\playbuf, [
  \out, 0,
  \bufnum, b.bufnum,
  \rate, 1,
  \trigger, "c0",
  \startPos, "c1"]);

/* Showing unmapping of control signals —
 * unmap the modulation of jump position when retriggered,
 * it will now be fixed
 */
a.set(\startPos, "c");

// Set fixed chosen start frame
a.set(\startPos, 30000);
