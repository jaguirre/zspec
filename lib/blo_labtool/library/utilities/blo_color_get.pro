;+
;===========================================================================
;  NAME: 
;		   blo_color_get
;  
;  DESCRIPTION: 
;		   Provide Code for 24 bit colors
;
;  USAGE: 
;		   x = blo_color_get(colorstring) 
;
;  INPUT: 	
;    colorstring   (string) ar strarray of names of colors
;
;  OUTPUT:	
;    function	   colorcode (long) or lonarr of colorcodes
;
;  KEYWORDS:
;    code	   if set function returns (long) RGB colorcode instead
;		   of integer number
;
;  AUTHOR: 
;		   Bernhard Schulz (IPAC)
; 
;  Edition History:
;
;  Date   	Programmer  Remarks
;  ----------   ----------  -------
;  2002-08-08 	B. Schulz   initial version
;  2002-10-11 	B. Schulz   version for blo_labtools
;
;===========================================================================
;-

function blo_color_get, colorstring, code=code

colorcode = ['000000'x, $
             '7FABFF'x, $
             '93DB70'x, $
             'FF0000'x, $
             'FFFF00'x, $
             '00BBFF'x, $
             '7F7F7F'x, $
             '00FF00'x, $
             'FF00FF'x, $
             '730000'x, $
             'DB70DB'x, $
             '7F7FFF'x, $
             '0000FF'x, $
             'FFA500'x, $
             '00FFFF'x, $
             'FFFFFF'x]

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

noutp = n_elements(colorstring)
outp = lonarr(noutp)

if noutp EQ 1 then colorstring = [colorstring]

for i=0, noutp-1 do begin
  ix = where(colorname EQ strupcase(colorstring(i)))
  if ix(0) GE 0 then begin
    if keyword_set(code) OR $
             !d.n_colors GE 16777216 then $
                              outp(i) = colorcode(ix) $
    else 					outp(i) = ix
  endif else outp(i) = -1
endfor

if noutp EQ 1 then return, outp(0)

return, outp

end
