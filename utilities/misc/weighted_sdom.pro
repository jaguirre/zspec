; This function has been updated using the 2nd error estimator proposed by
; Zhang, Metrologia 43 (2006) 195-204 (called Var^hat_2(X^bar_GD))
; Errors have to be binned (with ERRBIN > 3) to apply that estimator.

; There are two modes for using this function depending on the value
; of ERRBIN: 1) If ERRBIN is set to a single value then a set of equal
; sized bins are used to average sigmas or 2) if ERRBIN is set to a
; vector, then sigmas are grouped into bins whose sizes are given by
; the elements in ERRBIN.  After grouping the data, any NANs are
; identified and eliminated from the averaging.  Any bin with fewer
; than three points (after throwing out NANs) is discarded and a
; warning is issued.  Using this function with ERRBIN set to less than
; 5 is NOT RECOMMENDED.

; If ERRBIN is not set or set to 3 or less, then the "standard" (under-)
; estimator is used.
;
; JRK edit 3/6/09: discard bin if all points were removed.

; 2009_07_02 BJN Updated to use new binning and weighting behavior and
;                to correctly deal with NaNs
; JRK 12/7/12: Added keyword /quiet
; KSS 12/19/12: Committed revisions to svn.

FUNCTION weighted_sdom, sigmas, ERRBIN = ERRBIN, WEIGHTS_OUT = WEIGHTS_OUT,quiet=quiet
  WEIGHTS_OUT = compute_weights(sigmas, ERRBIN = ERRBIN, BINSIZES = BINSIZES)
  RETURN, weighted_sdom_input_weights(WEIGHTS_OUT, $
                                      ERRBIN = ERRBIN, BINSIZES = BINSIZES,quiet=quiet)
END
