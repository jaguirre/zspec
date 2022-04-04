;; This routine computes the mean and error in the mean of njacks random
;; jackknife splits of vec_in, a 1D array.  Half of vec_in values are
;; multiplied by -1, then the result is averaged.  The process is
;; repeated njacks times, recording the average result for each run.
;; Then the mean of all runs & the standard deviation of all runs is
;; computed.  The returned result is a two element vector, the first
;; element is the average jackknife result and the second is the error in
;; that average

;; Doing this process when njacks >> N_E(vec_in) produces unrealistic
;; error in the mean estimates.  njacks = 2*vec_in should be fairly
;; accurate.

FUNCTION vector_jackknife, vec_in, njacks
  vec = vec_in
  npts = N_ELEMENTS(vec)
  jackresults = DBLARR(njacks)
  FOR i = 0, njacks - 1 DO $
     jackresults[i] = MEAN(vec*create_jack_vec_knuth(npts))

  jackmean = MEAN(jackresults)
  jacksdom = STDDEV(jackresults)/SQRT(njacks)

  RETURN, [jackmean,jacksdom]
END
