
# scad-lib-FDMscrews

**This is a minimal OpenSCAD library to generate screw threads  
that are optimized for FDM 3D printing.**  
There is a chapter further down on why you might want to or why you might not want to use 3D printed plastic screws.  

<!--- ![ShowcaseOfSomePossibleScrews](screwdemo.png) --->
<img src="screwdemo.png" alt="ShowcaseOfSomePossibleScrews" width="100%"/>

Above examples in demo.scad  

**Existing standards are not a focus and not provided here since:**  

* Existing standards (metric, imperial, …) are not and where never meant for FDM printing (with its peculiar design constraints)  
* OpenSCAD libraries for existing standards do exist <br> (references at the very end)  

## Installation

Put this library in one of the standard locations for OpenSCAD libraries:  
http://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Libraries  
**For linux it's:** $HOME/.local/share/OpenSCAD/libraries  

## Basic Usage

Import the library with:  
**use <scad-lib-FDMscrews/lib-FDMscrews.scad>**  

Then get stared with the demos in demo.scad or the following:

**screwByPitch(pitch=3.6, d0=12, dr=1.5, length=12, flat=0.6);**  
**screwByTwist(twist=360*4, d0=12, dr=1.5, length=12, flat=0.6);**  

* d0 … outermost diameter of the screw  
* dr … total profile depth from radius r0 = d0/2 down to (r0-dr)  
* pitch … standard thread pitch ([see wikipedia](https://en.wikipedia.org/wiki/Screw_thread#Lead,_pitch,_and_starts))  
* twist … number of turns along the whole length of z_max  
* length … total length of the screw  
* flat … this cuts off the sides of the screws down to (d0*flat)
* … more parameters are listed further down …

_With twist=0 infinite pitch is possible. This gets you a fancy slide-rail._  
_The pitch parameter needs to be bigger than zero. Caution: there's no safety net in place._  

The flat parameter is provided so that the screws can be printed laying flat 
which **MASSIVELY** increases the tensile strength of the screw for most common FDM plastics. 
Assuming these screws are printed sideways (as highly suggested) 
by cutting off the sides one gets rid of:  

* need for support material (on the underside)  
* critical overhangs bigger than 45° (on the underside)  
* print layers with many insular spots leading to <br>many printhead jumps with retractions and stringing <br>(both on the underside and on the upper side)  

If you create a more fancy screw rather than than just a threaded rod, then 
instead of using the "flat" parameter you may want to do the flat-cutting manually 
at the end of the modelling process via an intersection with a cube.   
See: "flatscrewDemo()" in demo.scad  

## Additional parameters that can be changed from their default (for both functions) are:  

* chamfer1 … at the origin: chamfer the thread 45° over the hole depth of the thread  
* widen1 … at the origin: taper the core 45° out to (r0 = d0/2) over the hole depth of the thread – (to strenghten a transition to an unthreaded section of the screw with diameter d0)  

The same for the other side of the screw:  

* chamfer2 … at the other end: same as above  
* widen2 … at the other end: same as above  

**Triangulation Resolution:**  

* circum_resol … number of triangulation subdivisions over the whole circumference (default is 96)  
* axial_resol … number of triangulation subdivisions over an axial lenght of d0 (default is 48)  

**Other parameters:**  

* starts … number of starts of the thread (default is 1 – see further notes below)  
* profile … the shape of the profile of the screw (default is cubic – see further notes below for a list of available options)  
* offsetangle … if the angle of where the thread is starting is relevant then it can be adjusted here (default is 0)  
* flat … cutoff factor in therms of of d0 (default is 1 that is no cuttoff is applied)


## Examples:

Some demos are included in the file "demo.scad".  
The images at the tops where generated there.  
There is:  

* A demo for a basic nut and basic bolt – "nutAndBoltDemo()"  
* A demo for the profiles – "profileOverviewDemo()"  
* A demo with twist = 0  
* A demo how to make the same screw by giving pitch or twist

## Available thread profiles 

* Most useful for FDM printing (since fastly printable without jerks): "sinusodial" and "cubic" (default)  
* Classical profiles: "triangular", "trapezoid"  
* Asymmetric versions: "sine_asym", "triang_asym"  
* Exotic: "sine_spikey", "sine_blobby"  
* Crazy: "squarefourier5" a fifth order fourier approximation of a square wave (interesting: [Gibbs phenomenon](https://en.wikipedia.org/wiki/Gibbs_phenomenon))

Default is the "cubic" profile.  
It is a cubic piecewise function (a + b*x + c*x^2)  

* therefore the FDM 3D printing printhead speed is a quadatic piecewise function  
* therefore the FDM 3D printing printhead acceleration (and forces) is a continuous triangle wave without jumps (NO jerks)  
* mathematically simpler than a sine function (not that it matters much)  

The "sinusodial" profile has all its derivatives being sinusodial too. 
But in practice "sinusodial" and "cubic" can barely be distinguished. 
Especially if triangulation resolution is low.

Profiles for which the here implemented triangulation method unfortunately turned out to be unsuitable:

* Borderline usable: "circular" 
* Pretty much unusable: "rect", "saw_rising", "saw_falling" (BUG same as rising??),

## Further notes (known issues)

The standard rotate_extrude function that comes with OpenSCAD was(is)  
not usable for this library because it leads to bad triangulations  
with very long and slim triangles (degenerate triangles)  

The alternate triangulation method used here (projecting out the cylinder coordinates and evaluating there)  
comeswith with its own limitations.  
It is not suitable for profiles with vertical or very steep flanks like e.g.  
rectangular profiles, sawtooth profiles, steep trapezoidal profiles and  
even circular profiles to some degree.  

* Starts > 1 … chose this for quick acting screws or lead screws  
    (theses kind of threads can be found on drinking bottles and pickle jars)  

This library was pushing hard on the limitats of OpenSCAD and thus had to be dialed back.  
No support for higher order functions means I unfortunately cannot provide  
completely user definable profiles (without hacking hardcoded stuff in the library).  

For details see: [addressed-and-remaining-issues.md](addressed-and-remaining-issues.md)  

## Outlook

Go for a different triangulation approach where  
the triangulation follows the twist of the thread such that  
screw profiles with sharp drops like square, sawtooth, circular, cycloidal and more  
become possible too.  

Since for FDM printing the pitch needs to be quite big  
(because we print the screws laying on the side for giving them way more tensile strength  
and the standard FDM nozzel diamater is about 0.4mm)  
**these screws do not have good self holding by friction properties**.  
The planned solution:   
Designing of a dedicated cliplock for these kinds of low-pitched screws.  

# Known specific issues

WARNING: Too many unnamed arguments supplied, in file lib-FDMscrews.scad, line 217  

## Other screw-libraries for existing standards (none are meant for FDM printing)

To my knowledge there are no screw standards that where 
specifically created to abide the constraints of FDM printing.

**If you are looking for screw libraries that implement existing standards  
then here are some useful options:**

aubenc's "Poor man's openscad screw library"  
https://www.thingiverse.com/thing:8796  
Usefulf for screws that are common in photo equipment.

The MCAD librarie whick comes "batteries-included" with the newer OpenSCAD versions  
https://github.com/openscad/MCAD/blob/master/nuts_and_bolts.scad  

# Structure of internal dependencies:

demo.scad depends on lib-FDMscrews.scad  
lib-FDMscrews.scad internally depends on  

* basic-screw-profiles.scad <br>in there are defined all the "profile_xyz" functions  
* minimal_extrusion_core.scad <br>in there are defined: get_eval_indices & get_eval_params  

# Why 3D printed plastic screws ??

**Valid reasons to for 3D printed plastic screws might be:** 

* Artistic style: You want to give your 3D printed multi-part designs a unique and cool look.  
* You want to avoid non 3D printable "vitamins" at all costs. (e.g. due to investigatins in self replication)  
* Out of some reason you can't get some needed screws fast enough for something that you want to extremely urgently try.  


**Likely invalid reasons:**

* Saving money. Because printing these screws is time and labour intensive so the effective cost is way more than just the cost of the plastic.  
* Avoiding the weight of metal screws (or other properties like ferromagnetism, ...). This is hardly an argument since there also are plastic screws available commercially. And these non 3D printed plastic screws are smaller and even made form a better low friction plastic (Delrin aka POM aka polyoxymethalate). POM which is available as filament but extremely difficult to 3D print because of massive shinkage in conjunction with abysmal printbed adhesion (a devilish combo).

