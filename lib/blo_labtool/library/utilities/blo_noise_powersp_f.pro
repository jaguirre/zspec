;+
;===========================================================================
;  NAME:
;                  blo_noise_powersp_f
;
;  DESCRIPTION:
;                  Generate power spectrum with low frequency limit
;
;  USAGE:
;                  blo_noise_powersp_f, data, n0, ScanRateHz, s
;
;  INPUT:
;     data         signal data [V]
;     n0           number of data points expected in data
;     ScanRateHz   Scan rate of data in Hertz
;
;  OUTPUT:
;     s            power spectrum [V]
;
;  KEYWORDS:
;     f_limit      lower frequency limit in Hz
;     nopower      return simple fourier spectrum without normalization
;                  to W/sqrt[Hz]
;     deglitch     if set glitches above 5 sigma deviation are replaced
;                  by the median value of the dataset
;
;  Example:
;
;  scanrate = 1000.
;  frequ = 10.
;  n = 10000
;  x = findgen(n)/scanrate
;  y = sin(x*frequ*2*!PI)
;  plot, x, y, xrange=[0,0.1]
;  blo_noise_powersp_f, y, n, scanrate, s
;  x_s = findgen(n/2+1L)*scanrate/n
;  plot, x_s, s, xrange=[7,25]
;
;
;  Edition History
;
;  Date         Programmer  Remarks
;  ----------   ----------  -------
;  2004/02/29   B. Schulz   initial version
;
;===========================================================================
;-

pro blo_noise_powersp_f, data, n0, ScanRateHz, s, nopower=nopower, $
                        deglitch=deglitch, f_limit=f_limit

if NOT keyword_set(f_limit) then f_limit = 0.1 ;Hz

t_limit = 1./f_limit  ;sec

nrep = long(n0 / ScanRateHz / t_limit)   ;number of spectra that can be calculated
if nrep LT 1L then begin                 ;case if timeline less than t_limit
  nrep=1L
  nel = n0
endif else begin
  nel  = long(t_limit * ScanRateHz)      ;number of input elements for one spectrum
endelse

nsp  = nel/2L+1L                         ;number of output elements for spectrum

;print, nrep, "repeats"
for irep=0L, nrep-1L do begin
  data0 = data[irep*nel:irep*nel+nel-1L]
  blo_noise_powerspec, data0, nel, ScanRateHz, s0, nopower=nopower, $
                        deglitch=deglitch

  if irep EQ 0 then specaccu = s0^2 $
  else              specaccu = s0^2 + specaccu

endfor
s = sqrt(specaccu / nrep)

end

