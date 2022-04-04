;+
;============================================================================
;  NAME: 
;		   BLO_SINE2_FUNC
;
;  DESCRIPTION:    
;		   swsiged Double Sine function for fit
;
;  USAGE: 
;		   blo_sine2_func, time, a, fsin, fsin_der
;
;  INPUT:
;     time	   (array float) time					    
;     a             (array float) parameters [frequency[Hz], amplitude[V],   
;       	  				  phase[0..1],  	        	
;       	  				  offset[V], fswsig[Hz],        	
;       	  				  swsigphase[0..1]]	        	
;
;  OUTPUT:
;     fsin 	   array float) double sine signal			    
;     fsin_der	   (array float) partial derivatives			    
;
;  AUTHOR: 
;		   Bernhard Schulz (IPAC)
;
;  
;  Edition History:
;   
;  Date		Author	    Remarks
;  10/04/2002	B.Schulz    initial test version    		       
;
;
;=========================================================================
;-
pro blo_sine2_func, time, a, fsin, fsin_der

fsin = time * 0d
swsig = sin((time*a(4) + a(5))*2*!PI)	;switch signal function with phase

ix = where(swsig GT 0,cnt)		;no sign function found in IDL
sign = swsig * 0 - 1
if cnt GT 0 then sign(ix) = 1

fsin = a(3) + sign * a(1)*sin((time*a(0) + a(2)) *2*!PI)	;sine wave with phase


 IF N_PARAMS() GE 4 THEN $
   fsin_der=[[sign*2*a(1)*cos((2*time*a(0)+2*a(2))*!PI)*time*!PI], $
            [sign*sin((2*time*a(0)+2*a(2))*!PI)], $
            [sign*2*a(1)*cos((2*time*a(0)+2*a(2))*!PI)*!PI], $
            [time*0.+1]]

end

