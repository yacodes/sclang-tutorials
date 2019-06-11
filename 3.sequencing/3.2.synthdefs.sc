Server.local.boot;
Server.local.reboot;
Server.local.quit;

SynthDef(\sine, {
  Out.ar(0, SinOsc.ar(Rand(440, 880), 0, 0.1));
}).add;

a = Synth(\sine);
a.free;

// Arguments
/* Added frequency and amp arguments to recipe;
* make sure they have default values (e.g. freq=440)
*/
SynthDef(\sine, {|freq = 440, amp = 0.1|
  Out.ar(0, SinOsc.ar(freq, 0, amp));
}).add();

// Now this accepts the defaults
a = Synth(\sine);

// This makes another Synth from the recipe an octave up,
// by being explicit about the frequency argument to the SynthDef
a = Synth(\sine, [\freq, 880]);
a = Synth(\sine, [\freq, 660, \amp, 0.5]);
a.set(\amp, 0.3, \freq, 100);
a.free();


/* Exercise:
* Try taking a simple synthesis patch you've been working on and turn it into a SynthDef.
* As a prototype you want something like:
*/
(
  // Any arguments go here, make sure they have default values
  SynthDef(\synthdefname, {|input1 = defaultvalue|
    // Some code for UGens - the sort of thing that went inside {}.play before

    // Finaloutput is the final result UGen you want to hear
    Out.ar(0, finaloutput);
  }).add
)

// Inputval1 is the constant starting value for argument input1
Synth(\synthdefname, [\input1, inputval1]);

// SynthDesc
// Supercollider uses synth description directive under the hood
// Post code used to make SynthDef for \sine (assumes you added the \sine SynthDef above)
SynthDescLib.global.synthDescs[\sine].def.func.postcs

// Browse the properties of available SynthDescs in the system
SynthDescLib.global.browse;

// Iterate through all available, posting any known function code
(
  SynthDescLib.global.synthDescs.do {|desc|
    if (desc.def.notNil) {
      "\nSynthDef %\n".postf(desc.name.asCompileString);
      desc.def.func.postcs;
    };
  };
)
