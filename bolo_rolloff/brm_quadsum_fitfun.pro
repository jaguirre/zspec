; The rolloff model suggests a simple relationship beween the quadrature
; sum of vr & vi and different combination of vr & vi which includes
; the parameters of the model.  
FUNCTION brm_quadsum_fitfun, x, p
; x is a 2 by n matrix formed by [[vr],[vi]]
  vr = DOUBLE(REFORM(x[*,0]))
  vi = DOUBLE(REFORM(x[*,1]))
  vbias = p[0] * DOUBLE(1e-3)   ;convert given mV to V
  fbias = p[1] * DOUBLE(1)      ;frequency given in Hz
  rload = p[2] * DOUBLE(1e6)    ;convert given MOhm to Ohm
  cline = p[3] * DOUBLE(1e-12)  ;convert given pF to F
  gain  = p[4] * DOUBLE(1)      ;no conversion necessary
  phi   = p[5] * !DPI/180.      ;convert given degrees to radians

  fload = 1./(2.*!DPI*rload*cline)
  q = fbias/fload

  quadsum = vr*SIN(phi) - vi*COS(phi)
  quadsum *= gain*vbias
  quadsum /= q

  RETURN, quadsum
END
