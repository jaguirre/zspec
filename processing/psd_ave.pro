; Takes sliced up data_stuct with psds and averages them.  The default
; behavior is to average over all nods and nod positions.  If any of of
; the keywords (BOLOMETER, NOD, POSITION) are set then averaging will 
; occur over which ever keywords are set.

FUNCTION psd_ave, data_struct, $
                  BOLOMETER = bolometer, $
                  NOD = nod, $
                  POSITION = position

; Check keywords to see how averaging should proceed.  Default is
; to average over nod & position
  IF ~KEYWORD_SET(BOLOMETER) AND $
     ~KEYWORD_SET(NOD) AND $
     ~KEYWORD_SET(POSITION) THEN BEGIN
     BOLOMETER = 0
     NOD = 1
     POSITION = 1
  ENDIF ELSE BEGIN
     IF KEYWORD_SET(BOLOMETER) THEN BOLOMETER = bolometer ELSE BOLOMETER = 0
     IF KEYWORD_SET(NOD) THEN NOD = nod ELSE NOD = 0
     IF KEYWORD_SET(POSITION) THEN POSITION = position ELSE POSITION = 0
  ENDELSE

  nbolo = N_ELEMENTS(data_struct)
  nnod = N_ELEMENTS(data_struct[0].nod)
  npos = N_ELEMENTS(data_struct[0].nod[0].pos)

  psds_squared = data_struct.nod.pos.psd_raw^2
  n_averaged_over = 1
  averages_taken = 0
  IF POSITION NE 0 THEN BEGIN
     psds_squared = TOTAL(psds_squared,2)
     n_averaged_over *= npos
     averages_taken += 1
     MESSAGE, /INFO, 'Averaging Over Positions'
  ENDIF
  IF NOD NE 0 THEN BEGIN
     psds_squared = TOTAL(psds_squared,3-averages_taken)
     n_averaged_over *= nnod
     averages_taken += 1
     MESSAGE, /INFO, 'Averaging Over Nods'
  ENDIF
  IF BOLOMETER NE 0 THEN BEGIN
     psds_squared = TOTAL(psds_squared,4-averages_taken)
     n_averaged_over *= nbolo
     averages_taken += 1
     MESSAGE, /INFO, 'Averaging Over Bolometers'
  ENDIF
  
; Must reverse order of indicies (thus TRANSPOSE) but the transpose of a vector
; adds an extra dimension which is taken out with REFORM.
  avepsd = SQRT(REFORM(TRANSPOSE(psds_squared/DOUBLE(n_averaged_over))))

;;   avepsd = DBLARR(nbolo,nnod,npos,N_E(data_struct[0].nod[0].pos[0].freq))

;;   FOR bo = 0, nbolo-1 DO BEGIN
;;      FOR nd = 0, nnod-1 DO BEGIN
;;         FOR ps = 0, npos-1 DO BEGIN
;;            avepsd[bo,*] += data_struct[bo].nod[nd].pos[ps].psd_raw^2
;;         ENDFOR
;;      ENDFOR
;;      avepsd[bo,*] = SQRT(avepsd[bo,*]/DOUBLE(nnod*npos))
;;   ENDFOR

  RETURN, avepsd
END
