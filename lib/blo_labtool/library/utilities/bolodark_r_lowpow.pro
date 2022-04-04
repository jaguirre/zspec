;+
;===========================================================================
; 
;  NAME: 
; 		    bolodark_r_lowpow
; 
;  DESCRIPTION:     
;		    Determine resistances and temperatures at minimum power
; 		      using direct method after corrrecting for offset in ubolo
;
;  USAGE: 
;		    bolodark_r_lowpow, ubolo, ubias, T_c, Rmin, T_ca,
;		    nmed=nmed
;
;  INPUT: 	   					     
;	ubolo	   (array float) bolometer voltages [V]       
;	ibias	   (array float) bias voltage [V]	      
;	T_c	   (array float) cold plate temperatures [K]  
;    
;  OUTPUT:
; 	Rmin	   (float) resistance at minimum power        
;	T_ca	   (float) mean temperature at Rmin           
;
;
;  KEYWORDS:
;	nmed=nmed   Integer
;       RLC	    Resistance per channel. If set, the RLC value is used   .
;		    Othwerwise, the deafult RLC=2.0e7 will be used	   
; 
;  AUTHOR: 
;		    Bernhard Schulz (IPAC)
;	
; 
;  Edition History:
;
;  Date	        Programmer   Remarks
;  2003/05/01 	B. Schulz    initial test version
;  2003/05/08 	B. Schulz    Offset removal added
;  2003/09/19 	L. Zhang     Add RLC keyword
;===========================================================================
;-

pro bolodark_r_lowpow, ubolo, ubias,  T_c, Rmin, T_ca, nmed=nmed, RLC=RLC


if NOT keyword_set(RLC) then RLC = 2.0e7	;Ohms

if NOT keyword_set(nmed) then nmed = 200

a = bolodark_moffset(ubolo, ubias)	;determine offset
ubolo1 = ubolo-a[0]			;remove offset
bolodark_ibias, ubolo1, ubias, ibias, RLC=RLC

P = ubolo1 * ibias
R = ubolo1 / ibias

ix = where(R GT 0 AND abs(ubias) LT 0.005, cnt)

if cnt GT 1 then begin 
  index = sort(P[ix])
  if nmed GT cnt then nmed1 = cnt $
  else nmed1 = nmed
  T_ca = median(T_c[ix[index[0:nmed1-1]]])
  T_ca_err = stdev(T_c[ix[index[0:nmed1-1]]])
  Rmin = median(R[ix[index[0:nmed1-1]]])
  Rmin_err = stdev(R[ix[index[0:nmed1-1]]])
endif else begin
  Rmin = 0.
  Rmin_err = 0
  T_ca = T_c[0]
  T_ca_err = 0
endelse

return
end
