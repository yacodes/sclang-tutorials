// Systematic Sabbats
//
// Composed for Russian Sound Art Showcase in BERLIN 2020 LIMINAL (in frames of CTM Vorspiel)
// by Aleksandr Yakunichev on 2020-01-12
//
// MIT License
//
// Copyright (c) 2020 Aleksandr Yakunichev
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

(
  // Configuration
  var channels = 8; // Change to whatever number of channels you have/like
  ~busses = (
    audio: Bus.audio(s, channels),
    hardware: 0,
  );
  ~config = (
    \device: "CTM", // Change to your output device
    \channels: channels,
    \out: ~busses.audio,
    \tempo: 80/60,
  );
  ~clock = TempoClock.new(~config.tempo);
  ~routine = nil;

  // Helpers
  ~go = { |cycles, func| cycles.do({ |i| func.value((i+1)/cycles) }) };

  // Configure and run audio server
  Server.default.options.inDevice = ~config.device;
  Server.default.options.outDevice = ~config.device;
  Server.default.options.sampleRate = 44100;
  Server.default.options.blockSize = 2**9;
  Server.default.options.hardwareBufferSize = 2**9;
  Server.default.options.numBuffers = 2**20;
  Server.default.options.memSize = 2**20;
  Server.default.options.maxNodes = 2**20;
  Server.default.options.numOutputBusChannels = ~config.channels;
  Server.default.options.numInputBusChannels = 0; // We do not need inputs here

  Server.default.waitForBoot({
    s.prepareForRecord(numChannels: ~config.channels);
    s.sync;
    // Initialize synthdefs
    SynthDef(\pad, {
      | att = 2, sus = 0, rel = 3,
        freq = 440, detune = 0.2,
        ffmin = 500, ffmax = 2000,
        rqmin = 0.1, rqmax = 0.2,
        ffhzmin = 0.1, ffhzmax = 0.3,
        lsf = 200, ldb = 0,
        amp = 1, pan = 0, out = 0 |
      var source, envelope;

      envelope = EnvGen.kr(
        Env([0, 1, 1, 0], [att, sus, rel], [1, 0, -1]),
        doneAction: Done.freeSelf,
      );

      source = Saw.ar(freq * {LFNoise1.kr(0.5, detune).midiratio}!2);
      source = Resonz.ar(
        source,
        {LFNoise1.kr(
          LFNoise1.kr(4).exprange(ffhzmin, ffhzmax),
        ).exprange(ffmin, ffmax)}!2,
        {LFNoise1.kr(0.1).exprange(rqmin, rqmax)}!2,
      );
      source = BLowShelf.ar(source, lsf, 0.5, ldb);
      source = FreeVerb.ar(source, 0.5, 1, 1);

      source = FoaEncode.ar(source, FoaEncoderMatrix.newOmni);
      source = FoaZoom.ar(source, pan.linlin(0, 1, -pi/2, pi/2), LFNoise1.kr(0.01, 0, 2pi));
      source = FoaDecode.ar(source, FoaDecoderMatrix.newPanto(~config.channels, \point, \dual));
      source = source * envelope * (amp/(2/~config.channels));

      source = Limiter.ar(source, 0.5);
      OffsetOut.ar(out, source);
    }).add;

    SynthDef(\perc, {
      | freq = 220,
        atk = 0.01, rel = 1,
        pan = 0, amp = 0.1, out = 0 |
      var envelope, source, feedback;

      source = Saw.ar(freq * {LFNoise1.kr(0.5, 1).midiratio}!2);
      2.do({|i| source = AllpassC.ar(source, 0.08, Rand(0.001, 0.08), 1)});
      envelope = EnvGen.ar(Env.perc(atk, rel), doneAction: Done.freeSelf);

      feedback = LocalIn.ar(2) * 0.99;
      feedback = OnePole.ar(feedback, 0.75);
      feedback = source + feedback;
      feedback = LeakDC.ar(feedback);
      LocalOut.ar(feedback);
      feedback = FreeVerb.ar(feedback, 1) * 6;
      feedback = LeakDC.ar(feedback);

      feedback = FoaEncode.ar(feedback, FoaEncoderMatrix.newOmni);
      feedback = FoaPush.ar(feedback, pan.linlin(0, 1, -pi/2, pi/2), LFNoise1.kr(0.01, 0, 2pi));
      feedback = FoaDecode.ar(feedback, FoaDecoderMatrix.newPanto(~config.channels, \point, \dual));
      feedback = feedback * envelope * (amp/(2/~config.channels));
      feedback = Limiter.ar(feedback, 0.5);
      OffsetOut.ar(out, feedback);
    }).add;

    SynthDef(\kick, {
      | freq = 45,
        atk = 0.002, sus = 0.5,
        sweep = 0.3, sweepDur = 0.9,
        noise = 0.1, overdrive = 0,
        amp = 1, pan = 0, out = 0 |
      var freqEnv, source, env;

      freqEnv = EnvGen.ar(Env.perc(atk, Clip.ir(sus * sweepDur, 0, sus), sweep * freq, -4));
      freqEnv = (freqEnv + freq) + PinkNoise.ar(Clip.ir(noise * 100, 0, 100));
      env = EnvGen.ar(Env.perc(atk, sus, 1, -4), doneAction: 2);

      source = SinOsc.ar(freqEnv);
      source = (source * Clip.ir(10 * overdrive, 1, 10)).tanh;
      source = FoaEncode.ar(source, FoaEncoderMatrix.newOmni);
      source = FoaPush.ar(source, pan.linlin(0, 1, -pi/2, pi/2), LFNoise1.kr(0.01, 0, 2pi));
      source = FoaDecode.ar(source, FoaDecoderMatrix.newPanto(~config.channels, \point, \dual));
      source = source * env * (amp/(2/~config.channels));
      source = Limiter.ar(source, 0.5);
      OffsetOut.ar(out, source);
    }).add;

    SynthDef(\dpad, {
      | freq = 440,
        atk = 0.01, rel = 1, detune = 0.2,
        pan = 0, amp = 0.5, out = 0 |
      var envelope, source, feedback;
      source = Saw.ar(freq * {LFNoise1.kr(0.5, detune).midiratio}!2);
      envelope = EnvGen.ar(Env.perc(atk, rel), doneAction: Done.freeSelf);

      feedback = LocalIn.ar(2) * 0.9;
      feedback = OnePole.ar(feedback, 0.75);
      feedback = source + feedback;

      LocalOut.ar(feedback);
      feedback = LeakDC.ar(feedback);
      feedback = FreeVerb.ar(feedback, 0.75);

      feedback = Mix(HPF.ar(feedback, 40));
      feedback = FoaEncode.ar(feedback, FoaEncoderMatrix.newOmni);
      feedback = FoaZoom.ar(feedback, pan.linlin(0, 1, -pi/2, pi/2), LFNoise1.kr(0.01, 0, 2pi));
      feedback = FoaDecode.ar(feedback, FoaDecoderMatrix.newPanto(~config.channels, \point, \dual));
      feedback = feedback * envelope * (amp/(2/~config.channels));

      feedback = Limiter.ar(feedback);
      OffsetOut.ar(out, feedback);
    }).add;

    SynthDef(\limiter, {
      | in = 0, out = 0 |
      var source = In.ar(in, ~config.channels);
      source = Select.ar(CheckBadValues.ar(source, 0, 0), [source, DC.ar(0), DC.ar(0), source]);
      source = HPF.ar(source, 20);
      ReplaceOut.ar(out, Limiter.ar(source, 0.75));
    }).add;

    s.sync;
    "Synthdefs initialized".postln;
    Pbindef(\pad,
      \instrument, \pad,
      \dur, 2,
      \midinote, Pxrand([
        [20, 24, 38, 58, 62],
        [43, 46, 56, 62, 65, 66],
        [29, 35, 45, 59, 61, 67],
        [33, 40, 42, 54, 58],
        [28, 37, 42, 54, 57, 60, 65],
      ], inf),
      \detune, 0,
      \ffmin, 100,
      \ffmax, 200,
      \rqmin, 0.005,
      \rqmax, 0.0075,
      \atk, 5,
      \ldb, 12,
      \amp, 2,
      \pan, 0.5,
      \out, ~config.out,
    ).stop;

    Pbindef(\perc,
      \instrument, Prand([\perc], inf),
      \dur, Prand([1], inf),
      \stretch, ~config.tempo,
      \degree, Pseq([
        0,
        Prand((0, 2..12), 7),
      ], inf),
      \scale, Scale.pelog,
      \root, -48,
      \rel, 8,
      \amp, Pseq([
        1,
        Pseq([0], 3),
      ], inf),
      \pan, Pwhite(-1.0, 1.0, inf),
      \out, ~config.out,
    ).stop;

    Pbindef(\kick,
      \instrument, \kick,
      \dur, 4,
      \stretch, ~config.tempo,
      \sus, 8,
      \freq, 55,
      \amp, 1,
      \overdrive, 0.2,
      \noise, 0.4,
      \pan, Pwhite(-1.0, 1.0, inf),
      \out, ~config.out,
    ).stop;

    Pbindef(\dpad,
      \instrument, \dpad,
      \dur, 6,
      \midinote, Pxrand([
        [23, 33, 45, 65, 78],
        [44, 52, 61, 77, 89, 92],
        [19, 39, 47, 58, 61, 66],
        [30, 34, 42, 51, 55],
        [55, 63, 77, 83, 92],
      ], inf),
      \rel, 8,
      \atk, 8,
      \detune, 1,
      \amp, 0.1,
      \pan, Pwhite(-1.0, 1.0, inf),
      \out, ~config.out,
    ).stop;

    Synth(\limiter, [\in, ~config.out, \out, ~busses.hardware], s, \addToTail);

    s.sync;
    s.record(numChannels: ~config.channels);

    s.sync;
    "Instruments initialized".postln;
    "Composition start".postln;
    // Start composition
    ~routine = Routine({
      (
        "Intro".postln;
        Pbindef(\pad, \amp, 0, \ffmax, 200, \pan, 0.5).play;
        ~go.value(4*8, { |i| Pbindef(\pad, \amp, i.linexp(0, 1, 0.001, 2)).play; (1/2).wait;});
        ~go.value(4*16, { |i| Pbindef(\pad, \ffmax, i.linexp(0, 1, 200, 12000)).play; 1.wait;});
        Pbindef(\pad, \pan, Pwhite(0.0, 1.0, inf)).play; // Pan variations
        (4*16).wait;
      );

      (
        "Main".postln;
        Pbindef(\pad, \rqmin, Pwhite(0.001, 0.3, inf), \rqmax, Pkey(\rqmin) + 0.5, \amp, 0.5).play;
        (4*8).wait;
        Pbindef(\pad, \detune, Pwhite(0.0, 1.0)).play;
        (4*8).wait;
        Pbindef(\pad, \detune, 1).play;
        // Perc enters
        Pbindef(\perc).play(quant: ~config.tempo);
        (4*8).wait;
        Pbindef(\perc,
          \dur, Prand([1/4], inf),
          \amp, Pseq([1, Pexprand(0.01, 0.7, 3)], inf),
          \rel, Pwhite(1.5, 3.0, inf),
        ).quant_(~config.tempo);
        (4*4).wait;
        Pbindef(\perc,
          \dur, Prand([1/8], inf),
          \amp, Pseq([1.25, Pwhite(0.4, 0.7, 7)], inf),
          \rel, Pseq([1, Pexprand(0.5, 1.2, 7)], inf),
        ).quant_(~config.tempo);
        // Long tailed kick enters
        Pbindef(\kick, \amp, 1).play(quant: ~config.tempo);
        (4*8).wait;
        Pbindef(\pad, \amp, 0.75).play;
        (4*4).wait;
        Pbindef(\perc,
          \rel, 0.75,
          \degree, Pseq([0, Prand((0, 1..24), 7)], inf),
        ).quant_(~config.tempo);
        (4*8).wait;
        Pbindef(\perc,
          \rel, 4,
          \dur, Prand([1/2], inf),
          \amp, Pseq([1.25, Pexprand(0.01, 0.4, 7)], inf),
        ).quant_(~config.tempo);
        (4*8).wait;
        Pbindef(\kick, \amp, 0).quant_(~config.tempo);
        Pbindef(\perc,
          \rel, 8,
          \dur, Prand([1/2], inf),
          \amp, Pseq([0.8, 0!7].flatten, inf),
        ).quant_(~config.tempo);
        (4*8).wait;
      );

      (
        // Outro
        "Outro".postln;
        Pbindef(\dpad).play(quant: ~config.tempo);
        (4*8).wait;
        Pbindef(\perc).stop;
        (4*8).wait;
        Pbindef(\dpad).stop;
        Pbindef(\pad).stop;
        Pbindef(\perc).stop;
        Pbindef(\kick).stop;
        (4*4).wait;
        s.stopRecording;
      );
    }).play(~clock);
  });
)
