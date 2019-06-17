Server.local.boot;
Server.local.reboot;
Server.local.quit;
FreqScope.new();


/* Nodes
 * When creating Synths,
 * we have been accepting certain
 * defaults 'behind the scenes'.
 *
 * In particular, we have not worried about
 * the rendering order for the synthesis
 * (known as 'execution order').
 *
 * This can be controlled by specifying
 * Nodes on the Server, as I shall explain.
 */


/* The Server has a graph of all the running Synths,
 * which may be organised into Groups for convenience.
 *
 * You can see Synths and Groups being created just by looking at the Server graphics.
 *
 * A Node means a Synth or a Group.
 * Whenever you press command+period you reset the graph,
 * cleaning out all the Synths and Groups you added,
 * that is, clearing all Nodes.
 */
s.queryAllNodes(); // Run me to see the Nodes on the Server

/* There is also a keyboard shortcut of pressing 'N',
 * when the Server window is in focus
 */


/* When the Server determines the audio output,
 * it must run through all the Synths in the graph,
 * rendering them all.
 *
 * The order it does so is referred to as execution order.
 *
 * This can cause trouble if you're not careful with order!
 * Because the inputs of some Synths
 * depend on calculating some other Synth first:
 * imagine a reverb unit,
 * which has to follow some spawned sine wave grains.
 * If the reverb is calculated first, it has no current input to work on.
 */
(
  SynthDef(\reverb, {Out.ar(0, CombN.ar(In.ar(0, 2), 0.1, 0.1, 4))}).add();
  SynthDef(\impulses, {Out.ar(0, Impulse.ar([0.9, 1.19], 0, 0.3))}).add();
)

// Where is the reverb?
(
  Synth(\impulses);
  Synth(\reverb);
)


/* When you create Synths,
 * you may rely on defaults for the execution order.
 *
 * This is dangerous, as you'll discover when you find that
 * you aren't getting the sound you thought you should when
 * you combine say an effects unit and some other instrument,
 * and it is good practise to be explicit about the graph you create.
 *
 * This is a headache in some ways because it is extra effort for you;
 * the only consolation you can take is that SC3 is more efficient
 * because it doesn't have to worry about taking responsibility over execution order.
 */


/* What are the defaults?
 * The initial state of the Node graph on the Server looks like this
 * (do command + period first to destroy any existing nodes so you have the starting state):
 */
s.queryAllNodes(); // Run me to see the Nodes on the Server

/* The two default Nodes are convenient Groups for putting your Synths into.
 *
 * Group(0) is the absolute root of the tree.
 * All new Synths get placed within this Group somewhere
 * they might be in subGroups but they will be
 * within the RootNode Group at the top of the hierarchy.
 */
r = RootNode.new; // This gets a reference to Group(0)

/* Group(1) was added as an additional default
 * to receive all created Synths,
 * to avoid cluttering the base of the tree.
 */
Group.basicNew(s, 1); // This gets a reference to Group(1)



// If we get a new Synth running:
{SinOsc.ar(440, 0, 0.1)}.play();


/* If you now Query all Nodes you'll see the Synth was added to Group(1).
 *
 * Now run this as well:
 */
{SinOsc.ar(880, 0, 0.1)}.play();

/* Query all nodes again.
 * See how an execution order for rendering is building up.
 *
 * You might want to reset,
 * then try the earlier impulse and reverb example at this point,
 * to see what happens with their execution order.
 */


/* Now note we could have fixed the early example like this:
 *
 * with the reverb?
 */
(
  Synth(\reverb);
  Synth(\impulses);
)

/* That works because the defaults are on our side now.
 * Another fix would use the InFeedback UGen.
 *
 * InFeedback takes the old value from the bus
 * before this calculation cycle,
 * allowing you to set up feedback cycles,
 * and also circumvent execution order issues like this.
 */


/* But in more complex cases,
 * it is highly advised that you take responsibility
 * for the node graph on the Server, rather than accept defaults.
 *
 * In fact, always taking this responsibility
 * will mean you never get into trouble,
 * and is a good habit to fall into.
 *
 * You do this by specifying whenever you create
 * a Synth where to put it in the Node tree.
 *
 * You can put new Nodes after or before other Nodes,
 * and at the head or tail of Groups (lists of Synths)
 *
 * Controlled execution:
 */
(
  g = Group.basicNew(s, 1);
  Synth.tail(g, \reverb);
  Synth.head(g, \impulses);
)

/* Note it doesn't matter what order
 * the code runs in now since the placement is carefully controlled:
 *
 * Controlled execution:
 */
(
  g = Group.basicNew(s, 1);
  Synth.head(g, \impulses);
  Synth.tail(g, \reverb);
)

// Other ways we might do this:
(
  a = Synth(\impulses);
  Synth.after(a, \reverb);
)

(
  a = Synth(\reverb);
  Synth.before(a, \impulses);
)

/* You should have noted by now that all
 * Synths get a number (starting from 1000)
 * and all Groups get a number (starting from 0).
 *
 * The maximum number of Nodes you can have in your graph
 * is set in ServerOptions and defaults to 1024.
 */

/* Combining the use of Nodes with the use of Buses;
 * you use Nodes to control execution order,
 * and buses (via In and Out) to pass audio data between Synths,
 * so effects units can operate on a bus that
 * another synth has already written to,
 * and execution order will guarantee that this
 * will all be calculated in the right order.
 *
 * Have a look at the reverb and impulses SynthDefs above
 * again to see how this works in practice.
 */
