Server.local.boot;
Server.local.reboot;
Server.local.quit;
FreqScope();
Server.local.scope();
s.queryAllNodes();


/* Strategies for Algorithmic Composition
 *
 * -- Any machinery from mathematics/computer science/artificial intelligence is potentially applicable
 * -- Critical issues of musical representation; how to model music on a computer?
 * -- Building the model led by musicological analysis and intuition, or by more automated statistical analysis of a corpus
 *
 * For discussion of different motivations
 * and methodologies for the modeling of composition by computer,
 * recommended you read:
 * Pearce, M., Meredith, D. and Wiggins, G. A.
 * (2002) Motivations and Methodologies for Automation of the Compositional Process.
 * Musicae Scientiae 6(2): 119-147
 */

// For examples
(
  SynthDef(\acsound, {|freq = 440, amp = 0.1, dur = 0.2, cutoff = 2000|
    var sound, filter;
    sound = Saw.ar(freq, amp) * EnvGen.kr(Env([0, 1, 1, 0], [0.01, 0.05, (dur.max(0.07)) - 0.06]), doneAction: 2);
    filter = LPF.ar(sound, Line.kr(cutoff, 300, dur));
    Out.ar(0, filter.dup(2));
  }).add();
)


/* Practical probability
 *
 * See the accompanying 'Probability distributions' tutorial
 * later for a more mathematical approach from first principles
 * (skip it if it worries you).
 * We'll use helper functions herein for now.
 *
 * Probability is one of the great tools for algorithmic composition work.
 * Rather than deterministic works, fixed given a starting state,
 * we can create probabilistic works, different with every run.
 *
 * Actually, in truth, the random number generation we'll use depends
 * on deterministic 'pseudo-random' functions in the background,
 * cued from some factor like the current system time,
 * but for our intents and purposes,
 * they give the statistically legitimatised variation we seek.
 *
 * A host of probabilistic functions are available in SuperCollider.
 * We'll try some practically useful ones for algorithmic composition now,
 * and also see the [Randomness] help file for some more hints,
 * both language functions and UGens.
 *
 * Probability theory allows selection from a space of options.
 * Different options can have different chances of being chosen on any given 'roll of the dice'.
 *
 * In the simplest form, choices amongst objects might be equally likely (equiprobable, uniform distribution):
 *
 * Try these:
 */
2.rand(); // Generates an integer, either 0 or 1
2.0.rand();	// From 0.0 up to 2.0
2.rand2()	// -2 to 2
2.0.rand2();	// -2.0 to 2.0
rrand(2, 4);	// Range from 2 to 4, so one of 2,3,4
rrand(2.0, 4.0);	// Floating point range
[3, 6, 8, 19].choose(); // Choose one option from the Array

/* All these functions are making selections
 * where the numbers in the range or options
 * in the Array have an equal chance of turning up.
 */


/* But the choices can also be weighted differently.
 *
 * We might weight lower numbers as more likely than high:
 *
 * Linear distribution; not the same as uniform!
 * Linearly decreasing weighting, so low numbers have more chance of turning up
 */
1.0.linrand();

/* See this visually by creating 1000 numbers using this generator,
 * sorting them in order, then plotting the results
 */
(
  Array.fill(1000, {
    linrand(1.0);
  }).sort.plot();
)

/* Similar, goes between positive and negative 1.0,
 * more weight towards 0 in all cases
 */
1.0.bilinrand();

// See this visually
(
  Array.fill(1000, {
    bilinrand(1.0);
  }).sort.plot();
)

/* Sum of 3 uniform random numbers
 * between plus and minus 1.0
 * will come out with more chance of numbers nearer 0,
 * since values can cancel between positive and negative;
 * in general, a sum of distributions tends
 * to a centre-weighted normal distribution
 */
1.0.sum3rand();

// See this visually
(
  Array.fill(1000, {
    sum3rand(1.0);
  }).sort.plot();
)

/* Show similarity
 *
 * See this visually by creating 1000 numbers using this generator,
 * sorting them in order, then
 */
(
  Array.fill(1000, {
    ({1.0.rand2}!3).sum * 0.33;
  }).sort.plot();
)

/* Uniform choice,
 * but over an exponentially mapped range,
 * more likely to choose low
 */
exprand(1.0, 10.0);

/* Famous bell-shaped Gaussian, normal distribution;
 * has two parameters, mean and standard deviation.
 * Most output values are within three standard deviations each side of the mean
 */
gauss(0.0, 1.0);

// See this visually
(
  Array.fill(1000, {
    gauss(0.0,1.0);
  }).sort.plot();
)

// Mean 1.0, most output values within 0.3 (3*0.1) either side, so 0.7 to 1.3
gauss(1.0, 0.1);


/* Most often, you use arbitrary weights amongst a discrete set of options.
 * Think of choosing amongst a set of possible MIDI notes, or dynamic levels, or durations.
 *
 * The first array is the array of options;
 * the second is the array of weights
 */
