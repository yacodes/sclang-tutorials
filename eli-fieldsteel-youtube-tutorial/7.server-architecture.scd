/* SuperCollider Tutorial: 7. Server Architecture
 * https://youtu.be/VGs_lMw2hQg
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

Nodes, Busses, Order of Execution

Node -> [Synth, Group]

// Monophonic signal
(
  SynthDef.new(\blip, {|out|
    var freq, trig, sig;
    freq = LFNoise0.kr(3).exprange(300, 1200).round(300);
    sig = SinOsc.ar(freq) * 0.25;
    trig = Dust.kr(2);
    sig = sig * EnvGen.kr(Env.perc(0.01, 0.2), trig);
    Out.ar(out, sig);
  }).add;

  SynthDef.new(\reverb, {|in, out = 0|
    var sig;
    sig = In.ar(in, 1);
    sig = FreeVerb.ar(sig, 0.5, 0.8, 0.2)!2;
    Out.ar(out, sig)
  }).add;
)

s.options.numAudioBusChannels;
s.options.numOutputBusChannels;
s.options.numInputBusChannels;

s.options.numOutputBusChannels = 2;
s.options.numInputBusChannels = 2;

y = Synth.new(\reverb, [\in, ~reverbBus]);
x = Synth.new(\blip, [\out, ~reverbBus]);
y.free
x.free

x.set(\out, 25);
y.set(\in, 25);

Bus
~reverbBus = Bus.audio(s, 1);
~reverbBus.index

// Multichannel
(
  SynthDef.new(\blip, {|out|
    var freq, trig, sig;
    freq = LFNoise0.kr(3).exprange(300, 1200).round(300);
    sig = SinOsc.ar(freq) * 0.25;
    trig = Dust.kr(2);
    sig = sig * EnvGen.kr(Env.perc(0.01, 0.2), trig);
    sig = Pan2.ar(sig, LFNoise1.kr(10));
    Out.ar(out, sig);
  }).add;

  SynthDef.new(\reverb, {|in, out = 0|
    var sig;
    sig = In.ar(in, 2);
    sig = FreeVerb.ar(sig, 0.5, 0.8, 0.2);
    Out.ar(out, sig)
  }).add;
)

y = Synth.new(\reverb, [\in, ~reverbBus]);
x = Synth.new(\blip, [\out, ~reverbBus]);
y.free
x.free

~reverbBus2 = Bus.audio(s, 2);
~reverbBus3 = Bus.audio(s, 1);

~reverbBus2.index;

y = Synth.new(\reverb, [\in, ~reverbBus2]);
x = Synth.new(\blip, [\out, ~reverbBus2]);
y.free
x.free

// Creating synths in reverse order
// Order of execution
x = Synth.new(\blip, [\out, ~reverbBus2]);
y = Synth.new(\reverb, [\in, ~reverbBus2]);

s.freeAll

g = Group.new
g.free

// Fix for order of execution
x = Synth.new(\blip, [\out, ~reverbBus2]);
y = Synth.new(\reverb, [\in, ~reverbBus2], s, \addToTail);
x.free
y.free

x = Synth.new(\blip, [\out, ~reverbBus2]);
y = Synth.new(\reverb, [\in, ~reverbBus2], x, \addAfter);
x.free
y.free

y = Synth.new(\reverb, [\in, ~reverbBus2]);
x = Synth.before(y, \blip, [\out, ~reverbBus2]);
x.free
y.free

// Creating groups
~srcGrp = Group.new
~fxGrp = Group.after(~srcGrp)
y = Synth.new(\reverb, [\in, ~reverbBus2], ~fxGrp);
x = Synth.new(\blip, [\out, ~reverbBus2], ~srcGrp);
x.free
y.free


(
  SynthDef.new(\blip, {|out, fund = 300, dens = 2, decay = 0.2|
    var freq, trig, sig;
    freq = LFNoise0.kr(3).exprange(fund, fund * 4).round(fund);
    sig = SinOsc.ar(freq) * 0.25;
    trig = Dust.kr(dens);
    sig = sig * EnvGen.kr(Env.perc(0.01, decay), trig);
    sig = Pan2.ar(sig, LFNoise1.kr(10));
    Out.ar(out, sig);
  }).add;

  SynthDef.new(\reverb, {|in, out = 0|
    var sig;
    sig = In.ar(in, 2);
    sig = FreeVerb.ar(sig, 0.5, 0.8, 0.2);
    Out.ar(out, sig)
  }).add;
)

(
  8.do {
    Synth.new(
      \blip,
      [
        \out, ~reverbBus2,
        \fund, exprand(60, 300).round(30)
      ],
      ~srcGrp
    )
  }
)

~fxGrp = Group.after(~srcGrp)
~fxGrp.free
y = Synth.new(\reverb, [\in, ~reverbBus2], ~fxGrp);
