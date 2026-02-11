//-----------------------------------------------------------------------
// ESP32 Sailing Autopilot Remote v3 - Waterproof Enclosure
// Custom design with TPU button mask
// Dimensions derived from v2 YAPP-based enclosure
//-----------------------------------------------------------------------

// ===== Rendering control =====
render_front_face  = true;
render_tpu_mask    = true;
render_enclosure   = true;
render_hook        = true;
render_back_cover  = false;

// ===== Dimensions from v2 =====
// PCB: 70 x 90 mm, padding: 4mm each side, wall: 2mm
pcb_l       = 70;        // PCB length (X in v2)
pcb_w       = 90;        // PCB width  (Y in v2)
padding     = 4;         // padding on each side
wall        = 2.0;       // wall thickness (from v2)
corner_r    = 3;         // corner rounding (roundRadius in v2)

// Derived front face dimensions
front_w     = pcb_l + 2*padding + 2*wall;  // 82mm
front_h     = pcb_w + 2*padding + 2*wall;  // 102mm
front_t     = wall;                         // front face thickness

// ===== Enclosure depth from v2 =====
// v2: baseWallHeight=25, lidWallHeight=10 -> total depth 35mm
box_depth   = 28;        // interior depth behind front face

// ===== Hook parameters =====
hook_w      = 10;        // hook width
hook_t      = 5;         // hook bar thickness
hook_inner_r = 4;        // inner radius of the hook loop
hook_outer_r = hook_inner_r + hook_t;

// ===== Screw post parameters =====
screw_d       = 2.2;     // M2 screw hole diameter (self-tapping)
post_d        = 6;       // screw post outer diameter
post_inset    = post_d/2; // post flush against inner wall
post_h        = box_depth - wall;  // post height (leaves room for back cover thickness)
screw_head_d  = 4.5;     // M2 screw head diameter (countersink)
screw_head_h  = 1.5;     // countersink depth

// Gasket channel on back cover
gasket_w      = 1.5;     // gasket groove width
gasket_d      = 1.0;     // gasket groove depth

// ===== Button layout from v2 =====
// v2 cutoutsLid positions (PCB-relative coordinates):
//   Col1: x=21  Col2: x=49   (spacing 28mm, centered on pcb_l)
//   Row1: y=15  Row2: y=30   Row3: y=46
// v2 cutout size: 10mm diameter circle -> 10x10mm rectangle in v3
// v2 push button cap: 8x8mm

btn_open_w   = 16;       // rectangular opening width (wider for finger press)
btn_open_h   = 10;       // rectangular opening height
btn_corner_r = 2;        // opening corner radius

// Button center positions (PCB-relative, from v2)
v2_btn_x = [21, 49];
v2_btn_y = [15, 30, 46];

// Convert PCB-relative to box-relative (add padding + wall)
// Then to center-relative (subtract half of front face size)
function btn_box_x(px) = px + padding + wall - front_w/2;
function btn_box_y(py) = py + padding + wall - front_h/2;

// ===== TPU mask parameters =====
tpu_margin     = 6;      // extra margin around button grid
tpu_thickness  = 1.2;    // membrane thickness
tpu_bump_h     = 1.5;    // raised bump height on each button
tpu_bump_inset = 1.5;    // bump inset from opening edge
tpu_lip        = 1.5;    // lip width that sits in a channel on the front face
tpu_lip_depth  = 1.0;    // how deep the lip extends behind the face

// ===== Seal channel on front face =====
channel_w   = 1.8;       // width of the seal channel
channel_d   = 1.2;       // depth of the seal channel

// ===== Computed values =====
// Button grid bounding box (center-relative)
btn_min_x = btn_box_x(v2_btn_x[0]) - btn_open_w/2;
btn_max_x = btn_box_x(v2_btn_x[1]) + btn_open_w/2;
btn_min_y = btn_box_y(v2_btn_y[0]) - btn_open_h/2;
btn_max_y = btn_box_y(v2_btn_y[2]) + btn_open_h/2;

// TPU mask bounds (centered on button grid)
tpu_cx = (btn_min_x + btn_max_x) / 2;
tpu_cy = (btn_min_y + btn_max_y) / 2;
tpu_w  = (btn_max_x - btn_min_x) + 2 * tpu_margin;
tpu_h  = (btn_max_y - btn_min_y) + 2 * tpu_margin;

$fn = 40;

//-----------------------------------------------------------------------
// Helper: rounded rectangle (2D)
//-----------------------------------------------------------------------
module rounded_rect(w, h, r) {
    offset(r) square([w - 2*r, h - 2*r], center = true);
}

//-----------------------------------------------------------------------
// Button positions iterator - places children at each button center
// Uses exact v2 positions converted to center-relative coordinates
//-----------------------------------------------------------------------
module button_positions() {
    for (ix = [0 : len(v2_btn_x)-1])
        for (iy = [0 : len(v2_btn_y)-1])
            translate([
                btn_box_x(v2_btn_x[ix]),
                btn_box_y(v2_btn_y[iy]),
                0
            ])
            children();
}

