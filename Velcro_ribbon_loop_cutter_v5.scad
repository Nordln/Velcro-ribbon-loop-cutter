use<hinge.scad>

/* [Tape vars] */ 
// Tape src:  10 mm Wide Velcro Tape on Both Sides (https://www.amazon.de/-/en/dp/B0C3CJNB5P)
tape_widthX = 10;
tape_lengthY = 50;
tape_thinkness = 2;

/* [Tip vars] */
tip_tape_lengthY = 34;
tip_notchCutout_pos_x = 1;
tip_notchCutout_pos_y = 0;
tip_notchCutout_pos_z = -2.5;
tip_notchShape_base = 5;
tip_notchShape_height = 5; 
tip_notchShape_thinkness = 5; 

tip_taperCutout_pos_x = 9;
tip_taperCutout_pos_y = 11;
tip_taperCutout_pos_z = 0;
tip_taperShape_base = 15;
tip_taperShape_height = 18;
tip_taperShape_thinkness = 5; 

/* [Lid vars] */
lid_blade_cutiout = 1.4; // expansion offset for receving blades
lid_bladeSeg_length = 8; // expansion offset for receving blades

/* [Blade vars] */ 
// Blade src: 11-300 Stanley
blade_heightZ = 9;
blade_thicknessX = 0.7;
bladeSeg_lengthY = 5.5;
Slot_blade_dist = -25;

/* [Hinge vars] */
hinge_tolerance = 0.5;
hinge_offset_x = -16.7;
hinge_offset_z = 1.58;
hinge_scale = 1.1;
hinge_boltradius = 1.5;
hinge_boltless = true;

/* [Handle rope holes] */
rope_hole_x = 9.6;
rope_hole_y = 14.6;
rope_hole_innerRad = 1;
rope_hole_outerRad = 2;

/* [Visibility / Helpers] */
show = "all"; // ["body", "lid", "all"]
showblades = false;
tape_guide = false; // show example of cut tape


main();

module main() {
    if ((show=="body")||(show=="all")) body(["body", "hinged", "stdcutouts"]); // args opts: body/lid, hinged/hinged, thickcutouts/[cutouts]
    if ((show=="lid")||(show=="all")) translate([0,0,-0.6]) lid();
    if (tape_guide) guide();
}

module lid() {
    difference() {
        union() {
            color("grey") translate([0,-10,8.3]) cube([30,60,5], center = true); // caps the extrusion below
            translate([0,0,0.4]) linear_extrude(10) projection(cut = true) translate([0,0,1]) body(["lid", "unhinged", "thickcutouts"]); // creates a slice of housing top and extrudes
            hinges("top");
        }
       translate([0,-38.5,-2.6]) cube([30,3.9,6], center = true); 
       mirror([0,0,1]) handleropeholes();
       mirror([0,0,1]) mirror([1,0,0]) handleropeholes(); // mirrors holes
    }
    if (showblades) color("purple") blades(); 
}

module body(args) {
    difference() {
        color("yellow") housing(args);
        if (args[2]=="thickcutouts")
                color("purple") blades(lid_blade_cutiout,lid_bladeSeg_length); // makes thicker cutouts to receieve blade tips when generating lid
        else
            color("purple") blades(); // creates holes for blades in actual body  
    }
    if (args[1]=="hinged") hinges("bottom");
    if (showblades) color("purple") blades(); // uncomment in "body" view to see actual blades
}

module hinges(arg) {
    intersection() {
        color("pink") translate([0,-40,-1.5]) cube([30,22,20], center = true); 
        if (arg=="top") translate([hinge_offset_x,-40,-0.4-hinge_offset_z]) rotate([90,0,0]) scale(hinge_scale) left_part(tolerance = hinge_tolerance,boltless = hinge_boltless, boltradius = hinge_boltradius);
        if (arg=="bottom") translate([hinge_offset_x,-40,-1-hinge_offset_z]) rotate([90,0,0]) scale(hinge_scale) right_part(tolerance = hinge_tolerance,boltless = hinge_boltless, boltradius = hinge_boltradius);
    }
}

module guide() { // example of cut tape for reference
    difference() {
        color("blue") example_tape();
        color("purple") blades();
        translate([0,0-tape_lengthY+10,0.7]) cube([12,1,2], center=true);
    }
    
}

