/* SuperCollider Tutorial: 2. Making Sound
 * https://youtu.be/oTBcGPXH6K0
 */
Server.local.boot;

s;

s.boot;
s.reboot;
s.quit;

x = {SinOsc.ar}.play;
x.free;

x = {SinOsc.ar(700, 0, 0.125, 0)}.play;
x = {SinOsc.ar(700, mul: 0.125)}.play;
x = {SinOsc.ar(700) * 0.125}.play;

(
  z = {
    arg freq = 440, amp = 1;

    var sig;
    sig = SinOsc.ar(freq) * amp;
  }.play;
)

z.set(\freq, 330);
z.set(\amp, 0.5);
z.set(\freq, 550, \amp, 0.25);
z.free;

(
  z = {
    arg noiseHz = 8;
    var freq, amp, sig;

    // freq = LFNoise0.kr(8, 400, 600);
    // freq = LFNoise0.kr(8).range(200, 1000);
    freq = LFNoise0.kr(noiseHz).exprange(200, 1000);
    amp = LFNoise1.kr(12).exprange(0.02, 1);
    sig = SinOsc.ar(freq) * amp;
  }.play
)
z.set(\noiseHz, 8);
z.set(\noiseHz, exprand(4, 64));
z.free;
