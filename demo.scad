/*
Just some demos for 
how the lib-FDMscrews library can be used.
*/

// scad-lib-FDMscrews
use <lib-FDMscrews.scad>


// #######################################
// Uncomment all but one of the following to activate a demo:
// #######################################

!nutAndBoltDemo(); // most useful for a testprint thus this onne left uncommented
//!multiDemo();
//!profileOverviewDemo();

// -----

// !screwByTwist(twist=0,length=10,profile = "cubic",starts=6);
// this is a straight extrusion rather than a screw 
// straight extrusion means infinite pitch
// one gets infinite pitch choosing twist to be zero 

// -----

// The exact same screw generated 
// once with screwByPitch
// once with sceewByTwist
//translate([-6,0,0]) screwByTwist(twist=360*4,length=3.6*4,profile = "cubic");
//translate([+6,0,0]) screwByPitch(pitch=3.6,length=3.6*4,profile = "cubic");

// #######################################
// #######################################

module multiDemo()
{
  nutAndBoltDemo();
  
  translate([0,-20,12/2*0.6])
    rotate(90,[0,1,0]) flatscrewThreadedRod();
}
module nutAndBoltDemo()
{
  translate([-30, 0, 0]) nutdemo();
  translate([0,0,12/2*0.6]) rotate(90,[0,1,0])
    flatscrewDemo();
}


module profileOverviewDemo()
{
  rotate(90,[0,1,0])
  {
    ss = 10; ww = 16;
    
    translate([0,+2*ww,ss*0]) screwByPitch(profile="cubic",flat=0.6,length=7.2);
    translate([0,+2*ww,ss*1]) screwByPitch(profile="sinusodial",flat=0.6,length=7.2);
    translate([0,+2*ww,ss*2]) screwByPitch(profile="sine_asym",flat=0.6,length=7.2);
    
    translate([0,+1*ww,ss*0]) screwByPitch(profile="trapezoid",flat=0.6,length=7.2);
    translate([0,+1*ww,ss*1]) screwByPitch(profile="triangular",flat=0.6,length=7.2);
    translate([0,+1*ww,ss*2]) screwByPitch(profile="triang_asym",flat=0.6,length=7.2);

    translate([0,+0*ww,ss*0]) screwByPitch(profile="sine_blobby",flat=0.6,length=7.2);
    translate([0,+0*ww,ss*1]) screwByPitch(profile="sine_spikey",flat=0.6,length=7.2);  
    translate([0,+0*ww,ss*2]) screwByPitch(profile="circular",flat=0.6,length=7.2);
    
    // the currently implemented triangulation method 
    // messes up the following profiles pretty badly
    // rect, saw_rising, saw_falling  

    translate([0,-1*ww,ss*0]) screwByPitch(profile="rect",flat=0.6,length=7.2);
    translate([0,-1*ww,ss*1]) screwByPitch(profile="saw_rising",flat=0.6,length=7.2);  
    translate([0,-1*ww,ss*2]) screwByPitch(profile="saw_falling",flat=0.6,length=7.2);

  }
}





module flatscrewThreadedRod()
{
    screwByPitch(pitch=3.6, length=32, d0=12, dr=1.5, 
      flat=0.6, chamfer1=true, chamfer2=true);
}

module flatscrewDemo()
{
  lscrewthread = 32; // 24
  d = 12;
  c = 1.0; // chamfersize
  lthreadless = 10;
  lhandle = 6;
  whandle = 20;
  
  intersection()
  {
    union()
    {
      screwByPitch(pitch=3.6, length=lscrewthread, d0=d, dr=1.5, widen1=true, chamfer2=true);
      scale([1,1,-1]) cylinder(r=d/2,h=lthreadless+lhandle/2,center=false,$fn=48);
    }
    cube([d*0.6,100,100],center=true);
  }
  translate([0,0,-lhandle/2-10])
    b3cube(d*0.6,whandle,lhandle,c,c,c);
    //cube([d*0.6,20,6],center=true);
}


// lib-cyclogearprofiles.scad
// cycloid gear library can be used as alternate outer surface for the nut
module nutdemo()
{ 
  hnut = 3.6*2.5;
  wnut = 10; dnut = wnut/cos(30);
  c = 1.5; // 1 was a bit too small 
  eps=0.05;
  clrscrew = 0.55; 
  // 0.45 was still quite a bit too less
  // 0.75 quite loose but works
  // 0.60 loose but ok
  
  rotate(30,[0,0,1])
  difference()
  {
    hull()
    {
      cylinder(r=dnut-c,h=hnut,$fn=6,center=false);
      translate([0,0,c])
      cylinder(r=dnut,h=hnut-2*c,$fn=6,center=false);
    }
    translate([0,0,-eps])
      screwByPitch(pitch=3.6, length=hnut+2*0.05, d0=12+2*clrscrew, dr=1.5,
        widen1=true, widen2=true);
  }
}

module b3cube(x,y,z,bx,by,bz)
{
  hull()
  {
    cube([x-2*bx,y-2*by,z-0*bz],center=true);
    cube([x-2*bx,y-0*by,z-2*bz],center=true);
    cube([x-0*bx,y-2*by,z-2*bz],center=true);
  }
}
