; makenposswitch.pro - this program generates a complete UIP macro of nswitch beam switches

pro makenposswitch
	nswitch	= 5		; number of cycles
	throw   = 30		; postition switch throw
	t_int 	= 3		; integration time per pointing

	filedir = !ZSPEC_PIPELINE_ROOT + PATH_SEP() + $
		  'macros' + PATH_SEP() + 'posswitch'
	filename = 'pswitchcycle' + STRING(nswitch, FORMAT = '(I0)') + 'for' + $
			STRING(throw, FORMAT = '(I0)') + 'as' + $
			STRING(t_int, FORMAT = '(I0)') + 's.mac'
	
	fullfile = filedir + PATH_SEP() + filename
	filenum = 1
	
	OPENW, filenum, fullfile

	header = STRING(nswitch, FORMAT = '(I0)') + ' Position Switch cycles'
	header = header + ' -  Throw = ' + STRING(throw, FORMAT = '(F0.1)') + ' arcsec'
	header = header + ' -  Integration = ' + STRING(t_int, FORMAT = '(F0.1)') + ' sec'

	PRINTF, filenum, 'C UIP Macro made with uipmacromaker.prj'
	uipcomment, filenum, header
	obsstart, filenum
	pswitchtime = 4.*t_int		;approximately correct
	FOR i = 0, nswitch -1 DO BEGIN
			uipcomment, filenum, i_of_n('Position Switch Cycle', i+1, nswitch, $
					'Observation', pswitchtime,'seconds')
		posswitch, filenum, throw, t_int
	ENDFOR
	obsend, filenum

	CLOSE, filenum
END
