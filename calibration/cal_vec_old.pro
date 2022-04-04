; A combo calibration function that returns a 160 element vector
; with the flux of a calibration source in the specified units.
; The currently defined options are as follows:
;
; SOURCE = 0 [DEFAULT] - flux of planet mars
;          1 - flux of planet uranus
;          3 - flux of planet neptune
; 
; UNIT = 0 [DEFAULT] - flux in janskys
;        1 - flux in kelvin km sec^-1

FUNCTION cal_vec_old, year, month, night, $
                  SOURCE = SOURCE, $
                  UNIT = UNIT

  temp = cal_temp(year,month,night, SOURCE = SOURCE)

  IF ~KEYWORD_SET(UNIT) THEN UNIT = 0

  IF (UNIT EQ 0) THEN BEGIN
;     cal = 2.*temp*1.381e+3/(!pi*10.4^2/4)
      ;use effective diameter of telescope derived from beammmap fits
      cal = 2.*temp*1.381e+3/(!pi*7.26^2/4)
  ENDIF ELSE IF (UNIT EQ 1) THEN BEGIN
     freq=freqid2freq()
     deltav=freqid2bw() / freq * 2.9979e5 
     cal = temp*deltav
  ENDIF ELSE BEGIN
     PRINT, 'Unit = ', UNIT, $
            ' is not defined in cal_vec.  Stopping.'
     STOP
  ENDELSE

  RETURN, cal
END