[60, 62, 64, 67].wchoose([0.5, 0.25, 0.2, 0.05]);

// See this visually
(
  Array.fill(1000, {
    [60, 62, 64, 67].wchoose([0.5, 0.25, 0.2, 0.05]) ;
  }).sort.plot(minval: 50, maxval: 72);
)

/* When you use wchoose,
 * the array of weights has to add up to 1.0
 * (a standard feature of a probability distribution).
 * There is a helper function for this:
 *
 * Make array add up to 1.0 by dividing by the sum of the entries
 */
[14, 3.7, 5.6, 8, 11].normalizeSum();

/* Finally, for rolls of the dice in decision making,
 * the coin function is very useful:
 */
0.5.coin(); // Fair coin, equal chance of heads or tails: true or false as output
0.2.coin(); // Unfair coin, 20% chance true
0.95.coin(); // Unfair coin, 95% chance true

/* You can achieve a lot just with controlled
 * use of probability distributions in this way.
 *
 * You may also want to explore using different
 * probability distributions at different points in time during a piece,
 * perhaps by varying parameters in gauss, changing the weights for wchoose,
 * or moving between entirely different functions.
 *
 * You can remap the values to different ranges at different points in time,
 * or restrict which parts of a distribution you select from.
 *
 * We've seen similar ideas before in terms of time varying availability;
 * e.g. 'tendency masks' in granular synthesis
 * for allowed parameter ranges at different points in time.
 */

/* Use of conditionals
 *
 * Algorithmic music exploits the fundamental building blocks of computer algorithms.
 * Conditional execution empowers computerised decision making;
 * based on the current state,
 * you can choose the next action in either a rigid deterministic way,
 * or with (psuedo-)probabilistic choice.
 */

/* Examples:
 *
 * Deterministic:
 */
(
  var pitch = 60, amp = 1.0;
  if (pitch == 60, {amp = 0.2});
  amp;
)

// Probabilistic
(
  var pitch = 60, amp = 1.0;

  // Amp gets set to 0.5 on average half the time
  if (pitch == 60 and: 0.5.coin(), {amp = 0.2});

  amp;
)

/* In music, different states might correspond to:
 *
 * -- different parameter settings for musical attributes (as above)
 * -- different playing modes ('mellow', 'aggressive', etc.)
 * -- different models of harmony, tonality, melody...
 * -- etc
 *
 * One interesting analogy is the idea of a finite state machine
 * as a model of computation: the computer has a set of program states it can be in,
 * and at each step can transition to a variety of other states
 * (including staying where it is).
 *
 * It is for you to build the model of music;
 * there are as many music theories as you want to explore.
 *
 * Of course, not all correspond well to existing 'styles' or 'genres',
 * and there is much scope for experiment.
 */


/* Conditional probability
 *
 * If some event is known to have happened,
 * this gives information about the situation
 * which restricts what else may happen alongside it.
 * Such reductions from a full choice within probability space
 * to a more restricted area is the domain of conditional probability.
 *
 * P (B | A) = P (A and B) / P (A)
 * where P (B | A) means the probability of B given that A is known to have happened.
 *
 * If A is observed, to find P (B | A), look at the probability
 * that both A and B can happen
 * (the intersection of the areas of the probability space represented by A and B)
 * relative to the probability of A happening in the first place.
 *
 * Sidenote: Bayes theorem follows from the above, as P(B | A)= P(A | B) P(B)/P(A).
 * Bayes theorem is useful for calculating one conditional probability in terms of another,
 * ie A might be some observations and B a world state;
 *
 * Bayes theorem lets us calculate the most likely world state,
 * by looking at how each potential world state explains the observations
 *
 * We can also think about this in terms of an event observed
 * a moment ago further constraining what could happen next:
 * P (B occurs at time n | A occurs at time n-1) = P (A at time n-1 and B at time n) / P (A occurs at time n-1)
 *
 * In general, decisions can take account of not only the current situation,
 * but the history of past states.
 * We move away from '0th-order' systems
 * where each choice is entirely independent of anything else that has happened.
 */


/* Markovian systems
 *
 * The idea of the current choice being dependent
 * on past choices is encapsulated in a Markov system of order n,
 * where n is the number of previous choices at stake.
 *
 * Simple Markov processes need to keep track of a larger and larger
 * number of possibilities in a combinatorial explosion.
 *
 * Say there are 3 options at a given time, say, three notes to choose from:
 */
[\a, \b, \c].choose();	// 0th order system, uniform selection

// Now say that the choice depends on the choice just made, a 1st order system:
[\a, \b, \c].wchoose([0.7, 0.2, 0.1]); // If previously choose \a
[\a, \b, \c].wchoose([0.0, 0.5, 0.5]); // If previously choose \b
[\a, \b, \c].wchoose([0.1, 0.4, 0.5]); // If previously choose \c

