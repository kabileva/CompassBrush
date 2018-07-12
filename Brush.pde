

class Brush implements Observer {

  int diam;
  color currentColor;
  int i = 0;


  Brush() 
  {
    this.diam=5;
    this.currentColor=color(0);
  }


  Brush(int diam, color col)
  {
    this.diam = diam;
    currentColor = col;
  }


  void update(Observable obj, Object arg) {
    if (((String)arg).equals("ColorIsChanging")) {
      this.currentColor = Wheel.getCurrentColor();
    } else if (((String)arg).equals("SizeIsChanging")) {
      this.changeSize(accelerometerY);
    }
  }


  void draw(Canvas canvas)
  {   
    rectMode(CENTER);
    fill(127);
    noStroke();
    rect(width/2, 30, width, 60);
    noStroke();
    if (mousePressed && mouseY>80) {
      canvas.addPoint(new PVector(mouseX, mouseY));
      stroke(currentColor);
      strokeWeight(diam);
      line(mouseX, mouseY, pmouseX, pmouseY);
      noStroke();
    } else {
      if (canvas.line.size()>1) { 
        canvas.addLine();
        canvas.addColor(new PVector(red(currentColor), green(currentColor), blue(currentColor)));
        canvas.addDiam(diam);
        canvas.newLine();
      }
    }
  }


  void changeSize(float accelerometerY) 
  {
    if (accelerometerY>0 && diam<400) {
      diam+=(int)accelerometerY;
    } else if (accelerometerY<3 && diam>7) {
      diam+=(int)accelerometerY;
    }
  }

  void setColor(color c)
  {
    this.currentColor=c;
  }
  
  
  color getColor()
  {
    return currentColor;
  }
  

  void setSize(int diam) 
  {
    this.diam = diam;
  }

  int getSize() 
  {
    return diam;
  }
  
  /*******************/
  /* Builder Pattern */

  public Brush ofSize(int size) {
    this.setSize(size);
    return this;
  }
  public Brush ofColor(color col) {
    this.setColor(col);
    return this;
  }

    /*****************/

  boolean isPressed(int x, int y) {
    if (sq(mouseX-x)+(mouseY-y)<sq(diam/2)) {

      return true;
    }
    return false;
  }

  void show(int xpos, int ypos) {
    fill(currentColor);
    ellipse(xpos, ypos, diam, diam);
  }
}