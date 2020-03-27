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

s.boot


(
Ndef(\verb, {	
	var input, output, delrd, sig, deltimes;
	
	// Choose which sort of input you want by (un)commenting these lines:
	input = Pan2.ar(PlayBuf.ar(1, b, loop: 0), -0.5); // buffer playback, panned halfway left
	//input = SoundIn.ar([0,1]); // TAKE CARE of feedback - use headphones
	//input = Dust2.ar([0.1, 0.01]); // Occasional clicks
	
	// Read our 4-channel delayed signals back from the feedback loop
	delrd = LocalIn.ar(4);
	
	// This will be our eventual output, which will also be recirculated
	output = input + delrd[[0,1]];
	
	sig = output ++ delrd[[2,3]];
	// Cross-fertilise the four delay lines with each other:
	sig = ([ [1, 1, 1, 1],
	 [1, -1, 1, -1],
	 [1, 1, -1, -1],
	 [1, -1, -1, 1]] * sig).sum;
	// Attenutate the delayed signals so they decay:
	sig = sig * [0.4, 0.37, 0.333, 0.3];
	
	// Here we give delay times in milliseconds, convert to seconds,
	// then compensate with ControlDur for the one-block delay
	// which is always introduced when using the LocalIn/Out fdbk loop
	deltimes = [101, 143, 165, 177] * 0.001 - ControlDur.ir;
	
	// Apply the delays and send the signals into the feedback loop
	LocalOut.ar(DelayC.ar(sig, deltimes, deltimes));
	
	// Now let's hear it:
	output
	
}).play
)

// To stop it:
Ndef(\verb).free;