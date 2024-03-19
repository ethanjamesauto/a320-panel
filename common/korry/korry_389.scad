// note: current lens size is 14.226 (without tol)

wall_thickness = .75;
button_wall_thickness = .6;

tol_tight = 0.1;
tol_very_tight = .05;
tol_wall = 0.2;

outer_width = .69*25.4-tol_tight*2;//   + .5;
outer_lip = .8;//.75;
outer_lip_height = 1.5;//2;
outer_height = 21+1.54+2.2;

switch_height = 15+1.54;

button_height = 7+tol_tight;
button_width = 7+tol_tight;

// lip for mounting lens
lens_width = 2.54;
lip_depth = lens_width+.5;
lip_size = .55;

inner_width = outer_width - wall_thickness*2 - tol_wall*2; //14.526 //15.026

translate([-2, 0, outer_height])
rotate([0, 180, 0])
//translate([-18, 0, 3])
outer_switch();

//translate([5, 0, 0])
//translate([0, 0, button_height + 0.2]) 
inner_switch();

module outer_switch() {
	bridge();
	difference () {
		union() {
			cube([outer_width, outer_width, outer_height]);
			translate([-outer_lip, -outer_lip, outer_height-outer_lip_height]) 
				cube([outer_width + outer_lip*2, outer_width + outer_lip*2, outer_lip_height]);
		}
		
		w = outer_width - wall_thickness*2;
		translate([wall_thickness, wall_thickness, button_height]) cube([w, w, outer_height]);
		translate([outer_width/2 - button_width/2, outer_width/2 - button_width/2, 0])
			cube([button_width, button_width, button_height]);
		led_holes();
	}
}

module inner_switch() {
	extrusion_height = 3+tol_very_tight;
	extrusion_width = 2+tol_very_tight;
	extrusion_depth = 3+tol_very_tight;
	difference() {
		translate([wall_thickness + tol_wall, wall_thickness + tol_wall, 0]) {
			difference() {
			union() {
				difference() {
					cube([inner_width, inner_width, switch_height]);
					
					translate([button_wall_thickness, button_wall_thickness, extrusion_height+2]) // space above the extrusion
						cube([inner_width - button_wall_thickness*2, inner_width - button_wall_thickness*2, switch_height]);
				}
				translate([0, inner_width / 2 - button_wall_thickness/2, 0]) 
					cube([inner_width, button_wall_thickness, switch_height - lip_depth]);

			}
			translate([inner_width/2 - extrusion_width/2, inner_width/2 - extrusion_depth/2, 0]) 
				cube([extrusion_width, extrusion_depth, extrusion_height]);
			}

			translate([inner_width/2, inner_width/2, switch_height/2])
			difference() {
				cube([inner_width-button_wall_thickness*2, inner_width-button_wall_thickness*2, switch_height-lip_depth*2], center=true);
				cube([inner_width-button_wall_thickness*2-lip_size*2, inner_width-button_wall_thickness*2-lip_size*2, switch_height-lip_depth*2], center=true);
			}
		}
		led_holes();
	}
}

module bridge() {
	bridge_width = 2.5;
	bridge_length = outer_width;
	h = 3;
	translate([outer_width/2, outer_width/2, -h/2]) cube([bridge_length, bridge_width, h], center=true);
}

module led_holes() {
	squeeze = -.5;
	translate([outer_width / 2, outer_width /4 + squeeze])
	translate([0, 0, 5]) {
		cube([4, 1.2, 10], center=true);
		translate([0, outer_width / 2 - squeeze*2, 0]) cube([4, 1.2, 10], center=true);
	}
}