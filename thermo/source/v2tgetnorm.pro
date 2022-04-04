; v2tgetnorm.pro - this function computes the normalized
; varible useful for chebychev expansion.
;
; 31 May 2005 - First Version by Bret Naylor

FUNCTION v2tgetnorm, reading, zls, zus, range
	nread = N_ELEMENTS(reading)
	IF nread EQ 1 THEN BEGIN
		result = ((reading - zls[range]) - (zus[range] - reading))/$
				(zus[range] - zls[range])
		result = result[0]
	ENDIF ELSE BEGIN
		result = FLTARR(nread)
		FOR i = 0L, nread - 1 DO BEGIN
			result[i] = ((reading[i] - zls[range[i]]) - $
					(zus[range[i]] - reading[i]))/ $
					(zus[range[i]] - zls[range[i]])
		ENDFOR
	ENDELSE

	RETURN, result
END
