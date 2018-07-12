class Start implements Observer {

  boolean Help = false;
  boolean Draw = false;
  ArrayList<Option> opt;
  String msg;
  PFont font;
  PImage img;
  PImage help;


  Start() {

    font = loadFont("LaoMN-48.vlw");
    img = loadImage("title.png");
    help = loadImage("help.png");

    msg = "None";
    opt = new ArrayList<Option>();
    opt.add(new Option(width/2, height/8, width, height/4, "Help"));
    opt.add(new Option(width/2, 7*height/8, width, height/4, "Draw"));
    opt.get(0).addObserver(this);
    opt.get(1).addObserver(this);
  }

  void draw() {
    for (Option r : opt) {

      r.draw();

      fill(100);
      imageMode(CENTER);

      image(img, width/2, height/2, width, height/2);

      textAlign(CENTER);
      textFont(font, 148);

      text("HELP", width/2, height/8);
      text("DRAW", width/2, 7*(height/8)); 


      r.isPressed();
    }
  }

  void help() {
    background(255);

    opt.get(1).draw();

    fill(100);
    imageMode(CENTER);

    image(help, width/2, 3*height/8, width, 3*height/4);

    textAlign(CENTER);
    textFont(font, 148);

    text("DRAW", width/2, 7*(height/8)); 
    opt.get(1).isPressed();
  }

  void update(Observable obj, Object s) {

    if (!this.msg.equals(s))
    {
      this.msg = (String) s;
      println(msg);
    }

    if (s.equals("Help"))
    {
      Help = true;
      Draw = false;
      delay(500);
      background(255);
    } else if (s.equals("Draw"))
    {
      Draw = true;
      Help = false;
      delay(500);

      background(255);
    }
  }
}

class Option extends Observable {

  int x;
  int y;
  int w;
  int h;
  String msg;
  color col = color(235, 180, 180);

  Option( int x, int y, int w, int h, String msg) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.msg = msg;
  }

  void draw() {
    //background(255);
    rectMode(CENTER);
    fill(col);
    strokeWeight(4);
    stroke(120);
    rect(x, y, w, h);
  }

  void isPressed() {
    if (mousePressed) {
      if (mouseX<x+w/2&&mouseX>x-w/2&&mouseY<y+h/2&&mouseY>y-h/2) {
        setColor(color(250, 100, 100));
        println(msg);
        setChanged();
        notifyObservers(msg);
      }
    }
    setColor(color(250, 180, 180));
  }

  void setColor(color col) {
    this.col = col;
  }

  void changeState(color col) {
    this.col = col;
  }
}