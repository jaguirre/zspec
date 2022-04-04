; v2tcoeffsrox34.pro - this function returns the coefficients
; (or array of coefficients) necessary to convert a ROX S/N U01434 reading
; into temperature.  It also scales reading to be the normalized
; variable x = (z-zl)-(zu-z)/(zu-zl), where z is the reading, x
; is the normalized varible and zl and zu are parameters of the fits.
;
; 31 May 2005 - First Version by Bret Naylor (copied from v2tcoeffscer87.pro)

FUNCTION v2tcoeffsrox34, reading

	; Define Fit Arrays
	nranges = 3

	; Ranges are in reverse temp order as reading is inversely
	; proportional.  Ranges are 40K-6.24K, 6.24K-.855K and .855K-.05K
	rmins = ALOG10([2260.7032, 2787.4425, 4771.33])
	rmaxs = ALOG10([2787.4425, 4771.33, 71797.3973])
	zls = [3.34998709598856, 3.42937894358044, 3.64119440619716]
	zus = [3.46035646948349, 3.72344582025278, 4.88299102583086]	

	maxorder = 9
	; Pad coeff arrays with zeros to make them all the same length
	coeffs = FLTARR(maxorder + 1, nranges)
	coeffs[*,0] = [1.83012698883617E+01, -1.81270313036755E+01, $
			6.22836322156446E+00, -1.75657858717478E+00, $
			4.66220947364965E-01, -1.16383115839574E-01, $
			2.71030130065026E-02, 0.0, 0.0, 0.0]

	coeffs[*,1] = [2.77289112412813E+00, -3.04955559952355E+00, $
			1.36093221910294E+00, -5.52845451107431E-01, $
			2.09881957287272E-01, -7.51322468127236E-02, $
			2.55291118816476E-02, -7.98127649025362E-03, $
			2.11185815687711E-03, -1.28017234867160E-03] 

	coeffs[*,2] = [2.97832702919413E-01, -3.84522635924287E-01, $
			1.99740493638382E-01, -9.42464310907341E-02, $
			4.20945939844180E-02, -1.84875765292956E-02, $
			8.28318895842923E-03, -3.50834269474273E-03, $
			1.45886693937506E-03,  -6.02242902967776E-04]

	range = v2tgetrange(reading, rmins, rmaxs)
	normvar = v2tgetnorm(reading, zls, zus, range)
	retcoeff = v2tgetcoeff(coeffs, range)

	reading = normvar

	RETURN, retcoeff
END
