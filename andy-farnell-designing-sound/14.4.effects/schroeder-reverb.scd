"../../_/19.12/14/01.scd".load;
s.boot;
s.quit;
s.plotTree;
Window.closeAll;

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

~groups = ();
~groups.root = Group.new(s);
~groups.sources = Group.new(~groups.root, \addToHead);
~groups.effects = Group.new(~groups.root, \addToTail);

~busses = ();
~busses.hardware = 0;
~busses.effects = Bus.audio(s, 1);
