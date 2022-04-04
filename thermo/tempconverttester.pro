; tempconverttester.pro - this program loads sensor measurements
; and checks the calibration data from tempconvert against the
; measurements.  A plot, rms & max errors are given.  Only checks
; diode calibration currently.
;
; 31 May 2005 - First Version by Bret Naylor

PRO tempconverttester
	; Open calibrated data file
	OPENR, 1, '/home/zspec/naylor/thermo/curve10.txt'
	ncols = 3
	nlines = 120
	data = FLTARR(ncols,nlines)
	READF, 1, data
	CLOSE, 1

	temps = REFORM(data[0,*])
	volts = REFORM(data[1,*])

	PLOT, volts, temps, /YLOG, PSYM = 6
	
	convtemps = tempconvert(volts, 'diode', 'lin')
	
	OPLOT, volts, convtemps

	errors = ABS(convtemps - temps)/temps
	validrange = WHERE(temps GE 2.0)
	maxerr = MAX(errors[validrange])

	PRINT, 'Largest Fractional Error is', maxerr
	PRINT, 'Average Fractional Error is', MEAN(errors)
	
END
