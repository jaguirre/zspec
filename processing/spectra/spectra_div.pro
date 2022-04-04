FUNCTION spectra_div, spectra, avecal
  outspec = spectra
  ntags = N_TAGS(outspec)
  nnods = N_E(outspec.(0).(0)[0,*])
  nbolos = N_E(outspec.(0).(0)[*,0])
  nodvec = REPLICATE(1.D,nnods)

  FOR tag = 2, ntags - 1 DO BEGIN
     CASE N_E(avecal) OF
        ;; this is the case where avecal is a spectra variable
        ;; and we want to use the avespec to calibrate
        ;; Should use the in phase demodulations for calibrating
        ;; both in and out phase signals.
        1:begin
            avespeccal = avecal.(2 + ((tag - 2) MOD 3)).avespec
            outspec.(tag).(0) /= avespeccal#nodvec
            outspec.(tag).(1) /= avespeccal#nodvec
            outspec.(tag).(2) /= avespeccal
            outspec.(tag).(3) /= avespeccal
        end
        ;; this is the case where avecal is a nbolos element vector,
        ;; one for each bolometer (eg from cal_vec) 
        (nbolos):begin
            avespeccal = avecal
            outspec.(tag).(0) /= avespeccal#nodvec
            outspec.(tag).(1) /= avespeccal#nodvec
            outspec.(tag).(2) /= avespeccal
            outspec.(tag).(3) /= avespeccal   
        end
        ;; this is the case where avecal is a nbolos x nnods array, for
        ;; example when dividing by sky transmission computed for each 
        ;; nod
        (nbolos*nnods):begin
            avespeccal=avecal
            outspec.(tag).(0) /= avespeccal
            outspec.(tag).(1) /= avespeccal
            temp=dblarr(160)
            for ch=0,nbolos-1 do begin
                temp[ch]=mean(avespeccal[ch,*])
            endfor
            outspec.(tag).(2) /= temp
            outspec.(tag).(3) /= temp
        end
        ;; if avecal is a nbolos x nnods x 2 array, where the first
        ;; element is the last dimension is the calibration vector and
        ;; the second element is the corresponding error vector.  This is
        ;; the case when you use uber_spectrum, for example, which
        ;; uses the function get_cal to get a calibration vector which
        ;; is a function of the dc-voltage.
        (nbolos*nnods*2):begin
            avespeccal=reform(avecal[*,*,0])
            avespecerr=reform(avecal[*,*,1])
            tempstorage=outspec.(tag).(0)
            outspec.(tag).(0) /= avespeccal
            temp=dblarr(160)
            for ch=0,nbolos-1 do begin
                for nods=0,nnods-1 do begin
                    outspec.(tag).(1)[ch,nods]=$
                      abs(outspec.(tag).(0)[ch,nods])*$
                      sqrt((outspec.(tag).(1)[ch,nods]/$
                       tempstorage[ch,nods])^2.+$
                      (avespecerr[ch,nods]/$
                      avespeccal[ch,nods])^2.)
                endfor
                temp[ch]=mean(avespeccal[ch,*])
            endfor
            outspec.(tag).(2)/=temp
            outspec.(tag).(3)/=temp
        end          
        ELSE:MESSAGE, 'Given calibration "avecal" is not understood'
     ENDCASE
  ENDFOR

  ;; Recombine 1, 3 & 5 Hz (roughly) signals into the combination
  ;; combine the errors in quadrature
  FOR tag = 0, 1 DO BEGIN
     FOR subtag = 0, 3 DO BEGIN
        IF subtag MOD 2 EQ 0 THEN BEGIN
           outspec.(tag).(subtag) = $
              outspec.(3*tag+2).(subtag) + $
              outspec.(3*tag+3).(subtag) + $
              outspec.(3*tag+4).(subtag)
        ENDIF ELSE BEGIN
           outspec.(tag).(subtag) = $
              SQRT(outspec.(3*tag+2).(subtag)^2 + $
                   outspec.(3*tag+3).(subtag)^2 + $
                   outspec.(3*tag+4).(subtag)^2)
        ENDELSE
     ENDFOR
  ENDFOR
  RETURN, outspec
END
