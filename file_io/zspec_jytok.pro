function zspec_jytok,jy,freq,beamsize

; Edited 7/1/09 by JRK, was using total telescope area, not effective.
; Now use RJ limit with omega from beammap
; Edited 12/17/09 by JRK to allow to input a beamsize (ie if not using
; z-spec beam.
; Edited 6/30/10 by JRK, fixed bug

h=6.626e-34   ;Js
k=1.381e-23   ;J/K
c=299792458.0 ;m/s

;A=!pi*(10.4/2)^2.

IF ~KEYWORD_SET(BEAMSIZE) THEN BEGIN
    beam=fwhm_from_beammap(freq) ;radians
ENDIF ELSE BEGIN
    beam = BEAMSIZE
    beam /=(180./!PI) * 3600. ; convert to radians
ENDELSE

omega=fwhm_to_beam_area(beam)  ;sr

S=jy*1.e-26
nu=freq*1.e9

;numerator=h*nu
;denominator=k*alog((2.*h*nu^3*omega)/(c^2*S)+1.)

;temp=numerator/denominator

;In the R-J limit this is

;temp=S*A/(2*k)

temp=S*c^2/(k*omega*2*nu^2)

return,temp

end
