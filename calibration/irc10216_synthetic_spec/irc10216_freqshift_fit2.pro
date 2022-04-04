
zfreq = freqid2freq(/no_shift)

surveypts = WHERE((zfreq GE 220 AND zfreq LE 246.5) OR $
                    (zfreq GE 250 AND zfreq LT 270))     

continuumpts = WHERE((zfreq GE 203 AND zfreq LE 207) OR $
                     (zfreq GE 279 AND zfreq LE 281.5) OR $
                     (zfreq GE 286 AND zfreq LE 289))

cspts = WHERE((zfreq GE 194 AND zfreq LE 198) OR $
              (zfreq GE 292 AND zfreq LE 296.5))

csisopts = WHERE((zfreq GE 192 AND zfreq LT 194) OR $
              (zfreq GE 289 AND zfreq LT 292))

linepts = WHERE((zfreq GE 198.5 AND zfreq LE 201) OR $
                (zfreq GE 216 AND zfreq LE 218.5) OR $
                (zfreq GE 270 AND zfreq LE 275) OR $
                (zfreq GE 301.5 AND zfreq LE 305))

hc3npts = WHERE((zfreq GE 190 AND zfreq LE 192) OR $
                (zfreq GE 208 AND zfreq LE 210) OR $
                (zfreq GE 218.5 AND zfreq LE 219) OR $
                (zfreq GE 281.5 AND zfreq LE 283) OR $
                (zfreq GE 299 AND zfreq LE 301.5))

; Load in FTS data
RESTORE, !ZSPEC_PIPELINE_ROOT + $
         '/line_cont_fitting/ftsdata/normspec_nov_noshift.sav'

upsample_factor = 3
npts_orig = N_E(nu_trim)
npts_ups = upsample_factor*npts_orig
spec_interpol = FLTARR(160,npts_ups)

FOR b = 0, 159 DO BEGIN
   spec_interpol[b,*] = $
      INTERPOL(REFORM(spec_coadd_norm[b,*]),npts_ups,/SPLINE)
ENDFOR

nu_trim_interpol = nu_trim[0] + $
                   (nu_trim[N_E(nu_trim)-1] - nu_trim[0]) * $
                   FINDGEN(npts_ups)/(npts_ups-1)

; Load in IRC10216 line survey data
readcol, !ZSPEC_PIPELINE_ROOT + '/calibration/irc10216_synthetic_spec/' + $
         'irc10216_1mm_lines.txt', linefreqs, linefluxes, linewidths, $
         FORMAT = 'D,D,D'

; scale line frequencies to be in GHz
linefreqs /= 1000.D

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
linewidth_fit = DBLARR(N_E(linefluxes)) + 75.D;linewidths;

RESTORE, !ZSPEC_PIPELINE_ROOT + '/processing/spectra/coadded_spectra/' + $
         'IRC10216/IRC10216_20090622_1907.sav'

; Create parinfo structure
parinfo = REPLICATE({value:0.D, $
                     fixed:0, $
                     limited:[1,1], $
                     limits:[0.D,0],$
                     parname:''}, $
                    16)

parinfo[0].value = 1.0
parinfo[0].limits = [0.0,2.0]
parinfo[0].parname = 'Continuum Amp [Jy]'

parinfo[1].value = 1.0
parinfo[1].limits = [1.0,4.0]
parinfo[1].parname = 'Continuum Index'

parinfo[2].value = 11.0
parinfo[2].limits = [4.0,15.0]
parinfo[2].parname = 'CS 4-3 Amp [1e3 Jy km/s]'

parinfo[3].value = 0
parinfo[3].limits = [-1.0,1.0]
parinfo[3].parname = 'CS Exponent'

parinfo[4].value = 1.0
parinfo[4].limits = [0.5,1.5]
parinfo[4].parname = 'CO 2-1 Scale Factor'
parinfo[4].fixed = 0

parinfo[5].value = 4.0
parinfo[5].limits = [0.0,8.0]
parinfo[5].parname = 'SiS 11 Amp [1e3 Jy km/s]'

