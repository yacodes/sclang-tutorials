(
  s.boot;
  s.meter;
  // FreqScope.new(512, 512);
  FreqScope.new(368, 256);
  s.scope;
)

s.boot

play{p=Pulse;GVerb.ar(IFFT(PV_BrickWall(FFT(Buffer.alloc(s,128),WhiteNoise.ar*p.ar(8,5e-4)+SinOsc.ar(9*p.ar(1),0,n=p.kr(p.ar(5)))),n)))}//w8
s.freeAll

play{
  a=SinOsc;
  p=Pulse;
  WhiteNoise.ar * p.kr(8, 0.01)
  +
  a.ar(98 * n = p.ar(4), 0, p.kr(2, add:1))
  +
  GVerb.ar(a.ar(99 * n) + p.ar(p.kr(3 * n)), 1, mul:0.1)
}// #sc140

({v=})

(
play{
  v=GVerb;o=SinOsc;p=Pulse;
  (v.ar(o.ar(TChoose.kr(p.kr(11/6),Scale.minor.ratios*p.kr(7/3,0.5,2,3)*110),0,p.kr(4/3))*p.ar(11/3),3,2)/8)
  +
  (v.ar(o.ar(110)*p.kr(0.2,0.2)).distort.softclip)
}
)

s.freeAll

({
 // WhiteNoise.ar * Pulse.kr(2, 0.01)

 (GVerb.ar(SinOsc.ar(TChoose.kr(Pulse.kr(11/6), Scale.minor.ratios*Pulse.kr(7/3,0.5,2,3)*110), 0, Pulse.kr(4/3)) * Pulse.ar(11/3), 3, 2) / 8)
 +
 (GVerb.ar(SinOsc.ar(110) * Pulse.kr(0.2, 0.2)).distort.softclip)

 // Pulse.kr(freq: 440.0,  width: 0.5,  mul: 1.0,  add: 0.0)

 // GVerb.ar(in: nil,  roomsize: 10,  revtime: 3,  damping: 0.5,  inputbw: 0.5,  spread: 15,  drylevel: 1,  earlyreflevel: 0.7,  taillevel: 0.5,  maxroomsize: 300,  mul: 1,  add: 0)
 // SinOsc.ar(freq: 440.0, phase: 0.0, mul: 1.0, add: 0.0)
}.play)
s.freeAll
s.boot

{GVerb.ar(SinOsc.ar(110) * Pulse.kr(0.2, 0.2)).distort}.play

GVerb.ar(in: nil,  roomsize: 10,  revtime: 3,  damping: 0.5,  inputbw: 0.5,  spread: 15,  drylevel: 1,  earlyreflevel: 0.7,  taillevel: 0.5,  maxroomsize: 300,  mul: 1,  add: 0)
Pulse.ar(freq: 440.0,  width: 0.5,  mul: 1.0,  add: 0.0)
s.freeAll

Scale.minor.ratios

play{p=Pulse;WhiteNoise.ar*p.ar(8,h=3e-3)+GVerb.ar(GrainSin.ar(2,p.ar(8),n=h*t=LFNoise0.ar,1/n),2)+PMOsc.ar(9*p.ar(4*t),111,p.kr(6,t,1,1))}
s.freeAll

play{a=SinOsc;p=Pulse;GVerb.ar(WhiteNoise.ar*p.ar(TChoose.kr(a.kr(2),[5,8,20,30]))*p.ar(16,0.1))+a.ar(97*p.ar(4),0,p.kr(5,add:1))}// #sc140
s.freeAll

play{GVerb.ar(IFFT(PV_BrickWall(FFT(Buffer.alloc(s,1024),WhiteNoise.ar*Pulse.ar(8,2e-2)),SinOsc.ar(Duty.kr(1,0,Dseq((10..19),inf))))))}
s.freeAll
