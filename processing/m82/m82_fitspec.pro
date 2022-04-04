
!P.MULTI = [0,1,3]
makeps = !FALSE
IF makeps THEN BEGIN
   !P.CHARTHICK = 2
   !P.THICK = 2
   !X.THICK = 1.5
   !Y.THICK = 1.5
   !P.CHARSIZE = 1.0
   !P.PSYM = 10
   psfilename = 'SimplePowerLawAllLinesSO2.eps'
   SET_PLOT, 'ps', /COPY
   psfile = !ZSPEC_PIPELINE_ROOT + '/working_bret/plots/in/' + psfilename
   DEVICE, ENCAPSULATED=1, /INCHES, $
           /PORTRAIT, XOFF = 0, YOFF = 0, XSIZE = 6.0, YSIZE = 8.0, $
           FILENAME = psfile, /COLOR
ENDIF ELSE BEGIN
   ; Do nothing
ENDELSE

refit = !FALSE
ptname = ['','P1','P2','P3','P4','P3A','P3B']
FOR obsset = 2, 4 DO BEGIN
   CASE obsset OF               ; Select Observation
      1:BEGIN                   ; Observations offset (-9,-3.5)
         marsnight = 16 & marsobs = 1 & night = 16 & sourceobs = [4,6,7]
         raoff = -9 & decoff = -3.5
         datafilename = 'm82-09-35.sav'
         linepeaks = [3.41,0.29,0.05,0.22,0.05,0.14,0.05,$
                      0.11,0.08,0.05,0.05,0.08,0.05,0.05]
;         cont_start_par = [240.0,0.30,1.4]
         cont_start_par = [0.28,48.1,1.5,0.28]
         redshift_guess = 110.0
         linewidth = 250.
      END
      2:BEGIN                   ; These observations are of M82 center
         marsnight = 14 & marsobs = 6 & night = 14 & sourceobs = [8,9,10]
         raoff = 0 & decoff = 0
         datafilename = 'm82+00+00.sav'
         linepeaks = [7.72,0.57,0.18,0.40,0.05,0.14,0.07,$
                      0.28,0.10,0.20,0.05,0.17,0.05,0.12]
;         cont_start_par = [240.0,0.57,1.3]
         cont_start_par = [0.62,48.1,1.6,0.62]
         redshift_guess = 170.0
         linewidth = 250.
      END
      3:BEGIN                   ; Observations offset (+8,+3) & (+9,+3.5)
         marsnight = [14,16] & marsobs = [6,1] 
         night = [14,16] & sourceobs = [13,14,   8,9,10,11] 
         raoff = [+8,+9] & decoff = [+3,+3.5]
         datafilename = 'm82+0809+3035.sav'
         linepeaks = [7.81,0.70,0.04,0.38,0.08,0.22,0.05,$
                      0.27,0.10,0.06,0.09,0.05,0.09,0.05]
;         cont_start_par = [240.0,0.59,0.8]
         cont_start_par = [0.74,48.1,1.6,0.74]
         redshift_guess = 210.0
         linewidth = 250.
      END
      4:BEGIN                   ; Observations offset (+18,+7)
         marsnight = 14 & marsobs = 6 & night = 14 & sourceobs = [11,12]
         raoff = +18 & decoff = +7
         datafilename = 'm82+18+70.sav'
         linepeaks = [9.49,0.73,0.09,0.38,0.05,0.24,0.05,$
                      0.33,0.06,0.05,0.11,0.05,0.07,0.05]
;         cont_start_par = [240.0,0.44,0.5]
         cont_start_par = [0.58,48.1,1.6,0.58]
         redshift_guess = 250.0
         linewidth = 250.
      END
      5:BEGIN                   ; Observations offset (+8,+3)
         marsnight = 14 & marsobs = 6 & night = 14 & sourceobs = [13,14]
         raoff = +8 & decoff = +3
         datafilename = 'm82+08+30.sav'
         linepeaks = [8.49,0.68,0.15,0.42,0.14,0.16,0.08,$
                      0.29,0.10,0.17,0.09,0.09,0.05,0.05]
