// Quarantine Live Stream #2: Clown coloured SuperCollider GUI programming made easy
// https://youtu.be/Ww2QbWwWln0

(
  var numSliders = 4;
  var numButtons = 2;

  var sliders, sliderLayout;
  var buttons, buttonLayout;
  var layout;

  w = Window.new;

  sliders = numSliders.collect({
	Slider.new().background_(Color.rand(0.25, 0.9)).action_({
	  | slider |
	  slider.value.postln;
	});
  });

  buttons = numButtons.collect({
	Button.new().action_({
	  | button |
	  button.value.postln;
	});
  });

  // VLayout; HLayout;
  sliderLayout = HLayout.new(*sliders);
  buttonLayout = VLayout.new(*buttons);

  // Buttons config
  buttons[0].states_([["Start", Color.black, Color.rand]]).action_({ | button | Pdef(\q).play; }); // Start button
  buttons[1].states_([["Stop", Color.black, Color.rand]]).action_({ | button | Pdef(\q).stop; }); // Stop button

  // Slider actions
  sliders[0].action_({ | slider | Pdefn(\qdur, slider.value.linlin(0.0, 1.0, 0.05, 1.0)) }); // \dur MUST NOT BE 0
  sliders[1].action_({ | slider | Pdefn(\qdeg, slider.value) });
  sliders[2].action_({ | slider | Pdefn(\qoct, slider.value.linlin(0.0, 1.0, 1.0, 8.0)) });
  sliders[3].action_({ | slider | Pdefn(\qamp, slider.value).linexp(0.0, 1.0, 0.01, 1.0) });

  // Final layout
  layout = VLayout(buttonLayout, sliderLayout);

  w.layout = layout;

  w.front;
)

(
  Pdef(\q,
	Pbind(
	  \dur, 0.125,
	  \degree, Pwhite(0, 10),
	)
  ).play;
)

Pdef(\q).gui;
Pdef(\q).stop;

(
  Pdef(\q,
	Pbind(
	  \dur, Pdefn(\qdur, 0.25),
	  \degree, Pdefn(\qdeg, 0),
	  \octave, Pdefn(\qoct, 4),
	  \amp, Pdefn(\qamp, 0.5),
	)
  ).play;
)