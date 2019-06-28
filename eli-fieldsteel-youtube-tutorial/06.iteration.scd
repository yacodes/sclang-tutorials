/* SuperCollider Tutorial: 6. Iteration
 * https://youtu.be/bMGXYEg1gJo
 */

(
  Server.local.boot;
  Server.local.scope;
  FreqScope.new;
  Server.local.plotTree;
  Server.local.meter;
)

[6, 4, 0.5, 10, 7].do {"hello".postln}

(
  [6, 4, 0.5, 10, 7].do {|item, count|
    [count, item.squared].postln
  }
)

(
  x = Array.newClear(5);
  [6, 4, 0.5, 10, 7].do {|item, count|
    x[count] = item.squared;
  }
)

(
  z = [6, 4, 0.5, 10, 7].do {|item, count|
    item.squared;
  }
)

z = [6, 4, 0.5, 10, 7].do {_.squared}

5.do {|item| item.postln}
[0, 1, 2, 3, 4].do {|item| item.postln}

x = {VarSaw.ar(40!2, 0, 0.05)}.play;
x.free;

(
  SynthDef.new(\iter, {
    var temp, sum;
    sum = 0;

    10.do {
      temp = VarSaw.ar(
        40 * {Rand(0.99, 1.02)}!2,
        {Rand(0.0, 1.0)}!2,
        {ExpRand(0.005, 0.05)}!2
      );
      sum = sum + temp;
    };

    sum = sum * 0.05;
    Out.ar(0, sum);
  }).add
)

x = Synth.new(\iter);
x.free;

(
  SynthDef.new(\iter, {|freq = 40|
    var temp, sum, env;
    sum = 0;

    env = EnvGen.kr(
      Env.perc(0.01, 5, 1, -2),
      doneAction: 2
    );

    10.do {
      temp = VarSaw.ar(
        freq * {Rand(0.99, 1.02)}!2,
        {Rand(0.0, 1.0)}!2,
        {ExpRand(0.005, 0.05)}!2
      );
      sum = sum + temp;
    };

    sum = sum * 0.05 * env;
    Out.ar(0, sum);
  }).add
)
Env.perc(0.01, 5, 1, -2).plot;

x = Synth.new(\iter);
x = Synth.new(\iter, [\freq, 55]);
x.free;

x = Synth.new(\iter, [\freq, 64.midicps]);

(
  [53, 59, 63, 68].do {|midinote|
    Synth.new(\iter, [\freq, midinote.midicps]);
  }
)

(
  SynthDef.new(\iter2, {|freq = 200, dev = 1.02|
    var temp, sum;
    sum = 10.collect {|i|
      SinOsc.ar(freq * (i + 1) * LFNoise1.kr({Rand(0.05, 0.2)}!2).range(1.02.reciprocal, dev)) *
        LFNoise1.kr({Rand(0.5, 8)}!2).exprange(0.01, 1)
    }.sum;
    sum = sum * 0.05;
    Out.ar(0, sum);
  }).add;
)

x = Synth.new(\iter2);
x.set(\freq, 80);
x.set(\freq, 100);
x.set(\freq, 120);
x.set(\freq, 140);
x.set(\dev, 1.02);
x = {Blip.ar(200, 10, 0.5)}.play;
x.free;
s.freeAll;

1.02.reciprocal;

Array.fill(100, 0);

1.inspect;
