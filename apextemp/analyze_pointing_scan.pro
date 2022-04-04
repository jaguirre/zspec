pro analyze_pointing_scan, scanno, yrange

;scanno = 74921
file = 'APEX-'+strcompress(scanno,/rem)+'-2010-10-05-E-086.A-0793A-2010.nc'

;ch = read_ncdf(file,'chop_enc')
;ch -= mean(ch)
;ch /= max(ch)

;ch[where(ch ge 0)] = 1
;ch[where(ch lt 0)] = -1
;trans = get_choptrans(ch)

ac = read_ncdf(file,'ac_bolos')
longoff = read_ncdf(file,'longoff')
latoff = read_ncdf(file,'latoff')
t = read_ncdf(file,'ticks')
t-=t[0]
ntod = n_e(ch)

azcoeff = linfit(t,latoff*3600.)
az = poly(t,azcoeff)
elcoeff = linfit(t,longoff*3600.)
el = poly(t,elcoeff)

c = reform(ac[100,*])
a = linfit(t,c)
plot,t,(c-poly(t,a))*1.d6,/xst,/yst,yr=yrange

bpc = bpfilt(c)

end
