// TODO
// line up fillet radii
// x add pcb bracket
// get measurements down
// get PCB coordinates
// make button action smoother by adding some guide mechanism (spheres?)


tol_tight = 0.1;
tol_very_tight = .05;
epsilon = 1e-4;

button_height = 7+tol_tight;
button_width = 7+tol_tight;

// This variable was added to make the button stick out a bit from the chassis, due to problems where
// the button would rest too far deep in the chassis and not switch when pressed
//.5; not needed right now, as PCB will cause button to protrude a bit
button_protrude = 1;// 0; TODO: change

switch_size = 14;
switch_base_thickness = 5;
switch_height = 20;
lens_thickness = 1;

// radius of switch bumps that help move switch more smoothly
bump_r = .86;//.82; // .75 gives space of .113 - pretty good but could be tighter, trying 0.82. better, now trying 0.86
bump_start = 7; // 4mm from the top - was 4 trying 7

inner_wall_thickness = 0.9;
outer_wall_thickness = 0.5;

lens_size = switch_size-outer_wall_thickness*2-tol_tight*2;
echo(str("Lens size: ", lens_size));

// size of divider that blocks light from top and bottom half
switch_divider_thickness = .5; 

// hole where the pushbutton attaches
button_mount_height = 3+tol_very_tight;
button_mount_width = 2+tol_very_tight;
button_mount_depth = 3+tol_very_tight;


chassis_size = .69*25.4-tol_tight*2; // from old design
chassis_wall_thickness = 0.8;
chassis_lip = .75;
chassis_lip_thickness=2;
chassis_lip_depth = 0; //0.5;
chassis_base_thickness = button_height-button_protrude;
chassis_height = switch_height+button_height+tol_tight; // TODO: auto generate


// PCB related parameters
pcb_thickness = 2.5;
pcb_mount_width = 3; // the PCB gets smaller as this gets larger
pcb_mount_height = 3; // more of the PCB is blocked as this gets larger
pcb_mount_depth = pcb_thickness+tol_tight*2;
pcb_mount_depth_support = 3; // depth of the support bar


switch_bevel_r = 0;
chassis_bevel_r = .5;

switch_offset = chassis_size/2-switch_size/2;


echo(str("Thickness of switch base below button mount: ", 
	switch_base_thickness-button_mount_depth));
	
echo(str("Space between chassis and switch: ", switch_offset-chassis_wall_thickness));
echo(str("Space between chassis and switch (including bump): ", switch_offset-chassis_wall_thickness-bump_r));

led_cutout_width = 4;
led_cutout_height = 2;

led_cutout_width_chassis = 3;
led_cutout_height_chassis = .8;


// halfway between inner wall end and divider start
led_cutout_location = (inner_wall_thickness+(switch_size/2-switch_divider_thickness/2))/2 - .7;
led_cutout_location_chassis = led_cutout_location+switch_offset;
echo(str("LED-switch clearance (x-axis): ", led_cutout_location-inner_wall_thickness));

// preview();
chassis();
// switch(fn=40);
// cube([chassis_size, 2, pcb_thickness]);
// lens();
/*
	lens();
	translate([.6, -300+lens_size+3.5, switch_height-lens_thickness])
		color([1, .1, .1])
			linear_extrude(lens_thickness*2)
				 import("tmp_lens_export.svg", dpi=96);
//*/


module lens() {
	translate([outer_wall_thickness+tol_tight, outer_wall_thickness+tol_tight, switch_height-lens_thickness]) cube([lens_size, lens_size, lens_thickness]);
}

module preview() {
	translate([0, 0, -chassis_height]) chassis();
	translate([switch_offset, switch_offset, -switch_height]) switch(fn=20);
}

module chassis() {
	
	// pcb mount
	translate([0, 0, -pcb_mount_depth])
		cube([pcb_mount_height, pcb_mount_width, pcb_mount_depth]);
	translate([chassis_size-pcb_mount_height, 0, -pcb_mount_depth])
		cube([pcb_mount_height, pcb_mount_width, pcb_mount_depth]);
	translate([0, chassis_size-pcb_mount_width, -pcb_mount_depth])
		cube([pcb_mount_height, pcb_mount_width, pcb_mount_depth]);
	translate([chassis_size-pcb_mount_height, chassis_size-pcb_mount_width, -pcb_mount_depth])
		cube([pcb_mount_height, pcb_mount_width, pcb_mount_depth]);
	
	translate([0, 0, -pcb_mount_depth-pcb_mount_depth_support])
		cube([pcb_mount_height, chassis_size, pcb_mount_depth_support]);
	translate([chassis_size-pcb_mount_height, 0, -pcb_mount_depth-pcb_mount_depth_support])
		cube([pcb_mount_height, chassis_size, pcb_mount_depth_support]);

	
	
	// lip
	translate([-chassis_lip, -chassis_lip, chassis_height-chassis_lip_depth-chassis_lip_thickness])
		linear_extrude(chassis_lip_thickness) half_fillet_ring(width=chassis_lip, s=chassis_size+chassis_lip*2);
	
