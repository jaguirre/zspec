; jigglemap5ptvis.pro - this is a simple program that helps to 
; visualize jigglemap5pt coverage.  It also calculates mapping
; time based on nod cycle = 4 * t_int + 17 sec.

PRO jigglemap5ptvis, size, pts, acen, zcen, throw, t_int
	; Create offset arrays	
	aoffs = [acen]
	zoffs = [zcen]
	
	makejigglepts, size, pts, aoffs, zoffs, step

	; compute plot size
	asize = [-size/2.0 - throw, size/2.0 + throw]
	zsize = 1.2 * asize + zcen
	asize = 1.2 * asize + acen

	PLOT, aoffs, -zoffs, XRANGE = asize, YRANGE = zsize, $
		XSTYLE = 1, YSTYLE = 1, TITLE = 'JiggleMap of Five Points Coverage', $
		XTITLE = 'Azimuth', YTITLE = 'Elevation', PSYM = -7

	; Plot Five Point points around aoffs & zoffs
	npts = N_ELEMENTS(aoffs)
	FOR i = 0, npts - 1 DO BEGIN
		tempa = aoffs[i] + [0	,-throw	, throw	, 0	, 0	]
		tempz = zoffs[i] + [0	, 0	, 0 	, throw	,-throw	]
		FOR j = 0, 4 DO BEGIN
			XYOUTS, tempa[j], -tempz[j], STRING(j+1, FORMAT = '(I0)'), $
				CHARSIZE = 1.5, ALIGNMENT = 0.5
		ENDFOR
	ENDFOR

	npts = N_ELEMENTS(aoffs)
	XYOUTS, aoffs[0], -zoffs[0], 'START', CHARSIZE = 2, ALIGNMENT = 0.5
	XYOUTS, aoffs[npts-1], -zoffs[npts-1], 'END', CHARSIZE = 2, ALIGNMENT = 0.5

	PRINT, 'This ', pts, ' x', pts, ' map of five points will take ', $
		npts*5*(t_int+17.), ' seconds to make'

END
