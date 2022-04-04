; Edo Ibar (2012-12-02): 
; I modified the proj input. The main reason for that is that we are
; using different planet calibrations from different projects. The
; best option to solve this issue is to input the "proj" variable on
; the cal_file directly
; 12/19/2012 - KSS - Committed Edo's changes to svn

pro run_zapex_calibs,cal_file,rerun=rerun;,proj=proj

;; RUN MUST INCLUDE THE YEAR ie 'E-086.A-0793A-2010'
;if n_elements(proj) eq 0 then begin
;    print, 'Please specify a project! (Use the "proj=" keyword.)'
;    return
;endif 
;;run='E-086.A-0793A-2010'

cal_file=!zspec_pipeline_root+'/calibration/'+cal_file
spawn,'pwd',currdir

;_________________________________________________________________
;READ IN TEXT FILE DEFINING WHICH CALIBRATION OBSERVATIONS TO USE

  readcol,cal_file,date,obs,planet,flag,proj,format='(a8,a5,a,i1,a)'
  n_obs=n_e(date)

  ;get rid of observations with flag 0
    wantdata=where(flag eq 1)
    n_obs=n_e(wantdata)
    obs=obs(wantdata)
    planet=planet(wantdata)
    date=date(wantdata)
    proj=proj(wantdata)

for i=0,n_obs-1 do begin

   print,'Obs ',i+1,' of ',n_obs

   if proj[i] eq 'SPT' then run='E-086.A-0793A-2010'
   if proj[i] eq 'HERMES' then run='E-087.A-0397A-2010'
   if proj[i] eq 'ATLAS' then run='E-087.A-0820A-2010'
   if proj[i] eq 'INFANTE' then run='C-090.F-9717B-2012'
   if proj[i] eq 'JOHANSSON' then run='O-088.F-9328A-2011'
   if proj[i] eq 'CASASSUS' then run='C-090.F-0024A-2012'

;_________________________________________________________
; SEARCH FOR THE .SAV FILE
; USE ZAPEX IF THE .SAV FILE CANNOT BE FOUND

   savfile=!zspec_data_root+'/apexnc/*/APEX-'+obs[i]+'-*_spec.sav'
   spawn,'ls '+savfile,savresult   
   if savresult[0] NE '' then begin
     if ~keyword_set(rerun) then begin
         message,'Found .sav file for '+obs[i],/info
     endif else begin
         message,'Rerunning zapex for '+obs[i],/info
         zapex,obs[i],1,2
     endelse
   endif else begin

; SEARCH FOR THE .FITS FILE
; USE GAD IF THE .FITS DIRECTORY CANNOT BE FOUND
; Oh hey, guess what, you need to be in the right date's directory, gah.

       fitsdir=!zspec_data_root+'/apexnc/*/APEX-'+obs[i]+'-*.nc'
       spawn,'ls '+fitsdir,fitsresult
       if fitsresult[0] NE '' then begin
           message,'Found fits dir for '+obs[i],/info
       endif else begin
           ; Go to the observations directory
           cd,!zspec_data_root+'/apexnc/'
           ; Get the files into that directory
           spawn,'gadp '+obs[i]+' '+proj[i]
           ; Move them into the proper day's directory. OBSOLETE.
           ;spawn,'ls *'+obs[i]+'*',rawfiles
           ; Find the right date...
           ;split=STRSPLIT(rawfiles[0],'-',/extract)
           ;date=split[2]+split[3]+split[4]
           ;spawn,'mv *'+obs[i]+'* '+date
       endelse
       zapex,obs[i],1,2

   endelse

endfor

message,'Congrats, you should be ready to run flux_calibration_wrapper, with the /apex keyword',/info
cd,currdir

end
