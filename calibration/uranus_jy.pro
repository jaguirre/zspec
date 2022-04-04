function uranus_jy, date, apex = apex
; Updated 8 January 2010, MB. Now using the measured solid angle for
; the conversion from Temp to Jy.

; returns a 160-element vector with the flux of uranus as a function of UT date

temp=uranus_temperature(date,/apex)
;bandwidth=bolo2bw(findgen(160))
;freq=bolo2freq(findgen(160))*0.988
;fluxdensity=2.*temp*1.381e+3/(!pi*10.4^2/4)

RESTORE, !ZSPEC_PIPELINE_ROOT + $
         '/line_cont_fitting/ftsdata/normspec_nov.sav'
beam_size=fwhm_from_beammap(freqid2freq())*206265.
if (keyword_set(apex)) then beam_size *= 10.4/12.
omega=!pi*(beam_size/206265.)^2/4./alog(2.)
fluxdensity = 2*temp*1.381e5*(freqid2freq()/2.9979)^2*omega

return,fluxdensity
end
