/* The file "myBrushes.xml should be put into phone's
* /sdcard/myApp/ directory in order the app to work
* permission to write/read to the external storage should be given
*/


import android.view.MotionEvent;
import ketai.ui.*;
import ketai.sensors.*;
import java.util.Observable;
import java.util.Observer;

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


void setup() {

  reset(); //initializing objects
  /* “/sdcard/” + filename */
  /*  instead of filename   */
  /*  or isn’t saved (needs permission to read/write to external storage */

  loadBrushes("/sdcard/myApp/myBrushes.xml");

  background(255);
  fullScreen();


  sensor = new KetaiSensor(this);
  sensor.start();
  gesture = new KetaiGesture(this);
  magneticField = new PVector();

  sens.addObserver(iface);
  sens.addObserver(brush);
}

void draw() {

  noStroke();
  sens.press();
}

void loadBrushes(String filename)
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
    color col = color(r, g, b);
    brushes.add(new Brush().ofSize(diam).ofColor(col));
  }
}

void exit() {
  saveBrushes("myBrushes.xml");
  super.exit();
}

void saveBrushes (String filename)
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

void reset() {

  brushes = new ArrayList<Brush>();

  points = new ArrayList<PVector>();
  menu = new Start();

  Wheel = new colorWheel(600);
  control = new sizeControl();
  sens = new Sensor();
  iface = new IFace();
}