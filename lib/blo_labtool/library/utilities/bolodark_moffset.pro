;+
;===========================================================================
;  NAME: 
;		   bolodark_moffset
; 
;  DESCRIPTION:    
;		   Derive offset and slope close to zero bias
;
;  USAGE: 
;		   bolodark_moffset, ubolo, ubias  
;  	
;
;  INPUT: 	  					       
;	ubolo	   (float array) bolometer voltage	        
;	ubias	   (float array) bias voltage		        
;    
;  OUTPUT:
;	a[]	   (float array) [offset, slope]	        
;
;  KEYWORDS:
;	plot
;	ix	   returns indices of datapoints close to zero  
;
;  AUTHOR: 
;		   Bernhard Schulz
;	
; 
;  Edition History:
;
;  Date    	Programmer    Remarks
;  ---------- 	----------    -------
;  2003-05-08 	B. Schulz     initial test version
;  2004-03-11 	B. Schulz     minimum number of elements increased to 12
;
;===========================================================================
;-

function bolodark_moffset, ubolo, ubias, plot=plot, ix=ix

ix = where(ubias GT -0.001 AND (ubias LT  0.001), cnt)
;ix = where(ubias GT -0.0024 AND (ubias LT  0.0024), cnt)

if cnt LT 12 then begin
  ix = sort(abs(ubias))	    ;select 12 closest elem. to zero bias
  iy = sort(ubias[ix[0:12]])
  ix = ix[iy]
  message, /info, "Not enough U_bias found closer than 0.001V to zero!"
  message, /info, "New limits: "+string(min(ubias[ix]))+" : "+string(min(ubias[ix]))
endif

a = linfit(ubias[ix], ubolo[ix])	    ;linefit around zero

if keyword_set(plot) then begin
  plot, ubias[ix], ubolo[ix], psym=6			       
  rb = a[0] + ubias[ix] *a[1]  		       
  oplot, ubias[ix], rb, color=blo_color_get('white')
endif

return, a
end

