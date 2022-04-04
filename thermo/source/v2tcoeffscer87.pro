; v2tcoeffscer87.pro - this function returns the coefficients
; (or array of coefficients) necessary to convert a Cernox S/N X31187 reading
; into temperature.  It also scales reading to be the normalized
; variable x = (z-zl)-(zu-z)/(zu-zl), where z is the reading, x
; is the normalized varible and zl and zu are parameters of the fits.
;
; 31 May 2005 - First Version by Bret Naylor (copied from v2tcoeffsdiode.pro)

FUNCTION v2tcoeffscer87, reading

	; Define Fit Arrays
	nranges = 4

	; Ranges are in reverse temp order as reading is inversely
	; proportional.  Ranges are 325K-94.9K, 94.9K-20K, 20K-3K and 3K-0.3K
	rmins = ALOG10([34.6888, 72.0274, 164.3339, 500.537])
	rmaxs = ALOG10([72.0274, 164.3339, 500.537, 15595.4321])
	zls = [1.53393284385688, 1.8207354637661, 2.18848035071281, 2.65823815243254]
	zus = [1.88481057170423, 2.23812337513408, 2.74954455323003, 4.38161860641541]	

	maxorder = 8
	; Pad coeff arrays with zeros to make them all the same length
	coeffs = FLTARR(maxorder + 1, nranges)
	coeffs[*,0] = [1.88687947198740E+02, -1.21196434860429E+02, $
			1.98527897587926E+01, -2.95758794906037E+00, $
			6.10117709977056E-01, -1.18343340705174E-01, $
			2.23574476003821E-02, -1.11657993694913E-02, $
			4.40018581333022E-03]

	coeffs[*,1] = [5.50253355293494E+01, -4.48977062702936E+01, $
			8.90250651281557E+00, -1.08854641956378E+00, $
			8.65674532938245E-02, 1.40567343450497E-02, $
			-3.54232337205388E-03, 0.0, 0.0]

	coeffs[*,2] = [9.51771301469811E+00, -9.34809266214969E+00, $
			3.03714696223375E+00, -7.09441254585885E-01, $
			1.06535071583118E-01, -1.28156501626261E-03, $
			0.0, 0.0, 0.0]

	coeffs[*,3] = [1.11527789923880E+00, -1.27888330739829E+00, $
			6.04885472566337E-01, -2.52546246856832E-01, $
			9.61018971052949E-02, -3.45804293998503E-02, $
			1.21203727107486E-02, -3.68995944531188E-03, $
			1.21730733610273E-03]

	range = v2tgetrange(reading, rmins, rmaxs)
	normvar = v2tgetnorm(reading, zls, zus, range)
	retcoeff = v2tgetcoeff(coeffs, range)

	reading = normvar

	RETURN, retcoeff
END
