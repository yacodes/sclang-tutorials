(
  SynthDef(\wtf, {

  });
  play{
    v=GVerb;
    o=SinOsc;
    p=Pulse;
    ~signal = (v.ar(o.ar(TChoose.kr(p.kr(3/4),Scale.minor.ratios*p.kr(7/3,0.5,2,3)*110),0,p.kr(11/3))*p.ar(7/3),3,2)/8);
    ~signal = ~signal + (v.ar(o.ar(110)*p.kr(0.2,0.2)));
    ~signal = ~signal * (-24).dbamp;
    ~chain = FFT(LocalBuf(2048), ~signal);
    ~chain = PV_BrickWall(~chain, 0);
    ~chain = IFFT(~chain)!2;
    FreeVerb.ar(
      Mix(DelayN.ar(~chain, maxdelaytime: 1, delaytime: 1,  mul: 1.0,  add: 0.0)!16).tanh * (-6).dbamp,
      LFNoise1.ar(8).exprange(0.1, 1),
      LFNoise1.ar(6).exprange(0.1, 1),
      0.5
    );
  }
)
s.freeAll
