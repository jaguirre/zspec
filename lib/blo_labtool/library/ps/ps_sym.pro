;+
; NAME:
;       PS_SYM
; PURPOSE:
;       Print a table showing characters to use for the IDL fonts /zapfdingbats and /symbol.
; CATEGORY:
; CALLING SEQUENCE:
;       ps_sym
; INPUTS:
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Note: the fonts zapfdingbats and symbol are listed 
;         along with the ascii character used to obtain them. 
; MODIFICATION HISTORY:
;       R. Sterner, 29 Aug, 1989.
;-
 
	pro ps_sym, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Print a table showing characters to use for the IDL fonts /zapfdingbats and /symbol.'
	  print,' ps_sym
	  print,' No args.'
	  print,' Note: the fonts zapfdingbats and symbol are listed'
	  print,'   along with the ascii character used to obtain them.'
	  return
	endif
 
	psinit, /full, mar=.25
 
	mx = 12 
	fx = float(mx-1)/.9
	fy = ((126-33)/mx)/.2
 
;-------  ZAPFDINGBATS font conversion table  -------
	xyouts, 0, .85, 'IDL postscript font ITC Zapf Dingbats.  Do DEVICE,/ZAPFDINGDBATS', /normal
 
	for i = 33, 126 do begin
	  x = (i-33) mod mx
	  y = (i-33)/mx
	  xx = x/fx + .025 
	  yy = y/fy + .6 
	  xyouts, xx, yy, string(byte(i)), /normal
	endfor
 
	device, /ZAPFDINGBATS
	for i = 33, 126 do begin
	  x = (i-33) mod mx
	  y = (i-33)/mx
	  xx = x/fx 
	  yy = y/fy + .6 
	  xyouts, xx, yy, string(byte(i)), /normal
	endfor
 
	device, /times
 
;-------  SYMBOL font conversion table  -------
	xyouts, 0, .45, 'IDL postscript font Symbol.  Do DEVICE,/SYMBOL', /normal
 
	for i = 33, 126 do begin
	  x = (i-33) mod mx
	  y = (i-33)/mx
	  xx = x/fx + .025 
	  yy = y/fy + .2 
	  xyouts, xx, yy, string(byte(i)), /normal
	endfor
 
	device, /SYMBOL
	for i = 33, 126 do begin
	  x = (i-33) mod mx
	  y = (i-33)/mx
	  xx = x/fx 
	  yy = y/fy + .2 
	  xyouts, xx, yy, string(byte(i)), /normal
	endfor
 
	device, /times
 
	psterm
 
	return
	end
