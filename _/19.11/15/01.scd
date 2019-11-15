(
  s.boot;
  FreqScope.new;
  s.meter;
)

{LocalOut.ar(a=CombN.ar(BPF.ar(LocalIn.ar(2)*7.5+Saw.ar([32,33],0.2),2**LFNoise0.kr(4/3,4)*300,0.1).distort,2,2,40));a}.play
s.freeAll

(
  {
    var source, local;

    source = Decay.ar(Impulse.ar(0.3), 0.1) * WhiteNoise.ar(0.2);
    local = LocalIn.ar(2) + [source, 0]; // read feedback, add to source
    local = DelayN.ar(local, 0.2, 0.2); // delay sound

    // reverse channels to give ping pong effect, apply decay factor
    LocalOut.ar(local.reverse * 0.8);

    local
  }.play;
)
s.freeAll

// https://ccrma.stanford.edu/wiki/SuperCollider_Tweets
{BPF.ar(WhiteNoise.ar(1), 1000, 0.01)}.play
s.freeAll;

// ********************************************************
// FIRST PART: INSIDE THE BPF
// ********************************************************

// Starting from the BPF, a bandpass filter.
// Below is a simple BPF filtering white noise.
// BPF.ar(in, freq, rq) --> input, center frequency, rq
// This example uses a fixed center frequency of 1000 Hz and a rq of 0.1:
{BPF.ar(WhiteNoise.ar(1), 1000, 0.01)}.play
s.freeAll

// Now instead of a fixed center frequency, let's use a
// LFNoise0 to generate new center frequencies for the BPF.
// The LFNoise0 will output a new value between 500 and 5000
// twice per second in this example:
{BPF.ar(WhiteNoise.ar(1), LFNoise0.kr(2).range(500, 5000), 0.1)}.play

// Same thing as above, but now using 'poll' so we
// can see the new freqs values being generated:
{BPF.ar(WhiteNoise.ar(1), LFNoise0.kr(2).range(500, 5000).poll(2, label: "bpf-freq"), 0.1)}.play

// Same thing but now using single impulses (Impulse.ar)
// as the input of the BPF, instead of WhiteNoise. We use the *5
// at the end just to make it louder (too soft otherwise). Listen:
{BPF.ar(Impulse.ar(2), LFNoise0.kr(2).range(500, 5000).poll(2, label: "bpf-freq"), 0.1)*5}.play // filtered impulses

// Now let's step back for a moment. Compare the sound
// of a single impulse to that of a slow sawtooth wave:
{Impulse.ar(1)}.play    // hear it
s.freeAll
{Impulse.ar(1000)}.plot // see it
{Saw.ar(1)}.play        // hear it (you hear the dip of the sawtooth from +1 to -1)
{Saw.ar(1000)}.plot   // see it

// Let's use a 1 Hz sawtooth wave as the sound input for the BPF filter.
// These filtered 'saw pops' have a very different timbre from
// the filtered impulse pops created earlier with Impulse.ar:
{BPF.ar(Saw.ar(4), LFNoise0.kr(4).range(500, 5000).poll(4, label: "bpf-freq"), 0.1)}.play // "saw pops" BPF
// compare to
{BPF.ar(Impulse.ar(4), LFNoise0.kr(4).range(500, 5000).poll(4, label: "bpf-freq"), 0.1)*5}.play // "impulse pops" BPF
s.freeAll

// Getting a bit closer to the original tweet...
// Let's have get the Saw.ar at 32 and 33 Hz:
{Saw.ar(33)}.play // the raw saw, mono [CAREFUL: LOUD!]
{BPF.ar(Saw.ar(33), LFNoise0.kr(2).range(500, 5000).poll(2, label: "bpf-freq"), 0.1)}.play // raw saw thru BPF
{Saw.ar([32, 33])}.play // two raw saws, stereo [CAREFUL: LOUD!]
{BPF.ar(Saw.ar([32, 33]), LFNoise0.kr(2).range(500, 5000).poll(2, label: "bpf-freq"), 0.1)}.play // raw saws thru BPF

