TRUE = 1
FALSE = 0

dojack = TRUE
plottitle = TRUE
bigtext = FALSE
textout = TRUE
plotcont = TRUE
twopanel = FALSE

lines_on = [1,1,1, 1,1,0, 0,0, 1,1,1, 0,0,0, 1,1,1, 0, 0,0, 1, 1]
;lines_on = [1,1,1, 1,1,0, 1,1, 0,1,1, 0,0,0, 1,1,1, 1]
xr = [184,309]
;xr = [205,300]
plotsuffix = 'specs_26JUL07_v2.ps'

datacolor = 2
fitcolor = 6
contcolor = 3
jackcolor = 16

IF bigtext THEN BEGIN
   !P.PSYM = 10
   !P.THICK = 5
   !P.CHARTHICK = 5
   !X.THICK = 3
   !Y.THICK = 3
   !P.CHARSIZE = 2.0
ENDIF ELSE BEGIN
   !P.PSYM = 10
   !P.THICK = 3
   !P.CHARTHICK = 3
   !X.THICK = 2
   !Y.THICK = 2
   !P.CHARSIZE = 1.2
ENDELSE

SET_PLOT, 'ps', /COPY
psfilename = 'm82_' + plotsuffix
PRINT, psfilename
psfile = !ZSPEC_PIPELINE_ROOT + $
         '/working_bret/plots/in/' + psfilename
IF twopanel THEN BEGIN
   DEVICE, ENCAPSULATED=0, /INCHES, $
;              /PORTRAIT, XOFF=0.25, YOFF=0.25, XSIZE=8.0, YSIZE=10.5, $
           /LANDSCAPE, XOFF = 0.25, YOFF = 10.75, $
           XSIZE = 10.5, YSIZE = 8.0, $
           FILENAME = psfile, /COLOR
ENDIF ELSE BEGIN
   DEVICE, ENCAPSULATED=0, /INCHES, $
           /PORTRAIT, XOFF=0.25, YOFF=0.25, XSIZE=8.0, YSIZE=10.5, $
;              /LANDSCAPE, XOFF = 0.25, YOFF = 10.75, $
;              XSIZE = 10.5, YSIZE = 8.0, $
           FILENAME = psfile, /COLOR
ENDELSE

