; This function computes an array of weights based on sigmas and
; ERRBIN.  The returned weights is an array of the same length as
; sigmas.  If ERRBIN is not set or equals zero, then the returned
; vector is 1/sigmas^2.  If ERRBIN is a single value, then the sigmas
; are binned together into groups of size ERRBIN and the MEDIAN is
; used to average those together.  If ERRBIN is a vector, it is
; assumed to be a vector of (potentially variable) bin sizes and
; sequencial bins of the sizes in ERRBIN are used to group values in
; sigmas which are then averaged by MEDIAN.  Any NaNs in sigmas are
; duplicated in the returned weights.  The binsizes used are returned
; in keyword BINSIZES.

; 2009_07_02 BJN First Edition

FUNCTION compute_weights, sigmas, ERRBIN = ERRBIN, BINSIZES = BINSIZES
  IF ~KEYWORD_SET(ERRBIN) THEN RETURN, 1/sigmas^2
  nsigmas = N_ELEMENTS(sigmas)
  binsizes = create_bin_array(nsigmas, ERRBIN)
  nbins = N_ELEMENTS(binsizes)
; Now for each bin, compute median variance and weights
  weights = sigmas
  binstart = 0L
  binend = -1L
  FOR bin = 0, nbins-1 DO BEGIN
     binend += binsizes[bin]
     binvar = MEDIAN(sigmas[binstart:binend]^2,/EVEN)
     weights[binstart:binend] = 1.0/binvar
     binstart += binsizes[bin]
  ENDFOR
; Check for NaNs and overwrite
  nan_inds = WHERE(FINITE(sigmas, /NAN) EQ 1, nan_count)
  IF nan_count NE 0 THEN weights[nan_inds] = !VALUES.F_NAN

  RETURN, weights
END


