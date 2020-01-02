"../../19.12/14//01.scd".load;
s.boot;
s.quit;
s.plotTree;
Window.closeAll;
s.scope;

(
  // Configuration
  ~config = (
    \channels: 8,
    \out: 0,
  );
  Server.default.options.inDevice = "Scarlett 2i4 USB";
  Server.default.options.outDevice = "Scarlett 2i4 USB";
  Server.default.options.sampleRate = 44100;
  Server.default.options.blockSize = 2**9;
  Server.default.options.hardwareBufferSize = 2**9;
  Server.default.options.numBuffers = 2**18;
  Server.default.options.memSize = 2**18;
  Server.default.options.maxNodes = 2**18;
  Server.default.options.numOutputBusChannels = ~config.channels;
  Server.default.options.numInputBusChannels = 2;

  Server.default.waitForBoot({
    "Server booted".postln;
  });
)

play{t=Dust.kr(2,0.2);l=TRand.kr(40,200,t);LocalOut.ar(f=LocalIn.ar(2);f=9.collect{f=AllpassC.ar(f*0.9,0.01,Rand(0.001, 0.01),0.5)}.last+Saw.ar([l,l+9],t));f;}
s.freeAll


(
play{t=Dust.kr(0.5);f=TRand.kr(20,440,t);g=SinOsc.ar([f,f+9],0,t);k=LocalIn.ar(2)*0.9;99.do{k=AllpassC.ar(k,0.01,Rand(0.001,0.01),0.5)};LocalOut.ar(k=k+g);k;}
)


(
  play{
    ~trig = Dust.kr(1);
    ~f = TRand.kr(40, 440, ~trig);
    ~sig = SinOsc.ar([~f, ~f+9], 0, ~trig);
    ~fb = LocalIn.ar(2) * 0.9;
    64.do{~fb = AllpassC.ar(~fb, 0.01, Rand(0.001, 0.01), 0.5)};
    // ~fb = OnePole.ar(~fb, 0.1);
    ~fb = ~fb + ~sig;
    // ~fb = LeakDC.ar(~fb);
    LocalOut.ar(~fb);
    ~fb;
    // GVerb.ar(~fb).tanh;
  }
)
s.freeAll
Dust.kr(density: 0.0,  mul: 1.0,  add: 0.0)

LFNoise0.kr(freq: 500.0,  mul: 1.0,  add: 0.0)
LFPulse.ar(freq: 440.0,  iphase: 0.0,  width: 0.5,  mul: 1.0,  add: 0.0)
