pro run_slice_observations, date, obsnum_start = obsnum_start, min_min=min_min

date = strcompress(date,/rem)

; Use standard naming convention.  Saves typing.
plogdir = !zspec_data_root+'/plog/'+date
ncdfdir = !zspec_data_root+'/ncdf/'+date


; Find out how many files there are in dir
files = file_search(plogdir+'/*plog.bin')

; Always look for the lock file
lock_file = file_search(plogdir+'/*plog.lck')
if (lock_file[0] ne '') then begin
    lock_file = strmid(lock_file[0],0,strlen(lock_file)-4)+'.bin'
    whnotlocked = where(files ne lock_file)
    if (whnotlocked[0] ne -1) then begin
        files = files[whnotlocked]
    endif else begin
        files[0] = ''
    endelse
endif

nfiles = n_e(files)
if (nfiles eq 1 and files[0] eq '') then begin
    message,'No PLOG files found in directory '+plogdir
endif

;____________________________________________________________
;find out how bze files are in the directory
;bze_files=file_search(bzedir+'/*_bze.bin')
;nbze=n_e(bze_files)
;____________________________________________________________

keep_going = 1

nfiles_last = -1

if not(keyword_set(min_min)) then min_min = 1

obsnum = 0

while(keep_going) do begin

 ; If we have any new files, let's search them for observations
    if (nfiles gt nfiles_last) then begin

        message,/info,'Found new files; searching for observations'
        
        slice_observations, plogdir, date, $
          obsmin = obsmin, obssamp = obssamp, min_min = min_min, $
          utcmin = utcmin, utcmax = utcmax
; -----------------------------------------------------------------------
; This section added JA 2010/05/02
; Occasionally we get this weird-ass thing where it keeps re-finding
; the observations back to the beginning.  So let's disallow this.
       ;help,obsmin
        ;print,obsmin
        ;print,obssamp
        

        whnext = where(obsmin[*,0] ge min_min)
; If there aren't any observations with numbers greater than the
; previous one, so indicate
;obs_def files get screwed up *** RL 2010/05/11 
;;ooh, you need to fix obssamp, too! darn, JA!
        if whnext[0] eq -1 then begin
            obsmin[0,0]=-1
        endif else begin
            obsmin = obsmin[whnext,*] 
            obssamp = obssamp[whnext,*]
        endelse
; Now remove anybody whose start and end minutes are the same
; Shit.  This can sometimes happen and be legitimate.
if (0) then begin
;print,min_min
;print,whnext
        n_obs = n_e(obsmin[*,0])
        for i=0,n_obs-1 do begin
            if (obsmin[i,0] eq obsmin[i,1]) then obsmin[i,0] = -1
        endfor
        whnodup = where(obsmin[*,0] ne -1)
        if whnodup[0] ne -1 then begin
        obsmin = obsmin[whnodup,*] 
        obssamp = obssamp[whnodup,*] 
        endif else obsmin[0,0] = -1
endif
        ;help,obsmin
        ;print,obsmin
        ;print,obssamp
; -----------------------------------------------------------------------

        if (obsmin[0,0] ne -1) then begin

; Write out any new observations which were found

            nobs_found = n_e(obsmin[*,0])
            
            message,/info,'Found '+strcompress(nobs_found,/rem)+$
              ' new observations.'

            for i=0,nobs_found-1 do begin

; It could be that some observations in a multi-observation list are
; screwed up, so we need to check
                if (obsmin[i,0] ne -1) then begin

                    message,/info,'Writing information for observation '+$
                      strcompress(obsnum,/rem)
                    obstr = make_obsnum_str(obsnum)
                    openw,lun,ncdfdir+'/'+obstr+'_obs_def.txt',/get_lun
                    printf,lun,obsnum,format='(I10)'
                    printf,lun,obsmin[i,*],format='(2I10)'
                    printf,lun,obssamp[i,*],format='(2I10)'
                    printf,lun,utcmin[i],utcmax[i],$
                      format = '(2D10.2)'
                    close,lun
                    free_lun,lun

; Increment the observation number
                    obsnum = obsnum + 1

                endif

            endfor
    
            min_min = (obsmin[nobs_found-1,1])[0]
            help,min_min
        endif

    endif else begin

        message,/info,'No new files.  Waiting 10 seconds.'
        message,/info,'Current observation is '+strcompress(obsnum,/rem)
        wait,10

    endelse

    nfiles_last = nfiles
    files = file_search(plogdir+'/*plog.bin')

; Always look for the lock file
    lock_file = file_search(plogdir+'/*plog.lck')
    if (lock_file[0] ne '') then begin
        lock_file = strmid(lock_file[0],0,strlen(lock_file)-4)+'.bin'
        whnotlocked = where(files ne lock_file)
        if (whnotlocked[0] ne -1) then begin
            files = files[whnotlocked]
        endif else begin
            files[0] = ''
        endelse
    endif

    nfiles = n_e(files)
    if (files[0] eq '') then nfiles = 0

    if ((file_search(plogdir+'/stop'))[0] ne '') then keep_going = 0

endwhile

end
