

/*
Date: 2016-07-23
Author: Lukas M. Süss aka mechadense
Name: clean-extrusion
License: LGPL / CC-BY-SA


----------------------------------------------------------------------
Problem 1: 
* OpenSCADs linear_extrude command leads to bad hyperbolic necking 
    or highly stretced triangulation
* making a chain of pairwise convex hulls instead works only for convex cross sections

Solution to problem 1:
* For every layer evaluate the function at twisted points but 
    connect the vertices vertically
    (or ideally with a 30° twist -- to get near equilateral triangles)
----------------------------------------------------------------------
Problem 2:
* no higher order functions 
( OpenSCAD is a declarative referentially transparent language
  but not a functional language)
    this leads to :
    => massive inflexible parameter threading (HACK) 
  combined with the lack of data records 
    this leads to:
    => hard to maintain code

The HACK solution 2:
* keep massive inflexible parameter threading HACK but 
    use a records library (also a HACK)
----------------------------------------------------------------------


This Library is a HACK that becomes necessary due 
to OpenSCADSs lack of higher order functions

###############################
TODO:
  maybe make sure the resoulution aspect ratio is controlled ... ??

  keep conical bevel gears as a seperate problem ...
    radial variations (spherical evolvents ...)

 further up the abstraction tree: use inverse of screw lead ??
   this allows to use 
   the value "zero" for straight profiles and 
   "negative" values for lefthanded theads

// TODO ... add an option such that a raw profile list can be supplied
    still relevant ??

-----
  test triangulation of a nontwisted extrusion ... easy WORKS :)

################### MISC ....

splitup of convenience demo
module that makes it more screwlike (started)
  screw_lead multi_start trapezoid_parameters ???
  sine profile ???
  introduction of the premade profiles
  .... records ???? 

!!! Is the 2D case still preserved ?? probably not
  Can theis be restored - is there motivation to do so ?
quite elegant for 2D case 
//pp = profile_data_2D(vert,"testprofile1"); // OLD ....
//echo(pp=pp);
//translate([0,0,-3]) polygon(points=pp[0], paths=[pp[1]]);

*/

//demo_of_the_problem();
module demo_of_the_problem()
{
  nn=32;
  phi_indices = [for (a = [0 : nn-1]) a];
  phi_angles = [for (a = phi_indices) a/nn * 360 ];
  coords_2D = [ for(phi=phi_angles) (10+2*sin(2*phi)) * [cos(phi),sin(phi)] ];
  //color("red")
  linear_extrude(height = 10, twist=360*1)
  polygon(points=coords_2D, paths=[phi_indices]);
  // translate([0,0,-5]) polygon(points=[[10,0],[0,10],[-10,0],[0,-10]], paths=[[0,1,2,3]]);
  //echo(coords_2D=coords_2D,[for (a = [0 : nn-1]) a]);
}

// ##################################
// ############## TESTS
// ##################################



// ######################### RENDERING TESTS


// #################################
// convenience function -- TODO move this in a seperate module

// combos of vertexlist and indexlist for easier passing around
// TO TEST
// "unit_circle"

// TODO move that dependency out of this module !!!
use <basic-screw-profiles.scad> // polar_profile(phi, name, parameterlist)


function shell_data_3D(resol_circ,resol_z,twist=360,z_max=10,name="testprofile1",profile_params=[]) =
  let
  ( evalparams = get_eval_params(resol_circ,resol_z,twist,z_max)
  , evalindices = get_eval_indices(resol_circ,resol_z,twist,z_max)
  , preevalpoints = [ for(i=evalparams) concat( i[0]*polar_profile(i[1],name,profile_params), i[2]) ]
  ) [concat(preevalpoints,[[0,0,0],[0,0,z_max]]),evalindices];
  // the concatenated vertices are:
  // bottom center point of the screw shell vertices
  // top centerpoint of the screw shell vertices

convenience_demo();

module convenience_demo()
{
  vert = 64;
  ss = shell_data_3D(120,50,90*2.0,20,name="testprofile1",profile_params=[]);
  //ss = shell_data_3D(3,3,a=360,l=5,name="testprofile1",profile_params=[]);
  //echo(ss=ss);
  polyhedron(points=ss[0],faces=ss[1],convexity=3);
  //clockwise when looking at each face from outside inwards

  //ballpreview(); // why a cylinder and not my profile ??
  module ballpreview() // put a low poly sphere at every vertex
  {
    for(point=ss[0])
    {
      color("red") translate(point) sphere(r=0.2); // 0.2
    }
  }
}

