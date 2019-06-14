Server.local.boot;
Server.local.reboot;
Server.local.quit;
FreqScope.new();

/* Graphical user interface capabilities in SC
 * let us build frontends for our computer music projects.
 * They are a convenient way to create custom virtual synths,
 * and package up novel programs for ourselves and other users.
 *
 * GUI classes include various forms of slider, buttons, dials,
 * drop down lists, drag and drop facilities and many more custom views.
 *
 * This file will use code which should work on all platforms
 * without any worry about the underlying implementation (SC 3.3.1 on).
 * There may be slight differences between versions of
 * SuperCollider on the available GUI capabilities.
 *
 * [side note: On the Mac, for SC3.5 and earlier,
 * you can press shift+cmd+N immediately to see a selection of the available GUI widgets.]
 */


/* Just in case you want to know more about the implementation:
 *
 * Because GUIs tend to be quite operating system specific,
 * under the surface, there are different main GUI implementations available.
 *
 * From SC 3.6, the standard GUI library is qt.
 *
 * Historically, there are also OS X ('cocoa') specific classes
 * (usually with prefix SC before the class names used here)
 * and SwingOSC ('swing') Java cross platform classes (usually with prefix JSC).
 *
 * You can call the standard cross-platform GUI class names,
 * like Slider, Window, View, without worrying about which of qt,
 * Cocoa or SwingOSC is operative.
 *
 * Both qt and SwingOSC act like servers,
 * sending and receiving messages from the language app.
 * On OS X, a native Cocoa implementation is built into
 * the standard language environment for SC3.5 and earlier.
 *
 * Test which GUI library you are using by default:
 */
GUI.current();

/* For more on this, see:
 *
 * [GUI] main GUI help file
 *
 * [GUI-Classes] list of all GUI classes, with cross-
 *
 *
 * Quick swap of implementation:
 */

// SC 3.5 and earlier on a Mac
GUI.cocoa();

// Will only work if SwingOSC is installed, see instructions with SwingOSC
GUI.swing();

/* Make sure SwingOSC server is running
 * if you are using that, before you run any GUI code:
 */
SwingOSC.default.boot();


/* To make a window
 * The Rect(angle) takes the initial screen position and the window size
 * as screenx, screeny, windowwidth, windowheight, where screeny is 0 at the bottom
 */
(
  var w;
  w = Window("My Window", Rect(100, 500, 200, 200));

  /* A 200 by 200 window appears at screen co-ordinates (100, 500)
   *
   * This line is needed to make the window actually appear
   */
  w.front;
)

/* Note that we count on the y axis from
 * screen origin at bottom left, to the bottom left corner of the window.
 */

/* We add controls to our window,
 * defining any parameters of their use.
 * We pass in the window we wish the control to appear in
 * and use a Rect again to specify where in the window
 * the control will appear and how large it is.
 *
 * However, this time the co-ordinates are no longer relative to the screen,
 * but relative to the top left corner of the window,
 * and x and y positions indicate distance from left and from top respectively.
 */
(
  var w, slid;
  w = Window("My Window", Rect(100, 500, 200, 100));
  /* A 200 by 100 window appears at screen co-ordinates (100, 500)
   *
   * A basic slider object of size 180 by 40 appears
   * 10 pixels in from the left, and 10 pixels down from the top
   */
  slid = Slider(w, Rect(10, 10, 180, 40));

  /* This is the callback:
   * the function is called whenever you move the slider.
   * action_ means to set up the slider object
   * to use the function passed in as its argument.
   */
  slid.action_({
    slid.value.postln();
  });
  w.front();
)
// Note how the default slider range is from 0.0 to 1.0


/* We might not want to create numbers from 0.0 to 1.0,
 * but remap the value to other ranges.
 *
 * 0.0 to 1.0 is a very useful starting point, though. Try:
 */

// Create a random number from 0.0 to 1.0
1.0.rand();

// Create a random number from 0.0 to 1.0, and multiply it by 50 to get a new range from 0.0 to 50.0
1.0.rand() * 50;

// Create a random number from 0.0 to 1.0, multiply it by 50, then add 14.7, to get a new range from 14.7 to 64.7
1.0.rand() * 50 + 14.7;

// Create a random number from 0.0 to 1.0, and use a built in function to remap it to the output range 14.7 to 64.71
1.0.rand.linlin(0.0, 1.0, 14.7, 64.71);

/* Create a random number from 0.0 to 1.0,
 * and use a built in function to remap it to the output range 14.7 to 64.71
 * with an exponential function, which tends to spend longer over lower values
 */
