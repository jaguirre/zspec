;+
;===========================================================================
;  NAME: 
;		  get_13colortable
; 
;  DESCRIPTION: 
;		  Get the color names
;
;  USAGE: 
;		  colors = get_13colortable( ) 
;
;  INPUT: 
;		  none
;  
;  OUTPUT: 
;		  String array contains the 13 colors
;
;  KEYWORDS: 
;		  none
;
;  AUTHOR: 
;		  B. SCHULZ
;
;  EDITION HISTORY
;  
;  Date		Programmer	Remarks
;===========================================================================
;-
 
function get_13colortable 

return, ['NAVY', 'BLUE', 'GREEN', 'MAGENTA', $
	'RED', 'ORCHID', 'CYAN', 'SKY', $
        'BEIGE', 'PINK', 'GRAY', 'GOLD', 'AQUA']

end
