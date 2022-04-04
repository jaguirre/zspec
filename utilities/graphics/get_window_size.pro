pro get_window_size, device_type, aspect_ratio, xsize, ysize, xpos, ypos
;+
; NAME:
;    GET_WINDOW_SIZE
;
; PURPOSE:
;    Given an aspect ratio, returns window positioning and size parameters
;    that match the desired aspect ratio, are as close as possible to the
;    user's default window settings (i.e., try to match user's standard
;    xsize or ysize), and fit within the screen.
;
; CALLING SEQUENCE:
;    get_window_size, device_type, aspect_ratio, xsize, ysize, xpos, ypos
;
; INPUTS:
;    device_type - which device is being used (e.g., 'x', 'ps')
;    aspect_ratio - desired aspect ratio (dy/dx)
;    if aspect_ratio = 0, then, for a window of size xsize and ysize, 
;    returns xpos and ypos to reposition the window according to 
;    POSNTYPE field of IDL_WIN.
;
; OUTPUTS:
;    xsize, ysize, xpos, ypos - outputs to be used for keywords in 
;       WINDOW or DEVICE command.  
;       xsize, ysize - width of plot window
;       xpos, ypos - corner of plot window (which one depends on device)
;
; NOTES:
;    ASSUMES THE EXISTENCE OF THE COMMON BLOCK USER_COMMON, containing 
;    the variable IDL_WIN.  IDL_WIN has a substructure for each device
;    type of interest (e.g., IDL_WIN.X, IDL_WIN.PS, etc.) and each
;    device field contains a structure containing the fields
;    XPOS, YPOS, XSIZE, YSIZE, XBORDER, YBORDER, UNITS
;    with XPOS, YPOS, XSIZE, and YSIZE as defined above, XBORDER and 
;    YBORDER begin twice the thickness of the window border (0 for PS)
;    an UNITS being the units that all the dimensions are expressed in
;    (e.g., 'PIXELS', 'INCHES', 'CENTIMETERS')
;
; REVISION HISTORY:
;        2000/08/28 SG
;-

COMMON USER_COMMON

; uppercase device_type
device_type = strupcase(device_type)

; get list of tag names
tnames = tag_names(IDL_WIN)
ntags = n_elements(tnames)

; see if device_type matches any of these
keepgoing = 1
k = -1
while keepgoing do begin
   k = k + 1
   keepgoing = (not (device_type eq tnames[k])) and (k lt ntags-1)
endwhile
if (not (device_type eq tnames[k])) then begin
   message, 'IDL_WIN has no fields matching device type.'
   message, 'device = ' + device_type
   message, 'IDL_WIN list of fields:'
   message, tnames
   return
endif

IDL_WIN_THIS = IDL_WIN.(k)

if (device_type eq 'X') then begin
   scr_size = get_screen_size()
   xscr_size = scr_size[0] - IDL_WIN_THIS.XBORDER
   yscr_size = scr_size[1] - IDL_WIN_THIS.YBORDER
endif else if (device_type eq 'PS') then begin
   xscr_size = 8.0 - IDL_WIN_THIS.XBORDER
   yscr_size = 10.5 - IDL_WIN_THIS.YBORDER
endif

if (aspect_ratio gt 0.0) then begin
   if (aspect_ratio lt 1.0) then begin
      ysize = IDL_WIN_THIS.YSIZE
      xsize = IDL_WIN_THIS.YSIZE / aspect_ratio
   endif else begin
      xsize = IDL_WIN_THIS.XSIZE
      ysize = IDL_WIN_THIS.XSIZE * aspect_ratio
   endelse

   if (xsize gt xscr_size) then begin
      ysize = ysize * xscr_size/xsize
      xsize = xscr_size
   endif

   if (ysize gt yscr_size) then begin
      xsize = xsize * yscr_size/ysize
      ysize = yscr_size
   endif
endif

; fill in the possibilities as they arise -- note that different
; device types have different rules for where the origin is and which
; way the axes increase
if (device_type eq 'X') then begin
   if (IDL_WIN_THIS.POSNTYPE eq 1) then begin
      ; lower left
      xpos = IDL_WIN_THIS.XPOS * xsize / IDL_WIN_THIS.XSIZE
      ypos = IDL_WIN_THIS.YPOS + IDL_WIN_THIS.YSIZE - ysize
   endif
endif else if (device_type eq 'PS') then begin
   if (IDL_WIN_THIS.POSNTYPE eq 0) then begin
      ; center
      xpos = (xscr_size - xsize)/2.0
      ypos = (yscr_size - ysize)/2.0
   endif
endif

end
