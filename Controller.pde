abstract class Controller {

  float beginX;  // Initial x-coordinate
  float beginY;  // Initial y-coordinate
  float endX = width/2 ;  // Final x-coordinate
  float endY = height/2 - 200 ;  // Final y-coordinate
  float distX;          // X-axis distance to move
  float distY;          // Y-axis distance to move
  float exponent = 4;   // Determines the curve
  float xpos = 0.0;        // Current x-coordinate
  float ypos = 0.0;        // Current y-coordinate
  float step = 0.03;    // Size of each step along the path
  float pct = 0.0;      // Percentage traveled (0.0 to 1.0)

  Controller() {
  }

  abstract void draw(); 
  {
  }

  abstract void start(); 
  {
  }

  void initialize(float beginX, float beginY) {
    this.beginX = beginX;  // Initial x-coordinate
    this.beginY = beginY;  // Initial y-coordinate
    endX = width/2 ;  // Final x-coordinate
    endY = height/2  - 200 ;  // Final y-coordinate
    pct = 0.0;      // Percentage traveled (0.0 to 1.0)
    distX = endX - beginX;
    distY = endY - beginY;
  }

  /* Show brushes templates */
  void showBrushes() {
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
        color col = brushes.get(i).getColor();
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
  private color currentColor;
  PImage img= loadImage("colorWheel.png");

  colorWheel(int size)
  {
    this.size = size;
    radius = 0.95*this.size/2;
    currentColor = brush.currentColor;

    imageMode(CENTER);
    distX = endX - beginX;
    distY = endY - beginY;
  }


  void draw()
  {

    background(255, 240, 245);
    rectMode(CENTER);
    fill(127);
    noStroke();

    rect(width/2, 30, width, 60);

    /* Y = x^4 trajectory */

    if (pct < 1.0) {
      pct += step;

      xpos = beginX + (pct * distX);
      ypos = beginY + (pow(pct, exponent) * distY);
    }

    image(img, xpos, ypos, size, size);
    fill(255);
    /*white ellipse in the middle */
    ellipse(xpos, ypos, 80, 80);
    fill(0);
    /*black ellipse in the middle */
    ellipse(xpos, ypos, 35, 35);
    fill(currentColor);
    strokeWeight(1);
    stroke(0);
    /*current brush*/
    brush.show((int)xpos, (int)ypos - 500);
    super.showBrushes();

    noStroke();
  }

  void start() 
  {
    float angle = abs(360.0/30*magneticField.x);
    float x = cos(radians(angle)) * radius; //convert angle to radians for x and y coordinates
    float y = sin(radians(angle)) * radius;

    float delta = min(light/100.0, 1.0);

    setCurrentColor(get((int)xpos+(int)(x*delta), (int)ypos+(int)(y*delta)));
    /***********************************************/
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
    /**********************************************/
  }

  void setCurrentColor(color c)
  {
    this.currentColor = c;
  }

  int getCurrentColor() 
  {
    return this.currentColor;
  }
}

class sizeControl extends Controller {

  color c;


  sizeControl() {
  }

  void draw() {
    background(255, 240, 245);
    rectMode(CENTER);
    noStroke();

    fill(127);
    rect(width/2, 30, width, 60);

    /* Y = x^4 trajectory */

    if (pct < 1.0) {
      pct += step;

      xpos = beginX + (pct * distX);
      ypos = beginY + (pow(pct, exponent) * distY);
    }
    noFill();
    stroke(127);
    strokeWeight(3);
    ellipse(xpos, ypos, 400, 400);
    strokeWeight(2);
    /*current brush*/

    brush.show((int)xpos, (int)ypos);
    super.showBrushes();

    noStroke();
  }
  void start() {

    brush.show((int)xpos, (int)ypos);
  }
}