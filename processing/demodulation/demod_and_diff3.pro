; 14 MAR 2007 BN Changed output structure format to accomidate error
;                Downstream software will break - sorry :-P

FUNCTION demod_and_diff3, nod_struct, data_struct, chop_struct, $
                          REL_PHASE = REL_PHASE, $
                          DIAGNOSTIC = DIAGNOSTIC, $
                          CHOP_PRECOMPUTE = CHOP_PRECOMPUTE, $
                          FUNDAMENTAL = FUNDAMENTAL

  nbolos = N_ELEMENTS(data_struct)
  nnods = N_ELEMENTS(nod_struct)
  npos = N_ELEMENTS(nod_struct[0].pos)

  demod = demodulate3(nod_struct,data_struct,chop_struct,$
                      REL_PHASE = REL_PHASE, $
                      DIAGNOSTIC = DIAGNOSTIC, $
                      CHOP_PRECOMPUTE = CHOP_PRECOMPUTE,$
                      FUNDAMENTAL = FUNDAMENTAL)

; Create sign variable to do differencing
  demod_sgn = REPLICATE(CREATE_STRUCT('nod',nod_struct),nbolos)
  demod_sgn = TRANSPOSE(demod_sgn.nod.pos.sgn)
  
; Create place holder variables to be filled by other functions
  noderr = DBLARR(nbolos,nnods)
  avespec = DBLARR(nbolos)
  aveerr = DBLARR(nbolos)
  mask = REPLICATE(1,nbolos,nnods)
  psd_stdev=dblarr(nbolos, nnods)
  psd_stdev_err=dblarr(nbolos, nnods)

  demod_tags = TAG_NAMES(demod)
  FOR tag = 0, N_TAGS(demod)-1 DO BEGIN
      ndtemp = size(demod.(tag),/n_dim)
      if ndtemp eq 3 then begin
          temp = CREATE_STRUCT('nodspec',TOTAL(demod.(tag)*demod_sgn,3)/npos,$
                               'noderr',noderr,$
                               'avespec',avespec,$
                               'aveerr',aveerr,$
                               'mask',mask ,$
                               'psd_stdev',psd_stdev,$
                               'psd_stdev_err', psd_stdev_err) 
          temp2=CREATE_STRUCT('nodspec',TOTAL(demod.(tag),3)/npos,$
                               'noderr',noderr,$
                               'avespec',avespec,$
                               'aveerr',aveerr,$
                               'mask',mask ,$
                               'psd_stdev',psd_stdev,$
                               'psd_stdev_err', psd_stdev_err) 
      endif else begin 
     temp = CREATE_STRUCT('nodspec',TOTAL(demod.(tag)*demod_sgn,2)/npos,$
                          'noderr',noderr,$
                          'avespec',avespec,$
                          'aveerr',aveerr,$
                          'mask',mask)
     temp2 = CREATE_STRUCT('nodspec',TOTAL(demod.(tag),2)/npos,$
                          'noderr',noderr,$
                          'avespec',avespec,$
                          'aveerr',aveerr,$
                           'mask',mask)
 endelse    
     IF tag EQ 0 THEN $
        out_struct = CREATE_STRUCT(demod_tags(tag),temp) $
     ELSE out_struct = CREATE_STRUCT(out_struct, $
                                     demod_tags[tag],temp)
     IF tag EQ 0 THEN $
        out_struct2 = CREATE_STRUCT(demod_tags(tag),temp2) $
     ELSE out_struct2= CREATE_STRUCT(out_struct2, $
                                     demod_tags[tag],temp2)
 ENDFOR

  RETURN, {signal:out_struct, chopper:out_struct2}
END