module handleropeholes(){  // holes for rope handles to help pull apart the heads
        translate([rope_hole_x,rope_hole_y,-1.5]) cylinder(3,rope_hole_outerRad,rope_hole_outerRad, center = true, $fn = 12);
        translate([rope_hole_x,rope_hole_y,-15]) cylinder(30,rope_hole_innerRad,rope_hole_innerRad, center = true, $fn = 12);
}

module housing(args) {
   difference() {
       translate([0,-10,-6-(tape_thinkness/2)]) cube([30,60,12], center = true); 
       if (args[0]=="body") translate([0,-38,-15]) rotate([55,0,0]) tape(25); 
       if (args[0]=="body") translate([0,+22.5,-15]) rotate([114,0,0]) tape(25);
       if (args[0]=="body") handleropeholes();
       if (args[0]=="body")mirror([1,0,0]) handleropeholes(); 
   }
}



// ******* Example Tape Tip *********

module blades(thickness = blade_thicknessX, length = bladeSeg_lengthY ) {
    translate([0,0,-2.7]) {
        taper_blade(thickness, length);
        mirror([1,0,0]) taper_blade(thickness, length);
        notch_blade1(thickness, length);
        mirror([1,0,0]) notch_blade1(thickness, length);
        notch_blade2(thickness, length);
        mirror([1,0,0]) notch_blade2(thickness, length);
        translate([0,0,0]) slit_blade(90, thickness, length);
        translate([0,15,0]) slit_blade(90, thickness, length);
        //translate([-2,29.1,0]) slit_blade(0);
        translate([+0.0,38,0]) slit_blade(90, thickness, length);
    }
}

module slit_blade(zRot=90, thickness, length) { 
    translate([2,Slot_blade_dist,1.1]) rotate([0,0,zRot]) bladeSection(2,1,thickness, length);
}

module taper_blade(thickness, length) {
    translate([-(4.5+thickness/2),+0.2,0]) rotate([0,0,-20]) bladeSection(5.5,2,thickness, length);
}

module notch_blade2(thickness,length) {
    translate([-(1.6+thickness/2),0,0]) rotate([0,0,90]) bladeSection(2,1,thickness, length);
}

module notch_blade1(thickness,length) {
    translate([-(3.0+thickness/2),1.8,0]) rotate([0,0,45]) bladeSection(0.8,1,thickness, length);
}

module bladeSection(shift, max, thickness, length,center=true) { // creates the blade of given section length
    centroid = center ? [-thickness/2,-blade_heightZ/2,-blade_heightZ/2] : [0, 0, 0];
    translate(centroid) translate([0,0+shift,0]) {  
        translate([0,4.7/2,0]) blade(thickness,length);
        for (i = [1:1:max-1]) {
            translate([0,(5.6/2)+4.9*i,0]) blade(thickness, length);
        }
    }
}

module blade(thickness, length) {
    rotate([60,0,0]) rotate([0,90,00]) linear_extrude(height=thickness) polygon(points=[[0,0],[-length,blade_heightZ],[0,blade_heightZ],[length,0]], paths=[[0,1,2,3]]);
}

// ******* Example Tape Tip *********

module example_tape() {
    tip();
    translate ([0,-50.5,0]) tape(tape_lengthY);
}   

module tip() {
    difference() {
       translate([0,-0.5,0])tape(18);
       tip_tape_cutouts();
    }
}

module tip_tape_cutouts() {
    tip_notch();
    mirror([1,0,0]) tip_notch();
    tip_taper();
    mirror([1,0,0]) tip_taper();
}

module tip_notch() {
    translate([tip_notchCutout_pos_x,tip_notchCutout_pos_y,tip_notchCutout_pos_z]) rotate([0,0,-45]) tip_notchShape();
}

module tip_taper() {
    translate([tip_taperCutout_pos_x,tip_taperCutout_pos_y,tip_taperCutout_pos_z]) rotate([0,0,17]) tip_taperShape();
}

module tip_notchShape() {
    triangle(tip_notchShape_base,tip_notchShape_height,tip_notchShape_thinkness);
}

module tip_taperShape() {
    cube([tip_taperShape_base,tip_taperShape_height,tip_taperShape_thinkness], center=true);
}

module triangle(o_len, a_len, depth, center=false) {
    centroid = center ? [-a_len/3, -o_len/3, -depth/2] : [0, 0, 0];
    translate(centroid) linear_extrude(height=depth) {
        polygon(points=[[0,0],[a_len,0],[0,o_len]], paths=[[0,1,2]]);
    }
}

module tape(length) {
    translate([0,length/2,0])cube([tape_widthX,length,tape_thinkness], center=true);
}