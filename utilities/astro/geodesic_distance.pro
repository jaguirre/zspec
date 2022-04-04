;$Id: geodesic_distance.pro,v 1.1 2004/02/03 20:48:29 glaurent Exp $
;$Log: geodesic_distance.pro,v $
;Revision 1.1  2004/02/03 20:48:29  glaurent
;040203 -GL general updates (minor)
;
;Revision 1.1  2004/01/14 20:19:16  glaurent
;040114 GL general updates
;
;Revision 1.2  2001/10/01 16:07:01  tcrawfor
;fixed typo in geodesic_distance.pro and added option to use healpix number as input
;
;Revision 1.1  2001/09/29 18:01:53  jjbezair
;
;updated pointing model with Danish treatment of sun sensors
;added function geodesic_distance which calculates the distance between
;two points on the sphere
;
;This function calculates the geodesic distance between two points on
;the sphere. It takes two points in equatorial coordinates (ra in
;hours and dec in degrees) and returns geodesic distance in degrees
;
;----------------------------------------------------------------------------- 
; NAME:
;	GEODESIC_DISTANCE.PRO
; 
; PURPOSE:
;	Calculate geodesic distance between two points on a sphere.
;	
; CALLING SEQUENCE:  
;	result = GEODESIC_DISTANCE(ra1,dec1,ra2,dec2, pixel1=pixel1, 
;		pixel2=pixel2, nside=nside)
;
; INPUT: 
;	RA1 - ra of first point (or vector of points) in hours
;
;	RA2 - ra of second point (or vector of points) in hours
;
;	DEC1 - dec of first point (or vector of points) in degrees
;
;	DEC2 - dec of second point (or vector of points) in degrees
;
; OUTPUT: 
;	RESULT - geodesic distance in degrees
;
; KEYWORDS: 
;	PIXEL1 - to use healpix pixel number as input (instead of ra and dec),
;		set this to the healpix pixel number for the first point
;		(or vector of points).
;
;	PIXEL2 - set this to the healpix pixel number for the second point
;		(or vector of points).  Must be set if PIXEL1 is set.
;
;	NSIDE - set this to the healpix nside parameter used for PIXEL1
;		and PIXEL2.  Must be set if PIXEL1 is set.
;
;
; NOTES:
;	If pixel number is used as input, first four function arguments 
;		are ignored and can be omitted.
;	Assumes RING ordering for pixel numbers.
;
; ROUTINES USED:
;	nside2npix.pro
;	pix2ang_ring.pro
;
; HISTORY: 
;	Added pixel-number input option, 1-Oct-01, TC
;	Created 29-Sep-2001, JB 
;
;-----------------------------------------------------------------------------


function geodesic_distance,ra1,dec1,ra2,dec2

ra1r = double(ra1/12.d*!pi)
ra2r = double(ra2/12.d*!pi)
dec1r = double(dec1*!dtor)
dec2r = double(dec2*!dtor)

; CALCULATE DISTANCE 
distance = acos((cos(double(dec1r+!pi/2.))*cos(double(dec2r+!pi/2.))+ $
	sin(double(dec1r+!pi/2.))*sin(double(dec2r+!pi/2.))* $
	cos(ra2r-ra1r) < 1.d))/double(!dtor)

return ,distance
end
