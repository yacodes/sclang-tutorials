/* SuperCollider Tutorial: 3. Synth and SynthDef
 * https://youtu.be/LKGGWsXyiyo
 */

s.boot;
s.reboot;

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

(
  SynthDef.new(\sineTest, {
    arg noiseHz = 8;
    var freq, amp, sig;

    // freq = LFNoise0.kr(8, 400, 600);
    // freq = LFNoise0.kr(8).range(200, 1000);
    freq = LFNoise0.kr(noiseHz).exprange(200, 1000);
    amp = LFNoise1.kr(12).exprange(0.02, 1);
    sig = SinOsc.ar(freq) * amp;
    Out.ar(0, sig);
  }).add;
)

x = Synth.new(\sineTest, [\noiseHz, 32]);

x.set(\noiseHz, 4);

x.free;

(
  SynthDef.new(\pulseTest, {
    arg ampHz = 4, fund = 40, maxPartial = 4, width = 0.5;
    var amp1, amp2, freq1, freq2, sig1, sig2;
    amp1 = LFPulse.kr(ampHz, 0, 0.12) * 0.75;
    amp2 = LFPulse.kr(ampHz, 0.5, 0.12) * 0.75;
    freq1 = LFNoise0.kr(4).exprange(fund, fund * maxPartial).round(fund);
    freq2 = LFNoise0.kr(4).exprange(fund, fund * maxPartial).round(fund);
    freq1 = freq1 * LFPulse.kr(8, add: 1);
    freq2 = freq2 * LFPulse.kr(6, add: 1);
    sig1 = Pulse.ar(freq1, width, amp1);
    sig2 = Pulse.ar(freq2, width, amp2);
    sig1 = FreeVerb.ar(sig1, 0.7, 0.8, 0.25);
    sig2 = FreeVerb.ar(sig2, 0.7, 0.8, 0.25);
    Out.ar(0, sig1);
    Out.ar(1, sig2);
  }).add;
)

x = Synth.new(\pulseTest);
x.set(\width, 0.5, \maxPartial, 12, \fund, 40, \ampHz, 4);
x.free;

x = Synth.new(\pulseTest, [\maxPartial, 12, \fund, 48]);