// Now let's say we want the BPF frequencies to be
// in the range 18.75 Hz to 4800 Hz, which is the
// range of the original tweet (more on that later):
{BPF.ar(Saw.ar([32, 33]), LFNoise0.kr(2).range(18.75, 4800).poll(2, label: "bpf-freq"), 0.1)}.play
s.freeAll

// Note that whenever the output of LFNoise0 produces a big leap from a very low to a
// very high number (center frequency for BPF), there's a loud "pop" as a consequence.
// These are the interesting "accented notes" we often hear in the final result.
// Watch the Post window as you listen, and check when the louder pops happen.

// One more step closer to the original tweet:
// Let's make the LFNoise0 freq to be 4/3, that is,
// 4 new values every 3 seconds (note that we change
// the poll frequency accordingly):
{BPF.ar(Saw.ar([32, 33]), LFNoise0.kr(4/3).range(18.75, 4800).poll(4/3, label: "bpf-freq"), 0.1)}.play
s.freeAll

/* What does this mean? If you think of this rhythm in a Tempo of quarter note = 60,
which will be the case in the final result, you have something like this
(imagine these are representations of 16th notes):

>  >   >   >
|||| |||| ||||

In other words: the frequency of change of the BPF center-freqs (4/3 Hz)
actually promotes a certain "syncopated" feel of the final result, especially
when the louder pops appear (created by the occasional sudden change from a very low
  to a very high BPF center-freq)
  */

  // Now take a look at how the scaling of the output of LFNoise0
  // is actually accomplished in the original tweet. The author does
  // NOT use .range(18.75, 4800). Instead we see this:

  2**LFNoise0.kr(4/3,4)*300 // output range is 18.75 to 4800 Hz

  // With 4 as the "mul", the range of this LFNoise0 becomes -4 to + 4.
  // "2 to the power of (-4 up to + 4), and this result multiplied by 300"

  2**(-4)*300 // Evaluate this: if LFNoise0 outputs its lowest -4, result is 18.75
  2**(0)*300  // Evaluate this: if LFNoise0 outputs its middle value 0, the result is 300
  2**(4)*300  // Evaluate this: if LFNoise0 outputs its highest +4, result is 4800

  // So, in fact, the range boundaries are the same as in our earlier examples
  // using .range(18.75, 4800), but, unlike before, the distribution is NOT linear.
  // Compare how often you see numbers below 300 appearing in these two examples:

  {LFNoise0.kr(4/3).range(18.75, 4800).poll(4/3, label: "linear")}.play  // Watch the Post window
  {(2**LFNoise0.kr(4/3,4)*300).poll(4/3, label: "exponential")}.play     // Watch the Post window
  s.freeAll

  // You can see from the math above that, in the second case, the distribution
  // of random values is not anymore linear. Basically, there's 50% of chance that
  // the selected value will be BELOW 300; and 50% of chance that it will be above 300.
  // In other words, lower center-freqs for the BPF are now being favored.

  // This is how the linear distribution sounds like with the rest of our code so far:

  {BPF.ar(Saw.ar([32, 33]), LFNoise0.kr(4/3).range(18.75, 4800).poll(4/3, label: "bpf-freq"), 0.1)}.play
  s.freeAll

  // And this is how the exponential one sounds like:

  {BPF.ar(Saw.ar([32,33]),(2**LFNoise0.kr(4/3,4)*300).poll(2, label: "bpf-freq"),0.1)}.play

  // The exponential one not only favors lower notes in general, but also
  // increases the likelihood of louder pops to appear (leaps from
  // very low to very high center-freq). That's probably why the original tweet
  // uses a multiplier of 0.2 for the Saw:

  {BPF.ar(Saw.ar([32,33],0.2),(2**LFNoise0.kr(4/3,4)*300).poll(4/3, label: "bpf-freq"),0.1)}.play
  s.freeAll

  // Finally, a 'distort' method is added to this to smooth things out a bit:

  {BPF.ar(Saw.ar([32,33],0.2),(2**LFNoise0.kr(4/3,4)*300).poll(4/3, label: "bpf-freq"),0.1).distort}.scope

  // A few visual examples of what distort does:

  {LFSaw.ar(300)}.plot          // sawtooth
  {LFSaw.ar(300).distort}.plot  // sawtooth with distort

  {SinOsc.ar(300)}.plot          // sine
  {SinOsc.ar(300).distort}.plot  // sine with distort

  {LFTri.ar(300)}.plot          // triangle
  {LFTri.ar(300).distort}.plot  // triangle with distort


  // Back to the tweet, inside the BPF. Here's the original tweet again:
  {LocalOut.ar(a=CombN.ar(BPF.ar(LocalIn.ar(2)*7.5+Saw.ar([32,33],0.2),2**LFNoise0.kr(4/3,4)*300,0.1).distort,2,2,40));a}.play
  s.freeAll

  // There is still this LocalIn.ar(2)*7.5+ in the code,
  // preceding the Saw, and which we have not analyzed yet.
  // Forget about it for now. Let's look at the the CombN,
  // which has the entire BPF code as its first argument.


  // ********************************************************
  // SECOND PART: CombN
  // ********************************************************

  // This is a comb delay line.
  // CombN.ar(in, maxdelaytime, delaytime, decaytime, mul, add)
  // Simple example with Impulses:

  {CombN.ar(Impulse.ar(1/2), 2, 0.25, 3)}.play
  s.freeAll

  // Input signal: one impulse every 2 seconds (1/2 Hz)
  // Maximum delay time: 2 seconds
  // Delay time: 0.25 seconds
  // Decay time: 3

  // You can hear the 'echoing' impulse fading out.
  // Now let's plug that BPF code into a CombN:

  (
    {CombN.ar(
      BPF.ar(Saw.ar([32,33],0.2),(2**LFNoise0.kr(4/3,4)*300),0.1).distort, // input signal
      2, // max delay time
      0.25, // delay time
      3 // decay time
    )
  }.play
)
s.freeAll