//-----------------------------------------------------------------------
// FRONT FACE
// - Rounded rectangular plate (82 x 102 mm)
// - 6 rectangular button openings (3 rows x 2 cols)
// - Seal channel around the button area for TPU mask lip
//-----------------------------------------------------------------------
module front_face() {
    difference() {
        // Main plate
        linear_extrude(front_t)
            rounded_rect(front_w, front_h, corner_r);

        // Button openings - cut through
        translate([0, 0, -0.1])
            button_positions()
                linear_extrude(front_t + 0.2)
                    rounded_rect(btn_open_w, btn_open_h, btn_corner_r);

        // Seal channel on the outer surface (z = front_t side)
        // Rectangular groove around the button area for TPU lip
        translate([tpu_cx, tpu_cy, front_t - channel_d])
            linear_extrude(channel_d + 0.1)
                difference() {
                    rounded_rect(
                        tpu_w + channel_w,
                        tpu_h + channel_w,
                        corner_r
                    );
                    rounded_rect(
                        tpu_w - channel_w,
                        tpu_h - channel_w,
                        corner_r
                    );
                }
    }
}

//-----------------------------------------------------------------------
// Screw post positions - 4 corners, inset from inner walls
//-----------------------------------------------------------------------
module post_positions() {
    px = front_w/2 - wall - post_inset;
    py = front_h/2 - wall - post_inset;
    for (sx = [-1, 1])
        for (sy = [-1, 1])
            translate([sx * px, sy * py, 0])
                children();
}

//-----------------------------------------------------------------------
// SIDE WALLS
// - Extruded from front face perimeter going backward (-Z)
// - Includes screw posts for back cover attachment
//-----------------------------------------------------------------------
module side_walls() {
    // Walls
    translate([0, 0, -box_depth])
        linear_extrude(box_depth)
            difference() {
                rounded_rect(front_w, front_h, corner_r);
                rounded_rect(front_w - 2*wall, front_h - 2*wall, corner_r);
            }

    // Screw posts inside corners
    translate([0, 0, -box_depth])
        post_positions()
            difference() {
                cylinder(d = post_d, h = post_h);
                translate([0, 0, -0.1])
                    cylinder(d = screw_d, h = post_h + 0.2);
            }
}

//-----------------------------------------------------------------------
// BACK COVER
// - Flat plate that closes the enclosure
// - Countersunk screw holes at 4 corners
// - Gasket channel around the perimeter for waterproof seal
//-----------------------------------------------------------------------
module back_cover() {
    translate([0, 0, -box_depth - wall])
        difference() {
            // Main plate
            linear_extrude(wall)
                rounded_rect(front_w, front_h, corner_r);

            // Countersunk screw holes
            post_positions() {
                // Through hole
                translate([0, 0, -0.1])
                    cylinder(d = screw_d, h = wall + 0.2);
                // Countersink from outside
                translate([0, 0, -0.1])
                    cylinder(d = screw_head_d, h = screw_head_h + 0.1);
            }

            // Gasket channel on the inner face (top of back cover)
            translate([0, 0, wall - gasket_d])
                linear_extrude(gasket_d + 0.1)
                    difference() {
                        rounded_rect(
                            front_w - 2*wall + gasket_w,
                            front_h - 2*wall + gasket_w,
                            corner_r
                        );
                        rounded_rect(
                            front_w - 2*wall - gasket_w,
                            front_h - 2*wall - gasket_w,
                            corner_r
                        );
                    }
        }
}

//-----------------------------------------------------------------------
// HANGING HOOK
// - Arch loop on bottom edge (Y- side) of the enclosure
// - Centered on X axis, attached to the bottom wall
//-----------------------------------------------------------------------
module hanging_hook() {
    translate([0, -front_h/2, -box_depth/2])
        rotate([0, 90, 0])
            linear_extrude(hook_w, center = true)
                difference() {
                    circle(r = hook_outer_r);
                    circle(r = hook_inner_r);
                    // Cut top half so the arch opens outward (away from enclosure)
                    translate([-hook_outer_r - 1, 0])
                        square([2 * (hook_outer_r + 1), hook_outer_r + 1]);
                }
}

//-----------------------------------------------------------------------
// TPU BUTTON MASK
// - Thin flexible membrane covering all 6 buttons
// - Raised bumps at each button position for tactile feel
// - Perimeter lip that sits into the seal channel
//-----------------------------------------------------------------------
module tpu_mask() {
    translate([tpu_cx, tpu_cy, 0]) {
        // Base membrane
        linear_extrude(tpu_thickness)
            rounded_rect(tpu_w, tpu_h, corner_r);

        // Perimeter lip (goes into the seal channel, on the back side)
        translate([0, 0, -tpu_lip_depth])
            linear_extrude(tpu_lip_depth)
                difference() {
                    rounded_rect(tpu_w, tpu_h, corner_r);
                    rounded_rect(
                        tpu_w - 2 * tpu_lip,
                        tpu_h - 2 * tpu_lip,
                        corner_r
                    );
                }
    }

    // Raised bumps on each button - face outward for tactile feel
    translate([0, 0, tpu_thickness])
        button_positions()
            linear_extrude(tpu_bump_h)
                rounded_rect(
                    btn_open_w - 2 * tpu_bump_inset,
                    btn_open_h - 2 * tpu_bump_inset,
                    btn_corner_r
                );
}

//-----------------------------------------------------------------------
// Assembly / Part selection
//-----------------------------------------------------------------------
if (render_enclosure) {
    color("SlateGray") {
        if (render_front_face)
            front_face();
        side_walls();
    }
}

if (render_back_cover) {
    color("DarkSlateGray")
        back_cover();
}

if (render_hook) {
    color("SlateGray")
        hanging_hook();
}

if (render_tpu_mask) {
    color("DarkOrange", 0.7)
        translate([0, 0, front_t + 0.3])  // offset for preview clarity
            tpu_mask();
}
