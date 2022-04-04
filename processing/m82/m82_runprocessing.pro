; Use this script to reprocess demodulated M82 data 
; (from calibration to fitting to plotting)
; USE WITH CAUTION - set up all called scripts before this script is called.

; TO USE copy the following lines to the IDL shell

run_save_spectra, /cont, /psd, /save_ts, rel_phase = 1, $
                  date = '20060414', obsnum_start = 6, obsnum_end = 14
run_save_spectra, /cont, /psd, /save_ts, rel_phase = 1, $
                  date = '20060416', obsnum_start = 1, obsnum_end = 4
run_save_spectra, /cont, /psd, /save_ts, rel_phase = 1, $
                  date = '20060416', obsnum_start = 6, obsnum_end = 11
.run m82_concat
.run m82_cofix
.run m82_joinpointing
.run m82_ploterr2
.run m82_nodhist
.run m82_senshist
.run m82_fitspec
.run m82_plotfit

; Use this section to process quadrature rather than optimum voltage
run_save_quad_spectra, /cont, /psd, /save_ts, rel_phase = 1, $
                       date = '20060414', obsnum_start = 6, obsnum_end = 14
run_save_quad_spectra, /cont, /psd, /save_ts, rel_phase = 1, $
                       date = '20060416', obsnum_start = 1, obsnum_end = 4
run_save_quad_spectra, /cont, /psd, /save_ts, rel_phase = 1, $
                       date = '20060416', obsnum_start = 6, obsnum_end = 11
.run m82_quad_concat
.run m82_cofix
.run m82_joinpointing
.run m82_ploterr2
.run m82_nodhist
.run m82_senshist
.run m82_fitspec
.run m82_plotfit

