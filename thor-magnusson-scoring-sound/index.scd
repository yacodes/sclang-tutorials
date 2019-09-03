"Hello world".postln;

"Hello, world".postln; "Goodbye, world".postln;

Scale.minor.degrees;
Scale.major.degrees;

"v1: %, v2: %\n".postf(100, 200)

Post << "hey"

Array.fill(1000, {100.rand}).post

Post << Array.fill(1000, {100.rand})

Help.gui

s.boot

s.quit

(
  {
    var freq, oscillator, filter, signal;
    freq = 333;
    oscillator = Saw.ar([freq, freq + 2]);
    filter = RLPF.ar(oscillator, freq * 4, 0.25);
    signal = filter * 0.5;
  }.play
)

s.freeAll

play{HPF.ar(({|k|({|i|SinOsc.ar(i/96,Saw.ar(2**(i+k))/Decay.ar(Impulse.ar(0.5**i/k),[k*i+1,k*i+1*2],3**k))}!6).product}!32).sum/2,40)}

f = {44.postln};

f.value

(
  f = {
    69 + ( 12 * log( 220/440 ) / log(2) )
  };
  f.value // returns the MIDI note 57 (the MIDI note for 220 Hz)
)

(
  f = {
    arg freq;
    69 + (12 * log(freq / 440) / log(2));
  };
)

f.value(440)

(
  f = { arg salary, tax=20;
    var aftertax;
    aftertax = salary - (salary * (tax/100) )
  }
)

f.value(2000) // here we use the default 20% tax rate
f.value(2000, 35) // and here the tax percentage has become 35%

f = { arg string; string.postln; }; // we will post the string that comes into the function
f.value("hi there"); // and here we call the function passing “hi there” as the argument.

f = {|string| string.postln;} // arguments can be defined within two pipes ‘|’
f.("hi there") // and you can skip the .value and just write a dot (.)

// Arrays, Lists and Dictionaries
a = [11, 22, 33, 44, 55];

a[0]; // we get at the first item in the array (most programming languages index at zero)
a[4] // returns 55, as index 4 into the array contains the value 55
a[1] + a[4] // returns 77 as 22 plus 55 equals 77
a.reverse // we can reverse the array
a.maxItem // the array can tell us what is the highest value

// create an array with five random numbers from 0 to 100
a = Array.fill(5, { 100.rand });
a = Array.fill(5, 100.rand ); // create an array with ONE random number from 0 to 100

a = Array.fill(5, { arg i; i }); // create a function with the iterator (‘i’) argument
a = Array.fill(5, { arg i; (i+1)*11 }); // the same as the first array we created
a = Array.fill(5, { arg i; i*i });
a = Array.series(5, 10, 2); // a new method (series).
// Fill the array with 5 items, starting at 10, adding 2 in every step.

m = Scale.minor.degrees; // Scale class returns the degrees of the minor scale
m = m + 12; // you might want to add the octave (12) into your array
m = m + 60 // here we simply add 60 to all the values in the array
m = m.midicps // and here we turn the MIDI notes into their frequency values
m = m.cpsmidi // but let’s turn them back to MIDI values for now

n = m.choose; // choose a random MIDI note and store it in the variable ’n’
x = m.scramble; // we could create a melody by scrambling the array
x = m.scramble[0..3] // scramble the list and select the first 4 notes
p = m.mirror // mirror the array (like an ascending and descending scale)

a = [1, "two", 3.33, Scale.minor] // we mix types into the array.
// This can be dangerous as the following
a[0]*10 // will work
a[1]*10 // but this won’t, as you cant multiply the word “two” with 10

// a function that will create a 5 item array with random numbers from 0 to 10
f = { Array.fill(5, { 10.rand }) }; // array generating function
a = Array.fill(10, f.value); // create another array with 10 items of the above array
// But the above was evaluated only once. Why?
// Because, you need to pass it a function to get a different array every time. Like this:
a = Array.fill(10, { f.value } ); // create another array with 10 items of the above array
// We can get at the first array and see it’s different from the second array
a[0]
a[1]
// We could put a new array into a[0] (that slot contains an array)
a[0] = f.value
// We could put a new array into a[0][0] (an integer)
a[0][0] = f.value

m = Scale.minor.degrees;
m + 12; // but try to run this line many times, the array won’t grow forever


// Lists
l = List.new;
l.add(100.rand) // try to run this a few times and watch the list grow
l.scramble


// Dictionaries
a = Dictionary.new
a.put(\C, 60)
a.put(\Cs, 61)
a.put(\D, 62)
a[\Ds] = 63 // same as .put
// and now, let's get the values
a.at(\D)
a[\Ds] // same as .at
a.keys
a.values
a.getPairs
a.findKeyForValue(60)

