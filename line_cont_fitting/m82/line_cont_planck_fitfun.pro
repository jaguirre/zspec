;; This fit function works with mpfitfun to do multiple line fits based
;; on the measured bandpasses of Z-Spec's optical channels.  It optionally 
;; includes a continuum contribution depending on how many elements are
;; in the p variable.

;; The independent variable x contains a structure with two tags, 
;; .species,.transitions.  These can be arrays
;; which identify the molecule and upper level J number of the transition(s)
;; to be used in the calculation of a template spectrum.
;;
;; The parameter variable p is a vector with at least 3*N_E(x.species)
;; elements, and possiblly three additional elements.  For each species, there
;; is an amplitude and a linewidth and a redshift.  These are 
;; cycled through for each species.  The 
;; three optional elements if present are the three parameters of the 
;; continuum spectrum (fscale, amp & exp).  If they aren't present, no
;; continuum spectrum is calculated.
;;
;; The _EXTRA argument for this fit function must contain the bandpasses
;; for the optical channels as extracted by Randol from an FTS
;; run.  They must be only the bandpasses for the channels to be used for
;; the fitting.  
;;
;; scales and centers are optional arguments which after execution
;; contain the scaling factor and center frequency for each line.
;; These optional arguments can not used by mpfitfun, but are handy 
;; for calls this function after fitting is complete

FUNCTION line_cont_planck_fitfun, x, p, _EXTRA = FUNCTARGS, $
                                  scales, centers
  nu_fts = DOUBLE(FUNCTARGS.nu_fts)
  ftsspec = DOUBLE(FUNCTARGS.ftsspec)
  
  species = x.species
  transitions = x.transitions

  nspecies = N_E(species)
  paramsperline = 3
  ampind = paramsperline*INDGEN(nspecies)
  widthind = paramsperline*INDGEN(nspecies)+1
  redind = paramsperline*INDGEN(nspecies)+2

  scales = DBLARR(nspecies)
  centers = DBLARR(nspecies)
  linespec = DBLARR((SIZE(ftsspec))[1])
  FOR line = 0L, nspecies - 1 DO BEGIN
     amp = p[ampind[line]]
     linewidth = p[widthind[line]]
     redshift = p[redind[line]]
     linespec += amp*make_template_spec(nu_fts,ftsspec,redshift,$
                                        species[line],$
                                        transitions[line],$
                                        linewidth, scale, center)
     scales[line] = scale
     centers[line] = center
  ENDFOR

  CASE N_E(p) OF
     paramsperline*nspecies   : contspec = 0 ; no continuum spectrum
     paramsperline*nspecies+4 : BEGIN
        contamp = p[paramsperline*nspecies+0]
        conttemp = p[paramsperline*nspecies+1]
        contexp = p[paramsperline*nspecies+2]
        contffamp = p[paramsperline*nspecies+3]
        contspec = $
           make_cont_spec_planck(nu_fts,ftsspec,$
                                 contamp,conttemp,contexp,contffamp)
     END
     ELSE:MESSAGE,'Incorrect number of elements in p variable.  Stopping'
  ENDCASE

  RETURN, linespec+contspec
END
