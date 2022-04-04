; This function concatenates two spectra structures together with
; and optional scale factor applied to the second spectrum
;
; Updated for new output of demod_and_diff3 (15 Mar 2007)
;
; Note: this function resets the avespec & aveerr values, setting
; of those should be done by spectra_ave after all spectras are combined
FUNCTION combine_spectra, spec1, spec2, scale_fac

;; Let scale_fac be an optional argument, which if absent is set to unity
  IF N_PARAMS() EQ 2 THEN scale_fac = 1.D

  tags = TAG_NAMES(spec1)
  ntags = N_TAGS(spec1)
  subtags = TAG_NAMES(spec1.(0))
  FOR tag = 0, ntags - 1 DO BEGIN
     temp = CREATE_STRUCT(subtags[0],$
                          [[spec1.(tag).(0)],$
                           [scale_fac*spec2.(tag).(0)]], $
                          subtags[1],$
                          [[spec1.(tag).(1)],$
                           [scale_fac*spec2.(tag).(1)]], $
                          subtags[2],spec1.(tag).(2)*0.D, $
                          subtags[3],spec1.(tag).(3)*0.D, $
                          subtags[4],$
                          [[spec1.(tag).(4)],[spec2.(tag).(4)]])
     IF tag EQ 0 THEN $
        out_spec = CREATE_STRUCT(tags[tag],temp) $
     ELSE out_spec = CREATE_STRUCT(out_spec,tags[tag],temp)
  ENDFOR
  RETURN, out_spec
END
