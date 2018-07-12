class IFace implements Observer {
  IFace() {
  }

  String mode = "Drawing";

  void update(Observable obj, Object arg) {
    if (mode!=(String)arg) {
      mode = (String)arg;
      println(mode);
    }
    if (menu.Help) {
      menu.help();
    } else if (menu.Draw) {

      if (mode.equals("Drawing")) {
        brush.draw(canvas);
      } else if (mode.equals("ColorControl")) 
      { 
        Wheel.draw();
      } else if (mode.equals("ColorIsChanging"))
      {
        Wheel.draw();
        Wheel.start();
      } else if (mode.equals("Clean")) 
      {
        canvas.reset();
        background(255);
      } else if (mode.equals("Rotating")) 
      {
        int angle = computeAngle(g);
        canvas.rotateCanvas(angle);
      } else if (mode.equals("SizeControl")) 
      {
        control.draw();
      } else if (mode.equals("SizeIsChanging"))
      {
        control.draw();
        control.start();
      } else if (mode.equals("Wait")) {
        delay(1000);
      } else if (mode.equals("AddTemplate")) {

        color col = brush.getColor();
        int size = brush.getSize();

        brushes.set(index%8, new Brush().ofSize(size).ofColor(col));
        index++;
        saveBrushes("/sdcard/myApp/myBrushes.xml");
      } else if (mode.equals("Save")) {

        String name = Integer.toString(millis())+".jpg";
        canvas.saveImage(name);

        sens.mode = "Drawing";
      }
    } else {
      menu.draw();
    }
  }
}