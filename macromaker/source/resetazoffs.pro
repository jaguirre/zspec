; resetazoffs.pro - prints the UIP commands to lun to zero the azimuth 
; and zenith offsets.

PRO resetazoffs, lun
	uipcomment, lun, 'Resetting azimuth and zenith offsets'
	setazoffs, lun, 0, 0
END