;         cont_start_par = [240.0,0.57,0.9]
         cont_start_par = [0.74,48.1,1.6,0.74]
         redshift_guess = 210.0
         linewidth = 250.
      END
      6:BEGIN                   ; Observations offset (+9,+3.5)
         marsnight = 16 & marsobs = 1 
         night = 16 & sourceobs = [8,9,10,11] 
         raoff = +9 & decoff = +3.5
         datafilename = 'm82+09+35.sav'
         linepeaks = [7.81,0.70,0.04,0.38,0.08,0.22,0.05,$
                      0.27,0.10,0.06,0.09,0.05,0.09,0.05]
;         cont_start_par = [240.0,0.59,0.7]
         cont_start_par = [0.74,48.1,1.6,0.74]
         redshift_guess = 210.0
         linewidth = 250.
      END
   ENDCASE
   FOR datatype = 1, 1, 2 DO BEGIN
      CASE datatype OF
         0: BEGIN
            psd = 1 & unweighted = 0
            errbin = 5 & sigma = 4.0
            datafilesuffix = '_psd05.sav'
         END
         1: BEGIN
            psd = 1 & unweighted = 0
            errbin = 10 & sigma = 4.0
            datafilesuffix = '_psd10.sav'
         END
         2: BEGIN
            psd = 0 & unweighted = 0
            errbin = 10 & sigma = 4.0
            datafilesuffix = '_nod10.sav'
         END
         3: BEGIN
            psd = 0 & unweighted = 1
            errbin = 5 & sigma = 4.0
            datafilesuffix = '_unw40.sav'
         END
      ENDCASE
      FOR cofix = 1, 1 DO BEGIN
         newdatafilename = change_suffix(datafilename,datafilesuffix)
         IF cofix EQ 1 THEN $
            newdatafilename = change_suffix(newdatafilename,'_cofix.sav')
         RESTORE, !ZSPEC_PIPELINE_ROOT + '/working_bret/m82/joined_data/' + $
                  newdatafilename
         
         freqshift = 95.5D      ; km/s
         sol = 299792.458
         freqs *= 1.0/(1.0 + freqshift/sol)
         binfreqs *= 1.0/(1.0 + freqshift/sol)
         
         binfreqid = 60         ; freqid of first non-binned channel
         IF binfreqid GT 0 THEN BEGIN
            newfreqs = [binfreqs[0:(binfreqid/2)-1],freqs[binfreqid:*]]
            newavespec = [binavespec[0:(binfreqid/2)-1],avespec[binfreqid:*]]
            newaveerr = [binaveerr[0:(binfreqid/2)-1],aveerr[binfreqid:*]]
            
            freqs = newfreqs
            avespec = newavespec
            aveerr = newaveerr
         ENDIF
         
         ;fitrange = WHERE(freqs GT 194 AND freqs LT 300)
         ;fitrange = WHERE(freqs GT 213 AND freqs LT 279)
         fitrange0 = WHERE(freqs GT 213 AND freqs LT 215)
         fitrange1 = WHERE(freqs GT 218 AND freqs LT 250.5)
;         fitrange1 = WHERE(freqs GT 218 AND freqs LE 251)
         fitrange2 = WHERE(freqs GT 251 AND freqs LT 272)
         fitrange3 = WHERE(freqs GT 273 AND freqs LT 276)

         fitrange = [fitrange0,fitrange1,fitrange2,fitrange3]
         
         xr = [184,309]
         !P.PSYM = 10
         PLOTERROR, freqs, avespec, aveerr, YRANGE = [-0.2,1.4], $
                    XRANGE = xr, /xst, /yst, $
                    TITLE = ptname[obsset], $
                    YTITLE = 'Flux Density!CF!D!4m!3!N [Jy]'
         FOR range = 0, 3 DO BEGIN
            CASE range OF
               0: curr = fitrange0
               1: curr = fitrange1
               2: curr = fitrange2
               3: curr = fitrange3
            ENDCASE
            OPLOTERROR, freqs[curr], avespec[curr], $
                        aveerr[curr], $
                        COLOR = 2, /NOHAT, ERRCOLOR = 2
         ENDFOR
         lines_on = [1,1,1, 1,1,0, 0,0, 1,1,1, 0,0,0, 1,1,1, 0, 0,0, 1, 1, 1, 1]
