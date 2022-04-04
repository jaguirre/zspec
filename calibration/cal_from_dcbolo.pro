function cal_from_dcbolo,year,month,night,obs,a=a

if ~keyword_set(a) then begin
    restore,!zspec_pipeline_root+$
      '/calibration/calibration_obs_spring07_fitparams.sav'
    a=reform(fitpars[*,0,*])
endif

vdc=get_quad_sum(year,month,night,obs)

n_nods=n_e(vdc[*,0])

cal=fltarr(160,n_nods)

for ch=0,159 do begin
    
    for nod=0,n_nods-1 do begin

        cal[ch,nod]=a[ch,0]+a[ch,1]*vdc[nod,ch]

    endfor

endfor

return,cal

end

