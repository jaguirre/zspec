;updated by LE April 2008

;written by LE

;This function computes linear fits for each planet for the
;transmission-corrected data
;
;08/30/10 - KSS - Added keyword option FITALL
;               - Fixed bug in chi^2/dof calc for neptune
;12/19/2012 - KSS - Committed latest revisions to svn

function flux_calibration_linear_fits,calfile,fitall=fitall,flag=flag

fitparfile=change_suffix(calfile,'_fitparams.sav')

restore,!zspec_pipeline_root+'/calibration/'+calfile
savefilename=!zspec_pipeline_root+'/calibration/'+fitparfile

;________________________________________________________________________
;LINEAR FIT TO 3 PLANETS SEPARATELY

;linear fit parameters
fitpars=fltarr(160,3,2)

;these will be reduced chi^2 values
chi_sq_vals=fltarr(160,3)

;these will be the RMS fractional deviation
rms_dev=fltarr(160,3)

;______________________________________________________________________
;COMPUTE LINEAR FITS

for bolo=0,159 do begin

    ;fit mars data
    if mars_obs eq 1 then begin
        dum=1
        goodmars=plotmars(where(cal_total[bolo,plotmars] gt 0))
        dumx=reform(vbolo_quad_total[goodmars,bolo])
        dumy=reform(cal_total[bolo,goodmars])
        dumz=reform(err_total[bolo,goodmars])
        use=where(finite(dumx) and finite(dumy) and finite(dumz))
        if use(0) ne -1 then begin
        dumx=dumx(use)
        dumy=dumy(use)
        dumz=dumz(use)
        endif
        fitpars[bolo,0,*]=linfit(dumx,$
          dumy,$
          measure_errors=dumz,yfit=yvals)

        dif=0
        frac=0
        for q=0,n_e(goodmars)-1 do begin
            dif+=((yvals[q]-cal_total[bolo,goodmars[q]])/$
              err_total[bolo,goodmars[q]])^2
            frac+=((yvals[q]-cal_total[bolo,goodmars[q]])/yvals[q])^2.
        endfor
        chi_sq_vals[bolo,0]=dif/(n_e(goodmars)-2)
        rms_dev[bolo,0]=(frac/n_e(goodmars))^.5
    endif else begin
        fitpars[*,0,*]=0
        chi_sq_vals[*,0]=0
        rms_dev[*,0]=0
    endelse

        
    ;fit uranus data
    if uranus_obs eq 1 then begin
        dum=where(cal_total[bolo,ploturanus] gt 0)
        if dum(0) ne -1 then begin
            gooduranus=ploturanus(dum)
        dumx=reform(vbolo_quad_total[gooduranus,bolo])
        dumy=reform(cal_total[bolo,gooduranus])
        dumz=reform(err_total[bolo,gooduranus])
        use=where(finite(dumx) and finite(dumy) and finite(dumz))
        if use(0) ne -1 then begin
        dumx=dumx(use)
        dumy=dumy(use)
        dumz=dumz(use)
        endif
        fitpars[bolo,1,*]=linfit(dumx,$
           dumy,$
           measure_errors=dumz,yfit=yvals)

        dif=0
        frac=0
        for q=0,n_e(gooduranus)-1 do begin
            dif+=((yvals[q]-cal_total[bolo,gooduranus[q]])/$
              err_total[bolo,gooduranus[q]])^2
            frac+=((yvals[q]-cal_total[bolo,gooduranus[q]])/yvals[q])^2.
        endfor
        chi_sq_vals[bolo,1]=dif/(n_e(gooduranus)-2)
        rms_dev[bolo,1]=(frac/n_e(gooduranus))^.5
           endif else begin
            fitpars[bolo,1,*]=0
            chi_sq_vals[bolo,1]=0
            rms_dev[bolo,1]=0   
           endelse
    endif else begin
        fitpars[*,1,*]=0
        chi_sq_vals[*,1]=0
        rms_dev[*,1]=0
    endelse



     ;fit neptune data
     if neptune_obs eq 1 then begin       
         dum=where(cal_total[bolo,plotnep] gt 0)
        if dum(0) ne -1 then begin
        goodnep=plotnep(dum)
        dumx=reform(vbolo_quad_total[goodnep,bolo])
        dumy=reform(cal_total[bolo,goodnep])
        dumz=reform(err_total[bolo,goodnep])
        use=where(finite(dumx) and finite(dumy) and finite(dumz))
        if use(0) ne -1 then begin
        dumx=dumx(use)
        dumy=dumy(use)
        dumz=dumz(use)
        endif
        fitpars[bolo,2,*]=linfit(dumx,$
           dumy,$
           measure_errors=dumz,yfit=yvals)

        dif=0
        frac=0
        for q=0,n_e(goodnep)-1 do begin
            dif+=((yvals[q]-cal_total[bolo,goodnep[q]])/$
              err_total[bolo,goodnep[q]])^2
            frac+=((yvals[q]-cal_total[bolo,goodnep[q]])/yvals[q])^2.
        endfor
        chi_sq_vals[bolo,2]=dif/(n_e(goodnep)-2)
        rms_dev[bolo,2]=(frac/n_e(goodnep))^.5        
           endif else begin
            fitpars[bolo,1,*]=0
            chi_sq_vals[bolo,1]=0
            rms_dev[bolo,1]=0   
           endelse
   endif else begin
        fitpars[*,2,*]=0
        chi_sq_vals[*,2]=0
        rms_dev[*,2]=0
    endelse

    ;fit them all together?
    ;if bolo ne 5 then begin
    if keyword_set(fitall) then begin
        if dum(0) ne -1 then begin
        if (bolo eq 0) then begin
            fitpars_all = dblarr(160, 2)
            chi_sq_vals_all = dblarr(160)
            rms_dev_all = dblarr(160)
        endif
        dumx=reform(vbolo_quad_total[*,bolo])
        dumy=reform(cal_total[bolo,*])
        dumz=reform(err_total[bolo,*])
        use=where(finite(dumx) and finite(dumy) and finite(dumz))
        if use(0) ne -1 then begin
        dumx=dumx(use)
        dumy=dumy(use)
        dumz=dumz(use)
        endif
        fitpars_all[bolo,*] = linfit(dumx, $
                                     dumy, $
                                     measure_errors=dumz, $
                                     yfit=yvals)
        dif=0
        frac=0
        for q=0, n_e(yvals)-1 do begin
            dif+=( (yvals[q]-cal_total[bolo,q]) / err_total[bolo,q] )^2
            frac+=( (yvals[q]-cal_total[bolo,q]) / yvals[q] )^2.
        endfor
        chi_sq_vals_all[bolo] = dif / (n_e(yvals)-2)
        rms_dev_all[bolo] = (frac/n_e(yvals))^.5
        endif
    endif
   ;endif

endfor
    
;_______________________________________________________________________
;CREATE .SAV FILE

if not keyword_set(fitall) then $
  save,file=savefilename,fitpars,chi_sq_vals,rms_dev $
else save,file=savefilename,fitpars,chi_sq_vals,rms_dev, $
  fitpars_all, chi_sq_vals_all, rms_dev_all

return,fitpars

end
