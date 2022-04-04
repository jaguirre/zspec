;restore,'SPT_0155-62_20130717_1934_nocalcorr.sav'

nu = freqid2freq()
bw = freqid2bw()
kms = bw/nu*3e5

err = both_decorr_spectra.in1.aveerr
err_jykms = err*kms
indx = lindgen(160)

forprint,indx,nu,err,err_jykms

end
