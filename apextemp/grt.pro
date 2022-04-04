; Compute GRT temperature for a given scan number

pro grt, date , t, grt ,noplot=noplot

; JRK 10/29, added ability to grab t and grt using this program,
; use keyword /noplot if you just want the arrays and not the plot.

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

t = t - t[0]

t *= 24.

grt = grt[srt]

grt = grt_filter(grt)

if ~keyword_set(noplot) then begin

a = linfit(t,grt)

window,0,xs=1200,ys=400
!p.charsize=1.5
plot,t,grt*1.e-9,psy=3,/xst,/yst;,yr=[0.07,.110],xtit='Hours',ytit='Kelvin'
oplot,t,poly(t,a),col=2

mk = a[1]*1000.

legend,/top,/left,['Warming at '+string(mk,format='(F3.1)')+' mK/hour'],$
  box=0

endif


end
