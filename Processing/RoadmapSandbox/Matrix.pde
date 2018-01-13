/* The Matrix class contains most of the methods and objects 
 * needed to compute and render our sandbox application.
 * If you wanted to write your own application, you might
 * start by using the Matrix class as a template.
 */

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
  /* WEIGHT_CUT is the number of discrete ways allowed to differentiate connectivity between two roadmaps.
   * 5 - Figures of Merit (FOMs) Model Shared
   * 4 - Figures of Merit (FOMs) Numbers Shared
   * 3 - Figures of Merit (FOMs) Identified
   * 2 - Bi -directional Dependencies Indentified
   * 1 - Uni-directional Dependencies Indentified
   * 0 - No Dependencies Indentified
   */
  
  // Dimension of each Lego cell in Pixels
  float cellW, cellH;
  
  // List of Objects describing Roadmaps and their Connections. 
  // Together, these are a network graph.
  ArrayList<RoadMap> maps;
  ArrayList<Edge> links;
  
  Matrix(int w, int h) {
    // Calculate the dimensions of a Lego cell in pixels
    cellW = float(w) / TABLE_U;
    cellH = float(h) / TABLE_V;
    
    // Initialize our parameters
    maps = new ArrayList<RoadMap>();
    links = new ArrayList<Edge>();
    randomMaps();
  }
  
  // Create Random Roadmap pieces (useful when debugging without Colortizer)
  void randomMaps() {
    maps.clear();
    for (int i=0; i<MAX_MAPS; i++) {
      int rotation = int(random(4));
      int u = int(random(GRID_U));
      int v = int(random(GRID_V));
      String name = "" + i;
      RoadMap m = new RoadMap(i, rotation, u, v, name);
      maps.add(m);
    }
    // Initialize linkages based upon Roadmaps
    initLinks();
  }
  
  // Translates Colortizer Input into Roadmap Pieces
  void decodePieces() {
    maps.clear();
    int id, rot;
    // Cycle through each 17x20 Table Grid
    for (int u=0; u<sandbox.GRID_U; u++) {
      for (int v=1; v<sandbox.GRID_V; v++) {
        id = tablePieceInput[u][v][0];
        rot = tablePieceInput[u][v][1];
        if (id >= 0) {
          RoadMap piece = new RoadMap( id, rot, u, v-1, "" + id );
          maps.add(piece);
        }
      }
    }
    // Initialize linkages based upon Roadmaps
    initLinks();
  }
  
  // Add/Remove a piece from a location
  void clickPiece(int id, float mX, float mY) {
    boolean removed = false;
    PVector uv = mouseToGrid(int(mX), int(mY));
    int clickU = int(uv.x);
    int clickV = int(uv.y);
    if (clickU>=0 && clickU<GRID_U && clickV>=0 && clickV<GRID_V) {
      int numRemoved = 0;
      // Check for duplicate id and position and remove
      for (int m=maps.size()-1; m>=0; m--) {
        if (maps.get(m).ID == id && maps.get(m).u == clickU && maps.get(m).v == clickV) {
          maps.remove(m);
          removed = true;
        }
      }
      // Check for existing piece and remove
      for (int m=maps.size()-1; m>=0; m--) {
        if (maps.get(m).u == clickU && maps.get(m).v == clickV) {
          maps.remove(m);
          removed = true;
        } 
      }
      // Check for duplicate id and remove
      for (int m=maps.size()-1; m>=0; m--) {
        if (maps.get(m).ID == id && (maps.get(m).u != clickU || maps.get(m).v != clickV) && !removed) {
          maps.remove(m);
          // don't count duplicates as removed
        }
      }
      // Add a Piece if another Piece was not removed
      if (!removed) {
        RoadMap piece = new RoadMap( id, 0, clickU, clickV, "" + id );
        maps.add(piece);
      }
    }
    // Initialize linkages based upon Roadmaps
    initLinks();
  }
  
  // Convert pixel position into Lego grid position
  PVector mouseToGrid(int mX, int mY) {
    int u = int(mX/cellW) - MARGIN_U;
    int v = int(mY/cellH) - MARGIN_V;
    return new PVector(u,v);
  }
  
  // Retreat the specific position in the list of a Roadmap object with a particular ID
  int getMapIndex(int id) {
    int index = 0;
    for (int m=0; m<maps.size(); m++) {
      if (maps.get(m).ID == id) index = m;
    }
    return index;
  }
  
  // Initialize linkages based upon Roadmaps
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
  
  // The majority of our application's draw functions are located within render()
  void render(PGraphics p) {
    p.stroke(255, 50); // Define line colors as "white"
    p.strokeWeight(3); // Define Line thickness as "2"
    
    if (gridLines) {
      // GRID: Draw Vertical Grid Lines
      for (int u=0; u<=GRID_U; u++) {
        p.line((MARGIN_U + u)*cellW, MARGIN_V*cellH, (MARGIN_U + u)*cellW, (MARGIN_V+GRID_V)*cellH);
      }
      
      // GRID: Draw Horizontal Grid Lines
      for (int v=0; v<=GRID_V; v++) {
        p.line(MARGIN_U*cellW, (MARGIN_V + v)*cellH, (MARGIN_U + GRID_U)*cellW, (MARGIN_V + v)*cellH);
      }
    }
    
    // GRID: Draw Links + Weights
    for (Edge l: links) {
      if (l.weight < WEIGHT_CUT) {
        p.pushMatrix();
        p.translate( (MARGIN_U + 0.5) * cellW, (MARGIN_V + 0.5) * cellH );
        p.strokeCap(ROUND);
        p.strokeWeight(pow(WEIGHT_CUT - l.weight, 1.1) + 2);
        p.stroke(255, 255*float(WEIGHT_CUT-l.weight)/WEIGHT_CUT);
        p.line(l.u0*cellW, l.v0*cellH, l.uF*cellW, l.vF*cellH);
        p.popMatrix();
      }
    }
    
    // Sometimes ending and beginning a draw session allows layers and opacities to render correctly ...
    p.endDraw();
    p.beginDraw();
    
    // GRID: Draw Roadmap Tiles + Attributes
    for (RoadMap m: maps) {
      p.pushMatrix();
      p.translate((MARGIN_U + m.u)*cellW, (MARGIN_V + m.v)*cellH);
      
      // GRID: Draw Shape on Lego Tile 
      p.fill( 0 );
      p.stroke(m.col, 100);
      p.strokeWeight(5);
      p.ellipse( 0.5*cellW, 0.5*cellH, 0.9*cellW, 0.9*cellH );
      
      // GRID: Rotate Coordinate Systems
      p.pushMatrix();
      p.translate(0.5*cellW, 0.5*cellH);
      p.rotate(-m.rotation*0.5*PI);
      
      // GRID: Draw Arrow
      p.fill( m.col );
      p.noStroke();
      p.triangle(0, -0.5*cellW, 0.5*cellW, 0, -0.5*cellW, 0);
      
      // GRID: Draw ID Text
      p.textSize(24);
      p.fill(255);
      p.textAlign(CENTER, CENTER);
      p.text(m.name, 0, 0.17*cellH );
      p.popMatrix();
      
      p.popMatrix();
    }
    
    // MARGIN: Draw Title and Explanations in Left-Hand Margin
    p.fill(255);
    p.textAlign(LEFT, TOP);
    p.textSize(40);
    p.text("RoadMap\nSandbox", 10, MARGIN_V*cellW);
    p.textSize(25);
    p.text("Design\nStructure\nMatrix\n\nPrototype by\nAirbus XP\nOCD", 10, 3.5*cellW);
    p.textSize(20);
    p.text("Roadmaps, represented by numbered tiles, are interconnected technology strategies. " +
           "Move RoadMap tiles closer to each other to increase their relative dependence upon each other.", 
           10, 9*cellW, MARGIN_U*cellW - 20, TABLE_V*cellW);
    
    // SUMMARY: Draw Summary Martix in Bottom of Left-Hand Margin
    float sumCellW = 0.95*MARGIN_U * cellW / (maps.size() + 1);
    p.pushMatrix();
    p.translate(0, (TABLE_V - MARGIN_V)*cellW - sumCellW*(maps.size()+1));
    
    // SUMMARY: Draw Legend
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
      p.textSize(0.8*sumCellW);
      p.textAlign(CENTER, CENTER);
      p.text(maps.get(m).ID, (m + 1.5)*sumCellW, 0.4*sumCellW); // Horizontal Axis
      p.text(maps.get(m).ID, 0.5*sumCellW, (m + 1.4)*sumCellW); // Vertical Axis
    }
    
    // SUMMARY: Draw Links / Edge / Connection Weights
    for (Edge l: links) {
      if (l.weight < WEIGHT_CUT) {
        p.pushMatrix();
        p.translate(sumCellW*(1+getMapIndex(l.ID_0)), sumCellW*(1+getMapIndex(l.ID_F)));
        p.fill(255*float(WEIGHT_CUT-l.weight)/WEIGHT_CUT);
        p.noStroke();
        p.rect(0, 0, sumCellW, sumCellW);
        p.popMatrix();
      }
    }
    
    // SUMMARY: Draw selection box around selected RoadMap
    p.noFill();
    p.stroke(255);
    p.strokeWeight(3);
    int m = getMapIndex(selectedID);
    p.rect((m + 1)*sumCellW, 0, sumCellW, (m + 2)*sumCellW); // Horizontal Axis
    p.rect(0, (m + 1)*sumCellW, (m + 2)*sumCellW, sumCellW); // Vertical Axis
    p.popMatrix();
    
  }
}

