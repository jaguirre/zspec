; fivepointmac.pro - prints to lun the commands for a five point
; observation with the specified throw around aoff and zoff.  
; It nods at each point with a integration time of t_int.

PRO fivepointmac, lun, throw, aoff, zoff, t_int
	; Compute five actual azimuth and zenith offsets
	aoffs = aoff + [0	,-throw	, throw	, 0	, 0	]
	zoffs = zoff + [0	, 0	, 0	, throw	,-throw	] 	
	
	uipcomment, lun, 'Starting Five Point - Center = (' + $
				STRING(aoff, FORMAT = '(F0.1)') + $
				', ' + STRING(zoff, FORMAT = '(F0.1)') + ')'
	fivepttime = 4.*t_int		;approximate
	FOR i = 0, 4 DO BEGIN
		uipcomment, lun, i_of_n('Five Point Position', i+1, 5, $
				'Observation', fivepttime, 'seconds')
		setazoffs, lun, aoffs[i], zoffs[i]
		nodsequence, lun, t_int
	ENDFOR
	resetazoffs, lun
	uipcomment, lun, 'Five Point Complete'
END
