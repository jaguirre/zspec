;+
; NAME:
;       PSFONTS
; PURPOSE:
;       Print a listing showing an example of each IDL postscript font.
; CATEGORY:
; CALLING SEQUENCE:
;       psfonts, [printer]
; INPUTS:
;       printer = printer id to use in call to psinit 
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 29 Aug, 1989
;       Adaption for IAC printers, Reinhold Kroll, 22/12/93
;-
 
	pro psfonts, printer, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Print a listing showing an example of each IDL postscript font.'
	  print,' psfonts, [printer]'
	  print,'   printer = printer  id to use in call to psinit
	  return
	endif
 
        pid=getenv('PRINTER')
        if pid eq '' then pid='lw'
        if n_params() gt 0 then pid = printer
 
	font = strarr(35)
	font(0) = '/COURIER'
	font(1) = '/COURIER,/BOLD'
	font(2) = '/COURIER,/OBLIQUE'
	font(3) = '/COURIER,/BOLD,/OBLIQUE'
	font(4) = '/HELVETICA'
	font(5) = '/HELVETICA,/BOLD'
	font(6) = '/HELVETICA,/OBLIQUE'
	font(7) = '/HELVETICA,/BOLD,/OBLIQUE'
	font(8) = '/HELVETICA,/NARROW'
	font(9) = '/HELVETICA,/NARROW,/BOLD'
	font(10) = '/HELVETICA,/NARROW,/OBLIQUE'
	font(11) = '/HELVETICA,/NARROW,/BOLD,/OBLIQUE'
	font(12) = '/AVANTGARDE,/BOOK'
	font(13) = '/AVANTGARDE,/BOOK,/OBLIQUE'
	font(14) = '/AVANTGARDE,/DEMI'
	font(15) = '/AVANTGARDE,/DEMI,/OBLIQUE'
	font(16) = '/BKMAN,/DEMI'
	font(17) = '/BKMAN,/DEMI,/ITALIC'
	font(18) = '/BKMAN,/LIGHT'
	font(19) = '/BKMAN,/LIGHT,/ITALIC'
	font(20) = '/ZAPFCHANCERY,/MEDIUM,/ITALIC'
	font(21) = '/ZAPFDINGBATS'
	font(22) = '/SCHOOLBOOK'
	font(23) = '/SCHOOLBOOK,/BOLD'
	font(24) = '/SCHOOLBOOK,/ITALIC'
	font(25) = '/SCHOOLBOOK,/BOLD,/ITALIC'
	font(26) = '/PALATINO'
	font(27) = '/PALATINO,/BOLD'
	font(28) = '/PALATINO,/ITALIC'
	font(29) = '/PALATINO,/BOLD,/ITALIC'
	font(30) = '/SYMBOL'
	font(31) = '/TIMES'
	font(32) = '/TIMES,/BOLD'
	font(33) = '/TIMES,/ITALIC'
	font(34) = '/TIMES,/BOLD,/ITALIC'
 
	l = 34 
 
	txt = '  This line of text is printed in the indicated font.  0123456789'
	
	psinit, pid, /full, margin=.25
 
	sz = .75
 
	xyouts, 0, .98, 'IDL postscript fonts.  After PSINIT do DEVICE,xxx where xxx is one of the following fonts:', /normal,size=sz
 
	x = 0 & y = .926 & dy = .024
	for i = 0, l do begin
	  print, font(i)
	  xyouts, x, y, font(i), /normal,size=sz
	  y = y - dy
	endfor
 
	x = 0.34 & y = .926
	for i = 0, l do begin
	  ii = execute('device,'+font(i))
	  print, font(i)
	  xyouts, x, y, txt, /normal, size=sz
	  y = y - dy
	endfor
 
	psterm
 
	return
	end
