
; Take a .sav spectrum file and create a fits file
; with frequency, flux, error, sensitivity.
; JRK 10/16/09

pro sav_to_dat,savfile,datfile

; file includes directory, ie 'NGC4038N/NGC4038N.sav'

savfile=!zspec_pipeline_root+'/processing/spectra/coadded_spectra/'+savfile

restore,savfile

freqs=freqid2freq()

comment='# Frequency in Ghz, flux density in Jy, error in Jy, sensitivity in Jy s^1/2'

forprint,freqs,uber_psderror.in1.avespec,uber_psderror.in1.aveerr,$
   uber_psderror.in1.aveerr*sqrt(total_n_sec),text=datfile,$
   comment=comment


end