a = [\C, 60, \Cs, 61, \D, 62, \Ds, 63]
// we find the slot of a key:
x = a.indexOf(\D) // 4
a[x+1]
// or simply
a[a.indexOf(\D)+1]

b = Dictionary.new
b.put(\major, [ 0, 2, 4, 5, 7, 9, 11 ])
b.put(\minor, [ 0, 2, 3, 5, 7, 8, 10 ])
b[\minor]


// Methods?
Array.openHelpFile // get the documentation of the Array class
Array.dumpInterface // get the interface or the methods of the Array class
Array.dumpFullInterface // get the methods of Array’s superclasses as well.


// Conditionals, data flow and control
if( true, { "condition is TRUE".postln;}, {"condition is FALSE".postln;});
if( false, { "condition is TRUE".postln;}, {"condition is FALSE".postln;});

true.binaryValue;
false.binaryValue;

true == true // returns true
true != true // returns false (as true does indeed equal true)
true == false // returns false
true != false // returns true (as true does not equal false)
3 == 3 // yes, 3 equals 3
3 != 4 // true, 3 does not equal 4
true || false // returns true, as one of the elements are true
false || false // returns false, as both of the elements are false
3 > 4 // false, as 3 is less than 4
3 < 4 // true
3 < 3 // false
3 <= 3 // true, as 3 is indeed less than or equal to 3

if( 3==3, { "condition is TRUE".postln;}, {"condition is FALSE".postln;});
if( 3==4, { "condition is TRUE".postln;}, {"condition is FALSE".postln;});
// and things can be a bit more complex:
if( (3 < 4) && (true != false), {"TRUE".postln;}, {"FALSE".postln;});

(
  a = 4.rand; // a will be a number from 0 to 4;
  switch(a)
  {0} {"a is zero".postln;} // runs this if a is zero
  {1} {"a is one".postln;} // runs this if a is one
  {2} {"a is two".postln;} // etc.
  {3} {"a is three".postln;};
)

(
  a = 4.rand; // a will be a number from 0 to 4;
  case
  {a == 0} {"a is zero".postln;} // runs this if a is zero
  {a == 1} {"a is one".postln;} // runs this if a is one
  {a == 2} {"a is two".postln;} // etc.
  {a == 3} {"a is three".postln;};
)


// Looping and iterating
10.do({ "SCRAMBLE THIS 10 TIMES".scramble.postln; })

(
  var counter = 0;
  10.do({
    counter = counter + 1;
    "counter is now: ".post;
    counter.postln;
  })
)

10.do({arg counter; counter.postln;});
// you can call this argument whatever you want:
10.do({arg num; num.postln;});
// and the typical convention is to use the character "i" (for iteration):
10.do({arg i; i.postln;});

(
  p = List.new;
  10000.do({ arg i; // i is the iteration from 0 to 10000
    if( i.isPrime, { p.add(i) }); // no else condition - we don't need it
  });
  Post << p;
)

(
  [ 11, 22, 33, 44, 55, 66, 77, 88, 99 ].do({arg item, counter;
    item.post; " is in the array at slot: ".post; counter.postln;
  });
)

[ 11, 22, 33, 44, 55, 66, 77, 88, 99 ].do({arg aa, bb; aa.post; " is in the array at slot: ".post; bb.postln });

// for(startValue, endValue, function); // this is the syntax
for(100, 130, { arg i; i = i+10; i.postln; }) // example

// forBy(startValue, endValue, stepValue, function); // the syntax
forBy(100, 130, 4, { arg i; i = i+10; i.postln; }) // example

// while (testFunc, bodyFunc); // syntax
(
  i = 0;
  while ({ i < 30 }, { i = i + 1; i.postln; });
)

// Peaking under the hood
UGen.dumpSubclassList // UGen is a class. Try dumping LFSaw for example
UGen.browse // examine methods interactively in a GUI (OSX)
SinOsc.dumpFullInterface // list all methods for the classhierarchically
SinOsc.dumpMethodList // list instance methods alphabetically
SinOsc.openHelpFile



// ------------------------------------
// Chapter 2 - The SuperCollider Server
// let us explore the 's' variable, that stands for the synth:
s.postln; // we see that it contains a localhost synth
s.addr // the address of the synth (IP address and Port)
s.name // the localhost server is the default server (see Main.sc file)
s.serverRunning // is it running?
s.avgCPU // how much CPU is it using right now?
// Let's
s.boot

n = NetAddr("127.0.0.1", 57200); // IP (get it from whatsmyip.org) and port
p = Server.new("hoho", n); // create a server with the specific net address
p.makeWindow; // make a GUI window
p.boot; // boot it
// try the server:
{SinOsc.ar(444)}.play(p);
// stop it
p.quit

