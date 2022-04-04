; This function estimates the phase shift present in
; the list of edges, assuming the edges are period periodic.
; The phase shift is given in units of samples (units of edges & period)
FUNCTION phase_estimator, period, zeros
	test_edges = DINDGEN(N_E(zeros))*period
	RETURN, mean(zeros - test_edges)
END
