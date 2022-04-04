; makemap5ptobs.pro - creates a complete mapping of 5 points UIP macro

PRO makemap5ptobs
	size = 30	; Overall Size of map in arcsec
	points = 3	; Number of points in one dimension of map	
	aoff = 0	; Center of map
	zoff = 0
	throw = 22.5	; Five point throw	
	inttime = 5	; Integration Time Per Nod

	ptsstring = STRING(points, FORMAT = '(I0)')

	filedir = !ZSPEC_PIPELINE_ROOT + PATH_SEP() + $
		  'macros' + PATH_SEP() + 'jiggle5pt'
	filename = 'jiggle5ptmap' + STRING(size, FORMAT = '(I0)') + 'as' + $
			ptsstring + 'x' + ptsstring + STRING(throw, FORMAT = '(I0)') + 'as.mac'
	
	fullfile = filedir + PATH_SEP() + filename
	filenum = 1
	
	OPENW, filenum, fullfile

	header = 'Jiggle Map of Five Point Observations'
	header = header + ' - Throw = ' + STRING(throw, FORMAT = '(F0.1)') + ' arcsec'
	header = header + ' - ' + 'Nod Integration = ' + STRING(inttime, FORMAT = '(I0)') + ' sec'

	macrostart, filenum, header
	obsstart, filenum
	jigglemap5ptmac, filenum, size, points, aoff, zoff, throw, inttime
	obsend, filenum

	CLOSE, filenum
END