s.boot
// Here is a sine wave unit generator
// it has an audio rate method (the .ar)
// and its argument order is frequency, phase and multiplication
{SinOsc.ar(440, 0, 1)}.play
// now try to run a SinOsc with control rate:
{SinOsc.kr(440, 0, 1)}.play // and it is inaudible
s.freeAll

// A sine wave of 1 Hz modulates the 440 Hz frequency
{SinOsc.ar(440*SinOsc.kr(1), 0, 1)}.play
// A control rate sine wave of 3 Hz modulates the amplitude
{SinOsc.ar(440, 0, SinOsc.kr(3))}.play
// An audio rate sine wave of 3 Hz modulates the amplitude
{SinOsc.ar(440, 0, SinOsc.ar(3))}.play
// and as you can hear, there is no difference
// 2 Hz modulation of the cutoff frequency of a Low Pass Filter (LPF)
// we add 1002, so the filter does not go into negative range
// which might blow up the filter
{LPF.ar(Saw.ar(440), SinOsc.kr(2, 0, 1000)+1002)}.play

(
  {
    // we create a slow oscillator in control rate
    a = SinOsc.kr(1);
    // the output of 'a' is used to multiply the frequency of a saw wave
    // resulting in a frequency from 440 to 660. Why?
    b = Saw.ar(220 * (a + 2), 0.5);
    // and here we use 'a' to control amplitude (from -0.5 to 0.5)
    c = Saw.ar(110, a * 0.5);
    // we add b and c, and use a to control the filter cutoff frequency
    // we simply added a .range method to a so it now outputs
    // values between 100 and 2000 at 1 Hz
    d = LPF.ar(b + c, a.range(100, 2000));
    Out.ar(0, Pan2.ar(d, 0));
  }.play
)
s.freeAll

(
  {
    // we take sound in from the sound card
    a = SoundIn.ar(0);
    // and we ring modulate using the mouse to control frequency
    b = a * SinOsc.ar(MouseX.kr(100, 3000));
    // we also use the mouse (vertical) to control delay
    c = b + AllpassC.ar(b, 1, MouseY.kr(0.001, 0.2), 2);
    // and here, instead of Pan2, we simply use an array [c, c]
    Out.ar(0, [c, c]);
  }.play
)
s.freeAll

UGen.browse; // XXX check if this works

Function.browse

// this simple synth
{Saw.ar(440)}.play

s.freeAll

(
  // becomes this synth definition
  SynthDef(\mysaw, {
    Out.ar(0, Saw.ar(440));
  }).add;
)

// you can use the 'Out' UGen in Function:play
{Out.ar(1, Saw.ar(440))}.play // out on the right speaker

// create a synth and put it into variable 'a'
a = Synth(\mysaw);
// create another synth and put it into variable 'b'
b = Synth(\mysaw);
a.free; // kill a
b.free; // kill b

(
  SynthDef(\mysaw, { arg freq=440, amp=0.2, pan=0;
    Out.ar(0, Pan2.ar(Saw.ar(freq, amp), pan));
  }).add;
)
// this now allows us to create a new synth:
a = Synth(\mysaw); // explore the Synth help file
// and control it, using the .set, method of the Synth:
a.set(\freq, 220);
a.set(\amp, 0.8);
a.set(\freq, 555, \amp, 0.4, \pan, -1);
a.free;

(
  SynthDef(\mysaw, { arg freq=440, amp=0.2, pan=0, cutoff=880, rq=0.3;
    Out.ar(0, Pan2.ar(RLPF.ar(Saw.ar(freq, amp), pan), cutoff, rq));
  }).add;
)

a = Synth(\mysaw); // explore the Synth help file
s.freeAll;

(
  // the same as above, but more readable
  SynthDef(\mysaw, { arg freq=440, amp=0.2, pan=0, cutoff=880, rq=0.3;
    var signal, filter, panned;
    signal = Saw.ar(freq, amp);
    filter = RLPF.ar(signal, cutoff, rq);
    panned = Pan2.ar(filter, pan);
    Out.ar(0, panned);
  }).add;
)

a = Synth(\mysaw); // we create a synth with the default arguments
b = Synth(\mysaw, [\freq, 880, \cutoff, 12000]); // we pass arguments
a.set(\cutoff, 500);
b.set(\freq, 444);
a.set(\freq, 1000, \cutoff, 1200);
b.set(\cutoff, 4000);
b.set(\rq, 0.1);
s.freeAll
s.avgCPU


