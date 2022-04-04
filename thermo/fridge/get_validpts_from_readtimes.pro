; This function returns the indicies of all the good data points in
; a vector of read times from fridge data.  This is necessary
; because sometimes data taking is restarted and the data logging software
; appends to an existing file instead of starting a new one.  This
; function only works on read time columns that are NOT the first column
; in a file.
FUNCTION get_validpts_from_readtimes, readtimes
  GOOD = 1.0
  BAD = 0.0
  nreadtimes = N_ELEMENTS(readtimes)
  mask = REPLICATE(GOOD,nreadtimes)
  FOR i = 0L, nreadtimes-1 DO BEGIN
     ; Nominal readtime is 'MM/DD/YY HH:MM:SS [AM or PM]'
     temp = strsplit(readtimes[i],' ',/EXTRACT)
     IF N_E(temp) NE 3 THEN mask[i] = BAD
  ENDFOR
  goodpts = WHERE(mask EQ GOOD,ngoodpts)
  IF ngoodpts EQ 0 THEN BEGIN
     MESSAGE, /INFO, 'No valid points found.  Stopping'
     STOP
  ENDIF
  RETURN, goodpts
END
