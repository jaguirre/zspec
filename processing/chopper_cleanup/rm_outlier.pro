;This function takes a set of data, computes the mean and recursively
;cuts out points in the data that outside a certain range from that
;mean.  The range can be defined in either absolute units, or in terms
;of the standard deviation (set keyword /SDEV).  The standard deviation
;will be recalculated when data points are eliminated when that is used
;for cutting points.
;The return value is the mean of the masked data
;goodmask is an array with 1's where the point is good, and 0 where it isn't
;sigma contains the standard deviation of the mean of the cut data
;If QUIET = 0 (or not set) then print status info 
;IF QUIET = 1 then print no status info
;IF QUIET = 2 then print status info only when points are cut
;
; 10/01/09 BJN Updated to recognize and ignore NaNs in the input
FUNCTION rm_outlier, rawdata, range, goodmask, sigma, $
                     SDEV = SDEV, QUIET = QUIET

  ;; Set up variable for recursive glitch finding loop
  data = rawdata
  
  npts = N_ELEMENTS(data)
  ngoodpts = 0L
  goodmask = REPLICATE(1,npts)

; Check for NaNs in rawdata and incorporate into goodmask
  nan_inds = WHERE(FINITE(rawdata, /NAN) EQ 1, nan_count)
  IF nan_count NE 0 THEN goodmask[nan_inds] = 0

  IF (nan_count EQ npts) THEN BEGIN
     message, /info, 'No good data points for rm_outlier'
     message, /info, 'Returning average = NaN'
     ave=!Values.D_NaN
  ENDIF ELSE BEGIN
     data = data[WHERE(goodmask EQ 1)]
     ncurrpts = N_ELEMENTS(data)
  
  ;; add a recursion failsafe
  nloop = 0
  totalloops = 50
  
  ;; Time the outlier removal process
  start = SYSTIME(/SEC)
  
  WHILE ((ngoodpts LT ncurrpts) AND (nloop LT totalloops)) DO BEGIN
     nloop = nloop + 1
     ncurrpts = N_ELEMENTS(data)
     
     ;; First compute mean & stddev
     ave = MEAN(data,/NAN)
     
     ;; Get good points
     IF KEYWORD_SET(SDEV) THEN BEGIN
        IF ncurrpts EQ 1 THEN BEGIN
           MESSAGE, /INFO, 'Only one good point remaining in loop ' + $
                    STRING(nloop,F='(I0)')
           MESSAGE, /INFO, 'Unable to to do further sigma based cuts'
           MESSAGE, /INFO, 'Returning original data'
           data = rawdata
           goodmask = REPLICATE(1,npts)
           IF nan_count NE 0 THEN goodmask[nan_inds] = 0
           BREAK
        ENDIF ELSE BEGIN
           sigma = STDDEV(data,/NAN)
           goodpts = WHERE(ABS(data - ave) LT range*sigma, ngoodpts)
        ENDELSE
     ENDIF ELSE BEGIN
        goodpts = WHERE(ABS(data - ave) LT range, ngoodpts)
     ENDELSE
     
     ;; Check to make sure there are some good points
     IF (ngoodpts EQ 0) THEN BEGIN
        message, /info, 'No good data points remain in loop ' + $
                 STRING(nloop, F = '(I0)')
        message, /info, 'Returning original data'
        data = rawdata
        goodmask = REPLICATE(1,npts)
        IF nan_count NE 0 THEN goodmask[nan_inds] = 0
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
     ENDELSE
  ENDWHILE
  
  deltime = SYSTIME(/SEC) - start
  
  IF ~KEYWORD_SET(QUIET) THEN QUIET = 0
  IF (QUIET EQ 0) OR ((QUIET EQ 2) AND (ngoodpts LT npts)) THEN $
     message, /info, 'Cut ' + STRING(npts - ngoodpts, F='(I0)') + $
              ' of ' + STRING(npts, F='(I0)') + ' points using ' + $
              STRING(nloop, F='(I0)') + ' iterations and taking ' + $
              STRING(deltime, F='(F0.4)') + ' seconds'

  ENDELSE
  
  RETURN, ave
;   RETURN, goodmask
END
