; Data points
lambda = [100, 160, 348.8 ,869.6, 1355.0, 1945.5]
mJy = [40.08, 154.46, 336, 125, 29.68, 8.54]
mJy_uncert = [4.703, 7, 88, 7, 5.132, 1.393]
freq = 3d8/(lambda*1e-6)/1d9

; Cigale model - not at all sure what's going on here
;readcol,'smg04_SMG04.spec',comment='#',format='(F,F,F,F,F)',$
;  lam,Flam,zlam,zflam,zfnu

restore,'SPT_0538-50_lp_20120601_0051__MS_PCA.sav'

nu = freqid2freq()
ploterror,nu,uber_spectra.in1.avespec*1000,uber_spectra.in1.aveerr*1000,psy=3,$
  /xlog,/ylog,/xst,/yst,xr=[1e2,5000],yr=[1,1e3]
oploterror,freq,mjy,mjy_uncert,psy=4,col=2,errc=2

;oplot,freq,greybody(freq,[5e16,2000,2,40,2.782]),col=3,psy=-4

parinfo = replicate({value:0.D, fixed:0, limited:[0,0], $
                       limits:[0.D,0]}, 5)

; Initial guess
parinfo(*).value = [5e16,970.84,2.,38.3,2.782]
; Fix the redshift
parinfo(1).fixed = 0
parinfo(2).fixed = 1
parinfo(3).fixed = 1
parinfo(4).fixed = 1
parinfo(1).limited(*) = [1,1]
parinfo(1).limits(*) = [500,4000]
parinfo(2).limited(*) = [1,1]
parinfo(2).limits(*) = [0,4]
parinfo(3).limited(*) = [1,1]
parinfo(3).limits(*) = [20,80]

p = mpfitfun('greybody', freq, mJy, mJy_uncert, parinfo=parinfo)
;,yfit=yfit) ;p0)

f = loggen(10,100,1e4)
oplot,f,greybody(f,p),col=3,thick=3

end
