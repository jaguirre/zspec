FUNCTION find_sample_interval, seconds
  
; If seconds is padded at the end with constant data (a "feature" in Z-Spec 
; timestream data as of Aug 2006), that portion shouldn't be used in the
; calculation of the sample interval.  We can mask that out by only including
; points with nozero derivative.

diffs = fin_diff(seconds)
goodpts = WHERE(diffs NE 0)
dsec = deglitch(diffs[goodpts], mask, step=0.005, sigma=6)

RETURN, MEAN(dsec[WHERE(mask NE 0)])

END
