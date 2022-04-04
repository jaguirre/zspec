; This function returns the weighted mean of values based on the
; vector of weights, which must be the same length as values.

FUNCTION weighted_mean_input_weights, values, weights
  IF N_E(values) NE N_E(weights) THEN $
     STOP, 'Values & weights have different numbers' + $
           ' of elements - this is not correct.  STOPPING.'
  RETURN,TOTAL(values*weights, /NAN)/TOTAL(weights, /NAN)
END
