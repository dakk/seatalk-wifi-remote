
//-----------------------------------------------------------------------
// ESP32 Sailing Autopilot Remote - nke style
// Based on YAPP Box Generator v3
//-----------------------------------------------------------------------
include <../Enclosures/YAPP_Box/YAPPgenerator_v3.scad>

//-- which part(s) do you want to print?
printBaseShell        = true;
printLidShell         = true;
printSwitchExtenders  = true;

// PCB dimensions - adjust to your ESP32 board
pcbLength           = 70;    // X axis (front to back)
pcbWidth            = 50;    // Y axis (side to side)
pcbThickness        = 1.6;
standoffHeight      = 3.0;   // space below PCB for soldering/battery
standoffDiameter    = 5;
standoffPinDiameter = 2.0;
standoffHoleSlack   = 0.4;

pcb = 
[
  ["Main", pcbLength, pcbWidth, 0, 0, pcbThickness, standoffHeight, 
   standoffDiameter, standoffPinDiameter, standoffHoleSlack]
];

//-- padding between PCB and inside wall
paddingFront  = 4;
paddingBack   = 4;
paddingRight  = 4;
paddingLeft   = 4;

//-- wall dimensions
wallThickness       = 2.0;
basePlaneThickness  = 1.5;
lidPlaneThickness   = 1.5;

//-- Total height ~23mm (nke remote style)
baseWallHeight  = 10;
lidWallHeight   = 8;

//-- ridge for lid/base overlap (sealing area)
ridgeHeight  = 4.0;
ridgeSlack   = 0.2;
roundRadius  = 5.0;   // rounded corners

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
  // 4 corner standoffs (adjust to your ESP32 mounting holes)
  [3,  3,  standoffHeight, -1, standoffDiameter, standoffPinDiameter],
  [3,  pcbWidth-3],
  [pcbLength-3, 3],
  [pcbLength-3, pcbWidth-3]
];

//===================================================================
// *** Cutouts - FIXED FORMAT ***
//-------------------------------------------------------------------
cutoutsLid = 
[
  // 6 button holes: 10mm diameter circles, 2x3 grid centered on lid
  // Format: [x, y, diameter, diameter, yappCircle]
  // Row 1 (top)
  [35, 15, 10, 10, yappCircle],
  [35, 35, 10, 10, yappCircle],
  // Row 2 (middle)  
  [45, 15, 10, 10, yappCircle],
  [45, 35, 10, 10, yappCircle],
  // Row 3 (bottom)
  [55, 15, 10, 10, yappCircle],
  [55, 35, 10, 10, yappCircle]
];

cutoutsBase = [];

// USB-C charging port on front face
cutoutsFront = 
[
  // USB-C: 9mm wide x 3.5mm tall, centered vertically
  [9, 32, 9, 3.5, yappRoundedRect]
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
  [35, 15, 8, 8, 2, 1.5, 6.0, 0.5, 4, standoffHeight + pcbThickness],
  [35, 35, 8, 8, 2, 1.5, 6.0, 0.5, 4, standoffHeight + pcbThickness],
  [45, 15, 8, 8, 2, 1.5, 6.0, 0.5, 4, standoffHeight + pcbThickness],
  [45, 35, 8, 8, 2, 1.5, 6.0, 0.5, 4, standoffHeight + pcbThickness],
  [55, 15, 8, 8, 2, 1.5, 6.0, 0.5, 4, standoffHeight + pcbThickness],
  [55, 35, 8, 8, 2, 1.5, 6.0, 0.5, 4, standoffHeight + pcbThickness]
];

//===================================================================
// *** Snap Joins - clips to hold lid and base together ***
//-------------------------------------------------------------------
snapJoins = 
[
  [(pcbLength + paddingFront + paddingBack)/2, 10, yappLeft, yappRight, yappCenter]
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
  // 4 corner M2 screw posts
  [5, 5, standoffHeight, 2.2, 4.5, 2.2, 4, yappAllCorners, yappCoordBox],
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