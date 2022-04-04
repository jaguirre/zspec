; This function computes the deltas between points in an array
FUNCTION compute_deltas, array
	RETURN, array[1:*] - array[0:N_E(array)-2]
END