ptname = ['','P1','P2','P3','P4','P3A','P3B']
FOR allchan = 0, 1 DO BEGIN
   FOR obsset = 1, 4 DO BEGIN
      CASE obsset OF            ; Select Observation
         1:BEGIN                ; Observations offset (-9,-3.5)
            marsnight = 16 & marsobs = 1 
            night = 16 & sourceobs = [4,6,7]
            raoff = -9 & decoff = -3.5
            datafilename = 'm82-09-35.sav'
         END
         2:BEGIN                ; These observations are of M82 center
            marsnight = 14 & marsobs = 6 
            night = 14 & sourceobs = [8,9,10]
            raoff = 0 & decoff = 0
            datafilename = 'm82+00+00.sav'
         END
         3:BEGIN                ; Observations offset (+8,+3) & (+9,+3.5)
            marsnight = [14,16] & marsobs = [6,1] 
            night = [14,16] & sourceobs = [13,14,   8,9,10,11] 
            raoff = [+8,+9] & decoff = [+3,+3.5]
            datafilename = 'm82+0809+3035.sav'
         END
         4:BEGIN                ; Observations offset (+18,+7)
            marsnight = 14 & marsobs = 6 
            night = 14 & sourceobs = [11,12]
            raoff = +18 & decoff = +7
            datafilename = 'm82+18+70.sav'
         END
         5:BEGIN                ; Observations offset (+8,+3)
            marsnight = 14 & marsobs = 6 
            night = 14 & sourceobs = [13,14]
            raoff = +8 & decoff = +3
            datafilename = 'm82+08+30.sav'
         END
         6:BEGIN                ; Observations offset (+9,+3.5)
            marsnight = 16 & marsobs = 1 
            night = 16 & sourceobs = [8,9,10,11] 
            raoff = +9 & decoff = +3.5
            datafilename = 'm82+09+35.sav'
         END
      ENDCASE
      
      
      FOR datatype = 0, 0 DO BEGIN
         dataorder = [1,3,0,2]
         CASE dataorder[datatype] OF
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

         FOR cofix = 1, 1, -1 DO BEGIN
            IF cofix EQ 0 THEN costr = ' ' ELSE costr = ' *CO Fixed* '
            ;IF allchan EQ 0 THEN acstr = '' ELSE acstr = '_allchan'
            newdatafilename = change_suffix(datafilename,datafilesuffix)
            IF cofix EQ 1 THEN $
               newdatafilename = change_suffix(newdatafilename,'_cofix.sav')
            RESTORE, !ZSPEC_PIPELINE_ROOT + '/working_bret/m82/joined_data/' + $
                     newdatafilename
            fitdatafile = !ZSPEC_PIPELINE_ROOT + $
                          '/working_bret/m82/fit_data/' + $
                          change_suffix(newdatafilename,$
                                        '_planck_alllines.sav')
            RESTORE, fitdatafile
            
            freqshift = fitdata.freqshift ; km/s
            sol = 299792.458
            freqs *= 1.0/(1.0 + freqshift/sol)
            binfreqs *= 1.0/(1.0 + freqshift/sol)
            
            ; Mask out crappy channel at 251 GHz
            ; avespec[104] /= 0

            IF binfreqid GT 0 THEN BEGIN
               newfreqs = [binfreqs[0:(binfreqid/2)-1],freqs[binfreqid:*]]
               newavespec = [binavespec[0:(binfreqid/2)-1],avespec[binfreqid:*]]
               newaveerr = [binaveerr[0:(binfreqid/2)-1],aveerr[binfreqid:*]]
               
               freqs = newfreqs
               avespec = newavespec
               aveerr = newaveerr
            ENDIF
            
            IF plottitle THEN BEGIN
               IF N_E(night) EQ 1 THEN BEGIN
                  titlehdr = 'Night = 200604' + STRING(night, F='(I0)') + $
                             ', Offset ' + $
                             STRING(raoff,decoff,$
                                    F='("(",F+0.1,",",F+0.1,")")') + $
                             '!C' + STRING(N_E(sourceobs),F='(I0)') + $
                             ' observations' + costr + $
                             'Error Method = ' + strmid(datafilesuffix,1,5)
               ENDIF ELSE BEGIN
                  titlehdr = 'Nights = 200604' + STRING(night[0], F='(I0)') + $
                             ' & ' + STRING(night[1], F='(I0)') + $
                             ', Offsets ' + $
                             STRING(raoff[0],decoff[0],$
                                    F='("(",F+0.1,",",F+0.1,")")') + $
                             ' & ' + STRING(raoff[1],decoff[1],$
                                            F='("(",F+0.1,",",F+0.1,")")') + $
                             '!C' + STRING(N_E(sourceobs),F='(I0)') + $
                             ' observations' + costr + $
                             'Error Method = ' + strmid(datafilesuffix,1,5)
               ENDELSE
            ENDIF ELSE BEGIN
               titlehdr = ''
            ENDELSE

            IF twopanel THEN $
               multiplot,[1,2], /init, /verbose $
            ELSE multiplot,[1,3], /init, /verbose
            !P.NOERASE = 0
            multiplot, /verbose
            PLOTERROR, freqs, avespec, aveerr, HATLENGTH = !D.X_VSIZE / 200, $
                       XRANGE = xr, /XSTY, YRANGE = [-0.5,11], /YSTY, $
                       TITLE = titlehdr, $
                       YTITLE = 'Flux Density!CF!D!4m!3!N [Jy]'
            
            printlines, 10.0 - 1.2*[0,1,2,3], fitdata.redshift[0], $
                        LINES_ON = lines_on
            IF allchan EQ 1 THEN BEGIN
               plotspec = avespec
               ploterr = plotspec
               FOR i = 0, N_E(sourceobs)-1 DO BEGIN
                  FOR bolo = 0, N_E(freqs) - 1 DO BEGIN
                     IF bolo LT binfreqid/2 THEN BEGIN
                        currnods = [cal.in1.nodspec[2*bolo,(10*i):(10*i)+9],$
                                    cal.in1.nodspec[2*bolo+1,(10*i):(10*i)+9]]
                        currerrs = [cal.in1.noderr[2*bolo,(10*i):(10*i)+9],$
                                    cal.in1.noderr[2*bolo+1,(10*i):(10*i)+9]]
                     ENDIF ELSE BEGIN
                        currnods = $
                           cal.in1.nodspec[bolo+(binfreqid/2),(10*i):(10*i)+9]
                        currerrs = $
                           cal.in1.noderr[bolo+(binfreqid/2),(10*i):(10*i)+9]
                     ENDELSE 
                     IF unweighted EQ 0 THEN BEGIN
                        plotspec[bolo] = $
                           weighted_mean(currnods,currerrs,ERRBIN = errbin)
                        ploterr[bolo] = $
                           weighted_sdom(currerrs,ERRBIN = errbin)
                     ENDIF ELSE BEGIN
                        plotspec[bolo] = $
                           rm_outlier(currnods,sigma,$
                                      currmask,currsigma,/SDEV,QUIET = 1)
                        ploterr[bolo] = currsigma
                     ENDELSE
                  ENDFOR
                  OPLOTERROR, freqs, plotspec, ploterr, $
                              COLOR = i + 7, PSYM = 4, $
                              ERRCOLOR = i + 7, /NOHAT, SYMSIZE = 0.3
               ENDFOR
            ENDIF
            OPLOTERROR, freqs, avespec, aveerr, $
                        HATLENGTH = !D.X_VSIZE / 200
            FOR range = 0, 3 DO BEGIN
               CASE range OF
                  0: curr = fitrange0
                  1: curr = fitrange1
                  2: curr = fitrange2
                  3: curr = fitrange3
               ENDCASE
               OPLOTERROR, freqs[curr], avespec[curr], $
                           aveerr[curr], $
                           COLOR = datacolor, ERRCOLOR = datacolor, $
                           HATLENGTH = !D.X_VSIZE / 200
            ENDFOR
            OPLOT, freqs, fitdata.lcspec, COLOR = fitcolor
            cspec = hughes94_fitfun(freqs,$
                                    [fitdata.camp,fitdata.ctemp,$
                                     fitdata.cexp,fitdata.cffamp])
            IF plotcont THEN BEGIN
               OPLOT, freqs, fitdata.cspec, COLOR = contcolor
               OPLOT, freqs, cspec, COLOR = contcolor, PSYM = 0, LINESTYLE = 2
               OPLOT, freqs, fitdata.cffamp*0.59*(freqs/92.)^(-0.1), $
                      COLOR = contcolor, PSYM = 0, LINE = 3
            ENDIF

            IF textout THEN BEGIN
               XYOUTS, 235, 6.8, STRING(inttime/60.,F='(F0.1)') + $
                       ' min observation time', CHARSIZE = 0.8
               XYOUTS, 235, 5.8, 'Best Fit V!Dlsr!N = ' + $
                       STRING(fitdata.redshift[0],F='(F0.1)')  + '' + $
                       STRING(177B) + '' + $
                       STRING(fitdata.zerr[0],F='(F0.1)') + ' km/sec', $
                       CHARSIZE = 0.8
               XYOUTS, 235, 4.8,'!4v!3!E2!N/d.o.f. = ' + $
                       STRING(fitdata.redchi,F='(F0.2)') + $
                       ' for ' + STRING(N_E(fitrange),F='(I0)') + $
                       ' red points, ' + $
                       STRING(fitdata.dof,F='(I0)') + $
                       ' d.o.f.', CHARSIZE = 0.8
               XYOUTS, 235, 3.8, 'Cont Par = (' + $
                       STRING([fitdata.camp,fitdata.ctemp,$
                               fitdata.cexp,fitdata.cffamp], $
                              F='(3(F0.3,", "),F0.3)') + $
                       ')', CHARSIZE = 0.8
               XYOUTS, 245, 3.3, '+/- (' + $
                       STRING([fitdata.caerr,fitdata.cterr,$
                               fitdata.ceerr,fitdata.cferr], $
                              F='(3(F0.3,", "),F0.3)') + $
                       ')', CHARSIZE = 0.8

