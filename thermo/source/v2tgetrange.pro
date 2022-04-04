
; v2tgetrange.pro - this function returns the appropriate fit range(s)
; for the given reading and fit range ends (rmins & rmaxs)
;
; 30 May 2005 - First Version by Bret Naylor

FUNCTION v2tgetrange, reading, rmins, rmaxs
	nread = N_ELEMENTS(reading)
	IF nread EQ 1 THEN BEGIN
		range = v2tgetrangesing(reading, rmins, rmaxs)
	ENDIF ELSE BEGIN
		range = LONARR(nread)
		FOR i = 0L, nread - 1 DO range[i] = v2tgetrangesing(reading[i], rmins, rmaxs)
	ENDELSE

	RETURN, range
END  