// Same thing, with longer decay time (10s), and delay of 1 second:

(
  {CombN.ar(
    BPF.ar(Saw.ar([32,33],0.2),(2**LFNoise0.kr(4/3,4)*300),0.1).distort, // input signal
    2, // max delay time
    1, // delay time
    10 // decay time
  )
}.play
)
s.freeAll

// Now with the actual values used in the original tweet,
// that is, very long decay time (40s) and delay = 2 seconds
(
  {CombN.ar(
    BPF.ar(Saw.ar([32,33],0.2),(2**LFNoise0.kr(4/3,4)*300),0.1).distort, // input signal
    2, // max delay time
    2, // delay time
    40 // decay time
  )
}.play
)

// Because the delay is now 2 seconds, we hear it more as 'meter'
// rathern than 'echo'. The result is a kind of 2-beat metric structure
// (say, a 2/4 with quarter note = 60), which gradually gets filled
// with "sixteenth notes" (the 4:3 pattern of the LFNoise0)
// as the CombN accumulates decaying echoes of these attacks.

// Remember the earlier example with a linear distribution of the
// random numbers between 18.75 and 4800? If we use THAT one now,
// a lot LESS pops (attacks) are generated, and the whole thing is
// much less rhythmic as a result. The exponential distribution
// of random numbers is then directly relevant to the
// effectiveness of the final rhythmic result. Here's how
// this same bit of code sounds with the linear distribution:
(
  {CombN.ar(
    BPF.ar(Saw.ar([32,33],0.2),LFNoise0.kr(4/3).range(18.75, 4800),0.1).distort, // input signal
    2, // max delay time
    2, // delay time
    40) // decay time
  }.play
)
s.freeAll

