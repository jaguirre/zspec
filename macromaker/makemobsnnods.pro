; makemobsnnods.pro - this program generates a complete UIP macro of 
; mobs total observations consisting of nnods nods each.

pro makemobsnnods
	mobs = 2		;Number of observations
	nnods =	5		;Number of nods per observation
	t_int = 20.		;Integration time per nod position

	ifor = '(I0)'

	filedir = !ZSPEC_PIPELINE_ROOT + PATH_SEP() + $
		  'macros' + PATH_SEP() + 'nodding'
	filename = 'obsnods' + STRING(mobs, F = ifor) + 'of' + $
			STRING(nnods, F = ifor) + 'for' + $
			STRING(t_int, F = ifor) + 's.mac'
	
	fullfile = filedir + PATH_SEP() + filename
	filenum = 1
	
	OPENW, filenum, fullfile

	header = STRING(mobs, F = ifor) + ' Observations of '
	header = header + STRING(nnods, F = ifor) + ' nod cycles each'
	header = header + ' -  Nod Integration = ' + $
			STRING(t_int, FORMAT = '(F0.1)') + ' sec'

	macrostart, filenum, header

	nodtime = 4*t_int	  	; Approximately Correct
	obstime = nnods * nodtime 
	FOR j = 0, mobs - 1 DO BEGIN
		uipcomment, filenum, i_of_n('Observation', j+1, mobs, $
					'Macro', obstime/60.,'minutes')
 		obsstart, filenum
		FOR i = 0, nnods - 1 DO BEGIN
			uipcomment, filenum, i_of_n('Nod', i+1, nnods, $
					'Observation', nodtime/60.,'minutes')
			nodsequence, filenum, t_int
		ENDFOR
		obsend, filenum
	ENDFOR

	CLOSE, filenum
END
