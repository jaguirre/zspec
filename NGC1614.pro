nu = freqid2freq()

root = !zspec_pipeline_root+'/processing/spectra/coadded_spectra/NGC1614/'

restore,root+'NGC1614_20110306_1448.sav'
s_jan = uber_psderror.in1.avespec
e_jan = uber_psderror.in1.aveerr
ns_jan = uber_psderror.in1.nodspec
ne_jan = uber_psderror.in1.noderr

restore,root+'NGC1614_20110306_1444.sav'
s_nov = uber_psderror.in1.avespec
e_nov = uber_psderror.in1.aveerr
ns_nov = uber_psderror.in1.nodspec
ne_nov = uber_psderror.in1.noderr

fac = 0.65
ploterror,nu,s_jan,e_jan,psy=10,/xst,/yst,yr=[-0.2,1]
oploterror,nu,s_nov/fac,e_nov/fac,psy=10,col=2,errc=2

end
