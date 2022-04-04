pro summarize_coadd, file,lun=lun

; Plop out a couple of useful facts about a coadd
restore,file

;print,source_name
;print,'Hours observed '+string(total_n_sec/3600.,format='(F5.2)')
if keyword_set(lun) then begin
    printf,lun,ubername
    printf,lun,string(source_name,$
                 total_n_sec/3600.,' hrs ',$
                 total(obs_labels.nnods),' nods ',$
                 n_e(file_list),' files',$
                 format='(A-25,F5.2,A5,I4,A6,I4,A6)')
endif else begin
    print,ubername
    print,string(source_name,$
                 total_n_sec/3600.,' hrs ',$
                 total(obs_labels.nnods),' nods ',$
                 n_e(file_list),' files',$
                 format='(A-25,F5.2,A5,I4,A6,I4,A6)')
endelse
    
end
