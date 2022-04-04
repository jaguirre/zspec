if (1) then begin

nu = freqid2freq()

restore,'SPT_0538-50_lp_20120425_1505__MS_PCA.sav'

spec1505 = both_decorr_spectra.in1.avespec
err1505 = both_decorr_spectra.in1.aveerr

restore,'SPT_0538-50_lp_20120601_0051__MS_PCA.sav'

spec0051 = both_decorr_spectra.in1.avespec
err0051 = both_decorr_spectra.in1.aveerr

restore,'SMG04_20120425_1505_fit.sav'
fit1505 = fit

readcol,'smg04_sed.txt',comment='#',format='(F,X,X,X,F)',angstroms,mjy
ghz = 3.d8/(angstroms*1e-10)/1e9
; Goddammit, Bothwell
mu = 20.5
z = 2.7817
ghz = ghz/(1+z)
mjy = mjy*mu

lambda_obs = [3.6e-6,4.5e-6,100e-6,160e-6,350e-6,870e-6,.0014,.002,0.0086]
ghz_obs = 3.d8/lambda_obs/1e9
mjy_obs = [0.0036,0.0046,2,7.5,16.4,6.1,1.5,0.4,0.0063]*mu
mjy_err_obs = [0.0007,0.0009,0.4,1.5,5.1,1.2,0.4,0.1,0.002]*mu

linefit = fit1505.lcspec-fit1505.cspec
whgood = where(nu ge 200. and finite(spec1505-linefit))

; Ah, hell, let's just fit the FIR points
fir_mjy_fit = [(spec1505-linefit)[whgood]*1000,mjy_obs[4:7]]
fir_mjy_err_fit = [err1505[whgood]*1000,mjy_err_obs[4:7]]
fir_ghz_fit = [nu[whgood],ghz_obs[4:7]]

srt = sort(fir_ghz_fit)
fir_ghz_fit = fir_ghz_fit[srt]
fir_mjy_fit = fir_mjy_fit[srt]
fir_mjy_err_fit = fir_mjy_fit[srt]

;window,1
;window,2

endif

parinfo = replicate({value:0.D, fixed:0, limited:[0,0], $
                       limits:[0.D,0], relstep:1}, 5)
parinfo(4).fixed = 1
;parinfo(4).limited(0) = 1
;parinfo(4).limits(0)  = 50.D
parinfo(*).value = [10000, 3700, 2, 10., 0.]
p = mpfitfun('greybody', fir_ghz_fit, fir_mjy_fit, fir_mjy_err_fit, $
             parinfo=parinfo)

; Z-Spec Spectra
cleanplot
wset,1
multiplot,[1,3],/init

multiplot
ploterror,nu,spec1505/fit1505.flags*1000,err1505/fit1505.flags*1000,$
  psy=10,/xst,xr=[200,max(nu)]
oplot,nu,fit1505.lcspec*1000,psy=10,col=2,thick=2
plots,3d8/0.0014/1e9,1.5*20.5,psy=4,col=3
oplot,ghz,mjy,col=3,thick=2
oplot,fir_ghz_fit,greybody(fir_ghz_fit,p),col=4,thick=2

multiplot
ploterror,nu,(spec1505/fit1505.flags-fit1505.cspec)*1000,$
  err1505/fit1505.flags*1000,$
  psy=10,/xst,xr=[200,max(nu)]
oplot,nu,(fit1505.lcspec-fit1505.cspec)*1000,psy=10,col=2,thick=2

multiplot
plot,nu,(spec1505/fit1505.flags-fit1505.cspec)/err1505,$
  psy=10,/xst,xr=[200,max(nu)]

cleanplot

wset,2
plot_oo,ghz,mjy,/xst,xr=[10,1e5]
;oplot,nu,fit1505.cspec*1000,col=2,psy=10
oploterror,nu[whgood],(spec1505-linefit)[whgood]*1000,err1505[whgood]*1000,$
  psy=3,col=2,errc=2
oploterror,ghz_obs,mjy_obs,mjy_err_obs,psy=4,col=3,errc=3
oplot,ghz,41.9*(ghz/240.)^3.278,col=5
oplot,ghz,greybody(ghz,p),col=3,line=2

end
