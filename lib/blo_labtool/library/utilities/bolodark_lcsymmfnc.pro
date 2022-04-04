;+
;=========================================================
; NAME: 
;		   bolodark_lcsymmfnc
;
; DESCRIPTION: 
;		   function for amoeba iteration
; 
; INPUT:
;		   none
;
; OUTPUT:	   
;	obias      double precision array 
;
; KEYWORDS:
;		   none
;
; AUTHOR:
;		   Bernhard Schulz
;
;========================================================= 
;_

function bolodark_lcsymmfnc, obias

common lcsymm, ubias0, ubolo0

a = bolodark_lcsymm(ubias0, ubolo0, obias)

return, a^2

end
