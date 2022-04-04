; tempconvtestcal.pro - this program verifies the conversion from
; grt resistance to temperature that is the basis of tempconvert.
; It loads in actual sensor measurements for the 4 calibrated
; sensors and compares with the chebychev polynomial expansion
;
; 31 May 2005 - First Version by Bret Naylor

PRO tempconvtestcal
	; Open calibrated data file for Cernox X31187
;	OPENR, 1, '/home/zspec/naylor/thermo/X31187.dat'
;	nlines = 99
;	OPENR, 1, '/home/zspec/naylor/thermo/29177.dat'
;	nlines = 54
;	OPENR, 1, '/home/zspec/naylor/thermo/29178.dat'
;	nlines = 54
	OPENR, 1, '/home/zspec/naylor/thermo/U01434.dat'
	nlines = 77

	ncols = 2
	data = FLTARR(ncols,nlines)
	READF, 1, data
	CLOSE, 1

	temps = REFORM(data[0,*])
	reses = REFORM(data[1,*])

	PLOT, temps, reses, /YLOG, /XLOG, PSYM = 6, $
		XTITLE = 'Temperature (K)', YTITLE = 'Resistance (Ohm)'
	
	reads = ALOG10(reses)
;	coeffs = v2tloadcal(reads, 'cerx31187')
;	coeffs = v2tloadcal(reads, 'grt29177')
;	coeffs = v2tloadcal(reads, 'grt29178')
	coeffs = v2tloadcal(reads, 'roxu01434')
	caltemps = v2tchebychev(reads, coeffs)
	
	OPLOT, caltemps, reses, thick = 3

	errors = ABS(caltemps - temps)/temps
	maxerr = MAX(errors)

	PRINT, 'Largest Fractional Error is', maxerr
	PRINT, 'Average Fractional Error is', MEAN(errors)
	
END
