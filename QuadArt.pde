import toxi.color.*;
import toxi.color.theory.*;
import toxi.util.datatypes.*;
import java.util.Iterator;

ColorList cList;
TColor currentColor;
ColorTheoryStrategy currentTheory;
ArrayList colorStrategies;
Iterator I_theories;
PGraphics img;
int[] colorMap;

int WIDTH = 1024;
int WHITE_PCT = 5;

int w = 50;
int h = int(w / 1.6);
int init_s = WIDTH/w;
int s = init_s;

// x, y, radius, gravity (0-100)
int[][] magnets = {
  {
    0, 0, 10
  }
  , {
    0, 0, 10
  }
  , {    
    w, 0, 20
  }
  , {
    0, h, 20
  }
  , {
    w, h, 20
  }
};



void setup() {

  size((w * s), (h * s) );
  img = createGraphics((w * s), (h * s));
  noStroke();
  noLoop();

  colorStrategies = ColorTheoryRegistry.getRegisteredStrategies();
  currentTheory = ColorTheoryRegistry.MONOCHROME;
  currentColor = randomizeColor();
  cList = createColorList(currentTheory, currentColor);

  colorMap = colorMap(cList);
  resetStrategy();
}

int[] colorMap(ColorList cList) {
  int[] map = new int[cList.size()];
  float n;
  for (int i=0;i<cList.size();i++) {
    //float n = (float) i / cList.size();
    if (floor(random(0, 100/WHITE_PCT)) == 0) {
      map[i] = 0;
    } 
    else {
      n = random(1);
      map[i] = floor(map(n, 0, 1, 0, cList.size()-1));
    }
    // map[i] = i;
    //  println(map[i]);
    //exit();
  }
  return map;
}

void draw() {
  magnets[0][0] = mouseX/s;
  magnets[0][1] = mouseY/s;
  background(0); 
  noStroke();
  h = int(w / 1.6);
  s = WIDTH/w;
  //
  cList = createColorList(currentTheory, currentColor);

  paintQuads(cList);
  fill(currentColor.toARGB());
  rect(0, 0, s, s);
  // magenet indicator
  stroke(255, 0, 0);
  noFill();
  ellipse(mouseX, mouseY, magnets[0][2]*s, magnets[0][2]*s);
}

void paintQuads(ColorList cList) {
  int row = 0;
  int col = 0;
  int g;

  pushMatrix();
  for (int i = 1; i <= w*h; i++) {

    g = gravityToClosestMagnet(row, col);
    if (g>0) {
      fill(cList.get((int)random(g, cList.size()-1)).toARGB());
    } 
    else {
      fill(cList.getRandom().toARGB());
    }

    //    fill(getRandColor(gravityToClosestMagnet(row, col)));
    rect(0, 0, s, s);
    col++;    
    translate(s, 0);

    if (i % w == 0) {
      popMatrix();
      pushMatrix();
      row++;
      translate(0, row * s);
      col = 0;
    }
  }
  popMatrix();
}

int gravityToClosestMagnet(int row, int col) {
  int d, x, y = 0;
  float g, max_g = 0;

  for (int i=0;i<magnets.length;i++) {
    x = magnets[i][0];
    y = magnets[i][1];
    d = (int)sqrt(pow(abs(row-y), 2) + pow(abs(col-x), 2));

    if (d>magnets[i][2]) {
      g = 0;
    } 
    else {
      g = map(d, 0, magnets[i][2], cList.size()-1, 0);
    }
    max_g = max(g, max_g);
  }
  // g can never be > 100
  return floor(max_g);
}

color getRandColor(float g) {
  if (floor(random(0, 100/WHITE_PCT)) == 0) {
    return cList.getLightest().toARGB();
  }
  int rnd = (int)random(map(g, 0, 100, 0, cList.size()-1), cList.size()-1);
  return cList.get(rnd).toARGB();
}


ColorList createColorList(ColorTheoryStrategy currentTheory, TColor currentColor) {
  ColorList c = ColorList.createUsingStrategy(currentTheory, currentColor);
  return new ColorRange(c).getColors(null, w*h, 1).sortByCriteria(AccessCriteria.LUMINANCE, true);
}

TColor randomizeColor() {
  return TColor.newRandom();
}

ColorTheoryStrategy resetStrategy() {
  I_theories = colorStrategies.iterator();
  return nextTheory();
}

ColorTheoryStrategy nextTheory() {
  if (!I_theories.hasNext()) {
    return resetStrategy();
  }
  return (ColorTheoryStrategy) I_theories.next();
}

void keyPressed() {
  if (key == 'c') {
    currentColor = randomizeColor();
  }
  if (key == 't') {
    currentTheory = nextTheory();
  }  
  if (key == '0') {
    currentTheory = resetStrategy();
  }   
  //@todo creates ArrayIndexOutOfBoundsException
  if (key == '+') {
    //w++;
  }  
  if (key == '-' && w > 5) {
    w--;
  }  
  if (key == 's') {
    save("quads_" + currentTheory.getName() + "_" + currentColor.toARGB() +".png");
  }
  //colorMap = colorMap(cList);
  redraw();
}

void mouseMoved() {
  redraw();
} 

