FUNCTION brm_vi_fitfun, x, p
  vr = DOUBLE(x)
  vbias = p[0] * DOUBLE(1e-3)   ;convert given mV to V
  fbias = p[1] * DOUBLE(1)      ;frequency given in Hz
  rload = p[2] * DOUBLE(1e6)    ;convert given MOhm to Ohm
  cline = p[3] * DOUBLE(1e-12)  ;convert given pF to F
  gain  = p[4] * DOUBLE(1)      ;no conversion necessary
  phi   = p[5] * !DPI/180.      ;convert given degrees to radians
  RETURN, brm_vi_from_vr(vr,vbias,fbias,rload,cline,phi,gain)
END
