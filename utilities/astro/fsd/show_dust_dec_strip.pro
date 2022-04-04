function show_dust_dec_strip, alphain, ps_stub = ps_stub
;+
; plots the HI column density and 100 um DIRBE flux
; as a function of declination for a given
; value of RA using the Leiden/Dwingeloo survey for HI and 
; the Schlegel DIRBE dust maps for 100 um cirrus
;
; INPUTS:
;    alphain: Right Ascension.   RA must be in HH, HH MM, or 
;             HH MM SS (1, 2, or 3 element array)
;
; KEYWORDS:
;    ps_stub: stub for postscript output file.  RA is appended.
;             If not set, displays to screen.
; 
;
; SG 2000/08/01
;+

COMMON USER_COMMON

alpha = alphain

if (n_elements(alpha) eq 1) then alpha = [alpha, 0, 0]

if (n_elements(alpha) eq 2) then alpha = [alpha[0], alpha[1], 0]

if (n_elements(alpha) ne 3) then begin
   print
   print, $
'ERROR in show_dust_dec_strip: Input has incorrect length.  RA input must'
   print, $
'have between 1 and 3 elements (HH, HH MM, or HH MM SS).'
   return, 0
endif

n_dec_val = 181
dec = findgen(n_dec_val) - 90
dec = dec # [1, 1, 1]
dec[*,1:2] = 0.0
xrange = [min(dec), max(dec)]
alpha = replicate(1.0,n_dec_val) # alpha

NHI = find_nhi(alpha, dec, 1);
I100um = find_i100um(alpha, dec, 1);

window, free = 1, retain = 2, $
        xpos = IDL_WIN.XPOS, ypos = IDL_WIN.YPOS, $
        xsize = IDL_WIN.XSIZE, ysize = IDL_WIN.YSIZE

RA_str = string(format = '((I2.2),"h",(I2.2),"m",(F5.2),"s")', $
                alphain[0], alphain[1], alphain[2])

!P.MULTI = [0, 1, 2];
!P.TITLE = 'RA = ' + RA_str
!X.TITLE = 'declination [degrees]'
!Y.TITLE = 'N_HI [/cm^2]'
plot, dec, NHI, xrange = xrange, /ylog

!P.TITLE = ''
!X.TITLE = 'declination [degrees]'
!Y.TITLE = 'DIRBE 100 um surface brightness [MJy/ster]'
plot, dec, I100um, xrange = xrange, /ylog

if keyword_set(ps_stub) then begin
   pageInfo = pswindow()
   set_plot, 'PS'
   ps_filename = ps_stub + RA_str + '.eps'
   device, _Extra = pageInfo, filename = ps_filename

   !P.TITLE = RA_str
   !X.TITLE = 'declination [degrees]'
   !Y.TITLE = 'N_HI [/cm^2]'
   plot, dec, NHI, xrange = xrange, /ylog

   !P.TITLE = ''
   !X.TITLE = 'declination [degrees]'
   !Y.TITLE = 'DIRBE 100 um surface brightness [MJy/ster]'
   plot, dec, I100um, xrange = xrange, /ylog

   device, /close_file
endif

set_plot, 'X'

return, 1

end



