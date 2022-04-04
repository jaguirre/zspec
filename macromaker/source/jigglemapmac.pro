; jigglemapmac.pro - prints to the lun the necessary commands
; for a evenly sampled square jiggle map of overall size size
; and with pts points in both azimuth and zenith.  The map is
; centered on acen and zcen.  At each
; map position, a nod sequence is executed with t_int integration time.

PRO jigglemapmac, lun, size, pts, acen, zcen, t_int
	; Create offset arrays	
	aoffs = [acen]
	zoffs = [zcen]
	
	makejigglepts, size, pts, aoffs, zoffs, step

	nmappts = N_ELEMENTS(aoffs)
	nmapptsstring = STRING(nmappts, FORMAT = '(I0)')
	uipcomment, lun, 'Executing Jiggle Map'
	uipcomment, lun, ('Map Size = ' + STRING(size, FORMAT = '(F0.1)') + ' arcsec square')
	uipcomment, lun, ('Step Size = ' + STRING(step, FORMAT = '(F0.1)') + $
					' arcsec in azimuth and zenith') 
	uipcomment, lun, ('Number of Map Points = ' + nmapptsstring)

	mappttime = 4.*t_int + 10.		;approximate
	FOR i = 0, nmappts - 1 DO BEGIN
		uipcomment, lun, i_of_n('Map Position', i+1, nmappts, $
				'Observation', mappttime/60., 'minutes')
		setazoffs, lun, aoffs[i], zoffs[i]
		nodsequence, lun, t_int
	ENDFOR

	resetazoffs, lun
	uipcomment, lun, 'Jiggle Map Complete'	

END
