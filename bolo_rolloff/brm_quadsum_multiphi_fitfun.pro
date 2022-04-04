FUNCTION brm_quadsum_multiphi_fitfun, x, p, _EXTRA = FUNCTARGS
  quadsum = DBLARR(N_E(x[*,0]))
  newp = p[0:5]
  IF N_E(FUNCTARGS) GT 0 THEN BEGIN
     phiranges = FUNCTARGS.phiranges
     FOR range = 0, N_E(phiranges) - 2 DO BEGIN
        startind = phiranges[range]
        endind = phiranges[range+1] - 1
        newx = x[startind:endind,*]
        newp[5] = p[5+range]
        quadsum[startind:endind] = brm_quadsum_fitfun(newx,newp)
     ENDFOR
  ENDIF ELSE quadsum = brm_quadsum_fitfun(x,newp)
  RETURN, quadsum
END
