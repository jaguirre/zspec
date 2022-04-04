; Like demodulate2, except that it uses the fundamental chop and the 
; 2nd & 4th chop harmonics, unless FUNDAMENTAL is set and then only 
; the fundamental is computed and the higher harmonic demodulations are 
; set to zero.  If CHOP_PRECOMPUTE is set, then chop_struct is
; assumed to the the phase shifted chopper waveforms for each of the 
; bolometers in data_struct.  If DIAGNOSTIC is to a number, then that
; number bolometer's timestreams will be plotted, one plot for each
; nod position, with 4 plots grouped together.  Set REL_PHASE to a 
; 3 x nbolo matrix of chopper to bolometer phases, otherwise no phase
; shift will be applied (unless CHOP_PRECOMPUTE is set and thus REL_PHASE
; is ignored.

FUNCTION demodulate3, nod_struct, data_struct, chop_struct, $
                      REL_PHASE = rel_phase, $
                      DIAGNOSTIC = DIAGNOSTIC, $
                      CHOP_PRECOMPUTE = CHOP_PRECOMPUTE, $
                      FUNDAMENTAL = FUNDAMENTAL

  nbolos = N_E(data_struct)
  nnods = N_E(data_struct[0].nod)
  npos = N_E(data_struct[0].nod[0].pos)
  npts = N_E(data_struct[0].nod[0].pos[0].time)

  nharm = 3

  IF ~(KEYWORD_SET(CHOP_PRECOMPUTE)) THEN BEGIN
     IF ~(KEYWORD_SET(REL_PHASE)) THEN REL_PHASE = DBLARR(nharm,nbolos)
     sliced_chop = $
        make_phased_sliced_chop(nod_struct,chop_struct,rel_phase,$
                                FUNDAMENTAL = FUNDAMENTAL)
  ENDIF ELSE BEGIN
     PRINT, 'Phased & Sliced Chop Precomputed.  Proceed to demodulation'
     sliced_chop = chop_struct
  ENDELSE
  chop_in_slice = sliced_chop.chop_in_slice
  chop_out_slice = sliced_chop.chop_out_slice

  ; Get Timestream Data & Flags Arrays (npts x npos x nnods x nbolos)
  timestreams = data_struct.nod.pos.time
  flags = data_struct.nod.pos.flag

  ; Do demodulation
  PRINT, 'Doing demodulation'
  t = SYSTIME(1)
  demod_in = DBLARR(nharm,nbolos,nnods,npos)
  demod_out = demod_in
  IF KEYWORD_SET(FUNDAMENTAL) THEN computeharm = 1 ELSE computeharm = nharm
  FOR harm = 0, computeharm - 1 DO BEGIN
     curr_in = REFORM(chop_in_slice[harm,*,*,*,*])*flags
     curr_out = REFORM(chop_out_slice[harm,*,*,*,*])*flags
     demod_in[harm,*,*,*] = $
        TRANSPOSE(TOTAL(curr_in*timestreams,1)/TOTAL(curr_in*curr_in,1))
     demod_out[harm,*,*,*] = $
        TRANSPOSE(TOTAL(curr_out*timestreams,1)/TOTAL(curr_out*curr_out,1))
  ENDFOR
  PRINT, SYSTIME(1) - t

  demods = CREATE_STRUCT('in',TOTAL(demod_in,1),$
                         'out',TOTAL(demod_out,1),$
                         'in1',REFORM(demod_in[0,*,*,*]),$
                         'in3',REFORM(demod_in[1,*,*,*]),$
                         'in5',REFORM(demod_in[2,*,*,*]),$
                         'out1',REFORM(demod_out[0,*,*,*]),$
                         'out3',REFORM(demod_out[1,*,*,*]),$
                         'out5',REFORM(demod_out[2,*,*,*]))

; Make diagnostic plots if requested
  IF KEYWORD_SET(DIAGNOSTIC) THEN BEGIN
     bolo = DIAGNOSTIC
     nnods = N_ELEMENTS(nod_struct)
     npos = N_ELEMENTS(nod_struct[0].pos)
     FOR nod = 0, nnods-1 DO BEGIN
        !P.MULTI = [0,2,2]
        FOR pos = 0, npos-1 DO BEGIN
           PRINT, nod, pos
           PLOT, timestreams[*,pos,nod,bolo], XST = 2, $
                 TITLE=STRING('Nod ',nod,' Position ',pos,' Channel ',bolo,$
                              FORMAT='(A0,I0,A0,I0,A0,I0)')
           est_inbolos = $
              chop_in_slice[0,*,pos,nod,bolo]*demods.in1[bolo,nod,pos] + $
              chop_in_slice[1,*,pos,nod,bolo]*demods.in3[bolo,nod,pos] + $
              chop_in_slice[2,*,pos,nod,bolo]*demods.in5[bolo,nod,pos]
           est_outbolos = $
              chop_out_slice[0,*,pos,nod,bolo]*demods.out1[bolo,nod,pos] + $
              chop_out_slice[1,*,pos,nod,bolo]*demods.out3[bolo,nod,pos] + $
              chop_out_slice[2,*,pos,nod,bolo]*demods.out5[bolo,nod,pos]
         
           OPLOT, est_inbolos, COLOR = 2
           OPLOT, est_outbolos, COLOR = 3
           OPLOT, timestreams[*,pos,nod,bolo] - est_inbolos, COLOR = 4
        ENDFOR
        blah = ''
        READ,blah
     ENDFOR
     !P.MULTI = 0
  ENDIF

  RETURN, demods
END
