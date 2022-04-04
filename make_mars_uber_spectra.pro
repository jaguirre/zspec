; 

coadd_list_files = file_search(!zspec_pipeline_root+$
                               '/processing/spectra/coadd_lists/Mars_2*.txt')
nfiles = n_e(coadd_list_files)

for i=2,nfiles-1 do begin

    temp = strsplit(coadd_list_files[i],'/',/extract)
    coadd_list = temp[n_e(temp)-1]
    readcol,coadd_list_files[i],format='(A)',name
    dir = name[0]

    readcol,coadd_list_files[i],format='(A,A,A,A)',$
      yyyymmdd,obsnum,flag,chopphase

    print,'Writing new file'

    openw,lun,coadd_list_files[i],/get_lun

    printf,lun,name[0]
    printf,lun
    printf,lun,name[1]
    printf,lun
    printf,lun,yyyymmdd,obsnum,flag,chopphase,format='(A8,A10,A10,"    ",A)'

    close,lun
    free_lun,lun

    year = strmid(yyyymmdd,0,4)
    month = strmid(yyyymmdd,4,2)
    day = strmid(yyyymmdd,6,2)

    print,'Running save_spectra'

    file = save_spectra(year,month,day,obsnum,1,/deg)

;    run_save_spectra,obs=coadd_list_files[i]

    print,'Running uber_spectrum'

    uber_spectrum,coadd_list,savename=savename
    
    temp = strsplit(savename,'/',/extract)
    ntemp = n_e(temp)

    plot_uber_spectrum_ks,temp[ntemp-2]+'/'+temp[ntemp-1],dir+'.ps',/mars

endfor

end
