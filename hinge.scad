// A library to create print-in-place horizontal hinges.
//
// Copyright (c) 2020 Rodrigo Chandia (rodrigo.chandia@gmail.com)
// All rights reserved.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
//
// The contents of this file are DUAL-LICENSED.  You may modify and/or
// redistribute this software according to the terms of one of the
// following two licenses (at your option):
//
// License 1: Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)
//            https://creativecommons.org/licenses/by-sa/4.0/
//
// License 2: GNU General Public License (GPLv3)
//            https://www.gnu.org/licenses/gpl-3.0.en.html
//
// You should have received a copy of the GNU General Public License
// along with this program. https://www.gnu.org/licenses/
//

module bottomWedge(r, d, rodH, tolerance, other) {
  wedgeH = (r + tolerance) * sin(45);
  wedgeBottom = max(r + tolerance, d);
  wedgeFlip = other ? 1 : -1;
  linear_extrude(height = rodH)
  polygon(points=[
    [wedgeH,wedgeFlip*-r],
    [wedgeH,wedgeFlip*wedgeH],
    [wedgeBottom,wedgeFlip*(wedgeH - (wedgeBottom - wedgeH))],
    [wedgeBottom,wedgeFlip*-r]
  ]);
}

module hingeRodNegative(r, d, h, tolerance, tip, other) {
  difference() {
    translate([0,0,d])
    rotate([0,90,0]) {
      translate([0, 0, -tolerance/2]) {
        rodH = h  + (tip ? tolerance/2 : 0) + tolerance/2;
        cylinder(r = r + tolerance, h = rodH);
        bottomWedge(r, d, rodH, tolerance, other);
      }
      if (tip) {
        translate([0,0,h])
        cylinder(r = r, h = tolerance + 0.01);
        translate([0,0,h + tolerance])
        cylinder(r1 = r, r2 = 0, h = r + tolerance);
      } else {
        translate([0,0,h])
        cylinder(r = r + tolerance, h = tolerance / 2);
      }
    }
    translate([
      -tolerance/2 - 0.01,
      other ? -r - tolerance : 0,
      -0.01])
    cube([h + tolerance + + 0.02 + (tip ? r + tolerance * 1.5 : 0), r + tolerance, d + r + tolerance + 0.02]);
  }
}

module hingeRod(r, d, h, tip, dip, tolerance, negative, other) {
  if (negative) {
    hingeRodNegative(r, d, h, tolerance, tip, other);
  } else {
    toleranceTip = tip ? tolerance/2 : tolerance/2;
    toleranceDip = dip ? tolerance/2 : tolerance/2;
    translate([0,0,d])
    rotate([0,90,0])
    difference() {
      union() {
        rodH = h - toleranceTip - toleranceDip;
        translate([0,0,toleranceDip]) {
          cylinder(r = r, h = rodH);
          bottomWedge(r, d, rodH, 0, !other);
        }
        if (tip) {
          translate([0,0,h - toleranceTip - 0.01])
          cylinder(r1 = r, r2 = 0, h = r + 0.01);
        }
      }
      if (dip) {
        translate([0,0,toleranceDip-0.01])
        cylinder(r1 = r, r2 = 0, h = r + tolerance);
      }
    }
  }
}

function xor(a, b) = (a && !b) || (b && !a);

module hingeCorner(r, cornerHeight, hingeLength, pieces, other, negative, tolerance, bolted = true) {
  startAtFirst = xor(other, negative);
  for (i = [1:pieces]) {
    if (i % 2 == (startAtFirst ? 0 : 1)) {
      translate([hingeLength / pieces * (i - 1),0,0])
      hingeRod(r, cornerHeight, hingeLength / pieces, ((i != pieces || cornerHeight > (hingeLength / pieces))&& bolted) , i != 1 && bolted, tolerance, negative, other);
    }   
  }
}

module applyHingeCorner(position = [0,0,0], rotation = [0,0,0], r = 3, cornerHeight = 5, hingeLength = 15, pieces = 3, tolerance = 0.3) {
  translate(position)
  for (i = [0:1]) {
    difference() {
      translate(-position)
      children(i);
      rotate(rotation)
      hingeCorner(r, cornerHeight, hingeLength, pieces, i == 0, true, tolerance);
    }
    rotate(rotation)
    hingeCorner(r, cornerHeight, hingeLength, pieces, i == 0, false, tolerance);
  }
  if ($children > 2) {
    children([2:$children-1]);
  }
}