parinfo[6].value = 1.0
parinfo[6].limits = [-3.0,3.0]
parinfo[6].parname = 'SiS Exponent'

parinfo[7].value = 300.
parinfo[7].limits = [0.0,500.0]
parinfo[7].parname = 'HNC Ratio [rel to HN13C]'

parinfo[8].value = 5.0
parinfo[8].limits = [0.0,8.0]
parinfo[8].parname = 'SiO 5-4 Amp [1e3 Jy km/s]'

parinfo[9].value = 0.0
parinfo[9].limits = [-3.0,3.0]
parinfo[9].parname = 'SiO Exponent'

parinfo[10].value = 2.0
parinfo[10].limits = [0.0,8.0]
parinfo[10].parname = 'HCCCN 21-20 Amp [1e3 Jy km/s]'

parinfo[11].value = 0.0
parinfo[11].limits = [-3.0,3.0]
parinfo[11].parname = 'HCCCN Exponent'

parinfo[12:*].value = [-0.4,0.5,-0.3,0]
parinfo[12:*].limits[0] = FLTARR(N_E(parinfo[12:*])) - 8.0
parinfo[12:*].limits[1] = FLTARR(N_E(parinfo[12:*])) + 8.0
parinfo[12:*].parname = 'Frequency^'+$
                        STRING(INDGEN(N_E(parinfo[12:*])),F='(I0)')+' Factor'
parinfo[12:*].fixed = [0,0,0,1]

fitpts = [surveypts,continuumpts,cspts,csisopts,linepts,hc3npts]


; Create independent variable structure
fit_input = CREATE_STRUCT('fts_freq', nu_trim_interpol, $
                          'fts_spec', spec_interpol[fitpts,*], $
                          'linefreq', linefreqs, $
                          'lineflux', linefluxes_jy_fill, $
                          'linewdth', linewidth_fit)

fit_result = mpfitfun('irc10216_freqshift_fitfun', fit_input, $
                      uber_psderror.in1.avespec[fitpts], $
                      uber_psderror.in1.aveerr[fitpts], $
                      PARINFO = parinfo, $
                      DOF = dof, BESTNORM = bestnorm, $
                      PERROR = fit_error, COVAR = covar, $
                      FTOL = 1e-4)

PRINT, fit_result, fit_error, BESTNORM/DOUBLE(dof), dof, covar

fit_input_all = CREATE_STRUCT('fts_freq', nu_trim_interpol, $
                              'fts_spec', spec_interpol, $
                              'linefreq', linefreqs, $
                              'lineflux', linefluxes_jy_fill, $
                              'linewdth', linewidth_fit)
fit_spec = irc10216_freqshift_fitfun(fit_input_all, fit_result) ;,/TOP_HAT)
fit_spec_top = irc10216_freqshift_fitfun(fit_input_all, fit_result,/TOP_HAT)

WINDOW, 0, XSIZE = 1050, YSIZE = 800

zfreq = freqid2freq(/no_shift)
zfreq += POLY(((zfreq - 180.D)/(320.D - 180.D)),fit_result[12:*])

;; SET_PLOT, 'ps', /COPY
;; psfile = !ZSPEC_PIPELINE_ROOT + '/calibration/irc10216_synthetic_spec/' + $
;;          'irc10216_freqshift_fit2.eps'
;; DEVICE,FILENAME=psfile,/inches,/color,$
;;        xsize=10.5, ysize=8.0, /ENCAPSULATED, XOFF = 0, YOFF = 0

!P.MULTI = [0,1,2]

PLOTERROR, zfreq, uber_psderror.in1.avespec, uber_psderror.in1.aveerr, $
           PSYM = 10, /NOHAT, XRANGE = [184,308], /XST, $
           TITLE = 'IRC +10216 Measured and Fitted Spectrum', $
           XTITLE = '(Corrected) Frequency [GHz]', YTITLE = 'Flux Density [Jy]'

