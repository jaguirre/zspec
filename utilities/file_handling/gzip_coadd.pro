pro gzip_coadd,obs_list,unzip=unzip,flags=flags

;+
; NAME:
;  GZIP_COADD
;
; PURPOSE:
;  Gzip (or gunzip) all .nc files in a coadd list.
;  Gzip when finished coadding an object for
;  a while to save room on spire1.
;
; CALLING SEQUENCE:
;  gzip_coadd,obs_list,unzip=unzip,flags=flags
;
; EXAMPLE:
;  gzip_coadd,'UGC5101_spr07.txt'
;     (gzips all observations listed in the file)
;  gzip_coadd,'UGC5101_spr07.txt',/unzip,/flags
;     (gunzip only those observations which are flagged)
;
; MODIFICATION HISTORY:
;  Written by JRK 2/9/09
;  Most code for interpreting coadd list grabbed
;  from uber_spectrum.pro
;
; INPUTS:
;  obs_list: the filename of the coadd list.
;
; OPTIONAL KEYWORDS:
;  /unzip actually UNzips the whole coadd list.
;  Useful if you know you'll want to coadd; can 
;  set this up ahead of time.
;
;  /flags only g(un)zips the files flagged with a 1
;  in the coadd list.
;
; RESTRICTIONS
;  If there is already both a zipped and unzipped
;  version of an observation, this program will not
;  do anything to either file.
;
;-

;_____________________________________________________
;READ IN TEXT FILE

  start=systime(/seconds)

  file=!zspec_pipeline_root+'/processing/spectra/coadd_lists/'+obs_list
  readcol,file,date,obs,flag,format='(a8,a3,i1)',$
    comment=';'
  readcol,file,header,format='(a)',comment=';'
 
  n_obs=n_e(date)

  ;Break up the date into year, month, night        
     a=0L & b=0L & c=0L
     year=strarr(n_obs) & month=year & night=year
     for i=0, n_obs-1 do begin
       reads,date[i],a,b,c,format='(a4,a2,a2)'
       year[i]=a & month[i]=b & night[i]=c
     endfor
  
  ;If the "flags" keyword is set, only use those obs.
  ;which are flagged 1.
  if keyword_set(flags) then begin
     wantdata=where(flag eq 1)
     n_obs=n_e(wantdata)
     year=year(wantdata)
     month=month(wantdata)
     night=night(wantdata)
     obs=obs(wantdata)
  endif
 
;_____________________________________________________
;GZIP (OR GUNZIP) FILES
     
     ncfile_list=strarr(n_obs)
     
     ;Loop over all observations in the list
     for i=0,n_obs-1 do begin
     
     ;Search for zipped and unzipped files
     ncfile=get_ncdfpath(year[i],month[i],night[i],obs[i])
     zippedfile=ncfile+'.gz'
     maligned=file_search(ncfile)
     zipped=file_search(zippedfile)
     
     ;Gunzip if keyword set
     if keyword_set(unzip) then begin
         if maligned eq '' and zipped eq zippedfile then begin
             print,'Gunzipping file '+STRTRIM(i+1,2)+$
                 ' of '+STRTRIM(n_obs,2)+'.'
             spawn,'gunzip '+zippedfile
         endif else print,'File '+STRTRIM(i+1,2)+' already unzipped.'
         
     ;Gzip otherwise
     endif else begin 
         if maligned eq ncfile and zipped eq '' then begin
             print,'Gzipping file '+STRTRIM(i+1,2)+$
                 ' of '+STRTRIM(n_obs,2)+'.'
             spawn,'gzip '+ncfile
         endif else print,'File '+STRTRIM(i+1,2)+' already zipped.'
     endelse

     endfor ; Looped over all observations

  ;Report time
  stop=systime(/seconds)
  time=(stop-start)/60
  
  print,'Procedure took '+STRTRIM(time,2)+' minutes for '+$
      STRTRIM(n_obs,2)+' observations.'

end
 