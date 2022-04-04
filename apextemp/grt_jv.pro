; Compute GRT temperature for a given scan number

pro grt_jv, date, now=now, nhrs=nhrs, t_out=t_out, grt_out=grt_out, stopit=stopit

if n_elements(nhrs) eq 0 then nhrs = 2.

if keyword_set(now) then begin
    julnow = systime(/jul,/utc)
    date_long = date_toolkit(julnow,'file')
    date = strmid(date_long,0,8)
endif

files1 = file_search('/data/'+strcompress(date,/rem)+'/*board09.nc',count=nfiles1)
datem1 = string(long(date)-1L)
files2 = file_search('/data/'+strcompress(datem1,/rem)+'/*board09.nc',count=nfiles2)
files = [files2,files1]
nfiles = nfiles1 + nfiles2

t0 = parse_udp_timestamp(read_ncdf(files2[0],'timestampUDP'))

filetimes = dblarr(nfiles)
for i=0,nfiles-1 do begin
    str1 = strsplit(files[i],'_',/ext)
    str2 = strsplit(str1[n_elements(str1)-3],'/',/ext)
    filetime_str = str2[n_elements(str2)-1] + '_' + str1[n_elements(str1)-2]
    filetimes[i] = date_toolkit(filetime_str,'mjd')
endfor

whnhr = where((max(filetimes) - filetimes)*24.d0 le nhrs,nnhr)
files = files[whnhr]
nfiles = nnhr

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

t = t - t0[0]

t *= 24.

if min(t) ge 24. then t -= 24.

grt = grt[srt]

grt = grt_filter(grt)

a = linfit(t,grt)

window,0,xs=1200,ys=400
!p.charsize=1.5
plot,t,grt*1000.,psy=3,/xst,/yst,$
  xtit='Hours',ytit='mK', chars=1.5, xr=[max(t)-nhrs, max(t)]
;oplot,t,poly(t,a)*1000,col=2

mk = a[1]*1000.

t_out = t
grt_out = grt

print,"GRT temperature now is: "+strcompress(string(grt[n_elements(grt)-1]*1000.,form='(f8.3)'),/rem) + " mK."

;legend,/top,/left,['Warming at '+string(mk,format='(F3.1)')+' mK/hour'],$
;  box=0

if keyword_set(stopit) then stop

end
