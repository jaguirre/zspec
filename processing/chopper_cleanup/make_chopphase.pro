;This function makes the chop phase varible for make_artichop
;based on the mask, zeros and desired number of pts.
FUNCTION make_chopphase, mask, zeros, period, pts
	; Find the transistions in chop_mask and pad the results so that
	; at least one rise & fall are present and that the first and
	; last points are marked as a rise and fall, respectively, if necessary.
	masktrans = find_transitions(mask)
	IF (SIZE(masktrans.rise))[0] EQ 0 THEN BEGIN
		maskrises = [0]
	ENDIF ELSE BEGIN
		IF mask[0] EQ 1 THEN $
			maskrises = [0,masktrans.rise] $
		ELSE maskrises = masktrans.rise
	ENDELSE
	IF (SIZE(masktrans.fall))[0] EQ 0 THEN BEGIN
		maskfalls = [pts-1]
	ENDIF ELSE BEGIN
		IF mask[pts-1] EQ 1 THEN $
			maskfalls = [masktrans.fall,pts-1] $
		ELSE maskfalls = masktrans.fall
	ENDELSE

	; Step though good portions of mask and adjust phase for each section
	phase = DINDGEN(pts)
	FOR i = 0, N_E(maskrises)-1 DO BEGIN
		good_zeros = WHERE(zeros.rise GT maskrises[i] AND $
					    zeros.rise LT maskfalls[i], ngood_zeros)
		IF ngood_zeros NE 0 THEN BEGIN
			currphase = phase_estimator(period, zeros.rise[good_zeros])
		ENDIF ELSE BEGIN
			message, /info, 'No rising edges of chop in this mask window'
			message, /info, 'Phase reference impossible to find.  Using zero.'
			message, /info, 'CHECK chop_enc in range ' + $
					STRING(maskrises[i], maskfalls[i], F='("[",I0,":",I0,"].")')
			currphase = 0
		ENDELSE
		; Adjust the phase so that the phase adjustment extends one
		; before (if possible) and one after the region of good chops.
		IF maskrises[i] EQ 0 THEN $
			phase[maskrises[i]:maskfalls[i]] -= currphase $
		ELSE phase[maskrises[i]-1:maskfalls[i]] -= currphase
	ENDFOR

	RETURN, phase*2.*!DPI/period
END