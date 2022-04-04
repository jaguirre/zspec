;+
;=========================================================================
;  NAME: 
;		  blo_zoomin
;
;  DESCRIPTION:   
;		  Zoom into rectangle
;
;  INPUT: 
;	x	  x 2-el.-Vector
;       y	  y 2-el.-Vector
;	ctrl	  control data structure
;
;  OUTPUT: 
;		  none
;
;  KEYWORDS: 
;		  none
;
;  AUTHOR: 
;		  B. Schulz
;=========================================================================
;-

pro blo_zoomin, x, y, ctrl

(*ctrl).xmin = x(0)
(*ctrl).xmax = x(1)
(*ctrl).ymin = y(0)
(*ctrl).ymax = y(1)

END
