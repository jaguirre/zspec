; Procedure to do polynomial (or mean) subtraction on sliced data.
; Adds coefficients of polynomial subtracted off to sliced data structure
; and does subtraction to time element of data structure, unless
; NO_SUBTRACT is set.
;
; PARAMS: data - timestream data as sliced by slice_data
;
; KEYWORDS: POLY_DEG - degree of polynomial to subtract
;                     if POLY_DEG is not set or set to zero,
;                     then just do mean subtraction
;           NO_SUBTRACT - if set, just compute best fit polymonial (or mean)
;                         no data modification

PRO poly_subtract, data, POLY_DEG = POLY_DEG, NO_SUBTRACT = NO_SUBTRACT, quiet = quiet

  IF ~KEYWORD_SET(POLY_DEG) THEN POLY_DEG = 0

  IF POLY_DEG GT N_ELEMENTS(data[0].nod[0].pos[0].coeff)-1 THEN BEGIN
     MESSAGE, /INFO, 'Requested polymonial degree is too large to fit in ' + $
              'sliced data structure.  Stopping'
     STOP
  ENDIF

  nchan = N_ELEMENTS(data)
  nnod = N_ELEMENTS(data[0].nod)
  npos = N_ELEMENTS(data[0].nod[0].pos)
  FOR ch = 0, nchan-1 DO BEGIN
     IF ((ch MOD 10 EQ 0) and not(quiet)) THEN $
        MESSAGE, /INFO, 'Subtracting polynomial from channel ' + $
                 STRING(ch,F='(I0)')
     FOR nd = 0, nnod-1 DO BEGIN
        FOR ps = 0, npos-1 DO BEGIN
           ts = data[ch].nod[nd].pos[ps].time
           goodpts = WHERE(data[ch].nod[nd].pos[ps].flag NE 0, ngoodpts)
           data[ch].nod[nd].pos[ps].coeff = 0
           IF ngoodpts EQ 0 THEN BEGIN
              MESSAGE, /INFO, 'All points are flagged bad for channel ' + $
                       STRING(ch,F='(I0)') + ', nod ' + STRING(nd,F='(I0)') + $
                       ', position ' + STRING(ps,F='(I0)') + '.'
              MESSAGE, /info,'No subtraction performed.'
              data[ch].nod[nd].pos[ps].coeff[0:POLY_DEG] = $
                 REPLICATE(DOUBLE(0.0),POLY_DEG+1)
              BREAK
           ENDIF 
           IF POLY_DEG EQ 0 THEN BEGIN
              data[ch].nod[nd].pos[ps].coeff[0] = $
                 REPLICATE(MEAN(ts[goodpts],/DOUBLE),1)
           ENDIF ELSE BEGIN
              IF ngoodpts LE POLY_DEG + 1 THEN BEGIN
                 MESSAGE, /INFO, 'Not enough good points for polynomial ' + $
                          'subtraction for channel ' + STRING(ch,F='(I0)') + $
                          ', nod ' + STRING(nd,F='(I0)') + $
                          ', position ' + STRING(ps,F='(I0)') + '.'
                 MESSAGE, 'No subtraction performed.'
                 data[ch].nod[nd].pos[ps].coeff[0:POLY_DEG] = $
                    REPLICATE(DOUBLE(0.0),POLY_DEG+1)
                 BREAK
              ENDIF ELSE BEGIN
                 tick = DINDGEN(N_E(ts))
                 data[ch].nod[nd].pos[ps].coeff[0:POLY_DEG] = $
                    POLY_FIT(tick[goodpts],ts[goodpts],POLY_DEG,/DOUBLE)
              ENDELSE
           ENDELSE
           IF ~(KEYWORD_SET(NO_SUBTRACT)) THEN BEGIN
              tick = DINDGEN(N_E(ts))
              data[ch].nod[nd].pos[ps].time -= $
                 POLY(tick,data[ch].nod[nd].pos[ps].coeff)
           ENDIF
        ENDFOR
     ENDFOR
  ENDFOR
END
