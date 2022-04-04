FUNCTION brm_vr_from_vi, vi, vbias, fbias, rload, cline, phi, gain
  fload = 1./(2.*!DPI*rload*cline)
  q = fbias/fload

  a = q
  b = -gain*vbias*SIN(phi)
  c = vi*(q*vi + gain*vbias*COS(phi))

; Choose the better sign in quadratic equation based on which one
; determines more positive values for rbolo.
  nplus = 0
  nminus = 0

  vrplus = (-b + SQRT(COMPLEX(b^2 - 4.*a*c)))/(2.*a)
  plusvalid = WHERE(IMAGINARY(vrplus) EQ 0,nplusvalid)
  IF nplusvalid NE 0 THEN $
     good = WHERE(brm_rbolo_from_vrvi(REAL_PART(vrplus[plusvalid]),$
                                     vi[plusvalid],$
                                     fbias,rload,cline,phi) GT 0,nplus)

  vrminus = (-b - SQRT(COMPLEX(b^2 - 4.*a*c)))/(2.*a)
  minusvalid = WHERE(IMAGINARY(vrminus) EQ 0,nminusvalid)
  IF nminusvalid NE 0 THEN $
     good = WHERE(brm_rbolo_from_vrvi(REAL_PART(vrminus[minusvalid]),$
                                     vi[minusvalid],$
                                     fbias,rload,cline,phi) GT 0,nminus)

  IF nplus GE nminus THEN vr = vrplus ELSE vr = vrminus

; Zero out points where determinant is negative
  notvalid = WHERE(IMAGINARY(vr) NE 0,nnotvalid)
  IF nnotvalid NE 0 THEN vr[notvalid] = COMPLEX(0)

  RETURN, REAL_PART(vr)
END
