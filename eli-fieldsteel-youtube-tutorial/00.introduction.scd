/* SuperCollider Tutorial: 0. Introduction
 * https://youtu.be/yRzsOOiJ_p4
 */

2 + 2

s.boot;
s.reboot;
s.quit;

1000 / 100 + 324234

(
  var foo = 100;
  foo = foo.cubed;
  foo;
)

{SinOsc.ar(SinOsc.kr(440, 0, 100, 0), 0, 1, 0)}.play;

{PinkNoise.ar(440, 1, 1, 0)}.play;

{LFNoise0.ar(500, 1, 0)}.play
s.freeAll

{LFNoise0.ar(freq: 500, mul: 1, add: 0)}.play
