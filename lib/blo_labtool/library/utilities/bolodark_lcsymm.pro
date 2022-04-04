;+
;==============================================================================
;  NAME: 
;		   bolodark_lcsymm
;
;  DESCRIPTION: 
;		   Returns average residual asymmetry in loadcurve
;
;  USAGE: 
;		   a = bolodark_lcsymm(ubias0, ubolo0, obias)
;
;  INPUT:	  	 						 
;     ubias0       bias voltage 					  
;     ubolo0       bolometer voltage					  
;
;  OUTPUT:
;     function     (float) average difference in ubias0 between positive   
;	           part of loadcurve and flipped negative part  	  
; 
;  KEYWORD: 
;		   none
;
;  AUTHOR: 
;		   Bernhard Schulz
;
;  Edition History:
;
;  Date		Programmer   Remarks
;  2003/05/13   B.Schulz     initial test version
;==============================================================================
;-

function bolodark_lcsymm, ubias0, ubolo0, obias

ubias = ubias0 - obias[0]						      
a = bolodark_moffset(ubolo0, ubias)	  ;determine bolo offset      
ubolo = ubolo0-a[0]			  ;remove bolo offset	      

ixm = where(ubias LT 0,cntm) 					      
ixp = where(ubias GE 0,cntp) 					      

if cntp LT 15 OR cntm LT 15 then begin

  message, /info, 'Obias out of range!'
  return, 1.0  

endif else begin

  ;plot, ubias[ixp], ubolo[ixp], psym=3 	     		     
  ;oplot,-(ubias[ixm]), -ubolo[ixm], psym=3	     		     

  ixs = sort(ubias[ixp])

  ubiasp = ubias[ixp[ixs]]
  ubolop = ubolo[ixp[ixs]]

  ;select values that can be interpolated;
  ix = where(-ubias(ixm) GE min(ubolop) AND $	     		     
  	     -ubias(ixm) LE max(ubiasp),cnt)	     		     

  ubolo2 = interpol(ubolop, ubiasp, -ubias[ixm[ix]])

  ;plot,  ubias[ixm[ix]], ubolo[ixm[ix]], psym=3     			     
  ;oplot, ubias[ixm[ix]], -ubolo2, psym=4	     			 
  ;plot, ubias[ixp[ix]],ubolo[ixp[ix]]-ubolo2, psym=6

  return, avg(ubolo[ixp[ix]]-ubolo2)

endelse
end
