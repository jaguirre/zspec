;; This function uses the measured FTS profiles to model the response of Z-Spec
;; optical channels to a graybody continuum. nu_fts and ftsspec are the FTS 
;; freqencies and profiles respectively for the channels of interest.  The 
;; graybody spectrum has the form

;; spec = amp*(2*h*nu_fts^3/c^2)*
;;        (EXP(h*nu_fts/k*tdust)-1)^-1*
;;        (1-EXP(-tau))
;; where tau = (nu_fts/6THz)^beta

;; And that is combined with the FTS profiles to give the bolometers response.

FUNCTION make_cont_spec_planck, nu_fts, ftsspec, frac, tdust, beta, lambda_0

  gbspec = hughes94_fitfun(nu_fts,[frac,tdust,beta,lambda_0])

  nbolos = (SIZE(ftsspec))[1]
  spec = DBLARR(nbolos)
  delnu = MEAN(nu_fts[1:*]-nu_fts[0:N_E(nu_fts)-2])
; Calculate the integral of the product of the fts profile and the 
; line profile (assuming equal spacing between fts freqencies)
  FOR b = 0L, nbolos - 1 DO BEGIN
     spec[b] = TOTAL(delnu*gbspec*ftsspec[b,*])
  ENDFOR
  RETURN, spec
END
