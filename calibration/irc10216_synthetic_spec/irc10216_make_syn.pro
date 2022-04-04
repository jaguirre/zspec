device = 'X'

!P.THICK = 2.5
!P.CHARTHICK = 1.5
!X.THICK = 2
!Y.THICK = 2
!P.CHARSIZE = 1.0

CASE device of
   'X': BEGIN
      WINDOW, 0, XSIZE = 1050, YSIZE = 800
   END
   'PS': BEGIN
      SET_PLOT, 'ps', /COPY
      psfilename = 'IRC10216_Synth_Spec.eps'
;      psfilename = 'IRC10216_Synth_Spec_ModelShift.eps'
      psfile = !ZSPEC_PIPELINE_ROOT + '/calibration/irc10216_synthetic_spec/' + $
               psfilename
      DEVICE, ENCAPSULATED=1, /INCHES, $
              /PORTRAIT, XOFF = 0, YOFF = 0, XSIZE = 10.5, YSIZE = 8.0, $
              FILENAME = psfile, /COLOR
   END 
ENDCASE

; Load in FTS data
RESTORE, !ZSPEC_PIPELINE_ROOT + $
         '/line_cont_fitting/ftsdata/normspec_nov.sav'

upsample_factor = 3
npts_orig = N_E(nu_trim)
npts_ups = upsample_factor*npts_orig
spec_interpol = FLTARR(160,npts_ups)

FOR b = 0, 159 DO spec_interpol[b,*] = $
   INTERPOL(REFORM(spec_coadd_norm[b,*]),npts_ups)

nu_trim_interpol = nu_trim[0] + $
                   (nu_trim[N_E(nu_trim)-1] - nu_trim[0]) * $
                   FINDGEN(npts_ups)/(npts_ups-1)
   
; Load in IRC10216 line survey data
readcol, !ZSPEC_PIPELINE_ROOT + '/calibration/irc10216_synthetic_spec/' + $
         'irc10216_1mm_lines.txt', linefreqs, linefluxes, linewidths

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

linespec = FLTARR(160)
linespec_fill = FLTARR(160)
linespec_tophat = FLTARR(160)

RESTORE, !ZSPEC_PIPELINE_ROOT + '/processing/spectra/coadded_spectra/' + $
         'IRC10216/zilf_fit.sav'
fixed_LW = 75.
redshift = fit.redshift[0]

FOR line = 0, N_E(linefluxes)-1 DO BEGIN
IF line MOD 10 EQ 0 THEN print, line
   currfreq = linefreqs[line]/(1+redshift)
   newline = zspec_make_line(nu_trim_interpol, spec_interpol, 0.0, $
                             currfreq, fixed_LW, $
                             scale, center)
   amp = linefluxes_jy[line]/(scale*fixed_LW)
   linespec += amp*newline
   amp = linefluxes_jy_fill[line]/(scale*fixed_LW)
   linespec_fill += amp*newline
   newline = zspec_make_line(nu_trim_interpol, spec_interpol, 0.0, $
                             currfreq, fixed_LW, $
                             scale, center, /TOP_HAT)
   amp = linefluxes_jy[line]/(scale*fixed_LW)
   linespec_tophat += amp*newline
END

linespec += fit.cspec
linespec_fill += fit.cspec
linespec_tophat += fit.cspec

zfreq = freqid2freq()

PLOT, zfreq, linespec, YRANGE = [0,25], XRANGE = [215,270], /XST, $
      XTITLE = 'Frequency [GHz]', YTITLE = 'Flux Density [Jy]', $
      TITLE = 'IRC 10216 Z-Spec and Synthetic Spectrum', PSYM = 10

OPLOT, zfreq, linespec_fill, COLOR = 2, PSYM = 10
OPLOT, zfreq, linespec_tophat, PSYM = 10, COLOR = 6

RESTORE, !ZSPEC_PIPELINE_ROOT + '/processing/spectra/coadded_spectra/' + $
         'IRC10216/IRC10216_20090622_1907.sav'
OPLOTERROR, zfreq, uber_psderror.in1.avespec, uber_psderror.in1.aveerr, $
            PSYM = 10, /NOHAT, THICK = 5

OPLOT, zfreq, fit.lcspec, COLOR = 4, PSYM = 10

OPLOT, [219.5,245.5], [0.5,0.5], THICK = 8
OPLOT, [251.5,267.5], [0.5,0.5], THICK = 8

printlines_zilf, fit, [0.7,0.8,0.9], COLOR = 3, LINE = 5, CHARSIZE = 1.5

IF device EQ 'PS' THEN BEGIN
   DEVICE,/CLOSE   
ENDIF
!P.THICK = 0
!P.CHARTHICK = 0
!X.THICK = 0
!Y.THICK = 0
!P.CHARSIZE = 0
SET_PLOT, 'X', /COPY

END
