; Compare & combine various rolloff fits 

path = !ZSPEC_PIPELINE_ROOT + PATH_SEP() + 'bolo_rolloff' + $
       PATH_SEP() + 'fit_data' + PATH_SEP() + 'all_fit_files' + PATH_SEP()

;files = path + ['rolloff_fits_20060412-16_10mV_100Hz.txt',$
;                'rolloff_fits_20060413-15_8mV_100Hz.txt',$
;                'rolloff_fits_20060417-19_10mV_100Hz.txt',$
;                'rolloff_fits_20060421-22_10mV_190Hz.txt',$
;                'rolloff_fits_20060422-25_10mV_100Hz.txt',$
;                'rolloff_fits_20060426-29_10mV_100Hz.txt']

files = path + ['rolloff_fits_20061221-22_8mV_71Hz.txt',$
                'rolloff_fits_20061230-31_8mV_71Hz.txt',$
                'rolloff_fits_20070102-03_8mV_71Hz.txt',$
                'rolloff_fits_20070104-05_8mV_71Hz.txt',$
                'rolloff_fits_20070106-09_8mV_71Hz.txt',$
                'rolloff_fits_20070112-13_8mV_71Hz.txt']

   
nfiles = N_ELEMENTS(files)
nbolos = 160
allcline = DBLARR(nbolos,nfiles)
allcline_err = DBLARR(nbolos,nfiles)
FOR file = 0, nfiles - 1 DO BEGIN
  READCOL, files[file], freqid, cline, phi, cline_err, phi_err, $
           FORMAT = 'I,F,F,F,F', COMMENT = '#'
  allcline[*,file] = cline
  allcline_err[*,file] = cline_err
ENDFOR

weights = 1/allcline_err^2
avecline = TOTAL(weights*allcline,2)/TOTAL(weights,2)
avecline_err = SQRT(1.D/TOTAL(weights,2))

avecline_noweight = DBLARR(nbolos)
avecline_err_noweight = DBLARR(nbolos)

sigmatest = DBLARR(nbolos,nfiles)
FOR bolo = 0, nbolos - 1 DO BEGIN
   avecline_noweight[bolo] = MEAN(allcline[bolo,*]);,/EVEN)
   avecline_err_noweight[bolo] = STDDEV(allcline[bolo,*])/SQRT(nfiles)
   FOR file = 0, nfiles - 1 DO BEGIN
      sigmatest[bolo,file] = ABS(allcline[bolo,file] - $
                                 avecline_noweight[bolo])/$
                             SQRT(allcline_err[bolo,file]^2 + $
                                  avecline_err_noweight[bolo]^2)
   ENDFOR
ENDFOR

FOR bolo = 0, nbolos -1 DO BEGIN
   PRINT, bolo, avecline[bolo], $
          avecline_noweight[bolo], $
          avecline_err[bolo], $
          avecline_err_noweight[bolo], $
          ;REFORM(allcline[bolo,*])
          WHERE(sigmatest[bolo,*] GT 2)
   IF (bolo MOD 40) EQ 39 THEN BEGIN
      blah = ''
      read, blah
   ENDIF
ENDFOR

out_file = path + 'cline_combine.txt'
FORPRINT, INDGEN(nbolos), avecline_noweight, avecline_err_noweight, $
          TEXTOUT = out_file, COMMENT = '# freqid, cline[pF], cline_err'

END
