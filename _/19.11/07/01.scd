
(
  s.boot;
  s.meter;
  FreqScope.new(512, 512);
  s.scope;
)
{LFPulse.ar(1000)}.plot
LFPulse.kr.signalRange

play{Dust.ar(8)}
(
play{t=Dust.kr(2);DynKlank.ar(`[8.collect{|i|200*(i+2)*(i+2).log},8.collect{1},8.collect{TRand.kr(0,1,t)}],BrownNoise.ar(0.2))*Lag.kr(t,TRand.kr(1,5,t))!2*4}
)

// Final for publish
play{f=50;t=Dust.kr(4);GVerb.ar(Resonz.ar(LFSaw.ar(TChoose.kr(t,8.collect{|i|f*i}+f))*Lag.kr(t,TRand.kr(1,5,t)),TIRand.kr(f,f*16,t),0.1))*16}

(
  {
    f = 50;
    t = Dust.kr(4);
    GVerb.ar(
      Resonz.ar(
        LFSaw.ar(
          TChoose.kr(t, 8.collect{|i|f*i}+f)
        )
        *
        Lag.kr(
          t,
          TRand.kr(1, 5, t)
        ),
        TIRand.kr(f, f*16, t),
        0.1
      )
    ) * 16
  }.play
)

s.freeAll;

// Try Decay, TChoose, PMOsc, Ringz



s.freeAll

Env.perc().kr();

50.collect{|i|50*i}

10.collect{|i|50*i}

50.exp(10, 20)

2**2

s.freeAll

plot({ Decay.ar(Impulse.ar(1), 0.01) });

play({ Decay.ar(Impulse.ar(XLine.kr(1,50,20), 0.25), 0.2, PinkNoise.ar, 0) });

play{LFTri.ar(TRand.kr(220, 440, Dust.kr(2)))}

{ Formant.ar(XLine.kr(400,1000, 8), 2000, 800, 0.125) }.play

{ LFTri.ar(LFTri.kr(LFCub.kr(200,0,8,10),0, 400,800),0,0.1) }.play

{ LFTri.ar(LFTri.kr(200)) }.play

{ LFCub.ar(800,0,0.1) }.play

{ Ringz.ar(Dust.ar(3, 0.3), 2000, 2) }.play

(
play {
    DynKlang.ar(`[
        [800, 1000, 1200] + SinOsc.kr([2, 3, 4.2], 0, [13, 24, 12]),
        [0.3, 0.3, 0.3],
        [pi,pi,pi]
    ]
) * 0.1
};
)

5.collect{|i|200*(i+2)*(i+2).log}

(
b = Buffer.alloc(s, 512, 1, {arg buf; buf.sine1Msg(1.0/[1,2,3,4,5,6,7,8,9,10])});
{ COsc.ar(b.bufnum, 200, 0.7, 0.25) }.play;
)
s.freeAll

