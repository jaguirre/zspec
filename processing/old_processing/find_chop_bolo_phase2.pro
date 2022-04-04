; Find the relative phase of the chopper and bolometers, assuming either
; 1) there is a large signal (i.e., Mars) or 
; 2) only use the chopper offset
;
; HISTORY: 06 SEP 2006 BN Create new version to use demodulate2.pro

function find_chop_bolo_phase2, nod_struct, data_struct, chop_struct

  message,/info,'Assuming there is signal in timestream with which to phase up.'

  nbolos = N_ELEMENTS(data_struct)
  rel_phase = DBLARR(nbolos)

  FOR i = 0,0 DO BEGIN
     PRINT, i
     amp = demod_and_diff(nod_struct,data_struct,chop_struct,$
                          REL_PHASE = rel_phase)

; Average over nods and compute phase shift for each bolometer
     nnods = N_ELEMENTS(nod_struct)
     in_ave = TOTAL(amp.in,2)/nnods
     out_ave = TOTAL(amp.out,2)/nnods

     rel_phase += atan(out_ave,in_ave)
     PRINT, rel_phase[0], out_ave[0], in_ave[0], atan(out_ave[0],in_ave[0])
  ENDFOR

  RETURN, rel_phase

END
