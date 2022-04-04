
root = !zspec_pipeline_root+'/processing/spectra/coadded_spectra/NGC4418ZSPEC/'

restore,root+'NGC4418ZSPEC_20110307_0209.sav'

s = uber_psderror.in1.avespec
err = uber_psderror.in1.aveerr
ns = uber_psderror.in1.nodspec
nerr = uber_psderror.in1.noderr
mask = uber_psderror.in1.mask

nu = freqid2freq()

restore,'ngc4418_fit.sav'

ploterror,nu,s-fit.lcspec,err,psy=10,/xst

oploterror,nu,s-fit.lcspec,err,psy=10,col=2,errc=2

end