// ########################### INDEX TESTS

//indextests(); // low resolution for simple correctness checking
module indextests()
{
  //echo(bottom_closingface_indexlist(5,10));
  echo("TEST bcfil", bottom_closingface_indexlist(3,3));
  echo("TEST tcfil", top_closingface_indexlist(3,3)); // nothing ?!

  echo("TEST uptsil", up_pointing_triangle_strip_indexlist(3)); // OK
  echo("TEST dptsil", down_pointing_triangle_strip_indexlist(3)); // OK
  echo("TEST tspil", triangle_strip_indexlist(3)); // OK
  echo("TEST tmil", triangle_lateralsurf_indexlist(3,3)); // seems ok
  echo("TEST tslil", triangle_shell_indexlist(3,3)); 
}

// ############################## VERTEX TESTS

//vertextests();
module vertextests()
{
  //echo("profile_data_3D", polar_profile_cartesian_pos_list_3D(3,0,"testprofile1",0,0,[]) );
  echo("shell_data", triangle_shell_vertex_list(3,3,a=360,l=10,name="testprofile1") ); // OLD <<<<<<<<<<<<<
  // works :)
}


// MAIN CODE:

// #################################################################################
// SECTION: calculation of triangulation indices (polygon face vertex lists)
// #################################################################################

// ####################################################
// planned index format:
// resol_circ ... number of circumferencial vertices
// nl == resol_z... number of vertical slices
// na == resol_circ

// face_0 (0na) .. (1na-1)
// face_1 (1na) .. (2na-1)
// face_2 (2na) .. (4na-1)
// .....................
// face_(nl-1)  ((nl-1)na) .. ((nl-1)na-1)

// lower capping face (0na) .. (1na-1)
// upper capping face ((nl-1)na) .. ((nl-1)na-1) // wrong !!!

// bottom center ((nl-0)na-1)+1
// top center ((nl-0)na-1)+2
// ####################################################

function flatten(l) = [ for (a = l) for (b = a) b ];

// caution: dont shift indices of bottom and top plate centers
function shiftindices(indexshift,indextriples) = 
  [for(indextriple=indextriples) indextriple + [indexshift,indexshift,indexshift] ];

// function to shift list needed
function bottom_closingface_indexlist(resol_circ,resol_z) =
  let(centerindex = ((resol_z+1)*resol_circ-1)+1)
    [for(i=[0:resol_circ-1]) [centerindex,i,(i+1)%resol_circ]];
      // assuming points ordered CCW 

// (resol_z+1) and (resol_z+0) works - dont know why right now ...
function top_closingface_indexlist(resol_circ,resol_z) =
  let(centerindex =((resol_z+1)*resol_circ-1)+2)
    [for(i=[0:resol_circ-1]) 
      [centerindex,(i+1)%resol_circ,i] + 
      [0,(resol_z-0)*resol_circ,(resol_z-0)*resol_circ]
    ];
      // partial indexshift
      // again assuming points ordered CCW

function up_pointing_triangle_indexlist(resol_circ) = [0,resol_circ,1];
function down_pointing_triangle_indexlist(resol_circ) = [1,resol_circ,(resol_circ+1)];

// todo test this
function up_pointing_triangle_strip_indexlist(na) = 
 let
 ( c_loop = [for(i=[0:na-2]) [up_pointing_triangle_indexlist(na)+[i,i,i]] ]
 , closure = [[0,na,1] + [(na-1),(na-1),(na-1)] + [0,0,-(na)]] // -(na) wraparound !!!!
 ) concat(flatten(c_loop),closure); // flatten cloop needed ....
  
function down_pointing_triangle_strip_indexlist(na) =
 let
 ( c_loop = [for(i=[0:na-2]) [down_pointing_triangle_indexlist(na)+[i,i,i]] ]
 , closure = [[1,na,(na+1)] + [(na-1),(na-1),(na-1)] + [-(na),0,-(na)]] // -(na) wraparound !!!!
 ) concat(flatten(c_loop),closure);

// merging the two sawtooth strips to a band strip
function triangle_strip_indexlist(resol_circ) =  // no index shift needed here
  concat( up_pointing_triangle_strip_indexlist(resol_circ),
          down_pointing_triangle_strip_indexlist(resol_circ));

// stacking the strips above each other
function triangle_lateralsurf_indexlist(resol_circ,resol_z) =
  flatten(
    [for(i=[0:resol_z-1]) shiftindices(i*resol_circ,triangle_strip_indexlist(resol_circ))]
  );


