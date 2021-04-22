
use <basic-screw-profiles.scad> // all the profile_… functions
use <minimal_extrusion_core.scad> // get_eval_indices & get_eval_params
// see minimal-extrusion-boilerplate-demo.scad

screwByPitch();
//screwByTwist();

defresolcirc = 96; // 64, 96, 128
defresolax = 48; // 32, 48, 64

// ##########################

module screwByPitch
  ( pitch = 3
  , length = 12
  , d0 = 10
  , dr = 1.5
  , circum_resol = defresolcirc
  , axial_resol = defresolax
  , starts = 1
  , profile = "cubic"
  , offsetangle = 0
  , flat = 1
  , chamfer1 = false
  , chamfer2 = false
  , widen1 = false
  , widen2 = false
  ) 
{
  r0 = d0/2;
  twist = length/(pitch*starts)*360;
  axial_resol2 = ceil(axial_resol*length/(2*r0));
  // ceil is to prevent non-manifoldness of the result
  
  intersection()
  {
    screw_internal
      ( profile
      , r0, dr
      , twist
      , length // <<<<<<<<<< z_max = length
      , circum_resol 
      , axial_resol2 // z_resol = axial_resol
      , starts
      , offsetangle
      );
    screwcropper(length,r0,dr,flat,chamfer1,chamfer2,circum_resol);
  }
  screwaugmenter(length,r0,dr,flat,widen1,widen2,circum_resol);
}

module screwByTwist
  ( twist = 360*4
  , length = 12
  , d0 = 10
  , dr = 1.5
  , circum_resol = defresolcirc
  , axial_resol = defresolax
  , starts = 1
  , profile = "cubic"
  , offsetangle = 0
  , flat = 1
  , chamfer1 = false
  , chamfer2 = false
  , widen1 = false
  , widen2 = false
  ) 
{
  r0 = d0/2;
  axial_resol2 = ceil(axial_resol*length/(2*r0));
  
  intersection()
  {
    screw_internal
      ( profile
      , r0, dr
      , twist
      , length // <<<<<<<<<< z_max = length
      , circum_resol 
      , axial_resol2 // z_resol = axial_resol
      , starts
      , offsetangle
      );
    screwcropper(length,r0,dr,flat,chamfer1,chamfer2,circum_resol);
  }
  screwaugmenter(length,r0,dr,flat,widen1,widen2,circum_resol);
  
  //  translate([0,0,(length+2)/2-1])
  //    cube([2*r0*flat,(r0+dr)*2+2,length+2],center=true);
  //} 
}



// ###############################
// ###############################

module screwaugmenter
  ( length, r0, dr
  , flat = 0.6
  , widen1 = false
  , widen2 = false
  , circum_resol = defresolcirc
  )
{
    if(widen1)
  {
    intersection()
    {
      translate([0,0,0])
        cylinder(r1=r0,r2=r0-dr,h=dr,center=false,$fn=circum_resol);
      // the flat
      translate([0,0,dr/2])
        cube([2*r0*flat,r0*2+2,dr],center=true);
    }
  }
  if(widen2)
  {
    intersection()
    {
      translate([0,0,length-dr])
        cylinder(r2=r0,r1=r0-dr,h=dr,center=false,$fn=circum_resol);
      // the flat
      translate([0,0,length-dr/2])
        cube([2*r0*flat,r0*2+2,dr],center=true);
    }
  }
}

module screwcropper
  ( length, r0, dr
  , flat = 0.6
  , chamfer1 = false
  , chamfer2 = false
  , circum_resol = defresolcirc
  )
{
  intersection()
  {
    union()
    { // chamfer
      if(chamfer1)
      {
        translate([0,0,0])
          cylinder(r1=r0-dr,r2=r0,h=dr,center=false,$fn=circum_resol);
      }         
      if(chamfer2)
      {
        translate([0,0,length-dr])
          cylinder(r1=r0,r2=r0-dr,h=dr,center=false,$fn=circum_resol);
      }
      dl = 0 + (chamfer1 ? dr : 0) + (chamfer2 ? dr : 0);
      //echo("AAAAAAAA",chamfer1,camfer1 ? dr : 0);
      translate([0,0,chamfer1 ? dr : 0 ])
        cylinder(r=r0,h=length-dl,center=false,$fn=circum_resol);
    }
    // the flat
    translate([0,0,(length+2)/2-1])
      cube([2*r0*flat,r0*2+2,length+2*dr],center=true);
  }
}



// ###############################
// ###############################

module screw_internal
  ( screwtype = "circular"
  , r0 = 5
  , dr = 1.5
  , twist = 360*4
  , z_max = 12
  , circum_resol = defresolcirc*1
  , z_resol = defresolax*1
  , starts = 1
  , offsetangle = 0  // assert offsetangle>=0
  )
{
  // choose profile function by screwtype name ....
  function profileradiusfunction(phi) =
    // best for FDM 3D-printing:
    (screwtype == "cubic")     ? (r0 + dr*(profile_cubic(phi+180)-1)) :
    // todo: profile cycloid ...
    (screwtype == "sinusodial") ? (r0 + dr*(profile_sinusodial(phi)-1)) :
    (screwtype == "triangular") ? (r0 + dr*(profile_triangular(phi)-1)) :
    (screwtype == "circular")   ? (r0 + dr*(profile_circular(phi%360)-1)) :
    // just special case:
    (screwtype == "trapezoid") ? (r0 + dr*(profile_trapezoid0(phi)-1)) :
    (screwtype == "triang_asym")? (r0 + dr*(profile_triang_asym(phi%360)-1)) :
    (screwtype == "sine_asym")  ? (r0 + dr*(profile_sine_asym(phi%360)-1)) :
    // bad triangulation :(
    (screwtype == "rect")       ? (r0 + dr*(profile_rectangular(phi)-1)) :
    (screwtype == "saw_rising") ? (r0 + dr*(profile_saw_rising(phi)-1)) :
    (screwtype == "saw_falling")? (r0 + dr*(profile_saw_rising(phi)-1)) :
    // the funky ones ...
    (screwtype == "sine_spikey")? (r0 + dr*(profile_sine_spikey(phi)-1)) :
    (screwtype == "sine_blobby")? (r0 + dr*(profile_sine_blobby(phi)-1)) :
    // the really funky ones:

    (screwtype == "squarefourier5")       ? (r0 + dr*(profile_fourier5_square(phi%360)-1)) :
    r0*phi/360; // in case of no match default to something crazy that can hardly be missed.
    //r0+0; // default to constant ? Opt to not to.

  evalparams = get_eval_params(circum_resol,z_resol,twist,z_max);
  evalindices = get_eval_indices(circum_resol,z_resol,twist,z_max);
  //echo(evalparams);
  //echo(evalindices);

  // WARNING: Too many unnamed arguments supplied, in file lib-FDMscrews.scad, line 217 -- ???
  // i[0] ... direction vector with unit length
  // i[1] ... cylindercoord evaluation angle for user supplied function (can go negative!!)
  // i[2] ... cylindercoord evaluation height for user supplied function
  preevalpoints =
    [ for(i=evalparams)
      concat( i[0]*profileradiusfunction(starts*i[1]+offsetangle+360,i[2]), i[2] ) ];
    
  translate([0,0,0])
    polyhedron(points = concat(preevalpoints,[[0,0,0],[0,0,z_max]]),faces = evalindices,convexity =3);
  // the last two explicit verticies are the bottom face and top face centerpoints
  // they are necessary for a perfectly symmetrical star shaped triangulation
}
