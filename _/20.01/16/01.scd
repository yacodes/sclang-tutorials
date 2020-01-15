
(
  ~config = (
    device: "TC",
    channels: 2,
  );
  Server.default.options.inDevice = ~config.device;
  Server.default.options.outDevice = ~config.device;
  Server.default.options.sampleRate = 44100;
  Server.default.options.blockSize = 2**9;
  Server.default.options.hardwareBufferSize = 2**9;
  Server.default.options.numBuffers = 2**20;
  Server.default.options.memSize = 2**20;
  Server.default.options.maxNodes = 2**20;
  Server.default.options.numOutputBusChannels = ~config.channels;
  Server.default.options.numInputBusChannels = 0;

  Server.default.waitForBoot({
    "../../19.12/14//01.scd".load;
  });
)

{SinOsc.ar}.play

(
  play{t=LFPulse.kr(LFNoise1.kr(4,1,1),0,0.1);i=LocalIn.ar(2);a=OneZero.ar((OnePole.ar(Saw.ar(TExpRand.kr(80,2200,t),Decay.kr(t,0.2),Wrap.ar(i)),0.9)+i)/2);LocalOut.ar(FreeVerb.ar(a,0.1));AllpassC.ar(HPF.ar(a,20));}
)
(-6.dbamp)
s.freeAll
7.wrap2

LFN

play{p=PinkNoise.ar(1!2);BRF.ar(p+Blip.ar(p+2,400),150,2,0.1)+LPF.ar(FreeVerb2.ar(*LPF.ar(p+0.2*Dust.ar(0.1),60)++[1,1,0.2,1e4]).tanh,2000)}
s.freeAll
LFNoise2.ar.signalRange
