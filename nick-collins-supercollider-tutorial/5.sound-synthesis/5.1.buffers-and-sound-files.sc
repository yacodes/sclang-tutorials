Server.local.boot;
Server.local.reboot;
Server.local.quit;
FreqScope.new();

/* Buffers and Sound Files
 *
 * To do sample playback and manipulation,
 * for streaming files off disk,
 * for recording and wavetables and many other processes,
 * it is necessary to handle memory buffers on the Server.
 *
 * Note: SuperCollider versions from 3.5 on have the
 * default sound files that come with SuperCollider in a different location.
 *
 * You will see the path as:
 */
Platform.resourceDir +/+ "sounds/a11wlk01.wav"; // 3.5 or later

/* Note that if you need a path for a sound file,
 * you can drag and drop to the text window in SuperCollider to get the path.
 */


/* There are 1024 individual buffers by default.
 * The Buffer memory is allocated as needed from the operating system.
 *
 * Advanced:
 * You can check defaults by looking at the ServerOptions class and Main: startup.
 *
 * The Buffer memory is not the memSize option;
 * memSize is just some reserved memory for use by plug-ins like delay lines.
 * So you should still set memSize big
 * because UGens like CombN or DelayN need to use it for their allocations.
 *
 * We'll deal with buffers using the convenience wrapper class appropriately called Buffer.
 * allocate a one channel buffer of 441000 sample frames (10 sec at standard sampling rate)
 *
 * s = server, 10 * 44100 num frames, 1 = 1 channel, i.e. mono
 */
b = Buffer.alloc(s, 10 * 44100, 1);

/* If you check scsynth's memory use in your operating system
 * (e.g., for OS X use the Terminal with the top command or Activity Monitor)
 * before and after running this line (top command would work) you should see it has gone up.
 *
 * Which buffer are we using?
 * This is an essential parameter to pass to lots of UGens
 */
b.bufnum;

// Restore that memory and free that bufferID
b.free();

/* To prepare buffers for playback by loopers or disk streamers,
 * there are other methods of the Buffer class you'll see called.
 *
 * To work with sample playback there are a variety of possible UGens to use.
 */


/* PlayBuf
 *
 * This loads into a buffer the default sound that comes with SuperCollider
 */
(
  /* .read brings in the whole sound at once
   * store handle to Buffer in global variable b
   */
  b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");

  SynthDef("playbuf", {|out = 0, bufnum = 0, rate = 1, trigger = 1, startPos = 0, loop = 1|
    Out.ar(out,
      Pan2.ar(
        PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum) * rate, trigger, BufFrames.ir(bufnum) * startPos, loop),
        0.0
      )
    )
  }).add();
)

/* BufRateScale is vital because the soundfile
 * I've loaded is actually at 11025Hz sampling rate,
 * and my audio output is at 44100Hz - so it adjusts
 * for different possible sampling rates.
 *
 * The BufFrames UGen returns, well,
 * the number of frames in the soundfile.
 *
 * But note the .ir - this is initialisation rate,
 * i.e., the UGen only runs once when first created,
 * it doesn't need to be continually recalculated.
 *
 * Note how even though the soundfile doesn't loop,
 * the Synth is not deallocated when done
 *
 * (it has no envelope function).
 * you'll need to cmd+period to kill it
 */
Synth(\playbuf, [\out, 0, \bufnum, b.bufnum]);

// Play at half rate
Synth(\playbuf, [\out, 0, \bufnum, b.bufnum, \rate, 0.5]);


// Example with GUI controlling Synth
(
  var w, rateslid, trigslid, startposslid, loopslid, a;

  a = Synth(\playbuf, [\out, 0, \bufnum, b.bufnum]);

  w = Window("PlayBuf Example", Rect(10, 200, 300, 150));
  w.front();

  /* Control positioning of new GUI elements,
   * so I don't have to think too hard about it
   */
  w.view.decorator = FlowLayout(w.view.bounds);

  /* James' shortcut slider class
   *
   * 250@24 means a Point of size 250 by 24
   *
   * |ez| is the same as arg ez;
   * — the EZSlider object is being passed into the callback action function
   */
  rateslid = EZSlider(w, 250@24, "Rate", ControlSpec(0.5, 10, 'exponential', 0.1), {|ez|
    a.set(\rate,ez.value)
  }, 1);

  trigslid = EZSlider(w, 250@24, "Trigger", ControlSpec(0, 1, 'lin', 1), {|ez|
    a.set(\trigger,ez.value)
  }, 1);

  startposslid = EZSlider(w, 250@24, "StartPos", ControlSpec(0.0, 1.0, 'lin', 0.01), {|ez|
    a.set(\startPos, ez.value)
  }, 0);

  loopslid = EZSlider(w, 250@24, "Loop", ControlSpec(0, 1, 'lin', 0.1), {|ez|
    a.set(\loop,ez.value)
  }, 1);

  w.onClose_({
    a.free();
  });
)


