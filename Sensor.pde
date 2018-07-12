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

  void press() {
    setChanged();
    notifyObservers(this.mode());
  }
  String mode() {

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



int computeAngle(float[] g) 
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
void onLongPress(float x, float y)
{
  sens.saved = true;
  //String name = Integer.toString(millis())+".jpg";
  //canvas.saveImage(name);
}


void onDoubleTap(float x, float y) 
{
  if (sens.mode.contains("Color") ||sens.mode.contains("Size") )

    sens.change  = !sens.change ;

  println("CHANGED");
}

void onLightEvent(float v)
{
  light = v;
}


void onAccelerometerEvent(float x, float y, float z)
{
  accelerometerX = x;
  accelerometerY = y;
  accelerometerZ = z;
  g[0] = x;
  g[1] = y;
  g[2] = z;
}
void onMagneticFieldEvent(float x, float y, float z, long time, int accuracy)
{
  magneticField.set(x, y, z);
  c[0] = x;
  c[1] = y;
  c[2] = z;
}

void onFlick( float x, float y, float px, float py, float v)
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

/*Have some errors when I try to use 
* it for better rotation
* angle calculatiton *
*/

/*
import java.lang.Object*;
public void onSensorChanged(SensorEvent event) {
    if (event.sensor.getType() == Sensor.TYPE_ACCELEROMETER)
        mGravity = event.values;
    if (event.sensor.getType() == Sensor.TYPE_MAGNETIC_FIELD)
        mGeomagnetic = event.values;
    if (mGravity != null && mGeomagnetic != null) {
       float R[] = new float[9];
       float I[] = new float[9];
       boolean success = SensorManager.getRotationMatrix(R, I, mGravity, mGeomagnetic);
       if (success) {
         float orientation[] = new float[3];
         SensorManager.getOrientation(R, orientation);
         azimut = orientation[0]; // orientation contains: azimut, pitch and roll
         pitch = orientation[1];
         roll = orientation[2];
       }
    }
}

*/