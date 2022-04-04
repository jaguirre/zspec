FUNCTION make_phased_sliced_chop, nod_struct, chop_struct, rel_phase, $
                                  FUNDAMENTAL = FUNDAMENTAL
  nbolos = N_E(rel_phase[0,*])
  ntod = N_E(chop_struct.sin1)
  nnods = N_E(nod_struct)
  npos = N_E(nod_struct[0].pos)
  npts = nod_struct[0].pos[0].f - nod_struct[0].pos[0].i + 1

  nharm = N_E(rel_phase[*,0])
  
  ; Create phase shifted chop matricies
  PRINT, 'Creating phase shifted chop matricies'
  t = SYSTIME(1)

  chop_in = DBLARR(nharm,nbolos,ntod)
  chop_out = chop_in
  chopsin = [[chop_struct.sin1],[chop_struct.sin3],[chop_struct.sin5]]
  chopcos = [[chop_struct.cos1],[chop_struct.cos3],[chop_struct.cos5]]
  IF KEYWORD_SET(FUNDAMENTAL) THEN computeharm = 1 ELSE computeharm = nharm
  FOR harm = 0, computeharm - 1 DO BEGIN
     currph = REFORM(rel_phase[harm,*])
     currsin = REFORM(chopsin[*,harm])
     currcos = REFORM(chopcos[*,harm])
     chop_in[harm,*,*] = MATRIX_MULTIPLY($
                         [[COS(currph)],[-1.0*SIN(currph)]],$
                         [[currsin],[currcos]],/BTRANSPOSE)
     currph += !DPI/2.0
     chop_out[harm,*,*] = MATRIX_MULTIPLY($
                          [[COS(currph)],[-1.0*SIN(currph)]],$
                          [[currsin],[currcos]],/BTRANSPOSE)
  ENDFOR
  PRINT, SYSTIME(1) - t

  ; Slice phase shifted chop to be like timestream data & flags arrays
  PRINT, 'Slicing phased chop matricies'
  t = SYSTIME(1)
  chop_in_slice = DBLARR(nharm,npts,npos,nnods,nbolos)
  chop_out_slice = chop_in_slice
  FOR bolo = 0, nbolos - 1 DO BEGIN
     FOR nod = 0, nnods - 1 DO BEGIN
        FOR pos = 0, npos - 1 DO BEGIN
           npi = nod_struct[nod].pos[pos].i
           npf = nod_struct[nod].pos[pos].f
           FOR harm = 0, computeharm - 1 DO BEGIN
              chop_in_slice[harm,*,pos,nod,bolo] = chop_in[harm,bolo,npi:npf]
              chop_out_slice[harm,*,pos,nod,bolo] = chop_out[harm,bolo,npi:npf]
           ENDFOR
        ENDFOR
     ENDFOR
  ENDFOR
  PRINT, SYSTIME(1) - t

  chop_in=0
  chop_out=0
  
  RETURN, CREATE_STRUCT('chop_in_slice',temporary(chop_in_slice),$
                        'chop_out_slice',temporary(chop_out_slice))
END
