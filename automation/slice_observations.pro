pro slice_observations, dir, date, obsmin = obsmin, obssamp = obssamp, $
                        min_min = min_min, utcmin = utcmin, utcmax = utcmax, $
                        plot = plot, debug = debug

; Walk through a bunch of PLOG files in order, finding when
; observations occurred.

; Grab all files in the given dir.  Need to add error checking for
; various fault conditions, including finding no files.
files = file_search(dir+'/*plog.bin')

; Always look for the lock file
lock_file = file_search(dir+'/*plog.lck')
if (lock_file[0] ne '') then begin
    lock_file = strmid(lock_file[0],0,strlen(lock_file[0])-4)+'.bin'
    message,/info,'Excluding '+lock_file[0]+' because it is locked.'
    whnotlocked = where(files ne lock_file[0])
    if (whnotlocked[0] ne -1) then begin
        files = files[whnotlocked]
    endif else begin
        files[0] = ''
    endelse
endif

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

; For now, using minute and sample, but eventually just need UTC
obsmin_begin = 0
obsmin_end = 0
obssamp_begin = 0
obssamp_end = 0
fin=0
for i=0,nfiles-1 do begin

    message,/info,'Reading PLOG file '+files[i]
    obsflag = (read_plog(files[i])).observing
    obsticks = (read_plog(files[i])).ticks
nflg=n_elements(obsflag)
; Slicer doesn't deal well with the observing flag having been on to start
    if (date eq '20071122' and min[i] eq 341) then begin
        obsflag[0:5000] = 0
    endif

    whobs = where(obsflag eq 1)
; If we are actually observing ... (and cut out any short glitches in
; the signal, which, irritatingly, happen)
    if (whobs[0] ne -1 and total(obsflag) gt 1) then begin

; See whether the flag makes a transition
        trans = find_transitions(obsflag, fin_diff = fin_diff, thresh=0.5)
        ;added RL 2010/05/11
        ;somehow there are some glitches in the plog files that make the time record be 0
        ;find glitches
        glix=find_transitions(obsticks, fin_diff = fin_diff, thresh=0.1)

;        help,trans,/str

        for k=0,n_e(trans.rise)-1 do begin
        whglix=where(glix.rise eq trans.rise[k])
            if ((trans.rise[k] ne 0) and (whglix[0] eq -1)) then begin
                obsmin_begin = [obsmin_begin, min[i]]
                obssamp_begin = [obssamp_begin, trans.rise[k]]
            endif
        endfor
        for k=0,n_e(trans.fall)-1 do begin
        whglix=where(glix.fall eq trans.fall[k])
            if ((trans.fall[k] ne 0) and (whglix[0] eq -1)) then begin
                obsmin_end = [obsmin_end, min[i]]
                obssamp_end = [obssamp_end, trans.fall[k]]
            endif
        endfor     
        
    endif
;print,fin,obsflag[0],min[i]
;;added RL 2010/05/01
;;make it find obs that begin or end at the very start or end of the file
;this instroduces some bug that JA fixed in run_slice_observations
;now I know why... it keeps reading the last file! Let's fix that.
if ((fin eq 0) and (obsflag[0] eq 1) and (i ne 0)) then begin
                obsmin_begin = [obsmin_begin, min[i]]
                obssamp_begin = [obssamp_begin, 0]
endif
if ((fin eq 1) and (obsflag[0] eq 0)) then begin
                obsmin_end = [obsmin_end, min[i-1]]
                obssamp_end = [obssamp_end, nflg-1]
endif          
if ((obsflag[1] eq 1) and (obsflag[0] eq 0)) then begin
                obsmin_begin = [obsmin_begin, min[i]]
                obssamp_begin = [obssamp_begin, 0]
endif
if ((obsflag[0] eq 1) and (obsflag[1] eq 0)) then begin
                obsmin_end = [obsmin_end, min[i]]
                obssamp_end = [obssamp_end, 1]
endif          


    if (keyword_set(debug)) then begin
        plot,obsflag,/yst,yr=[-.2,1.2]
        print,trans.rise
        print,trans.fall
        print
        print,obsmin_begin
        print,obsmin_end
        
        blah = ''
        read,blah
    endif 
fin=obsflag[nflg-1]
endfor

; Minute zero fucks things up, and I don't know why it's getting in.
; JA 2010/05/02
; Just cut it out
;whnonzero = where(obsmin_begin ne 0)
;if (whnonzero[0] ne -1) then begin
;    obsmin_begin = obsmin_begin[whnonzero]
;endif
;whnonzero = where(obsmin_end ne 0)
;if (whnonzero[0] ne -1) then begin
;    obsmin_end = obsmin_end[whnonzero]
;endif

