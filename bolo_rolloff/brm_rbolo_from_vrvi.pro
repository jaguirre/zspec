FUNCTION brm_rbolo_from_vrvi, vr, vi, fbias, rload, cline, phi
  fload = 1./(2.*!DPI*rload*cline)
  q = fbias/fload
  y = q*(vr*COS(phi) + vi*SIN(phi))/(vr*SIN(phi) - vi*COS(phi))
  RETURN,rload/(y-1)
END
