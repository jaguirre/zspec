; Probably somebody already wrote this, but let's plow through ...

mbfits_dir = '/home/local/zspec/mbfits/'
apexnc_dir = '/home/local/zspec/apexnc/'

files = file_search(mbfits_dir+'APEX-?????-2012-*',/test_directory,$
                    count = nfiles)

for i = 358,nfiles-1 do begin
    
    spawn,'confirm_nonempty_fits.py '+files[i]+'> '+mbfits_dir+'test_empty'
; Check if the file was empty
    openr,lun,mbfits_dir+'test_empty',/get_lun
    scan = ''
    subscans = ''
; If confirm_nonempty_fits kicks back an error, you won't get anything
; in the test_empty file
    if (~(eof(lun))) then begin
        readf,lun,scan
        print,scan
        readf,lun,subscans
        print,subscans
        close,lun
        free_lun,lun
        nsubscans = strsplit(subscans,': ',/ext)
        if (long(nsubscans[n_e(nsubscans)-1]) gt 1) then begin
            spawn,'convert_fits_netcdf.py '+files[i]+' '+apexnc_dir
        endif
    endif else begin
        print,'Moving a bad file'
        spawn,'mv '+files[i]+' '+mbfits_dir+'/bad'
    endelse
endfor

end
