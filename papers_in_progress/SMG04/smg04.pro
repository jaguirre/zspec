pth = '/home/local/zspec/zspec_data_svn/coadded_spectra/'

non = 'SPT_0538-50/SPT_0538-50_20120425_1455__MS_PCA.sav'
cmb = 'SPT_0538-50_combined/SPT_0538-50_combined_20120425_1522__MS_PCA.sav'
lp = 'SPT_0538-50_lp/SPT_0538-50_lp_20120425_1505__MS_PCA.sav'

;restore,pth+non
;help,file_list
;restore,pth+lp
;help,file_list
;restore,pth+cmb,/verb
;help,file_list

reduc = 'SPT_0538-50_lp_20120425_1505__MS_PCA'
file = reduc+'.sav'

; Magic combination: lp, both decorrelations, and binned sample variance
redshift_search,'SPT_0538-50',reduc,/local,/MS_decorr,/PCA_decorr,/spectra

end
