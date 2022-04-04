;created by LE in April 2008

;This function is essentially a lookup table for the coefficients to
;the calibration equation Cal=mx+b, where x is the DC voltage.  

;set tie=1 in the first line if you want to use cal_corr files (this
;takes the spring 07 calibration and ties it to a current (08) Mars
;observation.

; Modified MB 20091201  
; Provide to this function the calcor file if you want to
; use it.   
;  This will eliminate the lookup-table type syntax, but now
; have to modify uber_spectrum to carry this as well for each obs (put
; a cal_corr file column in the
; coadd file list ( .txt) file.)
; have to generate the cal_corr files in advance (by hand) from either planet or
; QSO observations.
; cal_corr files are in /calibration/cal_corr_files directory, and are
; passed with format YYYYMMDD_OBS string format (for now)

; Still need to generate winter 08/09 and spring 09, winter 09/10
; calibration curves?


function get_cal,year,month,night,obs,cal_corr_file=cal_corr_file

tie=1
if ~keyword_set(cal_corr_file) then cal_corr_file='' 
if cal_corr_file eq '' then tie=0


case year of

   2007: begin
      if month le 5 then begin
         restore,!zspec_pipeline_root+$
                 '/calibration/calibration_obs_spring07_fitparams.sav'
         cal_constants=reform(fitpars[*,0,*])
         dev=rms_dev[*,0]
         vector=$
            cal_from_dcbolo(year,month,night,obs,a=cal_constants)

         restore,!zspec_pipeline_root+'/calibration/cal_corr_files/'+$
              cal_corr_file+'_calcor.sav'
           vector*=discrepancy

      endif
      
      if month gt 10 then begin
         restore,!zspec_pipeline_root+$
                 '/calibration/calibration_obs_winter07_fitparams.sav'
         cal_constants=reform(fitpars[*,0,*])
         dev=rms_dev[*,0]
         vector=$
            cal_from_dcbolo(year,month,night,obs,a=cal_constants)
      endif
  end


   2008: begin
      case tie of 
         0: begin
            restore,!zspec_pipeline_root+$
                    '/calibration/calibration_obs_spring08_fitparams.sav'
            cal_constants=reform(fitpars[*,0,*])
            dev=rms_dev[*,0]
            vector=$
               cal_from_dcbolo(year,month,night,obs,a=cal_constants)
         end
         1: begin
            restore,!zspec_pipeline_root+$
                    '/calibration/calibration_obs_spring07_fitparams.sav'
            cal_constants=reform(fitpars[*,0,*])
            dev=rms_dev[*,0]
            vector=$
               cal_from_dcbolo(year,month,night,obs,a=cal_constants)

            restore,!zspec_pipeline_root+'/calibration/cal_corr_files/'+$
              cal_corr_file+'_calcor.sav'
            
            

;             case month of 
;                3: begin
;                   if night eq 23 then begin ;choose one of the 3 below?
;                      restore,!zspec_pipeline_root+$
;                              '/calibration/cal_corr_files/20080323_007_calcor.sav'
;                                 ;restore,!zspec_pipeline_root+$
;                                 ;  '/calibration/cal_corr_files/20080323_008_calcor.sav'
;                                 ;restore,!zspec_pipeline_root+$
;                                 ;  '/calibration/cal_corr_files/20080323_013_calcor.sav'
;                   endif 
;                   if night eq 27 then begin
;                      restore,!zspec_pipeline_root+$
;                              '/calibration/cal_corr_files/20080327_013_calcor.sav'
;                   endif
;                   if night eq 29 then begin
;                      restore,!zspec_pipeline_root+$
;                              '/calibration/cal_corr_files/20080329_013_calcor.sav'
;                   endif 
;                   if night eq 30 then begin
;                      restore,!zspec_pipeline_root+$
;                              '/calibration/cal_corr_files/20080330_011_calcor.sav'
;                   endif
;                   if night eq 31 then begin
;                      restore,!zspec_pipeline_root+$
;                              '/calibration/cal_corr_files/20080331_009_calcor.sav'
;                   endif
;                   if night eq 27 then begin
;                      restore,!zspec_pipeline_root+$
;                              '/calibration/cal_corr_files/20080327_013_calcor.sav'
;                   endif
;                end
;                4: begin
;                   if night eq 8 then begin
;                      restore,!zspec_pipeline_root+$
;                              '/calibration/cal_corr_files/20080408_013_calcor.sav'
;                   endif
;                   if night eq 15 then begin
;                      restore,!zspec_pipeline_root+$
;                              '/calibration/cal_corr_files/20080415_004_calcor.sav'
;                   endif
;                   if night eq 16 then begin
;                      restore,!zspec_pipeline_root+$
;                              '/calibration/cal_corr_files/20080416_014_calcor.sav'
;                   endif
;                end
;            endcase

            vector*=discrepancy
        end
        endcase
    end

  2009: begin ; the same as 2008 for now.
      case tie of 
         0: begin
            restore,!zspec_pipeline_root+$
                    '/calibration/calibration_obs_spring08_fitparams.sav'
            cal_constants=reform(fitpars[*,0,*])
            dev=rms_dev[*,0]
            vector=$
               cal_from_dcbolo(year,month,night,obs,a=cal_constants)
         end
         1: begin
            restore,!zspec_pipeline_root+$
                    '/calibration/calibration_obs_spring07_fitparams.sav'
            cal_constants=reform(fitpars[*,0,*])
            dev=rms_dev[*,0]
            vector=$
               cal_from_dcbolo(year,month,night,obs,a=cal_constants)

            restore,!zspec_pipeline_root+'/calibration/cal_corr_files/'+$
              cal_corr_file+'_calcor.sav'
            
            vector*=discrepancy

        end
    endcase
end



; Default is to use the spring 2007 calibration, which is the best determined,
; if perhaps not always the most appropriate.
   else : begin 
      message,/info,'Using Spring 2007 calibration.'
      restore,!zspec_pipeline_root+$
              '/calibration/calibration_obs_spring07_fitparams.sav'
      cal_constants=reform(fitpars[*,0,*])
      dev=rms_dev[*,0]
      vector=$
         cal_from_dcbolo(year,month,night,obs,a=cal_constants)
   end
endcase

dev*=vector
calibration_vector=create_struct('cal',vector,$
                                 'rmsdev',dev)

return,calibration_vector

end



 
        
        

        
    
