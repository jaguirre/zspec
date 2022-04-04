; setazoffs.pro - prints to lun the UIP commands to set
; the azimuth and zenith offsets to aoff and zoff, then
; wait until those offsets are achieved

PRO setazoffs, lun, aoff, zoff
	PRINTF, lun, ('AZO ' + STRING(aoff,format='(F0.1)'))
	PRINTF, lun, ('ZAO ' + STRING(zoff,format='(F0.1)'))
	PRINTF, lun, 'ANWAIT'
END
