;written Feb 2008 by LE

;takes the results of Hanae's 2d-gaussian fit to the beammap data from
;20070516_021 and computes an effective aperture diameter for use in
;computing the approximate FWHM of Z-Spec's beam according to the relation
;fwhm=(1.02+(alpha*lambda))*lambda/d

;produces a postscript plot of the result


pro fit_for_fwhm

compute_beammap_vars=0

nu=freqid2freq()

if compute_beammap_vars eq 0 then goto,justfit

;restore results of 2d gaussian fit to the beammap from 20070516_021
  restore,'beam_mapping_params.sav'
  
  ;average of sigma_x and sigma_y
     sigma=(a[2,*]+a[3,*])/2.
     fwhm=2.35*reform(sigma)

  ;corresponding errors
     xerr=reform(params_err[2,*])  ;these are the errors in sigma
     yerr=reform(params_err[3,*])
     fwhm_err=2.35*(xerr+yerr)/2.

save,fwhm,fwhm_err,filename='beammap.sav'

justfit:
restore,'beammap.sav'

;for purposes of fitting, take out crappy data
  trial=1.02*29.979/nu/860.*206265.
  res=abs(fwhm-trial)
  goodch=where(fwhm_err le 2.*stddev(fwhm) and res le 3.)
  fwhm_good=fwhm(goodch)
  err=fwhm_err(goodch)
  xarr=29.979/nu(goodch)
 
A=[1040.,-1.]

fitpar=mpfitfun('fwhmfunc',xarr,fwhm_good,err,A,miniter=50)

fitval=((1.02+(fitpar[1]*xarr))*xarr/fitpar[0])*206265.
nu_fit=freqid2freq(goodch)

D_eff=total(fitpar[0])
alpha=total(fitpar[1])

save,D_eff,alpha,filename='beamwidth.sav'


;now plot result

set_plot,'ps'
device,/landscape,filename='fwhm_fit_from_beammap.ps',$
  /color,/inches

!p.thick=3
!p.charthick=3
!p.charsize=1.5

plot,nu,fwhm,psym=6,xtit=textoidl('\nu (GHz)'),$
  ytit=textoidl('mean of \sigma_x and \sigma_y (arcsec)'),$
  tit='Z-Spec beam size!Cfrom 20070516_021 beammap',$
  xthick=3,ythick=3,/yno,xrange=[180,310],/xst,/yst

oploterror,nu_fit,fwhm_good,err,psym=7,col=4

oplot,nu_fit,fitval,col=2,thick=4

old_beam=1.2*29.979/nu/1040.*206265
oplot,nu,old_beam,col=3,thick=4

temp=textoidl('D_{eff} = ')+strcompress(D_eff)+' cm'
temp2=textoidl('\alpha = ')+strcompress(alpha)+textoidl(' cm^{-1}')
xyouts,0.47,0.86,$
  textoidl('FWHM=206265*(1.02+\alpha\lambda)*\lambda/D_{eff}'),/normal
xyouts,0.57,0.81,textoidl('=2(2*ln(2))^{0.5}*\sigma'),/normal
xyouts,0.63,0.74,temp,/normal,col=2
xyouts,0.63,0.69,temp2,/normal,col=2

xyouts,0.2,0.23,textoidl('compare with 1.2*\lambda/1040 cm'),col=3,/normal
xyouts,0.2,0.17,'data used for fit in blue',/normal,col=4


device,/close
set_plot,'x'


end
