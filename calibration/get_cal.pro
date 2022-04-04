
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
; 01/11/10 - KSS - Modified from get_cal_mb.pro to use cal_corr_file,
;            when provided.
; 05/10/10 - KSS - Updated calibration for Spring 2010
; 05/13/10 - KSS - Updated calibration for Winter 2009
; 09/06/10 - KSS - Revised calibrations for Spring2007, Winter2009,
;            and Spring2010 to use curve determined from all planets
;            (Mars, Neptune, and Uranus)
;                - Cleaned up some code, removing unnecessary case
;                  statements and recurring calculations
;                - Changed default calibration to Spring 2010
; 19/10/10 - REL Make it deal with APEX data
; 21/10/10 - JRK APEX data now by default uses calibration_obs_fall10_fitparams.sav
; 01/04/11 - REL added Uranus calibration for winter 2011
; 12/19/12 - KSS Committed latest version to svn

function get_cal, year, month, night, obs, cal_corr_file=cal_corr_file, apex=apex, vdc=vdc, return_fitpars=return_fitpars, return_file=return_file

;Did user supply cal_corr_file?
if keyword_set(cal_corr_file) then tie = 1 else tie = 0

;Determine which calibration curve to use, and get it
if ~keyword_set(apex) then  begin
case year of
    
    2007: begin
        if month le 5 then begin
                                ;Spring 2007
            file='calibration_obs_spring07_fitparams.sav'
            if keyword_set(return_file) then return, file
            restore,!zspec_pipeline_root+$
              '/calibration/'+file
            cal_constants = fitpars_all
            dev = rms_dev_all
            vector = cal_from_dcbolo(year,month,night,obs,a=cal_constants)
        endif
                                ;Winter 2007
        if month gt 10 then begin
            file='calibration_obs_winter07_fitparams.sav'
            if keyword_set(return_file) then return, file
            restore,!zspec_pipeline_root+$
              '/calibration/'+file
            cal_constants = reform(fitpars[*,0,*])
            dev = rms_dev[*,0]
            vector = cal_from_dcbolo(year,month,night,obs,a=cal_constants)
        endif
    end

    2008: begin
                                ;All of 2008 (need to update?)
                                ;If no cal_corr file, use spring2008 curve
        if (tie eq 0) then begin
            file='calibration_obs_spring08_fitparams.sav'
            if keyword_set(return_file) then return, file
            restore,!zspec_pipeline_root+$
              '/calibration/'+file
            cal_constants = reform(fitpars[*,0,*])
            dev = rms_dev[*,0]
            vector = cal_from_dcbolo(year,month,night,obs,a=cal_constants)
        endif else begin
                                ;otherwise, use spring2007 curve,
                                ;assuming corrections are based off
                                ;that
            file='calibration_obs_spring07_fitparams.sav'
            if keyword_set(return_file) then return, file
            restore,!zspec_pipeline_root+$
              '/calibration/'+file
            cal_constants = fitpars_all
            dev = rms_dev_all
            vector = cal_from_dcbolo(year,month,night,obs,a=cal_constants)
        endelse
    end

    2009: begin 
                                ;First part - same as 2008
        if (month le 10) then begin
                                ;use Spring 2008
            if (tie eq 0) then begin
                file='calibration_obs_spring08_fitparams.sav'
                if keyword_set(return_file) then return, file
                restore,!zspec_pipeline_root+$
                  '/calibration/'+file
                cal_constants = reform(fitpars[*,0,*])
                dev = rms_dev[*,0]
                vector = cal_from_dcbolo(year,month,night,obs,a=cal_constants)
            endif else begin
                                ;other wise, use spring 2007 plus
                                ;correction
                file='calibration_obs_spring07_fitparams.sav'
                if keyword_set(return_file) then return, file
                restore,!zspec_pipeline_root+$
                  '/calibration/'+file
                cal_constants = fitpars_all
                dev = rms_dev_all
                vector = cal_from_dcbolo(year,month,night,obs,a=cal_constants)
            endelse
        endif else begin
                                ;Winter 2009
            file='calibration_obs_winter09_fitparams.sav'
            if keyword_set(return_file) then return, file
            restore,!zspec_pipeline_root+$
              '/calibration/'+file
            cal_constants = fitpars_all
            dev = rms_dev_all
            vector = cal_from_dcbolo(year,month,night,obs,a=cal_constants)
        endelse

    end

    2010: begin
                                ;Spring 2010
        file='calibration_obs_spring10_fitparams.sav'
        if keyword_set(return_file) then return, file
        restore,!zspec_pipeline_root+$
          '/calibration/'+file
        cal_constants = fitpars_all
        dev = rms_dev_all
        vector = cal_from_dcbolo(year,month,night,obs,a=cal_constants)

    end


;Default is to use the spring 2010 calibration, which is the best determined,
;if perhaps not always the most appropriate.
    else : begin 
        message,/info,'Using Spring 2010 calibration.'
        file='calibration_obs_spring10_fitparams.sav'
        if keyword_set(return_file) then return, file
        restore,!zspec_pipeline_root+$
          '/calibration/'+file
        cal_constants = fitpars_all
        dev = rms_dev_all
        vector = cal_from_dcbolo(year,month,night,obs,a=cal_constants)
    end
endcase

endif else begin ; APEX CASE--------------
;print,'Calibration work in progress. Need V DC.'
;stop
;        message,/info,'Using Spring 2010 calibration for APEX data.'
;        restore,!zspec_pipeline_root+$
;          '/calibration/calibration_obs_spring10_fitparams.sav'
;        a = fitpars_all
;        dev = rms_dev_all

case year of
2010:  begin 
    file='calibration_obs_fall10_fitparams.sav'
    if keyword_set(return_file) then return, file
    restore,!zspec_pipeline_root+'/calibration/'+file
end
2011: if (month lt 4) then  begin
    file='calibration_obs_winter11_fitparams.sav'
    if keyword_set(return_file) then return, file
    restore,!zspec_pipeline_root+'/calibration/'+file
endif else begin
    file='calibration_obs_may11_fitparams.sav'
    if keyword_set(return_file) then return, file
    restore,!zspec_pipeline_root+'/calibration/'+file
endelse
2012: begin
    file='calibration_obs_nov12_fitparams.sav'
    if keyword_set(return_file) then return, file
    restore,!zspec_pipeline_root+'/calibration/'+file
endelse
2014: begin
    file='calibration_obs_20141006_fitparams.sav'
    if keyword_set(return_file) then return, file
    restore,!zspec_pipeline_root+'/calibration/'+file
end

endcase
    cal_constants=fitpars_all;reform(fitpars[0:159,0,0:1])
    dev=rms_dev_all;rms_dev[0:159,0]
    a=cal_constants

    if keyword_set(return_fitpars) then return, a

;;need to calculate vdc here, or get it from the .sav file
	n_nods=n_e(vdc[*,0])
	vector=fltarr(160,n_nods)
	for ch=0,159 do for nod=0,n_nods-1 do vector[ch,nod]=a[ch,0]+a[ch,1]*vdc[nod,ch]
        ;vector = cal_from_dcbolo_apex(year,month,night,obs,a=cal_constants)
;stop
endelse

;Use cal corr file?
if (tie eq 1) then begin
    restore,!zspec_pipeline_root+'/calibration/cal_corr_files/'+$
      cal_corr_file+'_calcor.sav'
    vector *= discrepancy
endif

;rms deviation
dev *= vector

;create and return calibration vector
calibration_vector = create_struct('cal',vector, 'rmsdev',dev)

return, calibration_vector

end
