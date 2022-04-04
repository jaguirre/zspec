; Makes a mask of npts based on the zeros (rising & falling) and period given
; The mask will have points = 1 during a good cycle and 0 when the
; cycle isn't good.
FUNCTION make_chopmask, chopzeros, chop_period, npts, QUIET = QUIET
	half_chop = get_halfperiods(chopzeros)
	del_half = compute_deltas(half_chop)
	bad_half = WHERE(ABS(del_half - chop_period/2.0) GT 0.6, nbad_half, COMPLEMENT = good_half)

	; Making the chopmask
	chop_mask = FLTARR(npts) + 1.0
	curr_bad = 0
	nbad_groups = 0
	WHILE curr_bad LT nbad_half DO BEGIN
		nbad_groups += 1
		start_bad = FLOOR(half_chop[bad_half[curr_bad]]) ; start of mask before zero crossing
		nperiod_mask = 1.0
		end_bad = start_bad - 1 + ROUND(nperiod_mask*chop_period)
		WHILE TOTAL(WHERE(half_chop[bad_half] GT end_bad AND $
				half_chop[bad_half] LE end_bad + chop_period)) NE -1 DO BEGIN
			nperiod_mask += 1.0
			end_bad = start_bad - 1 + ROUND(nperiod_mask*chop_period)
                    ENDWHILE
                    if start_bad lt 0 then start_bad=0
                    if end_bad ge n_e(chop_mask) then end_bad=n_e(chop_mask)-1
		chop_mask[start_bad:end_bad] = 0.0

		post_end_bad = WHERE(half_chop[bad_half] GT end_bad, npost)
		IF npost EQ 0 THEN BEGIN
			curr_bad = nbad_half
		ENDIF ELSE BEGIN
			curr_bad = post_end_bad[0]
		ENDELSE
	ENDWHILE

	IF ~(KEYWORD_SET(QUIET)) THEN BEGIN
		MESSAGE, /INFO, 'Masked out ' + STRING(nbad_half, F='(I0)') + $
			' bad half cycles in ' + STRING(nbad_groups, F='(I0)') + ' groups.'
		IF nbad_half GT 0 THEN BEGIN
			MESSAGE, /INFO, 'Bad half cycles occur at these indicies: ' + $
                                 STRJOIN(STRING(ROUND(half_chop[bad_half]), F='(I0)'),', ')
		ENDIF
	ENDIF

	RETURN, chop_mask
END
