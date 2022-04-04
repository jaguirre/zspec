; make5ptobs.pro - creates a complete five point UIP macro

PRO make5ptobs
	throw = 18
	t_int = 15
	aoff = 0
	zoff = 0

	filedir = !ZSPEC_PIPELINE_ROOT + PATH_SEP() + $
		  'macros' + PATH_SEP() + 'fivepoint'
	filename = 'fivepoint' + STRING(throw, FORMAT = '(I0)') + 'as' + $
			STRING(t_int, FORMAT = '(I0)') + 's.mac'
	
	fullfile = filedir + PATH_SEP() + filename
	filenum = 1
	
	OPENW, filenum, fullfile

	header = 'Single Five Point Observation'
	header = header + ' - Throw = ' + STRING(throw, FORMAT = '(F0.1)') + ' arcsec'
	header = header + ', Nod Integration = ' + STRING(t_int, FORMAT = '(I0)') + ' sec'

	macrostart, filenum, header
	obsstart, filenum
	fivepointmac, filenum, throw, aoff, zoff, t_int
	obsend, filenum

	CLOSE, filenum
END