print,obsmin_begin
print,obsmin_end

if (n_e(obsmin_begin[*,0]) eq 1) then begin
; Didn't find any new beginnings
    obsmin_begin=[-1]
    obssamp_begin = [-1]
endif else begin
    obsmin_begin = obsmin_begin[1:*]
    obssamp_begin = obssamp_begin[1:*]
endelse

if (n_e(obsmin_end[*,0]) eq 1) then begin
; Didn't find any new ends
    obsmin_end=[-1]
    obssamp_end = [-1]
endif else begin
    obsmin_end = obsmin_end[1:*]
    obssamp_end = obssamp_end[1:*]
endelse

;stop

if (date eq '20070106' and obsmin_begin[0] eq 274 and obsmin_end[0] eq 274) then begin
    obsmin_end = obsmin_end[1:*]
    obssamp_end = obssamp_end[1:*]
endif

if ( ((n_e(obsmin_begin) ne n_e(obsmin_end)) or $
     (n_e(obssamp_begin) ne n_e(obssamp_end))) ) then begin

    message,/info,'Not an even number of starts and ends.'

    if (n_e(obsmin_end) gt n_e(obsmin_begin) and $
       n_e(obsmin_end) gt 1) then begin
; Throw away the *first* end if you can
        message,/info,'Discarding first end transition.'
        obsmin_end = obsmin_end[1:n_e(obsmin_end)-1]
        obssamp_end = obssamp_end[1:n_e(obssamp_end)-1]
    endif else begin
        if (n_e(obsmin_begin) gt 1) then begin
; Throw away the *last* beginning
            message,/info,'Discarding last start transition.'
            obsmin_begin = obsmin_begin[0:n_e(obsmin_begin)-2]
            obssamp_begin = obssamp_begin[0:n_e(obssamp_begin)-2]
        endif
    endelse

endif

; Check that there is a continuous period of observing between
; transitions, and that obsmin_begin is less than obsmin_end.

utcmin = dblarr(n_e(obsmin_begin))
utcmax = dblarr(n_e(obsmin_begin))

for i=0,n_e(obsmin_begin)-1 do begin
    
    plog_files = ['']
    observing = [0]
    ticks = [0]

    min = obsmin_begin[i]
    
    nfiles_obs = obsmin_end[i]-obsmin_begin[i]+1
    if (nfiles_obs gt 0) then begin
        nticks = lonarr(nfiles_obs)
    endif  else begin
        nticks = lonarr(1)
        nfiles_obs = 0
    endelse
    
; We need the index of the start, and the index of the end.  The fact that we
; check every intervening minute prevents getting misleading data from a
; dropout.
    missing_data = 0

    for j = 0L,nfiles_obs-1 do begin
        
        newfile = dir+'/'+date+'_'+make_padded_num_str(min,4)+'_plog.bin'
        if ((file_search(newfile))[0] eq '') then begin
; Drop out of the loop, and set this observation as bad
            missing_data = 1
        endif else begin

            plog_files = [plog_files,newfile]
            
            obs = (read_plog(newfile)).observing
            nticks[j] = n_e(obs)
            
            observing = [observing,obs]
            ticks = [ticks,(read_plog(newfile)).ticks]
            
            min = min + 1
        
        endelse    
    endfor
        
    if ((n_e(observing) eq 1) or (missing_data eq 1) or $
        (obsmin_begin[i] gt obsmin_end[i])) then begin

        obsmin_begin[i] = -1
        obsmin_end[i] = -1

    endif 

    if (obsmin_begin[i] ne -1 ) then begin
        
        observing = observing[1:*]
        ticks = ticks[1:*]
        
        utcmin[i] = ticks[obssamp_begin[i]]
        if (nfiles_obs eq 1) then begin
            offset = 0
        endif else begin
            offset = total(nticks[0:nfiles_obs-2]) 
        endelse
        utcmax[i] = ticks[offset+obssamp_end[i]]
        
        if (utcmax[i] lt utcmin[i]) then begin

            obsmin_begin[i] = -1
            obsmin_end[i] = -1

        endif

        if (keyword_set(plot)) then begin
        
            plot,ticks,observing,/yst,yr=[-.2,1.2]
            oplot,[1,1]*utcmin[i],[-1,0.5],col=2,line=2
            oplot,[1,1]*utcmax[i],[-1,0.5],col=2,line=2
            
            blah = ''
            read, blah
            
        endif

    endif
    
endfor

    
obsmin = [[obsmin_begin], [obsmin_end]]
obssamp = [[obssamp_begin], [obssamp_end]]

;stop

end
