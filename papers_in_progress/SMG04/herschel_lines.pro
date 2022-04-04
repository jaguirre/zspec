; Magnification

mu = 8.47

; This is de-lensed, 3 sigma upper limit
line_lum = [1.3,1.3,1.2,0.94,-99,1.8,2.2]*1.d10
line_rat = [1.2,1.2,1.1,1.2,-99,0.9,2.0]*1d-3
nline = n_e(line_lum)

line_name = ['[OIII](52)','[NIII](57)','[OI](63)','[OIII](88)',$
             '[NII](122)','[OI](146)','[CII](158)']

; At this point, just a a WAG
l_fir = 8.5d13/mu

r = spinoglio_line_ratios(l_fir)
r_hi = spinoglio_line_ratios(l_fir,/upper)
r_lo = spinoglio_line_ratios(l_fir,/lower)

indx = lindgen(nline)+1

plot,indx,alog10(line_rat),psy=4,xst=5,xr=[0,nline+1],$
  /yst,yr=[-5,-2],ytit=textoidl('log_{10}(L_{line}/L_{FIR})'),$
  charsize=1.5

whline = [8,9,10,11,13,14]
rat = dblarr(nline)
rat_hi = rat
rat_lo = rat
for i=0,nline-1 do begin
    rat[i] = r.(whline[i])
    rat_hi[i] = r_hi.(whline[i])
    rat_lo[i] = r_lo.(whline[i])
endfor

oploterror,indx,alog10(rat),alog10(rat_hi/rat),psy=4,col=2,errc=2,/hibar
oploterror,indx,alog10(rat),alog10(rat/rat_lo),psy=4,col=2,errc=2,/lobar

xyouts,indx,-2.2,line_name,$
  orientation=90,alignment=0.5,charsize=1.5

end
