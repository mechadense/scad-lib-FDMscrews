// test-HOF-features.scad
// Test file to verify all API features work in the HOF version

use <scad-lib-FDMscrews/lib-FDMscrews-HOF.scad>

// Test different features systematically
spacing = 25;

// Row 1: Basic features
translate([0*spacing, 0, 0]) 
  screwByPitch(pitch=3, length=12, d0=10, dr=1.5, profile="cubic");

translate([1*spacing, 0, 0]) 
  screwByPitch(pitch=3, length=12, d0=10, dr=1.5, profile="sinusodial");

translate([2*spacing, 0, 0]) 
  screwByPitch(pitch=3, length=12, d0=10, dr=1.5, profile="triangular");

// Row 2: Chamfers and widens
translate([0*spacing, spacing, 0]) 
  screwByPitch(pitch=3, length=12, d0=10, dr=1.5, profile="cubic", 
               chamfer1=true, chamfer2=true);

translate([1*spacing, spacing, 0]) 
  screwByPitch(pitch=3, length=12, d0=10, dr=1.5, profile="cubic", 
               widen1=true, widen2=true);

translate([2*spacing, spacing, 0]) 
  screwByPitch(pitch=3, length=12, d0=10, dr=1.5, profile="cubic", 
               chamfer1=true, widen2=true);

// Row 3: Resolution and starts
translate([0*spacing, 2*spacing, 0]) 
  screwByPitch(pitch=3, length=12, d0=10, dr=1.5, profile="cubic", 
               circum_resol=48, axial_resol=24);

translate([1*spacing, 2*spacing, 0]) 
  screwByPitch(pitch=3, length=12, d0=10, dr=1.5, profile="cubic", 
               starts=2);

translate([2*spacing, 2*spacing, 0]) 
  screwByPitch(pitch=3, length=12, d0=10, dr=1.5, profile="cubic", 
               starts=3, offsetangle=45);

// Row 4: Flat parameter and screwByTwist
translate([0*spacing, 3*spacing, 0]) 
  screwByPitch(pitch=3, length=12, d0=10, dr=1.5, profile="cubic", 
               flat=0.8);

translate([1*spacing, 3*spacing, 0]) 
  screwByPitch(pitch=3, length=12, d0=10, dr=1.5, profile="cubic", 
               flat=0.4);

translate([2*spacing, 3*spacing, 0]) 
  screwByTwist(twist=360*3, length=12, d0=10, dr=1.5, profile="cubic", 
               flat=0.6);

// Test labels (comment/uncomment as needed)
s=10;
translate([0*spacing, -s, 0]) 
  text("basic", size=3, halign="center");
translate([1*spacing, -s, 0]) 
  text("sine", size=3, halign="center");
translate([2*spacing, -s, 0]) 
  text("tri", size=3, halign="center");

translate([0*spacing, spacing-s, 0]) 
  text("chamfers", size=3, halign="center");
translate([1*spacing, spacing-s, 0]) 
  text("widens", size=3, halign="center");
translate([2*spacing, spacing-s, 0]) 
  text("mixed", size=3, halign="center");

translate([0*spacing, 2*spacing-s, 0]) 
  text("low-res", size=3, halign="center");
translate([1*spacing, 2*spacing-s, 0]) 
  text("2-start", size=3, halign="center");
translate([2*spacing, 2*spacing-s, 0]) 
  text("3-start+offset", size=3, halign="center");

translate([0*spacing, 3*spacing-s, 0]) 
  text("flat=0.8", size=3, halign="center");
translate([1*spacing, 3*spacing-s, 0]) 
  text("flat=0.4", size=3, halign="center");
translate([2*spacing, 3*spacing-s, 0]) 
  text("twist", size=3, halign="center");
