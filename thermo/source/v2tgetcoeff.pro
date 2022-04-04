; v2tgetcoeff.pro - this function returns the appropriate coefficients
; for the chebychev fit given the range(s) in range.
;
; 31 May 2005 - First Version by Bret Naylor

FUNCTION v2tgetcoeff, coeffs, range
	nread = N_ELEMENTS(range)
	IF nread EQ 1 THEN BEGIN
		retcof = coeffs[*,range]
	ENDIF ELSE BEGIN
		nterm = N_ELEMENTS(coeffs[*,0])
		retcof = FLTARR(nterm, nread)
		FOR i = 0L, nread - 1 DO BEGIN
			retcof[*,i] = coeffs[*,range[i]]
		ENDFOR
	ENDELSE

	RETURN, retcof
END
