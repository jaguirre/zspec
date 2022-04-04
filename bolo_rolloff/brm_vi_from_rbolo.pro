FUNCTION brm_vi_from_rbolo, rbolo, vbias, fbias, rload, cline, phi, gain
  fload = 1./(2.*!DPI*rload*cline)
  q = fbias/fload
  y = 1. + (rload/rbolo)
  RETURN, (gain*vbias/(y^2+q^2))*(-q*COS(phi)+y*SIN(phi))
END
