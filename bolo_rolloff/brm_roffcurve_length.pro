; Given an operating point(s) (vr,vi) and the rolloff parameter phi, this 
; function returns the length along the rolloff curve.  If vr and vi 
; are vectors, then the return value is a vector with lengths for each
; operating point.

FUNCTION brm_roffcurve_length, vr, vi, phi
  nsteps = 1000L

  nvr = N_ELEMENTS(vr)
  nvi = N_ELEMENTS(vi)
  IF nvr NE nvi THEN BEGIN
     MESSAGE, 'Unequal number of operating points, stopping.'
  ENDIF ELSE BEGIN
     IF nvr EQ 1 THEN lengths = 0.D ELSE lengths = DBLARR(nvr)
     FOR opt_pt = 0L, nvr-1 DO BEGIN
        vrc = DOUBLE(vr[opt_pt])
        vic = DOUBLE(vi[opt_pt])
        dist = 0.D
        FOR step = 0L, nsteps-1 DO BEGIN
           quadstep = SQRT((vrc^2 + vic^2))/DOUBLE(nsteps-step)
           quadang = atan(vic,vrc)
           theta = brm_thetaopt(vrc,vic,phi)
           currdist = quadstep/COS(quadang - theta)
           dist += currdist
           vrc -= currdist*COS(theta)
           vic -= currdist*SIN(theta)
        ENDFOR
        lengths[opt_pt] = dist
     ENDFOR
  ENDELSE
  RETURN, lengths
END


           
