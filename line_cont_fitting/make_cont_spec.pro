;; This function uses the measured FTS profiles to model the response of Z-Spec
;; optical channels to a power-law continuum. nu_fts and ftsspec are the FTS 
;; freqencies and profiles respectively for the channels of interest.  The power
;; law takes the form

;; spec = amp*((nu_fts/fscale)^exp)

;; And that is combined with the FTS profiles to give the bolometers response.

FUNCTION make_cont_spec, nu_fts, ftsspec, fscale, amp, exp
  pwrlawspec = pwrlaw_mpfit_func(nu_fts/fscale,[amp,exp])
  
  nbolos = (SIZE(ftsspec))[1]
  spec = DBLARR(nbolos)
;  delnu = MEAN(nu_fts[1:*]-nu_fts[0:N_E(nu_fts)-2])
  delnu = DBLARR(N_E(nu_fts))
  delnu[0:N_E(nu_fts)-2] = nu_fts[1:*]-nu_fts[0:N_E(nu_fts)-2]
  delnu[N_E(nu_fts)-1] = delnu[N_E(nu_fts)-2]

; Calculate the integral of the product of the fts profile and the 
; line profile 
  FOR b = 0L, nbolos - 1 DO BEGIN
     spec[b] = TOTAL(delnu*pwrlawspec*ftsspec[b,*])
  ENDFOR
  RETURN, spec
END
