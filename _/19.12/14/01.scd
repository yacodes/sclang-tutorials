(
  QtGUI.palette = QPalette.dark;
  ~gui = ();
  ~gui[\bounds] = Rect(0, Window.screenBounds.height - 380, 380, 380);
  ~gui[\win] = Window.new("Channel strip", ~gui[\bounds], false, false);
  ~gui[\meter] = CustomMeterView.new(s, ~gui[\win], 0@0, 2, 16);
  ~gui[\bounds].height = ~gui[\meter].view.bounds.height * 2;
  ~gui[\win].bounds = ~gui[\bounds];

  ~gui[\freqscope] = FreqScopeView(
    ~gui[\win],
    Rect(
      0,
      ~gui[\meter].view.bounds.height,
      ~gui[\win].view.bounds.width,
      200
    )
  );
  ~gui[\freqscope].background = Color(0, 0, 0, 1);
  ~gui[\freqscope].active_(true);
  ~gui[\freqscope].freqMode_(1);
  ~gui[\win].onClose_({~gui[\freqscope].kill});
  ~gui[\win].view.background = Color(0, 0, 0, 1);
  ~gui[\win].alwaysOnTop = false;
  ~gui[\win].acceptsClickThrough = true;
  ~gui[\win].front;

  ~gui;
)
