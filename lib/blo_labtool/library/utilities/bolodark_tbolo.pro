;+
;===========================================================================
;  NAME: 
;		  bolodark_tbolo
; 
;  DESCRIPTION:   
;		  Derive actual bolometer temperature
;
;  USAGE: 
;		  bolodark_tbolo, Rmin, R_star, T_star 
;
;  INPUT:	  
;     R           (float array) resistance at minimum power  
;     R_star      (float) bolometer voltage		     
;     T_star      (float) bias voltage			     
;
;  OUTPUT:
;     T	  	  (float array) temperature of bolometer     
;
;  KEYWORD: 
;		  none
;
;  AUTHOR: 
;		  Bernhard Schulz
;	
; 
;  Edition History:
;
;  Date    	Programmer   Remarks
; ---------- ----------      --------------------
; 2003-05-12 	B. Schulz    initial test version
;
;===========================================================================
;-

function bolodark_tbolo, R, R_star, T_star


T = T_star / (alog(R / R_star))^2


return, T
end
