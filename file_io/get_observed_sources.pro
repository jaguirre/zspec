if (0) then begin

; Something is weird with the 20071114 folder ...
obs_def_files = $
  [file_search(!zspec_data_root+'/ncdf/20071117/*obs_def.txt'), $
   file_search(!zspec_data_root+'/ncdf/20071118/*obs_def.txt'), $
   file_search(!zspec_data_root+'/ncdf/20071119/*obs_def.txt'), $
   file_search(!zspec_data_root+'/ncdf/20071120/*obs_def.txt'), $
   file_search(!zspec_data_root+'/ncdf/20071121/*obs_def.txt'), $
   file_search(!zspec_data_root+'/ncdf/20071122/*obs_def.txt'), $
   file_search(!zspec_data_root+'/ncdf/20071123/*obs_def.txt'), $
   file_search(!zspec_data_root+'/ncdf/20071124/*obs_def.txt'), $
   file_search(!zspec_data_root+'/ncdf/20071125/*obs_def.txt'), $
   file_search(!zspec_data_root+'/ncdf/20071130/*obs_def.txt')  $
  ]

nfiles = n_e(obs_def_files)

date_list = strarr(nfiles)
obsnum_list = lonarr(nfiles)
source_list = strarr(nfiles)

for i=0,nfiles-1 do begin

    temp = strsplit(obs_def_files[i],'/',/extract)
    date = temp[n_e(temp)-2]
    year = long(strmid(date,0,4))
    month = long(strmid(date,4,2))
    night = long(strmid(date,6,2))
    obsnum = long((strsplit(temp[n_e(temp)-1],'_',/extract))[0])

    obsdef = read_obsdef(year, month, night, obsnum)

    rpcfile = !zspec_data_root+'/rpc/'+date+'/'+date+'_'+$
      make_padded_num_str(obsdef.min[0],4)+'_rpc.bin'

    rpc = read_rpc(rpcfile)

    date_list[i] = date
    obsnum_list[i] = obsnum
    source_list[i] = string(rpc[10].source_name)

endfor

endif

science_sources = ['VIIZW31', $
                   'M82', $
                   'NGC253', $
                   'NGC253NEW', $
                   'NGC253_ZSPEC', $
                   'NGC520', $
                   'NGC695',  $
                   'NGC891', $
                   'NGC2623', $
                   'NGC2903', $
                   'NGC6946', $
                   'NGC7469' $
                  ]

openw,lun,'observed_sources_fall07.txt',/get_lun

for i=0,n_e(science_sources)-1 do begin
    
    printf,lun,science_sources[i]
  
    wh = where(source_list eq science_sources[i])

    for j=0,n_e(wh)-1 do begin
        printf,lun,date_list[wh[j]],obsnum_list[wh[j]],source_list[wh[j]],$
          format='(A10,"  ",I4,"   ",A)'
    endfor

    printf,lun

endfor

close,lun
free_lun,lun

end
