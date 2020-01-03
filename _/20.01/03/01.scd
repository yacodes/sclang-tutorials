"../../19.12/14//01.scd".load;
s.boot;
s.quit;
s.plotTree;
Window.closeAll;
s.scope;

Platform.resourceDir()
PlayBufFree.generateSynthDef
Platform.userExtensionDir

(
  // Configuration
  ~config = (
    \channels: 8,
    \out: 0,
  );
  Server.default.options.inDevice = "SC140";
  Server.default.options.outDevice = "SC140";
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

// Final
play{t=Dust.kr(0.5);f=TRand.kr(20,440,t);g=SinOsc.ar([f,f+9],0,t);k=LocalIn.ar(2)*0.9;99.do{k=AllpassC.ar(k,0.01,Rand(0.001,0.01),0.5)};LocalOut.ar(k=k+g);(k*4).tanh;}
s.freeAll

(
  QtGUI.palette = QPalette.dark;
  ~gui = ();
  ~gui.width = 1024 / 2;
  ~gui.height = 576 / 2;
  ~gui[\bounds] = Rect(0, Window.screenBounds.height - ~gui.height, ~gui.width, ~gui.height);
  ~gui[\win] = Window.new("Channel strip", ~gui[\bounds], false, false);
  ~gui[\win].bounds = ~gui[\bounds];

  ~gui[\freqscope] = FreqScopeView(~gui[\win], Rect(0, 0, ~gui.width, ~gui.height));
  ~gui[\freqscope].background = Color(0, 0, 0, 1);
  ~gui[\freqscope].active_(true);
  ~gui[\freqscope].freqMode_(1);

  ~gui.text = StaticText(~gui.win, Rect(0, 0, ~gui.width, ~gui.height));
  ~gui.text.font = Font("Anonymous Pro", 16);
  ~gui.text.align = \topLeft;
  ~gui.text.background = Color(0, 0, 0, 0);
  ~gui.text.string = "play{t=Dust.kr(0.5);f=TRand.kr(20,440,t);g=SinOsc.ar([f,f+9],0,t);k=LocalIn.ar(2)*0.9;99.do{k=AllpassC.ar(k,0.01,Rand(0.001,0.01),0.5)};LocalOut.ar(k=k+g);k;}";

  ~gui[\win].onClose_({~gui[\freqscope].kill});
  ~gui[\win].view.background = Color(0, 0, 0, 1);
  ~gui[\win].alwaysOnTop = false;
  ~gui[\win].acceptsClickThrough = true;
  ~gui[\win].front;

  ~gui;
)
s.freeAll;
Window.closeAll;
{SinOsc.ar(440)}.play

10.collect{"10"}.toString