//  Another variation below. A version with white noise instead of the
//  sawtooth reveals an interesting aspect about the sawtooth:
(
  {CombN.ar(
    BPF.ar(WhiteNoise.ar([1,1]),(2**LFNoise0.kr(4/3,4)*300),0.1).distort, // input signal
    2, // max delay time
    2, // delay time
    40) // decay time
  }.play
)
s.freeAll

// We still get occasional "rhythmic" pops; but note that the distance
// in amplitude between the pops and the 'sustained' portions of
// the texture is smaller; the continuous white noise
// competes for the foreground with the pops. In the original Saw
// version, the dynamic distance between 'explosive' pops and the
// continuous notes is much bigger, so that the pops (thus the rhythm)
// becomes clearly the foreground within an overall 'quieter' texture.

// Here's another version, back with Saw, but with a more limited
// range of center freqs for the BPF. The attacks (pops) disappear, since
// there are no more big leaps from low to high center-freqs. A more continuous
// texture becomes prevalent, but you can still hear the underlying rhythm:

(
  {CombN.ar(
    BPF.ar(Saw.ar([32,33],0.2),LFNoise0.kr(4/3).range(500, 1500),0.1).distort, // input signal
    2, // max delay time
    2, // delay time
    40) // decay time
  }.play
)
s.freeAll


// ********************************************************
// THIRD PART: LocalIn and LocalOut
// ********************************************************

// LocalIn.ar and LocalOut.ar are internal buses (see help file).
// In the example below, we feed one impulse every 3 seconds
// into this local bus. LocalIn is inside LocalOut, thus a feedback
// is created. The impulse is repeated every 64 samples (block size),
// each time multiplied by 0.99 (so it fades out quickly).

{LocalOut.ar(a=LocalIn.ar(1)+Impulse.ar(1/3)*1);a}.play
s.freeAll


// Assuming the current sampling rate (sr) is 44100, we can find out the
// frequency of this "note" by dividing sr by 64 (block size):

44100/64  // result is 689.0625 Hz if your sr = 44100

// Check it with a sine wave, they should sound the same pitch:

{SinOsc.ar(44100/64, mul: 0.5)}.play // freq = sampling rate / block size
s.freeAll

{LocalOut.ar(a=LocalIn.ar(1)+Impulse.ar(1/3)*0.99);a}.play // freq = sampling rate / block size
s.freeAll

// With a delay line we can hear a gradual accumulation
// of impulses. One impulse is generate every 1 second, and
// mixed (+) with the ones played before. Because there is
// an extra delay of 64 samples "built-in" due to the use of
// LocalIn & LocalOut, the successive impulses do not pile up
// in a simultaneous attack; instead they are gradually
// juxtaposed one after the other, 64 samples apart each time.
// This builds up as a repeated note (689 Hz) of increasing length:

{LocalOut.ar(a=DelayN.ar(LocalIn.ar(1)+Impulse.ar(1),1,1));a}.play // thanks to Nathaniel for this example
s.freeAll

// The variable 'a' above works like in the simpler example below.
// There are two statements separated by a semicolon:

{a=SinOsc.ar(440);a}.play
s.freeAll

// Finally, this is how the original tweet
// uses the LocalIn LocalOut structure:
{LocalOut.ar(a=CombN.ar(BPF.ar(LocalIn.ar(2)*7.5+Saw.ar([32,33],0.2),2**LFNoise0.kr(4/3,4)*300,0.1).distort,2,2,40));a}.play

// The variable 'a' is the CombN code we analyzed earlier:
{CombN.ar(BPF.ar(Saw.ar([32,33],0.2),2**LFNoise0.kr(4/3,4)*300,0.1).distort,2,2,40)}.play

{LocalOut.ar(a=LocalIn.ar(1)+Impulse.ar(1/3));a}.play
s.freeAll
