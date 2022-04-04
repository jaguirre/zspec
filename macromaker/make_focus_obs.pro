; Make a UIP focus macro

PRO make_focus_obs, filename, offsets_in, t_int, orig_offset

filedir = !ZSPEC_PIPELINE_ROOT + PATH_SEP() + $
  'macros' 
; + PATH_SEP() + 'fivepoint'
;	filename = 'fivepoint' + STRING(throw, FORMAT = '(I0)') + 'as' + $
;			STRING(t_int, FORMAT = '(I0)') + 's.mac'

fullfile = filedir + PATH_SEP() + filename
;filenum = 1

OPENW, filenum, fullfile, /get_lun

header = 'Focus Observation'
header = header + ', Nod Integration = ' + $
  STRING(t_int, FORMAT = '(I0)') + ' sec'

macrostart, filenum, header
obsstart, filenum

noffsets = n_e(offsets_in)

; Randomize the order of the input offsets
offsets = offsets_in
for shuffle=0,30 do begin
    i = long(randomu(seed,1)*noffsets)
    j = long(randomu(seed,1)*noffsets)
    temp = offsets[i]
    offsets[i] = offsets[j]
    offsets[j] = temp
endfor

mappttime = 4.*t_int+10.

for i = 0,noffsets-1 do begin

    uipcomment,filenum,i_of_n('Focus Offset ', i+1, noffsets, $
                                'Observation', mappttime/60., 'minutes')
    printf,filenum,'FOCUS /OFFSET '+string(offsets[i],format='(F0.2)')
    nodsequence,filenum, t_int
    
endfor

; Reset the focus offset back to the original value
uipcomment,filenum,'Reset focus offset to original value'
printf,filenum,'FOCUS /OFFSET '+string(orig_offset,format='(F0.2)')

obsend, filenum

CLOSE, filenum

free_lun,filenum

END
