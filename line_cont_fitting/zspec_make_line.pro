; Much simplified version of Bret's make_template_spec

; 2009_07_07 BJN Added TOP_HAT keyword to pick top-hat line
;                profile instead of gaussian

function zspec_make_line, nu_fts, ftsspec, redshift, $
                          line_freq, $
                          line_width, scale, center, $
                          TOP_HAT = TOP_HAT
  
scale=!values.D_NAN;0.D
  center = line_freq/(1.D + redshift)
  if center lt min(nu_fts, /nan) or center gt max(nu_fts, /nan) then $
    return, dblarr((size(ftsspec))[1])
  
  line = make_line_single(nu_fts, center, line_width, TOP_HAT = TOP_HAT)
  
  nbolos = (SIZE(ftsspec))[1]
  spec = DBLARR(nbolos)
;  delnu = MEAN(nu_fts[1:*]-nu_fts[0:N_E(nu_fts)-2])
  delnu = DBLARR(N_E(nu_fts))
  delnu[0:N_E(nu_fts)-2] = nu_fts[1:*]-nu_fts[0:N_E(nu_fts)-2]
  delnu[N_E(nu_fts)-1] = delnu[N_E(nu_fts)-2]
  
; Calculate the integral of the product of the fts profile and the 
; line profile 
  FOR b = 0L, nbolos - 1 DO BEGIN
     spec[b] = TOTAL(delnu*line*ftsspec[b,*])
  ENDFOR
  
  IF ~KEYWORD_SET(TOP_HAT) THEN BEGIN
     scale = 1.D/MAX(spec)
     spec *= scale
  ENDIF ELSE BEGIN
     scale = 1.D
  ENDELSE

  RETURN, spec
  
end
