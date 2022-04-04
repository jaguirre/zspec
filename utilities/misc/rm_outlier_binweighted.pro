; This function recusively removes outliers from values and sigmas (by
; setting them to NaN) based on a weighted mean where the weights are
; based on the variance, averaged over the bin size specified in
; ERRBIN, which can be a single value or a vector of bin sizes.
; CUT_LEVEL sets how many sigma a point has to be away from the
; weighted mean to be eliminated (default = 3.0).  N_LOOPS is the
; number of times to go through the removal loop (default = 50).  The
; default value for ERRBIN is 10.

; The function returns the final weighted mean value and stores the
; final estimated error in the weighted mean in finalsdom.  The mask
; of good points is stored in finalmask.  The final weights used are
; returned in keyword WEIGHTS_OUT.

; Unless no outliers are found, values and sigmas will be altered by
; this function such that the outlying points will be replaced with
; NaNs. 

; By default, the recursion algorithm will exit if the estimated error
; in the mean at some recursion step is larger than the estimated
; error of the previous step.  The outlier removal will be rolled back
; one step and that data will be returned.  If NO_SDOM_CHECK is set,
; then this check won't be used.

; 2009_07_02 BJN Initial Version
; 2009_07_14 JRK Bug fix, removed "values" from calls to weighted_sdom
; 2009_07_20 BJN Added weights_out
; 2009_10_01 BJN Input NaN are now recorded in output mask in all
; cases
; 2012-12-07 JRK Added keyword /quiet
; KSS 12/19/12: Committed revisions to svn.

FUNCTION rm_outlier_binweighted, values, sigmas, finalsdom, finalmask, $
                                 ERRBIN = ERRBIN, WEIGHTS_OUT = WEIGHTS_OUT, $
                                 CUT_LEVEL = CUT_LEVEL, N_LOOPS = N_LOOPS, $
                                 QUIET=QUIET
; Check keywords and set default values
  IF ~KEYWORD_SET(ERRBIN) THEN ERRBIN = 10
  IF ~KEYWORD_SET(CUT_LEVEL) THEN CUT_LEVEL = 3.0
  IF ~KEYWORD_SET(N_LOOPS) THEN N_LOOPS = 50
  
; Create some boolean values and mask array
  true = BYTE(1)
  false = BYTE(0)
  
  goodmask = BYTARR(N_E(values))
  goodmask += true
  
; Check for NaNs in values and incorporate into goodmask
  nan_inds = WHERE(FINITE(values, /NAN) EQ 1, nan_count)
  IF nan_count NE 0 THEN goodmask[nan_inds] = false

; Store original input
  orig_values = values
  orig_sigmas = sigmas

  FOR i = 0, N_LOOPS-1 DO BEGIN
; Compute current weighted mean and error in that weighted mean
     currmean = weighted_mean(values, sigmas, ERRBIN = ERRBIN, $
                              WEIGHTS_OUT = currweights)
     currsdom = weighted_sdom(sigmas, ERRBIN = ERRBIN,quiet=quiet)

; Check for outlier points (NOTE - currweights = (estimated sample variance)^-1)
     outliers = WHERE((ABS(values - currmean) * SQRT(currweights)) GT $
                      CUT_LEVEL, n_outliers)

; If there are outliers, temporarily mask out those points both in
; goodmask and with NaNs
     IF n_outliers NE 0 THEN BEGIN
        goodmask[outliers] = false
        tempvalues = values
        tempsigmas = sigmas
        tempvalues[outliers] = !VALUES.F_NAN
        tempsigmas[outliers] = !VALUES.F_NAN
; If no more outliers, store output values and exit loop
     ENDIF ELSE BEGIN
        out_values = values
        out_sigmas = sigmas
        BREAK
     ENDELSE
     
; Check if all points have been masked out and if so, restore original
; inputs and exit from loop
     IF N_E(WHERE(goodmask EQ false)) EQ N_E(values) THEN BEGIN
        out_values = orig_values
        out_sigmas = orig_sigmas
        goodmask = BYTARR(N_E(values))
        goodmask += true
        IF nan_count NE 0 THEN goodmask[nan_inds] = false
        BREAK
     ENDIF

; The section below turned out to not be what we want to do...

; Check if the new estimated error in the weighted average is larger
; or smaller than the previous estimate.  If it is larger, then exit
; the loop with the previous set of values and sigmas.  Otherwise,
; accept the new masks and loop again.
;     newsdom = weighted_sdom(tempsigmas, ERRBIN = ERRBIN)
;     IF ((~KEYWORD_SET(NO_SDOM_CHECK)) AND (newsdom GT currsdom)) THEN BEGIN
;        out_values = values
;        out_sigmas = sigmas
;        goodmask[outliers] = true
;        BREAK
;     ENDIF ELSE BEGIN
;        values = tempvalues
;        sigmas = tempsigmas
;     ENDELSE
     
     values = tempvalues
     sigmas = tempsigmas
     
  ENDFOR

; Create output
  values = out_values
  sigmas = out_sigmas
  finalmean = weighted_mean(values, sigmas, ERRBIN = ERRBIN)
  finalsdom = weighted_sdom(sigmas, ERRBIN = ERRBIN, WEIGHTS_OUT = WEIGHTS_OUT,quiet=quiet)
  finalmask = goodmask

  RETURN, finalmean
END
