;+
;===========================================================================
;  NAME: 
;		  BLO_CLIPSIGMA
;
;
;  DESCRIPTION: 
;		  Clip noisy data outside of sigma standard deviations.
;  		  Algorithm iterates until no outliers are found.
;
;  USAGE: 
;		  blo_clipsigma(signal, sigma)
;
;  INPUT:
;    signal   	  array float) signal
;    sigma	  float) number of standard deviations to clip
;
;  OUTPUT:
;    		  Array of flags, set to 1 where signal exceeded limit
;
;  AUTHOR: 
;		  Bernhard Schulz (IPAC)
;
;  Edition History:
;
;  Date	        Programmer  Remarks
;  04/10/2002	B.Schulz    initial test version		    	  
;  12/03/2003	B.Schulz    documentation corrected		    	  
;  09/07/2003	B.Schulz    double keyword added to mean and stddev 	  
;
;
;===========================================================================
;-
function blo_clipsigma, signal, sigma

flg = byte(signal * 0)

repeat begin

  iy = where(flg EQ 0)
  sg = stddev(signal(iy),/double)
  ix = where(abs(signal(iy) - mean(signal(iy),/double)) GT sigma*sg,cnt)
  if cnt GT 0 then flg(iy(ix)) = 1
;help, iy, ix, cnt, sg

endrep until cnt EQ 0
return, flg

end
