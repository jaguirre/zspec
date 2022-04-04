;+
;===========================================================================
;  NAME: 
;		   BLO_SINE_START
;
;
;  DESCRIPTION:    
;		   Derive estimates of frequency and amplitude from
;  		     sampled sine signal
;
;  USAGE: 
;		   blo_sine_start, time, sig, frequ, ampl, phase, 
;		     offset
;
;  INPUT:
;    signal	  (array float) sine signal
;
;  OUTPUT:
;    frequ   	  (float) frequency						 
;    ampl	  (float) estimate of amplitude 				 
;    phase   	  (float) phase (0..1), multiply by 2*!PI or 360 to get angle	 
;    offset  	  (float) zero offset						 
;
;  AUTHOR: 
;		  Bernhard Schulz (IPAC)
;
;  Edition History
;   
;  Date	        Author	   Remarks
;  01/10/2002  	B.Schulz   initial test version 	   		
;  09/10/2002  	B.Schulz   bug fix in phase recognition    		
;
;
;===========================================================================
;-
pro blo_sine_start, time, sig, frequ, ampl, phase, offset

n = n_elements(sig)

ampl = (max(sig)-min(sig))/2.d			;Amplitude
offset = mean(sig)					;Zero offset

signal = sig - offset				;subtract offset

signal1 = shift(signal,-1)
ix = where(signal * signal1 LT 0, n_cycles)

if n_cycles GE 2 then begin

  n_cycles = (n_cycles-1)/2.d
  frequ = n_cycles / (time(n-1) - time(0))			;Frequency

  trans1 = (time(ix(0))+time(ix(0)+1))/2 - time(0)	;Phase
  
  if signal(0) LT 0 then 	phase =     - trans1*frequ  $
  else 				phase = 0.5 - trans1*frequ

  if n / n_cycles LT 4 then n_cycles = 0	;need at least Nyquist!
endif else n_cycles = 0

end
