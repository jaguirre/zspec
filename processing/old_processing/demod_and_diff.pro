; Does the demodulation and differences nod positions according to pos.sgn

FUNCTION demod_and_diff, nod_struct, data_struct, chop_struct, $
                         REL_PHASE = REL_PHASE, $
                         DIAGNOSTIC = DIAGNOSTIC

  nbolos = N_ELEMENTS(data_struct)
  npos = N_ELEMENTS(nod_struct[0].pos)

  demod = demodulate2(nod_struct,data_struct,chop_struct,$
                      REL_PHASE = REL_PHASE, $
                      DIAGNOSTIC = DIAGNOSTIC)

; Create sign variable to do differencing
  demod_sgn = REPLICATE(CREATE_STRUCT('nod',nod_struct),nbolos)
  demod_sgn = TRANSPOSE(demod_sgn.nod.pos.sgn)

; Not sure why we need the overall minus sign, but we'll keep for now.
  in_amp = TOTAL(demod.in*demod_sgn,3)/npos
  out_amp = TOTAL(demod.out*demod_sgn,3)/npos
  
  RETURN, CREATE_STRUCT('in',in_amp,$
                        'out',out_amp)

END