;;          lines_on = [1,1,0, 1,1,0, 0,0, 0,0,0, 0,0,0, 0,0,1, 0]
          printlines, 1.23-0.15*[0,1,2,3], redshift_guess, LINES_ON = lines_on
;          sofreqs = [235.1517,241.6158,251.1997,271.529]
;          FOR soline = 0, N_E(sofreqs) - 1 DO $
;             OPLOT, sofreqs[soline]*[1,1]/(1.0 + 210.1/sol), $
;                    !Y.CRANGE, COLOR = 5, LINE = 2
          
;;          plotspec = avespec
;;          ploterr = plotspec
;;          FOR i = 0, N_E(sourceobs)-1 DO BEGIN
;;             FOR bolo = 0, N_E(freqs) - 1 DO BEGIN
;;                IF bolo LT binfreqid/2 THEN BEGIN
;;                   currnods = [cal.in1.nodspec[2*bolo,(10*i):(10*i)+9],$
;;                               cal.in1.nodspec[2*bolo+1,(10*i):(10*i)+9]]
;;                   currerrs = [cal.in1.noderr[2*bolo,(10*i):(10*i)+9],$
;;                               cal.in1.noderr[2*bolo+1,(10*i):(10*i)+9]]
;;                ENDIF ELSE BEGIN
;;                   currnods = $
;;                      cal.in1.nodspec[bolo+(binfreqid/2),(10*i):(10*i)+9]
;;                   currerrs = $
;;                      cal.in1.noderr[bolo+(binfreqid/2),(10*i):(10*i)+9]
;;                ENDELSE 
;;                IF unweighted EQ 0 THEN BEGIN
;;                   plotspec[bolo] = $
;;                      weighted_mean(currnods,currerrs,ERRBIN = errbin)
;;                   ploterr[bolo] = $
;;                      weighted_sdom(currerrs,ERRBIN = errbin)
;;                ENDIF ELSE BEGIN
;;                   plotspec[bolo] = $
;;                      rm_outlier(currnods,sigma,$
;;                                 currmask,currsigma,/SDEV,QUIET = 1)
;;                   ploterr[bolo] = currsigma
;;                ENDELSE
;;             ENDFOR
;;             OPLOTERROR, freqs, plotspec, ploterr, $
;;                         COLOR = i + 7, PSYM = 4, $
;;                         ERRCOLOR = i + 7, /NOHAT, SYMSIZE = 0.3
;;          ENDFOR
         fitdatafile = !ZSPEC_PIPELINE_ROOT + '/working_bret/m82/fit_data/' + $
                       change_suffix(newdatafilename,$
;                                     '_planck_brightlines_.sav')
;                                     '_planck_alllines_fixB.sav')
;                                     '_power_brightlines_.sav')
                                     '_power_alllines_so2.sav')
         
         IF FILE_TEST(fitdatafile) AND ~(refit) THEN BEGIN
            RESTORE, fitdatafile
         ENDIF ELSE BEGIN
            fitdata = fit_lines_planck(fitrange,$
                                       avespec,$
                                       aveerr,redshift_guess,$
                                       [0,1,2,3,221.96521,$
                                        4,5,6,7,255.9581,8,$
                                        235.1517,241.6158],$
                                       [2,2,2,2,1,3,3,3,3,1,5,1,1],$
                                       [linepeaks[[0,1,2,3,4,5,6,$
                                                  7,8,10,12]],$
                                        0.5,0.5],$
;;                                        [0,1,3,4,6],$
;;                                        [2,2,2,3,3],$
;;                                        linepeaks[[0,1,3,5,7]],$
                                       LW_VALUE = 250.,/LW_TIED,$
                                       /LW_FIXED, $
                                ;CONT_START_PAR = cont_start_par,$
                                       CONT_START_PAR = $
                                       [0.5,0.0,1.0,0.5],$
                                       FREQSHIFT = freqshift,$
                                       BINFREQID = binfreqid)
            SAVE, fitdata, binfreqid, $
                  fitrange, fitrange0, fitrange1, fitrange2, fitrange3, $
                  FILE = fitdatafile
         ENDELSE
         
         OPLOT, freqs, fitdata.lcspec, COLOR = 6
         OPLOT, freqs, fitdata.cspec, COLOR = 3
         cspec = hughes94_fitfun(freqs,$
                                 [fitdata.camp,fitdata.ctemp,$
                                  fitdata.cexp,fitdata.cffamp])
         OPLOT, freqs, cspec, COLOR = 3, PSYM = 0, LINE = 2
         OPLOT, freqs, hughes94_fitfun(freqs,$
                                       [0.0,fitdata.ctemp,$
                                        fitdata.cexp,fitdata.cffamp]), $
                COLOR = 3, PSYM = 0, LINE = 3
         XYOUTS, 190, 0.1, '!4v!3!E2!N/d.o.f. = ' + $
                 STRING(fitdata.redchi,F='(F0.2)') + $
                 ' for ' + STRING(N_E(fitrange),F='(I0)') + $
                 ' red points, ' + $
                 STRING(fitdata.dof,F='(I0)') + $
                 ' d.o.f.', CHARSIZE = 0.8
         XYOUTS, 190, 0.0, 'Cont Par = (' + $
                 STRING([fitdata.camp,fitdata.ctemp,$
                         fitdata.cexp,fitdata.cffamp], $
                        F='(3(F0.3,", "),F0.3)') + $
                 ')', CHARSIZE = 0.8
         XYOUTS, 205, -0.1, '+/- (' + $
                 STRING([fitdata.caerr,fitdata.cterr,$
                         fitdata.ceerr,fitdata.cferr], $
                        F='(3(F0.3,", "),F0.3)') + $
                 ')', CHARSIZE = 0.8
                 


         PRINT
         PRINT, fitdata.camp,fitdata.ctemp,fitdata.cexp,fitdata.cffamp
         PRINT, fitdata.caerr,fitdata.cterr,fitdata.ceerr,fitdata.cferr
