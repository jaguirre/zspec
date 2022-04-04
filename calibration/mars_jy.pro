function mars_jy, date, apex = apex

; returns a 160-element vector with the flux of mars as a function of UT date
;
; Updated 7 Jan 2010 MB to use the same solid angle as used in the
; calculation of the antenna temperature.   This should now give the
; flux of mars referred to a point source.


temp=mars_temperature(date,/apex)
;bandwidth=bolo2bw(findgen(160))
;freq=bolo2freq(findgen(160))*0.988
;fluxdensity=2.*temp*1.381e+3/(!pi*10.4^2/4)


RESTORE, !ZSPEC_PIPELINE_ROOT + $
         '/line_cont_fitting/ftsdata/normspec_nov.sav'

freq=freqid2freq()
beam_size=fwhm_from_beammap(freq)*206265.
; A kluge
if keyword_set(apex) then beam_size *= 10.4/12.

omega=!pi*(beam_size/206265.)^2/4./alog(2.)

fluxdensity = 2*temp*1.381e5*(freq/2.9979)^2*omega

 
return,fluxdensity
end
