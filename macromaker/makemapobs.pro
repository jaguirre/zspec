; makemapobs.pro - creates a complete mapping UIP macro

PRO makemapobs
	size = 120	; Overall Size of map in arcsec
	points = 13	; Number of points in one dimension of map	
	aoff = 0	; Center of map
	zoff = 0
	t_int = 5	; Integration Time Per Nod

	ptsstring = STRING(points, FORMAT = '(I0)')

	filedir = !ZSPEC_PIPELINE_ROOT + PATH_SEP() + $
		  'macros' + PATH_SEP() + 'jiggle'
	filename = 'jigglemap' + STRING(size, FORMAT = '(I0)') + 'as' + $
			ptsstring + "x" + ptsstring + '.mac'
	
	fullfile = filedir + PATH_SEP() + filename
	filenum = 1
	
	OPENW, filenum, fullfile

	header = 'Jiggle Map Observation'
	header = header + ' - ' + 'Nod Integration = ' + STRING(t_int, FORMAT = '(I0)') + ' sec'

	macrostart, filenum, header
	obsstart, filenum
	jigglemapmac, filenum, size, points, aoff, zoff, t_int
	obsend, filenum

	CLOSE, filenum
END
