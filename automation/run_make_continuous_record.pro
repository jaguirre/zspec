files = [$
;          file_search(!zspec_data_root+'/plog/2007????',/test_directory),$
;          file_search(!zspec_data_root+'/plog/2008????',/test_directory),$
;          file_search(!zspec_data_root+'/plog/2009????',/test_directory),$
          file_search(!zspec_data_root+'/plog/2010????',/test_directory)]

nnights = n_e(files)
nights = strarr(nnights)

openw,lun,'continuous_record_log.txt',/get_lun

for i = 0,nnights-1 do begin
    
    temp = strsplit(files[i],'/',/extract)
    nights[i] = temp[n_e(temp)-1]
    
    str = 'Making record for night '+nights[i]
    print,str
    printf,lun,str

    ncdfdir = !zspec_data_root+'/ncdf/'+nights[i]+'/'
; If the ncdf directory doesn't exist make it
    if file_search(ncdfdir) eq '' then $
      spawn,'mkdir '+ncdfdir
;    if (file_search(ncdfdir+'plog'+nights[i]+'.sav') eq '' or $
;        file_search(ncdfdir+'rpc'+nights[i]+'.sav') eq '') then begin
        
        str = 'No files found for night '+nights[i]+$
          '. Making continuous record.'
        
        print,str
        printf,lun,str

        make_continuous_record,nights[i],lun = lun
        
;    endif else begin
;        
;        str = 'Continuous record files for night '+nights[i]+$
;          ' already exist.  Not overwriting.'
;        
;        print,str
;        printf,lun,str 
;        
;    endelse

endfor

close,lun
free_lun,lun

end
