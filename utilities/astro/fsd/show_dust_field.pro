pro show_dust_field, alphain, decin, dalphain, ddecin, $
                     NHI, I100um, alpha_array, dec_array, $
                     nodisplay_flag = nodisplay_flag, $
                     ps_stub = ps_stub
;+
; plots the HI column density and 100 um DIRBE flux
; for a desired field
;
; HI from the Leiden/Dwingeloo survey for HI and 
; the Schlegel DIRBE dust maps for 100 um cirrus
;
; INPUTS:
;    alphain: Right Ascension.   RA must be in HH, HH MM, or 
;             HH MM SS (1, 2, or 3 element array)
;    decin: Declination.  Dec must be in DD, DD AM, or DD AM AS
;    dalphain: field width in RA, degrees
;    ddecin: field width in dec, degrees
;
; KEYWORDS:
;    nodisplay_flag: turns off display
;                    display is automatically turned on if making postscript
;    ps_stub: stub for postscript output file.  RA/dec and field size are
;             appended.  
;
; OUTPUTS:
;    NHI: grid containing the N_HI map in 1/cm^2
;    I100um: grid containing the 100 um flux in MJy/ster
;    alpha_array: RA array (in hours) for above grids
;    dec_array: dec array (in degrees) for above grids
;    to plot, do, for example:
;       contour(I100um,alpha_array,dec_array)
;
; SG 2000/08/01
;+

COMMON USER_COMMON

NHI = -999999.0
I100um = -999999.0
alpha_array = -999999.0
dec_array = -999999.0

if (n_params() lt 4) then begin
   print
   print, $
'ERROR in show_dust_field: 4 input parameters are required.'
   return
endif

alpha = alphain
dec = decin
dalpha = dalphain
ddec = ddecin

if (n_elements(alpha) eq 1) then alpha = [alpha, 0, 0]
if (n_elements(alpha) eq 2) then alpha = [alpha[0], alpha[1], 0]
if (n_elements(alpha) ne 3) then begin
   print
   print, $
'ERROR in show_dust_field: Input has incorrect length.  RA input must'
   print, $
'have between 1 and 3 elements (HH, HH MM, or HH MM SS).'
   return
endif

if (n_elements(dec) eq 1) then dec = [dec, 0, 0]
if (n_elements(dec) eq 2) then dec = [dec[0], dec[1], 0]
if (n_elements(dec) ne 3) then begin
   print
   print, $
'ERROR in show_dust_field: Input has incorrect length.  Dec input must'
   print, $
'have between 1 and 3 elements (DD, DD AM, or DD AM AS).'
   return
endif

; convert inputs to double
alpha = double(alpha)
dec = double(dec)
dalpha = double(dalpha)
ddec = double(ddec)

; convert alpha and dec to decimal (note that no flag is needed:
; 60 minutes in an hour, 60 arcminutes in a degree)
alpha = smart_sixty(alpha)
dec = smart_sixty(dec)

; convert RA field width from degrees to hours
dalpha = dalpha/15.0

; create arrays for creating maps
n_per_side = 100
alpha_array = findgen(n_per_side)*dalpha/n_per_side + (alpha - dalpha/2.0)
dec_array = findgen(n_per_side)*ddec/n_per_side + (dec - ddec/2.0)

; find_nhi and find_i100um can't handle 2D input arrays
; so we reform and reform again
alpha_grid = alpha_array # replicate(1.0, n_per_side)
dec_grid = replicate(1.0, n_per_side) # dec_array

alpha_grid = reform(alpha_grid,n_per_side^2)
dec_grid = reform(dec_grid,n_per_side^2)

NHI = find_nhi(alpha_grid, dec_grid, 2);
I100um = find_i100um(alpha_grid, dec_grid, 2);

NHI = reform(NHI, n_per_side, n_per_side)
I100um = reform(I100um, n_per_side, n_per_side)

; and reverse the horizontal axis so RA reads like on sky
NHI = reverse(NHI,1)
I100um = reverse(I100um,1)
alpha_array = reverse(alpha_array,1)
alpha_grid = reverse(alpha_grid,1)
; dec_grid: no need

;;;;
; make plots

RA_str = radec_str(alphain,1)
dec_str = radec_str(decin,2)
dRA_str = radec_str(smart_sixty(dalphain),2)
ddec_str = radec_str(smart_sixty(ddecin),2)
; drop the +/- at start and the arcsec
dRA_str = strmid(dRA_str,1,5)
ddec_str = strmid(ddec_str,1,5)
; strings we use
field_str = dRA_str + 'x' + ddec_str
RAdec_str = 'RA = ' + RA_str + ' ' + 'DEC = ' + DEC_str 

if keyword_set(nodisplay_flag) and not keyword_set(ps_stub) then return

if keyword_set(ps_stub) then begin
   ps_stub2 = ps_stub + RA_str + dec_str + '_' + field_str
endif

