; strip off any non-date material from a filename to get the date

function extract_date_from_filename, files, mjd=mjd

nfiles = n_elements(files)
result = strarr(nfiles)

for i=0,nfiles-1 do begin
    split1 = strsplit(files[i],'/',/extract)
    filename_nopath = split1[n_elements(split1)-1]
    split2 = strsplit(filename_nopath,'_',/extract)
    datepart1 = split2[n_elements(split2)-2]
    datepart2_plus_extension = split2[n_elements(split2)-1]
    split3 = strsplit(datepart2_plus_extension,'.',/extract)
    datepart2 = split3[0]
    result[i] = strcompress(datepart1+'_'+datepart2+'00',/rem)
endfor

if keyword_set(mjd) then begin
    result_str = result
    result = dblarr(n_elements(result_str))
    for i=0,nfiles-1 do result[i] = date_toolkit(result_str[i],'mjd')
    if nfiles eq 1 then result = result[0]
endif

return, result

end
