;This function computes linear fits for each planet for both
;the sky-corrected and uncorrected cases and saves the result in
;planetdata.sav.

function cal_spring07_linefit

restore,!zspec_pipeline_root+'/calibration/calibration_obs_spring07.sav'
savefilename=!zspec_pipeline_root+'/calibration/planetdata.sav'

;mask=mask_crappy_data(1.5,/nosky)
;skymask=mask_crappy_data(1.5)
mask=intarr(160,120)+1
skymask=mask

;________________________________________________________________________
;LINEAR FIT TO 3 PLANETS SEPARATELY

;linear fit parameters
fitpars=dblarr(160,3,2)
fitpars_nosky=fitpars

;these will be reduced chi^2 values
chi_sq_vals=dblarr(160,3)
chi_sq_vals_nosky=dblarr(160,3)

;___________________________________________________________________
;SORT DATA BY PLANET

    ;mars
        marsobs=where(source eq 0)
        for i=0,n_e(marsobs)-1 do begin
            if i eq 0 then begin
                plotmars=where(which_obs eq marsobs[i])
            endif else begin
                plotmars_temp=where(which_obs eq marsobs[i])
                plotmars=[plotmars,plotmars_temp]
            endelse
        endfor

    ;uranus   
        uranusobs=where(source eq 1)
        for i=0, n_e(uranusobs)-1 do begin
            if i eq 0 then begin
                ploturanus=where(which_obs eq uranusobs[i])
            endif else begin
                ploturanus_temp=where(which_obs eq uranusobs[i])
                ploturanus=[ploturanus,ploturanus_temp]
            endelse
        endfor

    ;neptune
        neptuneobs=where(source eq 3)
        for i=0, n_e(neptuneobs)-1 do begin
            if i eq 0 then begin
                plotnep=where(which_obs eq neptuneobs[i])
            endif else begin
                plotnep_temp=where(which_obs eq neptuneobs[i])
                plotnep=[plotnep,plotnep_temp]
            endelse
        endfor
        
;______________________________________________________________________
;COMPUTE LINEAR FITS

for bolo=0,159 do begin

    ;fit mars data

        ;sky-corrected data
        goodmars=plotmars(where(cal_total_sky[bolo,plotmars] gt 0 and $
                    skymask[bolo,plotmars] eq 1))
        fitpars[bolo,0,*]=linfit(vbolo_quad_total[goodmars,bolo],$
          cal_total_sky[bolo,goodmars],yfit=yvals)

        dif=0
        for q=0,n_e(goodmars)-1 do begin
            dif=((yvals[q]-cal_total_sky[bolo,goodmars[q]])/$
              err_total_sky[bolo,goodmars[q]])^2
            dif+=dif
        endfor
        chi_sq_vals[bolo,0]=dif/(n_e(goodmars)-2)
        
        ;non-sky-corrected data
        goodmars=plotmars(where(cal_total[bolo,plotmars] gt 0 and $
                     mask[bolo,plotmars] eq 1))
        fitpars_nosky[bolo,0,*]=$
          linfit(vbolo_quad_total[goodmars,bolo],$
          cal_total[bolo,goodmars],yfit=yvals)
        
        dif=0
        for q=0,n_e(goodmars)-1 do begin
            dif=((yvals[q]-cal_total[bolo,goodmars[q]])/$
              err_total[bolo,goodmars[q]])^2
            dif+=dif
        endfor
        chi_sq_vals_nosky[bolo,0]=dif/(n_e(goodmars)-2)

     ;fit uranus data

        ;sky-corrected data
        gooduranus=ploturanus(where(cal_total_sky[bolo,ploturanus] gt 0 and $
                     skymask[bolo,ploturanus] eq 1))
        fitpars[bolo,1,*]=linfit(vbolo_quad_total[gooduranus,bolo],$
           cal_total_sky[bolo,gooduranus],yfit=yvals)

        dif=0
        for q=0,n_e(gooduranus)-1 do begin
            dif=((yvals[q]-cal_total_sky[bolo,gooduranus[q]])/$
              err_total_sky[bolo,gooduranus[q]])^2
            dif+=dif
        endfor
        chi_sq_vals[bolo,1]=dif/(n_e(gooduranus)-2)

        ;non-sky-corrected data
        gooduranus=ploturanus(where(cal_total[bolo,gooduranus] gt 0 and $
                     mask[bolo,ploturanus] eq 1))
        fitpars_nosky[bolo,1,*]=$
          linfit(vbolo_quad_total[gooduranus,bolo],$
          cal_total[bolo,gooduranus],yfit=yvals)

        dif=0
        for q=0,n_e(gooduranus)-1 do begin
            dif=((yvals[q]-cal_total[bolo,gooduranus[q]])/$
              err_total[bolo,gooduranus[q]])^2
            dif+=dif
        endfor
        chi_sq_vals_nosky[bolo,1]=dif/(n_e(gooduranus)-2)

      ;fit neptune data

        ;sky-corrected data
        goodnep=plotnep(where(cal_total_sky[bolo,plotnep] gt 0 and $
                   skymask[bolo,plotnep] eq 1))
        fitpars[bolo,2,*]=linfit(vbolo_quad_total[goodnep,bolo],$
           cal_total_sky[bolo,goodnep],yfit=yvals)

        dif=0
        for q=0,n_e(goodnep)-1 do begin
            dif=((yvals[q]-cal_total_sky[bolo,goodnep[q]])/$
              err_total_sky[bolo,goodnep[q]])^2
            dif+=dif
        endfor
        chi_sq_vals[bolo,2]=dif/(n_e(goodnep)-2)

        ;non-sky-corrected data
        goodnep=plotnep(where(cal_total[bolo,plotnep] gt 0 and $
                   mask[bolo,plotnep] eq 1))
        fitpars_nosky[bolo,2,*]=linfit(vbolo_quad_total[goodnep,bolo],$
           cal_total[bolo,goodnep],yfit=yvals)

        dif=0
        for q=0,n_e(goodnep)-1 do begin
            dif=((yvals[q]-cal_total[bolo,goodnep[q]])/$
              err_total[bolo,goodnep[q]])^2
            dif+=dif
        endfor
        chi_sq_vals_nosky[bolo,2]=dif/(n_e(goodnep)-2)

endfor

;_______________________________________________________________________
;CREATE .SAV FILE

save,plotmars,ploturanus,plotnep,fitpars,fitpars_nosky,$
  chi_sq_vals,chi_sq_vals_nosky,err_total_sky,$
  err_total,file=savefilename

return,fitpars

end
