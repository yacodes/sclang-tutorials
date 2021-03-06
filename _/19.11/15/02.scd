s.boot


{RLPFD.ar(Pulse.ar([40, 42]), LFNoise0.kr(4/3).range(18.75, 4800).poll(4/3, label: "bpf-freq"), 1, 0.5)}.play

{RLPFD.ar(Pulse.ar([40, 42]), 2**LFNoise0.kr(4/3,3)*300, 1, 1).distort}.play
{MoogFF.ar(Pulse.ar([40, 42])*0.01, 2**LFNoise0.kr(4/3,4)*512, 1)}.play
{BPF.ar(Pulse.ar([40, 42])*0.1, 2**LFNoise0.kr(4/3,4)*512, 1)}.play

{Impulse.ar(4/3)}.play
s.freeAll

{WhiteNoise.ar(LFPulse.kr(4))}.play
{WhiteNoise.ar(LFPulse.kr(4, width: 0.05))}.play
{WhiteNoise.ar(LFPulse.kr(4, width: LFPulse.kr(1, iphase: 3/4, mul: 1/4, add: 0.05)))}.play
s.freeAll

{LFNoise0.ar(8).poll}.play
s.freeAll

{BBandPass.ar(Pulse.ar([40, 41])*0.1, 2**LFNoise0.kr(11/7,4)*512, 1)}.play
s.freeAll

{ RLPF.ar(CombL.ar(Decay.ar(Impulse.ar(2), 0.1, BrownNoise.ar), 0.02, 100.reciprocal, 3), 400, 1)!2 }.play
s.freeAll

play{a=Dust.ar(3);GVerb.ar(BPF.ar(Decay.ar(a,TRand.ar(0.1,0.7,a),BrownNoise.ar),2**LFNoise0.kr(4/3,3)*1024)).distort!2}
s.freeAll

// Hydra
// osc(100, 0.001, 0.5)
//   .rotate(0, 0.1)
//   .mult(osc(10, 0.1).modulate(osc(10, 0.02).rotate(0, -0.1), 1))
//   .color(() => a.fft[0], () => a.fft[1], () => a.fft[2])
//   .contrast(() => (a.fft[3] + 1) * 5)
//   .out(o0)

// osc(2**3, 0.05, 0.1)
//   .thresh(() => a.fft[0], 0.35)
//   .rotate(180, 0.1)
//   .diff(osc(2**4, 0.05, 0.1).modulateRotate(osc(2**5, 0.001), 2))
//   .rotate(45, 0.025)
//   .contrast(() => 1/a.fft[1])
//   .out(o0)

2**(-4)*512 // Evaluate this: if LFNoise0 outputs its lowest -4, result is 18.75
2**(0)*512  // Evaluate this: if LFNoise0 outputs its middle value 0, the result is 300
2**(4)*1024  // Evaluate this: if LFNoise0 outputs its highest +4, result is 4800
