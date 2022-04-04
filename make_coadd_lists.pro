pro make_coadd_lists, name=name, tag=tag, date=date

;List of "source" names to skip
bad_names=['problematic', 'notarget', 'blank', 'block','capped', $
           'moveaside.sh', 'test', 'NoName']

;Get a full list of source names if no source was specified
if ~keyword_set(name) then begin

    nc_dirs = file_search(!zspec_data_root+'/apexnc/*')
    n_nc_dirs = n_e(nc_dirs)
    source_names = strarr(n_nc_dirs)
    
    for i = 0,n_nc_dirs-1 do begin
        
        temp = strsplit(nc_dirs[i],'/',/extract)
        source_names[i] = temp[n_e(temp)-1]
    endfor
    
endif else source_names=name ;Else just use the specified name

;Get a list of phase files, sources, and scan numbers
nc_phases = file_search(!zspec_data_root+'/apexnc/*/APEX-*chopphase.sav')
n_nc_phases = n_e(nc_phases)
phase_files = strarr(n_nc_phases)
phase_numbers = lonarr(n_nc_phases)
phase_sources=strarr(n_nc_phases)

for i = 0,n_nc_phases-1 do begin

    temp = strsplit(nc_phases[i],'/',/extract)
    phase_files[i]= temp[n_e(temp)-1]
    phase_sources[i]=temp[n_e(temp)-2]

    temp = strsplit(nc_phases[i],'-',/extract)
    a=strpos(temp[1], 'APEX') ;Used to deal with hyphens in the source name

    ;Make sure we're past the 'APEX' to get the scan number
    if a[0] ne -1 then curNum = temp[2] $
    else curNum = temp[1]

    num=0l ;Convert the scan number from string to int
    reads, curNum, num
    phase_numbers[i]=num

endfor

a=sort(phase_numbers) ;Sort by phase number
phase_numbers=phase_numbers[a]
phase_files=phase_files[a]
nc_phases=nc_phases[a]
phase_sources=phase_sources[uniq(phase_sources)]

;Get the full list of netcdf files
nc_files = file_search(!zspec_data_root+'/apexnc/*/APEX-*subscan01.nc')

;Screen for certain dates, if requested
if keyword_set(date) then begin
    goodFiles=where(strpos(nc_files, date) ne -1, count)

    if count eq 0 then begin
        print, 'Error: No files for date string '+date
        return
    endif

    nc_files=nc_files[goodFiles]

endif

n_nc_files = n_e(nc_files)
nc_source_name = strarr(n_nc_files)
nc_scan_number = lonarr(n_nc_files)
dates=strarr(n_nc_files)

for i = 0,n_nc_files-1 do begin
    
    temp = strsplit(nc_files[i],'/',/extract)
    nc_source_name[i] = temp[n_e(temp)-2]
    
    temp = strsplit(nc_files[i],'-',/extract)
    a=strpos(temp[1], 'APEX')
    
    if a[0] ne -1 then curNum= temp[2] $
    else curNum= temp[1]

    num=0l
    reads, curNum, num
    nc_scan_number[i]=num ;Convert the scan number from string to int
    dates[i]=temp[n_e(temp)-7]+temp[n_e(temp)-6]+temp[n_e(temp)-5]
        
endfor
a=sort(nc_scan_number) ;Sort by scan number
nc_source_name = nc_source_name[a]
nc_scan_number = nc_scan_number[a]
dates=dates[a]

basedir=!zspec_pipeline_root+'/processing/spectra/coadd_lists/'
                                ;Dir to hold the coadd lists

for file=0, n_elements(source_names) -1 do begin
    w=where(bad_names eq source_names[file])
    if w[0] ne -1 then continue ;Skip bad names

    if keyword_set(tag) then $
      openw, lun, basedir+source_names[file]+'_'+tag+'.txt', /get_lun $
    else openw, lun, basedir+source_names[file]+'.txt', /get_lun

    printf, lun, source_names[file] ;File headers
    printf, lun, ''
    printf, lun, '0.0 (=z unknown)'
    printf, lun, ''
   
    ;Is this a phase?
    w=where(phase_sources eq source_names[file])
    if w[0] eq -1 then phase=0 else phase=1

    w=where(nc_source_name eq source_names[file])
    if w[0] eq -1 then begin
        close, lun
        free_lun, lun
        continue
    endif

    ;Populate the files
    for i=0, n_e(w)-1 do begin
        if phase then printf, lun, dates[w[i]], nc_scan_number[w[i]],$
          1, 1, format='(A8,"    ",I5,"     ",I1,"  ",I5)' $

        else begin
            w2=where(phase_numbers lt nc_scan_number[w[i]])
            
            printf, lun, dates[w[i]], nc_scan_number[w[i]],$
              1, phase_numbers[w2[n_e(w2)-1]], $
              format='(A8,"    ",I5,"     ",I1,"  ",I5)' 
        endelse
    end

    close, lun
    free_lun, lun
   
endfor
end
