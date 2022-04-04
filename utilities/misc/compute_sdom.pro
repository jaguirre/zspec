; This function takes a set of weights (assumed to be based on
; 1/variance) to estimate the error in the weighted mean based on the
; second proposed estimator from Zhang, Metrologia 43 (2006) 195-204
; (Eqn 20).  IF keyword ERRBIN is not set, then the standard (under-)
; estimate is returned along with a warning.  If keyword BINSIZES is
; not present, then a call to create_bin_sizes is made.

; If ERRBIN is a single value less that three, Zhang's
; estimator cannot be used, so a warning is issued and the standard
; (under-) estimate is returned.  

; The weights are assumed to be in groups based on the method described
; in compute_weights.  
; 
; JRK 12/7/12: added keyword quiet just for 3 bin messages.
; KSS 12/19/12: Committed revisions to svn.

FUNCTION weighted_sdom_input_weights, weights, ERRBIN = ERRBIN, $
                                      BINSIZES = BINSIZES,quiet=quiet
  IF ~KEYWORD_SET(ERRBIN) THEN BEGIN
     MESSAGE, /INFO, 'ERRBIN not set.  Returning standard (under-) estimate.'
     RETURN, SQRT(1.D/TOTAL(weights, /NAN))
  ENDIF
  IF ~KEYWORD_SET(BINSIZES) THEN BEGIN
     MESSAGE, /INFO, 'BINSIZES vector not given.  I hope this works.'
     BINSIZES = create_bin_array(N_E(weights), ERRBIN)
  ENDIF

;For each bin check for NANs, reducing the binsize for that bin as necessary.
  binsizes_corr = BINSIZES
  nbins = N_ELEMENTS(BINSIZES)
  binweights = DBLARR(nbins)
  binstart = 0L
  binend = -1L
  FOR bin = 0, nbins-1 DO BEGIN
     binend += binsizes[bin]
     binweights[bin] = TOTAL(weights[binstart:binend], /NAN)
     nan_inds = WHERE(FINITE(weights[binstart:binend], /NAN) EQ 1, nan_count)
     binsizes_corr[bin] -= nan_count
     binstart += binsizes[bin]
  ENDFOR
;Finally, do the calculation indicated in Zhang, Metrologia 43 (2006)
;195-204, Equation 20.
  bins_le_3 = WHERE(binsizes_corr LE 3, n_bins_le_3, $
                    COMPLEMENT = bins_gt_3, NCOMPLEMENT = n_bins_gt_3)
  IF n_bins_le_3 GT 0 THEN $
     if ~keyword_set(quiet) then MESSAGE, /INFO, STRING(n_bins_le_3) + ' bins have fewer than three ' + $
              'points and will be skipped.  This should over-estimate ' + $
              'the error in the weighted mean but proceed with caution.'
  IF n_bins_gt_3 EQ 0 THEN BEGIN
     if ~keyword_set(quiet) then MESSAGE, /INFO, 'All bins have three or fewer points and are ' + $
              'too small for Zhang Eqn 20.  Returning standard (under-)estimate'
     RETURN, SQRT(1.D/TOTAL(weights, /NAN))
  ENDIF ELSE BEGIN
     binweights = binweights[bins_gt_3]
     binsizes_corr = binsizes_corr[bins_gt_3]
  ENDELSE
  w_tilde = ((binsizes_corr - 3D)/(binsizes_corr - 1D)) * binweights
  w_tilde_norm = TOTAL(w_tilde, /NAN)
  w_tilde /= w_tilde_norm

  wm_var_est = (1/w_tilde_norm) * $
               (1 + 2*TOTAL((w_tilde * (1 - w_tilde))/binsizes_corr, /NAN))

  RETURN, SQRT(wm_var_est)
END


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
; JRK 12/7/12: Added keyword /quiet to pass to weighted_sdom_input_weights.

FUNCTION weighted_sdom, sigmas, ERRBIN = ERRBIN, WEIGHTS_OUT = WEIGHTS_OUT,$
                        weights_in=weights_in,quiet=quiet

if keyword_set(weights_in) then begin 
    weights_out=weights_in 
    BINSIZES = create_bin_array(n_e(sigmas), ERRBIN)
endif else WEIGHTS_OUT = compute_weights(sigmas, ERRBIN = ERRBIN, binsizes=binsizes)

  RETURN, weighted_sdom_input_weights(WEIGHTS_OUT, $
                                      ERRBIN = ERRBIN, BINSIZES = BINSIZES,quiet=quiet)
END 


;Driver function
function compute_sdom, values, mask, ERRBIN =ERRBIN,WEIGHTS_OUT = WEIGHTS_OUT,$
                        weights_in=weights_in, weighted=weighted,quiet=quiet

;Make any bad data NaN
; I did this so I could reuse the above functions
w=where(mask eq 0, count)
if count ne 0 then values[w]=!values.F_NAN

;Unweighted mean
if ~keyword_set(weighted) then return, stddev(values, /NAN)

;Weighted mean
return, weighted_sdom(values, ERRBIN = ERRBIN, WEIGHTS_OUT = WEIGHTS_OUT,$
                      weights_in=weights_in,quiet=quiet)
end
