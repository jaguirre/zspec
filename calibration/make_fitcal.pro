;  MB 20091201
; This procedure reads in a coaddition and a fit to those data and
; calculates the ratio then saves this as a cal_corr file.   This is
; useful for using fits to QSO data for spectral flat-fielding.
; index allows for multiple fits to the same data
; 12/19/2012 - KSS - Committed latest revisions to svn

pro make_fitcal,source,date,obs,index=index,mars=mars,uranus=uranus

if ~keyword_set(index) then index = '1'
if ~keyword_set(mars) then mars=0
if ~keyword_set(uranus) then uranus=0

datafile=!zspec_pipeline_root+'/processing/spectra/coadded_spectra/'+source+'/'+source+'_'+date+'_'+obs+'_nocalcorr_naive'+index+'.sav'
fitfile=!zspec_pipeline_root+'/processing/spectra/coadded_spectra/'+source+'/'+source+'_'+date+'_'+obs+'_nocalcorr_'+'fit'+index+'.sav'


restore,datafile

signal=uber_psderror.in1.avespec

restore,fitfile
fitsignal=fit.cspec

discrepancy=1./(fitsignal / signal)

if mars then begin
    freqs=freqid2freq()
    planet_flux=fltarr(160)
    use = where(freqs lt 270. and freqs gt 230.)
    if mars then planet_flux=mars_jy(long(date))
    if uranus then planet_flux=uranus_jy(long(date)) ; URANUS_JY NOT CORRECT YET Dec16,09 
    planet_tweak=mean(fitsignal[use]/planet_flux[use])
    discrepancy = discrepancy * planet_tweak
end

save,discrepancy,file=!zspec_pipeline_root+'/calibration/cal_corr_files/'+source+'_'+date+'_'+obs+'_nocalcorr_'+index+'_calcor.sav'

datfile=!zspec_pipeline_root+'/calibration/cal_corr_files/'+source+'_'+date+'_'+obs+'_nocalcorr_'+index+'_calcor.dat'

openw,unit,datfile,/get_lun
printf,unit,'Flux[Jy]: ' + string(fit.camp)
printf,unit,'Flux_err: '+string(fit.caerr)
printf,unit,'Index: '+string(fit.cexp)
printf,unit,'Index_err: '+string(fit.ceerr)
close,unit & free_lun,unit

;stop



end
