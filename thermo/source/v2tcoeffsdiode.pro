; v2tcoeffsdiode.pro - this function returns the coefficients
; (or array of coefficients) necessary to convert a diode reading
; into temperature.  It also scales reading to be the normalized
; variable x = (z-zl)-(zu-z)/(zu-zl), where z is the reading, x
; is the normalized varible and zl and zu are parameters of the fits.
;
; 30 May 2005 - First Version by Bret Naylor

FUNCTION v2tcoeffsdiode, reading

	; Define Fit Arrays
	nranges = 4

	; Ranges are in reverse temp order as reading is inversely
	; proportional.  Ranges are 475K-100K, 100K-24.5K, 12K-24.5K and 2K-12K
	rmins = [0.09062, 0.97550, 1.13000, 1.36809] ; third value is estimated
	rmaxs = [0.97550, 1.13000, 1.36809, 1.68786] ; second value is estimated 
	zls = [0.079767, 0.923174, 1.11732, 1.32412]
	zus = [0.999614, 1.13935, 1.42013, 1.69812]	

	maxorder = 11
	; Pad coeff arrays with zeros to make them all the same length
	coeffs = FLTARR(maxorder + 1, nranges)
	coeffs[*,0] = [287.756797, -194.144823, -3.837903, -1.318325, $
			-0.109120, -0.393265, 0.146911, -0.111192, $
			0.028877, -0.029286, 0.015619, 0.0]
	coeffs[*,1] = [71.818025, -53.799888, 1.669931, 2.314228, $
			1.566635, 0.723026, -0.149503, 0.046876, $
			-0.388555, 0.056889, -0.116823, 0.058580]
	coeffs[*,2] = [17.304227, -7.894688, 0.453442, 0.002243, $
			0.158036, -0.193093, 0.155717, -0.085185, $
			0.078550, -0.018312, 0.039255, 0.0]
	coeffs[*,3] = [7.556358, -5.917261, 0.237238, -0.334636, $
			-0.058642, -0.019929, -0.020715, -0.014814, $
			-0.008789, -0.008554, 0.0, 0.0]

	range = v2tgetrange(reading, rmins, rmaxs)
	normvar = v2tgetnorm(reading, zls, zus, range)
	retcoeff = v2tgetcoeff(coeffs, range)

	reading = normvar

	RETURN, retcoeff
END
