; makennods.pro - this program generates a complete UIP macro of nnods nods

pro makennods
	nnods = 5
	t_int 	= 20.5

	filedir = !ZSPEC_PIPELINE_ROOT + PATH_SEP() + $
		  'macros' + PATH_SEP() + 'nodding'
	filename = 'nodcycle' + STRING(nnods, FORMAT = '(I0)') + 'for' + $
			STRING(t_int, FORMAT = '(I0)') + 's.mac'
	
	fullfile = filedir + PATH_SEP() + filename
	filenum = 1
	
	OPENW, filenum, fullfile

	header = STRING(nnods, FORMAT = '(I0)') + ' Chop & Nod cycles'
	header = header + ' -  Nod Integration = ' + STRING(t_int, FORMAT = '(F0.1)') + ' sec'

	macrostart, filenum, header
	obsstart, filenum
	nodtime = 4.*t_int		;approximately correct
	FOR i = 0, nnods -1 DO BEGIN
			uipcomment, filenum, i_of_n('Nod', i+1, nnods, $
					'Observation', nodtime/60.,'minutes')
		nodsequence, filenum, t_int
	ENDFOR
	obsend, filenum

	CLOSE, filenum
END
