FUNCTION cal_temp, year, month, night, SOURCE = SOURCE
  IF ~KEYWORD_SET(SOURCE) THEN SOURCE = 0
  
  case source of 
      0:temp=mars_temperature(night+100L*month+10000L*year)
      1:temp=uranus_temperature(night+100L*month+10000L*year)
;     2:temp=jupiter_temperature(night+100L*month+10000L*year)
      3:temp=neptune_temperature(night+100L*month+10000L*year)
  else:message,'source is not defined in cal_vec.'
  endcase


;  IF (SOURCE EQ 0) THEN BEGIN
;     temp = mars_temperature(night + 100L*month + 10000L*year)
;  ENDIF ELSE IF (SOURCE EQ 1) THEN BEGIN
;     temp = uranus_temperature(night + 100L*month + 10000L*year)
;  ENDIF ELSE BEGIN
;     PRINT, 'Source = ', SOURCE, ' is not defined in cal_temp.  Stopping'
;     STOP
;  ENDELSE
  RETURN, temp
END
