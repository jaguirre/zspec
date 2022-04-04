; jigglemapvis.pro - this is a simple program that helps to 
; visualize jigglemap coverage.  It also calculates mapping
; time based on nod cycle = 4*t_int + 17 sec.

PRO jigglemapvis, size, pts, acen, zcen, t_int
	; Create offset arrays	
	aoffs = [acen]
	zoffs = [zcen]
	
	makejigglepts, size, pts, aoffs, zoffs, step

	; compute plot size
	asize = [-size/2.0, size/2.0]
	zsize = 1.2 * asize + zcen
	asize = 1.2 * asize + acen

	PLOT, aoffs, -zoffs, XRANGE = asize, YRANGE = zsize, $
		XSTYLE = 1, YSTYLE = 1, TITLE = 'JiggleMap Coverage', $
		XTITLE = 'Azimuth', YTITLE = 'Elevation', PSYM = -7, /ISOTROPIC

	npts = N_ELEMENTS(aoffs)
	XYOUTS, aoffs[0], -zoffs[0], 'START', CHARSIZE = 2, ALIGNMENT = 0.5
	XYOUTS, aoffs[npts-1], -zoffs[npts-1], 'END', CHARSIZE = 2, ALIGNMENT = 0.5

	npts = N_ELEMENTS(aoffs)
	PRINT, 'This ', pts, ' x', pts, ' map will take ', $
		npts*(t_int+17.), ' seconds to make'

END
