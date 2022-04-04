;-------------------------------------------------------------
;+
; NAME:
;       PSHARD
; PURPOSE:
;       Produce a hardcopy of the active window on Postscript printer
; CATEGORY:
; CALLING SEQUENCE:
;       pshard [,printer, /box, /standard ]
; INPUTS:
;       printer = printer id, default taken from $PRINTER
;                 (remember quotes, e.g.: psinit,'lw1' !)
; KEYWORD PARAMETERS:
;       Keywords:
;         /BOX       define partial hardcopy
;         /STANDARD  no color transformation
; NOTES:
; MODIFICATION HISTORY:
;       Author: unknown
;       Adapted for use with psinit, psterm: Reinhold Kroll, 22/12/93
;
;---------------------------------------------------------------------

pro pshard,printer,box=box,standard=sta
on_error,2   ; return to caller

pid=getenv('PRINTER')
if pid eq '' then pid='lw'
if n_params() gt 0 then pid = printer

if keyword_set(box) then begin
      ; get image size and position from box_cursor procedure
   print,' left mouse button:move box , middle:resize , right:ready'
   box_cursor,x0,y0,xs,ys
   empty
endif else begin
   x0=0          ; default values for image size : whole current window
   y0=0
   xs=!d.x_size
   ys=!d.y_size
endelse
a = tvrd(x0,y0,xs,ys)		;Read image from current window
bpp=8                           ;normal bits_per_pixel value 
;check if image contains only the values 0 or 255
;  if this is true, a is transformed to "black lines on white ground"
ww=where(histogram(a) ne 0)
if n_elements(ww) eq 2 then begin
   bpp=1
   a=bytscl(a)
   ct=bytarr(256) & ct(0)=255
   a=ct(a)
   goto,output
endif
;
; no color table transformation if keyword parameter 'standard' is given
if not keyword_set(standard) then begin
   tvlct,v1,v2,v3,/get          ;get current color table
   color_convert,v1,v2,v3,h1,h2,h3,/rgb_hls
   ct=bytscl(h2)
   a=ct(a)                      ;transform data using normalized "light" values
endif
;
output:;
if min(a) eq max(a) then begin
   print,' I think You might not like this image (nothing will be printed)'
   return
endif

psinit,pid,/silent
tv,a
psterm

;
;dname=!d.name                              ;Save current device name
;set_plot, 'PS'                             ;new device PostScript
;spawn,/sh,'echo $USER',username            ;get username
;psfile='/var/tmp/' + username + '_idl.ps'  ;construct filename
;psfile=psfile(0)
;device,filename=psfile
;device,bits_per_pixel=bpp
;tv,a                                       ;output to postScript
;device, /close
;spawn,/sh,'lpr -Plw2 ' + psfile              ;send to printer
;spawn,/sh,'rm ' + psfile                   ;remove file
;set_plot, dname                            ;return to previous device
return
end
