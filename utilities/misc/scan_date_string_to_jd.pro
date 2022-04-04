; convert date string from scan database to julian day

function scan_date_string_to_jd, datestr

nscans = n_elements(datestr)
result = dblarr(nscans)

for i=0L,nscans-1L do begin
    yearstr = strmid(datestr[i],0,4)
    monthstr = strmid(datestr[i],5,2)
    daystr = strmid(datestr[i],8,2)
    hrstr = strmid(datestr[i],11,2)
    minstr = strmid(datestr[i],14,2)
    secstr = strmid(datestr[i],17,2)
    newdatestr = strcompress(yearstr+monthstr+daystr+'_'+hrstr+minstr+secstr,/rem)
    result[i] = date_toolkit(newdatestr,'mjd') + 2400000.5d0
endfor

return, result

end
