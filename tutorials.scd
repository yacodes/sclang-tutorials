Server.local.boot;
Server.local.quit;
Server.local.reboot;

(
  {Pan2.ar(Mix(SinOsc.ar([400,660],0,0.1)),MouseX.kr(-1,1))}.scope

  {Resonz.ar(LFNoise0.ar(400),XLine.kr(10000,1000,10),0.1)}.scope

  {Pan2.ar(WhiteNoise.ar(0.1), MouseX.kr(-1,1))}.scope

  {Mix(SinOsc.ar([400,660],0,0.1))}.scope
)

(
  {
    var n = 20;
    var wave = Mix.fill(n, {|i|
      var mult = ((-1) ** i) * (0.5 / ((i + 1)));
      SinOsc.ar(440 * (i + 1)) * mult;
    });
    Pan2.ar(wave / n, 0.0); //stereo, panned centre
  }.scope;
)

{Mix(SinOsc.ar(500*[0.5,1,1.19,1.56,2,2.51,2.66,3.01,4.1],0,0.1))}.scope

{Mix(SinOsc.ar(500*[0.5,1,1.19,1.56,2,2.51,2.66,3.01,4.1],0,0.1*[0.25,1,0.8,0.5,0.9,0.4,0.3,0.6,0.1]))}.scope

FreqScope.new

(
  var n = 10;
  {Mix(SinOsc.ar(250 * (1..n), 0, 1 / n))}.scope;
)

(1..10)