// A global variable to determine which roadmap ID to use when clicking
int selectedID = 0;
// Maximum Number of Roadmaps Expected
int MAX_MAPS = 16;

// The Roadmap Class functions as the "Nodes" in our netowrk.
class RoadMap {
  int ID;
  int u, v;
  String name;
  color col;
  int rotation; // 0, 1, 2, 3
  
  RoadMap(int ID, int rotation, int u, int v, String name) {
    this.ID = ID;             // ID of roadmap
    this.rotation = rotation; // rotation of piece (0, 1, 2, or 3 representing 90-degree intervals)
    this.u = u;               // u-coordinate upon table
    this.v = v;               // v-coordinate upon table
    this.name = name;         // human-friendly name of Roadmap
    
    colorMode(HSB);
    col = color(255.0 * ID / MAX_MAPS, 255, 255); // Color of Roadmap
    colorMode(RGB);
  }
}

// The Edge Class describes the nature of the connections in our network
class Edge {
  int u0, v0, uF, vF;
  int ID_0, ID_F;
  int weight;
  
  Edge(int u0, int v0, int ID_0, int uF, int vF, int ID_F) {
    this.u0 = u0;      // u coordinate of origin node
    this.v0 = v0;      // v coordinate of origin node
    this.ID_0 = ID_0;  // ID of origin node
    this.uF = uF;      // u coordinate of destination node
    this.vF = vF;      // v coordinate of destination node
    this.ID_F = ID_F;  // ID of destination node
    
    // Calculate strength of connection based upon the "city block" 
    // distance (i.e. calculated as orthogonal path)
    weight = abs(uF-u0) + abs(vF-v0) - 2;
  }
}
