
//-----------------------------------------------------------------------
// ESP32 Sailing Autopilot Remote - nke style
// Based on YAPP Box Generator v3
//-----------------------------------------------------------------------
include <../YAPPgenerator_v3.scad>

//-- which part(s) do you want to print?
printBaseShell        = true;
printLidShell         = true;
printSwitchExtenders  = true;

// PCB dimensions - adjust to your ESP32 board
pcbLength           = 70;    // X axis (front to back)
pcbWidth            = 90;    // Y axis (side to side)
pcbThickness        = 1.6;
standoffHeight      = 20.0;  // space below PCB for ESP and battery
standoffDiameter    = 5;
standoffPinDiameter = 2.0;
standoffHoleSlack   = 0.4;

pcb = 
[
  ["Main", pcbLength, pcbWidth, 0, 0, pcbThickness, standoffHeight, 
   standoffDiameter, standoffPinDiameter, standoffHoleSlack]
];

//-- padding between PCB and inside wall
//-- increased to avoid overlap between PCB stands and box corner connectors
paddingFront  = 4;
paddingBack   = 4;
paddingRight  = 4;
paddingLeft   = 4;

//-- wall dimensions
wallThickness       = 2.0;
basePlaneThickness  = 1.5;
lidPlaneThickness   = 1.5;

//-- Total height adjusted for 20mm standoff + PCB + components
baseWallHeight  = 25;
lidWallHeight   = 10;

//-- ridge for lid/base overlap (sealing area)
ridgeHeight  = 4.0;
ridgeSlack   = 0.2;
roundRadius  = 3;

boxType = 0;  // all edges rounded

printerLayerHeight = 0.2;

//-- Preview settings
renderQuality    = 8;
previewQuality   = 5;
showSideBySide   = true;
colorLid         = "DarkSlateGray";
colorBase        = "SlateGray";
showPCB          = true;
showSwitches     = true;

//===================================================================
// *** PCB Supports - mounting posts for ESP32 ***
//-------------------------------------------------------------------
pcbStands =
[
  // 4 corner standoffs (PCB holes: 3mm, 1mm from left/right, 1.5mm from top/bottom)
  [5,  5,  standoffHeight, -1, standoffDiameter, standoffPinDiameter],
  [5,  pcbWidth-5],
  [pcbLength-5, 5],
  [pcbLength-5, pcbWidth-5]
];

//===================================================================
// *** Cutouts - FIXED FORMAT ***
//-------------------------------------------------------------------
cutoutsLid =
[
  // 6 button holes: 10mm diameter circles, 3x2 grid centered on lid
  // Format: [x, y, diameter, diameter, yappCircle]
  // Column 1 (left)
  [21, 15, 10, 10, yappCircle],
  [21, 30, 10, 10, yappCircle],
  [21, 46, 10, 10, yappCircle],
  // Column 2 (right)
  [49, 15, 10, 10, yappCircle],
  [49, 30, 10, 10, yappCircle],
  [49, 46, 10, 10, yappCircle]
];

cutoutsBase = [];

// USB-C charging port on front face
cutoutsFront =
[
  // USB-C: 9mm wide x 3.5mm tall, centered on width
  //[9, 49, 9, 3.5, yappRoundedRect]
];

cutoutsBack   = [];
cutoutsLeft   = [];
cutoutsRight  = [];

//===================================================================
// *** Push Buttons - printed extenders for tactile switches ***
//-------------------------------------------------------------------
pushButtons =
[
  // Match cutouts exactly - adjust switchHeight to your tact switches
  // Format: [x, y, capLength, capWidth, capAboveLid, plateThick, switchHeight, travel, poly, pcbTop2Cap]
  // Column 1 (left)
  [21, 15, 8, 8, 2, 1.5, 25.0, 0.5, 4, 0],
  [21, 30, 8, 8, 2, 1.5, 25.0, 0.5, 4, 0],
  [21, 46, 8, 8, 2, 1.5, 25.0, 0.5, 4, 0],
  // Column 2 (right)
  [49, 15, 8, 8, 2, 1.5, 25.0, 0.5, 4, 0],
  [49, 30, 8, 8, 2, 1.5, 25.0, 0.5, 4, 0],
  [49, 46, 8, 8, 2, 1.5, 25.0, 0.5, 4, 0]
];

//===================================================================
// *** Snap Joins - clips to hold lid and base together ***
//-------------------------------------------------------------------
snapJoins =
[
  [(pcbLength + paddingFront + paddingBack)/2, 15, yappLeft, yappRight, yappCenter]
];

//===================================================================
// *** Labels - embossed text ***
//-------------------------------------------------------------------
labelsPlane = 
[
  // Example button labels
  // [45, 15+12, 0, 0.4, yappLid, "Liberation Sans:style=Bold", 4, "AUTO"],
  // [45, 35-12, 0, 0.4, yappLid, "Liberation Sans:style=Bold", 4, "STBY"],
  // [35, 25, 0, 0.4, yappLid, "Liberation Sans", 3, "+1"],
  // [55, 25, 0, 0.4, yappLid, "Liberation Sans", 3, "-1"]
];

//===================================================================
// *** Connectors - screw posts for secure closure ***
//-------------------------------------------------------------------
connectors =
[
  // 4 corner M2 screw posts - moved inside to clear rounded corners
  [7, 7, standoffHeight, 2.2, 4.5, 2.2, 4, yappAllCorners, yappCoordBox],
];

boxMounts     = [];
lightTubes    = [];
ridgeExtLeft  = [];
ridgeExtRight = [];
ridgeExtFront = [];
ridgeExtBack  = [];
displayMounts = [];

//---- Generate the box ----
YAPPgenerate();