;   PRINT, fitdata.redchi, fitdata.dof ;, co_cont.splitting
;   PRINT, fitdata.cknee
;   PRINT, fitdata.camp, fitdata.caerr
;   PRINT, fitdata.cexp, fitdata.ceerr
;   PRINT, fitdata.rpar, fitdata.rerr
         
; Naive Intensity Calculation (no redshift error)
         sol = 299792.458d3     ; m/s
         kb = 1.3806503e-23 
         line_inten_kkms = fitdata.width * fitdata.scale * fitdata.amp*1d-26 * $
                           !DPI*(10.4/2)^2 / (2*kb)
         line_err_kkms = fitdata.width * fitdata.scale * fitdata.aerr*1d-26 * $
                         !DPI*(10.4/2)^2 / (2*kb)
         line_snr = line_inten_kkms/line_err_kkms
         
         nlines = N_E(fitdata.amp)
         PRINT
         PRINT, obsset, datafilesuffix, cofix
         FOR i = 0, nlines - 1 DO BEGIN
            PRINT, STRING(fitdata.linename[i],F='(A15)'), $
                   fitdata.center[i], $
                   fitdata.scale[i], $
                   fitdata.amp[i], fitdata.aerr[i], $
                   line_inten_kkms[i], line_err_kkms[i], line_snr[i], $
                   fitdata.width[i], fitdata.werr[i], $
                   fitdata.redshift[i], fitdata.zerr[i]
         ENDFOR
         
      ENDFOR
   
   ENDFOR


ENDFOR

!P.MULTI = 0
IF makeps THEN BEGIN
   DEVICE, /CLOSE_FILE
   SET_PLOT, 'x', /COPY
ENDIF ELSE BEGIN
   ; Do nothing
ENDELSE

!P.CHARTHICK = 0
!X.THICK = 0
!Y.THICK = 0
!P.CHARSIZE = 0
!P.PSYM = 0
!P.THICK = 0

END

