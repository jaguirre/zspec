;; This function uses the make_line_* functions to create template
;; spectra based on the instrument transmission profiles as measured by
;; an FTS run. nu_fts and ftsspec are the transmission profiles
;; for the channels of interest.  redshift, species & transition control
;; the frequency of the line (and which make_line_* routine is used to
;; generate the profile). line_width is the FWHM of the line profile (or
;; intrinsic line profiles if the species has some sort of splitting).
;; scale is an optional argument that, after execution, contains the
;; factor applied to the template to boost it up to unit peak amplitude.
;; After execution, center contains the center freqency of the intrinsic
;; line profile.

;; The currently defined species are
;;
;;  0) CO 
;;  1) 13CO
;;  2) C18O
;;  3) CN (splitted)
;;  4) CCH (splitted)
;;  5) HCN 
;;  6) HCO+ 
;;  7) HNC 
;;  8) CS 
;;  9) SiO 
;; 10) HCNH+
;; 11) HOC+
;;
;; Additionally, a unknown species can be included by setting species equal
;; to a guess at the center freqency of the unknown line in the rest frame.

;; not all transitions are included (only CN 2-1 & CCH 3-2, for example)

FUNCTION make_template_spec, nu_fts, ftsspec, redshift_in, $
                             species, transition, $
                             line_width, scale, center
  
  redshift = redshift_in/299792.458
  ; This CASE switch creates the intrinsic line template
  CASE 1 OF
     species EQ 0: BEGIN                   ; CO
        center = (transition/2.D)*(230.5380000/(1.D + redshift))
        line = make_line_single(nu_fts, center, line_width)
     END
     species EQ 1: BEGIN                   ; 13CO
        center = (transition/2.0)*(220.3986765/(1.D + redshift))
        line = make_line_single(nu_fts, center, line_width)
     END
     species EQ 2: BEGIN                   ; C18O
        center = (transition/2.D)*(219.5603568/(1.D + redshift))
        line = make_line_single(nu_fts, center, line_width)
     END
     species EQ 3: BEGIN                   ; CN 
        center = (transition/2.D)*(226.8747450/(1.D + redshift))
        line = make_line_single(nu_fts, center, line_width)
;;         CASE transition OF
;;            2: line = make_line_cn2(nu_fts, redshift, line_width, $
;;                                    center)
;;            ELSE: MESSAGE, 'Unable to create CN line profile'
;;         ENDCASE
     END
     species EQ 4: BEGIN                   ; CCH 
        center = (transition/3.D)*(262.2084388/(1.D + redshift))
        line = make_line_single(nu_fts, center, line_width)
;;         CASE transition OF
;;            3: line = make_line_cch3(nu_fts, redshift, line_width, $
;;                                     center)
;;            ELSE: MESSAGE, 'Unable to create CN line profile'
;;         ENDCASE
     END
     species EQ 5: BEGIN                   ; HCN
        center = (transition/3.D)*(265.8861800/(1.D + redshift))
        line = make_line_single(nu_fts, center, line_width)
     END
     species EQ 6: BEGIN                   ; HCO+
        center = (transition/3.D)*(267.5576190/(1.D + redshift))
        line = make_line_single(nu_fts, center, line_width)
     END
     species EQ 7: BEGIN                   ; HNC
        center = (transition/3.0)*(271.9811420/(1.D + redshift))
        line = make_line_single(nu_fts, center, line_width)
     END
     species EQ 8: BEGIN                   ; CS
        center = (transition/6.D)*(293.9122440/(1.D + redshift))
        line = make_line_single(nu_fts, center, line_width)
     END
     species EQ 9: BEGIN                   ; SiO
        center = (transition/7.D)*(303.9269600/(1.D + redshift))
        line = make_line_single(nu_fts, center, line_width)
     END
     species EQ 10: BEGIN                  ; HCNH+
        center = (transition/4.D)*(296.4336811/(1.D + redshift))
        line = make_line_single(nu_fts, center, line_width)
     END
     species EQ 11: BEGIN                  ; HOC+
        center = (transition/3.D)*(268.4510940/(1.D + redshift))
        line = make_line_single(nu_fts, center, line_width)
     END
     (species/(1.D + redshift) GT 180.) AND $
        (species/(1.D + redshift) LT 320): BEGIN ;Mystery Line
        center = species/(1.D + redshift)
        line = make_line_single(nu_fts, center, line_width)
     END
     ELSE: MESSAGE, 'Species not defined'
  ENDCASE
  nbolos = (SIZE(ftsspec))[1]
  spec = DBLARR(nbolos)
  delnu = MEAN(nu_fts[1:*]-nu_fts[0:N_E(nu_fts)-2])
; Calculate the integral of the product of the fts profile and the 
; line profile (assuming equal spacing between fts freqencies)
  FOR b = 0L, nbolos - 1 DO BEGIN
     spec[b] = TOTAL(delnu*line*ftsspec[b,*])
  ENDFOR
  scale = 1.D/MAX(spec)
  spec *= scale
  RETURN, spec
END
