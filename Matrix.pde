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
    randomMaps();
  }
  
  // Create Random Roadmap pieces (useful when debugging without Colortizer)
  void randomMaps() {
    maps.clear();
    for (int i=0; i<10; i++) {
      RoadMap m = new RoadMap(i, int(random(4)), int(random(GRID_U)), int(random(GRID_V)), "" + i);
      maps.add(m);
    }
    initLinks();
  }
  
  // Translates Colortizer Input into Roadmap Pieces
  void decodePieces() {
    maps.clear();
    int id, rot;
    // Cycle through each 17x20 Table Grid
    for (int u=0; u<table.GRID_U; u++) {
      for (int v=1; v<table.GRID_V; v++) {
        id = tablePieceInput[u][v][0];
        rot = tablePieceInput[u][v][1];
        if (id >= 0) {
          RoadMap piece = new RoadMap( id, rot, u, v, "" + id);
          maps.add(piece);
        }
      }
    }
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
    table.initLinks();
  }
  
  PVector mouseToGrid(int mX, int mY) {
    int u = int(mX/cellW) - MARGIN_U;
    int v = int(mY/cellH) - MARGIN_V;
    return new PVector(u,v);
  }
  
  int getMapIndex(int id) {
    int index = 0;
    for (int m=0; m<maps.size(); m++) {
      if (maps.get(m).ID == id) index = m;
    }
    return index;
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
    
    // Draw Title and Explanations
    p.fill(255);
    p.textAlign(LEFT, TOP);
    p.textSize(40);
    p.text("RoadMap\nSandbox", 10, MARGIN_V*cellW);
    p.textSize(25);
    p.text("Design\nStructure\nMatrix\n\nPrototype by\nAirbus XP\nOCD", 10, 3.5*cellW);
    p.textSize(20);
    p.text("Roadmaps, represented by numbered tiles, are interconnected technology strategies. Move RoadMap tiles closer to each other to increase their relative dependence upon each other.", 
      10, 9*cellW, MARGIN_U*cellW - 20, TABLE_V*cellW);
    p.textAlign(CENTER, CENTER);
    p.text("Press 'r' to generate random Roadmap Configuration", (0.5*GRID_U+MARGIN_U)*cellW, (TABLE_V - 0.5)*cellW);
    p.text("Press number keys 0 - 9 to select a Roadmap ID", (0.5*GRID_U+MARGIN_U)*cellW, 0.5*cellW);
    
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
        p.translate(sumCellW*(1+getMapIndex(l.ID_0)), sumCellW*(1+getMapIndex(l.ID_F)));
        p.fill(255*float(WEIGHT_CUT-l.weight)/WEIGHT_CUT);
        p.noStroke();
        p.rect(0, 0, sumCellW, sumCellW);
        p.popMatrix();
      }
    }
    // Draw selection box around selected RoadMap
    p.noFill();
    p.stroke(255);
    p.strokeWeight(3);
    int m = getMapIndex(selectedID);
    p.rect((m + 1)*sumCellW, 0, sumCellW, (m + 2)*sumCellW); // Horizontal Axis
    p.rect(0, (m + 1)*sumCellW, (m + 2)*sumCellW, sumCellW); // Vertical Axis
    p.popMatrix();
    
    println(maps.size(), links.size());
    
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
    col = color(255 * float(ID) / 10, 255, 255);
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
