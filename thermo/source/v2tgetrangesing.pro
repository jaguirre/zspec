; v2tgetrangesing.pro - this function gets the proper range 
; for a single measurement.
;
; 31 May 2005 - First Version by Bret Naylor

FUNCTION v2tgetrangesing, singlet, rmins, rmaxs

	range = WHERE(((rmins LT singlet) AND (rmaxs GE singlet)), count)

	; If reading is out of bounds, count will equal zero and reading is
	; either smaller than the smallest value or larger than the largest.
	IF count EQ 0 THEN BEGIN
		IF singlet LE rmins[0] THEN BEGIN
			range = LONG(0)
		ENDIF ELSE BEGIN
			nranges = N_ELEMENTS(rmaxs)
			range = LONG(nranges - 1)
		ENDELSE

	; If count isn't zero, then range will be a single element array, which
	; is undesireable.
	ENDIF ELSE range = range[0]

	RETURN, range
END
