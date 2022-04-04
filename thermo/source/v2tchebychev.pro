; v2tchebychev.pro - this program converts sensor readings
; to temperatures based on the given chebychev calibration
; coefficients and scaling parameters.  It can deal with 
; singlets and vectors of readings which have been scaled
; to the normalized variable.
;
; 30 May 2005 - First Version by Bret Naylor

FUNCTION v2tchebychev, normval, coeffs
	; create the first two chebychev terms (t0 = 1.0, t1 = x)
	; I want both of these to have the same type 
	; (singlet, array) as normval
	t0 = (normval - normval) + 1.0
	t1 = normval

	nval = N_ELEMENTS(normval)
	IF nval EQ 1 THEN BEGIN
		; Compute first two terms of expansion
		total = t0 * coeffs[0] + t1 * coeffs[1]

		; Set up the recursion relation for the remaining terms
		tnmin1 = t0
		tn = t1
		; Get the number of terms in the expansion
		nterms = N_ELEMENTS(coeffs)
		FOR i = 2, nterms - 1 DO BEGIN
			tnplus1 = 2 * normval * tn - tnmin1
			total = total + coeffs[i] * tnplus1
			tnmin1 = tn
			tn = tnplus1
		ENDFOR
	ENDIF ELSE BEGIN
		; Compute the first two terms of the expansion
		total = t0 * coeffs[0,*] + t1 * coeffs[1,*]

		; Set up recursion realation varibles
		tnmin1 = t0
		tn = t1
		; Assume all sets of coeffs have same number of terms
		nterms = N_ELEMENTS(coeffs[*,0])
		FOR i = 2, nterms - 1 DO BEGIN
			tnplus1 = 2 * normval * tn - tnmin1
			total = total + coeffs[i,*] * tnplus1
			tnmin1 = tn
			tn = tnplus1
		ENDFOR
	ENDELSE

	RETURN, total
END
