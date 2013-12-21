import toxi.color.*;
import toxi.color.theory.*;
import toxi.util.datatypes.*;
import java.util.Iterator;

ColorList cList;
ColorRange cRange;
TColor currentColor;
ColorTheoryStrategy currentTheory;
ArrayList colorStrategies;
Iterator I_theories;
PGraphics img;

int w = 80;
int h = int(w / 1.6);
int init_s = 1280/w;
int s = init_s;
int WHITE_PCT = 10;

// x, y, radius, gravity (0-100)
int[][] magnets = {
  {
    0, 0, 30, 50
  }
  , {
    w, 0, 35, 80
  }
  , {
    0, h, 35, 80
  }
  , {
    w, h, 35, 30
  }
};



void setup() {
  
  size((w * s), (h * s) );
  img = createGraphics((w * s), (h * s));
  noStroke();
  noLoop();

  colorStrategies = ColorTheoryRegistry.getRegisteredStrategies();
  currentTheory = ColorTheoryRegistry.TRIAD;
  randomizeColor();
  resetStrategy();
}

void draw() {
  magnets[0][0] = mouseX/s;
  magnets[0][1] = mouseY/s;
  background(0); 
  noStroke();
  paintQuads();
  fill(currentColor.toARGB());
  rect(0, 0, s, s);
  // magenet indicator
  stroke(255,0,0);
  noFill();
  ellipse(mouseX, mouseY,magnets[0][3]*s, magnets[0][3]*s);  
}

void paintQuads() {
  int row = 0;
  int col = 0;

  pushMatrix();
  for (int i = 1; i <= w*h; i++) {
    //fill(cSortedList.get(i-1).toARGB());
    fill(getRandColor(gravityToClosestHill(row, col)));
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

float gravityToClosestHill(int row, int col) {
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
      g = map(d, 0, magnets[i][2], magnets[i][3], 0);
    }
    max_g = max(g, max_g);
  }
  // g can never be > 100
  return min(max_g, 100);
}

color getRandColor(float g) {
  if (floor(random(0, 100/WHITE_PCT)) == 0) {
    return cList.getLightest().toARGB();
    // return TColor.WHITE.toARGB();
  }
  int rnd = (int)random(map(g, 0, 100, 0, cList.size()-1), cList.size()-1);
  return cList.get(rnd).toARGB();
}


void createColorList() {
  cList = ColorList.createUsingStrategy(currentTheory, currentColor);
  cList = new ColorRange(cList).addBrightnessRange(0.5, 1).getColors(null, w*h, .5).sortByCriteria(AccessCriteria.LUMINANCE, true);
}

void randomizeColor() {
  currentColor = TColor.newRandom();
  createColorList();
}

void resetStrategy() {
  I_theories = colorStrategies.iterator();
  nextTheory();
}

void nextTheory() {
  if (!I_theories.hasNext()) {
    resetStrategy();
  }
  currentTheory = (ColorTheoryStrategy) I_theories.next();
  createColorList();
}

void keyPressed() {
  if (key == 'c') {
    randomizeColor();
  }
  if (key == 't') {
    nextTheory();
  }  
  if (key == '0') {
    resetStrategy();
  }   
  if (key == '+') {
    s++;
  }  
  if (key == '-' && s > init_s) {
    s--;
  }  
  if (key == 's') {
    save("quads_" + currentTheory.getName() + "_" + currentColor.toARGB() +".png");
  }
  redraw();
}

void mouseMoved() {
  redraw();

  //exit();
} 

