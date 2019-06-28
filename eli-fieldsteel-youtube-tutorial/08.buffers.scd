/* SuperCollider Tutorial: 8. Buffers
 * https://youtu.be/_GZmuvmgtUc
 */

s.boot;
s.quit;
s.reboot;

(
  s.waitForBoot {
    s.plotTree;
    s.meter;
  };
)

~b1 = Buffer.read(s, "/Users/canvaskisa/Work/Algorave/samples/k/k0.wav");

~b1.play;

~b1.zero;

~b1.read("/Users/canvaskisa/Work/Algorave/samples/k/k0.wav");

~b1.free

Buffer.freeAll


~b0 = Buffer.read(s, "/Users/canvaskisa/Work/Algorave/samples/k/k0.wav");
~b1 = Buffer.read(s, "/Users/canvaskisa/Work/Algorave/samples/k/k1.wav");
~b2 = Buffer.read(s, "/Users/canvaskisa/Work/Algorave/samples/k/k2.wav");
~b3 = Buffer.read(s, "/Users/canvaskisa/Work/Algorave/samples/bss/bss0.wav");

~b0.play
~b1.play
~b2.play
~b3.play

// Frames
~b0.numFrames
~b1.numFrames

// Channels
~b0.numChannels
~b1.numChannels
numSamples = numFrames * numChannels

// Getting only one channel
~b4 = Buffer.readChannel(s, "/Users/canvaskisa/Work/Algorave/samples/bss/bss0.wav", channels: [1]);
~b4.play

// Duration
~b4.duration;

// Buffer numbers (bufnums)
~b0.bufnum;
~b1.bufnum;
~b2.bufnum;
~b3.bufnum;

// Buffer sample rate
~b0.sampleRate;
~b1.sampleRate;
~b2.sampleRate;
~b3.sampleRate;
s.sampleRate;

// Summary
~b0.query;



~b3.play

~b3Part0 = Buffer.read(s, "/Users/canvaskisa/Work/Algorave/samples/bss/bss0.wav", 0, s.sampleRate / 2);
~b3Part0.play;

~b3.numFrames;

(
  ~b3Part1 = Buffer.read(
    s,
    "/Users/canvaskisa/Work/Algorave/samples/bss/bss0.wav",
    10000,
    ~b3.numFrames - 10001
  )
)
~b3Part1.play


// Load files at once
~kicks = Array.new;
~folder = PathName.new("/Users/canvaskisa/Work/Algorave/samples/k");

(
  ~folder.entries.do {|path|
    ~kicks = ~kicks.add(Buffer.read(s, path.fullPath));
  }
)

~kicks.at(0).play;
~kicks[0].play;

// Max buffers
s.options.numBuffers;


// PlayBuf + BufRead
(
  SynthDef.new(\playbuf_test, {|amp = 1, out = 0, buf, rate = 1, da = 2|
    var sig;
    sig = PlayBuf.ar(2, buf, rate, doneAction: da);
    sig = sig * amp;
    Out.ar(out, sig);
  }).add;
)

Synth.new(\playbuf_test, [\buf, ~b0.bufnum, \rate, 0.25]);

s.plotTree;
s.freeAll;

// Playing buffers with other than servers samplerate with BufRateScale
(
  SynthDef.new(\playbuf_test, {|amp = 1, out = 0, buf, rate = 1, da = 2|
    var sig;
    sig = PlayBuf.ar(2, buf, BufRateScale.kr(buf) * rate, doneAction: da);
    sig = sig * amp;
    Out.ar(out, sig);
  }).add;
)

Synth.new(\playbuf_test, [\buf, ~b0.bufnum, \rate, 1.7]);

// Buffers trigger and startPos
(
  SynthDef.new(\playbuf_test, {|amp = 1, loop = 0, out = 0, buf, rate = 1, da = 2, t_trig = 1, start = 0|
    var sig;
    sig = PlayBuf.ar(2, buf, BufRateScale.kr(buf) * rate, t_trig, start, loop, doneAction: da);
    sig = sig * amp;
    Out.ar(out, sig);
  }).add;
)

