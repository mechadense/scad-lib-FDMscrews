/*
Date: 2016-07-23 ... 2017-12-13
Author: Lukas M. Süss aka mechadense
Name: basic-screw-profiles
License: Public Domain
*/


// ####################################
// ------------------------------------ PROFILE MODIFIERS
  
  // All profiles are supposed be properly defined in the bounding box: [[-1,-1],[+1,+1]] -- covering the whole range [[_,-1],[_,+1]]

  // These triangular and saw waveforms (of period length 1) are tools 
  // to make non-periodic functions periodic

  function trirepeater0(x) = abs(((x*2+1)%2)-1)*2-1; // 0:1(=maximum) periodlength:1
  // f(-1/2)=1 linear-down f(0)=-1 linear-up f(+1/2)=1

  function sawrepeater1(x) = x-floor(x); // (can be used as profile)
  // f(0)=0 linear-up f(1)=1 jump-down
  
  
  // ####### profile amplitudes must be between 0 and 1 reaching both ##### !!!
  // "crop01(x)" can be used to cull the profile function to these limits
  function crop01(x) = min(1,max(0,x));


// ####################################
// ------------------------------------ PROFILES
  // you may add more profiles here ... (plus corresponding entries at §§ locations)

  // simple sinusodial
  function profile_sinusodial(x) = (1-cos(x))/2; // thread profile

  // rectangular
  function profile_rectangular(x) = (sign(sin(x))+1)/2;

  // simple triangular (linear) (kinks make speed steps make acceleration spikes)
  function profile_triangular(x) = abs(((x/360*2+1)%2)-1);
    // triangular //abs(((x+1)%2)-1)

  // simple cubical:
  // squarewavejerk is designed such 
  // that when the printer nozzle is moved along its range [-1:+1]
  // the acting accelerations and forces make a triangle wave 
  // avoiding spikes in change rate of the acceleration (the "jerk")
  function squarewavejerk(x) = (1+pow(x,3)/2-3*x/2)/2;
  function profile_cubic(x) = squarewavejerk(trirepeater0(x/360));

  // simple quartical: TODO ... probably of no use thus not implemented 
  // function profile5(x) = "yet undefined";

  // triangular stretched and cropped to trapezoidal
  // TODO add some steeper versions
  // trapezoidal stretchable & shiftable
  t1 = 2; t2 = 0*0.25;
  //function profile_trapezoid(x,t1,t2) = crop01( (profile2(x)-1/2)*t1+1/2+t2 );
  function profile_trapezoid(x,t1,t2) = crop01( (profile_triangular(x)-1/2)*t1+1/2+t2 );
    // BUG: for some screw-lengths this leads to soem non-manifold results :S

  function profile_trapezoid0(x) = profile_trapezoid(x,2,0*1/4);
  function profile_trapezoid_steep(x) = profile_trapezoid(x,4,0*1/4); // yet unused

  function profile_saw_rising(x) = ( ceil(x/360) -(x/360) );
  function profile_saw_falling(x) = ( (x/360)-floor(x/360) );

  // sinusodial saw
  function profile7(x) = profile_sinusodial(sawrepeater1(x/360)*360/2); // pos & neg
  // TODO: barrel & pillow

  // first terms of fourier series of rectangular wave
  // sin(x)+1/3*sin(3*x)+1/5*sin(5*x)+ ... 
  function profile_fourier5_square(x) = 
    crop01( ( sin(x)+1/3*sin(3*x)+1/5*sin(5*x)*0 )/2+1/2 );
  function profile101(x) = (1  - cos( x+cos(x)*45 ))/2; 

  // circular (note the harsh 0° overhangs !)
  function circles(x) =
    1/2*(
    (x<=1/2) ? 0.99+sqrt(1-pow(4*x-1,2)) : 
    (x> 1/2) ? 1-sqrt(1-pow(4*x-3,2)) :1
    );
  function profile_circular(x) = sawrepeater1(circles(x/360));
  
  //echo( profile6(360.1)); // phi>360 PROBLEM
  // where did profile6 go ???

  // sinusodial convex braid
  function profile_sine_blobby(x) = abs(cos(x/2));
  // sinusodial concave spikes
  function profile_sine_spikey(x) = 1-abs(cos(x/2));
  // TODO: combination => curly brace shape .....

  // gap trouble trianglesaw4 / sinusodial trianglesaw4
  function slanttriangle(x,n) = ( (x<(1-1/n)) ? (n/(n-1))*x : 1 - (n)*x ); 
  function profile_triang_asym(x) = sawrepeater1( slanttriangle(x/(360+0.1),4) );
  // saw from stretched and squeezed sinusodial
  // => soft profile with overhangs mainly on one side in case of
  // NOT RECOMMENDET vertical orientation print
  function profile_sine_asym(x) = 
    1/2-1/2*cos( 180* sawrepeater1( slanttriangle(x/(360+0.1),4) )  );


// ##############################


// parameters r0 , dr
function polar_profile(phi, name="unitcircle", parameters = []) =
  (name == "unitcircle") ? 1 :
  (name == "testprofile1") ?  10*profile_sinusodial(phi) : 1;
  //(name == "testprofile1") ?  testprofile1(phi) : 1;
  // testprofile1 not defined
  
  
  
// ############## OLD STUFF
/*
// currently the format parameter is pretty undefined ... TODO change that
// todo ... radial clearingshift .... offset clearingshift ...
// The list of predefined profile - supposed to be hidden away in a seperate library

  // name == "syntaxtree" ? ... 
  // use the paramlist as a syntax tree for algebraic expressions 
  // STOP -- just a hypothetical possibility
  // would require serious language reimplementation in the 
  // unsuitable host language OpenSCAD
  // its easier for users to just extend the function list here instead
*/

  