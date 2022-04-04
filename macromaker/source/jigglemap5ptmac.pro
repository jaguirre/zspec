; jigglemap5ptmac.pro - prints to the lun the necessary commands
; for a evenly sampled square jiggle map of overall size size
; and with pts points in both azimuth and zenith.  At each
; map position, a five point with throw throw is executed with 
; t_int integration time.  Map is centered on acen and zcen.
; 
; Each five point will be one observation so that data files are of resonable size.


PRO jigglemap5ptmac, lun, size, pts, acen, zcen, throw, t_int
	; Create offset arrays	
	aoffs = [acen]
	zoffs = [zcen]
	
	makejigglepts, size, pts, aoffs, zoffs, step

	nmappts = N_ELEMENTS(aoffs)
	nmapptsstring = STRING(nmappts, FORMAT = '(I0)')
	uipcomment, lun, 'Executing Jiggle Map of Five Points'
	uipcomment, lun, ('Map Size = ' + STRING(size, FORMAT = '(F0.1)') + ' arcsec square')
	uipcomment, lun, ('Step Size = ' + STRING(step, FORMAT = '(F0.1)') + $
					' arcsec in azimuth and zenith') 
	uipcomment, lun, ('Number of Map Points = ' + nmapptsstring)

	mappttime = 5.*4.*t_int			;approximate
	FOR i = 0, nmappts - 1 DO BEGIN
		obsstart, lun
		uipcomment, lun, i_of_n('Map Position', i+1, nmappts, $
				'Macro', mappttime/60., 'minutes')
		fivepointmac, lun, throw, aoffs[i], zoffs[i], t_int
		obsend, lun
	ENDFOR

	resetazoffs, lun
	uipcomment, lun, 'Jiggle Map of Five Points Complete'	

END
