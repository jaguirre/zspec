; Grab GRT temperature for a given day and save it

pro get_grt_day, date, stopit=stopit

print, 'getting grt data for ', date

files = file_search('/data/'+strcompress(date,/rem)+'/*board09.nc')
nfiles = n_e(files)

t = parse_udp_timestamp(read_ncdf(files[0],'timestampUDP'))
sin = read_ncdf(files[0],'sin')
grt = tempconvert(sin[11,*],'grt29178','log')

for i=1,nfiles-1 do begin

    t = [t,parse_udp_timestamp(read_ncdf(files[i],'timestampUDP'))]
    sin = read_ncdf(files[i],'sin')
    grt = [grt,tempconvert(sin[11,*],'grt29178','log')]

endfor

srt = sort(t)
t = t[srt]
grt = grt[srt]
grt = grt_filter(grt)

n_tot = n_elements(grt)

whg = where(grt lt 0.2, n_good)
t=t[whg]
grt=grt[whg]


print, 'saving ', n_good, ' /', n_tot, '  samples'
save, t, grt, filename='/home/zspec/jv/grt_data/grt_data_'+strtrim(date,2)+'.sav'

print, 'done'
;stop

IF keyword_set(stopit) then stop

end
