basedir = ZSPEC_PIPELINE_ROOT + '/processing/spectra/coadded_spectra/'
freqs = freqid2freq()
pts = ['NE','CEN','SW']
dirs = 'M82_' + pts
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
;!P.MULTI = [0,1,3]
multiplot,[1,3],/verb
CASE device of
   'X': BEGIN
      WINDOW, 0, XSIZE = 900, YSIZE = 825
      !P.BACKGROUND = 1
   END
   'PS': BEGIN
      SET_PLOT, 'ps', /COPY
      psfilename = 'M82_Jan09_spectra.eps'
      psfile = !ZSPEC_PIPELINE_ROOT + '/papers_in_progress/M82/idl_code/' + psfilename
      DEVICE, ENCAPSULATED=1, /INCHES, $
              /PORTRAIT, XOFF = 0, YOFF = 0, XSIZE = 10.2, YSIZE = 9.35, $
              FILENAME = psfile, /COLOR
   END 
ENDCASE

FOR i = 0, 2 DO BEGIN
   restore, basedir + '/' + dirs[i] + '/' + fitfiles[i] ;, /verb
   restore, basedir + '/' + dirs[i] + '/' + datfiles[i] ;, /verb
   IF i LT 2 THEN xtitle = '' ELSE xtitle = 'Frequency [GHz]'
   ploterror, freqs, uber_psderror.in1.avespec, uber_psderror.in1.aveerr, $
              PSYM = 10, $
              XRANGE = [190,310], /XSTY, YRANGE = [0.25,1.68], /YSTY, /NOHAT, $
              YTITLE = 'Flux Density [Jy]', XTITLE = xtitle, THICK = 4, ERRTHICK = 4
   oplot, freqs, fit.lcspec, PSYM = 10, COLOR = 14, THICK = 2
   printlines_m82, [1.65,1.35,1.1,0.515], MEAN(fit.redshift), -10, 10, NOTEXT = i
   XYOUTS, 197, 1.55, pts[i], SIZE = 1.5, CHARTHICK = 2.5
   IF i LT 2 THEN multiplot, /verb
   corange = WHERE(freqs GT 228 AND freqs LT 233)
   cospec = uber_psderror.in1.avespec[corange]-fit.cspec[corange]
   oploterror, freqs[corange], (cospec/10.)+fit.cspec[corange], $
               uber_psderror.in1.aveerr[corange]/10., $
               PSYM = 10, /NOHAT, COLOR = 16, ERRCOLOR = 16
   oplot, freqs[corange], $
          (fit.lcspec[corange]-fit.cspec[corange])/10.+fit.cspec[corange], $
          PSYM = 10, COLOR = 7, THICK = 1.5
   xyouts, 234, 1.15, ALIGN = 0.5, COLOR = 16, 'CO!C!M/10', $
           SIZE = 1.25, CHARTHICK = 2.0
   oplot, freqs, fit.cspec, LINE = 5, COLOR = 9
   
ENDFOR

IF device EQ 'PS' THEN DEVICE,/CLOSE  
multiplot,/reset,/verb 
!P.MULTI = 0
!P.THICK = 0
!P.CHARTHICK = 0
!X.THICK = 0
!Y.THICK = 0
!P.CHARSIZE = 0
SET_PLOT, 'X', /COPY

END
