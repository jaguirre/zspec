;+
;=================================================================
;  NAME: 
;		  BLO_SINE_FUNC
;
;  DESCRIPTION: 
;		  Sine function for fit
;
;
;  USAGE: 
;		  blo_sine_func, time, a, fsin, fsin_der
;
;  INPUT:
;    time	 (array float) time					   
;    a            (array float) parameters [frequency[Hz], amplitude[V],    
;		  phase, [0..1], offset[V]]				   
;
;  OUTPUT:
;    fsin	 (array float) sine signal				   
;    fsin_der	 (array float) partial derivatives			   
;
;  KEYWORD:
;  		  none
;
;  AUTHOR: 
;		  Bernhard Schulz (IPAC)
;
;  Edition History:
;
;  Date		Author	   Remarks
;  10/01/2002 	B.Schulz   initial test version     		      
;
;
;=================================================================
;-
pro blo_sine_func, time, a, fsin, fsin_der

fsin = time * 0d
fsin = a(3) + a(1)*sin((time*a(0) + a(2)) *2*!PI)

 IF N_PARAMS() GE 4 THEN $
   fsin_der=[[2*a(1)*cos((2*time*a(0)+2*a(2))*!PI)*time*!PI], $
            [sin((2*time*a(0)+2*a(2))*!PI)], $
            [2*a(1)*cos((2*time*a(0)+2*a(2))*!PI)*!PI], $
            [time*0.+1]]
end

