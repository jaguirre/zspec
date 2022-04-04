;; This function takes a set of data, computes the weighted average and
;; recursively cuts out points in the data that are outside a certain
;; range from that average.  The range is determined by the error in the
;; difference between the weighted average and the rawdata point (whose
;; errors are given in sigmas_in) multiplied by the range parameter.
;; Formally, the error in the difference is given by the square root of
;; the sum of the variances (sigma squared).  The error in the weighted
;; mean will be recalculated when data points are eliminated

;; The return value is the weighted average of the masked data
;; goodmask is an array with 1 where a point is good, and 0 where it isn't
;; sigma contains the standard deviation of the weighted data

;; If QUIET = 0 (or not set) then print status info 
;; IF QUIET = 1 then print no status info
;; IF QUIET = 2 then print status info only when points are cut

FUNCTION rm_outlier_weighted, rawdata, sigmas_in, range, $
                              goodmask, sigma, $
                              transmission=transmission,$
                              QUIET = QUIET
  ;; Set up variable for recursive glitch finding loop
  data = rawdata
  sigmas = sigmas_in
  ; This will add weighting by the transmission, when present 
  IF KEYWORD_SET(transmission) THEN $
     sigmas /= SQRT(transmission) $
  ELSE transmission = REPLICATE(1.0,N_E(sigmas_in))
  
  npts = N_ELEMENTS(data)
  ncurrpts = npts
  ngoodpts = LONG(0)
  goodmask = REPLICATE(1,npts)
  
  ;; add a recursion failsafe
  nloop = 0
  totalloops = 50
  
  ;; Time the outlier removal process
  start = SYSTIME(/SEC)
  
  WHILE ((ngoodpts LT ncurrpts) AND (nloop LT totalloops)) DO BEGIN
     nloop = nloop + 1
     ncurrpts = N_ELEMENTS(data)

     ;; Get good points
     ave = weighted_mean(data,sigmas)
     
     sigma = weighted_sdom(sigmas)

     goodpts = WHERE(ABS(data - ave) LT $
                     range*SQRT(sigma^2+sigmas^2), ngoodpts)
     
     ;; Check to make sure there are some good points
     IF (ngoodpts EQ 0) THEN BEGIN
        message, /info, 'No good data points remain in loop ' + $
                 STRING(nloop, F = '(I0)')
        message, /info, 'Returning original data'
        data = rawdata
        sigmas = sigmas_in/SQRT(transmission)
        goodmask = REPLICATE(1,npts)
        BREAK
     ENDIF ELSE BEGIN
        ;; Set goodflags to 0 where there are bad points
        IF (ngoodpts LT ncurrpts) THEN BEGIN
           temp = INTARR(ncurrpts)
           temp[goodpts] = 1
           goodmask[WHERE(goodmask EQ 1)] = temp
        ENDIF
        ;; Prepare for next iteration
        data = data[goodpts]
        sigmas = sigmas[goodpts]
     ENDELSE
  ENDWHILE
  
  goodpts = WHERE(goodmask EQ 1, ngoodpts)
  IF ngoodpts GT 0 THEN BEGIN
     ave=weighted_mean(rawdata[goodpts],$
                       sigmas_in[goodpts]/SQRT(transmission[goodpts]))
     sigma = weighted_sdom(sigmas_in[goodpts]/SQRT(transmission[goodpts]))
  ENDIF ELSE BEGIN
     message, /info, $
              'No good points left, using all for mean & standard deviation'
     ave=weighted_mean(rawdata,sigmas_in/SQRT(transmission))
     sigma = weighted_sdom(sigmas_in/SQRT(transmission))
     goodmask = REPLICATE(1,npts)
  ENDELSE
  
  deltime = SYSTIME(/SEC) - start
  
  IF ~KEYWORD_SET(QUIET) THEN QUIET = 0
  IF (QUIET EQ 0) OR ((QUIET EQ 2) AND (ngoodpts LT npts)) THEN $
     message, /info, 'Cut ' + STRING(npts - ngoodpts, F='(I0)') + $
              ' of ' + STRING(npts, F='(I0)') + ' points using ' + $
              STRING(nloop, F='(I0)') + ' iterations and taking ' + $
              STRING(deltime, F='(F0.4)') + ' seconds'
  
  RETURN, ave
END
