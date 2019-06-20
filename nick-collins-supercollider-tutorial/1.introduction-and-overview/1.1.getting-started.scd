Server.local.boot;
Server.local.reboot;
Server.local.quit;
FreqScope();
Server.local.scope();
s.queryAllNodes();

/* Essentials
 *
 * Welcome to SuperCollider!
 *
 * This is SuperCollider 3 (SC3), also occasionally called SC Server.
 * It is a powerful programming language for audio synthesis.
 *
 * Let's warn you up front of a few points. When learning this language, you will find:
 * 1) The stupid computer will only accept syntactically correct statements in this language.
 * 2) You need to become aware of standard mechanisms of computer languages, like iteration, conditional execution, messaging and containers.
 * 3) It's frustrating if you have a specific musical task in mind to have to deal with this computer language stuff
 * 4) There are a few different versions of SuperCollider around. 3.6 is a cross-platform version, but on a Mac 3.5 or earlier is a different environment.
 *
 * BUT the payoff is:
 * 1) You can explore musical tasks that standard software doesn't give you as an option
 * 2) You can learn the programming parts 'on the side' as you practise with the language, and I hope you'll hear inspiring outputs quickly in this course
 * 3) You are working with free software which is easily extendable
 *
 * You need to know three specific things before you dare to run any code:
 *
 * (Mac version: there are keyboard shortcut variations for Linux/Windows)
 * 1. You must select and evaluate code,
 * or at least put the cursor on a given line of code, for it to run.
 * Depending on your version of SuperCollider, the key command may vary.
 * For SC3.5 or earlier on Mac, use Enter, not Return.
 * Enter is at the base of the numeric keypad on some keyboards,
 * on the bottom row of some older laptop keyboards,
 * or obtain it with shift+return or ctrl+return. [windows- ctrl+return]
 * For SC3.6 or later and the sc-IDE, use shift + return or cmd + return.
 *
 * 2. Before doing any sound synthesis, make sure the synthesis server is on.
 * For SC3.5 or earlier, you should see some grey server boxes, with 'Boot' buttons.
 * Turn on the localhost server, by pressing 'Boot' on the grey localhost server graphic.
 * For SC3.6, select boot from the menu option under language, or cmd+B
 *
 * 3. To stop running sounds, use command+period (apple key and .) [win: alt+.]
 * Here are some warm up examples:
 */

/* Run me by the evaluate code key command with
 * the cursor anywhere on this line - a four should appear in the posting window
 */
2 + 2;

// Run me (Mac only, 3.5 or earlier)
"I am SuperCollider 3".speak();

// Similarly, concert A sine (works only if server booted)
{Pan2.ar(SinOsc.ar(440, 0, 0.1), 0.0)}.play();

/* One powerful feature of SuperCollider
 * is the ease with which you might bring in interaction:
 * here I substitute a Mouse controller for frequency rather than having a constant
 */
{Pan2.ar(SinOsc.ar(MouseX.kr(440, 880), 0, 0.1), 0.0)}.play();

/* Another traffic moment,
 * more involved example
 * (don't worry if you don't understand everything here yet!).
 *
 * Double click on the initial bracket to select this whole block of text,
 * which needs to be run at once.
 * You can't use evaluate on a single line
 * of this example since it's a program consisting of more than one line.
 */
(
  {
    // Try changing me to 34, or 3, and then re-running...
    var n = 11;
    Resonz.ar(
      Mix.fill(n, {
        var freq = rrand(50, 560.3);
        var numcps = rrand(2, 20);
        Pan2.ar(
          Gendy1.ar(
            6.rand,
            6.rand,
            1.0.rand,
            1.0.rand,
            freq ,
            freq,
            1.0.rand,
            1.0.rand,
            numcps,
            SinOsc.kr(exprand(0.02, 0.2), 0, numcps / 2, numcps / 2), 0.5 / (n.sqrt)),
            1.0.rand2
          );
      }),
      MouseX.kr(100, 2000),
      MouseY.kr(0.01, 1.0)
    );
  }.play()
)

/* SuperCollider is very powerful and much loved because
 * it is easy to do real time synthesis,
 * interaction and algorithmic composition, within one package.
 *
 * SC3 has the same operating freedom as Max/MSP or Pd,
 * but with the power of the SuperCollider language for UGen Graph generation
 * (connecting up a flow graph of sound generators and processors), and more besides.
 *
 * On the down side, the visual display of graphs is more limited or non-existent:
 * I hope you aren't surprised at this in a text based interface.
 *
 * I promise that you will grow to be familiar with this,
 * the structures existing in your mind, and if you're worried at any point,
 * try drawing out a diagram of what you're trying
 * to build on good old fashioned paper as an aide memoire.
 *
 * SuperCollider does have graphical user interface facilities though,
 * so we will see ways to create visuals later on.
 */

/* If you see this,
 * I hope you're already in the SuperCollider environment
 * (make sure it doesn't say TextEdit in the menu bar on OS X).
 *
 * We write code as text
 * (on the Mac stored as .rtf files before SC3.6, or sometimes .sc or .scd = plain text),
 * and when we instruct the code to run, SuperCollider compiles and executes it immediately.
 *
 * SuperCollider has similar control structures to programming languages you may already know,
 * like conditional execution and loops.
 * It is an object orientated language based on Smalltalk and C,
 * and has a very strong set of Collection classes like Arrays.
 *
 * In this course we shall try to get you to pick up the syntax as we go along,
 * and get on to making sounds as quickly as possible!
 */

// This is a comment
/* This is also a comment */
/* Comments are very useful to annotate programs
 * so they make sense to other people
 * or when you return to them yourself six months later on!
 */

