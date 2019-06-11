Server.local.boot;
Server.local.reboot;

{0.1 * SinOsc.ar}.scope

{SinOsc.ar(mul: 0.1)}.scope

(
  {
    // cutoff values need to be sensible frequencies in Hz; here sine output turned from -1 to 1 into 2000+-1700
    // var cutoff = SinOsc.ar(1, mul:MouseX.kr(0.0,1700.0), add:2000.0);
    var cutoff = SinOsc.ar(1)*1700.0 + 2000.0;  //same thing
    LPF.ar(WhiteNoise.ar,freq:cutoff);
  }.scope
)

// Modulation
{SinOsc.ar(SinOsc.ar(3, mul: 40, add: 440), 0, 0.1)}.scope

a = {arg freq=440, amp=0.1; SinOsc.ar(freq)*amp}.play
a.set(\freq,rrand(220,440), \amp, rrand(0.05,0.2))
a.run(false)

// Run frequency analyzer
FreqScope.new;

// Ring Modulation (RM)
(
  {
    var carrier, modulator, carrfreq, modfreq;
    carrfreq = MouseX.kr(440, 5000, 'exponential');
    modfreq = MouseY.kr(1, 5000, 'exponential');
    carrier = SinOsc.ar(carrfreq, 0, 0.5);
    modulator = SinOsc.ar(modfreq, 0, 0.5);
    carrier * modulator;
  }.scope
)

// Amplitude Modulation (AM)
(
  {
    var carrier, modulator, carrfreq, modfreq;
    carrfreq = MouseX.kr(440, 5000, 'exponential');
    modfreq = MouseY.kr(1, 5000, 'exponential');
    carrier = SinOsc.ar(carrfreq, 0, 0.5);
    modulator = SinOsc.ar(modfreq, 0, 0.25, 0.25);
    carrier * modulator;
  }.scope
)

// Frequency Modulation (FM)
(
  var w, carrfreqslider, modfreqslider, moddepthslider, synth;
  w = Window("frequency modulation", Rect(100, 400, 400, 300));
  w.view.decorator = FlowLayout(w.view.bounds);
  synth = {|carrfreq = 440, modfreq = 1, moddepth = 0.01|
    SinOsc.ar(carrfreq + (moddepth * SinOsc.ar(modfreq)), 0, 0.25)
  }.scope;
  carrfreqslider = EZSlider(w, 300@50, "carrfreq", ControlSpec(20, 5000, 'exponential', 10, 440), {|ez|
    synth.set(\carrfreq, ez.value)
  });
  w.view.decorator.nextLine;
  modfreqslider = EZSlider(w, 300@50, "modfreq", ControlSpec(1, 5000, 'exponential', 1, 1), {|ez|
    synth.set(\modfreq, ez.value)
  });
  w.view.decorator.nextLine;
  moddepthslider = EZSlider(w, 300@50, "moddepth", ControlSpec(0.01, 5000, 'exponential', 0.01, 0.01), {|ez|
    synth.set(\moddepth, ez.value)
  });
  w.front;
)

// Frequency Modulation #2 (FM)
(
  var w, carrfreqslider, modfreqslider, modindexslider, synth;
  w=Window("frequency modulation via modulation index", Rect(100, 400, 400, 300));
  w.view.decorator = FlowLayout(w.view.bounds);
  synth= {arg carrfreq=440, modfreq=1, modindex=0;
    SinOsc.ar(carrfreq + (modindex*modfreq*SinOsc.ar(modfreq)),0,0.25)
  }.scope;
  carrfreqslider= EZSlider(w, 300@50, "carrfreq", ControlSpec(20, 5000, 'exponential', 10, 440), {|ez|  synth.set(\carrfreq, ez.value)});
  w.view.decorator.nextLine;
  modfreqslider= EZSlider(w, 300@50, "modfreq", ControlSpec(1, 5000, 'exponential', 1, 1), {|ez|  synth.set(\modfreq, ez.value)});
  w.view.decorator.nextLine;
  modindexslider= EZSlider(w, 300@50, "modindex", ControlSpec(0.0, 10, 'linear', 0.01, 0.0), {|ez|  synth.set(\modindex, ez.value)});
  w.front;
)

// Phase Modulation
(
  var w, carrfreqslider, modfreqslider, modindexslider, synth;
  var conversion= 2pi/(s.sampleRate); //needed to avoid phase being adjusted too wildly
  w=Window("phase modulation via modulation index", Rect(100, 400, 400, 300));
  w.view.decorator = FlowLayout(w.view.bounds);
  synth= {arg carrfreq=440, modfreq=1, modindex=0;
    SinOsc.ar(carrfreq, ( (modfreq*modindex)*conversion*SinOsc.ar(modfreq)),0.25)
  }.scope;
  carrfreqslider= EZSlider(w, 300@50, "carrfreq", ControlSpec(20, 5000, 'exponential', 10, 440), {|ez|  synth.set(\carrfreq, ez.value)});
  w.view.decorator.nextLine;
  modfreqslider= EZSlider(w, 300@50, "modfreq", ControlSpec(1, 5000, 'exponential', 1, 1), {|ez|  synth.set(\modfreq, ez.value)});
  w.view.decorator.nextLine;
  //bigger range since adjusting phase directly and not frequency
  modindexslider= EZSlider(w, 300@50, "modindex", ControlSpec(0.0, 100, 'linear', 0.01, 0.0), {|ez|  synth.set(\modindex, ez.value)});
  w.front;
)
