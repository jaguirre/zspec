; I'm sure this is duplicating a routine somewhere, but I can't find
; it

pro plot_planet_paths_one_night, date_string, planets=planets, noaz=noaz

; date_string should be YYYY_MMDDD (e.g., '2010_1102'), and it should
; correspond to the date it will be at midnight.
yrstr = strmid(date_string[0],0,4)
mdstr = strmid(date_string[0],5,4)
jd_midnight = date_toolkit(yrstr+mdstr+'_000000','mjd') + 2400000.5d
t_offset = dindgen(48)*0.5/24.d0 - 12./24.d0
jdvec = jd_midnight[0] + t_offset
paths_az = dblarr(48,8)
paths_el = dblarr(48,8)

; APEX coords 	
; Latitude : 23¼00'20.8" South
; Longitude :67¼45'33.0" West
; Altitude : 5105 m 
lat_apex = -ten(23.,00.,20.8)
lon_apex = -ten(67.,45.,33.0)
alt_apex = 5105.

for i=0,47 do begin
; get planet coords
    planet_coords,jdvec[i],ra_temp,dec_temp,/jd
    eq2hor,ra_temp,dec_temp,jdvec[i],el_temp,az_temp,lat=lat_apex,lon=lon_apex,refract=0
    paths_az[i,*] = az_temp
    paths_el[i,*] = el_temp
endfor

planet_names = ['Mercury','Venus','Mars','Jupiter','Saturn','Uranus','Neptune','Pluto']
if n_elements(planets) eq 0 then planets = planet_names
n2plot = n_elements(planets)
wh2plot = intarr(n2plot)
for i=0,n2plot-1 do begin
    whpl = where(strupcase(planet_names) eq strcompress(strupcase(planets[i]),/rem))
    wh2plot[i] = whpl[0]
endfor

window,0,xs=700,ys=400
dummy = LABEL_DATE(DATE_FORMAT='%M %D, %Hh')
syms = [7,2,1,5,6,4,7,3]
PLOT, jdvec, paths_el[*,wh2plot[0]], XTICKUNITS='Time', XTICKFORMAT='LABEL_DATE',/xst,yra=[-5,95],/yst,xtitle='UTC',ytitle='Elevation [deg]',psym=syms[wh2plot[0]],thick=2,chars=1.4
loadct,39
n2plot = n_elements(wh2plot)
cols = (indgen(8)+1)*200/n2plot + 50
for i=0,n2plot-1 do oplot, jdvec, paths_el[*,wh2plot[i]], psym=syms[wh2plot[i]],thick=2,color=cols[i]
oplot,[0,0]+systime(/jul,/utc),[-100,1000],line=2
xyouts,systime(/jul,/utc)+0.5/24.,80,'NOW',orient=90
legend,planet_names[wh2plot],psym=syms[wh2plot],color=cols,thick=2,/right

if keyword_set(noaz) eq 0 then begin
    window,2,xs=700,ys=400
    PLOT, jdvec, paths_az[*,wh2plot[0]], XTICKUNITS='Time', XTICKFORMAT='LABEL_DATE',/xst,yra=[0,360],/yst,xtitle='UTC',ytitle='Azimuth [deg]',psym=syms[wh2plot[0]],thick=2,chars=1.4
    loadct,39
    n2plot = n_elements(wh2plot)
    cols = (indgen(8)+1)*200/n2plot + 50
    for i=0,n2plot-1 do oplot, jdvec, paths_az[*,wh2plot[i]], psym=syms[wh2plot[i]],thick=2,color=cols[i]
    oplot,[0,0]+systime(/jul,/utc),[-100,1000],line=2
    xyouts,systime(/jul,/utc)+0.5/24.,80,'NOW',orient=90
    legend,planet_names[wh2plot],psym=syms[wh2plot],color=cols,thick=2,/right
endif

end
