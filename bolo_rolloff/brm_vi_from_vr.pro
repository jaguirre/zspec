FUNCTION brm_vi_from_vr, vr, vbias, fbias, rload, cline, phi, gain
  fload = 1./(2.*!DPI*rload*cline)
  q = fbias/fload

  a = q
  b = gain*vbias*COS(phi)
  c = vr*(q*vr - gain*vbias*SIN(phi))

; Choose the better sign in quadratic equation based on which one
; determines more positive values for rbolo.
  nplus = 0
  nminus = 0

  viplus = (-b + SQRT(COMPLEX(b^2 - 4.*a*c)))/(2.*a)
  plusvalid = WHERE(IMAGINARY(viplus) EQ 0,nplusvalid)
  IF nplusvalid NE 0 THEN $
     good = WHERE(brm_rbolo_from_vrvi(vr[plusvalid],$
                                     REAL_PART(viplus[plusvalid]),$
                                     fbias,rload,cline,phi) GT 0,nplus)

  viminus = (-b - SQRT(COMPLEX(b^2 - 4.*a*c)))/(2.*a)
  minusvalid = WHERE(IMAGINARY(viminus) EQ 0,nminusvalid)
  IF nminusvalid NE 0 THEN $
     good = WHERE(brm_rbolo_from_vrvi(vr[minusvalid],$
                                     REAL_PART(viminus[minusvalid]),$
                                     fbias,rload,cline,phi) GT 0,nminus)

  IF nplus GE nminus THEN vi = viplus ELSE vi = viminus

; Zero out points where determinant is negative
  notvalid = WHERE(IMAGINARY(vi) NE 0,nnotvalid)
  IF nnotvalid NE 0 THEN vi[notvalid] = COMPLEX(0)

  RETURN, REAL_PART(vi)
END
