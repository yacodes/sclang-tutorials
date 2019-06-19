Server.local.boot;
Server.local.reboot;
Server.local.quit;
FreqScope();
Server.local.scope();
s.queryAllNodes();


/* Probability distributions
 *
 * A probability distribution gives a relative weight
 * to each available option in the space of possible outcomes;
 * this is the probability density function (pdf).
 *
 * For a discrete set of possible outcomes,
 * there is an explicit probability mass for each;
 * for a continuous set (e.g., any number from the range 0.0 to 1.0)
 * a mass can be associated with any interval.
 *
 * The sum of the probability density is normalized to 1.
 *
 *
 * From a probability density function we can create
 * a cumulative distribution function (cdf) which allows us
 * to calculate which output we get on a particular occasion
 * (particular roll of the dice).
 */

// Helper functions for investigating pdfs and cdfs
(
  // Normalize total sum of an array to 1.0
  ~normalize = {|array| array / (array.sum)}; // Note, not safe if array is empty or otherwise sums to zero

  /* Could also use normalizeSum, just showing this explicitly
   * Create array of cumulative values,
   * assuming input is normalized (sums to 1.0)
   */
  ~cumulative = {|array|
    var num = array.size;
    var accumulate = 0.0;
    var cumul;
    cumul = array.collect{|val, i| var old = accumulate; accumulate = accumulate + val; old};
    cumul;
  };

  /* Use cumulative distribution to find an output value for an input
   * assumes array is a cumulative distribution function, and array size is at least 1
   */
  ~draw= {|input, array|
    var nextindex;
    nextindex = array.indexOfGreaterThan(input); // Also see indexInBetween if want linearly interpolated index

    // Get nil if input greater than anything in array
    if (nextindex.isNil, {nextindex = array.size;});

    // Get index before; we 'went past' and have to go one back to find the slot our input falls in
    nextindex = nextindex - 1;

    // Nextindex should never be less than 0
    nextindex / (array.size); // Get position proportional within array length
  }
)


// Plotting approximations to different probability distributions:

// 1. Uniform distribution, equal chance for any equal subsection of the range:
p = ~normalize.value(Array.fill(1000, 1.0));
p.plot(minval: 0.0, maxval: 2.0 / 1000); // pdf

c = ~cumulative.value(p);
c.plot(); // cdf


/* Choose values; driven by uniform random number,
 * could also just provide increasing uniform numbers
 * from 0.0 to 1.0 (and then wouldn't need the sort)
 */
Array.fill(1000, {~draw.value(1.0.rand, c)}).sort.plot();

/* We do this a thousand times to simulate 'rolling the dice' many times;
 * the distribution only really shows itself over many trials
 * (and can do it more times for better approximations)
 */
Array.fill(1000, {1.0.rand()}).sort.plot(); // Create values directly



// 2. Linear distribution, probability density drops linearly, so more likely to get lower values:
p = ~normalize.value(Array.fill(1000, {|i| 1000 - i}));
p.plot(); // pdf
c = ~cumulative.value(p);
c.plot();	// cdf
Array.fill(1000, {~draw.value(1.0.rand(), c)}).sort.plot(); // Choose values
Array.fill(1000, {1.0.linrand()}).sort.plot(); // Create values directly


/* 3. Negative exponential distribution, probability density drops exponentially,
 * so much more likely to get lower values:
 */

// There is a parameter here for the rate of fall off of the distribution
~alpha = 10.0;
p = ~normalize.value(Array.fill(1000, {|i| exp((i.neg / 1000) * ~alpha)}));
p.plot(); // pdf
c = ~cumulative.value(p);
c.plot();	// cdf
Array.fill(1000, {~draw.value(1.0.rand, c)}).sort.plot(); // Choose values

/* Go back and try ~alpha= 100.0;
 * note the quantisation caused by only working with arrays
 * of limited size as we create a discrete approximation
 * to the ideal continuous distribution
 */



// 4. Normal distribution (Gaussian)
/* Two parameters, mean ('centre') and standard deviation ('spread');
 * here we take sensible values to plot the distribution easily
 */
~mu = 0.5; // Mean

/* Standard deviation;
 * most of probability mass within 3 standard deviations,
 * so this makes the Gaussian fit the 0.0 to 1.0 range easily for our plotting;
 * try changing these parameters later to see the effect.
 */
~sigma =  0.17;

/* Normalization constant calculated automatically,
 * though there is a mathematical expression for it
 */
p = ~normalize.value(Array.fill(1000, {|i| exp((((i / 1000) - ~mu) / ~sigma).squared.neg)}));
p.plot(); // pdf
c = ~cumulative.value(p);
c.plot();	// cdf
Array.fill(1000, {~draw.value(1.0.rand, c)}).sort.plot(); // Choose values
Array.fill(1000, {0.5.gauss(0.17).max(0.0).min(1.0)}).sort.plot(); // Create values directly, clamping within +-3 standard deviations


// 5. Arbitrary distribution

// Let's make up our own function
p = ~normalize.value(Array.fill(1000, {|i| var prop = (i / 1000.0); if (prop < 0.2, {(0.2 - prop) ** (0.3)}, {(prop - 0.2) ** 2})}));
p.plot(); // pdf
c = ~cumulative.value(p);
c.plot();	// cdf
Array.fill(1000, {~draw.value(1.0.rand, c)}).sort.plot(); // Choose values

/* Example in use;
 * 20 notes drawn using the custom distribution
 * (0.0 to 1.0 range output rescaled to MIDI notes 48 to 72)
 */
(
	{
		20.do {
			Synth(\acsound, [\freq, 48 + (24 * ~draw.value(1.0.rand, c))]);
			// Could quantise the notes to discrete pitches, e.g., with .round(1.0)
			0.25.wait();
		}
	}.fork();
)


/* There are many other interesting distributions you might investigate, see for example:
 *
 * Charles Ames.
 * A catalog of statistical distributions:
 * Techniques for transforming random, determinate and chaotic sequences.
 * Leonardo Music Journal, 1(1):55–70, 1991.
 *
 * Denis Lorrain.
 * A panoply of stochastic 'cannons'.
 * Computer Music Journal, 41(1):53–81, 1980.
 *
 * In practice, we often work with a relatively small discrete set of options.
 * It is easy to create a custom probability distribution over a set:
 */
[0, 1, 2, 3, 4, 5].wchoose([0.2, 0.3, 0.1, 0.1, 0.05, 0.25]); // Make sure weights add to 1.0, or use normalizeSum

// Examination using our machinery for pdf, cdf, and draws:
p = ~normalize.value([0.2, 0.3, 0.1, 0.1, 0.05, 0.25]);
p.plot(); // pdf
c = ~cumulative.value(p);
c.plot();	// cdf
Array.fill(1000, {~draw.value(1.0.rand, c) * 6}).sort.plot() // Choose values; multiply by 6 to get back integer indices
