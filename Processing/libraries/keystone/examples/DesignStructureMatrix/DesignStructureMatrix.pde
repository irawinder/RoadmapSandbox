/**
 * This is a simple example of how to use the Keystone library.
 *
 * To use this example in the real world, you need a projector
 * and a surface you want to project your Processing sketch onto.
 *
 * Simply drag the corners of the CornerPinSurface so that they
 * match the physical surface's corners. The result will be an
 * undistorted projection, regardless of projector position or 
 * orientation.
 *
 * You can also create more than one Surface object, and project
 * onto multiple flat surfaces using a single projector.
 *
 * This extra flexbility can comes at the sacrifice of more or 
 * less pixel resolution, depending on your projector and how
 * many surfaces you want to map. 
 */

import deadpixel.keystone.*;

Keystone ks;
CornerPinSurface surface;

PGraphics offscreen;

Matrix table;

void setup() {
  // Keystone will only work with P3D or OPENGL renderers, 
  // since it relies on texture mapping to deform
  size(800, 500, P3D);

  ks = new Keystone(this);
  surface = ks.createCornerPinSurface(1200 , 1200, 20);
  
  // We need an offscreen buffer to draw the surface we
  // want projected
  // note that we're matching the resolution of the
  // CornerPinSurface.
  // (The offscreen buffer can be P2D or P3D)
  offscreen = createGraphics(1200, 1200, P3D);
  
  table = new Matrix(offscreen.width, offscreen.height);
  
  ks.load();
}

void draw() {

  // Convert the mouse coordinate into surface coordinates
  // this will allow you to use mouse events inside the 
  // surface from your screen. 
  PVector surfaceMouse = surface.getTransformedMouse();

  // Draw the scene, offscreen
  offscreen.beginDraw();
  offscreen.background(0);
  table.render(offscreen);
  offscreen.endDraw();

  // most likely, you'll want a black background to minimize
  // bleeding around your projection area
  background(0);

  // render the scene, transformed using the corner pin surface
  surface.render(offscreen);
}

class Matrix {
  
  // Offset of grif from upper left corning in Lego Cells
  int MARGIN_U = 4;
  int MARGIN_V = 1;
  
  // Dimension of Table in Lego Cells
  int TABLE_U = 22;
  int TABLE_V = 22;
  
  // Dimensions of the grid in Lego Cells
  int GRID_U = 17;
  int GRID_V = 20;
  
  int WEIGHT_CUT = 6;
  
  // Dimension of each cell in Pixels
  float cellW, cellH;
  
  ArrayList<RoadMap> maps;
  ArrayList<Edge> links;
  
  Matrix(int w, int h) {
    cellW = float(w) / TABLE_U;
    cellH = float(h) / TABLE_V;
    
    maps = new ArrayList<RoadMap>();
    links = new ArrayList<Edge>();
    initMaps();
    initLinks();
  }
  
  // reset random pieces
  void initMaps() {
    maps.clear();
    for (int i=0; i<10; i++) {
      RoadMap m = new RoadMap(i, int(random(4)), int(random(GRID_U)), int(random(GRID_V)), "" + i);
      maps.add(m);
    }
  }
  
  // generate edges for given Roadmap Space
  void initLinks() {
    links.clear();
    // Interates through every link in the network
    for (int i=0; i<maps.size(); i++) {
      for (int f=0; f<maps.size(); f++) {
        if (i != f) {
          Edge l = new Edge(maps.get(i).u, maps.get(i).v, maps.get(i).ID, maps.get(f).u, maps.get(f).v, maps.get(f).ID);
          links.add(l);
        }
      }
    }
  }
  
