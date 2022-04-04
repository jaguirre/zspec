; makejigglepts.pro - this program generates two arrays
; of points for a jiggle map.  The first value in the
; arguments aoffs and zoffs is taken to be the center of 
; the map.  If keyword first is set, include the inital 
; point in the arrays (useful for maps with even numbers
; of points), otherwise strip it off.

PRO makejigglepts, size, pts, aoffs, zoffs, returnstep, keepfirst = kf
	step = size/FLOAT(pts-1)
	half = FLOAT(pts-1)/2.0

	FOR i = -half, half DO BEGIN
		FOR j = -half, half DO BEGIN
			aoffs = [aoffs,i*step + aoffs[0]]
			IF CEIL(i) MOD 2 EQ 0 THEN BEGIN
				zoffs = [zoffs,j*step + zoffs[0]]
			ENDIF ELSE BEGIN
				zoffs = [zoffs,-j*step + zoffs[0]]
			ENDELSE
		ENDFOR
	ENDFOR

	; Strip off inital (redundant for odd x odd map) point in array
	; unless keepfirst is set
	IF NOT(KEYWORD_SET(kf)) THEN BEGIN
		aoffs = aoffs[1:*]
		zoffs = zoffs[1:*]
	ENDIF

	returnstep = step
END
