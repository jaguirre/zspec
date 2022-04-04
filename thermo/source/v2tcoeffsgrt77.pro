; v2tcoeffsgrt77.pro - this function returns the coefficients
; (or array of coefficients) necessary to convert a GRT S/N 29177 reading
; into temperature.  It also scales reading to be the normalized
; variable x = (z-zl)-(zu-z)/(zu-zl), where z is the reading, x
; is the normalized varible and zl and zu are parameters of the fits.
;
; 31 May 2005 - First Version by Bret Naylor (copied from v2tcoeffscer87.pro)

FUNCTION v2tcoeffsgrt77, reading

	; Define Fit Arrays
	nranges = 2

	; Ranges are in reverse temp order as reading is inversely
	; proportional.  Ranges are 5K-1.15K and 1.15K-0.05K
	rmins = ALOG10([17.35, 36.1311])
	rmaxs = ALOG10([36.1311, 25578.3686])
	zls = [1.22056318371666, 1.54287271146326]
	zus = [1.57967368776453, 4.49036026187077]	

	maxorder = 11
	; Pad coeff arrays with zeros to make them all the same length
	coeffs = FLTARR(maxorder + 1, nranges)
	coeffs[*,0] = [2.67615714096046E+00, -2.16594606884944E+00, $
			7.85454642122224E-01, -3.09934044872214E-01, $
			1.39550266067604E-01, -6.86056973951330E-02, $
			3.66755067874175E-02, -2.07261671589794E-02, $
			1.08523866232057E-02, -6.93971133906733E-03, $
			3.19977788887936E-03, -2.94407150243386E-03]

	coeffs[*,1] = [3.03961630942296E-01, -4.13597694591500E-01, $
			2.42964989316760E-01, -1.27586092270591E-01, $
			6.32319208899388E-02, -3.00789760298283E-02, $
			1.40091081532479E-02, -6.34563720702974E-03, $
			2.91871064205273E-03, -1.20862549714124E-03, 0.0, 0.0]

	range = v2tgetrange(reading, rmins, rmaxs)
	normvar = v2tgetnorm(reading, zls, zus, range)
	retcoeff = v2tgetcoeff(coeffs, range)

	reading = normvar

	RETURN, retcoeff
END
