/* SuperCollider Tutorial: 4. Envelopes and doneAction
 * https://youtu.be/-wDAPo9hpCg
 */

s.boot;
s.reboot;

x = {PinkNoise.ar * 0.5}.play;

x.free;

Server.local.plotTree;

(
  {
    var sig, env;
    env = Line.kr(1, 0, 1, doneAction: 2);
    sig = Pulse.ar(ExpRand(30, 500)) * env;
  }.play
)

s.freeAll;

(
  {
    var sig, env;
    env = XLine.kr(1, 0.01, 1, doneAction: 2);
    sig = Pulse.ar(ExpRand(30, 500)) * env;
  }.play
)

(
  {
    var sig, env;
    env = Line.kr(0, -40, 1, doneAction: 2);
    sig = Pulse.ar(ExpRand(30, 500)) * env.dbamp;
  }.play
)

0.5.ampdb;
20.dbamp;

(
  {
    var sig, freq, env;
    env = XLine.kr(1, 0.01, 1, doneAction: 0);
    freq = XLine.kr(880, 110, 3, doneAction: 2);
    sig = Pulse.ar(freq) * env;
  }.play
)

Env.new.plot

(
  Env.new(
    [0.01, 1, 0.2, 0.01],
    [0.5, 1, 2],
    \exp
  ).plot
)

(
  Env.new(
    [0, 1, 0.2, 0],
    [0.5, 1, 2],
    [3, -3, 0]
  ).plot
)

(
  Env.new(
    [0, 1, 0.2, 0],
    [0.5, 1, 2],
    [\sine, \sine, 0]
  ).plot
)

(
  {
    var sig, env;
    env = EnvGen.kr(
      Env.new(
        [0, 1, 0.2, 0],
        [0.05, 0.25, 0.25],
        [3, -3, 0]
      ), doneAction: 2);
    sig = Pulse.ar(ExpRand(30, 500)) * env;
  }.play
)

(
  Env.new(
    [0, 1, 0.2, 0],
    [0.01, 0.05, 0.5],
    [\sine, -3, 0]
  ).plot;
)

(
  x = {
    |t_gate = 1|
    var sig, env;
    env = EnvGen.kr(
      Env.new([0, 1, 0.2, 0], [0.05, 0.25, 0.25], [3, -3, 0]),
      t_gate,
      doneAction: 0
    );
    sig = Pulse.ar(LFPulse.kr(8).exprange(600, 900)) * env;
  }.play
)

x.set(\t_gate, 1);
x.set(\gate, 0);


(
  x = {|gate = 0|
    var sig, env;
    env = EnvGen.kr(Env.adsr, gate);
    sig = Pulse.ar(LFPulse.kr(8).exprange(600, 900)) * env;
  }.play
)

x.set(\gate, 1);
x.free;

Env.adsr.plot;

(
  x = {|gate = 0|
    var sig, freq, env;
    freq = EnvGen.kr(Env.adsr(1), gate, 200, 0.1);
    env = EnvGen.kr(Env.adsr, gate, doneAction: 2);
    sig = VarSaw.ar(SinOsc.kr(freq).range(500, 1000)) * env;
  }.play
)

x.set(\gate, 1);
x.set(\gate, -1);
x.free;
