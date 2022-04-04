path = '/home/local/zspec/zspec_data_svn/coadded_spectra/'
files = file_search(path+'SPT_*/*__MS_PCA.sav',count=nfiles)

openw,lun,'SPT_Observations.txt',/get_lun
for i = 0,nfiles-1 do begin
   summarize_coadd,files[i],lun=lun
   flush,lun
endfor
close,lun
free_lun,lun

end
