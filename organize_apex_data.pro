pro organize_apex_data

nc_files = file_search(!zspec_data_root+'/apexnc/*/APEX-*subscan01.nc')
n_nc_files = n_e(nc_files)
source_name = strarr(n_nc_files)
nc_scan_number = strarr(n_nc_files)

for i = 0,n_nc_files-1 do begin

    temp = strsplit(nc_files[i],'/',/extract)
    source_name[i] = temp[n_e(temp)-2]
    
    temp = strsplit(nc_files[i],'-',/extract)
    a=strpos(temp[1], 'APEX')

    if a[0] ne -1 then nc_scan_number[i] = temp[2] $
    else nc_scan_number[i] = temp[1]

endfor

mbfits_files = file_search(!zspec_data_root+'/mbfits/APEX-*',$
                           /test_directory)
n_mbfits_files = n_e(mbfits_files)
scan_number = strarr(n_mbfits_files)
year = strarr(n_mbfits_files)
month = strarr(n_mbfits_files)
day = strarr(n_mbfits_files)

openw,lun,'APEX_observations.txt',/get_lun

for i = 0,n_mbfits_files-1 do begin
    
    temp = strsplit(mbfits_files[i],'-',/extract)
    
    scan_number[i] = temp[1]
    year[i] = temp[2]
    month[i]= temp[3]
    day[i] = temp[4]
    
    wh = where(nc_scan_number eq scan_number[i])
    if (wh[0] ne -1) then name_to_print = source_name[wh[0]] else $
      name_to_print = '???'
    
    if (year[i] eq '2011') then begin
        
        printf,lun,scan_number[i],year[i],month[i],day[i],name_to_print,$
          format='(A5,"  ",A4,"   ",A2,"  ",A2,"   ",A30)' 

    endif
endfor

close,lun
free_lun,lun

stop
end
