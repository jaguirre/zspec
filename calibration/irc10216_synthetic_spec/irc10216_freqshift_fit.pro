
zfreq = freqid2freq()

fitrange = WHERE((zfreq GE 203 AND zfreq LE 207) OR $
                 (zfreq GE 279 AND zfreq LE 281.5) OR $
                 (zfreq GE 286 AND zfreq LE 289) OR $
                 (zfreq GE 301 AND zfreq LE 301.5) OR $
                 (zfreq GE 194 AND zfreq LE 198) OR $
                 (zfreq GE 292 AND zfreq LE 296.5) OR $
                 (zfreq GE 220 AND zfreq LE 246.5) OR $
                 (zfreq GE 250 AND zfreq LE 270))     

; Load in FTS data
RESTORE, !ZSPEC_PIPELINE_ROOT + $
         '/line_cont_fitting/ftsdata/normspec_nov.sav'

upsample_factor = 3
npts_orig = N_E(nu_trim)
npts_ups = upsample_factor*npts_orig
spec_interpol = FLTARR(160,npts_ups)

FOR b = 0, 159 DO BEGIN
;   b_ind = fitrange[b]
   spec_interpol[b,*] = $
      INTERPOL(REFORM(spec_coadd_norm[b,*]),npts_ups,/SPLINE)
ENDFOR

nu_trim_interpol = nu_trim[0] + $
                   (nu_trim[N_E(nu_trim)-1] - nu_trim[0]) * $
                   FINDGEN(npts_ups)/(npts_ups-1)

; Load in IRC10216 line survey data
readcol, !ZSPEC_PIPELINE_ROOT + '/calibration/irc10216_synthetic_spec/' + $
         'irc10216_1mm_lines.txt', linefreqs, linefluxes, linewidths

; scale down CO 2-1 intensity by 20%
;linefluxes[52] *= 0.8
; scale line frequencies to be in GHz
linefreqs /= 1000.0

linefluxes_jy = linefluxes
; convert to Jy km/s
FOR l = 0, N_E(linefluxes)-1 DO $
   linefluxes_jy[l] = zspec_ktojy(linefluxes[l],$
                                  linefreqs[l], $
                                  BEAMSIZE = (31.0 * (240.0/linefreqs[l])^2))

; scale fluxes for beam filling source
linefluxes_jy_fill = linefluxes_jy * $
                     (fwhm_from_beammap(linefreqs)*(180./!DPI)*3600.)^2 * $
                     (31.0 * (240.0/linefreqs)^2)^(-2)

; Use fixed linewidths
linewidth_fit = FLTARR(N_E(linefluxes)) + 100.

; Create independent variable structure
fit_input = CREATE_STRUCT('fts_freq', nu_trim_interpol, $
                          'fts_spec', spec_interpol[fitrange,*], $
                          'linefreq', linefreqs, $
                          'lineflux', linefluxes_jy_fill, $
                          'linewdth', linewidth_fit)

parinfo = REPLICATE({value:0.D, $
                     fixed:0, $
                     limited:[0,0], $
                     limits:[0.D,0],$
                     tied:'',$
                     parname:''}, $
                    8)


parinfo[0].value = 0.9
parinfo[0].limited = [1,1]
parinfo[0].limits = [0.0,2.0]
parinfo[0].parname = 'Continuum Amplitude'

parinfo[1].value = 2.4
parinfo[1].limited = [1,1]
parinfo[1].limits = [1.0,4.0]
parinfo[1].parname = 'Continuum Index'

parinfo[2].value = 5.2
parinfo[2].limited = [1,1]
parinfo[2].limits = [2.0,8.0]
parinfo[2].parname = 'CS 4-3 Amp'

parinfo[3].value = 4.5
parinfo[3].limited = [1,1]
parinfo[3].limits = [2.0,8.0]
parinfo[3].parname = 'CS 6-5 Amp'

parinfo[4].value = 0.84
parinfo[4].limited = [1,1]
parinfo[4].limits = [0.5,1.0]
parinfo[4].parname = 'CO 2-1 Scale Factor'

parinfo[5].value = -1.1
parinfo[5].limited = [1,1]
parinfo[5].limits = [-2.0,2.0]
parinfo[5].parname = 'Frequency Factor'

parinfo[6].value = 0.84
parinfo[6].fixed = 0
parinfo[6].limited = [1,1]
parinfo[6].limits = [-2.0,2.0]
parinfo[6].parname = 'Frequency^2 Factor'

parinfo[7].value = 0.0
parinfo[7].fixed = 0
parinfo[7].limited = [1,1]
parinfo[7].limits = [-2.0,2.0]
parinfo[7].parname = 'Frequency^3 Factor'

RESTORE, !ZSPEC_PIPELINE_ROOT + '/processing/spectra/coadded_spectra/' + $
         'IRC10216/IRC10216_20090622_1907.sav'

fit_result = mpfitfun('irc10216_freqshift_fitfun', fit_input, $
                      uber_psderror.in1.avespec[fitrange], $
                      uber_psderror.in1.aveerr[fitrange], $
                      PARINFO = parinfo, $
                      DOF = dof, BESTNORM = bestnorm, $
                      PERROR = fit_error, COVAR = covar, FTOL = 1e-4)

PRINT, fit_result, fit_error, BESTNORM/DOUBLE(dof), dof, covar

fit_input_all = CREATE_STRUCT('fts_freq', nu_trim_interpol, $
                              'fts_spec', spec_interpol, $
                              'linefreq', linefreqs, $
                              'lineflux', linefluxes_jy_fill, $
                              'linewdth', linewidth_fit)
fit_spec = irc10216_freqshift_fitfun(fit_input_all, fit_result)

WINDOW, 0, XSIZE = 1200, YSIZE = 900
!P.MULTI = [0,1,2]
PLOTERROR, zfreq, uber_psderror.in1.avespec, uber_psderror.in1.aveerr, $
           PSYM = 10, /NOHAT, XRANGE = [185,308], /XST

OPLOT, zfreq, fit_spec, PSYM = 10, COLOR = 2
OPLOT, zfreq[fitrange], fit_spec[fitrange], PSYM = 2, COLOR = 2

RESTORE, !ZSPEC_PIPELINE_ROOT + '/processing/spectra/coadded_spectra/' + $
         'IRC10216/zilf_fit.sav'
printlines_zilf, fit, [0.5,0.7,0.9]

!P.MULTI = [2,2,2]
resids = (fit_spec[fitrange] - uber_psderror.in1.avespec[fitrange])/$
         uber_psderror.in1.aveerr[fitrange]
PLOT, zfreq[fitrange], resids, PSYM = 10, $
      XRANGE = !X.CRANGE, /XST

resid_hist = HISTOGRAM(resids, BINSIZE = (0.8), MIN = -5, MAX = 7, $
                       LOCATIONS = hist_bins)
PLOT, hist_bins, resid_hist, PSYM = 10
hist_fit = GAUSSFIT(hist_bins, resid_hist, coeff, $
                    NTERMS = 3, CHISQ = GAUSSCHI)
OPLOT, hist_bins, hist_fit, COLOR = 2 
PRINT, coeff, gausschi

!P.MULTI = 0
END

