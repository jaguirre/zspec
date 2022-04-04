; Created by BJN on 7/6/09 based on 7/1/2009 version of zspec_jytok by JRK

; If the keyword BEAMSIZE is not set, then Z-Spec's beam as
; measured by the beam map is used.  If it is set, then the value of
; BEAMSIZE is used for the calculation.  BEAMSIZE is assumed to be in
; units of arcseconds.

FUNCTION zspec_ktojy, temp, freq, BEAMSIZE
  
  k=1.381e-23                   ;J/K
  c=299792458.0                 ;m/s
  
  IF ~KEYWORD_SET(BEAMSIZE) THEN BEGIN
     beam=fwhm_from_beammap(freq) ;radians
  ENDIF ELSE BEGIN
     beam = BEAMSIZE
     beam /= (180./!PI) * 3600. ;convert to radians
  ENDELSE

  omega=fwhm_to_beam_area(beam) ;sr
  
  nu=freq*1.e9
  
  jy = (omega * (nu/c)^2) * 2 * k * temp * 1e26
  
  RETURN, jy
END