module applyHinges(positions, rotations, r, cornerHeight, hingeLength, pieces, tolerance) {
  difference() {
    children();
    for (j = [0 : 1 : len(positions) - 1]) {
      translate(positions[j])
      rotate([0,0, rotations[j]])
      for (b = [0, 1]) {
        hingeCorner(r, cornerHeight, hingeLength, pieces, b == 0, true, tolerance);
      }
    }
  }
  for (j = [0 : 1 : len(positions) - 1]) {
    translate(positions[j])
    rotate([0,0, rotations[j]])
    for (b = [0, 1]) {
      hingeCorner(r, cornerHeight, hingeLength, pieces, b == 0, false, tolerance);
    }
  }
}

module negativeExtraAngle(position, rotation, cornerHeight, centerHeight, hingeLength, pieces, tolerance, other, angle) {
  translate(position)
  rotate(rotation) {
    startAtFirst = !other;
    l = (cornerHeight + tolerance - centerHeight) / tan(90-angle / 2);
    for (i = [1 : pieces]) {
      if (i % 2 == (startAtFirst ? 0 : 1)) {
        dip = i != 1;
        w = hingeLength / pieces + (dip ? 1 : 0.5) * tolerance;
        positionX = (i - 1) * hingeLength / pieces + (dip ? -tolerance / 2 : 0);
        difference() {
          translate([ positionX, 0, centerHeight])
          rotate([other ? -angle : angle, 0, 0])
          translate([0, other ? -l : 0, -centerHeight])
          cube([w, l, cornerHeight + tolerance]);
          
          translate([positionX - 0.01, other ? -cornerHeight + 0.01 : -0.01, 0])
          cube([w + 0.02, cornerHeight, 2 * cornerHeight]);
          
          diffY = norm([l, cornerHeight + tolerance]);
          translate([positionX - 0.01, other? -0.01 : -diffY - 2 * tolerance + 0.01, cornerHeight + 0.01])
          cube([w + 0.02, diffY + 2 * tolerance, diffY]);
        }
      }    
    }
  }
}

module applyExtraAngle(positions, rotations, cornerHeight, centerHeight, hingeLength, pieces, tolerance, angle) {
  difference() {
    children();
    for (j = [0 : 1 : len(positions) - 1]) {
      negativeExtraAngle(positions[j], rotations[j], cornerHeight, centerHeight, hingeLength, pieces, tolerance, false, angle);
      negativeExtraAngle(positions[j], rotations[j], cornerHeight, centerHeight, hingeLength, pieces, tolerance, true, angle);
    }
  }
}


left_part(boltless = false, boltradius = 1.5);
right_part(boltless = false, boltradius = 1.5);


module bolt(boltradius) {
    translate([0,0,7/2]) rotate([0,90,0]) cylinder(70,boltradius,boltradius,$fn = 12);
} 

module left_part(len=20, tolerance = 0.7, boltless = true, boltradius = 1.5) {
    difference() {
        union() {
            difference() {
                translate([0,0.5,0]) cube([60,len,7]);
                hingeCorner(7/2, 7/2, 60, 6, true, true, tolerance, boltless);
                negativeExtraAngle([0,0,0], [0,0,0], 7, 7/2, 60, 6, tolerance, true, 90);
            }
            hingeCorner(7/2, 7/2, 60, 6, true, false, tolerance, boltless);
        }
      if (boltless==false) bolt(boltradius);
    }
 }

module right_part(len=20, tolerance = 0.7, boltless = true, boltradius) {
    difference() {
        union() {
            difference() {
                translate([0,(-0.5)-len,0]) cube([60,len,7]);
                hingeCorner(7/2, 7/2, 60, 6, false, true, tolerance);
                negativeExtraAngle([0,0,0], [0,0,0], 7, 7/2, 60, 6, tolerance, false, 90);
            }
            hingeCorner(7/2, 7/2, 60, 6, false, false, tolerance, boltless);
        }
      if (boltless==false) bolt(boltradius);
    }
 }
