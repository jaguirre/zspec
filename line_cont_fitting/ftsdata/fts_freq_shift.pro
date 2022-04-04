; Script to update fts data with polynomial frequency shift

; Load in FTS data
RESTORE, !ZSPEC_PIPELINE_ROOT + $
         '/line_cont_fitting/ftsdata/normspec_nov_noshift.sav'

; Shift frequencies according to fitted 2nd order polynomial shift
; from IRC +10216 data

polycof = [-0.45522401,      0.59646798,     -0.30161380]
nu_norm = (nu_trim - 180.D)/(320.D - 180.D)
nu_trim += POLY(nu_norm, polycof)

; Now compute the normalizing integral for each optical channel
nbolos = 160
norm = DBLARR(nbolos)
peak = norm
nu_peak = norm

PRINT, 'Computing Normalization Integral'

delnu = DBLARR(N_E(nu_trim))
delnu[0:N_E(nu_trim)-2] = nu_trim[1:*]-nu_trim[0:N_E(nu_trim)-2]
delnu[N_E(nu_trim)-1] = delnu[N_E(nu_trim)-2]

FOR i = 0L, nbolos - 1 DO BEGIN
   norm[i] = TOTAL(delnu*spec_coadd_norm[i,*])
   spec_coadd_norm[i,*] /= norm[i]
   peak[i] = MAX(spec_coadd_norm[i,*],maxind)
   nu_peak[i] = nu_trim[maxind]
ENDFOR

SAVE, nu_trim, spec_coadd_norm, peak, nu_peak, peak_fraction, $
      FILE = !ZSPEC_PIPELINE_ROOT + '/line_cont_fitting/' + $
      'ftsdata/normspec_nov.sav'
END 


