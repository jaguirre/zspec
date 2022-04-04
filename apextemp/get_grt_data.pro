; Loadcurves and noise data are only in telescope_tests.  Observations
; made with the APECS software are in data/observations, but the
; parse-able thing is actually in /data/

;dates = ['20101001','

files = [file_search('~/data/telescope_tests/201010*/*board09.nc'),$
         file_search('/data/201010*/*board09.nc')]

nfiles = n_e(files)

sin = read_ncdf(files[0],'sin')
ts = read_ncdf(files[0],'timestampUDP')
grt1 = grt_filter(tempconvert(sin[10,*],'grt29177','log'))
grt2 = grt_filter(tempconvert(sin[11,*],'grt29178','log'))
jd = parse_udp_timestamp(ts)
nt = n_e(jd)
help,jd,grt1

plot,jd,grt1,/yno

; Cut the first and last 2% of each observation because of the way
; filtering works.
pct = 0.05
grt1 = grt1[nt*pct : nt*(1-pct)]
jd = jd[nt*pct : nt*(1-pct)]

oplot,jd,grt1,col=2

crap = 0

for i=1,nfiles-1 do begin

    print,i,' of  ',nfiles-1
    sin = read_ncdf(files[i],'sin')
; Make sure there was data in the file
    if sin[0] ne -1 and n_e(sin[0,*]) gt 150 then begin
        ts = read_ncdf(files[i],'timestampUDP')
        tc = tempconvert(sin[10,*],'grt29177','log')
; Through out crappy data
        if (min(tc) gt 0) then begin
            grt1_tmp = grt_filter(tempconvert(sin[10,*],'grt29177','log'))
            grt2_tmp = grt_filter(tempconvert(sin[11,*],'grt29178','log'))
            jd_tmp = parse_udp_timestamp(ts)
            nt = n_e(jd_tmp)
            grt1 = [grt1,grt1_tmp[nt*pct : nt*(1-pct)]]
            grt2 = [grt2,grt2_tmp[nt*pct : nt*(1-pct)]]
            jd = [jd,jd_tmp[nt*pct : nt*(1-pct)]]
        
            plot,jd_tmp,grt2_tmp,/yno
        endif else begin
            print,'Crappy data'
            crap++
        endelse
    endif else begin
        print,'Crappy data'
        crap++
    endelse

endfor

srt = sort(jd)
jd = jd[srt]
grt1 = grt1[srt]
grt2 = grt2[srt]

save,file='grt_data.sav',grt1,grt2,jd

end
