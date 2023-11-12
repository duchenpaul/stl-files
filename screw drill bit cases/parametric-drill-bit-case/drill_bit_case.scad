// Drill bits case
// Author: Krzysztof Suszka
// Last update: 2019-08-14

// Select part to render:
//   1 - base
//   2 - cover
//   3 - base and cover for printing
//   4 - base and cover as closed case
select_part(3);

// Should labels be embedded into the case
show_labels = true;

// Outer case dimensions
box_width = 80;
box_depth = 25;
box_height = 140;

drill_bits = [
  [
    // diameter, label, length
    [10,  "10",  132],
    [9.5, "9.5", 126],
    [9,   "9",   125],
    [8.5, "8.5", 117],
    [8,   "8",   117],
    [7.5, "7.5", 109],
    [7,   "7",   109]
  ],
  [
    [6.5, "6.5", 101],
    [6,   "6",   94],
    [5.5, "5.5", 92],
    [5,   "5",   86],
    [4.5, "4.5", 80],
    [4,   "4",   75],
    [3.5, "3.5", 71],
    [3,   "3",   63],
    [2.5, "2.5", 57],
    [2,   "2",   49],
    [1.5, "1.5", 40],
    [1,   "1",   35]
  ]
];
lines_conf = [
  // text_padding, text_size, label_offset, alternating, row_offset, row_depth
  [3, 4, 40, false, 17, 13],
  [5, 3, 27, true, 6, 9]
];

cover_wall_thickness = 1.5;
box_chamfer = 3;
bottom_case_height = 45;
base_height = bottom_case_height + 10;
padding = 3;
clearance = 0.2;
cover_drill_distance = 5;

$fa = 3;
$fs = 0.2;

box_dimensions = [box_width, box_depth, box_height];

function drill_dia(record) = record[0];
function drill_label(record) = record[1];
function drill_length(record) = record[2];
function sum(vector) = [for(p=vector) 1]*vector;

show_bits = 1;
show_chamfer = 2;
show_block = 3;

module drill_row(drill_row, row_width=100, options=[], row_depth) {
  drill_dia_sum = sum([for(drill=drill_row)drill_dia(drill)]);
  echo(drill_dia_sum);
  gap = (row_width-drill_dia_sum)/(len(drill_row)-1);
  echo(gap);
  for (drill_index=[0:len(drill_row)-1]) {
    drill = drill_row[drill_index];
    dia = drill_dia(drill);
    offset = dia/2 + ((drill_index > 0) ? sum([for(i=[0:drill_index-1])drill_dia(drill_row[i])+gap]) : 0);
    length = drill_length(drill);
    bottom_thickness=2;
    z_fix = ((length/2)<(base_height-bottom_thickness))?length/2:(base_height-bottom_thickness);
    if (search(show_bits, options)) {
      translate([offset,0,-z_fix]) cylinder(d=dia+clearance*2,h=length);
    }
    if (search(show_chamfer, options)) {
      translate([offset,0,-0.75]) cylinder(d1=dia,d2=dia+4,h=2);
    }
    if (search(show_block, options)) {
      addon = (drill_index == 0) ? -10 : (drill_index == len(drill_row)-1) ? 10 : 0;
      translate([offset+addon,0,(-z_fix+length)/2])
        cube([dia+gap+0.01+abs(addon)*2,row_depth+0.01,-z_fix+length], true);
    }
  }
}

module drill_bits(options=[show_bits, show_chamfer]) {
  for (line_index=[0:len(drill_bits)-1]) {
    translate([padding,lines_conf[line_index][4],base_height]) {
      line=drill_bits[line_index];
      row_depth=lines_conf[line_index][5];
      drill_row(line,box_width-2*padding, options, row_depth);
    }
  }
}
module octahedron(side=1, trim) {
  module pure_octahedron(side) {
    for(a=[0,1])
      mirror([0,0,a])
        linear_extrude(height=sqrt(2)*side/2,scale=0)
          rotate([0,0,45])
            square([side,side],true);
  }
  if ((trim != undef) && (trim < sqrt(2)*side/2)) {
    intersection() {
      pure_octahedron(side);
      cube([trim*2,trim*2,trim*2],true);
    }
  } else {
    pure_octahedron(side);
  }
}

