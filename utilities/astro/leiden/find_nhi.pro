function find_nhi, ain, bin, modein
;+
; uses the Leiden/Dwingeloo HI survey to find NHI
; data are in file total_hi.fit, obtained from VizieR:
; ftp://cdsarc.u-strasbg.fr/pub/cats/VIII/54/fits/total_hi.fit
;
; data are in K km/s; FITS file header says to multiply by
; 1.8224e18 K km s^-1 cm^2 to convert to NHI
;
; INPUTS
;    ain = RA or gal longitude
;    bin = dec or gal latitude
;    modein = 1 RA and dec in sexigesimal (see NOTES)
;             2 RA and dec in decimal
;             3 glong and glat is decimal
;
; OUTPUTS
;    NHI = column density of HI in cm^-2
;
; NOTES
;    inputs may be scalars or arrays
;    if modein = 1, then the last index of the RA and dec arrays is
;       assumed to correspond to the HH, MM, SS direction; it need not
;       be 3 entries long.  For example, if 2 entries long, SS is assumed
;       to be 0 for all the entries.  
;       RA in HH, MM, SS; DEC in DEG, ARCMIN, ARCSEC
;
; SG 2000/07/31
;-

COMMON USER_COMMON
COMMON LEIDENHI, total_HI

NHI = !VALUES.F_INFINITY

if n_params() lt 3 then begin
   print
   print, $
'ERROR in FIND_NHI: FIND_NHI requires 3 arguments.'
   return, NHI
endif

a = ain
b = bin
mode = modein

if (n_elements(total_HI) eq 0) then begin
   ; load the fits file
   file = IDL_USER_PATH + IDL_FILESEP + 'astro_local' + IDL_FILESEP + $
          'LeidenHI' + IDL_FILESEP + 'total_hi.fit'
   print, file
   rdfits_struct, file, total_HI, /silent
endif

sz_a = size(a,/dim)
sz_b = size(b,/dim)
if total( sz_a ne sz_b) gt 0 then begin
   print
   print, $
'ERROR in FIND_NHI: a and b angle inputs must be the same size.'
   return, NHI
endif

if (mode lt 0 and mode gt 3) then begin
   print
   print, $
'ERROR in FIND_NHI: mode input must 1, 2, or 3.'
   return, NHI
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

; construct arrays for the axes
; first index is gal longitude
; second is gal latitude
l_index = 721 - (360.0 - a)/0.5
b_index = (b + 90.0)/0.5 

v = interpolate(total_HI.im0, l_index, b_index)

NHI = v * 1.8224e18

return, NHI

end
	