// Observing server activity (Poll, Scope and FreqScope)
// we can explore the output of the SinOsc
{SinOsc.ar(1).poll}.play // you won't be able to hear this
// and compare to white noise:
{WhiteNoise.ar(1).poll}.play // the first arg of noise is amplitude
// we can explore the mouse:
{MouseX.kr(10, 1000).poll}.play // nothing to hear
// we can poll the frequency of a sound:
{SinOsc.ar(LFNoise2.ar(1).range(100, 1000).poll)}.play
// or we poll the amplitude of it
{SinOsc.ar(LFNoise2.ar(1).range(100, 1000)).poll}.play
// and we can add a label (first arg is poll rate, second is label)
{SinOsc.ar(LFNoise2.ar(1).range(100, 1000).poll(10, "freq"))}.play


s.freeAll
// we can explore the output of the SinOsc
{SinOsc.ar(1)}.scope // you won't be able to hear this
// and compare to white noise:
{WhiteNoise.ar(1)}.scope // the first arg of noise is amplitude
// we can scope the mouse state (but note the control rate):
{MouseX.kr(-1, 1)}.scope // nothing to hear
// the range method maps the output from -1 to 1 into 100 to 1000
{SinOsc.ar(LFNoise2.ar(1).range(100, 1000))}.scope;
// same here, we explore the saw wave form at different frequencies
{Saw.ar(220*SinOsc.ar(0.5).range(1, 10))}.scope

s.freeAll
// we see the wave at 1000 Hz, with amplitude modulated
{SinOsc.ar(1000, 0, SinOsc.ar(0.25))}.freqscope
// some white noise again:
{WhiteNoise.ar(1)}.freqscope // random values throughout the spectrum
// and we can now experienc the power of the scope
{RLPF.ar(WhiteNoise.ar(1), MouseX.kr(20, 12000), MouseY.kr(0.01, 0.99))}.freqscope
// we can now explore various wave forms:
{Saw.ar(440*XLine.ar(1, 10, 5))}.freqscope // check the XLine helpfile
// LFTri is a non-bandlimited UGen, so explore the mirroring or 'aliasing'
{LFTri.ar(440*XLine.ar(1, 10, 25))}.freqscope


// A quick intro to busses and multichannel expansion
// sound put out on different busses
s.freeAll
{ Out.ar(0, LFPulse.ar(220, 0, 0.5, 0.3)) }.play; // left speaker (bus 0)
{ Out.ar(1, LFPulse.ar(220, 0, 0.5, 0.3)) }.play; // right speaker (bus 1)
{ Out.ar(2, LFPulse.ar(220, 0, 0.5, 0.3)) }.play; // third speaker (bus 2)
// Pan2 makes takes the signal and converts it into an array of two signals
{ Out.ar(0, Pan2.ar(PinkNoise.ar(1), 0)) }.scope(8)
// or we can play it out on bus 6 (and you probably won't hear it)
{ Out.ar(0, Pan2.ar(PinkNoise.ar(1), 0)) }.scope(8)
// but the above is the same as:
{ a = PinkNoise.ar(1); Out.ar(0, [a, a]) }.scope(8)
// and (where the first six channels are silent):
{ a = PinkNoise.ar(1); Out.ar(0, [0, 0, 0, 0, 0, 0, a, a]) }.scope(8)
// however, it's not the same as:
{ Out.ar(0, [PinkNoise.ar(1), PinkNoise.ar(1)]) }.scope(8)
// why not? -> because we now have TWO signals rather than one

s.freeAll
{ SinOsc.ar(440) }.scope(8)
{ [SinOsc.ar(440), SinOsc.ar(880)] }.scope(8)
// same as:
{ SinOsc.ar([440, 880]) }.scope(8)
// a trick to 'expand into an array'
{ SinOsc.ar(440) ! 2 }.scope(8)
// if that was strange, check this:
123 ! 30

// Getting values back to the language
// If we would like to do something with audio data in the language, such as visualising it, posting
// it, or such, we need to send a message to the server and wait for it to respond back. This can happen in
// various ways, but a typical way of doing this is to use the SendTrig Ugen: */
(
  // this is happening in the language
  OSCdef(\listener, {arg msg, time, addr, recvPort; msg.postln; }, '/tr', s.addr);
  // and this happens in the server
  {
    var freq;
    freq = LFSaw.ar(0.75, 0, 100, 900);
    SendTrig.kr(Impulse.kr(10), 0, freq);
    SinOsc.ar(freq, 0, 0.5)
  }.play
)
s.freeAll

s.boot;

(
  SynthDef("help-SendTrig",{
    SendTrig.kr(Dust.kr(1.0),0,0.9);
  }).add;

  // register to receive this message
  o = OSCFunc({ arg msg, time;
    [time, msg].postln;
  },'/tr', s.addr);
)

