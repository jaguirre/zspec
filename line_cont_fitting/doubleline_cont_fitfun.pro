;; This fit function works with mpfitfun to do multiple line fits based
;; on the measured bandpasses of Z-Spec's optical channels.  Each line 
;; profile is a double line (as seen, for example, in M82).  It optionally 
;; includes a continuum contribution depending on how many elements are
;; in the p variable.

;; The independent variable x contains a structure with three tags, 
;; .species,.transitions and .splitting.  The first two can be arrays
;; which identify the molecule and upper level J number of the transition(s)
;; to be used in the calculation of a template spectrum. splitting is a
;; single number whose value is to splitting between the two lobes (in km/s).
;;
;; The parameter variable p is a vector with at least 3*N_E(x.species) + 1
;; elements, and possiblly three additional elements.  For each species, there
;; is an amplitude (overall), a delta amplitude and a linewidth.  These are 
;; cycled through for each species.  The next element is the redshift.  The 
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
;; contain the scaling factor and center frequency for each line component.
;; These optional arguments are not used by mpfitfun, but are handy 
;; for call this function after fitting is complete


FUNCTION doubleline_cont_fitfun, x, p, _EXTRA = FUNCTARGS, $
                                 scales, centers
  nu_fts = DOUBLE(FUNCTARGS.nu_fts)
  ftsspec = DOUBLE(FUNCTARGS.ftsspec)
  
  species = x.species
  transitions = x.transitions
  splitting = x.splitting

  nspecies = N_E(species)
  redshift = p[3*nspecies]

  scales = DBLARR(2*nspecies)
  centers = DBLARR(2*nspecies)
  linespec = DBLARR((SIZE(ftsspec))[1])
  FOR line = 0L, nspecies - 1 DO BEGIN
     amp = p[3*line]
     del = p[3*line+1]
     linewidth = p[3*line+2]
     FOR i = 0, 1 DO BEGIN
        CASE i OF
           0:BEGIN              ; Western Lobe
              height = amp/2 + del
              IF height LT 0 THEN height = 0
              shift = redshift - splitting/2
           END
           1:BEGIN              ; Eastern Lobe
              height = amp/2 - del
              IF height LT 0 THEN height = 0
              shift = redshift + splitting/2
           END
        ENDCASE
        linespec += height*make_template_spec(nu_fts,ftsspec,shift,$
                                              species[line],$
                                              transitions[line],$
                                              linewidth, scale, center)
        scales[2*line+i] = scale
        centers[2*line+i] = center
     ENDFOR
  ENDFOR

  CASE N_E(p) OF
     3*nspecies+1:contspec = 0 ; no continuum spectrum
     3*nspecies+4:BEGIN
        contknee = p[3*nspecies+1]
        contamp = p[3*nspecies+2]
        contexp = p[3*nspecies+3]
        contspec = make_cont_spec(nu_fts,ftsspec,contknee,contamp,contexp)
     END
     ELSE:MESSAGE,'Incorrect number of elements in p variable.  Stopping'
  ENDCASE

  RETURN, linespec+contspec
END
