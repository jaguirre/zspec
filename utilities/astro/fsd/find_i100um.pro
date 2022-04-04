function find_i100um, ain, bin, modein
;+
; Used Schlegel/Finkbeiner/Davis 100um flux maps.
; see http://astron.berkeley.edu/dust/data/data.html 
;
; INPUTS
;    ain = RA or gal longitude
;    bin = dec or gal latitude
;    modein = 1 RA and dec in sexigesimal (see NOTES)
;             2 RA and dec in decimal
;             3 glong and glat is decimal
;
; OUTPUTS
;    i100um = flux density (MJy/ster) at 100 um
;
; NOTES
;    inputs may be scalars or arrays
;    if modein = 1, then the last index of the RA and dec arrays is
;       assumed to correspond to the HH, MM, SS direction; it need not
;       be 3 entries long.  For example, if 2 entries long, SS is assumed
;       to be 0 for all the entries.  
;       RA in HH, MM, SS; DEC in DEG, ARCMIN, ARCSEC
;    If you need to read a large amount of data from the FITS files, 
;       you should probably do it directly using dust_getval to minimize
;       the number of times the FITS file is loaded.
;    ***** You must define the DUST_DIR environment variable in your .cshrc
;       to point to the appropriate directory.  As of the writing of this 
;       routine, this directory is
;
;       /usr/local/rsi/idl/external/dust_map
;
; SG 2000/07/31
;-

I100um = !VALUES.F_INFINITY

if n_params() lt 3 then begin
   print
   print, $
'ERROR in FIND_I100UM: FIND_I100UM requires 3 arguments.'
   return, I100um
endif

a = ain
b = bin
mode = modein

sz_a = size(a,/dim)
sz_b = size(b,/dim)
if total( sz_a ne sz_b) gt 0 then begin
   print
   print, $
'ERROR in FIND_I100UM: a and b angle inputs must be the same size.'
   return, I100um
endif

if (mode lt 0 and mode gt 3) then begin
   print
   print, $
'ERROR in FIND_I100UM: mode input must 1, 2, or 3.'
   return, I100um
endif

if (mode eq 1) then begin
   ; convert to decimal
   a = smart_sixty(a)
   b = smart_sixty(b)
   ; convert a to degrees from hours
   a = a * 15
   ; convert to glong, glat
   euler, a, b, a, b, 1
endif
if (mode eq 2) then begin
   ; convert RA to degrees from hours
   a = a * 15
   ; convert to glong, glat
   euler, a, b, a, b, 1
endif

; and 100 um flux
; dust_getval requires 4096^2 maps
I100um = dust_getval(a, b, map = 'I100', /interp, /noloop)

; use this if you want lower res maps
;files = [ getenv('DUST_DIR') + '/maps/SFD_i100_1024_ngp.fits', $
;          getenv('DUST_DIR') + '/maps/SFD_i100_1024_sgp.fits']
;I100um = wcs_getval(files, glong, glat, /interp, /noloop)

return, I100um

end



