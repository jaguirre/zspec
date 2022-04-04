pro find_observations, dir, obsmin = obsmin, obssamp = obssamp, $
                       min_min = min_min

;dir = '/home/zspec/data/cso_test/20050525/plog'

; Walk through a bunch of PLOG files in order, finding when
; observations occurred.

; Grab all files in the given dir.  Need to add error checking for
; various fault conditions, including finding no files.
files = file_search(dir+'/*plog.bin')
nfiles = n_e(files)

; Sort them by minute.  This is made possible (and easy) by a standard
; naming convention, together with the fact that each directory will
; only contain minutes 0 - 1439.  The next day will be in a different
; directory.

; Need a standard filename parser ...
min = lonarr(nfiles)
for i = 0,nfiles-1 do begin
; First, gotta strip off the directory
    filename = strsplit(files[i],'/',/extract)
    filename = filename[n_e(filename)-1]
    min[i] = (strsplit(filename,'_',/extract))[1]
endfor

if (keyword_set(min_min)) then begin

    wh = where(min ge min_min)
    min = min[wh]
    files = files[wh]
    nfiles = n_e(wh)
    
endif

sortmin = sort(min)

files = files[sortmin]

obsnum = 0

; For now, using minute and sample, but eventually just need UTC
obsmin_begin = 0
obsmin_end = 0
obssamp_begin = 0
obssamp_end = 0

for i=0,nfiles-1 do begin

    obsflag = (read_plog(files[i])).observing

    whobs = where(obsflag eq 1)
; If we are actually observing ... (and cut out any short glitches in
; the signal, which, irritatingly, happen)
    if (whobs[0] ne -1 and total(obsflag) gt 1) then begin
; See whether the flag makes a transition
        trans = find_transitions(obsflag, fin_diff = fin_diff)

        for k=0,n_e(trans.rise)-1 do begin
            if (trans.rise[k] ne 0) then begin
                obsmin_begin = [obsmin_begin, min[i]]
                obssamp_begin = [obssamp_begin, trans.rise[k]]
            endif
        endfor
            
        for k=0,n_e(trans.fall)-1 do begin
            if (trans.fall[k] ne 0) then begin
                obsmin_end = [obsmin_end, min[i]]
                obssamp_end = [obssamp_end, trans.fall[k]]
            endif
        endfor     
        
    endif
    
endfor

obsmin_begin = obsmin_begin[1:*]
obsmin_end = obsmin_end[1:*]
obssamp_begin = obssamp_begin[1:*]
obssamp_end = obssamp_end[1:*]

if ( (n_e(obsmin_begin) ne n_e(obsmin_end)) or $
     (n_e(obssamp_begin) ne n_e(obssamp_end))) then begin
    message,/info,'Not an even number of starts and ends.'

    if (n_e(obsmin_end) gt n_e(obsmin_begin)) then begin
; Throw away the *first end*
        obsmin_end = obsmin_end[1:n_e(obsmin_end)-1]
        obssamp_end = obssamp_end[1:n_e(obssamp_end)-1]
    endif else begin
; Throw away the *last* beginning
        obsmin_begin = obsmin_begin[0:n_e(obsmin_begin)-2]
        obssamp_begin = obssamp_begin[0:n_e(obssamp_begin)-2]
    endelse

endif

obsmin = [[obsmin_begin], [obsmin_end]]
obssamp = [[obssamp_begin], [obssamp_end]]

end
