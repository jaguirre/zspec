basedir = ZSPEC_PIPELINE_ROOT + '/processing/spectra/coadded_spectra/'
freqs = freqid2freq()
dirs = ['M82_NE', 'M82_CEN', 'M82_SW']
ubernames = ['20100315_1457','20100315_1508','20100315_1512']
datfiles = dirs + '_' + ubernames + '.sav'
fitfiles = dirs + '_' + ubernames + '_zilf_fit.sav'
;fitfiles = REPLICATE('zilf_fit.sav', 3) ; dirs + '_fit.sav'
;datfiles = dirs + ['_20091001_2136','_20091001_2137','_20091001_2138'] + '.sav'

device = 'PS'

!P.THICK = 2.5
!P.CHARTHICK = 1.5
!X.THICK = 2
!Y.THICK = 2
!P.CHARSIZE = 1.0
!P.MULTI = [0,2,3]

CASE device of
   'X': BEGIN
      WINDOW, 0, XSIZE = 1200, YSIZE = 800
   END
   'PS': BEGIN
      SET_PLOT, 'ps', /COPY
      psfilename = 'M82_Jan09_residuals.eps'
      psfile = !ZSPEC_PIPELINE_ROOT + '/papers_in_progress/M82/idl_code/' + psfilename
      DEVICE, ENCAPSULATED=1, /INCHES, $
              /PORTRAIT, XOFF = 0, YOFF = 0, XSIZE = 12.0, YSIZE = 9.0, $
              FILENAME = psfile, /COLOR
   END 
ENDCASE


FOR i = 0, 2 DO BEGIN
   restore, basedir + '/' + dirs[i] + '/' + fitfiles[i] ;, /verb
   restore, basedir + '/' + dirs[i] + '/' + datfiles[i] ;, /verb
;   multiplot, /verb

   ploterror, freqs, uber_psderror.in1.avespec, uber_psderror.in1.aveerr, $
              PSYM = 10, $
              XRANGE = [183,310], /XSTY, YRANGE = [0.25,1.6], /YSTY, /NOHAT
   oplot, freqs, fit.lcspec, PSYM = 10, COLOR = 14, THICK = 2
   printlines_m82, [1.55,1.25,0.5,-0.05], MEAN(fit.redshift), -10, 10, NOTEXT = i
   XYOUTS, 190, 1.2, dirs[i], SIZE = 1.5
   
   plot, freqs, (uber_psderror.in1.avespec - fit.lcspec)/uber_psderror.in1.aveerr, $
         PSYM = 10,$
         XRANGE = [183,310], /XSTY, YRANGE = [-10,10], /YSTY
   printlines_m82, [9.5,5,-3,-11.5], MEAN(fit.redshift), -10, 10, NOTEXT = i
   oplot, [180,320], [5,5], COLOR = 12
   oplot, [180,320], [3,3], COLOR = 12, LINE = 2
   oplot, [180,320], [-5,-5], COLOR = 12
   oplot, [180,320], [-3,-3], COLOR = 12, LINE = 2
ENDFOR

IF device EQ 'PS' THEN DEVICE,/CLOSE   
!P.MULTI = 0
!P.THICK = 0
!P.CHARTHICK = 0
!X.THICK = 0
!Y.THICK = 0
!P.CHARSIZE = 0
SET_PLOT, 'X', /COPY

END