1.0.rand.linexp(0.0, 1.0, 14.7, 64.71);


/* Rather than doing these remappings yourself,
 * an alternative is to take advantage of a ControlSpec,
 * a helpful class which can be used to turn input into
 * any desired range through various available precanned mappings
 */
(
  var w, slid, cs;
  w = Window("My Window", Rect(100, 500, 200, 100));

  // A 200 by 200 window appears at screen co-ordinates (100, 500)
  slid = Slider(w, Rect(10, 10, 180, 40));

  // Arguments minimum value, maximum value, warp (mapping function), stepsize, starting value
  cs = ControlSpec(20, 20000, \exponential, 10, 1000);
  slid.action_({
   // Map to the desired range
    cs.map(slid.value).postln();
  });
  w.front();
)

/* Given the action function for a GUI component,
 * we can plug through to sound synthesis.
 *
 * Here we use the set command to modulate the control arguments of a running synth.
 *
 * Demo of using 2D-Slider for synthesis:
 */
(
  // Make sure there are control arguments to affect!
  SynthDef(\filterme, {|freq=1000, rq=0.5|
    Out.ar(0, Pan2.ar(
      BPF.ar(Impulse.ar(LFNoise0.kr(15, 500, 1000), 0.1, WhiteNoise.ar(2)), freq, rq);
    ))
  }).add();
)

(
  var w, slid2d, syn;

  w = Window("My Window", Rect(100, 300, 200, 200));
  slid2d = Slider2D(w, Rect(5, 5, 175, 175));
  syn = Synth(\filterme);	// Create synth
  slid2d.action_({
    [slid2d.x, slid2d.y].postln();

    // I'm doing my own linear mapping here rather than use a ControlSpec
    syn.set(\freq, 100 + (10000 * slid2d.y), \rq, 0.01 + (0.09 * slid2d.x));
  });
  w.front();

	// Action which stops running synth when the window close button is pressed
  w.onClose = {
    syn.free();
  };
)

/* If you want to arrange a bank of dials,
 * for instance, you might use a helper
 * class (a 'decorator') for arranging views on screen:
 *
 * Note:
 * 10@10 is the Point (10,10), an (x,y) co-ordinate position
 */
(
  w = Window("decoration", Rect(200, 200, 400, 500));

  /* Set up decorator.
  * FlowLayout needs to know the size of the parent window,
  * the outer borders (10 pixels in on horizontal and vertical here)
  * and the standard gap to space GUI views (20 in x, 20 in y)
  */
  w.view.decorator = FlowLayout(w.view.bounds, 10@10, 20@20);

  /* Now, when GUI views are added to the main view,
   * they are automatically arranged,
   * and you only need to say how big each view is
   */
  k = Array.fill(10, {
    Knob(w.view, 100@100).background_(Color.rand);
  });

  w.front(); // Make GUI appear
)

/* They were stored in an array,
 * held in global variable k,
 * so we can access them all easily via one variable
 */
k[3].background_(Color.rand);


/* However, maximum precision will come from specifying positions yourself.
 * Make use of SuperCollider as a programming language to do this:
 */
(
  w = Window("Programming it directly ourselves", Rect(200, 200, 400, 400));

  /* Now, when GUI views are added to the main view,
   * they are automatically arranged, and you only need to say how big each view is
   */
  k = Array.fill(16, {|i|
    Knob(w, Rect((i % 4) * 100 + 10, i.div(4) * 100 + 10, 80, 80)).background_(Color.rand);
  });

  /* If worried by the use of % for modulo and .div for integer division, try the code in isolation:
   * i.e., try out 5%4, and 5.div(4) as opposed to 5/4. How does this give the different grid positions as
   * argument i goes from 0 to 15?
   */
  w.front(); // Make GUI appear
)



/* You can dynamically add and remove views from a window.
 * Run these one at a time:
 */
w = Window();
w.front(); // Window appears
Slider(w, Rect(10,10,100,100));	// Slider appears straight away

/* Slider should be in the list,
 * even though we didn't store any reference
 * to the slider object in a global variable (like w) ourselves
 */
w.view.children;
w.view.children[0].remove(); // Nothing happens visually immediately
w.refresh(); // Refresh updates the appearance of the window and the slider disappears

/* For further explorations:
 * For demos of Drag and Drop and other UI facilities see the examples/GUI examples folder
 *
 * http://composerprogrammer.com/teaching/supercollider/sctutorial/4.2%20Graphical%20User%20Interfaces.html
 */
