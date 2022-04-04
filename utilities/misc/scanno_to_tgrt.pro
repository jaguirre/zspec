; find GRT temperature for a given scan number (or vector of scan numbers)

function scanno_to_tgrt, scanno, jd

nscans = n_elements(scanno)
;filestems = strarr(nscans)
result = fltarr(nscans) + !values.f_nan

jdvec = scanno_to_jd(scanno)
for i=0L,nscans-1L do begin
    dtemp = date_toolkit(jdvec[i],'file')
    thisdir = strmid(dtemp,0,8)
    thisfilestem = strmid(dtemp,0,12)
    files = file_search('/data/'+thisdir+'/*'+thisfilestem+'*board09.nc',count=nfiles)
    if nfiles gt 0 then begin
        file_jd = dblarr(nfiles)
        for j=0,nfiles-1 do begin
            str1 = strsplit(files[j],'/',/ext)
            str2 = strsplit(str1[n_elements(str1)-1],'_',/ext)
            file_jd[j] = date_toolkit(str2[0]+'_'+str2[1],'mjd') + 2400000.5d0
        endfor
        djd = abs(file_jd-jdvec[i])
        mindjd = min(djd,whmin)
        sin = read_ncdf(files[whmin[0]],'sin')
        grt = tempconvert(sin[11,*],'grt29178','log')
        result[i] = mean(grt)
    endif
endfor

if nscans eq 1 then begin
    result = result[0]
    jdvec = jdvec[0]
endif

jd = jdvec

return, result

end
