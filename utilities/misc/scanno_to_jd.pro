; get the start time (in julian date) for a given scan # or vector of
; scan #s.  scans can be supplied as strings or integers (or even
; floats). 

function scanno_to_jd, scanno, verbose=verbose

nscans = n_elements(scanno)
scanno_long = long(scanno)

scanfile = '/home/zspec/data/obs_logs/zspec_search.dat'
readcol,scanfile,datestr,run,scanlist,form='A,A,L',skip=3,/sil
dates_jd = scan_date_string_to_jd(datestr)

result = dblarr(nscans) + !values.f_nan
for i=0L,nscans-1L do begin
    whscan = where(scanlist eq scanno_long[i],nwhscan)
    if nwhscan gt 0 then result[i] = dates_jd[whscan[0]]
endfor

if keyword_set(verbose) then begin
    whbad = where(finite(result) eq 0,nbad)
    if nbad eq 0 then begin
        print,"All scans found!"
    endif else begin
        print,strcompress(string(nbad,form='(I8)'))+" scans not found:"
        print,string(scanno[whbad],form='(I8)')
    endelse
endif

return, result

end
