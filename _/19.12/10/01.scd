Quarks.gui

Atk.createUserSupportDir;
Atk.openUserSupportDir;

// s.options.numOutputBusChannels = 10;
s.options.numOutputBusChannels = 4;

s.plotTree

s.boot;
s.reboot;
s.meter;
s.quit


(
  {
    var sig;
    sig = Saw.ar(freq: 440.0,  mul: 1.0,  add: 0.0);
    // sig = Decay.ar(Dust.ar(20), 0.01, WhiteNoise.ar(0.5));
    sig = FoaEncode.ar(sig, FoaEncoderMatrix.newOmni);
    sig = FoaZoom.ar(sig, MouseX.kr(0, pi / 2), LFSaw.kr(0.2, 0, pi));
    // sig = FoaDecode.ar(sig, FoaDecoderMatrix.newStereo());
    sig = FoaDecode.ar(sig, FoaDecoderMatrix.newPanto(8, 'point', 'dual'));
    Out.ar(0, sig);
  }.play;
)
s.freeAll

{Out.ar(0, SinOsc.ar(440))}.play
{Out.ar(1, SinOsc.ar(440))}.play
{Out.ar(2, SinOsc.ar(440))}.play
{Out.ar(3, SinOsc.ar(440))}.play
s.freeAll

(
  {
    var sig;
    sig = WhiteNoise.ar(1!8);
    sig = BPF.ar(sig, postln({exprand(100, 4000)}!8), 0.02);
    // sig = Decay.ar(Dust.ar(20), 0.01, WhiteNoise.ar(0.5));
    sig = FoaEncode.ar(sig, FoaEncoderMatrix.newOmni);
    sig = FoaZoom.ar(sig, MouseX.kr(0, pi / 2), LFSaw.kr(0.05, 0, 2pi));
    // sig = FoaDecode.ar(sig, FoaDecoderMatrix.newStereo());
    sig = FoaDecode.ar(sig, FoaDecoderMatrix.newPanto(4, 'point', 'dual'));
    Out.ar(0, sig * 4);
  }.play
)
s.freeAll

FoaXformDisplay.new(4);

~bus = Bus.audio(s, 8);
~bus.index

(
  {
    var sig;
    sig = In.ar(~bus, 8);
    // sig = Decay.ar(Dust.ar(20), 0.01, WhiteNoise.ar(0.5));
    // sig = FoaEncode.ar(sig, FoaEncoderMatrix.newOmni);

    // sig = FoaDecode.ar(sig, FoaDecoderMatrix.newPanto(2, 'point', 'dual'));
    sig = FoaDecode.ar(sig, FoaDecoderMatrix.newStereo());
    Out.ar(0, sig);
  }.play;
)
s.freeAll
