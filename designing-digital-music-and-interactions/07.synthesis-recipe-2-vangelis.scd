(
  s.quit;
  s.options.inDevice = "Scarlett 2i4 USB";
  s.options.outDevice = "Scarlett 2i4 USB";
  s.options.memSize = 262144;
  s.options.sampleRate = 44100;
  s.options.blockSize = 128;
  s.options.hardwareBufferSize = 128;
  s.options.numBuffers = 1024 * 256;
  s.options.memSize = 8192 * 32;
  s.options.maxNodes = 1024 * 32;
  s.boot;
)

FreqScope.new;
s.meter;

// Vangelis synth
