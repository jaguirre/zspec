;This function computes linear fits for each planet for the
;transmission-corrected data then computes multiplicative factors to
;scale the Neptune and Uranus fits to match the Mars fit.

;updated 3-3-08 LE
;now nolonger computes scaling factors to match uranus and neptune to mars

function fit_to_mars,calfile,sortfile

;common commonc, goodmars,gooduranus,goodnep,fitpars,cal_total,$
;  vbolo_quad_total,bolo

fitparfile=change_suffix(calfile,'_marsfit.sav')

restore,!zspec_pipeline_root+'/calibration/'+calfile
restore,!zspec_pipeline_root+'/calibration/'+sortfile
savefilename=!zspec_pipeline_root+'/calibration/'+fitparfile

;________________________________________________________________________
;LINEAR FIT TO 3 PLANETS SEPARATELY

;linear fit parameters
fitpars=dblarr(160,3,2)

;these will be reduced chi^2 values
chi_sq_vals=dblarr(160,3)

;______________________________________________________________________
;COMPUTE LINEAR FITS

for bolo=0,159 do begin

    ;fit mars data
        goodmars=plotmars(where(cal_total[bolo,plotmars] gt 0))
        fitpars[bolo,0,*]=linfit(vbolo_quad_total[goodmars,bolo],$
          cal_total[bolo,goodmars],yfit=yvals)

        dif=0
        for q=0,n_e(goodmars)-1 do begin
            dif+=((yvals[q]-cal_total[bolo,goodmars[q]])/$
              err_total[bolo,goodmars[q]])^2
        endfor
        chi_sq_vals[bolo,0]=dif/(n_e(goodmars)-2)
        
    ;fit uranus data
        gooduranus=ploturanus(where(cal_total[bolo,ploturanus] gt 0))
        fitpars[bolo,1,*]=linfit(vbolo_quad_total[gooduranus,bolo],$
           cal_total[bolo,gooduranus],yfit=yvals)

        dif=0
        for q=0,n_e(gooduranus)-1 do begin
            dif+=((yvals[q]-cal_total[bolo,gooduranus[q]])/$
              err_total[bolo,gooduranus[q]])^2
        endfor
        chi_sq_vals[bolo,1]=dif/(n_e(gooduranus)-2)

     ;fit neptune data
        goodnep=plotnep(where(cal_total[bolo,plotnep] gt 0))
        fitpars[bolo,2,*]=linfit(vbolo_quad_total[goodnep,bolo],$
           cal_total[bolo,goodnep],yfit=yvals)

        dif=0
        for q=0,n_e(goodnep)-1 do begin
            dif+=((yvals[q]-cal_total[bolo,goodnep[q]])/$
              err_total[bolo,goodnep[q]])^2
        endfor
        chi_sq_vals[bolo,2]=dif/(n_e(goodnep)-2)

    endfor
    
;______________________________________________________________________
;COMPUTE SCALING FACTOR TO CORRECT NEPTUNE AND URANUS FITS TO MARS

;scale_facs=scale_neptune_uranus_to_mars(calfile)

;_______________________________________________________________________
;CREATE .SAV FILE

;save,file=savefilename,scale_facs,fitpars,chi_sq_vals
save,file=savefilename,fitpars,chi_sq_vals

;return,scale_facs
return,fitpars

end
