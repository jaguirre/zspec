FUNCTION datadeglitch, data, dataflags, $
                       USESIGMA = USESIGMA, SLICED = SLICED, $
                       STEP = STEP, SIGMA = SIGMA, AVE = AVE, $
                       QUIET = QUIET, NO_INTERPOLATE = NO_INTERPOLATE

cleandata = data
IF KEYWORD_SET(SLICED) THEN BEGIN
   nchan = N_ELEMENTS(data)
   nnod = N_ELEMENTS(data[0].nod)
   npos = N_ELEMENTS(data[0].nod[0].pos)
   FOR ch = 0, nchan-1 DO BEGIN
      IF ((ch MOD 10 EQ 0) and not(QUIET)) THEN MESSAGE, /INFO, 'Deglitching channel ' + $
                                      STRING(ch,F='(I0)')
      FOR nd = 0, nnod-1 DO BEGIN
         FOR ps = 0, npos-1 DO BEGIN
            timestream = data[ch].nod[nd].pos[ps].time
            IF KEYWORD_SET(USESIGMA) THEN BEGIN
               MESSAGE, /INFO, 'Using sigmadeglitch on sliced data ' + $
                        'is not recommended.'
               MESSAGE, /INFO, 'sigmadeglitch works better on long timestreams.'
               MESSAGE, /INFO, 'However, your wish is my command.'
               timestream = sigmadeglitch(timestream,dgflag,$
                                          SIGMA = SIGMA, AVE = AVE, $
                                          QUIET = QUIET, $
                                          NO_INTERPOLATE = NO_INTERPOLATE)
            ENDIF ELSE BEGIN
               timestream = deglitch(timestream,dgflag,$
                                     STEP = STEP, SIGMA = SIGMA, $
                                     QUIET = QUIET, $
                                     NO_INTERPOLATE = NO_INTERPOLATE)
            ENDELSE
            cleandata[ch].nod[nd].pos[ps].time = timestream
            cleandata[ch].nod[nd].pos[ps].flag *= dgflag
         ENDFOR
      ENDFOR
   ENDFOR
ENDIF ELSE BEGIN
   datasize = SIZE(data)
   ndim = datasize[0]
   CASE ndim OF
      2: BEGIN
         nchan = datasize[1]
         FOR chan = 0, nchan-1 DO BEGIN
            IF ((chan MOD 10 EQ 0) and not(quiet)) THEN MESSAGE, /INFO, 'Deglitching channel ' + $
                                              STRING(chan,F='(I0)')
            timestream = REFORM(data[chan,*])
            IF KEYWORD_SET(USESIGMA) THEN BEGIN
               timestream = sigmadeglitch(timestream,dgflag,$
                                          SIGMA = SIGMA, AVE = AVE, $
                                          QUIET = QUIET, $
                                          NO_INTERPOLATE = NO_INTERPOLATE)
            ENDIF ELSE BEGIN
               timestream = deglitch(timestream,dgflag,$
                                     STEP = STEP, SIGMA = SIGMA, $
                                     QUIET = QUIET, $
                                     NO_INTERPOLATE = NO_INTERPOLATE)
            ENDELSE
            cleandata[chan,*] = timestream
            dataflags[chan,*] *= dgflag
         ENDFOR
      END
      3: BEGIN
         nbox = datasize[1]
         nchan = datasize[2]
         FOR box = 0, nbox-1 DO BEGIN
            MESSAGE, /INFO, 'Deglitching box ' + STRING(box,F='(I0)')
            FOR chan = 0, nchan-1 DO BEGIN
               timestream = REFORM(data[box,chan,*])
               IF KEYWORD_SET(USESIGMA) THEN BEGIN
                  timestream = sigmadeglitch(timestream,dgflag,$
                                             SIGMA = SIGMA, AVE = AVE, $
                                             QUIET = QUIET, $
                                             NO_INTERPOLATE = NO_INTERPOLATE)
               ENDIF ELSE BEGIN
                  timestream = deglitch(timestream,dgflag,$
                                        STEP = STEP, SIGMA = SIGMA, $
                                        QUIET = QUIET, $
                                        NO_INTERPOLATE = NO_INTERPOLATE)
               ENDELSE
               cleandata[box,chan,*] = timestream
               dataflags[box,chan,*] *= dgflag
            ENDFOR
         ENDFOR
      END
      ELSE: BEGIN
         MESSAGE, /INFO, 'data is not 2 or 3 dimensional.  Stopping.'
         STOP
      END
   ENDCASE
ENDELSE

RETURN, cleandata

END