;;                XYOUTS, 235, 3.8, 'Continuum C!D!4m!3!N = ' + $
;;                        STRING(fitdata.camp,F='(F0.3)')  + '' + $
;;                        STRING(177B) + '' + $
;;                        STRING(fitdata.caerr,F='(F0.3)') + $
;;                        '(!4m!3/240 GHz)!E' + $
;;                        STRING(fitdata.cexp,F='(F0.2)') + '' + $
;;                        STRING(177B) + '' + $
;;                      STRING(fitdata.ceerr,F='(F0.2)')+ '!NJy', CHARSIZE = 0.8
               XYOUTS, 235, 2.8, 'Linewidth (for all lines) = ' + $
                       STRING(fitdata.width[0],F='(F0.1)')  + '' + $
                       STRING(177B) + '' + $
                       STRING(fitdata.werr[0],F='(F0.1)') + ' km/sec', $
                       CHARSIZE = 0.8
            ENDIF
   
            !P.NOERASE = 1
            multiplot, /verbose
            IF twopanel THEN $
               xtitle = 'Frequency !4m!3 [GHz]' $
            ELSE xtitle = ''

            PLOTERROR, freqs, avespec, aveerr, HATLENGTH = !D.X_VSIZE / 200, $
                       XRANGE = xr, /XSTY, YRANGE = [0.0,1.5], /YSTY, $
                       YTITLE = 'Flux Density!CF!D!4m!3!N [Jy]' ,$
                       XTITLE = xtitle
            
            printlines, 1.40 - 0.12*[0,1,2,3], fitdata.redshift[0], $
                        LINES_ON = lines_on
            IF allchan EQ 1 THEN BEGIN
               plotspec = avespec
               ploterr = plotspec
               FOR i = 0, N_E(sourceobs)-1 DO BEGIN
                  FOR bolo = 0, N_E(freqs) - 1 DO BEGIN
                     IF bolo LT binfreqid/2 THEN BEGIN
                        currnods = [cal.in1.nodspec[2*bolo,(10*i):(10*i)+9],$
                                    cal.in1.nodspec[2*bolo+1,(10*i):(10*i)+9]]
                        currerrs = [cal.in1.noderr[2*bolo,(10*i):(10*i)+9],$
                                    cal.in1.noderr[2*bolo+1,(10*i):(10*i)+9]]
                     ENDIF ELSE BEGIN
                        currnods = $
                           cal.in1.nodspec[bolo+(binfreqid/2),(10*i):(10*i)+9]
                        currerrs = $
                           cal.in1.noderr[bolo+(binfreqid/2),(10*i):(10*i)+9]
                     ENDELSE 
                     IF unweighted EQ 0 THEN BEGIN
                        plotspec[bolo] = $
                           weighted_mean(currnods,currerrs,ERRBIN = errbin)
                        ploterr[bolo] = $
                           weighted_sdom(currerrs,ERRBIN = errbin)
                     ENDIF ELSE BEGIN
                        plotspec[bolo] = $
                           rm_outlier(currnods,sigma,$
                                      currmask,currsigma,/SDEV,QUIET = 1)
                        ploterr[bolo] = currsigma
                     ENDELSE
                  ENDFOR
                  OPLOTERROR, freqs, plotspec, ploterr, $
                              COLOR = i + 7, PSYM = 4, $
                              ERRCOLOR = i + 7, /NOHAT, SYMSIZE = 0.3
               ENDFOR
            ENDIF
            OPLOTERROR, freqs, avespec, aveerr, $
                        HATLENGTH = !D.X_VSIZE / 200
            FOR range = 0, 3 DO BEGIN
               CASE range OF
                  0: curr = fitrange0
                  1: curr = fitrange1
                  2: curr = fitrange2
                  3: curr = fitrange3
               ENDCASE
               OPLOTERROR, freqs[curr], avespec[curr], $
                           aveerr[curr], $
                           COLOR = datacolor, ERRCOLOR = datacolor, $
                           HATLENGTH = !D.X_VSIZE / 200
            ENDFOR
            
            OPLOT, freqs, fitdata.lcspec, COLOR = fitcolor

            IF plotcont THEN BEGIN
               OPLOT, freqs, fitdata.cspec, COLOR = contcolor
               OPLOT, freqs, cspec, COLOR = contcolor, PSYM = 0, LINESTYLE = 2
               OPLOT, freqs, fitdata.cffamp*0.59*(freqs/92.)^(-0.1), $
                      COLOR = contcolor, PSYM = 0, LINE = 3
            ENDIF
            
            IF twopanel THEN BEGIN
               ; DO nothing
            ENDIF ELSE BEGIN
               multiplot, /verbose
               
               PLOTERROR, freqs, avespec - fitdata.lcspec, $
                          aveerr, HATLENGTH = !D.X_VSIZE / 200, $
                          XRANGE = xr, /XSTY, YRANGE = [-0.5,+0.5], /YSTY, $
                          YTITLE = 'Flux Density - Fit [Jy]',$
                          XTITLE = 'Frequency !4m!3 [GHz]'
               
               IF allchan EQ 1 THEN BEGIN
                  plotspec = avespec
                  ploterr = plotspec
                  FOR i = 0, N_E(sourceobs)-1 DO BEGIN
                     FOR bolo = 0, N_E(freqs) - 1 DO BEGIN
                        IF bolo LT binfreqid/2 THEN BEGIN
                           currnods = [cal.in1.nodspec[2*bolo,(10*i):(10*i)+9],$
                                       cal.in1.nodspec[2*bolo+1,(10*i):$
                                                       (10*i)+9]]
                           currerrs = [cal.in1.noderr[2*bolo,(10*i):(10*i)+9],$
                                       cal.in1.noderr[2*bolo+1,(10*i):(10*i)+9]]
                        ENDIF ELSE BEGIN
                           currnods = $
                              cal.in1.nodspec[bolo+(binfreqid/2),(10*i):$
                                              (10*i)+9]
                           currerrs = $
                              cal.in1.noderr[bolo+(binfreqid/2),(10*i):(10*i)+9]
                        ENDELSE 
                        IF unweighted EQ 0 THEN BEGIN
                           plotspec[bolo] = $
                              weighted_mean(currnods,currerrs,ERRBIN = errbin)
                           ploterr[bolo] = $
                              weighted_sdom(currerrs,ERRBIN = errbin)
                        ENDIF ELSE BEGIN
                           plotspec[bolo] = $
                              rm_outlier(currnods,sigma,$
                                         currmask,currsigma,/SDEV,QUIET = 1)
                           ploterr[bolo] = currsigma
                        ENDELSE
                     ENDFOR
                     OPLOTERROR, freqs, plotspec - fitdata.lcspec, ploterr, $
                                 COLOR = i + 7, PSYM = 4, $
                                 ERRCOLOR = i + 7, /NOHAT, SYMSIZE = 0.3
                  ENDFOR
               ENDIF
               
               printlines, 0.41 - 0.1*[0,1,2,3], fitdata.redshift[0], $
                           LINES_ON = lines_on
               FOR range = 0, 3 DO BEGIN
                  CASE range OF
                     0: curr = fitrange0
                     1: curr = fitrange1
                     2: curr = fitrange2
                     3: curr = fitrange3
                  ENDCASE
                  OPLOTERROR, freqs[curr], $
                              avespec[curr] - $
                              fitdata.lcspec[curr], $
                              aveerr[curr], $
                              COLOR = datacolor, ERRCOLOR = datacolor, $
                              HATLENGTH = !D.X_VSIZE / 200
               ENDFOR
               OPLOT, !X.CRANGE,[0,0],PSYM = 0
               
               IF dojack THEN BEGIN
                  jackspec = avespec
                  jackerr = jackspec
                  njacks = jackspec
                  FOR bolo = 0, N_E(freqs) - 1 DO BEGIN
                     IF bolo LT binfreqid/2 THEN BEGIN
                        njacks[bolo] = 2*nnodstot*2
                        temp = vector_jackknife([cal.in1.nodspec[2*bolo,*],$
                                                 cal.in1.nodspec[2*bolo+1,*]],$
                                                njacks[bolo])
                     ENDIF ELSE BEGIN
                        njacks[bolo] = nnodstot*2
                        temp = $
                           vector_jackknife($
                           cal.in1.nodspec[bolo+(binfreqid/2),*],$
                           njacks[bolo])
                     ENDELSE 
                     jackspec[bolo] = temp[0]
                     jackerr[bolo] = temp[1]
                  ENDFOR
                  jackshift = -0.3
                  OPLOTERROR, freqs, jackspec+jackshift, jackerr, $
                              /nohat, PSYM = 0, $
                              COLOR = jackcolor, ERRCOLOR = jackcolor
                  badpts = WHERE(ABS(jackspec) GT 1.0*jackerr,nbadpts)
                  IF nbadpts GT 0 THEN $
                     OPLOTERROR, freqs[badpts],jackspec[badpts]+$
                                 jackshift,jackerr[badpts],$
                                 COLOR = 2, ERRCOLOR = 2, /NOHAT, PSYM = 3
                  OPLOT, !X.CRANGE,jackshift*[1,1],PSYM = 0
                  
                  XYOUTS, 233, -0.4, $
                          '!4v!3!E2!N/# of points for Jackknife = ' + $
                          STRING(TOTAL((jackspec/jackerr)^2)/N_E(jackspec),$
                                 F='(F0.2)')
                  
                  OPLOTERROR, freqs, avespec - fitdata.lcspec, $
                              jackerr*SQRT(njacks), THICK = 1.5, $
                              ERRTHICK = 1.5, $
                              COLOR = jackcolor, ERRCOLOR = jackcolor, $
                              PSYM = 3, /NOHAT
               ENDIF
               IF textout THEN BEGIN
                  XYOUTS, 246, -0.19, ALIGN = 0.5, CHARSIZE = 0.75, $
                          'MEAN ABS Fit Residuals vs. MEDIAN Error!C' + $ 
                          'From 231.5 to 260.0 GHz'
                  span = WHERE(freqs GT 231.5 AND freqs LT 260.0,nspan)
                  resid = avespec[span] - fitdata.lcspec[span]
                  errors = aveerr[span]
                  XYOUTS, 237, -0.15, ALIGN = 0.5, $
                          STRING(MEAN(ABS(resid)),F='(F0.3)')
                  XYOUTS, 255, -0.15, ALIGN = 0.5, $
                          STRING(MEDIAN(errors),F='(F0.3)')
               ENDIF
            ENDELSE
            multiplot, /reset, /verbose
         ENDFOR
      ENDFOR
   ENDFOR
ENDFOR

DEVICE, /CLOSE_FILE
SET_PLOT, 'x', /COPY
!P.NOERASE = 0
!P.THICK = 0
!P.CHARTHICK = 0
!X.THICK = 0
!Y.THICK = 0
!P.PSYM = 0
!P.CHARSIZE = 0

END
