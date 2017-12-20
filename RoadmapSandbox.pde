/**
 * This is a simple example of a Roadmapping Exercise.
 */

/**
 * This is a also a simple example of how to use the Keystone library.
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
  
  // Initialize the Core Application
  table = new Matrix(offscreen.width, offscreen.height);
  
  // Initialize Connection to "Colortizer"
  initUDP();
  
  // Load the saved coordinates for projection-map
  try {
    ks.load();
  } catch (Exception e) {
    println("Error locating keystone.xml file.  Try saving one with the 's' key.");
  }
}

void draw() {
  
  // Decode Lego pieces only if there is a change in Colortizer input
  if (changeDetected) {
    println("Input Detected");
    table.decodePieces();
    changeDetected = false;
  }
  
  // Convert the mouse coordinate into surface coordinates
  // this will allow you to use mouse events inside the 
  // surface from your screen. 
  PVector surfaceMouse = surface.getTransformedMouse();
  
  // Draw the scene, offscreen
  offscreen.beginDraw();
  offscreen.background(0);
  table.render(offscreen);
  offscreen.ellipse(surfaceMouse.x, surfaceMouse.y, 10, 10);
  offscreen.endDraw();

  // most likely, you'll want a black background to minimize
  // bleeding around your projection area
  background(0);

  // render the scene, transformed using the corner pin surface
  surface.render(offscreen);
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
    table.randomMaps();
    break;
    
  }
}
