; This function makes fake nodding, on_beam, off_beam and acquired telescope
; flags that correspond to the "usual" 4 nod positions per nod (LRRL) 
; observation mode.  It takes two inputs, the total number of samples
; and the length (in samples) of each nod position.  It outputs a structure
; with four tags; the four artificial flags.  It makes as many nods as can
; fit in the given number of total samples.

FUNCTION make_fake_tel_flags, ntod, pospts
  nodding = FLTARR(ntod)
  on_beam = FLTARR(ntod)
  off_beam = FLTARR(ntod)
  acquired = FLTARR(ntod)
  
  nodgap = 25                   ;number of samples between nods
  acqmin = 20                   ;minimum number of samples to acquire source
  acqmax = 30                   ;maximum number of samples to acquire source

  nodlength = nodgap + 2*acqmax + 4*pospts
  
  nnods = FLOOR(ntod/nodlength)
  acqgap = acqmin + ROUND((acqmax-acqmin)*RANDOMU(seed,2*nnods))
  
  TRUE = 1
  FALSE = 0

  nodding_flag  = [FALSE,TRUE ,TRUE ,TRUE ,TRUE ,TRUE ]
  on_beam_flag  = [TRUE ,TRUE ,FALSE,FALSE,TRUE ,TRUE ]
  off_beam_flag = [FALSE,FALSE,TRUE ,TRUE ,FALSE,FALSE]
  acquired_flag = [TRUE ,TRUE ,FALSE,TRUE ,FALSE,TRUE ]

  currind = 0
  FOR nod = 0, nnods-1 DO BEGIN
     FOR state = 0, 5 DO BEGIN
        nodding[currind:*] = nodding_flag[state]
        on_beam[currind:*] = on_beam_flag[state]
        off_beam[currind:*] = off_beam_flag[state]
        acquired[currind:*] = acquired_flag[state]
        CASE state OF
           0: currind += nodgap
           1: currind += pospts
           2: currind += acqgap[2*nod]
           3: currind += 2*pospts
           4: currind += acqgap[2*nod+1]
           5: currind += pospts
        ENDCASE
     ENDFOR
  ENDFOR
  nodding[currind:*] = FALSE

  RETURN, CREATE_STRUCT('nodding', nodding, $
                             'on_beam', on_beam, $
                             'off_beam', off_beam, $
                             'acquired', acquired)
END