  void render(PGraphics p) {
    
    p.stroke(255);
    p.strokeWeight(2);
    
    // Vertical Grid Lines
    for (int u=0; u<=GRID_U; u++) {
      p.line((MARGIN_U + u)*cellW, MARGIN_V*cellH, (MARGIN_U + u)*cellW, (MARGIN_V+GRID_V)*cellH);
    }
    
    // Horizontal Grid Lines
    for (int v=0; v<=GRID_V; v++) {
      p.line(MARGIN_U*cellW, (MARGIN_V + v)*cellH, (MARGIN_U + GRID_U)*cellW, (MARGIN_V + v)*cellH);
    }
    
    // Draw Links + Weights
    for (Edge l: links) {
      if (l.weight < WEIGHT_CUT) {
        p.pushMatrix();
        p.translate( (MARGIN_U + 0.5) * cellW, (MARGIN_V + 0.5) * cellH );
        p.strokeCap(ROUND);
        p.strokeWeight(pow(WEIGHT_CUT - l.weight, 1.5) + 2);
        p.stroke(255, 255*float(2*WEIGHT_CUT-l.weight)/WEIGHT_CUT);
        p.line(l.u0*cellW, l.v0*cellH, l.uF*cellW, l.vF*cellH);
        p.popMatrix();
      }
    }
    
    p.endDraw();
    p.beginDraw();
    
    // Draw Roadmap Tiles + Attributes
    for (RoadMap m: maps) {
      p.pushMatrix();
      p.translate((MARGIN_U + m.u)*cellW, (MARGIN_V + m.v)*cellH);
      
      // Draw Square
      p.fill( 0 );
      p.stroke(m.col, 100);
      p.strokeWeight(5);
      p.ellipse( 0.5*cellW, 0.5*cellH, 0.9*cellW, 0.9*cellH );
      
      //Rotate Coordinate Systems
      p.pushMatrix();
      p.translate(0.5*cellW, 0.5*cellH);
      p.rotate(m.rotation*0.5*PI);
      // Draw Arrow
      p.fill( m.col );
      p.noStroke();
      p.triangle(0, -0.5*cellW, 0.5*cellW, 0, -0.5*cellW, 0);
      // Draw ID Text
      p.textSize(24);
      p.fill(255);
      p.textAlign(CENTER, CENTER);
      p.text(m.name, 0, 0.17*cellH );
      p.popMatrix();
      
      p.popMatrix();
    }
    
    // Draw Title
    p.fill(255);
    p.textAlign(LEFT, TOP);
    p.textSize(40);
    p.text("RoadMap\nSandbox", 10, MARGIN_V*cellW);
    p.textSize(25);
    p.text("Design\nStructure\nMatrix\n\nPrototype by\nAirbus XP\nOCD", 10, 3.5*cellW);
    
    // Draw Summary Martix in Margin
    float sumCellW = MARGIN_U * cellW / (maps.size() + 1);
    p.pushMatrix();
    p.translate(0, (TABLE_V - MARGIN_V)*cellW - sumCellW*(maps.size()+1));
    // Draw Legend
    p.fill(255);
    p.textAlign(CENTER, CENTER);
    p.text("RoadMap Origin", 0.55*MARGIN_U*cellW, -25);
    for (int m=0; m<maps.size(); m++) {
      //Rectangle background
      p.fill(maps.get(m).col);
      p.rect((m + 1)*sumCellW, 0, sumCellW, sumCellW); // Horizontal Axis
      p.rect(0, (m + 1)*sumCellW, sumCellW, sumCellW); // Vertical Axis
      //Text
      p.fill(0);
      p.textSize(sumCellW);
      p.textAlign(CENTER, CENTER);
      p.text(maps.get(m).ID, (m + 1.5)*sumCellW, 0.5*sumCellW); // Horizontal Axis
      p.text(maps.get(m).ID, 0.5*sumCellW, (m + 1.5)*sumCellW); // Vertical Axis
    }
    // Draw Links / Edge / Connection Weights
    for (Edge l: links) {
      if (l.weight < WEIGHT_CUT) {
        p.pushMatrix();
        p.translate(sumCellW*(1+l.ID_0), sumCellW*(1+l.ID_F));
        p.fill(255*float(WEIGHT_CUT-l.weight)/WEIGHT_CUT);
        p.noStroke();
        p.rect(0, 0, sumCellW, sumCellW);
        p.popMatrix();
      }
    }
    p.popMatrix();
    
  }
}

class RoadMap {
  int ID;
  int u, v;
  String name;
  color col;
  int rotation; // 0, 1, 2, 3
  
  RoadMap(int ID, int rotation, int u, int v, String name) {
    this.ID = ID;
    this.rotation = rotation;
    this.u = u;
    this.v = v;
    this.name = name;
    colorMode(HSB);
    col = color(255 * float(ID) / 16, 255, 255);
    colorMode(RGB);
  }
}

class Edge {
  int u0, v0, uF, vF;
  int ID_0, ID_F;
  int weight;
  
  Edge(int u0, int v0, int ID_0, int uF, int vF, int ID_F) {
    this.u0 = u0;
    this.v0 = v0;
    this.ID_0 = ID_0;
    this.uF = uF;
    this.vF = vF;
    this.ID_F = ID_F;
    
    weight = abs(uF-u0) + abs(vF-v0);
  }
}

void keyPressed() {
  switch(key) {
  case 'c':
    // enter/leave calibration mode, where surfaces can be warped 
    // and moved
    ks.toggleCalibration();
    break;

  case 'l':
    // loads the saved layout
    ks.load();
    break;

  case 's':
    // saves the layout
    ks.save();
    break;
  
  case 'r':
    // Reinitializes Random Maps
    table.initMaps();
    table.initLinks();
    break;
    
  }
}
