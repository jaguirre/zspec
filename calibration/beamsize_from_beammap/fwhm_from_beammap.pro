;work in progress 2008-03-02 LE 

;this function returns the fwhm beam size for a given frequency.  The
;beam size is determined from fitting (1.02+f(lambda))*lamda/d_eff to
;Hanae's results from the 2-d gaussian fits to get sigmas from the
;beammaps taken on 20070516_021.

;note frequency input in GHz, output beam size in radians

function fwhm_from_beammap,ghz

restore,!zspec_pipeline_root+$
  '/calibration/beamsize_from_beammap/beamwidth.sav'

lambda=29.979/ghz
fwhm=((1.02+(alpha*lambda))*lambda/D_eff)

return,fwhm

stop

end



