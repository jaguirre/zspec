nu = freqid2freq()

path = !zspec_pipeline_root+'/processing/spectra/coadded_spectra/'

restore,path+'SPT_0529-54/'+$
'SPT_0529-54_20110304_0055.sav'
;  'SPT_0529-54_20110430_0008.sav'

restore,path+'SPT_2353-50_lp/'+$
  'SPT_2353-50_lp_20110429_1848.sav'

restore,path+'FLS3/'+$
  'FLS3_ks20100411_spectra.sav'

restore,path+'SPT_0550-53_sma/'+$
  'SPT_0550-53_sma_20110601_1613.sav'

spec = uber_spectra.in1.avespec
err = uber_spectra.in1.aveerr
spec2 = uber_psderror.in1.avespec
err2 = uber_psderror.in1.aveerr

ploterror,nu,spec/uber_bolo_flags,err,psy=10

zearch_ks,nu,spec,err,z,sn,snpair,cont,fp1=fp1,fp2=fp2,fp3=fp3,name='SPT_0550-53_sma'

@~/idl_startup_zspec
oplot,nu,spec/uber_bolo_flags-cont,psy=10,col=2

end
