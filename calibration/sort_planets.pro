
pro sort_planets,savfile

;this routine sorts the calibration data by planet

restore,!zspec_pipeline_root+'/calibration/'+savfile
savefilename=change_suffix(savfile,'_sorted_by_planet.sav')

;savefilename=!zspec_pipeline_root+'/calibration/sorted_by_planet.sav'

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

save,file=savefilename,plotmars,plotnep,ploturanus

end

