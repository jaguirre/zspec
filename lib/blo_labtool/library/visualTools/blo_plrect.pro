;+
;===========================================================================
;  NAME: 
;		  blo_plrect
;
;  DESCRIPTION: 
;		  Overplot rectangle
;
;  INPUT: 
;     x        	  x 2-el.-Vector     
;     y       	  y 2-el.-Vector     
;
;  KEYWORDS:
;     linestyle   same as for plot   
;     color	  same as for plot   
;
;  AUTHOR: 
;		  B. Schulz
;===========================================================================
;-

pro blo_plrect, x, y, ctrl, color=color, linestyle=linestyle

wset, (*ctrl).wdraw
oplot, x, [y(0),y(0)], color=color, linestyle=linestyle
oplot, [x(1),x(1)], y, color=color, linestyle=linestyle
oplot, x, [y(1),y(1)], color=color, linestyle=linestyle
oplot, [x(0),x(0)], y, color=color, linestyle=linestyle

end