function triangle_shell_indexlist(resol_circ,resol_z) =
  let // the order here is completely arbitrary - it can be changed
  ( bottom = bottom_closingface_indexlist(resol_circ,resol_z)
  , top =       top_closingface_indexlist(resol_circ,resol_z)
  , lateralsurf = triangle_lateralsurf_indexlist(resol_circ,resol_z)
  )
  concat(bottom,top,lateralsurf);

// bad naming cnvention  eval_indices makes no sense triang_shell_indices
function get_eval_indices(resol_circum,resol_z,twist,z_max) =
  triangle_shell_indexlist(resol_circum,resol_z); // cap-points are in there NOT GOOD !!! maybe ok ??




// #################################################################################
// SECTION: calculation of triangulation vertex directions and evaluation parameters
// #################################################################################

// THIS IS THE IMPORTANT PART
//   the profile twist is decoupled from the triangulation twist (which is kept zero)!

// get:
// A) the direction vector for the triangulation vertex
// B) the evaluation argument/parameter angle
function pair_direction_angle(phi,phi_offset=0,phi_twist=0) =
  [ [ cos(phi+phi_offset),sin(phi+phi_offset) ]
  , (phi + phi_offset*1 + phi_twist)%360 ];
  // the 360° warparound makes the seam for noncylic functions straight
  // BUG: there's seems to be an issue when twisting nonperiodic functions more than 90° -- why??
  // phi_twist  ... object twist        - this should not twist the triangulation
  // phi_offset ... triangulation twist - this should not twist the object
  //   phi_offset is used for nice symmetric isoscele triangulation instead of ugly right angled ones


// get the all the direction evaluation angle pairs for one slice at a specific height
function pairs_direction_angle(resol_circ,phi_offset=0,phi_twist=0) =
  [for(i=[0:resol_circ-1]) 
    pair_direction_angle(360/resol_circ*i,phi_offset,phi_twist)];

// add z as a parameter
function triplet_dir_ang_z(resol_circ,z,phi_offset=0,phi_twist=0) =
 let( diranglist = pairs_direction_angle(resol_circ,phi_offset,phi_twist) )
 [ for(dirang = diranglist) [dirang[0],dirang[1],z] ]; 


// TODO update and elaborate in this description ...
// For a nicely triangulated 3D screw profile all** points need to be prepared in advance. 
// (This can become quite a huge dataset)
// (again this threading HACK is due to the lack of support for higher order functions)
// the order of the vertices here is very imortant (see format documentation ...)

// get all triang_vertex_direction evaluation_angle evaluation_height triples for the extrusion
function triangle_lateralsurf_argument_list(resol_circ,resol_z,a=360,z_max=10) =
  flatten ( 
    [ for(i_z=[0:resol_z-0])
      let
      ( // phi_offset = 0 // beneficial for nonperiodic functions
        phi_offset = (i_z)*(360/resol_circ)/2 // (1) (il%2 is not working) -- isoscele triangulation
      , phi_twist = -(i_z/resol_z)*a // (2)
      , z = (i_z/resol_z)*z_max // resol_z vertical slices 
      ) // (1) shift the vertices of every second layer between ...
        //       ... the vertices of the surrounding layers
        // (2) turn the full angle along the full length
        //       why is the minus sign needed for a math positive twist?
      triplet_dir_ang_z(resol_circ,z,phi_offset,phi_twist)
    ]
  );

// running CCW (math positive x+ to y+ axis)
// NOTE: phi_offset is just used internaly to 
// make the triangulation symmetric isoscele triangles instead of 
// assymmetric right angled ones

function get_eval_params(resol_circum,resol_z,twist,z_max) =
  triangle_lateralsurf_argument_list(resol_circum,resol_z,twist,z_max);




 
echo("####################");
// ########################################################################## 
// ###################################### END OF parameter generation section
// ########################################################################## 


// ################################################
// putting evaluation parameters and triang_shell_indices together:
// merging the vertices with the indices
// ##################################


// shorter to use but even less comprehensible ... so usage is not recommendet
function get_eval_params_and_indices(resol_circum,resol_z,twist,z_max) =
  [ get_eval_params(resol_circum,resol_z,twist,z_max)
  , get_eval_indices(resol_circum,resol_z,twist,z_max) // cap-points are in there NOT GOOD !!!
  ];
// evalparams...[list_of_phi_z_parameter_pairs,cap_points,faces_index_list] 


// #################### END













