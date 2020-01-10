// "Method One"
//
// Composed for the Fedora Project's "Musicians' Guide."
// Christopher Antila.
//
// Creative Commons CC-BY-SA 3.0
// http://creativecommons.org/licenses/by-sa/3.0/

(
//    The method is, "Choose something, and take it to the extreme."
// Here I've chosen to take SinOsc to the extreme, so I use it in every
// way that I can imagine.  Of course, there are more and different ways
// to use SinOsc.

//    When looking at this source code (as with any SuperCollider source
// file), keep in mind that there will be other ways to achieve the
// same end result.  I always find it helpful to arrange my code in
// such a way as to make it easily understood.






//    I'm creating a new TempoClock and assigning it to "t_c".  This
// way, when I change the tempo later, it won't be interfering with
// the default TempoClock (which is TempoClock.default).  It must be
// declared here, so that all of the functions in the file can access
// it, and I've put it first because, in each "scope," all var objects
// must be declared before anything else.  Really, I could have written:
//    var t_c;
// here, and only run:
//    t_c = TempoClock.new;
// later.  There is no benefit to that *for this file*, so they're together.
var t_c = TempoClock.new;






//    This is the function that, when executed (by calling
// secondPart.value ), will produce the second part of this simple
// three-part form.  Because it's assigned to a "var", it needs to
// be placed above the first part, which is a SynthDef sent to the
// server.
//
//    I've written this as a function, rather than as a SynthDef. The
// intention is that it sounds different every time it is heard, which
// is why I use pseudo-randomness in the "func" sub-function (see
// inside).  If this had been written as a SynthDef, then the pitches
// would be calculated pseudo-randomly *once* and every time a new
// Synth was created from it, it would have the same pitches.  Because
// it's a function, however, the pitches are generated pseudo-randomly
// every time the function is run.
//
//    Since the function is only run once in the execution of this
// program, you may be wondering why it matters.  Every time the
// program is run, the SynthDef would be re-calculated and sent to the
// server again.  In other words, every time the program is run, this
// middle section will sound different whether it's a SynthDef or a
// function.
//
//    This is true, but one of the principles of good programming is
// to allow for maximum flexibility.  If I later wanted to add another
// playing of "secondPart" to the program, I can do that easily, and
// it would produce different pitches each time.  I might also want to
// take this function and put it into a different program, and writing
// it as a function again allows for greater flexibility.  Besides, if
// I decided that I wanted a SynthDef, it's easy to get one from a
// function (in fact, it's impossible to get one without a function!)
//    SynthDef.new( "SecondPart", secondPart ).send( s );
// But you can't get the function out of a SynthDef.
var secondPart =
{
   // This creates a new array with the ability to hold ten objects of
   // any sort.  It's going to be used to hold each of the SinOsc
   // objects that are created in this section.  By using an array
   // (in SuperCollider called "ArrayedCollection"), I don't have to
   // worry about code like this:
   //    var so_1;
   //    var so_2;
   //    ...
   //    var so_10;
   // to hold the ten SinOsc's.
   var sounds = Array.new( 10 );

   // This generates a pseudo-random number to use as the pitch or
   // frequency (here meaning the same thing), and then creates two
   // equal SinOsc's on either side of the stereo image.
   var func =
   {
      // a_number.rand means "generate a pseudo-random number between
      // 0 and a_number".  I've added 200 to this because frequencies
      // below 200 aren't particularly useful, in terms of pitch. So
      // the result of this is a number between 200 and 800.
      var freq = 200 + 600.rand;

      // This is what the function returns, and it's why you can "play"
      // the function.  When you run func.play, you aren't actually
      // playing func, but rather you're playing what func returns.
      [ SinOsc.ar( freq:freq, mul:0.01),
        SinOsc.ar( freq:freq, mul:0.01) ];
   };

   // This part could certainly be written more elegantly (that is, with
   // less pointless repetition).  When programming, whether for audio
   // or any other reason, repetition is usually regarded as the
   // enemy of good code.  What if I wanted to change the time between
   // the addition of each object, from 5 beats to 6?  What if I wanted
   // to change the number of objects from 10 to 300?  Worse still,
   // what if I made a typing mistake in one line, and copy-and-pasted
   // it to all the others?  I would have to correct them all.  What
   // a pain!
   //
   // As an exercise, try to make this more efficient.  You'll need
   // to read up on "control structures" (see the SuperCollider help
   // files).  It's possible to work these ten lines into one - in
   // fact, it's recommended!
   t_c.sched( 1, { sounds = sounds.add( func.play ); } );
   t_c.sched( 6, { sounds = sounds.add( func.play ); } );
   t_c.sched( 11, { sounds = sounds.add( func.play ); } );
   t_c.sched( 16, { sounds = sounds.add( func.play ); } );
   t_c.sched( 21, { sounds = sounds.add( func.play ); } );
   t_c.sched( 26, { sounds = sounds.add( func.play ); } );
   t_c.sched( 31, { sounds = sounds.add( func.play ); } );
   t_c.sched( 36, { sounds = sounds.add( func.play ); } );
   t_c.sched( 41, { sounds = sounds.add( func.play ); } );
   t_c.sched( 46, { sounds = sounds.add( func.play ); } );

   // This will stop all the sounds held in "sounds".  The last "nil"
   // is required as a return value for the function, or else the .do
   // function will return "10", which t_c.sched() interprets as meaning
   // "run me again 10 beats after I finish."  This isn't disastrous,
   // as it might be in a more complex program, but it would give a
   // lot of error messages to anybody watching the "SuperCollider
   // output" pane.
   t_c.sched( 51, { 10.do( { arg index; sounds[index].free; } ); nil; } );

};






//    This SynthDef represents the first part of the piece.  Note that
// because the concluding brace is followed by ".send(s)", this
// definition gets sent to the server.  Although we have no local var
// that points to this SynthDef, we can use Synth.new( "FirstPart" ),
// because the server knows what "FirstPart" is.
//
//    I've chosen to write this as a SynthDef because it does not need
// to change when it is played.  It is intended to always sound the same,
// so there is no reason for the server to re-calculate everything
// each time it is to be played.  This is not the case for the second
// part (see above).
//
//    Above, I claimed it's impossible to get a SynthDef
// without a function.  Although "FirstPart" may look like a SynthDef
// without a function, the function simply isn't named, but it does
// start at the { and end at the }.  So, why not declare this as a
// function, then make a SynthDef below it, like this?
//    SynthDef.new( "FirstPart", firstPart ).send( s );
// Personal preference, really.  This format makes it more clear that
// "FirstPart" is only intended to be run as a Synth, and it also avoids
// the very minor computational slow-down that would have been involved
// with declaring a function, and a SynthDef from that.
SynthDef.new( \FirstPart,
{
   // These set and modulate the frequency emitted by the left and
   // right channels, respectively.
   //
   // What I've called "drone" is the slowly-moving pitches.
   //
   // "freq" changes how quickly the frequency changes
   // "mul" changes the range of oscillation
   // "add" is the lowest frequency it will hit
   //
   // The resulting frequency goes between "add" and "add + mul",
   // and it reaches each extreme "freq" times per second
   var frequencyL = SinOsc.kr( freq:10, mul:200, add:400 );
   var frequencyR = SinOsc.kr( freq:1, mul:50, add:150 );
   var frequencyL_drone = SinOsc.kr( freq:0.03, mul:20, add:100 );
   var frequencyR_drone = SinOsc.kr( freq:0.01, mul:20, add:210 );

   // This will change the volume of the left audio channel.
   // It was annoying when too loud for too long.
   //
   // It means that the volume will go between 0.03 and 0.05, reaching
   // the extremes once every two seconds.
   var volumeL = SinOsc.kr( freq:0.5, mul:0.02, add:0.03 );

   //    This is where I'm compiling the sound generators themselves.
   // Notice that all the SinOsc's above were SinOsc.kr(), for "kontrol,"
   // and all the ones here are SinOsc.ar(), for "audio."  I use array
   // notation, which is the [ ] brackets, several times.  This allows
   // multiple SinOsc calls with different arguments, and within each
   // call it allows multiple audio streams to be outputted, with
   // different frequencies.  While you might expect there to by
   // multi-channel audio created from this, that's not the case,
   // because everything assigned to "left" or "right" is ultimately
   // played below.  More on that later...
   var left = [ SinOsc.ar( freq:frequencyL, mul:volumeL ), // this is the oscillating part
                SinOsc.ar( freq:[frequencyL_drone,2*frequencyL_drone], mul:0.02 ), // the rest make up the drone; the numbers are close to the 2^x series
                SinOsc.ar( freq:[5*frequencyL_drone,7*frequencyL_drone], mul:0.005 ),
                SinOsc.ar( freq:[13*frequencyL_drone,28*frequencyL_drone], mul:0.001 ) ];

   var right = [ SinOsc.ar( freq:frequencyR, mul:0.1 ), // this is the oscillating part
                 SinOsc.ar( freq:[frequencyR_drone,2*frequencyR_drone], mul:0.02 ), // the rest make up the drone
                 SinOsc.ar( freq:4*frequencyR_drone, mul:0.005 ),
                 SinOsc.ar( freq:[64*frequencyR_drone,128*frequencyR_drone], mul:0.01 ) ]; // high frequencies!

   //    This stereo mix is what ultimately gets played.  Notice that
   // any multichannel effects created while mixing "left" and "right"
   // are ignored here, and all the sound from each variable is put
   // into one channel: all of the channels from "left" get played in
   // the new left channel, and all of the channels from "right" get
   // played in the new right channel.
   //
   //    Try commenting the array, and play "left" and "right" by
   // uncommenting the following lines, one at a time.  When you do
   // that, the multichannel mix of the variable is preserved, which
   // may lead to a surprising result (if it doesn't, listen more
   // carefully, and compare to the original).
   //
   //    For an explanation, go read about busses, and keep in mind
   // that this array doesn't create "left" and "right" channels,
   // but rather plays to busses 0 and 1, which usually wind up being
   // played through the speakers as "left" and "right" channels.
   Out.ar( 0, [left,right] );

} ).send( s );






//    This is the equivalent of the "main" function in a C-like language,
// which basically "causes" everything else to happen.  It's important
// to include the ".value;" at the end, or else executing the program
// would result in "a Function" in the output pane, and no sound.
{
   // This will hold the currently-running instance of "FirstPart".
   // I've set it to 0 now as a matter of habit, like initializing an
   // int in C.
   var sound = 0;

   // This sets the tempo to one beat per second; in effect, t_c now
   // counts in seconds.
   t_c.tempo_( 1 );

   // This schedules events to take place.  By number of beats after start:
   // 1: "FirstPart" starts to play.
   // 60: "FirstPart" is silenced.
   // 60: secondPart is engaged (but starts to play only on beat 61).
   // 112: "FirstPart" starts to play.
   // 142: "FirstPart" is silenced.
   t_c.sched( 1, { sound = Synth.new( \FirstPart ); } );
   t_c.sched( 61, { sound.free; } );
   t_c.sched( 61, { secondPart.value; nil; } ); // this takes 51 beats to complete
   t_c.sched( 113, { sound = Synth.new( \FirstPart ); } );
   t_c.sched( 143, { sound.free; } );
   //    I could have simply "paused" the \FirstPart synth, but then it
   // wouldn't necessarily re-start at the same point in the oscillation
   // as it did when first created.
}.value;

)