Synth("help-SendTrig");

o.free;


(
  // this is happening in the language
  var win, freqslider, mouseslider;
  win = Window.new.front;
  freqslider = Slider(win, Rect(20, 10, 40, 280));
  mouseslider = Slider2D(win, Rect(80, 10, 280, 280));
  OSCdef(\sliderdef, {arg msg, time, addr, recvPort;
    {freqslider.value_(msg[3].linlin(600, 1400, 0, 1))}.defer;
  }, '/slider', s.addr); // the OSC message we listen to
  OSCdef(\sliderdef2D, {arg msg, time, addr, recvPort;
    { mouseslider.x_(msg[3]); mouseslider.y_(msg[4]); }.defer;
  }, '/slider2D', s.addr); // the OSC message we listen to

  // and this happens on the server
  {
    var mx, my, freq;
    freq = LFSaw.ar(0.75, 0, 400, 1000); // outputs 600 to 1400 Hz. Why?
    mx = LFNoise2.kr(2).range(0,1);
    my = LFNoise2.kr(2).range(0, 1);
    SendReply.kr(Impulse.kr(10), '/slider', freq); // sending the OSC message
    SendReply.kr(Impulse.kr(10), '/slider2D', [mx, my]);
    (SinOsc.ar(freq, 0, 0.5)+RLPF.ar(WhiteNoise.ar(0.3), mx.range(100, 3000), my))!2 ;
  }.play;
)
s.freeAll

b = Bus.control(s,1); // we create a control bus
{Out.kr(b, MouseX.kr(20,22000))}.play // and we write the output of some UGen to the bus
b.get({arg val; val.postln;}); // we poll the puss from the language
// or even:
fork{loop{ b.get({arg val; val.postln;});0.1.wait; }}
s.boot


(
  x = 0; y= 0;
  b = Bus.control(s,1); // we create a control bus
  {Out.kr(b, MouseX.kr(20,22000))}.play;
  t = Task({
    inf.do({
      "1 - before b.get : ".post; x = Main.elapsedTime.postln;
      b.get({|val|
        "2 - ".post; val.postln;
        y = Main.elapsedTime.postln;
        "the asynchronious process took : ".post; (y-x).post; " seconds".postln;
      }); // this value is returned AFTER the next line
      "3 - after b.get : ".post; Main.elapsedTime.postln;
      0.5.wait;
    })
  }).play;
)
s.boot


// ProxySpace
p = ProxySpace.push(s.boot)
~signal.play;
~signal.fadeTime_(2) // fading in and out in 2 secs
~signal = {SinOsc.ar(400, 0, 1)!2}
~signal = {SinOsc.ar([400, 404], 0, LFNoise0.kr(4))}
~signal = {Saw.ar([400, 404], LFNoise0.kr(4))}
~signal = {Saw.ar([400, 404], Pulse.ar(2))}
~signal = {Saw.ar([400, 404], Pulse.ar(Line.kr(1, 30, 20)))}
~signal = {LFSaw.ar([400, 404], LFNoise0.kr(4))}
~signal = {Pulse.ar([400, 404], LFNoise0.kr(4))}
~signal = {Blip.ar([400, 404], 12, Pulse.ar(2))}
~signal = {Blip.ar([400, 404], 24, LFNoise0.kr(4))}
~signal = {Blip.ar([400, 404], 4, LFNoise0.kr(4))}
~signal = {Blip.ar([400, 404], MouseX.kr(4, 40), LFNoise0.kr(4))}
~signal = {Blip.ar([200, 204], 5, Pulse.ar(1))}
// now let's try to add some effects
~signal[1] = \filter -> {arg sig; (sig*0.6)+FreeVerb.ar(sig, 0.85, 0.86, 0.3)}; // reverb
~signal[2] = \filter -> {arg sig; sig + AllpassC.ar(sig, 1, 0.15, 1.3 )}; // delay
~signal[3] = \filter -> {arg sig; (sig * SinOsc.ar(2.1, 0, 5.44, 0))*0.5}; // tremolo
~signal[4] = \filter -> {arg sig; PitchShift.ar(sig, 0.008, SinOsc.ar(2.1, 0, 0.11, 1))}; // pitchshift
~signal[5] = \filter -> {arg sig; (3111.33*sig.distort/(1+(2231.23*sig.abs))).distort*0.2}; // distort
~signal[1] = nil;
~signal[2] = nil;
~signal[3] = nil;
~signal[4] = nil;
~signal[5] = nil;
s.freeAll