/* BufRd
 *
 * BufRd is similar to PlayBuf but lets you directly read from a buffer
 * (note you could also use this with non-soundfiles) via a phase argument.
 * This is more convenient for taking custom control of how you read through a sample.
 */
(
  /* This loads into a buffer the default sound that comes with SuperCollider
   * .read brings in the whole sound at once
   */
  b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");

  /* Using Mouse to scrub through- X position
   * is normalised position 0 to 1 phase through the source file
   */
  SynthDef("bufrd", {|out = 0, bufnum = 0|
    Out.ar(out,
      Pan2.ar(
        BufRd.ar(1, bufnum, K2A.ar(BufFrames.ir(b.bufnum) * MouseX.kr(0.0, 1.0)).lag(MouseY.kr(0.0, 1.0))),
        0.0
      )
    )
  }).play(s);
)

/* The K2A is needed to convert control rate Mouse to run at audio rate.
 * This is because the BufRd needs to know where it is reading for every sample.
 *
 * .lag (which is a shortcut to get a Lag UGen)
 * puts a smooth 'catch-up delay' (amount controlled by MouseY) on the scratching.
 */
[BufRd] // The help file has more examples



/* DiskIn
 * Here we only read a small part of the soundfile at a time;
 * you would use this for streaming a large file off disk.
 */
(
/* Prepare to stream.
 * You can use a big file for streaming:
 * replace the filename here with one valid for your machine.
 *
 * Note that dragging and dropping a file into the SC text
 * editor posts the full path of that file as text for you to use in your code.
 */
  b = Buffer.cueSoundFile(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav", 0, 1);
)

SynthDef(\diskin, {
  Out.ar(0, DiskIn.ar(1, b.bufnum));
}).play(s);

/* You can only playback,
 * you can't modulate the streaming rate in any way
 * (there is a more advanced UGen, VDiskIn,
 * that allows some extra functionality here).
 * But this allows you to bring in files for any processing you desire to do.
 *
 * help file - you will probably want to look
 * at the 'Object messaging style' further down the page, for now.
 */
[DiskIn];



/* Wavetables and oscillators
 * The implementation of most oscillator UGens
 * is to read sample values from a wavetable.
 * A short wavetable is read through again and again in a loop,
 * at a particular rate (giving a fixed pitch).
 *
 * plot 5 cycles of a SinOsc sine oscillator:
 * reads through the sine wavetable 5 times
 */
{SinOsc.ar(100)}.plot(0.05);

/* This is similar to sampling,
 * just with small tables which are continuously
 * reused many times per second (as many times as the frequency).
 *
 * Scanning through a fixed length table at variable rates means
 * that you sometimes fall inbetween table positions;
 * this can be covered by interpolation,
 * generating those inbetween values on the fly.
 *
 * You can specify the waveform shape for a wavetable yourself.
 * SuperCollider has a special efficient wavetable format to pack a buffer.
 *
 * Make a Buffer storage area
 */
b = Buffer.alloc(s, 512, 1);

// Fill the Buffer with wavetable data
b.sine1(1.0 / [1, 2, 3, 4, 5, 6], true, false, true);

// Stored shape (not in special SuperCollider Wavetable format, for clarity)
b.plot();

// OscN; N means non-interpolating
{OscN.ar(b, MouseX.kr(10, 1000), 0, 0.1)}.play();

[Osc];
[OscN];


/* There are various other UGens that leverage buffers.
 * You might try exploring the help files for
 */

// Buffer as array of data for UGen
[Index];

// Buffer for wave shaping distortion/complex sound generation
[Shaper];

// Buffer as complex Fourier data, gets passed through the phase vocoder processing chain
[FFT];

/* Note that Shaper and FFT will re-appear
 * in future weeks for effects and spectral analysis discussions.
 *
 * You'll probably see some other ways of using the Buffer
 * class to set or get information in server side Buffers from the language.
 *
 * (Sometimes communication with buffers uses the messaging style:
 * the exhaustive list is here: [Server-Command-Reference] and is a more advanced topic.
 * Just be forewarned that some help file examples might show some explicit message passing to handle buffers)
 */
