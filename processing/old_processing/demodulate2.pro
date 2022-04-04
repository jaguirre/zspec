; This function does chopper demodulation, creating both in phase & out of 
; phase demodulation.  It takes a trimed nod structure, a sliced up timestream
; data structure and a cleaned up chopper waveform structure.  It outputs a 
; structure with two elements, demod_in and demod_out, which are both 
; nbolo x nnod x npos arrays with the in and out phase demodulation for 
; each bolometer, nod and nod position.  
;
; The keyword rel_phase can be used to pass a vector of phase shifts to apply
; to the chopper waveforms for each bolometer.
;
; Set the keyword DIAGNOSTIC to a number of a particular bolometer channel
; to see plots of the bolometer timestream for each nod position.
;
; HISTORY: 05 SEP 06 BN - Changed interface & algorithm to use chop_struct
;                         and data flags.
;          13 SEP 06 BN - Added DIAGNOSTIC keyword

function demodulate2, nod_struct, data_struct, chop_struct, $
                      rel_phase = rel_phase, $
                      DIAGNOSTIC = DIAGNOSTIC

  nbolos = n_e(data_struct)
  nnods = n_e(data_struct[0].nod)
  npos = n_e(data_struct[0].nod[0].pos)

  if ~(keyword_set(rel_phase)) then rel_phase = dblarr(nbolos)

; Create nbolo x ntod matrix of phase shifted chop
  chop_in = MATRIX_MULTIPLY([[COS(rel_phase)],[-1.0*SIN(rel_phase)]],$
                            [[chop_struct.sin],[chop_struct.cos]],$
                            /BTRANSPOSE)
  out_phase = rel_phase + (!DPI/2.0)
  chop_out = MATRIX_MULTIPLY([[COS(out_phase)],[-1.0*SIN(out_phase)]],$
                             [[chop_struct.sin],[chop_struct.cos]],$
                             /BTRANSPOSE)

; Slice up the chop in structure like data with just time tag
  chop_in_slice = slice_data(nod_struct,chop_in,/JUST_DATA)
  chop_out_slice = slice_data(nod_struct,chop_out,/JUST_DATA)

; Get arrays for demodulation (ntod x npos x nnod x nbolo)
  bolos = data_struct.nod.pos.time
  flags = data_struct.nod.pos.flag
  chop_in_time = chop_in_slice.nod.pos.time*flags
  chop_out_time = chop_out_slice.nod.pos.time*flags

; Do the demodulation
  demod_in = TOTAL(chop_in_time*bolos,1)/TOTAL(chop_in_time*chop_in_time,1)
  demod_out = TOTAL(chop_out_time*bolos,1)/TOTAL(chop_out_time*chop_out_time,1)

  demods = create_struct('in',TRANSPOSE(demod_in),$
                         'out',TRANSPOSE(demod_out))

; Make diagnostic plots if requested
  IF KEYWORD_SET(DIAGNOSTIC) THEN BEGIN
     bolo = DIAGNOSTIC
     nnods = N_ELEMENTS(nod_struct)
     npos = N_ELEMENTS(nod_struct[0].pos)
     FOR nod = 0, nnods-1 DO BEGIN
        !P.MULTI = [0,2,2]
        FOR pos = 0, npos-1 DO BEGIN
           PRINT, nod, pos
           PLOT, bolos[*,pos,nod,bolo], XST = 2, $
                 TITLE=STRING('Nod ',nod,' Position ',pos,' Channel ',bolo,$
                              FORMAT='(A0,I0,A0,I0,A0,I0)')
           OPLOT, chop_in_time[*,pos,nod,bolo]*ABS(demod_in[pos,nod,bolo]), $
                  COLOR = 2
           OPLOT, chop_out_time[*,pos,nod,bolo]*ABS(demod_out[pos,nod,bolo]), $
                  COLOR = 3
           OPLOT, bolos[*,pos,nod,bolo] - $
                  chop_in_time[*,pos,nod,bolo]*demod_in[pos,nod,bolo], $
                  COLOR = 4
        ENDFOR
        blah = ''
        READ,blah
     ENDFOR
     !P.MULTI = 0
  ENDIF

  return, demods
end