// Another ProxySpace example:
p = ProxySpace.push(s.boot);
~blipper = { |freq=20, nHarm=30, amp=0.1| Blip.ar(freq, nHarm, amp)!2 };
~blipper.play;
~lfo = { MouseX.kr(10, 100, 1) };
~blipper.map(\freq, ~lfo);
~blipper.set(\nHarm, 50)
~lfn = { LFDNoise3.kr(15, 30, 40) };
~blipper.map(\nHarm, ~lfn);
~lfn = 30;
~blipper.set(\nHarm, 50);
s.freeAll


// ----------------------------------
// Chapter 3 - Controlling the Server
s.boot
s.reboot
(
  Routine({
    inf.do({arg i;
      "iteration: ".post; i.postln;
      0.25.wait;
    })
  }).play
)
s.freeAll

// Equals
fork{
  inf.do({arg i;
    "iteration: ".post; i.postln;
    0.25.wait;
  })
}

// this won't work, as there is no routine involved
100.do({arg i; "iteration: ".post; i.postln; 0.25.wait; });
// but this will work, as we are not asking the loop to wait:
100.do({arg i; "iteration: ".post; i.postln; })

// A routine can be played with different clocks (TempoClock, SystemClock, and AppClock)
s.boot
(
  r = Routine.new({
    10.do({ arg a;
      a.postln;
      1.wait;
    });
    0.5.wait;
    "routine finished!".postln;
  });
)

SystemClock.play(r); // and then we run it
r.reset // we have to reset the routine to start it again:
AppClock.play(r); // here we tell AppClock to play routine r
r.play(AppClock) // or we can use this syntax
r.stop; // stop the routine
r.play; // try to start the routine again... It won't work.

// In the last line above we experience that we can’t restart a routine after it has stopped.
// Here is where Tasks come in handy, but they are pauseable processes that behave like routines.
// (Check the Task helpfile).
s.reboot
(
  t = Task({
    inf.do({arg i;
      "iteration is: ".post; i.postln;
      0.25.wait;
    })
  });
)
t.play;
t.pause;
t.resume;
t.stop;
t.play;
t.reset;


s.boot
(
  SynthDef(\ch3synth1, {arg freq=333, amp=0.4, pan=0.0, dur=0.41; // the arguments
    var signal, env;
    env = EnvGen.ar(Env.perc(0.001, dur), doneAction:2); // doneAction gets rid of the synth
    signal = LFTri.ar(freq, 0, amp) * env; // the envelope multiplies the signal
    signal = Pan2.ar(signal, pan);
    Out.ar(0, signal);
  }).add;
)

(
  m = ([0, 1, 5, 6, 10, 12] + 48).midicps;
  m = m.scramble; // try to re-evaluate only this line
  t = Task({
    inf.do({arg i;
      Synth(\ch3synth1, [\freq, m.wrapAt(i)]);
      0.25.wait;
    })
  });
  t.play;
)

(
  f = fork{
    inf.do({arg i;
      m = m.scramble;
      "SCRAMBLING".postln;
      4.8.wait; // why did I choose 4.8 second wait.
    })
  }
)
s.freeAll

// Patterns
s.boot
().play; // run this Event and we observe the posting of default arguments
Pbind().play; // the event arguments are used in the Pbind.
s.freeAll
s.reboot

// here we have a Pattern that binds the frequency key to the value of 1000
Pbind(\freq, 1000, \dur, 0.25).play;

// the synthdef has the conventional 'freq' and 'amp' arguments, but also our own 'cutoff'
(
  SynthDef(\patsynth1, { arg out=0, freq=440, amp=0.1, pan=0, cutoff=1000, gate = 1;
    var signal = MoogFF.ar(Saw.ar(freq, amp), cutoff, 3);
    var env = EnvGen.kr(Env.adsr(), gate, doneAction: 2);
    Out.ar(out, Pan2.ar(signal, pan, env));
  }).add;
)
// we play our 'patsynth1' instrument, and control the cutoff parameter
Pbind(\instrument, \patsynth1, \freq, 100, \cutoff, 300, \amp, 0.6).play;
// try this as well:
Pbind(\instrument, \patsynth1, \freq, 100, \cutoff, 3000, \amp, 0.6).play;

Pbind(\instrument, \patsynth1, \freq, 100, \amp, 0.6, \dur, 0.5).play;
Pbind(\instrument, \patsynth1, \freq, 100, \amp, 0.6, \dur, 0.5, \sustain, 0.1).play;

// here we format it differently, into pairs of keys and values
(
  Pbind(
    \instrument, \patsynth1,
    \freq, Pseq([100, 200, 120, 180], inf), // sequencing frequency
    \amp, 0.6,
    \dur, 0.5
  ).play;
)

s.boot

