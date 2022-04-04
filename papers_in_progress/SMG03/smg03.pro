; Magic combination: lp, both decorrelations, and binned sample
; variance

pth = '/home/local/zspec/zspec_data_svn/coadded_spectra/SPT_2332-53_lp/'

reduc = 'SPT_2332-53_lp_20120425_2038__MS_PCA'
file = reduc+'.sav'

;restore,file,/verb

; What feature is giving the "false" spike at z = 3.24?
redshift_search,'SPT_2332-53',reduc,/local,/PCA_decorr,/spectra,$
  zrange=[1,5]

end
