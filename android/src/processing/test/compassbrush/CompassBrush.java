package processing.test.compassbrush;

import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import android.view.MotionEvent; 
import ketai.ui.*; 
import ketai.sensors.*; 
import java.util.Observable; 
import java.util.Observer; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class CompassBrush extends PApplet {








PVector magneticField;
colorWheel Wheel;
Brush brush = new Brush(30, color(200, 0, 255));
Canvas canvas = new Canvas();
sizeControl control;
KetaiSensor sensor;
Start menu;

float accelerometerX, accelerometerY, accelerometerZ;
KetaiGesture gesture;
ArrayList<PVector> points; //for tracking number of points(fingers) on the screen
float light; //light Sensor
ArrayList<Brush> brushes;
int index = 0; //for tracking recently used Brushes 

IFace iface; 
Sensor sens;
float[] g = new float[3];
float[] c = new float[3];


PImage img = createImage(width, height, RGB);


public void setup() {

  reset(); //initializing objects
  /* \u201c/sdcard/\u201d + filename */
  /*  instead of filename   */
  /*  or isn\u2019t saved (needs permission to read/write to external storage */

  loadBrushes("/sdcard/myApp/myBrushes.xml");

  background(255);
  


  sensor = new KetaiSensor(this);
  sensor.start();
  gesture = new KetaiGesture(this);
  magneticField = new PVector();

  sens.addObserver(iface);
  sens.addObserver(brush);
}

public void draw() {

  noStroke();
  sens.press();
}

public void loadBrushes(String filename)
{
  /* check if file exists */
  File f = new File(filename);
  if (!f.exists()) {

    /*if file doesn't exist on the smartphone, take the default
     *one from the sketch forlder
     doesn't work for some reason though, so the file from data folder
     should be first put into /sdcard/myApp/
     */
    f = new File("myBrushes.xml");
  }

  XML xml= loadXML(filename);
  XML[] children = xml.getChildren("Brush");

  for (int i = 0; i < children.length; i++) {
    println(children[i]);
    int diam = children[i].getInt("diam");
    int r = children[i].getInt("r");
    int g = children[i].getInt("g");
    int b = children[i].getInt("b");
    int col = color(r, g, b);
    brushes.add(new Brush().ofSize(diam).ofColor(col));
  }
}

public void exit() {
  saveBrushes("myBrushes.xml");
  super.exit();
}

public void saveBrushes (String filename)
{
  XML xml = new XML("AllBrushes.xml");

  for (Brush b : brushes)
  {
    XML child= xml.addChild("Brush");
    child.setInt("diam", (int)(b.getSize()));
    child.setInt("r", (int)(red(b.getColor())));
    child.setInt("g", (int)(green(b.getColor())));

    child.setInt("b", (int)(blue(b.getColor())));
  }

  PrintWriter pw= createWriter(filename);
  pw.print(xml);
  pw.flush();
  pw.close();
}

public void reset() {

  brushes = new ArrayList<Brush>();

  points = new ArrayList<PVector>();
  menu = new Start();

  Wheel = new colorWheel(600);
  control = new sizeControl();
  sens = new Sensor();
  iface = new IFace();
}


class Brush implements Observer {

  int diam;
  int currentColor;
  int i = 0;


  Brush() {
    this.diam=5;
    this.currentColor=color(0);
  }

  Brush(int diam, int col)
  {
    this.diam = diam;
    currentColor = col;
  }

  public void update(Observable obj, Object arg) {
    if (((String)arg).equals("ColorIsChanging")) {
      this.currentColor = Wheel.getCurrentColor();
    } else if (((String)arg).equals("SizeIsChanging")) {
      this.changeSize(accelerometerY);
    }
  }

  public void draw(Canvas canvas)
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


  public void changeSize(float accelerometerY) 
  {
    if (accelerometerY>0 && diam<400) {
      diam+=(int)accelerometerY;
    } else if (accelerometerY<3 && diam>7) {
      diam+=(int)accelerometerY;
    }
  }

  public void setColor(int c)
  {
    this.currentColor=c;
  }
  public int getColor() {
    return currentColor;
  }

  public void setSize(int diam) {
    this.diam = diam;
  }

  public int getSize() {
    return diam;
  }
  
  /* Builder Pattern */

  public Brush ofSize(int size) {
    this.setSize(size);
    return this;
  }
  public Brush ofColor(int col) {
    this.setColor(col);
    return this;
  }

  public boolean isPressed(int x, int y) {
    if (sq(mouseX-x)+(mouseY-y)<sq(diam/2)) {

      return true;
    }
    return false;
  }

  public void show(int xpos, int ypos) {
    fill(currentColor);
    ellipse(xpos, ypos, diam, diam);
  }
}
class Canvas {
  Lines lines;
  ArrayList<PVector> colors;
  IntList diams;
  ArrayList<PVector> line;

  Canvas()
  {
    reset();
  }

  public void restore(int xDelta, int yDelta) 
  {
    background(255);
    noStroke();
    
    for (int i = 0; i < lines.getSize(); i++) {
      for (int j = 1; j < lines.getLine(i).size(); j++) 
      {
       
        PVector p = lines.getPoint(i, j-1);
        PVector p2 = lines.getPoint(i, j);
        int col = color(colors.get(i).x, colors.get(i).y, colors.get(i).z);
        int diam = diams.get(i);
        fill(col);
        stroke(col);
        strokeWeight(diam);
        line(p.x- xDelta, p.y -yDelta, p2.x - xDelta, p2.y-yDelta);
        noStroke();
      }
      noStroke();
    }
    noStroke();
  }

  public void save(int angle, int xDelta, int yDelta) 
  {

    for (int i =0; i < lines.getSize(); i++) {
      for (int j = 0; j < lines.getLine(i).size(); j++) {
        float a = radians(angle);

        
        float px = lines.getX(i, j);
        float py = lines.getY(i, j);
        float x =  cos(a) * (px - xDelta) - sin(a) * ( py - yDelta) + xDelta;
        float y =  sin(a) * (px - xDelta) + cos(a) * ( py - yDelta) + yDelta;
        PVector p = new PVector(x, y);
        lines.setPoint(i, j, p);
      }
    }
  }
  public void newLine() {
    line = new ArrayList<PVector>();
  }

  public void addPoint(PVector p) 
  {
    line.add(p);
  }
  public void addLine() {
    lines.addLine(line);
  }
  public void addColor(PVector col)
  {
    colors.add(col);
  }

  public void addDiam(int diam)
  {
    diams.append(diam);
  }

  public void reset()
  {

    lines = new Lines();
    line = new ArrayList<PVector>();
    colors = new ArrayList<PVector>();
    diams = new IntList();
  }

  public void rotateCanvas(int angle) 
  {
    pushMatrix();
    translate(width/2, height/2);
    rotate(radians(angle));
    this.restore(width/2, height/2);
    popMatrix();
  }

  public void move(int xpos, int ypos)
  {
    int xDelta = mouseX - xpos;
    int yDelta = mouseY - ypos;
    pushMatrix();
    translate(xDelta, yDelta);
    this.restore(0, 0);
    popMatrix();
  }


  public void saveImage(String filename) {
    /* Create new Pimage and copy canvas to it to save */
    /* Without it is saved as a black rectangle */

    PImage img = get(0, 80, width, height);
    img.save("/sdcard/myApp/" + filename);
    delay(1000);

    restore(0, 0);
    println(filename + "  SAVED");
  }
}

class Lines {
  
  ArrayList<ArrayList<PVector>> lines;

  Lines() {
    lines = new ArrayList<ArrayList<PVector>>();
  }
  public void addLine(ArrayList<PVector> line) {
    lines.add(line);
  }

  public void setPoint(int i, int j, PVector p) {
    lines.get(i).set(j, p);
  }

  public ArrayList<PVector> getLine(int i) {
    return lines.get(i);
  }

  public PVector getPoint(int i, int j) {
    return lines.get(i).get(j);
  }

  public float getX(int i, int j) {
    return getPoint(i, j).x;
  }
  public float getY(int i, int j) {
    return getPoint(i, j).y;
  }

  public int getSize() {
    return lines.size();
  }
}
abstract class Controller {

  float beginX;  // Initial x-coordinate
  float beginY;  // Initial y-coordinate
  float endX = width/2 ;  // Final x-coordinate
  float endY = height/2 - 200 ;  // Final y-coordinate
  float distX;          // X-axis distance to move
  float distY;          // Y-axis distance to move
  float exponent = 4;   // Determines the curve
  float xpos = 0.0f;        // Current x-coordinate
  float ypos = 0.0f;        // Current y-coordinate
  float step = 0.03f;    // Size of each step along the path
  float pct = 0.0f;      // Percentage traveled (0.0 to 1.0)

  Controller() {
  }

  public abstract void draw(); 
  {
  }

  public abstract void start(); 
  {
  }

  public void initialize(float beginX, float beginY) {
    this.beginX = beginX;  // Initial x-coordinate
    this.beginY = beginY;  // Initial y-coordinate
    endX = width/2 ;  // Final x-coordinate
    endY = height/2  - 200 ;  // Final y-coordinate
    pct = 0.0f;      // Percentage traveled (0.0 to 1.0)
    distX = endX - beginX;
    distY = endY - beginY;
  }

  public void showBrushes() {
    int x = 0;
    for (int i=0; i<brushes.size(); i++) {
      if (x+width/5<(width-50)) {
        x+=width/5;
      } else {
        x=width/5;
      }
      int y = height/2+(i/4)*300+500;
      brushes.get(i).show(x, y);
      if (sq(mouseX-x)+sq(mouseY-y)<sq(brushes.get(i).getSize()/2)) {
        int col = brushes.get(i).getColor();
        int size = brushes.get(i).getSize();

        brush = new Brush().ofSize(size).ofColor(col);
        sens.addObserver(brush);
      }
    }
  }
}

public class colorWheel extends Controller {

  float radius;
  int size;
  private int currentColor;
  PImage img= loadImage("colorWheel.png");

  colorWheel(int size)
  {
    this.size = size;
    radius = 0.95f*this.size/2;
    currentColor = brush.currentColor;

    imageMode(CENTER);
    distX = endX - beginX;
    distY = endY - beginY;
  }


  public void draw()
  {

    background(255, 240, 245);
    rectMode(CENTER);
    fill(127);
    noStroke();

    rect(width/2, 30, width, 60);

    /* Y = x^4 trajectory */

    if (pct < 1.0f) {
      pct += step;

      xpos = beginX + (pct * distX);
      ypos = beginY + (pow(pct, exponent) * distY);
    }


    image(img, xpos, ypos, size, size);
    fill(255);
    ellipse(xpos, ypos, 80, 80);
    fill(0);
    ellipse(xpos, ypos, 35, 35);
    fill(currentColor);
    strokeWeight(1);
    stroke(0);
    brush.show((int)xpos, (int)ypos - 500);
    super.showBrushes();

    noStroke();
  }

  public void start() 
  {
    float angle = abs(360.0f/30*magneticField.x);
    float x = cos(radians(angle)) * radius; //convert angle to radians for x and y coordinates
    float y = sin(radians(angle)) * radius;

    float delta = min(light/100.0f, 1.0f);

    setCurrentColor(get((int)xpos+(int)(x*delta), (int)ypos+(int)(y*delta)));
/* draw a ball which gets the color from wheel */
    pushMatrix();

    translate(xpos, ypos);

    ellipseMode(CENTER);
    fill(255);
    stroke(0);
    strokeWeight(1);
    ellipse((int)(x*delta), (int)(y*delta), 30, 30);
    noStroke();
    popMatrix();
  }

  public void setCurrentColor(int c)
  {
    this.currentColor = c;
  }

  public int getCurrentColor() 
  {
    return this.currentColor;
  }
}

class sizeControl extends Controller {

  int c;


  sizeControl() {
  }

  public void draw() {
    background(255, 240, 245);
    rectMode(CENTER);
    noStroke();

    fill(127);
    rect(width/2, 30, width, 60);
    
    /* Y = x^4 trajectory */

    if (pct < 1.0f) {
      pct += step;

      xpos = beginX + (pct * distX);
      ypos = beginY + (pow(pct, exponent) * distY);
    }
    noFill();
    stroke(127);
    strokeWeight(3);
    ellipse(xpos, ypos, 400, 400);
    strokeWeight(2);
    brush.show((int)xpos, (int)ypos);
    super.showBrushes();

    noStroke();
  }
  public void start() {

    brush.show((int)xpos, (int)ypos);
  }
}
class IFace implements Observer {
  IFace() {
  }

  String mode = "Drawing";

  public void update(Observable obj, Object arg) {
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

        int col = brush.getColor();
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
class Sensor extends Observable {

  Sensor() {
  }

  String mode = "Drawing"; 
  boolean longPress = false;
  boolean change = false;
  boolean rotating = false;
  boolean gotThree = false;
  boolean doubleTap = false;
  boolean add =false;
  boolean rightFlick  = false;
  boolean leftFlick = false;
  
  boolean saved = false;

  public void press() {
    setChanged();
    notifyObservers(this.mode());
  }
  public String mode() {

    if ((mode.equals("Drawing"))&&leftFlick) 
    {
      leftFlick = false;
      Wheel.initialize(width, 0);
      return mode = "ColorControl";
    } 
    else if (mode.equals("Drawing")&&saved) {
      saved = false;
      return mode = "Save";
    }
    else if ((mode.equals("ColorIsChanging") && !change )) 
    {
      return mode = "ColorControl";
    } 
    else if ((mode.equals("Drawing"))&&rightFlick) 
    {
      control.initialize(0, 0);
      rightFlick = false;
      return mode = "SizeControl";
    } 
    else if ((mode.equals("SizeIsChanging") && !change ))
    {
      return mode = "SizeControl";
    } 
    else if ((mode.equals("ColorControl"))&&change )
    {
      return mode = "ColorIsChanging";
    } 
    else if ((mode.equals("SizeControl"))&&change )
    {
      return mode = "SizeIsChanging";
    }
    else if ((mode.equals("Drawing"))&&rotating) 
    {
      return mode = "Rotating";
    } 
    else if ((mode.equals("Rotating"))&&!rotating)
    {
      return mode = "Drawing";
    } 
    else if ((mode.equals("ColorControl")||mode.equals("SizeControl"))&&(rightFlick||leftFlick)) 
    {
      change  = false;
      rightFlick=false;
      leftFlick=false;
      
      canvas.restore(0, 0);
      mode = "Drawing";
      return "Delay";
    } 
    else if ((mode.equals("Drawing"))&& accelerometerZ<-9) 
    {
      return "Clean";
    } 
    else if ((mode.equals("ColorControl")||mode.equals("SizeControl")) && add) 
    {
      add = false;
      rotating = false;
      return "AddTemplate";
    }
    

    return mode;
  }
}



public int computeAngle(float[] g) 
{
  int rotation ;
  float norm_Of_g = sqrt(g[0] * g[0] + g[1] * g[1] + g[2] * g[2]);

  // Normalize the accelerometer vector
  g[0] = g[0] / norm_Of_g;
  g[1] = g[1] / norm_Of_g;
  g[2] = g[2] / norm_Of_g;

  rotation = (int)round(degrees(atan2(g[0], g[1])));
  
  return rotation;
}
public void onLongPress(float x, float y)
{
  sens.saved = true;
  //String name = Integer.toString(millis())+".jpg";
  //canvas.saveImage(name);
}


public void onDoubleTap(float x, float y) 
{
  if (sens.mode.contains("Color") ||sens.mode.contains("Size") )

    sens.change  = !sens.change ;

  println("CHANGED");
}

public void onLightEvent(float v)
{
  light = v;
}


public void onAccelerometerEvent(float x, float y, float z)
{
  accelerometerX = x;
  accelerometerY = y;
  accelerometerZ = z;
  g[0] = x;
  g[1] = y;
  g[2] = z;
}
public void onMagneticFieldEvent(float x, float y, float z, long time, int accuracy)
{
  magneticField.set(x, y, z);
  c[0] = x;
  c[1] = y;
  c[2] = z;
}

public void onFlick( float x, float y, float px, float py, float v)
{
  if ((abs(y-py)<80)&&y<80) {
    if (x-px>0)
    {
      sens.rightFlick = true;
      println("right");
    } else {
      sens.leftFlick = true;
      println("left");
    }
  } else
  {
    sens.rightFlick = false;
    sens.leftFlick = false;
  }

  //left: minus
  //right: plus
}

public boolean surfaceTouchEvent(MotionEvent event) {

  // //call to keep mouseX, mouseY, etc updated
  super.surfaceTouchEvent(event);
  if (!sens.gotThree&&event.getPointerCount()==3) 
  {
    sens.rotating = !sens.rotating;
    sens.gotThree = true;

    if (!sens.rotating)
    {
      canvas.save(computeAngle(g), width/2, height/2);
    }
  } else if (!sens.gotThree && event.getPointerCount()!=3) 
  {
    sens.gotThree = false;
  } 
  points.clear();

  if (event.getActionMasked() == MotionEvent.ACTION_UP) 
  {
    points.clear();
    if (sens.gotThree) sens.add = true;
    sens.gotThree = false;
  }

  return gesture.surfaceTouchEvent(event);
}
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

  public void draw() {
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
  public void help() {
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

  public void update(Observable obj, Object s) {

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

  boolean isFlicked;
  int x;
  int y;
  int w;
  int h;
  String msg;
  int col = color(235, 180, 180);

  Option( int x, int y, int w, int h, String msg) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.msg = msg;
  }

  public void draw() {
    //background(255);
    rectMode(CENTER);
    fill(col);
    strokeWeight(4);
    stroke(120);
    rect(x, y, w, h);
  }

  public void isPressed() {

    if (mousePressed) {

      if (mouseX<x+w/2&&mouseX>x-w/2&&mouseY<y+h/2&&mouseY>y-h/2) {

        println(msg);
        setChanged();
        notifyObservers(msg);
      }
    }
  }

  public void changeState(int col) {
    this.col = col;
  }
}
  public void settings() {  fullScreen(); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "CompassBrush" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