; window settings
!P.MULTI = [0, 1, 1];
!X.STYLE = 1
!Y.STYLE = 1

; get window parameters, resizing to match aspect ratio
aspect_ratio = ddec/(dalpha*15.0)
if not keyword_set(ps_stub) then begin
   get_window_size, 'x', aspect_ratio, $
                    xsize_this, ysize_this, xpos_this, ypos_this
endif else begin
   get_window_size, 'ps', aspect_ratio, $
                    xsize_this, ysize_this, xpos_this, ypos_this
endelse


; make plots
; (loop on the plots to prevent duplication of code)

for k = 1, 1 do begin

if (k eq 0) then begin
   ; NHI contours
   !P.TITLE = RAdec_str + '!C' + textoidl('n_{HI} [10^{20} cm^{-2}]')
   NHI_plot = NHI / 1e20
   level_max = alog10(max(NHI_plot))
   level_min = alog10(min(NHI_plot))
   level_arr = 10^( findgen(6)*(level_max-level_min)/5.0 + level_min)
   c_labels_arr = replicate(1, n_elements(level_arr))
   ps_suffix = '_NHI'
endif else begin
   ; set I100um contours: five contours, logarithmically spaced
   !P.TITLE = RAdec_str + '!C' + $
              textoidl('100 \mum surface brightness [MJy/ster]')
   level_max = alog10(max(I100um))
   level_min = alog10(min(I100um))
   level_arr = 10^( findgen(6)*(level_max-level_min)/5.0 + level_min)
   c_labels_arr = replicate(1, n_elements(level_arr))
   ps_suffix = '_I100um'
endelse

if not keyword_set(ps_stub) then begin
   window, free = 1, retain = 2, $
           xpos = xpos_this, ypos = ypos_this, $
           xsize = xsize_this, ysize = ysize_this
   ; do this to better mimic postscript
endif else begin
   ps_filename = ps_stub2 + ps_suffix + '.eps'
   set_plot, 'PS'
   ; this font size matches what you see on the screen better
   device, filename = ps_filename, /inches, $
           xoffset = xpos_this, yoffset = ypos_this, $
           xsize = xsize_this, ysize = ysize_this, $
           font_size = 10
endelse

; this bit is lame: the !D variables are in pixels (with 1000/cm for 
; postscript) but the device command wants values in centimeters (default)
; or inches (if /inches keyword is set)
if keyword_set(ps_stub) then begin
   xsize_this = xsize_this * 2.54 * 1000.0
   ysize_this = ysize_this * 2.54 * 1000.0
   xpos_this = xpos_this * 2.54 * 1000.0
   ypos_this = ypos_this * 2.54 * 1000.0
endif

; get correct size for figure and position of the axes in the figure
; (this stuff is specific to this routine -- how much space to leave 
; on each side)
xblank = !D.X_CH_SIZE * 12
yblank = !D.Y_CH_SIZE * 4
scalefacx = (double(xsize_this)-1.2*xblank)/double(xsize_this)
scalefacy = (double(ysize_this)-2*yblank)/double(ysize_this)
scalefac = min([scalefacx,scalefacy])
posn = [xblank, yblank, xblank+xsize_this*scalefac, yblank+ysize_this*scalefac]
xsize_new = xsize_this*scalefac + 1.2*xblank
ysize_new = ysize_this*scalefac + 2.0*yblank

; now, get the right offset for this window size and make a new window
if not keyword_set(ps_stub) then begin
   get_window_size, 'x', 0.0, xsize_new, ysize_new, xpos_new, ypos_new
   wdelete
   window, free = 1, retain = 2, $
           xpos = xpos_new, ypos = ypos_new, $
           xsize = xsize_new, ysize = ysize_new
endif else begin
   ; convert back to inches (need to do this for next iteration of loop)
   xsize_this = xsize_this/2.54/1000.0
   ysize_this = ysize_this/2.54/1000.0
   xpos_this = xpos_this/2.54/1000.0
   ypos_this = ypos_this/2.54/1000.0

   xsize_new = xsize_new/2.54/1000.0
   ysize_new = ysize_new/2.54/1000.0

   get_window_size, 'ps', 0.0, xsize_new, ysize_new, xpos_new, ypos_new
   device, /close_file
   device, filename = ps_filename, /inches, $
           xoffset = xpos_new, yoffset = ypos_new, $
           xsize = xsize_new, ysize = ysize_new
endelse

; finally, make the plot
if (k eq 0) then begin
   contour_radec, NHI_plot, alpha_array, dec_array, $
                  levels = level_arr, $
                  c_labels = c_labels_arr, $
                  /device, position = posn
endif else begin
   contour_radec, I100um, alpha_array, dec_array, $
                  levels = level_arr, $
                  c_labels = c_labels_arr, $
                  /device, position = posn
endelse

if keyword_set(ps_stub) then begin
   device, /close_file
   print, 'eps file written to ', ps_filename
   set_plot, 'x'
endif

endfor ; for k = 0,1


end


