;________________________________________________________________
;modified 2007-04-03 LE
;
;If the date doesn't correspond with the Engineering Run it
;will set the keyword /one in maligns (i.e. assume there is one
;bze file for each observation.
;
;It will also automatically check for and gunzip any zipped files as
;needed.
;
;Use optional keyword obsnum_end to make it stop looking for observations
;beyond that number.
;________________________________________________________________


pro run_maligns, date, plot = plot, obsnum_start = obsnum_start,$
                 obsnum_end = obsnum_end, $
                 skip_missing_bze = skip_missing_bze

if keyword_set(obsnum_end) then obs_end=obsnum_end else obs_end=999

date = strcompress(date,/rem)

keep_going = 1

if ~keyword_set(obsnum_start) then obsnum_start=0
obsnum=obsnum_start

new=0
one=0

case date of
    '20050603': new = 0
    '20050604': new = 0
    '20050605': new = 0
    '20050606': new = 0
    '20050607': new = 1
    '20050608': new = 1
    '20050609': new = 1
    '20050610': new = 1
    '20050613': new = 1
    else : one=1
endcase

;message,/info,'Variable new set to '+strcompress(new,/rem)

ncdfdir = !ZSPEC_DATA_ROOT + '/ncdf/'+date+'/'

;_______________________________________________________________________
;if files are gzipped we need to gunzip them first
;if we are run_maligning less than the whole night's worth of
;observations, then this part is skipped because maligns will gunzip
;individual files as necessary.

if ~keyword_set(obsnum_start) and ~keyword_set(obsnum_end) then begin

print,'Checking for (and gunzipping) any gzipped files.'
print,'This may take a few minutes.....'
spawn,'gunzip '+!ZSPEC_DATA_ROOT + '/ncdf/'+date+'/*.gz'
spawn,'gunzip '+!ZSPEC_DATA_ROOT + '/bze/'+date+'/*.gz'
spawn,'gunzip '+!ZSPEC_DATA_ROOT + '/plog/'+date+'/*.gz'
spawn,'gunzip '+!ZSPEC_DATA_ROOT + '/rpc/'+date+'/*.gz'

endif
;_______________________________________________________________________

while (keep_going) do begin

    print,'Looking for observation '+strcompress(obsnum,/rem)
    next_obs_file = ncdfdir+make_padded_num_str(obsnum,3)+'_obs_def.txt'

    if ((file_search(next_obs_file))[0] ne '') then begin
        
; Because of the at-telescope shuffling between wakea and kilauea, the obs_def
; file can show up before bze.bin file.  So let's account for that.

; Read the obs_def file
        year = long(strmid(date,0,4))
        month = long(strmid(date,4,2))
        night = long(strmid(date,6,2))
        obsdef = read_obsdef(year, month, night, obsnum)
        
; Check to see if the bze file is there, unless explicitly to not to
        if ~keyword_set(skip_missing_bze) then begin
            bze_min = obsdef.min[0]
            srch = 0
            bze_found = 0
            while(srch le 3 and ~bze_found) do begin
                bze_min_str = string(bze_min,format='(I04)')
                bze_file = !ZSPEC_DATA_ROOT+'/bze/'+date+'/'+date+'_'+$
                  bze_min_str+'_bze.bin'
                bze_test = file_search(bze_file)
                if (bze_test ne '') then begin
                    print,'Found '+bze_file
                    bze_found = 1
                endif else begin
                    ++srch
                    bze_min -= srch
                endelse
            endwhile
; Just assume it's there.  maligns will complain if it's not
        endif else begin
            bze_found = 1
        endelse

        if (bze_found) then begin

            print,'Maligning observation '+strcompress(obsnum,/rem)
            maligns, date, obsnum, new = new, plot = plot, onebze=one
            
            if obsnum eq obs_end then begin
                print,'Maligned observations '+$
                  strcompress(obsnum_start,/rem)+$
                  ' through '+strcompress(obsnum,/rem)+'.'
                keep_going=0  
            endif    

            obsnum = obsnum + 1

        endif else begin

            message,/info,$
              'Found obsdef file but no bze.bin for observation ' + $
              strcompress(obsnum,/rem) +'.'  
            message,/info,'Waiting 10 seconds.'
            wait,10
            
        endelse
        
    endif else begin
        
        message,/info,'No new files.  Waiting 10 seconds.'
        message,/info, 'Current observation is '+strcompress(obsnum,/rem)
        wait,10
        
    endelse
    
endwhile

end
