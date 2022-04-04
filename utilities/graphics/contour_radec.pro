pro contour_radec, data, alpha_array, dec_array, _EXTRA = extra
;+
; NAME: 
;       CONTOUR_RADEC
; PURPOSE:
;       Make a contour plot with astronomical coords for a data array
;       already aligned with RA and dec axes.
; EXPLANATION:
;       Given a data array and corresponding RA and dec arrays (the same
;       inputs that would be give to the contour command), does the 
;       necessary overhead to use imcontour, which actually does the
;       plotting and axis labelling.
;
; CALLING SEQUENCE:
;       CONTOUR_RADEC, data, alpha_array, dec_array, [_EXTRA = ]
;
; INPUTS:
;       data - data to be contour plotted; RA corresponds to first index,
;              dec to second index
;       alpha_array - RA array for data, in decimal hours
;       dec_array - declination array, in decimal degrees
;       
;       NOTE: the routine will plot the data in the orientation specified
;             by alpha_array.  If alpha_array is in decreasing order,
;             then the RA is plotted in decreasing order, as on the sky.
;             The user should, of course, make sure data and alpha_array
;             are properly aligned (i.e., data[0,0] corresponds to
;             alpha_array[0] and dec_array[0]).  There's no reason to 
;             plot the data backward in dec, but this routine will do it
;             if that's what the inputs imply.
;
; OPTIONAL KEYWORDS:
;       All keywords accepted by CONTOUR and IMCONTOUR are accepted via 
;       the _EXTRA utility.  If not specified, the following defaults are
;       assumed:
;       XTITLE - 'RA (J2000)'
;       YTITLE - 'DEC (J2000)'
;       SUBTITLE - ' '
;
; NOTES:
;       See IMCONTOUR for details.
;
; PROCEDURES USED:
;       IMCONTOUR
;
; REVISION HISTORY:
;       2000/08/27 SG
;       2003/12/06 SG Was giving dx to putast in coordinate units,
;                     not physical units.  Fixed.
;       3004/07/06 SG PUTAST calling syntax modified, adapt.
;-

if n_params() lt 3 then begin
   message, 'Three inputs are required.'
   return
endif 

if not keyword_set(xtitle) then xtitle = 'RA (J2000)'
if not keyword_set(ytitle) then ytitle = 'DEC (J2000)'
if not keyword_set(subtitle) then subtitle = ' '

dalpha = alpha_array[1] - alpha_array[0]
ddec = dec_array[1] - dec_array[0]

; create FITS structure so we can use imcontour
fxhmake, hdr, data, /initialize
; create astrometry structure for FITS
;      .CDELT - 2 element vector giving physical increment at reference pixel
;      .CRPIX - 2 element vector giving X and Y coordinates of reference pixel
;               (def = NAXIS/2) in FITS convention (first pixel is 1,1)
;      .CRVAL - 2 element double precision vector giving R.A. and DEC of
;             reference pixel in DEGREES
;      .CTYPE - 2 element string vector giving projection types, default
;             ['RA---TAN','DEC--TAN']
;         (the 'TAN' indicates tangential projection: sky projected onto
;          plane)
;      .LONGPOLE - scalar longitude of north pole (default = 180)
;      .PROJP1 - Scalar parameter needed in some projections
;      .PROJP2 - Scalar parameter needed in some projections
; not sure what .projp1 and .projp2 are, just set them to 1.0
putast, hdr, [ [dalpha*15.0*cos(median(dec_array)*!DTOR),  0.0], $
               [0.0,         ddec] ], $
               [1,1], $
               [alpha_array[0]*15.0, dec_array[0]], $
               ['RA---TAN','DEC--TAN'], $
               equinox = 2000.0, cd_type = 2

; and plot it
imcontour, data, hdr, /type, xtitle = xtitle, ytitle = ytitle, $
           subtitle = subtitle, _extra = extra

end


