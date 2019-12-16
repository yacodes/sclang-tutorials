"../14//01.scd".load;

{SinOsc.ar!2}.play;
s.freeAll;
Window.closeAll;


{(SinOsc.ar(500 + SinOsc.ar(1, mul: 400)) * 0.2)!2}.play
s.freeAll
s.scope


Quarks.install("https://github.com/scztt/Twister.quark")

Twister

SCDoc.renderAll

(
  MIDIClient.init;
  MIDIIn.connectAll();
  TwisterDevice.registerDevice(\primary, "Midi Fighter Twister 1", "Midi Fighter Twister");
  ~twister = Twister.new(\primary);
)


~twister.rows(0, 0).cv
~twister.rows(0, 0).cv = NumericControlValue(spec:[0, 100]);

~t.rows(0).do(_.ledColor_(Color.rand));

Quarks.gui

MIDIFunc.trace

~t = Twister(TwisterDevice(\primary, MIDIClient.sources[4]));
~t.knobs[0].cv = NumericControlValue(spec:[0, 1]);
~t.knobs[0].ledColor = Color.red;

~t.knobs[0].cv.signal(\value).connectToUnique {
  |...args|
  "ive changed: %".format(args).postln;
}


(
~t.buttons[0].cv.signal(\value).connectToUnique {
    |...args|
    "ive changed: %".format(args).postln;
};
)

~c = ControlValueEnvir(BusControlValue);
~c.use {
  ~amp.spec = \db.asSpec;
  ~freq.spec = \freq.asSpec;
};

~t.brightness = 0.5;
~t.rows(0, 0).knobCV = ~c.amp;
~t.rows(0, 1).knobCV = ~c.freq;
~t.rows(0).do(_.ledColor_(Color.rand));
~c.setValues((freq: 20000, amp: -10));

~c.freq.signal(\value).connectToUnique {
  |...args|
  "ive changed: %".format(args).postln;
};


~c.freq.signal(\value).connectToUnique {
  |...args|
  "ive changed: %".format(args).postln;
};
~c.amp.signal(\value).connectToUnique {
  |...args|
  "ive changed: %".format(args).postln;
};

~twister.brightness = 0;

s.freeAll

~twister.rows(0, 0).knobCV = {}

~twister.rows(0, 0).knobCV = {|val| val.postln;};

~c = ControlValueEnvir(BusControlValue);
~c.use {
  ~amp.spec = \db.asSpec;
  ~freq.spec = \freq.asSpec;
  ~formant.spec = [100, 5000];
  ~bw.spec = [10, 200];
  ~speak = OnOffControlValue();
};

~twister.rows(0, 0).knobCV = ~c.amp;

~c.amp.value

~twister.dump

~twister.rows(0, 0).dump
~twister.rows(0, 0).toggle = true;
~twister.rows(0, 0).toggle = false;
~twister.rows(0, 0).toggle;


MIDIClient.init

MIDIClient.sources


s.freeAll

(
s.waitForBoot {
    ~t = Twister(\default);

    // Set up some control values we want to connect the twister to.
    // See help for Connection library or BusControlValue for more details.
    ~c = ControlValueEnvir(BusControlValue);
    ~c.use {
        ~amp.spec = \db.asSpec;
        ~freq.spec = \freq.asSpec;
        ~formant.spec = [100, 5000];
        ~bw.spec = [10, 200];
        ~speak = OnOffControlValue();
    };

    // Map our control values to knobs and buttons
    ~t.rows(0, 0).knobCV = ~c.amp;
    ~t.rows(0, 1).knobCV = ~c.freq;
    ~t.rows(0, 2).knobCV = ~c.formant;
    ~t.rows(0, 3).knobCV = ~c.bw;

    ~t.buttons[0].cv = ~c.speak;


    // Set some random colors
    ~t.rows(0).do(_.ledColor_(Color.rand));

    // Play a simple synth
    Ndef(\tone, {
        |freq = 100, amp = 0, formant = 100, bw = 100, t_trigger|
        var sig;
        sig = Formant.ar(freq, formant, bw, amp.dbamp);
        sig = sig + (WhiteNoise.ar(0.1) * Env.perc().kr(gate:t_trigger));
    }).play;

    // Map our control values to synth params.
    Ndef(\tone).map(
        \amp,         ~c.amp.asMap,
        \freq,         ~c.freq.asMap,
        \formant,     ~c.formant.asMap,
        \bw,         ~c.bw
    );

    // Map our button to something arbitrary
    ~c.speak.signal(\on).connectToUnique({
        "Pushing a button".postln;
        Ndef(\tone).set(\t_trigger, 1);
    });

    // Set some initial values.
    // Note that this should update the display on the Twister device if it is connected.
    ~c.setValues((
        freq: 370,
        amp: -10,
        formant: 1000,
        bw: 300
    ));
};
)
s.freeAll
