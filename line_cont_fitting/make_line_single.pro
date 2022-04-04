;; Returns a Gaussian line profile centered at center (in GHz) with FWHM
;; line_width.  The profile will be evaluated at all points in freqs [in
;; GHz] & normalized such that the integral over the line is equal to
;; line_width.

; 2009_07_07 BJN Added TOP_HAT keyword to pick top-hat line
;                profile instead of gaussian


FUNCTION make_line_single, freqs, center, line_width, TOP_HAT = TOP_HAT
  c = 299792.458 ; in km/sec

  fwhm = (DOUBLE(line_width)/c)*center

  IF ~KEYWORD_SET(TOP_HAT) THEN BEGIN
; Gaussian Profile - DEFAULT BEHAVIOR
     sigma = fwhm/(2.D*SQRT(2.D*ALOG(2.D)))
     line = EXP(-0.5*((freqs-center)/sigma)^2)
; Integral of gaussian from -inf to +inf is sigma*SQRT(2 !PI)
; Let's divide out a couple factors so that the returned line's
; integral is given by line_width
     line /= (sigma/fwhm)*SQRT(2.*!DPI)
  ENDIF ELSE BEGIN
; Top Hat Profile - if no points fall in the FWHM range, then set the
;                   nearest point in freqs to 1 and issue warning
     line = FLTARR(N_E(freqs))
     hat_pts = WHERE(ABS(freqs - center) LE (fwhm/2.0), nhat_pts)
     IF nhat_pts GT 0 THEN BEGIN
        line[hat_pts] = 1.0
;        line *= line_width/fwhm
     ENDIF ELSE BEGIN
        MESSAGE, /INFO, 'No valid points in Top-Hat profile, line width is too small.'
        mindiff = MIN((freqs - center), closest_pt, /ABSOLUTE)
        line[closest_pt] = 1.0
;        line *= line_width/MEAN(freqs[1:*]-freqs[0:N_E(freqs)-2])
     ENDELSE
  ENDELSE
  RETURN, line
END
