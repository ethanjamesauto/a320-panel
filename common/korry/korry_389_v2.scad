tol_tight = 0.1;
tol_very_tight = .05;


switch();

// moving part that the user presses
module switch() {
	switch_size = 10;
	switch_bevel_r = .5;
	switch_base_thickness = 5;
	switch_height = 10;
	lens_thickness = 1;

	// size of divider that blocks light from top and bottom half
	switch_divider_thickness = .5; 

	// hole where the pushbutton attaches
	button_mount_height = 3+tol_very_tight;
	button_mount_width = 2+tol_very_tight;
	button_mount_depth = 3+tol_very_tight;
	
	echo(str("Thickness of switch base below button mount: ", 
		switch_base_thickness-button_mount_depth));
	
	led_cutout_width = 3;
	led_cutout_height = 1;
	
	// halfway between inner wall end and divider start
	led_cutout_location = 2;

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
			
		}
	}

	// switch center divider wall
	translate([switch_size/2 - switch_divider_thickness/2, 0, switch_base_thickness]) {
		cube([switch_divider_thickness, switch_size, 
			switch_height-lens_thickness-switch_base_thickness]);
	}

	// switch inner wall (lens rests on top of this)
	linear_extrude(switch_height-lens_thickness)
		half_fillet_ring(r=switch_bevel_r, s=switch_size, width=.8);

	// switch outer wall
	linear_extrude(switch_height)
		half_fillet_ring(r=switch_bevel_r, s=switch_size, width=.5);
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