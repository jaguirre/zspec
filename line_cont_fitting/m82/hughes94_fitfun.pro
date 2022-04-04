FUNCTION hughes94_fitfun, x, p
  nu = x ; in GHz
;;   thermfrac = p[0]
;;   tdust = p[1]
;;   beta = p[2]
;;   freefreefrac = p[3] 
  thermfrac = p[0]
  freefreefrac = p[0]
  beta = p[1]
  
  h = 6.626068d-34
  c = 299792458.d
  k = 1.3806503d-23
  GHz = 1d9
  um = 1d-6
  beta_0 = 1.3
  tdust = 48.1

;  beam_size=1.2*c/(nu*GHz)/10.40;*206265.
  
  IF tdust EQ 0 THEN BEGIN
     gbspec = REPLICATE(thermfrac,N_E(x))
  ENDIF ELSE BEGIN
     gbspec = thermfrac * 1d26 * (1.34d-8) * $
              (2.d * h*(nu*GHz)^3/c^2)/(EXP((h*nu*GHz)/(k*tdust)) - 1.d) * $
;           (7.9*um/1.2d-3)^1.3 * (1.2d-3/(c/(nu*GHz)))^beta + $
              (1.d - EXP(-(7.9*um/(c/(nu*GHz)))^beta_0)) + $
;              freefreefrac * 0.59d * (nu/92.)^(-0.1) 
              freefreefrac * 0.50d * (nu/92.)^(-0.1) 
                                ;0.59 Jy is total flux at 
                                ;92 GHz, 0.5 Jy is est. free-free flux 
                                ;at 92 GHz from Carlstrom & Kronberg,
                                ;1991.  Hughes, et al (1994) assume
                                ;0.59 Jy free-free flux at 92 GHz when
                                ;they fit their thermal radiation
                                ;model but the correction is an
                                ;insignificant amt. of flux at the
                                ;peak of the gray body.
     
     gbspec *= (nu/240.)^(-2.0) ; Point Source -> Beam Filling Source
  ENDELSE
  
  gbspec *= (nu/240.)^beta

  return, gbspec
END
