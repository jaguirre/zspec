;+
;===========================================================================
;  NAME: 
;		 get_16colortable
; 
;  DESCRIPTION: 
;		 Get the color names
;
;  USAGE: 
;		 colors = get_16colortable( ) 
;
;  INPUT: 
;		 none
;  
;  OUTPUT: 
;		 String array contains the 16` colors
;
;  KEYWORDS: 
;		 none
;
;  AUTHOR: 
;		 B. SCHULZ
;
;  EDITION HISTORY
;  
;  Date		Programmer	Remarks
;===========================================================================
;-

function get_16colortable 

return, ['NAVY', 'BLUE', 'GREEN', 'MAGENTA', $
	'RED', 'ORCHID', 'CYAN', 'SKY', $
        'BEIGE', 'PINK', 'GRAY', 'GOLD', 'AQUA']

end
