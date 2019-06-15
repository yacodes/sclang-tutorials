Server.local.boot;
Server.local.reboot;
Server.local.quit;
FreqScope.new();


/* In this example code,
 * a sound file can be made to loop at any selection in the graphical display
 *
 * load soundfile onto Server
 */
b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");

// SynthDef (making Synth straight away) which has arguments for the loop points
c = SynthDef(\loopbuffer, {|start = 0, end = 10000|
  Out.ar(0,
    Pan2.ar(
      BufRd.ar(1, 0, Phasor.ar(0, BufRateScale.kr(b.bufnum), start, end), 0.0)
    )
  )
}).play(s);
/* *BufFrames.ir(b.bufnum)
 * this isn't needed since the GUI gives us positions directly in samples
 */

// Make a simple SCSoundFileView
(
  w = Window("soundfiles looper", Rect(10, 700, 750, 100));
  w.front();

  a = SoundFileView(w, Rect(20, 20, 700, 60));
  f = SoundFile.new();
  f.openRead(Platform.resourceDir +/+ "sounds/a11wlk01.wav");

  // Set soundfile
  a.soundfile = f;

  // Read in the entire file
  a.read(0, f.numFrames);

  // Refresh to display the file
  a.refresh();

  /* Set a function which is called when the mouse is let go,
   * i.e. just after dragging out a selection in the window
   */
  a.mouseUpAction_({|view|
    var where;

    // Get the latest selection (assuming no other selections going on)
    where = (view.selections[0]);

    // Post where - start sample and length in samples of selection
    where.postln();

    // Convert to start and end samples for loop area
    c.set(\start, where[0], \end, where[0] + where[1]);
  });
)
