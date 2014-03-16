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

static final int WIDTH = 1024;
static final int WHITE_PCT = 5;
static final float MIN_COLOR_DIST = .2;

int w = 64;
int h = int(w / 1.6);
int init_s = WIDTH/w;
int s = init_s;
boolean actGravity = true;
boolean actOrder = false;

// x, y, radius, gravity (0-100)
float[][] magnets = {
  {
    w/2, h/2, .5, .7
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
  }
  return map;
}

void draw() {
  background(0); 
  noStroke();
  h = int(w / 1.6);
  s = WIDTH/w;
  //
  cList = createColorList(currentTheory, currentColor);
  //magnets[0][0] = mouseX/s;
  //magnets[0][1] = mouseY/s;
  paintQuads(cList);

  fill(currentColor.toARGB());
  rect(0, 0, s, s);
  // magnet indicator
  //  noFill();
  //  stroke(255, 0, 0);
  //  ellipse(mouseX, mouseY, magnets[0][2]*w*s, magnets[0][2]*w*s);
}

void paintQuads(ColorList cList) {
  int row = 0;
  int col = 0;
  int g;
  TColor c;
  ColorList map = new ColorList();

  pushMatrix();
  for (int i = 0; i < w*h; i++) {

    g = gravityToClosestMagnet(row, col);

    if (actOrder) {
      c = cList.get(i);
    } 
    else {
      do {

        if (actGravity && g>0) {
          c = cList.get((int)random(g, cList.size()-1));
        } 
        else {
          c = cList.getRandom();
        }
      } 
      while ( tooCloseColors (c, map, i, w));
      // add color to map
      map.add(c);
    }
    //define the fill color for the next quad
    fill(c.toARGB());
    rect(0, 0, s, s);
    col++;    
    translate(s, 0);

    if ((i+1) % w == 0) {
      popMatrix();
      pushMatrix();
      row++;
      translate(0, row * s);
      col = 0;
    }
  }
  popMatrix();
}

boolean tooCloseColors(TColor c, ColorList map, int i, int w) {
  if (i-w > 1) {
    return min(c.distanceToRGB(map.get(i-1)), c.distanceToRGB(map.get(i-w))) < MIN_COLOR_DIST;
  }  
  if (i > 1) {
    return c.distanceToRGB(map.get(i-1)) < MIN_COLOR_DIST;
  }

  return false;
}

int gravityToClosestMagnet(int row, int col) {
  int d, x, y = 0;
  float g, max_g = 0;

  for (int i=0;i<magnets.length;i++) {
    x = (int)magnets[i][0];
    y = (int)magnets[i][1];
    d = (int)sqrt(pow(abs(row-y), 2) + pow(abs(col-x), 2));

    if (d>magnets[i][2]*w) {
      g = 0;
    } 
    else {
      g = map(d, 0, magnets[i][2]*w, cList.size()*magnets[i][3]-1, 0);
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
  return new ColorRange(c).getColors(w*h).sortByProximityTo(currentColor, true);
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

  switch(key) {
  case 'c':
    currentColor = randomizeColor();
    break;
  case 't':
    currentTheory = nextTheory();
    break;
  case 'g':
    actGravity = !actGravity; 
    break;
  case 'o':
    actOrder = !actOrder; 
    break;    
  case '0':
    currentTheory = resetStrategy();
    break;
  case '+':
    w++;
    break;
  case '-':
    if (w > 5) {
      w--;
    }   
    break;
  case 's':
    save("quads_" + currentTheory.getName() + "_" + currentColor.toARGB() +".png");
    break;
  }   

  redraw();
}