x = Synth.new(\playbuf_test, [\buf, ~b3.bufnum, \loop, 1]);
x.set(\t_trig, 1);
x.free;

x = Synth.new(\playbuf_test, [\buf, ~b3.bufnum, \rate, -1, \start, ~b3.numFrames - 2]);

12.midiratio
-12.midiratio
7.midiratio

x = Synth.new(\playbuf_test, [\buf, ~b3.bufnum, \rate, 7.midiratio]);
x = Synth.new(\playbuf_test, [\buf, ~b3.bufnum, \rate, 5.midiratio]);
x = Synth.new(\playbuf_test, [\buf, ~b3.bufnum, \rate, 10.midiratio]);
x = Synth.new(\playbuf_test, [\buf, ~b3.bufnum, \rate, 12.midiratio]);


g = Group.new

(
  x = Synth.new(\playbuf_test, [
    \buf, ~b0.bufnum,
    \rate, 1.5,
    \loop, 1,
    \amp, 0.5
  ], g);
  y = Synth.new(\playbuf_test, [
    \buf, ~b0.bufnum,
    \rate, 1.2,
    \loop, 1,
    \amp, 0.5
  ], g);
  z = Synth.new(\playbuf_test, [
    \buf, ~b0.bufnum,
    \rate, 2.1,
    \loop, 1,
    \amp, 0.5
  ], g);
)

g.freeAll

g.set(\rate, 0.8);
g.set(\buf, ~b1.bufnum);

z.set(\rate, exprand(0.2, 2.0));

g.set(\loop, 0);
g.free


// BufRead
(
  SynthDef.new(\bufread_test, {
    arg amp = 1, out = 0, buf, start, end;
    var sig, ptr;
    ptr = Line.ar(start, end, BufDur.kr(buf), doneAction: 2);
    sig = BufRd.ar(2, buf, ptr);
    sig = sig * amp;
    Out.ar(out, sig);
  }).add;
)

Synth.new(\bufread_test, [
  \buf, ~b0.bufnum,
  \end, 0,
  \start, ~b0.numFrames - 1
]);


// Loop via Phasor
(
  SynthDef.new(\bufread_test, {
    arg amp = 1, out = 0, buf, start, end, rate = 1;
    var sig, ptr;
    ptr = Phasor.ar(0, BufRateScale.kr(buf) * rate, start, end);
    sig = BufRd.ar(2, buf, ptr);
    sig = sig * amp;
    Out.ar(out, sig);
  }).add;
)

x = Synth.new(\bufread_test, [
  \buf, ~b0.bufnum,
  \start, 0,
  \end, ~b0.numFrames - 1
]);

x.set(\rate, -5.midiratio);
x.free

s.freeAll

// Loop via SinOsc
(
  SynthDef.new(\bufread_test, {
    arg amp = 1, out = 0, buf, start, end, freq = 1;
    var sig, ptr;
    ptr = SinOsc.ar(freq, 3pi / 2).range(start, end);
    sig = BufRd.ar(2, buf, ptr);
    sig = sig * amp;
    Out.ar(out, sig);
  }).add;
)

x = Synth.new(\bufread_test, [
  \buf, ~b0.bufnum,
  \start, 0,
  \end, ~b0.numFrames - 1,
  \freq, 0.4
]);

x.set(\freq, -1)
s.freeAll

// Loop via LFDNoise1
(
  SynthDef.new(\bufread_noise, {
    arg amp = 1, out = 0, buf, start, end, freq = 1;
    var sig, ptr;
    ptr = LFDNoise1.ar(freq).range(start, end);
    sig = BufRd.ar(2, buf, ptr);
    sig = sig * amp;
    Out.ar(out, sig);
  }).add;
)

x = Synth.new(\bufread_noise, [
  \buf, ~b0.bufnum,
  \start, 0,
  \end, ~b0.numFrames - 1,
  \freq, 0.4
]);

x.set(\freq, 4);
x.free
