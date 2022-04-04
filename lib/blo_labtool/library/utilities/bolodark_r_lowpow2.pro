;+
;==========================================================================
;  NAME: 
;		  bolodark_r_lowpow2
;  
;  DESCRIPTION:    
;		   Determine resistances and temperatures at minimum power
; 		   using slope method
;
;  USAGE: 
;	           bolodark_r_lowpow2, ubolo, ubias, T_c, Rmin, T_ca, $ 
;	           plot=plot
;
;  INPUT: 	   
;	ubolo	   (array float) bolometer voltages [V]
;	ibias	   (array float) bias current [A]	      
;	T_c	   (array float) cold plate temperatures [K]  
;    		   					      
;  OUTPUT:	   
; 	Rmin	   (float) resistance at minimum power 
;	T_ca	   (float) mean temperature at Rmin	      
;		   					      
;
;  KEYWORDS:
;	plot	   if set plots of load curve and fit are produced	    
;       RLC	   Resistance per channel. If set, the RLC value will	    
;	           be used. Otherwise, the default RLC=2.0e7 will be used   
;
;  Author: 
;		   Bernhard Schulz (IPAC)
;	
; 
;  Edition History:
;
;  Date		Programmer  Remarks
;  2003/05/07 	B. Schulz   initial test version
;  2003/05/08 	B. Schulz   function bolodark_moffset inserted
;  2003-09-19 	L. Zhang    add RLC Keyword
;  2004-04-24 	B.Schulz    additions to plotting
;==========================================================================
;-

pro bolodark_r_lowpow2, ubolo, ubias,  T_c, Rmin, T_ca, $
                        RLC=RLC, plot=plot



if NOT keyword_set(RLC) then RLC = 2.0e7	;Ohms


if keyword_set(plot) then $
  plot, ubias,ubolo[*],  $
       psym=3, color=blo_color_get('white')


a = bolodark_moffset( ubolo, ubias, ix=ixlow)

if keyword_set(plot) then begin
  plot, T_c, ystyle=3, psym=3
endif



Rmin =  RLC * a[1] / (1 - a[1])

T_ca     = avg(T_c[ixlow])

if keyword_set(plot) and n_elements(ixlow) GT 1 then begin
  oplot, ixlow, T_c[ixlow], psym=6
endif


return
end
