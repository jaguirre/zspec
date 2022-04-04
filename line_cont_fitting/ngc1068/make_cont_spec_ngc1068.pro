;; This function uses the measured FTS profiles to model the response of Z-Spec
;; optical channels to a graybody continuum. nu_fts and ftsspec are the FTS 
;; freqencies and profiles respectively for the channels of interest.  The 
;; graybody spectrum has the form

;; spec = amp*(2*h*nu_fts^3/c^2)*
;;        (EXP(h*nu_fts/k*tdust)-1)^-1*
;;        (1-EXP(-tau))
;; where tau = (nu_fts/6THz)^beta

;; And that is combined with the FTS profiles to give the bolometers response.

; This is a copy of make_cont_spec_m82, but replacing "hughes94_fitfun" with
; "ngc1068_fitfun" on the first line.

FUNCTION make_cont_spec_ngc1068, nu_fts, ftsspec, frac, beta

  gbspec = ngc1068_fitfun(nu_fts,[frac,beta])

  nbolos = (SIZE(ftsspec))[1]
  spec = DBLARR(nbolos)
;  delnu = MEAN(nu_fts[1:*]-nu_fts[0:N_E(nu_fts)-2])
  delnu = DBLARR(N_E(nu_fts))
  delnu[0:N_E(nu_fts)-2] = nu_fts[1:*]-nu_fts[0:N_E(nu_fts)-2]
  delnu[N_E(nu_fts)-1] = delnu[N_E(nu_fts)-2]

; Calculate the integral of the product of the fts profile and the 
; line profile (assuming equal spacing between fts freqencies)
  FOR b = 0L, nbolos - 1 DO BEGIN
     spec[b] = TOTAL(delnu*gbspec*ftsspec[b,*])
  ENDFOR
  RETURN, spec
END
