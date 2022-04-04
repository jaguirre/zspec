;Written by BN

;Modifications:
;
;2008-03-04 LE
;Get rid of loop to look at second and third harmonic.  Then set the
;errors for higher harmonics to be -1 to avoid confusion with the
;input errors, which are based on the standard deviation.  Then
;comment the hell out of it.


FUNCTION estimate_psd_errs, spectra_in, pos_ave_psd, chopfreq, inttime
  spectra_out = spectra_in
  psdfreq = pos_ave_psd.freq
;;;;;;;deleting the for-loop for harmonics;;;;;;;;; 
;  FOR demod = 0, 0 DO BEGIN                      ;
;     currfreq = (2.*demod+1.)*chopfreq           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
     currfreq=chopfreq
     ;temp is the freq bin closest to chop freq
     ;chopind is the index where psdfreq is temp
     temp = MIN(ABS(psdfreq-currfreq), chopind)
     ;start above the 1/f and finish below second harmonic
     nearfreqs = WHERE(psdfreq GT currfreq - 0.4 AND $
                       psdfreq LT currfreq + 0.7) ;these are indices, not the freq values
     ;drop the fundamental and the bin immediately above and below
     nearfreqs = nearfreqs(WHERE(ABS(nearfreqs - chopind) GT 1))                  
     nnf = N_ELEMENTS(nearfreqs)
; JA 2009/10/30  If nnf = 1 (which can happen for very short
; integrations), then the call to "total" will crash
      ndtemp = size(pos_ave_psd.psd,/n_dim)
     if nnf eq 1 then begin
         if ndtemp eq 3 then $
           spectra_out.in1.noderr = $
           SQRT((pos_ave_psd.psd[*,*,nearfreqs]^2)/DOUBLE(nnf)/inttime) $
           else $
           spectra_out.in1.noderr = $
           SQRT((pos_ave_psd.psd[*,nearfreqs]^2)/DOUBLE(nnf)/inttime)
     endif else begin
;compute errors per nod, per channel
      if ndtemp eq 3 then $
         spectra_out.in1.noderr = $
           SQRT(TOTAL(pos_ave_psd.psd[*,*,nearfreqs]^2,3)/DOUBLE(nnf)/inttime) $
      else $
         spectra_out.in1.noderr = $
           SQRT(TOTAL(pos_ave_psd.psd[*,nearfreqs]^2,2)/DOUBLE(nnf)/inttime)
     endelse

;;;;;;;deleting the for-loop for harmonics;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;     temp = $                                                                     ;  
;       SQRT(TOTAL(pos_ave_psd.psd[*,*,nearfreqs]^2,3)/DOUBLE(nnf)/inttime)        ;
;     CASE demod OF                                                                ;
;        0:spectra_out.in1.noderr = temp                                           ;
;        1:spectra_out.in3.noderr = temp                                           ; 
;        2:spectra_out.in5.noderr = temp                                           ;
;     ENDCASE                                                                      ; 
;  ENDFOR                                                                          ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
spectra_out.in3.noderr=-1
spectra_out.in5.noderr=-1
spectra_out.in.noderr=spectra_out.in1.noderr
;  spectra_out.in.noderr = SQRT(spectra_out.in1.noderr^2+$
;                               spectra_out.in3.noderr^2+$
;                               spectra_out.in5.noderr^2)
  RETURN, spectra_out
END
