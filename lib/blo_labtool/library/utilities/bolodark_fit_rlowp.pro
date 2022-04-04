;+
;===========================================================================
;  NAME: 
;		   bolodark_fit_rlowp
;
;  DESCRIPTION:    
;		   Fit straight line to T^-0.5 and ln(Rmin)
;
;  USAGE: 
;		   bolodark_pl_rlowp, T_c, Rmin 	     
;
;  INPUT:  	  					        
;     T_c    	  (array float) temperature [K] 	          
;     Rmin	  (array float) resistance at minimum power [P]   
;    
;  OUTPUT:	  					        
;     a	 	  (array float) [intercept, slope]	          
;
;  KEYWORDS: 
;		   none
;	
;
;  AUTHOR: 
;		   Bernhard Schulz
; 
;  Edition History:
;
;  Date        Programmer  Remarks
;  ----------  ----------  -------
;  2003-05-08  B. Schulz   initial test version
;  2003-09-06  L. Zhang  fixed the undefined variable(a) bug
;-------------------------------------------------------------------
;-

function bolodark_fit_rlowp, T_c, Rmin


ix = where(Rmin GT 0, cnt)

if cnt GT 1 then begin

  T_c05 = T_c[ix]^(-0.5)
  lgRmin = alog(Rmin[ix])

  a = ladfit( T_c05, lgRmin)

endif else begin

  a=[0.0, 0.0]    ;fixed bug LZ 9/6/03

endelse


return, a

end
