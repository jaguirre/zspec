;+
;===========================================================================
;  NAME: 
;		   blo_noise_powerspec
;
;  DESCRIPTION:    
;		   Generate power spectrum
;
;  USAGE: 
;		   blo_noise_powerspec, data, n0, ScanRateHz, s
;
;  INPUT:
;     data	   signal data [V]				         
;     n0           number of data points expected in data	         
;     ScanRateHz   Scan rate of data in Hertz			         
; 
;  OUTPUT:
;     s		   power spectrum [V]				         
;
;  KEYWORDS:
;     nopower 	   return simple fourier spectrum without normalization  
;		   to W/sqrt[Hz]				         
;     deglitch	   if set glitches above 5 sigma deviation are replaced  
;		   by the median value of the dataset		         
;
;  Example: 
; 
;  scanrate = 1000.
;  frequ = 10.
;  n = 10000
;  x = findgen(n)/scanrate
;  y = sin(x*frequ*2*!PI)
;  plot, x, y, xrange=[0,0.1]
;  blo_noise_powerspec, y, n, scanrate, s
;  x_s = findgen(n/2+1L)*scanrate/n
;  plot, x_s, s, xrange=[7,25]
;
;
;  Edition History
;
;  Date    	Programmer  Remarks
;  ---------- 	----------  -------
;  2002-05-02 	B. Schulz   Extracted from coadd_spectra_files.pro
;  2003/05/16 	B. Schulz   nopower keyword added
;  2003/07/09 	B. Schulz   deglitch keyword added
;
;===========================================================================
;-

pro blo_noise_powerspec, data, n0, ScanRateHz, s, nopower=nopower, $
			deglitch=deglitch

s = reform(data)

if keyword_set(deglitch) then begin
  flg = blo_clipsigma(s, 5.)		;find >5 sigma glitches
  ix = where(flg GT 0, cnt)
  if cnt GT 0 then s[ix] = median(s)	;remove glitches  
  if cnt GT 0 then message, /info, string(cnt)+' glitches found!'
endif

; Make the Fourier transform
s = abs(fft(s, -1))^2
n = n_elements(s)
if n ne n0 then message, "Problem with sizes"
if NOT keyword_set(nopower) then $
  s = n*s/ScanRateHz

; Fold the spectrum over to combine positive
; and negative frequencies
case (n mod 2L) of     ; Combine positive and negative frequencies
   0: begin
      half = n/2L
      s_prime = s[half+1L:*]
      s[1:half-1L] = s[1:half-1L] + reverse(s_prime)
      s = sqrt(s[0L:half])
   end
   1: begin
      half = (n-1L)/2L
      s_prime = s[half+1L:*]
      s[1:half] = s[1:half] + reverse(s_prime)
      s = sqrt(s[0:half])
   end
   else : message, "Problem with FFT size"
endcase
return
end

