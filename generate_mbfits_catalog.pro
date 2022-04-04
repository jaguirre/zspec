pro generate_mbfits_catalog, path = path,file=file

if ~keyword_set(path) then path = !zspec_data_root+'/mbfits'
if ~keyword_set(file) then file = 'mbfits_catalog'

mbfits_files = file_search(path+'/APEX-*',/test_directory, $
                           count=n_mbfits_files)

if n_mbfits_files eq 0 then stop

mbfits = replicate(create_struct('scannum',0L,$
                                 'filename',' ',$
                                 'source',' ',$
                                 'ra',0.d,$
                                 'dec',0.d,$
                                 'projid',' ',$
                                 'date_obs',' ',$
                                 'year',0L,$
                                 'month',0L,$
                                 'day',0L,$
                                 'lst',0.d,$
                                 'mjd',0.d,$
                                 'nsubs',0L,$
                                 'wobthrow',0.d,$
                                 'wobperiod',0.d),$
                   n_mbfits_files)
;                                 'hdr',strarr(150)),$

for i=0,n_mbfits_files-1 do begin

    print,i,n_mbfits_files-1,format='(I5," of ",I5)'

    temp = strsplit(mbfits_files[i],'-',/extract)
; Just easier this way
    year = temp[2]
    month= temp[3]
    day = temp[4]

    scanfile = mbfits_files[i]+'/SCAN.fits'
    if (file_search(scanfile) ne '') then begin
        rdfits_struct,mbfits_files[i]+'/SCAN.fits',d,/silent
        tags = tag_names(d)
        whtag = where(tags eq 'HDR1')
    endif else begin
        whtag=lonarr(1)
        whtag[0] = -1
    endelse

    if (whtag[0] ne -1) then begin
        hdr = d.hdr1
; Extract useful stuff, but just throw in the whole damn header for
; good measure
;        mbfits[i].hdr = hdr

        mbfits[i].scannum = sxpar(hdr,'SCANNUM')
        mbfits[i].filename = sxpar(hdr,'MBFITS')
        mbfits[i].source = sxpar(hdr,'OBJECT')
        mbfits[i].ra = sxpar(hdr,'CRVAL1')
        mbfits[i].dec = sxpar(hdr,'CRVAL2')
        mbfits[i].projid = sxpar(hdr,'PROJID')
        mbfits[i].date_obs = sxpar(hdr,'DATE-OBS')
        mbfits[i].year = year
        mbfits[i].month = month
        mbfits[i].day = day
        mbfits[i].lst= sxpar(hdr,'LST')
        mbfits[i].mjd = sxpar(hdr,'MJD')
        mbfits[i].nsubs = sxpar(hdr,'NSUBS')
        mbfits[i].wobthrow = sxpar(hdr,'WOBTHROW')
        mbfits[i].wobperiod = sxpar(hdr,'WOBCYCLE')

    endif else begin

        print,'BAD!!!'
        mbfits[i].source = 'BAD'

    endelse

;stop

end

srt = sort(mbfits.mjd)
mbfits = mbfits[srt]

openw,lun,path+'/'+file+'.txt',/get_lun
for i = 0,n_mbfits_files-1 do begin
    if (mbfits[i].source ne 'BAD' and mbfits[i].source ne '') then begin
        printf,lun,mbfits[i].source,'   ',mbfits[i].date_obs
    endif
endfor

close,lun

save,file=path+'/'+file+'.sav',mbfits

end
