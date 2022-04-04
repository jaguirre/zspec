;-------------------------------------------------------------
;+
; NAME:
;       PSINIT
; PURPOSE:
;       Redirect plots and images to postscript printer
; CATEGORY:
; CALLING SEQUENCE:
;       psinit [,printer]
; INPUTS:
;       printer = printer id, default taken from $PRINTER
;                 (remember quotes, e.g.: psinit,'lw1' !)
; KEYWORD PARAMETERS:
;       Keywords: 
;         /FULL to use full page in portrait mode (def=top half). 
;         /LANDSCAPE to do plot in landscape mode. 
;         MARGIN = [left, right, bottom, top] sets margins (in inches). 
;         /SILENT  suppress messages
;        /CENTIMETERS causes margin to be interpreted as cm. 
;        /DOUBLE to do plot in double thickness. 
;        /VECTOR to use vector fonts instead of postscript fonts. 
;        /ORIGIN plots a mark at the page origin. 
;        /COLOR  produce color postscript output
;        /ENCAPSULATED produce encapsulated postscript
; OUTPUTS:
; COMMON BLOCKS:
;       ps_com
; NOTES:
;         Default is portrait mode, top half of page. 
;       GERMAN DIN A4 PAPER:
;       Note: may give as few values as needed.  For left margin only 
;       may just use MAR=xxx. Must give an array for more than one value. 
;       Notes: 
;         Related routines: 
;         psterm - terminate postscript output and make plots. 
;         pspaper - plot normalized coordinate system for selected page mode. 
; MODIFICATION HISTORY:
;       R. Sterner, 2 Aug, 1989.
;       IAAW, 1991 - Adapted for Inst. of Astron. & Astrophys. Wuerzburg
;       Reinhold Kroll 22.Dec.1993 - Adaption for IAC.
;       R. Kroll, 16.08.94: added color PS support
;       R. Kroll,  5.04.95: added keyword ENCAPSULATED
;       B. Schulz, 4.11.02: added keyword LETTER
;-
;-------------------------------------------------------------
 
	pro psinit, printer, landscape=v, double=dbl, full=fl, help=hlp, $
	            vector=d3, origin=ori, margin=mar, centimeters=cm, $
		    silent=silent,color=color,encapsulated=encaps, letter=let
 
	common ps_com, dname,xthick, ythick, pthick, pfont, pid, psfile

        on_error,2
 
	if keyword_set(hlp) then begin
	  print,' Redirect plots and images to postscript printer'
	  print,' psinit [,printer
	  print,'   printer = Printer id, (default taken from $PRINTER'	
	  print,' Keywords:'
 	  print,'   /FULL to use full page in portrait mode (def=top half).'
 	  print,'   /LETTER to use full letter format page in portrait mode (def=top half).'
	  print,'   /LANDSCAPE to do plot in landscape mode.'
 	  print,'   MARGIN = [left, right, bottom, top] sets margins (in inches).'
	  print,'     Note: may give as few values as needed.  For left margin only'
	  print,'     may just use MAR=xxx. Must give an array for more than one value.'
 	  print,'   /CENTIMETERS causes margin to be interpreted as cm.'
	  print,'   /DOUBLE to do plot in double thickness.'
 	  print,'   /VECTOR to use vector fonts instead of postscript fonts.'
 	  print,'   /ORIGIN plots a mark at the page origin.'
 	  print,'   /COLOR enables colors.'
 	  print,'   /SILENT suppresses messages.'
	  print,' Notes:'
	  print,'   Default is portrait mode, top half of page.'
	  print,'   Related routines:'
	  print,'   psterm - terminate postscript output and make plots.'
	  print,'   pspaper - plot normalized coordinate system for selected page mode.'
	  print,'   pshard - to make a hardcopy.'
	  return
	endif	
 
        pid=getenv('PRINTER')
        if pid eq '' then pid='lw'
	if n_params() gt 0 then pid = printer
 
	dname = !d.name		; Save current setup.
	xthick = !x.thick
	ythick = !y.thick
	pthick = !p.thick
	pfont = !p.font
 
	if n_elements(mar) eq 0 then mar=[0,0,0,0]	; Process optional page margins.
	if keyword_set(cm) then mar = mar/2.54
	mar = [mar,0,0,0]		; Allow for any number of values.
	dx1 = mar(0) & dx2 = dx1+mar(1) & dy1 = mar(2) & dy2 = dy1+mar(3)
 
	set_plot, 'ps'
        spawn,/sh,'echo $USER"$$"',username           ;get username
        psfile = '/var/tmp/' + username + '_idl.ps'   ;construct filename
        psfile=psfile(0)
        device, filename = psfile

	if not keyword_set(silent) then begin
	print,' All plots are now redirected to the postscript printer ' + strtrim(pid,2) + '.'
	print,' To output plots and reset to screen do PSTERM.'
	endif 

	phight = 10.0
	if keyword_set(let) then phight = 9.0
     pwidth = 7.0
	
	if keyword_set(v) then begin		; Handle viewgraph.
	  device, /landscape, /inches, xoffset=.65+dy1, yoffset=10.8-dx1, xsize=phight-dx2, ysize=pwidth-dy2
	  if not keyword_set(silent) then print,' Landscape mode.'
	endif else begin
	  if keyword_set(fl) then begin		; Handle top.
	    device, /portrait, /inches, xoffset=0.6+dx1, yoffset=1.0+dy1, xsize=pwidth-dx2, ysize=phight-dy2
	    if not keyword_set(silent) then print,' Portrait mode, full page.'
	  endif else begin
	      device, /portrait, /inches, xoffset=0.6+dx1, yoffset=phight-4.5+dy1, xsize=pwidth-dx2, ysize=5.0-dy2
              if not keyword_set(silent) then print,' Portrait mode, top half page.'
       endelse
	endelse
 
	device, bits_per_pixel = 8	; Default is 32 gray levels (max for apple laser writers.
;
        cmode=0
	if keyword_set(color) then cmode=1
	if pid eq 'pscolor1' then cmode=1
	if pid eq 'psc1' then cmode=1
        if pid eq 'PostScript Color' then cmode=1

	if cmode eq 1 then begin
	device,/color
        if not keyword_set(silent) then print,' Color mode'
	endif

	!p.font = 0
	device, /times			; Default font is times.
 
	if keyword_set(dbl) then begin		; Handle double thickness.
	  !x.thick = 2
	  !y.thick = 2
	  !p.thick = 2
	  device, /bold
	  if not keyword_set(silent) then print,' Double thickness mode.'
	endif
 
	if keyword_set(d3) then begin
	  !p.font = -1
	  if not keyword_set(silent) then print,' Using vector font.'
	endif
 
	if keyword_set(ori) then begin
	  if not keyword_set(silent) then print,' Marking origin.'
	  plots, [0,0], [0,0], /normal, psym=1
	endif 
 
	if keyword_set(encaps) then begin
          device,/encapsulated
          if not keyword_set(silent) then print,' Ecapsulated Postscript'
        endif

	return
	end
