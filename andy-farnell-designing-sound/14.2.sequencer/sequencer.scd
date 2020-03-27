(
  ~config = (
    columns: 16,
    rows: 16,
	margin: 6,
	width: 24,
  );

  ~gui = ();
  ~gui.window = Window.new(
	name: \Sequencer,
	bounds:
	  Rect(0, 0, ~config.columns * (~config.width + ~config.margin) + ~config.margin, ~config.rows * (~config.width + ~config.margin) + ~config.margin),
	resizable: false,
  ).background_(Color.black);

  ~gui.window.view.decorator = FlowLayout(~gui.window.view.bounds, ~config.margin@~config.margin, ~config.margin@~config.margin);

  ~rows = ~config.rows.collect({
	~config.columns.collect({
	  Button(~gui.window, ~config.width@~config.width).states_([["", Color.white, Color.white]]);
	});
  });

  ~gui.window.front;

)

~clock = TempoClock((120/60) * 4);
(
  ~clock.schedAbs(~clock.beats.ceil, {
	| beat, sec |
	[beat, sec].postln;

	~rows.do({ | r, i |
	  ~rows[i].do({ | r, j |
		if (beat % ~config.columns == j, {
		  { ~rows[i][j].states_([["", Color.red, Color.red]]).refresh }.defer;
		}, {
		  { ~rows[i][j].states_([["", Color.white, Color.white]]).refresh }.defer;
		});
	  });
	});
	1;
  });
)

s.freeAll
~clock.stop

~rows[0][0].states_([["", Color.red, Color.red]]).refresh;
~rows[0][0].background = Color.red
~rows[0][0].refresh
~rows[0][0].background 
