;This funtion makes a linear fit to all the planetary calibration
;data.  Multiplicative factors are computed to scale the Neptune and
;Uranus data up to be more consistent with the Mars data.

function scale_cals

restore,!zspec_pipeline_root+'/calibration/planetdata.sav'
restore,!zspec_pipeline_root+'/calibration/calibration_obs_spring07.sav'

common commonb, plotmars,ploturanus,plotnep,fitpars,$
  cal_total_sky,cal_total,vbolo_quad_total,bolo

p_facs=fltarr(160,5)

for bolo=0,159 do begin

trial=[fitpars[bolo,0,0],fitpars[bolo,0,1],0.9,0.8]

mogulbear=amoeba(1.e-8,scale=1.,P0=trial,function_value=fval,$
                function_name='linefit_func')

if n_elements(mogulbear) eq 1 then message,'amoeba failed to converge'

;record results

p_facs[bolo,0:3]=mogulbear
p_facs[bolo,4]=fval[0]

endfor

return,p_facs

end