module box(dimensions=[10,10,10], wall=1, chamfer=0) {
  if (chamfer <= 0) {
    difference() {
      cube(dimensions);
      translate(wall*[1,1,1]) cube([for(a=dimensions)a-2*wall]);
    }
  } else {
    difference() {
      minkowski() {
        translate((chamfer)*[1,1,1])
          cube([for(a=dimensions) a-2*chamfer]);
        octahedron(sqrt(2)*chamfer,chamfer);
      }
      minkowski() {
        translate((wall+chamfer)*[1,1,1])
          cube([for(a=dimensions) a-2*(wall+chamfer)]);
        octahedron(sqrt(2)*chamfer+1,chamfer);
      }
    }
  }
}

module cover() {
  module shell() {
    intersection() {
      box(box_dimensions,cover_wall_thickness,box_chamfer);
      translate([0,0,bottom_case_height+500]) cube([1000,1000,1000],true);
    }
  }
  module hooks() {
    translate([box_width/2,box_depth/2,bottom_case_height+4])
    for(a=[0,1])mirror([0,a,0])
    translate([0,-box_depth/2,0]) rotate([0,90,0]) intersection() {
      cylinder(r=cover_wall_thickness+1,h=10,center=true);
      translate([0,50.1,0])cube([100,100,100],true);
    }
  }
  module insert() {
    intersection() {
      difference() {
        translate([0,0,base_height+cover_drill_distance + 500.1]) cube([1000,1000,1000],true);
        translate([0,0,cover_drill_distance]) drill_bits([show_block]);
      }
      box(box_dimensions,1000,box_chamfer);
    }
  }
  union() {
    hooks();
    shell();
    insert();
  }
}

module base() {
  module base_bulk() {
    intersection() {
      box(box_dimensions,1000,box_chamfer);
      translate([0,0,bottom_case_height-500]) cube([1000,1000,1000],true);
    }
    offset = cover_wall_thickness;
    translate([offset,offset,10]) box([box_width-2*offset,box_depth-2*offset,base_height-10],1000,0.5);
  }
  difference() {
    base_bulk();
    cover();
  }
}


module drill_row_text(drill_row, row_width=100, alternating=false,size=3) {
  drill_dia_sum = sum([for(drill=drill_row)drill_dia(drill)]);
  echo(drill_dia_sum);
  gap = (row_width-drill_dia_sum)/(len(drill_row)-1);
  echo(gap);
  for (drill_index=[0:len(drill_row)-1]) {
    drill = drill_row[drill_index];
    dia = drill_dia(drill);
    offset = dia/2 + ((drill_index > 0) ? sum([for(i=[0:drill_index-1])drill_dia(drill_row[i])+gap]) : 0);
    label = drill_label(drill);
    length = drill_length(drill);
    translate([offset,(drill_index%2)*4*(alternating?1:0)])
    linear_extrude(height = 1) {
            text(label, size = size, halign = "center", valign = "center", font = "Verdana:style=Bold");
          }
  }
}

module drill_bit_labels() {
  rotate([90,0,0]) {
    for (line_index=[0:len(drill_bits)-1]) {
      padding=lines_conf[line_index][0];
      text_size=lines_conf[line_index][1];
      offset=lines_conf[line_index][2];
      alternating=lines_conf[line_index][3];
      translate([padding,offset,-0.5])
      drill_row_text(drill_bits[line_index], box_width-2*padding,alternating,text_size);
    }
  }
}

module holder() {
  difference() {
    base();
    drill_bits();
    if (show_labels) {
      drill_bit_labels();
    }
  }
}

module select_part(part_no) {
  if (part_no == 1) {
    holder();
  } else if (part_no == 2) {
    cover();
  } else if (part_no == 3) {
    holder();
    translate([0,box_depth*2+10,box_height])rotate([180,0]) cover();
  } else if (part_no == 4) {
    holder();
    cover();
  } else {
    echo("Invalid part selected!");
  }
}
