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
; JRK 12/7/12: Added /quiet keyword, just for the 3 point warnings.
; KSS 12/19/12: Committed revisions to svn.

FUNCTION weighted_sdom_input_weights, weights, ERRBIN = ERRBIN, $
                                      BINSIZES = BINSIZES, quiet=quiet
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