// we can use list patterns for values to any keys:
(
  Pbind(
    \instrument, \patsynth1,
    \freq, Prand([100, 200, 120, 180], inf),
    \amp, Pseq([0.3, 0.6], inf),
    \dur, Pseq([0.125, 0.25, 0.5, 0.25], inf),
  ).play;
)

(
  Pbind(
    \instrument, \patsynth1,
    \freq, Pseq([100, 200, 120, 180], inf),
    \cutoff, Pseq([1000, 2000, 3000], inf), // only 3 items in the list - it loops
    \amp, Pseq([0.3, 0.6], inf),
    \dur, Pseq([0.125, 0.25, 0.5, 0.25], inf),
  ).play;
)

// here we put a pattern into a variable "a"
(
  a = Pdef.new(\example1,
    Pbind(\instrument, \patsynth1, // using our sine synthdef
      \freq, Pseq([220, 440, 660, 880], inf), // freq arg
      \dur, Pseq([0.25, 0.5, 0.25, 0.5], inf); // dur arg
    )
  );
)
a.play;
a.pause;
a.resume;
// but we don't need to:
(
  Pdef(\example2,
    Pbind(\instrument, \patsynth1, // using our sine synthdef
      \freq, Pseq.new([720, 770, 990, 880], inf), // freq arg
      \dur, Pseq.new([0.25, 0.5, 0.25, 0.5], inf); // dur arg
    )
  );
)
Pdef(\example2).play;
Pdef(\example2).pause;
Pdef(\example1).pause;
Pdef(\example2).resume;
// Now, let's play them both together with a bit of timeshift
(
  Pdef(\example1).quant_([2, 0, 0]);
  Pdef(\example2).quant_([2, 0.5, 1]); // offset by half a beat
  Pdef(\example1).play;
  Pdef(\example2).play;
)
// and without stopping we redefine the example1 pattern:
(
  Pdef(\example1,
    Pbind(
      \instrument,
      \patsynth1, // using our sine synthdef
      \freq, Pseq.new([Pseq.new([220, 440, 660, 880], 4), Pseq.new([220, 440, 660, 880], 4) * 1.5], inf),
      \dur, Pseq.new([0.25, 0.125, 0.125, 0.25, 0.5], inf); // dur arg
    )
  );
)


// --------------
// The TempoClock
t = TempoClock.new;
t.tempo = 1;
// wait for 4 beats (4 secs);
// beat variable is fractional
t.sched(4, { arg beat, sec; [beat, sec].postln; });

t = TempoClock.new;
t.tempo = 4; // we make the tempo 240 bpm (240/60 = 4)
// wait for 4 beats (1 sec);
// abs beat variable
t.schedAbs(4, { arg beat, sec; [beat, sec].postln; });

t = TempoClock.new;
t.tempo = 1;
t.schedAbs(0, { arg beat, sec; [beat, sec].postln; 1});

s.boot

t = TempoClock.new;
t.tempo = 1;
t.schedAbs(0, { arg beat, sec; [beat, sec].postln; 1});
t.schedAbs(0, { arg beat, sec; "_Scramble_".scramble.postln; 0.5});

// our synth
(
  SynthDef(\clocksynth, { arg out=0, freq=440, amp=0.5, pan=0, cutoff=1000, gate = 1;
    var signal = MoogFF.ar( Saw.ar(freq, amp), cutoff, 3);
    var env = EnvGen.kr(Env.perc(), gate, doneAction: 2);
    Out.ar(out, Pan2.ar(signal, pan, env) );
  }).add;
)

s.boot

// the clock
t = TempoClock.new;
t.tempo = 2;
(
  t.schedAbs(0, { arg beat, sec;
    Synth(\clocksynth, [\freq, 440]);
    if(beat%4==0, { Synth(\clocksynth, [\freq, 440/4, \amp, 1]); });
    if(beat%2==0, { Synth(\clocksynth, [\freq, 440*4, \amp, 1]); });
    1
  });
)

// @NOTE
// When you get an error message that sounds like “… cannot be called from this process” then you
// need to use an AppClock or put the function into a .defer function: {myfunction.value}.defer
(
  var clock, waitTime;
  waitTime = 2;
  clock = TempoClock(2, 0);
  { // a fork
    "starting the program".postln;
    { // and we fork again (play 10 sines)
    10.do({|i|
      Synth(\clocksynth, [\freq, 1000+(rand(1000))]);
      "synth nr : ".post; i.postln;
      (waitTime/10).wait; // wait for 100 milliseconds
    });
    "end of 1st fork".postln;
  }.fork(clock);
  waitTime.wait;
  "finished waiting, now we play the 2nd fork".postln;
  { // and now we play another fork where the frequency is lower
    20.do({|i|
      Synth(\clocksynth, [\freq, 100+(rand(1000))]);
      "synth nr : ".post; i.postln;
      (waitTime/10).wait;
    });
    "end of 2nd fork".postln;
  }.fork(clock);
  "end of the program".postln;
}.fork(clock);
)

