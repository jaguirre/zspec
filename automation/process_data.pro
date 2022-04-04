pro process_data, date, plot = plot, obsnum_start = obsnum_start

date = strcompress(date,/rem)

keep_going = 1

if (keyword_set(obsnum_start)) then obsnum = obsnum_start else obsnum = 0

; Default behavior
new = 0
onebze = 1

ncdfdir = getenv('HOME')+'/data/observations/ncdf/'+date+'/'
bzedir = getenv('HOME')+'/data/observations/bze/'+date+'/'

while (keep_going) do begin

    next_obs_file = ncdfdir+make_padded_num_str(obsnum,3)+'_obs_def.txt'
    message,/info,'Looking for observation '+strcompress(obsnum,/rem)
    message,/info,'in '+next_obs_file

    if ((file_search(next_obs_file))[0] ne '') then begin
        
; Found the obs def.  That means PLOG is in place.  Make sure that BZE is also
; there.  Read the obs def to find the BZE file.

        obsnum_file = 0L
        obsmin = lonarr(2)
        obssamp = lonarr(2)
        utc = dblarr(2)

        openr,lun,next_obs_file,/get_lun
        readf,lun,obsnum_file,format='(I10)'
        readf,lun,obsmin,format='(2I10)'
        readf,lun,obssamp,format='(2I10)'
        readf,lun,utc,format='(2D10.2)'
        close,lun
        free_lun,lun

        found_bzefile = 0
        bzefile = bzedir + '/' + date + '_'+$
          make_padded_num_str(obsmin[0],4)+'_bze.bin'
        if (file_search(bzefile) ne '') then begin 
            found_bzefile = 1 
        endif else begin
; Search nearby minutes to fix that stupid problem
            trymin = obsmin[0]+1
            bzefile_wrong = bzedir + '/' + date + '_'+$
              make_padded_num_str(trymin,4)+'_bze.bin'
            if (file_search(bzefile_wrong) ne '') then begin 
                message,/info,'BZE file has wrong name.  Changing.'
                found_bzefile = 1
                spawn,'mv '+bzefile_wrong+' '+bzefile
            endif
            trymin = obsmin[0]-1
            bzefile_wrong = bzedir + '/' + date + '_'+$
              make_padded_num_str(trymin,4)+'_bze.bin'
            if (file_search(bzefile_wrong) ne '') then begin 
                message,/info,'BZE file has wrong name.  Changing.'
                found_bzefile = 1
                spawn,'mv '+bzefile_wrong+' '+bzefile
            endif
        endelse
        
        if (found_bzefile) then begin
            message,/info,'Found BZE file.'
            message,/info,'Maligning observation '+strcompress(obsnum,/rem)
            
            maligns, date, obsnum, new = new, onebze = onebze
            ncdffile = ncdfdir + '/' + date + '_'+$
              make_padded_num_str(obsnum,3)+'.nc'
            message,/info,'Running npt_obs.'
            npt_obs,ncdffile

            obsnum = obsnum + 1
            
        endif 

    endif else begin
            
        message,/info,'No new files.  Waiting 10 seconds.'
        message,/info, 'Current observation is '+strcompress(obsnum,/rem)
        wait,10
        
    endelse

    message,/info,'Waiting 10 seconds.'
    message,/info, 'Current observation is '+strcompress(obsnum,/rem)
    wait,10

endwhile

end
