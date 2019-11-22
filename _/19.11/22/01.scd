(play{v=GVerb;o=SinOsc;p=Pulse;(v.ar(o.ar(TChoose.kr(p.kr(11/6),Scale.minor.ratios*p.kr(7/3,0.5,2,3)*110),0,p.kr(4/3))*p.ar(11/3),3,2)/8)+(v.ar(o.ar(110)*p.kr(0.2,0.2)).distort.softclip)})
s.freeAll