// GUI Control
// we create a synth (here a oscillator with 16 harmonics)
(
  SynthDef(\simpleSynth, {|freq, amp|
    var signal, harmonics;
    harmonics = 16;
    signal = Mix.fill(harmonics, {arg i; SinOsc.ar(freq * (i + 1), 1.0.rand, amp * harmonics.reciprocal /(i + 1))});
    Out.ar(0, signal!2);
  }).add;
)

(
  var synth, win, freqsl, ampsl;
  // create a GUI window
  win = Window.new("simpleSynth", Rect(100, 100, 300, 90), false).front;
  // and place the frequency and amplitude sliders in the window
  StaticText.new(win, Rect(10,10, 160, 20)).font_(Font("Helvetica", 9)).string_("freq");
  freqsl = Slider.new(win, Rect(40,10, 160, 24)).value_(1.0.rand).action_({arg sl; synth.set(\freq, sl.value*1000;) });

  StaticText.new(win, Rect(10,46, 160, 20)).font_(Font("Helvetica", 9)).string_("amp");
  ampsl = Slider.new(win, Rect(40,46, 160, 24)).value_(1.0.rand).action_({arg sl; synth.set(\amp, sl.value) });

  // a button to start and stop the synth. If the button value is 1 we start it, else stop it
  Button.new(win, Rect(220, 10, 60, 60)).states_([["create"], ["kill"]]).action_({arg butt;
    if(butt.value == 1, {
      // the synth is created with freq and amp values from the sliders
      synth = Synth(\simpleSynth, [\freq, freqsl.value*1000, \amp, ampsl.value]);
    },{
      synth.free;
    });
  });
)

s.boot


// -------------------------------------------------------
// Chapter 4 - Interfaces and Communication (GUI/MIDI/OSC)
// @TODO MIDI - Musical Instrument Digital Interface
// @TODO OSC - Open Sound Control
// @TODO GUI - Graphical User Interfaces
(
  w = Window("SC Window", Rect(400, 64, 650, 360)).front;
  EnvelopeView(w, Rect(20, 220, 200, 80))
  .drawLines_(true)
  .selectionColor_(Color.red)
  .drawRects_(true)
  .resize_(5)
  .action_({arg b; [b.index,b.value].postln})
  .thumbSize_(5)
  .value_([[0.0, 0.1, 0.5, 1.0],[0.1,1.0,0.8,0.0]]);
)




// —————————————————————————————————————————————————
// Part 2
// —————————————————————————————————————————————————
// ------------------------------
// Chapter 5 - Additive Synthesis
// we add 500 oscillators together and the CPU is less than 20%
{({SinOsc.ar(4444.4.rand, 0, 0.005)}!500).sum}.play
s.freeAll

{[SinOsc.ar(440), SinOsc.ar(440), SinOsc.ar(440)+SinOsc.ar(440)]}.plot
// try this as well
{a = SinOsc.ar(440, 0, 0.5); [a, a, a+a]}.plot

{[SinOsc.ar(440), SinOsc.ar(220), SinOsc.ar(440)+SinOsc.ar(220)]}.plot

{[SinOsc.ar(440), SinOsc.ar(440, pi), SinOsc.ar(440)+SinOsc.ar(440, pi)]}.plot

{SinOsc.ar(440, 0, 10).clip(-0.75, 0.75)}.scope
{SinOsc.ar(440, 0, 10).clip(-0.75, 0.75)}.plot
s.freeAll

{Mix.fill(10, {SinOsc.ar(rrand(200,2000), 0, 0.1)})}.freqscope

s.boot

{Saw.ar(880)}.freqscope

// adding two waves - the second is the octave (second harmonic) of the first
{(SinOsc.ar(440,0, 0.4) + SinOsc.ar(880, 0, 0.4))!2}.freqscope
s.freeAll

// here we add four harmonics (of equal amplitude) together
(
  {
    var freq = 200;
    SinOsc.ar(freq, 0, 0.2) +
    SinOsc.ar(freq*2, 0, 0.2) +
    SinOsc.ar(freq*3, 0, 0.2) +
    SinOsc.ar(freq*4, 0, 0.2)
    !2
  }.freqscope
)

s.freeAll
{Blip.ar(440, MouseX.kr(1, 20))}.scope // using the Mouse
{Blip.ar(440, MouseX.kr(1, 20))}.freqscope
{Blip.ar(440, Line.kr(1, 22, 3) )}.play

// Creating wave forms out of sinusoids