	// main chassis
	difference() {
		union() {
			linear_extrude(chassis_height-epsilon) fillet_square(s=chassis_size);
			linear_extrude(chassis_height-chassis_lip_depth) square(chassis_size);

		}
		
		union() {
			// main chassis hole
			translate([chassis_wall_thickness, chassis_wall_thickness, chassis_base_thickness]) 
				linear_extrude(chassis_height-chassis_base_thickness) 
					square(chassis_size-chassis_wall_thickness*2);
			
			// button cutout
			translate([chassis_size/2, chassis_size/2, (chassis_base_thickness)/2])
				cube([button_width, button_width, chassis_base_thickness], center=true);
			
			// upper LED cutout
			translate([led_cutout_location_chassis, chassis_size/2, chassis_base_thickness/2])
				cube([led_cutout_height_chassis, led_cutout_width_chassis, chassis_base_thickness], center=true);
			// lower LED cutout
			translate([chassis_size-led_cutout_location_chassis, chassis_size/2, chassis_base_thickness/2])
				cube([led_cutout_height_chassis, led_cutout_width_chassis, chassis_base_thickness], center=true);

		}
	}
}


// moving part that the user presses
module switch(fn=50) {
	
	// switch bumps
	offset = 4.5;
	translate([0, 0, switch_height-bump_start]) {
		scale([1, 1, 2]) difference() {
			union() {
				translate([0, switch_size/2-offset, 0]) sphere(bump_r, $fn=fn);
				translate([switch_size/2-offset, switch_size, 0]) sphere(bump_r, $fn=fn);
				translate([switch_size/2-offset, 0, 0]) sphere(bump_r, $fn=fn);
				translate([switch_size, switch_size/2-offset, 0]) sphere(bump_r, $fn=fn);
				translate([0, switch_size/2+offset, 0]) sphere(bump_r, $fn=fn);
				translate([switch_size/2+offset, switch_size, 0]) sphere(bump_r, $fn=fn);
				translate([switch_size/2+offset, 0, 0]) sphere(bump_r, $fn=fn);
				translate([switch_size, switch_size/2+offset, 0]) sphere(bump_r, $fn=fn);

			}
			translate([0, 0, -bump_r]) cube([switch_size, switch_size, bump_r*2]);
		}
	}

	// switch base
	difference() {
		linear_extrude(switch_base_thickness)
			fillet_square(r=switch_bevel_r, s=switch_size);
		
		union() {
			// button attach point cutout
			translate([switch_size/2, switch_size/2, button_mount_depth/2])
				cube([button_mount_height, button_mount_width, button_mount_depth], center=true);
			
			// upper LED cutout
			translate([led_cutout_location, switch_size/2, switch_base_thickness/2])
				cube([led_cutout_height, led_cutout_width, switch_base_thickness], center=true);
			// lower LED cutout
			translate([switch_size-led_cutout_location, switch_size/2, switch_base_thickness/2])
				cube([led_cutout_height, led_cutout_width, switch_base_thickness], center=true);

			
		}
	}

	// switch center divider wall
	translate([switch_size/2 - switch_divider_thickness/2, 0, switch_base_thickness]) {
		cube([switch_divider_thickness, switch_size, 
			switch_height-lens_thickness-switch_base_thickness]);
	}

	// switch inner wall (lens rests on top of this)
	linear_extrude(switch_height-lens_thickness)
		half_fillet_ring(r=switch_bevel_r, s=switch_size, width=inner_wall_thickness);

	// switch outer wall
	linear_extrude(switch_height)
		half_fillet_ring(r=switch_bevel_r, s=switch_size, width=outer_wall_thickness);
}



//translate([0, 0, 3]) square(10);

// a square ring that is filleted on the outside, but not on the outside
module half_fillet_ring(width=1, s=10, r=1, fn=50) {
	difference() {
		fillet_square(s=s, r=r, fn=fn);
		
		translate([width, width])
			square(size=s-width*2);
	}
}

// a square ring with filleted edges
module fillet_ring(width=1, s=10, r=1, fn=50) {
	difference() {
		fillet_square(s=s, r=r, fn=fn);
		
		translate([width, width])
			fillet_square(s=s-width*2, r=r-width, fn=fn);
	}
}

// a square with filleted edges
module fillet_square(s=10, r=1, fn=50) {
	translate([r, r, 0]) {
		size1 = s-2*r;
		square(size=size1);
		translate([-r, 0, 0]) square([r, size1]);
		translate([size1, 0, 0]) square([r, size1]);
		
		translate([0, -r, 0]) square([size1, r]);
		translate([0, size1, 0]) square([size1, r]);
		
		circle(r=r, $fn=fn);
		translate([size1, 0, 0]) circle(r=r, $fn=fn);
		translate([0, size1, 0]) circle(r=r, $fn=fn);
		translate([size1, size1, 0]) circle(r=r, $fn=fn);
	}
}