{ DynKlank.ar(`[[200, 671, 1153, 1723], nil, [1, 1, 1, 1]], PinkNoise.ar([0.007, 0.007])) }.play;

{SinOscFB.ar(440,MouseX.kr(0,4))*0.1}.play

// default initial params
{ HenonC.ar(MouseX.kr(20, SampleRate.ir)) * 0.2 !2}.scope(s);

{Out.ar(0,Brusselator.ar(Impulse.kr(MouseY.kr(1,50,'exponential')),MouseX.kr(0.01,1,'exponential')))}.play

(
{ LorenzL.ar(
    SampleRate.ir,
    LFNoise0.kr(1, 2, 10),
    LFNoise0.kr(1, 20, 38),
    LFNoise0.kr(1, 1.5, 2)
) * 0.2 }.play(s);
)

{ SinOsc.ar(Lag.ar(LorenzL.ar(MouseX.kr(1, 200)),3e-3)*800+900)*0.4 }.play(s);

{ LorenzL.ar(MouseX.kr(20, SampleRate.ir)) * 0.3 }.play(s);

{ RLPF.ar(PulseDPW.ar([100,250],0.5,0.1), XLine.kr(8000,400,5), 0.05) }.play;

{ PulseDPW.ar(XLine.kr(40,4000,6),0.1, 0.2) }.play;

(
// used to lag pitch
{
    SinOsc.ar(                              // sine wave
        // Lag.kr(                             // lag the modulator
            LFPulse.kr(4, 0, 0.5, 50, 400), // frequency modulator
            // Line.kr(0, 1, 15)               // modulate lag time
        // ),
        0,                                  // phase
        0.3                                 // sine amplitude
    )
}.play
)
s.freeAll

{LFPulse.kr(1).poll}.play  // 0's and 1's, half a second each (1Hz)
s.freeAll
{WhiteNoise.ar(LFPulse.kr(1))}.play
{WhiteNoise.ar(LFPulse.kr(freq: 1, width: 1/10))}.play // note dur is 1/10 of the beat (very "staccato")
{WhiteNoise.ar(LFPulse.kr(freq: 1, width: 0.9))}.play // note dur is 9/10 of the beat ("non legato")
{WhiteNoise.ar(LFPulse.kr(4))}.play              // standard staccato (width default = 0.5)
{WhiteNoise.ar(LFPulse.kr(4, width: 0.05))}.play // much more staccato, "hi-hat"

{LFPulse.kr(1, mul: 1/4, add: 0.05).poll(2, label: "out")}.play // outputs 0.05 and 0.3 for half a second each

{WhiteNoise.ar(LFPulse.kr(4, width: LFPulse.kr(1, mul: 1/4, add: 0.05)))}.play
s.freeAll

play{LFCub.ar(LFSaw.kr(LFPulse.kr(1/4,1/4,1/4)*2+2,1,-20,50))+(WhiteNoise.ar(LFPulse.kr(4,0,LFPulse.kr(1,3/4)/4+0.05))/8)!2}

{WhiteNoise.ar(LFPulse.kr(4,0,LFPulse.kr(1,3/4)/4+0.05))/8}.play

{WhiteNoise.ar(LFPulse.kr(4, width: LFPulse.kr(1, iphase: 3/4, mul: 1/4, add: 0.05)))}.play


s.boot

play{t=GaussTrig.ar(0.5);r=TRand.ar(0,1,t);e=EnvGen.ar(Env.sine(r*0.2+0.3),t);Pan2.ar(Gendy1.ar(minfreq:(r*3+1+(e*3))*300)*e,2*r-1)}
s.freeAll

play{n=rrand(20,70);Pulse.ar(({rrand(0.2,n)}*Lag.kr(Dust.kr(n.pow(3)!2).exprange(1,10),0.4))!n,{rand(pi)}!n,n.reciprocal).sum}

play{a=LFSaw;a.ar((b=a.ar(1/3))+1**a.ar(b)*(99+c=[0,1]))%a.ar(b*99,c)%a.ar(1/32)+a.ar(a.ar(b)*4e4%2e3,0,a.ar(6,c)>0.9/2)/2}

{((SmoothDecimator.ar(Saw.ar([4e3,4054],0,0.2),LFTri.kr(0.01,1e3,1e3).abs)**Saw.ar(400))**Saw.ar(2e3)).clip(-0.5,0.5)}.play //11/29/12 - broken atari

// This is the tweet rewritten in a longer, more "readable" way:
(
{LocalOut.ar(
  a = CombN.ar(
	  in: BPF.ar(in: LocalIn.ar(2)*7.5 + Saw.ar([32,33], 0.2), // BPF in
		     freq: LFNoise0.kr(4/3).exprange(18.75, 4800), // BPF freq
		     rq: 0.1				           // BPF rq
		    ).distort,					   // distort BPF
	  maxdelaytime:	2,	// CombN max delay time
	  delaytime: 2,		// CombN delay time
	  decaytime: 40)	// CombN decay time
	    ); // end of LocalOut parentheses
  a; // last thing to be returned, ie., it gets played
}.play
)

{CombN.ar(BPF.ar(Saw.ar([32,33],0.2),2**LFNoise0.kr(4/3,4)*300,0.1).distort,2,2,40)}.play
s.boot;
s.freeAll;

{LocalOut.ar(a=CombN.ar(BPF.ar(LocalIn.ar(2)*7.5+Saw.ar([32,33],0.2),2**LFNoise0.kr(4/3,4)*300,0.1).distort,2,2,40));a}.play


play{GVerb.ar(VarSaw.ar(Duty.ar(1/5,0,Dseq(x=[[4,4.5],[2,3,5,6]];flat(x*.x allTuples(x*.x x)*4).clump(2))),0,0.9)*LFPulse.ar(5),99,5)/5}
s.freeAll

{k=LFNoise1.kr(8.0.rand+2,0.5,0.5);SinOsc.ar([[333,444],[222,555]]*(k+(rrand(1.0,5.0))),0,k).sum.cubed * 0.1}.play

{x=Array.fill(5,{[0.00001,0.03].asSpec.map(LFNoise2.kr(3))});Splay.ar(Friction.ar(LFTri.ar(50),friction:x,mass:x*30000))}.play

{ LFTri.ar(40) }.plot(0.1);

{ LFTri.ar(XLine.kr(1, 800, 0.1)) }.plot(0.1);

play{p=Pulse;GVerb.ar(IFFT(PV_BrickWall(FFT(Buffer.alloc(s,128),WhiteNoise.ar*p.ar(8,5e-4)+SinOsc.ar(9*p.ar(1),0,n=p.kr(p.ar(5)))),n)))}//w8
s.freeAll;
//2.
