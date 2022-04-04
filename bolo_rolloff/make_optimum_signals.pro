FUNCTION make_optimum_signals, vr_slice, vi_slice, phi, quad=quad
  vopt = vr_slice
  verr = vopt
  
  ; Copy flags from both components into vopt & verr
  vopt.nod.pos.flag = vr_slice.nod.pos.flag*vi_slice.nod.pos.flag
  verr.nod.pos.flag = vopt.nod.pos.flag
  
  nbolos = N_E(vr_slice)
  nnods = N_E(vr_slice[0].nod)

  theta_opt = DBLARR(nbolos,nnods)

  FOR bolo = 0, nbolos - 1 DO BEGIN
     FOR nod = 0, nnods - 1 DO BEGIN
        vr_nod = vr_slice[bolo].nod[nod].pos.time
        vi_nod = vi_slice[bolo].nod[nod].pos.time
        curr_theta = brm_thetaopt(MEAN(vr_nod),MEAN(vi_nod),$
                                  phi[bolo]*(!DPI/180.))
        theta_opt[bolo,nod] = curr_theta
        
        if keyword_set(quad) then begin
            vopt[bolo].nod[nod].pos.time = sqrt(vr_nod^2+vi_nod^2)
            verr[bolo].nod[nod].pos[0].time = $
              replicate(stdev(vopt[bolo].nod[nod].pos[0].time), $
                        n_e(vopt[bolo].nod[nod].pos[0].time))
            verr[bolo].nod[nod].pos[1].time = $
              replicate(stdev(vopt[bolo].nod[nod].pos[1].time), $
                        n_e(vopt[bolo].nod[nod].pos[1].time))
        endif else begin
            vopt[bolo].nod[nod].pos.time = brm_vopt(vr_nod,vi_nod,curr_theta)
            verr[bolo].nod[nod].pos.time = brm_verr(vr_nod,vi_nod,curr_theta)
        endelse
     ENDFOR
  ENDFOR
  
  RETURN, CREATE_STRUCT('vopt',vopt,'verr',verr,'theta_opt',theta_opt)
END
