;JRK 3/5/09
;Edit 3/12/09 to also look for .nc files
;Edit 8/8/09 to also accept zipped .nc files
;Edit 10/27/09 to not print full directory
; 
;Print a list of which observations in coadd list have not 
;had maligns or save_spectra run.

pro spectra_query,obs_list

;_______________________________________________________________________
;READ IN TEXT FILE DEFINING OBSERVATIONS, ALA UBER_SPECTRUM

  file=!zspec_pipeline_root+'/processing/spectra/coadd_lists/'+obs_list
  readcol,file,date,obs,flag,format='(a8,a3,i1)',$
    comment=';',/silent
  readcol,file,header,format='(a)',comment=';',/silent

  source_name=header[0] & z=header[1]

  n_obs=n_e(date)

  ;break up the date into year, month, night        
     a=0L & b=0L & c=0L
     year=strarr(n_obs) & month=year & night=year
     for i=0, n_obs-1 do begin
       reads,date[i],a,b,c,format='(a4,a2,a2)'
       year[i]=a & month[i]=b & night[i]=c
     endfor

     ;only use observations flagged 1
     wantdata=where(flag eq 1)
     n_obs=n_e(wantdata)
     year=year(wantdata)
     month=month(wantdata)
     night=night(wantdata)
     obs=obs(wantdata)

;_______________________________________________________________    
;CHECK TO MAKE SURE DEMODULATED DATA FILES EXIST

     file_list=strarr(n_obs)
     ncfile_list=strarr(n_obs)
     for i=0,n_obs-1 do begin
         
         ncfile=get_ncdfpath(year[i],month[i],night[i],obs[i])
         test_nc=file_search(ncfile)
         gzipncfile=ncfile+'.gz'
         test_gzipnc=file_search(gzipncfile)
         if (test_nc eq '') and (test_gzipnc eq '') then begin
             nc_split=strsplit(ncfile,'/',/extract)
             print,'Cannot find: '+nc_split[n_e(nc_split)-1]+'.'
         endif

         save_spectra_file=change_suffix(ncfile,'_spectra.sav')
         test_ss=file_search(save_spectra_file)
         if (test_ss eq '') then begin
             sav_split=strsplit(save_spectra_file,'/',/extract)
             print,'Cannot find: '+sav_split[n_e(sav_split)-1]+'.'
         endif
     endfor

end
