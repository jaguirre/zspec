FUNCTION brm_vr_multiphi_fitfun, x, p, _EXTRA = FUNCTARGS
  vr = DBLARR(N_E(x))
  newp = p[0:5]
  IF N_E(FUNCTARGS) GT 0 THEN BEGIN
     phiranges = FUNCTARGS.phiranges
     FOR range = 0, N_E(phiranges) - 2 DO BEGIN
        startind = phiranges[range]
        endind = phiranges[range+1] - 1
        newx = x[startind:endind]
        newp[5] = p[5+range]
        vr[startind:endind] = brm_vr_fitfun(newx,newp)
     ENDFOR
  ENDIF ELSE vr = brm_vr_fitfun(x,newp)
  RETURN, vr
END
