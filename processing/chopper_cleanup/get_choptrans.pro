; get_choptrans - returns the rises and falls in a periodic signal (eg. chop encoder)
; When the keyword EST_ZEROS is set, then the function returns
; linearly estimated zero crossings, not the typical rise or fall index.
; Use the CEIL function to recover the usual rise & fall indicies because
; the zero crossing always comes before the rise or fall index.
FUNCTION get_choptrans, signal, EST_ZEROS = EST_ZEROS
	; First do some mean subtraction & normalization
	chop = signal
	chop -= MEAN(chop)
	chop /= MAX(ABS(chop))

	; Create sharp square wave chop with same mean & amplitude
	squarechop = DBLARR(N_ELEMENTS(chop))
	squarechop[WHERE(chop GT 0.0)] = 2.0
	squarechop -= 1.0

	; Measure chop period and create sine wave chop
	choptrans = find_transitions(squarechop)
        choptrans = create_struct(choptrans, 'chop_status', 1)
        
        catch, error_status
        if error_status ne 0 then begin
            return, create_struct('chop_status', 0)
        endif

        IF KEYWORD_SET(EST_ZEROS) THEN BEGIN
		rises = DOUBLE(choptrans.rise)
		rises -= chop[choptrans.rise]/(chop[choptrans.rise] - chop[choptrans.rise - 1])
		falls = DOUBLE(choptrans.fall)
		falls -= chop[choptrans.fall]/(chop[choptrans.fall] - chop[choptrans.fall - 1])
		RETURN, create_struct('rise',rises,'fall',falls, 'chop_status', 1)
	ENDIF ELSE RETURN, choptrans
END