/* Then in general there are 3 * 3 = 9 probabilities to specify.
 * For each increase in order, we'd gain another multiple of 3,
 * so a second order Markov system requires 3 * 3 * 3 probabilities to be set up,
 * and an Nth order needs 3 ** (N + 1)
 *
 * Higher order Markovian systems require exponentially
 * bigger multi-dimensional matrices of probabilities.
 *
 * 1st order Markov system example:
 */
(
  var markovmatrix;
  var currentstate = 3.rand(); // Start in one of three states
  markovmatrix = [
    [0.7, 0.2, 0.1],
    [0.0, 0.5, 0.5],
    [0.3, 0.4, 0.3]
  ];

  {
    20.do {
      Synth(\acsound, [\freq, [48, 60, 64].at(currentstate).midicps]);

      // Which probability distribution to use depends on what state we're in right now
      currentstate = [0, 1, 2].wchoose(markovmatrix[currentstate]);
      0.25.wait();
    };
  }.fork();
)

/* For fixed and variable order Markovian modeling see also
 * the MathLib and ContextSnake Quarks.
 */


/* Search
 *
 * Search is a fundamental operation in computer algorithms.
 * Musical parameterisations lead to combinatorially explosive search spaces,
 * and issues of computational tractability.
 *
 * Heuristics are rules of thumb to cut down the amount of brute search by pruning the search tree.
 *
 * Charles Ames differentiates:
 *
 * Comparative search:
 * an exhaustive search through all options.
 * Can find an optimal solution, but usually too computationally intensive
 *
 * Constrained search:
 * finds a `good' solution by approximate methods, i.e., heuristics.
 *
 * An early strategy (used back in 1955 by Hiller and Isaacson's) was generate and test.
 * Random numbers are generated until they pass a test.
 * The passed number becomes the latest choice, and a new selection is then made.
 * Alternatively, we might restrict generations
 * to only acceptable options in the first place (by heuristics).
 *
 * More complicated strategies include back tracking
 * (jumping back to an earlier decision point when a path has led to an impasse)
 * and dynamic programming (greedy selection of the best option according
 * to a cost function at any point, to comparison of multiple paths
 * taking into account all steps but keeping down the proliferation
 * of possible paths by only following best scoring paths to any given branching point).
 *
 * You should see that any machinery from AI
 * (whether GOFAI symbolic or connectionist) may be imported to problems of musical search.
 *
 * Generate and test:
 */
(
  var currentvalue = rrand(60, 72);
  var generateandtest;

  generateandtest = {|previous=60|
    var number = rrand(24, 127);
    var keeplooking;

    // Keep searching until a number passes the tests
    while {
      keeplooking = false; // Can only fail

      /* Note we could replace this test with
       * just generating number in the allowable range to start with
       */
      if (abs(number - previous) > 12) {
        keeplooking= true;
      };

      // Avoid certain intervals
      if (#[-5, -3, 4, 7, 11].includes(number - previous)) {
        keeplooking= true;
      };

      ((number.asString()) ++ (if (keeplooking, " rejected", "accepted"))).postln();

      keeplooking;
    }, {
      /* No need to do anything here,
       * all done in while test function
       */
      number = rrand(24, 127);
    };

    number;
  };

  {
    20.do {
        currentvalue = generateandtest.(currentvalue);
        Synth(\acsound, [\freq, currentvalue.midicps]);
        0.25.wait();
    };
  }.fork();
)


/* Sonification of mathematics
 *
 * Given the wonderful resources of mathematics,
 * it's very tempting to translate mathematical structures into musical output.
 *
 * But be warned that the transformation does not often make perceptual sense,
 * and can be very contrived.
 *
 * On the other hand,
 * it may lead you to stimulating output you wouldn't otherwise have conceived.
 *
 * Logistic map function used to generate pitch values:
 */
(
  var currentvalue = 1.0.rand();
  var logisticmap, r;
  r = 3.74;
  logisticmap = {|previous = 60|
    ((1.0 - previous) * previous * r).postln();
  };

  {
    50.do{
      currentvalue = logisticmap.(currentvalue);
      /* Must convert from the value
      * in the range 0.0 to 1.0 to a musically useful pitch value
      *
      * Quartertones here
      */
      Synth(\acsound, [\freq, (60 + ((currentvalue * 12).round(0.5))).midicps]);
      0.125.wait();
    };
  }.fork();
)

/* The example here demonstrates how the logistic map acts
 * as a generator of values at the required rate for musical events set required,
 * much as a UGen is a (usually much faster running) generator of sample values at audio rate.
 *
 * Analogous networks of number generation and modification (synthesis and processing)
 * can be formed in algorithmic composition
 * to determine musical parameter values for event streams.
 *
 * We'll continue this next year in advanced computer music
 * by discussing mappings and musical modeling in general.
 *
 * For example, we haven't touched here on data-driven modeling
 * where a corpus is automatically analyzed to create a generative model.
 *
 * You may still approach such things intuitively,
 * by formulating rules via your own personal analyses of musical style.
 */
