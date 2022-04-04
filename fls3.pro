reduc = $
  'FLS3_20100318-20100501_noflags'
;  'FLS3_ks20110601'
;  'FLS3_ks20100411_spectra'

restore,!zspec_pipeline_root+'/processing/spectra/coadded_spectra/FLS3/'+$
  reduc+'.sav'
restore,'FLS3_zilf_fit_free.sav'

nu = freqid2freq()
spec = uber_psderror.in1.avespec
err = uber_psderror.in1.aveerr

zearch_ks,nu,spec,err,z,sn,snpair,cont,fp1=fp1,fp2=fp2,fp3=fp3,name='FLS3'
zzearch = fp1[1]

cleanplot
@~/.idl_startup_zspec
load_plot_colors
;restore,'zilf_fit_fls3_z5.22.sav'

set_plot,'ps'
device,file=reduc+'.eps'

;!p.multi=[0,1,2]
multiplot,[1,2],/init

multiplot
ploterror,nu,spec,err,psy=10,/xst,tit=reduc,ytit='Flux (Jy)',/yst,$
  yr=[0,.04]
oplot,nu,cont,col=!cols.pink,thick=4
oplot,nu,fit.lcspec,col=!cols.red,psy=10
legend,/top,/left,box=0,textoidl('z_{zearch} = ')+$
  string(zzearch,format='(F5.3)')
legend,/bottom,/right,['zilf fit','zearch continuum'],$
  textcolor=[!cols.red,!cols.pink]

snspec = (spec-cont)/err

co_freqs = [115.2712018, $
            230.5380000, $
            345.7959899, $
            461.0407682, $
            576.2679305, $
            691.4730763, $
            806.6518060, $
            921.7997000, $
            1036.9123930, $
            1151.9854520, $
            1267.0144860, $
            1381.9951050, $
            1496.9229090, $
            1611.7935180, $
            1726.6025057, $
            1841.3455060, $
            1956.0181390, $
            2070.6159930, $
            2185.1346800]
;rest-frame nu, other species
cii = 1900.5369
nii = [1461.1318 ,2459.38010085]
oi = 2060.06886000

wh = where(snspec gt 2.0)
print,nu[wh]
zmb = cii/nu[wh]-1.
print,zmb
print,nii[0]/nu[wh]-1.
print,nii[1]/nu[wh]-1.

zguess = zzearch

multiplot
plot,nu,snspec,psy=10,/xst,ytit='S/N (psderror)',xtit='Frequency (GHz)',$
  thick=2
legend,/top,/right,$
  ['[NII](205)', '[CII](158)', '[OI](145)', 'CO', textoidl('2 \sigma peaks')],$
  textcolor=[!cols.red,!cols.green,!cols.blue,!cols.gold,!cols.grey]

vline,co_freqs/(1.+zguess),col=!cols.gold,thick=2
vline,cii/(1.+zguess),col=!cols.green,thick=2
vline,nii/(1.+zguess),col=!cols.red,thick=2
vline,nu[wh],col=!cols.grey,thick=2
vline,oi/(1.+zguess),col=!cols.blue,thick=2

device,/close
set_plot,'x'

cleanplot

end
