Server.local.reboot;
Server.local.quit;
(
  Server.local.boot;
  FreqScope;
  Server.local.scope;
  Server.local.plotTree;
)
s.queryAllNodes();


/* Getting around in SC3
 *
 * Getting help
 *
 * cmd+d (F1 on Windows)
 *
 * If you just press help this brings up the main help menu.
 * If you have selected some text you may be able to get help on that specific thing,
 * but the help pages only exist for certain items.
 * These are usually things with capital letters in front, like:
 */
SinOsc;	// Try double clicking on SinOsc then pressing cmd+d

/* Searching for stuff
 *
 * Use your system text file search tools such as Spotlight.
 * (OS X) using Find in the OS X Finder- use cmd+F to bring up the search
 *
 * unix Commands can also be used within SC3 using the unixCmd method for String
 */
"ls -l".unixCmd(); // Run this line
"grep -r 'TempoClock.default' SCClassLibrary/*".unixCmd();

/* (OS X) You can use a Terminal window to do this directly from the command line.
 * You find the Terminal under Utilities in the Applications folder on your OS X drive.
 *
 * -----------------------------------------------------------------------
 * Advanced getting the result of unix commands back to SuperCollider:
 */
(
  d = "";
  p = Pipe.new("ls -l", "r");
  l = p.getLine;
  while({l.notNil}, {d = d ++ l ++ "\n"; l = p.getLine;});
  p.close();
)
Post << d << nl;
d[0..20];


/* Looking at source code
 * to see class definitions
 */
Object; // Highlight Object and then press cmd+J (3.6: cmd+I)

// To see which classes respond to a particular method
rand; // Highlight 'rand' and then press cmd+Y (3.6: press cmd+I as above)

// To find cases in the class library where that method is called
rand; // Highlight 'rand' and press shift+cmd+Y (3.6: press cmd+U)

// to find out class hierarchies- what derives from this?
Clock.dumpClassSubtree;	// Run this by pressing enter with cursor on the line

// to see the interface (methods of a class)
Array.dumpInterface;	// See instance methods
Meta_Array.dumpInterface;	// See class methods

// Does it have a help file or not?
Array.hasHelpFile;

// You can also bring up a browser GUI for classes by sending the class name the 'browse' message
Array.browse;


/* Getting out of trouble
 *
 * If you accidentally close a Server window for SC3.5 or earlier:
 */
Server.local.makeWindow; // See Main.startup
Server.internal.makeWindow; // See Main.startup

/* On 3.6, the server status is fully integrated into the IDE
 *
 * If things can't be stopped!
 *
 * first: Cmd+period (.)
 * second: quit the Server
 * third: Recompile the library cmd+K (3.6: cmd+shift+L)
 *
 * Occasionally a Server/Lang crash might force you to kill the applications from the system.
 * 3.5 and earlier, the server graphic has a 'K' next to the boot button,
 * which will attempt to kill all scsynths.
 *
 * On the command line (via Terminal) you use
 * ps -aux or top
 *
 * To see what processes are running and their numerical IDs then
 *
 * kill (processnumber)
 *
 * To stop them. If on boot SC3 can't set up an OSC connection,
 * there may be an old Server instance running
 * which you have to go in an kill explicitly via the command line.
 *
 * (OS X) You can do the same kill operations from the graphical ActivityMonitor program,
 * or via the Force Quit option from the Dock, or via cmd+alt+esc.
 * There is also a K button (for kill all server instances) on the standard server window.
 *
 * Managing SC SynthDefs (this won't be an issue until you get more experienced)
 *
 * To purge your synthdef files:
 * SC3.5 or earlier:
 */
"rm synthdefs/*.scsyndef".unixCmd();

/* SC3.6 has a different structuring to the file system.
 * You can open package contents (right click option)
 * on the SuperCollider app in the finder, to go explore.
 *
 * It may be best to just go in via the Finder to browse selectively through synthdefs...
 */
