;+
;===========================================================================
;  NAME: 
;		   bolodark_ibias
;
;  DESCRIPTION: 
;		   Derive bias current
;
;  USAGE: 
;		   bolodark_ibias, ubolo, ubias, ibias, RLC=RLC
;
;  INPUT: 	
;	ubolo	   (float array) bolometer voltage  
;	ubias	   (float array) bias voltage	    
;    
;  OUTPUT:
;	ibias	   (float array) bias current	    
;
;  KEYWORDS
;	RLC	   (float) load resistance [Ohm]    
;
;  AUTHOR: 
;		   Bernhard Schulz
; 
;  Edition History:
;
;  Date          Programmer    Remarks
;  ----------    ----------    -------
;  2003-05-01    B. Schulz     initial test version
;  2003-09-19    L. Zhang      Indroduced RLC keyword and changed the 
;			       default Rload RLC=2.0e7
;                       
;===========================================================================
;-

pro bolodark_ibias, ubolo, ubias, ibias, RLC=RLC

if NOT keyword_set(RLC) then RLC = 2.0e7        

 
;-------------------------------------
; derive the bias current

      ibias = (ubias - ubolo)/RLC
 
return
end
