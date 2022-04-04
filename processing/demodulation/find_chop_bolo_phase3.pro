; If FUNDAMENTAL is set, then only the chopper to bolometer phase for the
; fundatmental frequency is calculated (this is much faster)
FUNCTION find_chop_bolo_phase3, nod_struct, data_struct, chop_struct, $
                                NLOOPS = NLOOPS,$
                                FUNDAMENTAL = FUNDAMENTAL
  
  IF ~KEYWORD_SET(NLOOPS) THEN NLOOPS = 5
  IF NLOOPS LE 0 THEN NLOOPS = 1 ; 0 loops wouldn't get rel_phase
  IF NLOOPS GT 10 THEN NLOOPS = 10 ; 10 should be plenty
  
  nbolos = N_ELEMENTS(data_struct)
  nnods = N_ELEMENTS(nod_struct)
  nharm = 3
  REL_PHASE = DBLARR(nharm,nbolos)
  FOR i = 0, NLOOPS - 1 DO BEGIN
     struct = demod_and_diff3(nod_struct,data_struct,chop_struct,$
                            REL_PHASE = rel_phase,$
                            FUNDAMENTAL = FUNDAMENTAL)

     spec=struct.signal

     ; Average over nods and compute phase shift for each bolometer
     spectra_ave, spec, SIGMA_CUT = 5.0,/UNWEIGHTED,$
                  FUNDAMENTAL = FUNDAMENTAL
     rel_phase[0,*] += atan(spec.out1.avespec,spec.in1.avespec)
     rel_phase[1,*] += atan(spec.out3.avespec,spec.in3.avespec)
     rel_phase[2,*] += atan(spec.out5.avespec,spec.in5.avespec)
     PRINT, rel_phase[0,0], spec.out1.avespec[0], spec.in1.avespec[0], $
            atan(spec.out1.avespec[0],spec.in1.avespec[0])
     PRINT, rel_phase[1,0], spec.out3.avespec[0], spec.in3.avespec[0], $
            atan(spec.out3.avespec[0],spec.in3.avespec[0])
     PRINT, rel_phase[2,0], spec.out5.avespec[0], spec.in5.avespec[0], $
            atan(spec.out5.avespec[0],spec.in5.avespec[0])
  ENDFOR

  RETURN, rel_phase
END
