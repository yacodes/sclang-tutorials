Server.local.boot;
Server.local.reboot;
Server.local.quit;
FreqScope();
Server.local.scope();
s.queryAllNodes();

/* Open Sound Control (OSC)
 *
 * OSC is a communication protocol used for sending information across a computer network.
 * It is promoted as the successor to MIDI
 * (with greatly increased bandwidth and user-customisable representations),
 * and is supported by most modern music software.
 *
 * It is the lifeblood of SuperCollider since all communication
 * from the language application to the localhost server uses OSC!
 *
 * You may also send messages to any other SuperCollider Servers
 * for which you have an IP location. So SuperCollider is immediately equiped for network music.
 *
 * You can also use it to communicate with other applications like Max/MSP or Pd.
 */

/* For OSC, you create your own OSC Address Space,
 * a tree of methods that get called when their corresponding string is invoked.
 * In practice, this means you can choose how to tag the messages you pass.
 *
 * (see http://www.cnmat.berkeley.edu/OpenSoundControl/OSC-spec.html for more)
 *
 * You might use "/myparameters/object3/frequency"
 * Or any other string, where the forward slashes / split up the tree to be traversed.
 *
 * OSC messages themselves are denoted by an address string,
 * a typetag string that says whether the information passed is a float,
 * two integers etc and actual values for each type in the type string:
 * address, typetags, values
 *
 * The message is passed to the appropriate method as soon as it arrives.
 * A 'bundle' can also be sent,
 * which is a set of OSC commands that are to be called simultaneously
 * an absolute time tag is also enclosed, to control exactly when the commands are carried out.
 */

// To send general OSC to a known IP use the NetAddr class:
[NetAddr];

// Demo to send to the localhost Server
(
  var n, id;
  // Loopback address is 127.0.0.1 try substituting the IP address of another user's machine
  n = NetAddr("127.0.0.1", 57110); // 57110 is the port number; this is the standard number used by the Server
  id = s.nextNodeID;
  n.sendMsg("s_new", \default, id, 0, 0); // sendMsg works out the correct OSC message for you
  SystemClock.sched(1.0, {
    n.sendMsg("n_free", id);
  });
)

/* To send standard messages to control a SuperCollider server,
* the Server class is a better interface.
* Underneath, it uses NetAddr as above.
*/
[Server];

/* To receive and react to OSC messages in SCLang
 * you will use the OSCFunc or OSCdef classes
 * (used since SC 3.5. For SC3.4 or earlier see OSCresponder and OSCresponderNode,
 * tutorial reproduced lower down this file)
 */
(
  // Register to receive a trigger message
  o = OSCFunc({|msg, time, address, receivedPort|
    "received trigger!".postln();
    Post << msg << nl;
  }, // Function

  // OSC message address name,
  '/tr',

  /* NetAddr (where the message will arrive from).
   * Leave this nil if you want to allow it to come from anywhere
   * (for example, if another application is sending from a variable or unknown port)
   */
  s.addr
  );

  // Send a trigger message whenever the impulse fires (once every 2 seconds)
  {SendTrig.ar(Impulse.ar(0.5))}.play();
)

// Keep it running and now run these lines:
(
  p = OSCFunc({|time, responder, msg|
    "new reaction!".postln();
    Post << time << nl;
  }, '/tr', s.addr);
)

// Remove the OSCFunc instances
o.free();
p.free();

/* OSCFunc instances are freed if you press cmd+period
 * (SC 3.4: note that this is different to the old behaviour with OSCresponder for SC 3.4 and earlier.)
 */

// They can be re-enabled:
p.enable();

// And they can be made permanent to avoid them being affected by cmd+period:
p.permanent_(true); // You can also do this when first creating one

/* You can add as many different functions
 * to one OSCFunc instance as you like (internally it holds a 'FunctionList').
 */
f = {"whatever".postln();};
p.add(f);
p.remove(f)
p.add({"whatever".postln();}) // Add some function, don't keep any reference to it
p.clear(); // Remove all functions from the OSCFunc's list

/* OSCdefs are used in a similar way to OSCFunc,
 * but you can 'name' the specific instance, e.g.
 */
OSCdef(\namedOSCdef, {"new reaction!".postln;}, '/tr', s.addr);
OSCdef(\namedOSCdef).disable;

// It's helpful sometimes to be able to see all incoming OSC traffic:
OSCFunc.trace(true); // Turn posting on
OSCFunc.trace(false); // Turn posting off

// You might also like to read the [OSC Communication] help file to accompany this explanation.

/* For SC3.4 and earlier,
 * old style use of OSCresponder (also supported in 3.5 or later for backwards compatibility)
 *
 * To receive and react to OSC messages in SCLang you will use the OSCresponder class
 */
[OSCresponder];

(
  // Register to receive a trigger message
  OSCresponder(s.addr, '/tr', {|time, responder, msg|
    "received trigger!".postln();
    Post << msg << nl;
  }).add();

  // Send a trigger message whenever the impulse fires (once every 2 seconds)
  {SendTrig.ar(Impulse.ar(0.5))}.play();
)

// Keep it running and now run these lines:
(
  OSCresponder(s.addr, '/tr', {|time, responder, msg|
  "new reaction!".postln();
  Post << time << nl;
  }).add();
)

// Remove the responder
OSCresponder.all.do({|val| if (val.cmdName == '/tr', {OSCresponder.remove(val)});});

// OSCresponderNode can be used if you need more than one responder for a particular message.
[OSCresponderNode];

(
  // Register to receive a trigger message
  OSCresponderNode(s.addr, '/tr', {|time, responder, msg|
    "received trigger!".postln();
    Post << msg << nl;
  }).add();

  OSCresponderNode(s.addr, '/tr', {|time, responder, msg|
    "different reaction!".postln();
    Post << time << nl;
  }).add();

  // Send a trigger message whenever the impulse fires (once every 2 seconds)
  {SendTrig.ar(Impulse.ar(0.5))}.play();
)

// Clear all OSCresponderNodes for the trigger message
OSCresponder.all.do({|val| if (val.cmdName == '/tr', {OSCresponder.remove(val)});});

/* This would have been easier
 * if we'd set each created OSCresponderNode into a variable x say,
 * then we could go:
 */
x = OSCresponderNode(s.addr, '/tr', {|time, responder, msg| "bang!".postln();}).add();

// then
x.remove();
