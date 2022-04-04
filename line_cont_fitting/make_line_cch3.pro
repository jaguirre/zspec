;; Returns a line profile based on FWHM = line_width (in km/s) gaussians
;; centered at the redshifted freqencies of the hyperfine splittings of
;; the CCH 3-2 transition, whose amplitudes are chosen based on the
;; integrated intensity parameter from the JPL Line Catalog.  The
;; brightest transition is used as a relative calibrator for the rest of
;; the transitions.  The final result adjusted so that the integrated
;; intensity of the result is equal to the given line_width.  freqs is
;; assumed to be in GHz.  After execution, center is set to the 
;; the freqency of the peak of the line.


FUNCTION make_line_cch3, freqs, redshift, line_width, center
  
;; FROM the JPL Line CATALOG 
;; (first col = Freq, Third col = ALOG10(int. inten.)
;;               25001  CCH          
;;   262004.2266   .0307 -2.7339 2    8.7402  9  25001 123 3 4 4       2 3 3       
;;   262006.4034   .0306 -2.8599 2    8.7392  7  25001 123 3 4 3       2 3 2       
;;   262064.8433   .0314 -2.8800 2    8.7450  7  25001 123 3 3 3       2 2 2       
;;   262067.3312   .0313 -3.0647 2    8.7454  5  25001 123 3 3 2       2 2 1       
;;   262078.7758   .0317 -3.9360 2    8.7450  5  25001 123 3 3 2       2 2 2       
;;   262208.4388   .0350 -3.9713 2    8.7402  7  25001 123 3 3 3       2 3 3       

  centers = [262004.2266,262006.4034,262064.8433,$
             262067.3312,262078.7758,262208.4388]/1000.D
  centers /= (1.0 + redshift)
  intens = 10.^[-2.7339,-2.8599,-2.8800,-3.0647,-3.9360,-3.9713]
  intens /= MAX(intens,maxtrans)
  
  c = 299792.458                ; in km/sec
  fwhms = (line_width/c)*centers
  sigmas = fwhms/(2.D*SQRT(2.D*ALOG(2.D)))

  amps = intens/(fwhms/fwhms[maxtrans])
  amps *= (2.D*SQRT(2.D*ALOG(2.D)))/SQRT(2.D*!DPI)
  
  allline = DBLARR(N_E(freqs))
  totalinten = 0.D
  FOR f = 0L, N_E(centers) - 1 DO $
     allline += amps[f] * EXP(-0.5*((freqs-centers[f])/sigmas[f])^2)

  peak = MAX(allline,peakind)
  center = freqs[peakind]
  RETURN, allline/TOTAL(intens)
END
