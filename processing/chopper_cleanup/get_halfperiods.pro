; Interleaves the two arrays from find_transitions (.rise & .fall)
FUNCTION get_halfperiods, trans
	; Create 2D array to transpose & reindex to make
	; a sequence of the starts of each half cycle
	n_rise = N_ELEMENTS(trans.rise)
	n_fall = N_ELEMENTS(trans.fall)
	IF trans.rise[0] LT trans.fall[0] THEN $
		halfperiods = 	[[trans.rise[0:MIN([n_rise,n_fall])-1]],$
					 [trans.fall[0:MIN([n_rise,n_fall])-1]]] $
	ELSE halfperiods = 	[[trans.fall[0:MIN([n_rise,n_fall])-1]],$
					 [trans.rise[0:MIN([n_rise,n_fall])-1]]]

	halfperiods = TRANSPOSE(halfperiods)
	halfperiods = halfperiods[LINDGEN(N_E(halfperiods))]

	; If there is an unequal number of rises & falls, append
	; an extra point in the proper cases
	IF trans.rise[0] LT trans.fall[0] AND n_rise GT n_fall THEN BEGIN
		halfperiods = [halfperiods,trans.rise[n_fall]]
	ENDIF
	IF trans.fall[0] LT trans.rise[0] AND n_fall GT n_rise THEN BEGIN
		halfperiods = [halfperiods,trans.fall[n_rise]]
	ENDIF

	RETURN, halfperiods
END