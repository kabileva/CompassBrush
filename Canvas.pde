class Canvas {
  
  Lines lines;
  ArrayList<PVector> colors;
  IntList diams;
  ArrayList<PVector> line;

  Canvas()
  {
    reset();
  }

  void restore(int xDelta, int yDelta) 
  {
    background(255);
    noStroke();
    
    for (int i = 0; i < lines.getSize(); i++) {
      for (int j = 1; j < lines.getLine(i).size(); j++) 
      {
       
        PVector p = lines.getPoint(i, j-1);
        PVector p2 = lines.getPoint(i, j);
        color col = color(colors.get(i).x, colors.get(i).y, colors.get(i).z);
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

  void save(int angle, int xDelta, int yDelta) 
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
    delay(1000);
    println("ROTATION SAVED");
  }
  void newLine() {
    line = new ArrayList<PVector>();
  }

  void addPoint(PVector p) 
  {
    line.add(p);
  }
  void addLine() {
    lines.addLine(line);
  }
  void addColor(PVector col)
  {
    colors.add(col);
  }

  void addDiam(int diam)
  {
    diams.append(diam);
  }

  void reset()
  {

    lines = new Lines();
    line = new ArrayList<PVector>();
    colors = new ArrayList<PVector>();
    diams = new IntList();
  }

  void rotateCanvas(int angle) 
  {
    pushMatrix();
    translate(width/2, height/2);
    rotate(radians(angle));
    this.restore(width/2, height/2);
    popMatrix();
  }

  void move(int xpos, int ypos)
  {
    int xDelta = mouseX - xpos;
    int yDelta = mouseY - ypos;
    pushMatrix();
    translate(xDelta, yDelta);
    this.restore(0, 0);
    popMatrix();
  }


  void saveImage(String filename) {
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
  void addLine(ArrayList<PVector> line) {
    lines.add(line);
  }

  void setPoint(int i, int j, PVector p) {
    lines.get(i).set(j, p);
  }

  ArrayList<PVector> getLine(int i) {
    return lines.get(i);
  }

  PVector getPoint(int i, int j) {
    return lines.get(i).get(j);
  }

  float getX(int i, int j) {
    return getPoint(i, j).x;
  }
  float getY(int i, int j) {
    return getPoint(i, j).y;
  }

  int getSize() {
    return lines.size();
  }
}