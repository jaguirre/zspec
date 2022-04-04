;+
;===========================================================================
;  NAME: 
;		   bolodark_ipbolo
;
;  DESCRIPTION: 
;		   Determine current and power after correcting for 
;		   offset in ubolo
;
;  USAGE: 
;		   bolodark_ipbolo, ubolo, ubias, uboloc, ibias  
;
;  INPUT: 	
;    ubolo   	   (array float) bolometer voltages [V] 		   
;    ubias   	   (array float) bias voltage [V]			   
;    
; OUTPUT:
;    ibias   	   (array float) bias current [A]			   
;    uboloc  	   (array float) offset corrected bolometer voltages [V]   
;
;
;  KEYWORDS:
;    RLC           Resistance per channel				   
;
;  AUTHOR: 
;		   Bernhard Schulz (IPAC)
;	
; 
;  Edition History:
;
;  Date		Programmer   Remarks
;  2003/05/08 	B. Schulz    initial test version
;  2003-09-19: 	L  Zhang     Add  RLC keyword
;  2003-12-11:  L. Zhang     Add a block to take care the case
;                            when ubolo contains the same values
;
;-------------------------------------------------------------------
;-

pro bolodark_ipbolo, ubolo, ubias, uboloc, ibias, RLC=RLC

a = bolodark_moffset(ubolo, ubias)	;determine offset

;when the ubolo contains the same value, the linfit y=A+Bx will become
; y=A, in our case, A is the ubolo.  Therefore, when B=0 (a[1])=0,
;we don't treat offset. The block below is taking care this case
if (a[1] eq 0 ) then begin              
   uboloc=ubolo
endif else begin 
   uboloc = reform(ubolo)-a[0]			;remove offset
endelse

if keyword_set(RLC) then begin
    bolodark_ibias, uboloc, ubias, ibias, RLC=RLC
endif else begin
   bolodark_ibias, uboloc, ubias, ibias
endelse 

return
end
