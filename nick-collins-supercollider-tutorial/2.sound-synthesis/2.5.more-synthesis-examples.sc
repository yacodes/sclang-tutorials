Server.local.boot;
Server.local.reboot;
Server.local.quit;
FreqScope();
Server.local.scope();
s.queryAllNodes();

// Primitive Chorus Effect
{Mix(Saw.ar([440,443,437],0.1))}.scope

(
  {
    Mix(
      // The Resonz filter has arguments input, freq, rq=bandwidth/center frequency
      Resonz.ar(
        // Frequency modulated sawtooth wave with chorusing
        Saw.ar([440, 443, 437] + SinOsc.ar(100, 0, 100)),
        // Vary filter bandwidth over time
        XLine.kr(10000, 10, 10),
        // Vary filter rq over time
        Line.kr(1, 0.05, 10),
        // Amplitude modulation
        mul: LFSaw.kr(Line.kr(3, 17, 3), 0, 0.5, 0.5) * Line.kr(1, 0, 10)
      )
    )
  }.scope
)

// Rich Bell Sound
(
  var numpartials, spectrum, amplitudes, modfreqs1, modfreqs2, decaytimes;
  spectrum = [0.5, 1, 1.19, 1.56, 2, 2.51, 2.66, 3.01, 4.1];
  amplitudes = [0.25, 1, 0.8, 0.5, 0.9, 0.4, 0.3, 0.6, 0.1];
  numpartials = spectrum.size;
  // Vibrato rates from 1 to 5 Hz
  modfreqs1 = Array.rand(numpartials, 1, 5.0);
  // Tremolo rates from 0.1 to 3 Hz
  modfreqs2 = Array.rand(numpartials, 0.1, 3.0);
  // Decay from 2.5 to 7.5 seconds, lower partials longer decay
  decaytimes = Array.fill(numpartials, {|i|
    rrand(2.5, 2.5 + (5 * (1.0 - (i / numpartials))));
  });
  {
    Mix.fill(spectrum.size, {|i|
      var amp, freq;
      freq = (spectrum[i] + (SinOsc.kr(modfreqs1[i], 0, 0.005))) * 500;
      amp = 0.1 * Line.kr(1, 0, decaytimes[i]) * (SinOsc.ar(modfreqs2[i], 0, 0.1, 0.9) * amplitudes[i]);
      Pan2.ar(SinOsc.ar(freq, 0, amp), 1.0.rand2)
    });
  }.scope
)
