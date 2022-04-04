;handy little wrapper to do the flux calibration, linear fits, and 
;make plots
;
;calfile - [string] ascii file giving list of calibration observations
;          (e.g. calibration_obs_spring10.txt)

;created 09/02/10 by KSS
;added apex and run keywords 10/21/10 JRK

pro flux_calibration_wrapper, calfile, apex=apex, run=ruN

calfile_org = calfile
message,/cont,'Running FLUX_CALIBRATION'
flux_calibration, calfile, apex=apex, run=run

message,/cont,'Running FLUX_CALIBRATION_LINEAR_FITS'
savfile = repstr(calfile_org, '.txt', '.sav')
result = flux_calibration_linear_fits(savfile, /fitall)

message,/cont,'Running PLOT_CALIBRATION'
plot_calibration, savfile

end
