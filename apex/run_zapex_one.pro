pro run_zapex_one,obs,chop_file,rerun=rerun,regad=regad,proj=proj,$
                  savfile=savresult

; JRK 10/21/10
; Wrapper which goes through a coadd list, searching for .sav files.
; If .sav file is not found, next looks to see if the .fits files are
; present.
; If .fits are present, run zapex.  If not present, grab them, then
; run zapex.
; Use keyword /rerun to rerun zapex on all files, even if a .sav file
; already exists (ie if you have changed what chopphase file to use).
; Use a 1 in the 4th column instead of an observation number to
; calculate the observations own phase.
; 12/19/2012 - KSS - Committe latest version to svn.

; For now, hard code the run INCLUDING THE YEAR
if keyword_set(proj) then begin
if proj eq 'SPT' then run='E-086.A-0793A-2010'
if proj eq 'HERMES' then run='E-087.A-0397A-2010'
if proj eq 'ATLAS' then run='E-087.A-0820A-2010'
if proj eq 'INFANTE' then run='C-090.F-9717B-2012'
if proj eq 'JOHANSSON' then run='E-088.F-9328A-2011'
if proj eq 'CASASSUS' then run='C-090.F-0024A-2012'
endif

;file=!zspec_pipeline_root+'/processing/spectra/coadd_lists/'+coadd_file

spawn,'pwd',currdir

; Doesn't matter if the file has 4 or 5 columns (the 5th being a
; spectral flatting, which applies to uber_spectrum, not here).

;readcol,file,date,obs,flag,chop_file,format='(a8,a6,i1,a6)'

; Only want observations flagged 1
;wantdata=where(flag eq 1, n_obs)
;if (n_obs EQ 0) then begin
;    message,/cont, 'No good observations found.  Quitting...'
;    return
;endif

;obs=obs[wantdata]
;chop_file=chop_file[wantdata]

;n_obs=n_e(obs)

; Loop over all observations

;for i=0,n_obs-1 do begin

   ;print,'Obs ',i+1,' of ',n_obs

;_________________________________________________________
; SEARCH FOR THE .SAV FILE
; USE ZAPEX IF THE .SAV FILE CANNOT BE FOUND

   savfile=!zspec_data_root+'/apexnc/*/APEX-'+obs+'*'+'_spec.sav'
   spawn,'ls '+savfile,savresult   
   if savresult[0] NE '' then begin
     if ~keyword_set(rerun) then begin
         message,'Found .sav file for '+obs,/info
     endif else begin
         message,'Rerunning zapex for '+obs,/info
       if chop_file EQ '1' then begin
           zapex,obs,1,2
       endif else begin
           chopfile=!zspec_data_root+'/apexnc/*/APEX-'+chop_file+'*_chopphase.sav'
           spawn,'ls '+chopfile,chopresult
           if n_e(chopresult) NE 1 then message,'Why did I find more than one chopphase?'
           if chopresult[0] EQ '' then $
             message,'Chop file not found.  Run zapex separately on the phase observation first.' $
           else $
             restore,chopresult[0]
           zapex,obs,rel_phase,2
       endelse
     endelse
   endif else begin

; SEARCH FOR THE .FITS FILE
; USE GAD IF THE .FITS DIRECTORY CANNOT BE FOUND
; Oh hey, guess what, you need to be in the right date's directory, gah.

       fitsdir=!zspec_data_root+'/apexnc/*/APEX-'+obs+'*.nc'
       spawn,'ls '+fitsdir,fitsresult
       if fitsresult[0] NE '' then begin
           message,'Found fits dir for '+obs,/info
           if keyword_set(regad) then begin
               cd,!zspec_data_root+'/apexnc/'
               spawn,'gadp '+obs+' '+proj
           endif
       endif else begin
           ; Go to the observations directory
           cd,!zspec_data_root+'/apexnc/'
           ; Get the files into that directory
           spawn,'gadp '+obs+' '+proj
           ; Move them into the proper day's directory. OBSOLETE.
           ;spawn,'ls *'+obs[i]+'*',rawfiles
           ; Find the right date...
           ;split=STRSPLIT(rawfiles[0],'-',/extract)
           ;date=split[2]+split[3]+split[4]
           ;spawn,'mv *'+obs[i]+'* '+date
       endelse


; NOW THAT .FITS FILES ARE ACQUIRED, RUN ZAPEX
       ; First restore the chopphase file
       ; Unless you want to use 1...
       if chop_file EQ '1' then begin
           zapex,obs,1,2
       endif else begin
           chopfile=!zspec_data_root+'/apexnc/*/APEX-'+chop_file+'*_chopphase.sav'
           spawn,'ls '+chopfile,chopresult
           if n_e(chopresult) NE 1 then message,'Why did I find more than one chopphase?'
           if chopresult[0] EQ '' then $
             message,'Chop file not found.  Run zapex separately on the phase observation first.' $
           else $
print,obs
             restore,chopresult[0]
;rel_phase=chop_file[i]
;phil korngut commented out the above line and changed it to :
rel_phase=chop_file
           zapex,obs,rel_phase,2
       endelse
   endelse

;endfor
spawn,'ls '+savfile,savresult
;message,'Congrats, you should be ready to run uber_spectrum on this coadd list.',/info
cd,currdir

end