/* To do audio synthesis,
 * we give SuperCollider a list of instructions for building a Synth,
 * that is, a valid network of Unit Generators, or UGens.
 */

/* This code plugs a sine oscillator into a panner;
 * don't worry, this will be further explained as we go along!
 */
{Pan2.ar(SinOsc.ar(440, 0, 0.1), 0.0)}.play();

/* A hint as to the plugging together: frequency 440  ->  SinOsc -> Pan2 -> output
 *
 * Plugging in SuperCollider appears through nesting brackets,
 * e.g. SinOsc.ar(440) means that the number 440
 * is plugged into the first input (first in the brackets) of the SinOsc
 *
 * If you run this code, note that the localhost GUI will show important runtime information
 * -- like CPU load and number of Synths playing/UGens used -- when synthesis is underway)
 */

// Double click on the inside of any bracket to highlight the code contained within
(
)

// Select this code within the outer parentheses
(
  // Then press the evalute key command
  {SinOsc.ar(440, 0, 0.1) + Pulse.ar(443, 0.6, 0.05)}.play();
)

// A selection is either a whole highlighted area, or the current line of the cursor.

// Types of Parentheses
( ) // Most often, for grouping expressions together
{ } // Function (package up some reusable functionality)
[ ] // Array (list of data)


/* SuperCollider code can get full of nested expressions:
 * you look at the selections within brackets to check on the scope
 * (level of nesting) of code fragments.
 * Try double clicking around any of the brackets in the following code:
 */
(
  if (4 == 4, {
    if (3 == 3, {
      "correct!".postln();
    });
  });
)


/* How do I find out about strange new code objects?
 *
 * Use Cmd+d on its own to bring up a general help window (F1 on Windows)
 *
 * or on selected text (that has an associated help file)
 */
LFSaw; // Select and use Cmd+d

// You can also use Cmd+j (3.5) or Cmd+i (3.6) to go to source code to find out more:
LFSaw; // Select and use Cmd+j (3.5 or earlier) Cmd+i (3.6)

// You will use this more later on, but start with reading help files.

/* All generated text will appear in the posting window.
 * On SC3.5 or earlier, you can bring the posting window to the front with cmd+\.
 * For 3.6, the post window is an explicit part of the environment,
 * usually docked on the left of the screen.
 *
 * You'll often see the postln and Post instructions,
 * which are useful for checking on the running state of variables and particularly debugging.
 */

// Run these lines of code with the cursor on each line
2.postln();
Post << [2, 3, 4, 5] << nl;

/* The reason you see more than one thing posted is that when you execute some code,
 * SuperCollider always posts the last object it dealt with.
 * This is the object '2' in the first example and the special 'Post' operator in the second.
 * If you run this:
 */
(
  var freq;
  freq = rrand(300, 600);
  {SinOsc.ar(freq, 0, 0.1)}.play();
)

/* You'll see something posted about a Synth
 * (the object that represents the sound synthesis asked for in the last line).
 * You'll get used to all this, don't worry!
 */

// What happens when it all goes wrong?

// This will crash:
{SinOsc.ar(nil)}.play()

// So will this:
Array.series(9, 0, 1) + nil;

/* A nil is like an empty object;
 * it represents missing information,
 * so no wonder it doesn't work in the expressions above!
 */

/* Don't be scared!
 *
 * You get a trace of the stack (execution order of functions in SuperCollider code).
 * You will learn to read this better in time.
 * For now, look to the top line in the crash report,
 * and you should see something a bit more human-readable.
 *
 * The crash backtrace is very helpful in telling you what caused the error.
 * Don't be intimidated by it: everyone's code crashes, especially when you're developing it.
 *
 * Occasionally, you may crash the entire program.
 * This happens most often when programming big loops,
 * where your instructions cause the computer to get locked in repetitions of some task.
 * There is no cure for this, and SuperCollider is not doing anything wrong:
 * it is faithfully following your instructions.
 * But if you did not anticipate the consequences of your program, such an error may occur.
 * This happens to everyone at some point,
 * we can't anticipate every aspect of every line of code we program!
 */

/* How do I start exploring?
 *
 * If you type Cmd+O you can open files.
 * SuperCollider comes with an examples folder,
 * plus lots of examples in particular help files.
 *
 * It is best probably to begin by running examples,
 * and perhaps tinkering with a few numbers in the patches.
 *
 * Listen to what happens to the sound.
 *
 * For some of you,
 * you'll be learning about sound synthesis and processing as you explore;
 * others will be familiar with the theory,
 * but it may take some time and effort to come
 * to grips with the way things are implemented in SuperCollider.
 *
 * If you have internet access, go to http://supercollider.sourceforge.net/,
 * from where you can get hold of various websites which have SuperCollider examples and extensions.
 *
 * Now run through this tutorial file again if you're unsure,
 * and start to try a few examples out.
 * There is also a 'getting around in SC3' file which summarises some useful shortcuts.
 * Also have a look under the application menus above.
 */

/* Virtually all code should run on any operating system.
 *
 * However, one area of difference is the GUIs.
 * Under the surface, things run differently, especially prior to SC3.6.
 * On SC3.6 there is unified Qt GUI system.
 *
 * MouseX and MouseY should now work on all platforms.
 * But for older SC versions, or just in case they don't work for you,
 * the Mouse UGens can be simulated via SwingOSC,
 * using a GUI mouse area for controlling patches:
 */

// Run me first, you only need to run this part once and can keep using the window which is created
JMouseBase.makeGUI();

// Then in any code with a MouseX or MouseY UGen, add a J in front, i.e.
{SinOsc.ar(JMouseX.kr(400, 800), 0, 0.1)}.play(); // Now move the mouse in the Java window you created

// Rather than
{SinOsc.ar(MouseX.kr(400, 800), 0, 0.1)}.play();
