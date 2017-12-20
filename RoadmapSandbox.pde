/**
 * RoadMap Sandbox, Dec 2017
 * Ira Winder, ira@mit.edu
 *
 * This is a simple example of a Roadmapping Exercise. 
 * This is a also a simple example of how to use the Keystone library.
 *
 * The Scripts may be "Run" on either
 *    (a) PC Screen and controlled with Mouse and keyboard
 *    (b) Tactile Matrix projection and controlled with Colortizer (i.e. Lego)
 */
 
// These are libraries and objects needed for projection mapping (i.e. Keystone Library Objects)
import deadpixel.keystone.*;
Keystone ks;
CornerPinSurface surface;
PGraphics offscreen;
PVector surfaceMouse;

// The matrix class holds the bulk of our application.
// We've created a new implementation of my class called "sandbox"
Matrix sandbox;

boolean helpText = true;
boolean gridLines = true;

void setup() {
  size(800, 500, P3D);
  //size(1920, 1080, P3D); // Airbus CDF Projector Resolution.  Use this size for your projector
  
  // Keystone will only work with P3D or OPENGL renderers, 
  // since it relies on texture mapping to deform
  // We need an offscreen buffer to draw the surface we
  // want projected
  // note that we're matching the resolution of the
  // CornerPinSurface.
  // (The offscreen buffer can be P2D or P3D)
  ks = new Keystone(this);
  surface = ks.createCornerPinSurface(1200 , 1200, 20);
  offscreen = createGraphics(1200, 1200, P3D);
  
  // Initialize the Core Application
  sandbox = new Matrix(offscreen.width, offscreen.height);
  
  // Initialize connection to webcam via "Colortizer"
  initUDP();
  
  // Load the previously saved projection-map calibration
  try {
    ks.load();
  } catch (Exception e) {
    ks.save();
    ks.load();
  }
}

void draw() {
  
  // Decode Lego pieces only if there is a change in Colortizer input
  if (changeDetected) {
    println("Input Detected");
    sandbox.decodePieces();
    changeDetected = false;
  }
  
  // Convert the mouse coordinate into surface coordinates
  // this will allow you to use mouse events inside the 
  // keystone surface from your screen. 
  surfaceMouse = surface.getTransformedMouse();
  
  // Draw the scene, offscreen
  offscreen.beginDraw();
  offscreen.background(0);
  // Render the application onto our projection canvas
  sandbox.render(offscreen);
  // Draw a mouse cursor
  offscreen.ellipse(surfaceMouse.x - 3, surfaceMouse.y - 9, 10, 10);
  offscreen.endDraw();

  // most likely, you'll want a black background to minimize
  // bleeding around your projection area
  background(0);

  // render the scene, transformed using the corner pin surface
  surface.render(offscreen);
  
  // Help Text
  if (helpText) {
    text("Press 'h' to hide/show this text.\n" +
         "Press 'g' to hide/show grid lines.\n\n\n" +
         "Projection Map Key Commands:\n\n" +
         "  Press 'c' to turn on calibration mode.\n" +
         "  Press 's' to save calibration.\n" +
         "  Press 'l' to load calibration.\n" +
         "  Use mouse to adjust.\n\n\n" +
         "Application Key Commands:\n\n" +
         "  Press 'r' for random configuration\n" +
         "  Press '0' - '9' to select ID", 20, 30, 300, height);
  }
}

void keyPressed() {
  switch(key) {
    
  case 'h':
    // toggle help text
    helpText = !helpText;
    break;
  
  case 'g':
    // toggle help text
    gridLines = !gridLines;
    break;
    
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
    sandbox.randomMaps();
    break;
  
  // Select ID
  case '0': selectedID = 0; break;
  case '1': selectedID = 1; break;
  case '2': selectedID = 2; break;
  case '3': selectedID = 3; break;
  case '4': selectedID = 4; break;
  case '5': selectedID = 5; break;
  case '6': selectedID = 6; break;
  case '7': selectedID = 7; break;
  case '8': selectedID = 8; break;
  case '9': selectedID = 9; break;
    
  }
}

void mousePressed() {
  sandbox.clickPiece(selectedID, surfaceMouse.x, surfaceMouse.y);
}

void mouseDragged() {
  sandbox.clickPiece(selectedID, surfaceMouse.x, surfaceMouse.y);
}