OPLOT, zfreq, fit_spec, PSYM = 10, COLOR = 2
OPLOT, zfreq[fitpts], fit_spec[fitpts], PSYM = 2, COLOR = 2, SYMSIZE = 0.75
OPLOT, zfreq, fit_spec_top, PSYM = 10, COLOR = 3

RESTORE, !ZSPEC_PIPELINE_ROOT + '/processing/spectra/coadded_spectra/' + $
         'IRC10216/zilf_fit.sav'

printlines_zilf, fit, [0.5,0.7,0.9], LINE = 2, COLOR = 4
XYOUTS, 200, 15, 'Chi Sq/DOF ='
XYOUTS, 215, 13.5, STRING(BESTNORM/DOUBLE(dof), F = '(F0.3)'), ALIGN = 1.0

!P.MULTI = [2,2,2]
fitpts_sort = fitpts[SORT(fitpts)]
resids = (uber_psderror.in1.avespec[fitpts_sort] - fit_spec[fitpts_sort])/$
         uber_psderror.in1.aveerr[fitpts_sort]
resids_top = (uber_psderror.in1.avespec[fitpts_sort] - $
              fit_spec_top[fitpts_sort])/$
             uber_psderror.in1.aveerr[fitpts_sort]
PLOT, zfreq[fitpts_sort], resids, PSYM = 10, $
      XRANGE = !X.CRANGE, /XST, /NODATA, $
      XTITLE = '(Corrected) Frequency [GHz]', $
      YTITLE = '(Data - Fit)/Error'
OPLOT, zfreq[fitpts_sort], resids, PSYM = 10, COLOR = 2
OPLOT, zfreq[fitpts_sort], resids_top, PSYM = 10, COLOR = 3

resid_hist = HISTOGRAM(resids, BINSIZE = 0.5, MIN = -6, MAX = 6, $
                       LOCATIONS = hist_bins)
resid_hist_top = HISTOGRAM(resids_top, BINSIZE = 0.5, MIN = -6, MAX = 6, $
                           LOCATIONS = hist_bins_top)
PLOT, hist_bins, resid_hist, PSYM = 10, /NODATA, $
      TITLE = 'Histogram of Fit Residuals', $
      XTITLE = 'Normalized Residual Bins', YTITLE = '# in Bin'
OPLOT, hist_bins, resid_hist, PSYM = 10, COLOR = 2
OPLOT, hist_bins_top, resid_hist_top, PSYM = 10, COLOR = 3
hist_fit = GAUSSFIT(hist_bins, resid_hist, coeff, $
                    NTERMS = 3, CHISQ = GAUSSCHI)
OPLOT, hist_bins, hist_fit, COLOR = 4
PRINT, coeff, gausschi

!P.MULTI = 0

WINDOW, 1, XSIZE = 1050, YSIZE = 800

;; DEVICE, /CLOSE
;; psfile = !ZSPEC_PIPELINE_ROOT + '/calibration/irc10216_synthetic_spec/' + $
;;          'irc10216_freqshift.eps'
;; DEVICE,FILENAME=psfile,/inches,/color,/PORTRAIT, $
;;        xsize=10.5, ysize=8.0, /ENCAPSULATED, XOFF = 0, YOFF = 0

fts_freq_norm = (nu_trim_interpol - 180.D)/(320.D - 180.D)
PLOT, nu_trim_interpol, POLY(fts_freq_norm, fit_result[12:*]), $
      XRANGE = [180,320], /XST, $
      TITLE = 'Z-Spec Frequency Shift from IRC +10216 Measurements', $
      XTITLE = 'Frequency [GHz]', YTITLE = 'Frequency Shift [GHz]'
zfreq = freqid2freq(/no_shift)
zfreq += POLY(((zfreq - 180.D)/(320.D - 180.D)),fit_result[12:*])
OPLOT, freqid2freq(/no_shift), zfreq - freqid2freq(/no_shift), COLOR = 2, PSYM = 2

;; DEVICE, /CLOSE
;; SET_PLOT, 'X', /COPY

END

   
