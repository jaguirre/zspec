FUNCTION brm_vi_multiphi_fitfun, x, p, _EXTRA = FUNCTARGS
  vi = DBLARR(N_E(x))
  newp = p[0:5]
  IF N_E(FUNCTARGS) GT 0 THEN BEGIN
     phiranges = FUNCTARGS.phiranges
     FOR range = 0, N_E(phiranges) - 2 DO BEGIN
        startind = phiranges[range]
        endind = phiranges[range+1] - 1
        newx = x[startind:endind]
        newp[5] = p[5+range]
        vi[startind:endind] = brm_vi_fitfun(newx,newp)
     ENDFOR
  ENDIF ELSE vi = brm_vi_fitfun(x,newp)
     RETURN, vi
END
