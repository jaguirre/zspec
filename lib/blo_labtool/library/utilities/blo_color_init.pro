;+
;===========================================================================
; NAME: 
;		 blo_color_init
; 
; DESCRIPTION: 
;		 Initialize 24 bit colortable
;
; USAGE: 
;		 blo_color_init 
;
; INPUT: 
;		 none	
;	
; OUTPUT: 
;		 none	
;
;
; AUTHOR: 
;		 Bernhard Schulz (IPAC)
; 
; Edition History:
;
; Date    	Programmer   Remarks
; ---------- 	----------   -------
; 2002-10-11 	B. Schulz    initial version
;
;===========================================================================
;-

pro blo_color_init


if !d.n_colors LT 16777216 then begin

  colorname = ['BLACK',   $
               'BEIGE',   $
               'AQUA',    $
               'BLUE',    $
               'CYAN',    $
               'GOLD',    $
               'GRAY',    $
               'GREEN',   $
               'MAGENTA', $
               'NAVY',    $
               'ORCHID',  $
               'PINK',    $
               'RED',     $
               'SKY',     $
               'YELLOW',  $
               'WHITE']

  if !d.n_colors GT n_elements(colorname) then $
       ncolors = !d.n_colors $
  else $
       ncolors = n_elements(colorname)

  colorcode = lonarr(ncolors)

  for i= 0, n_elements(colorname)-1 do begin
    colorcode(i) = blo_color_get(colorname(i), /code)
  endfor

  graybeg = n_elements(colorname)
  ngray = ncolors-graybeg
  for i=0, ngray-1 do begin
    graycode = long(byte(float(i) / (ngray-1.) * 255.))
    colorcode(graybeg+i) = graycode + ishft(graycode, 8)+ ishft(graycode, 16)
  endfor

  R0 = colorcode AND '0000FF'x
  G0 = ishft(colorcode AND '00FF00'x, -8)
  B0 = ishft(colorcode AND 'FF0000'x, -16)

  tvlct, r0, g0, b0
endif

end
