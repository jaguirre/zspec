; v2tcoeffsgrt78.pro - this function returns the coefficients
; (or array of coefficients) necessary to convert a GRT S/N 29178 reading
; into temperature.  It also scales reading to be the normalized
; variable x = (z-zl)-(zu-z)/(zu-zl), where z is the reading, x
; is the normalized varible and zl and zu are parameters of the fits.
;
; 31 May 2005 - First Version by Bret Naylor (copied from v2tcoeffsgrt77.pro)

FUNCTION v2tcoeffsgrt78, reading

	; Define Fit Arrays
	nranges = 2

	; Ranges are in reverse temp order as reading is inversely
	; proportional.  Ranges are 5K-1.15K and 1.15K-0.05K
	rmins = ALOG10([19.03, 39.4969])
	rmaxs = ALOG10([39.4969, 27745.7918])
	zls = [1.26075837249213, 1.58432556945465]
	zus = [1.61817928994213, 4.50509840278782]	

	maxorder = 11
	; Pad coeff arrays with zeros to make them all the same length
	coeffs = FLTARR(maxorder + 1, nranges)
	coeffs[*,0] = [2.67930973600527E+00, -2.16832493667705E+00, $
			7.83589165335571E-01, -3.08674815763854E-01, $
			1.38768231075190E-01, -6.80994637004264E-02, $
			3.61973152673171E-02, -2.03331004424386E-02, $
			1.07315191131709E-02, -6.95099261893124E-03, $
			3.07294675203625E-03, -2.89976441026802E-03]

	coeffs[*,1] = [3.04444053803683E-01, -4.13415155866968E-01, $
			2.41892581682659E-01, -1.26202334625875E-01, $
			6.23676882914255E-02, -2.95594106912121E-02, $
			1.36314635927993E-02, -6.11933743873653E-03, $
			2.86058165547636E-03, -1.13653968805525E-03, 0.0, 0.0]

	range = v2tgetrange(reading, rmins, rmaxs)
	normvar = v2tgetnorm(reading, zls, zus, range)
	retcoeff = v2tgetcoeff(coeffs, range)

	reading = normvar

	RETURN, retcoeff
END
