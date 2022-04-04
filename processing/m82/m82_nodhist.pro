FOR cofix = 0, 1 DO BEGIN
  FOR allchan = 0, 1 DO BEGIN
     FOR datatype = 0, 3 DO BEGIN
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
        IF cofix EQ 0 THEN costr = '' ELSE costr = '_cofix'
        IF allchan EQ 0 THEN acstr = '' ELSE acstr = '_allchan'
        psfilename = 'm82_nodhist' + strmid(datafilesuffix,0,6) + $
                     costr + acstr + '.ps'
        PRINT, psfilename
        datacolor = 2
        fitcolor = 6
        contcolor = 3
        jackcolor = 16
        
        !P.PSYM = 10
        !P.THICK = 3
        !P.CHARTHICK = 3
        !X.THICK = 2
        !Y.THICK = 2
        !P.CHARSIZE = 1.2
        SET_PLOT, 'ps', /COPY
        psfile = !ZSPEC_PIPELINE_ROOT + '/working_bret/plots/in/' + psfilename
        DEVICE, ENCAPSULATED=0, /INCHES, $
;        /PORTRAIT, XOFF = 0.25, YOFF = 0.25, XSIZE = 8.0, YSIZE = 10.5, $
                /LANDSCAPE, XOFF=0.25, YOFF=10.75, XSIZE=10.5, YSIZE=8.0, $
                FILENAME = psfile, /COLOR
        FOR obsset = 1, 6 DO BEGIN
           CASE obsset OF       ; Select Observation
              1:BEGIN           ; Observations offset (-9,-3.5)
                 marsnight = 16 & marsobs = 1 
                 night = 16 & sourceobs = [4,6,7]
                 raoff = -9 & decoff = -3.5
                 datafilename = 'm82-09-35.sav'
              END
              2:BEGIN           ; These observations are of M82 center
                 marsnight = 14 & marsobs = 6 
                 night = 14 & sourceobs = [8,9,10]
                 raoff = 0 & decoff = 0
                 datafilename = 'm82+00+00.sav'
              END
              3:BEGIN           ; Observations offset (+8,+3) & (+9,+3.5)
                 marsnight = [14,16] & marsobs = [6,1] 
                 night = [14,16] & sourceobs = [13,14,   8,9,10,11] 
                 raoff = [+8,+9] & decoff = [+3,+3.5]
                 datafilename = 'm82+0809+3035.sav'
              END
              4:BEGIN           ; Observations offset (+18,+7)
                 marsnight = 14 & marsobs = 6 
                 night = 14 & sourceobs = [11,12]
                 raoff = +18 & decoff = +7
                 datafilename = 'm82+18+70.sav'
              END
              5:BEGIN           ; Observations offset (+8,+3)
                 marsnight = 14 & marsobs = 6 
                 night = 14 & sourceobs = [13,14]
                 raoff = +8 & decoff = +3
                 datafilename = 'm82+08+30.sav'
              END
              6:BEGIN           ; Observations offset (+9,+3.5)
                 marsnight = 16 & marsobs = 1 
                 night = 16 & sourceobs = [8,9,10,11] 
                 raoff = +9 & decoff = +3.5
                 datafilename = 'm82+09+35.sav'
              END
           ENDCASE
           newdatafilename = change_suffix(datafilename,datafilesuffix)
           IF cofix EQ 1 THEN $
              newdatafilename = change_suffix(newdatafilename,'_cofix.sav')
           RESTORE, !ZSPEC_PIPELINE_ROOT + '/working_bret/m82/joined_data/' + $
                    newdatafilename

           in1nodspec = cal.in1.nodspec
           FOR bolo = 0, 159 DO BEGIN
              in1nodspec[bolo,*] -= avespec[bolo]
              in1nodspec[bolo,*] /= aveerr[bolo]*SQRT(nnodstot)
           ENDFOR
           allchanhist = HISTOGRAM(in1nodspec,NBINS = 10*10+1, $
                                   LOCATIONS = allchanbins, $
                                   MIN = -5, MAX = 5)
           !P.MULTI = 0   
           IF N_E(night) EQ 1 THEN BEGIN
              titlehdr = 'Night = 200604' + STRING(night, F='(I0)') + $
                         ', Offset ' + $
                         STRING(raoff,decoff,$
                                F='("(",F+0.1,",",F+0.1,")")') + $
                         ', ' + STRING(N_E(sourceobs),F='(I0)') + $
                         ' observations'
           ENDIF ELSE BEGIN
              titlehdr = 'Nights = 200604' + STRING(night[0], F='(I0)') + $
                         ' & ' + STRING(night[1], F='(I0)') + $
                         ', Offsets ' + $
                         STRING(raoff[0],decoff[0],$
                                F='("(",F+0.1,",",F+0.1,")")') + $
                         ' & ' + STRING(raoff[1],decoff[1],$
                                        F='("(",F+0.1,",",F+0.1,")")') + $
                         ', ' + STRING(N_E(sourceobs),F='(I0)') + $
                         ' observations'
           ENDELSE
           PLOT, allchanbins, allchanhist, PSYM = 10, $
                 XTITLE = 'All Channels, mean subtracted, divided by sigma', $
                 YTITLE = '# of elements', $
                 TITLE = titlehdr
           yfit = GAUSSFIT(allchanbins,allchanhist,coeff,NTERMS = 3)
           PRINT,coeff
           OPLOT, allchanbins, yfit, PSYM = 0, COLOR = datacolor
           OPLOT, allchanbins, coeff[0]*EXP(-0.5*(allchanbins)^2), $
                  PSYM = 0, COLOR = fitcolor
           XYOUTS, !X.CRANGE[0] + 0.2*(!X.CRANGE[1] - !X.CRANGE[0]), $
                   3*coeff[0]/4.0, $
                   'Model in cyan - zero mean, unit sigma!C' + $
                   'Gaussian Fit Results in red:!C' + $
                   'Center = ' + STRING(coeff[1],F='(F0.3)') + '!C' + $
                   'Width = ' + STRING(coeff[2],F='(F0.3)')
           
           IF allchan THEN BEGIN
;;               jackspec = cal.in1.avespec
;;               jackerr = jackspec
;;               njacks = nnodstot*2
;;               FOR bolo = 0, 159 DO BEGIN
;;                  temp = vector_jackknife(cal.in1.nodspec[bolo,*],njacks)
;;                  jackspec[bolo] = temp[0]
;;                  jackerr[bolo] = temp[1]
;;               ENDFOR
              !P.MULTI = [0,5,4]   
              FOR bolo = 0, 159 DO BEGIN
                 hist = HISTOGRAM(cal.in1.nodspec[bolo,*],NBINS = 7, $
                                  LOCATIONS = bins)
                 PLOT, bins, hist, PSYM = 10, $
                       TITLE = 'FreqID # ' + STRING(bolo,F='(I0)') + $
                       ', ' + STRING(freqid2freq(bolo),F = '(F0.2)') + ' GHz', $
                       XTITLE = 'Demodulation Value', YTITLE = '# of Elements'
                 OPLOT, bins, $
                        max(hist)*$
                        EXP(-0.5*((bins-avespec[bolo])/$
                                  (SQRT(nnodstot)*aveerr[bolo]))^2), $
                        PSYM = 0, COLOR = fitcolor
                 
                 OPLOT, avespec[bolo]*[1,1], !Y.CRANGE, COLOR = datacolor
                 OPLOT, (avespec[bolo]-SQRT(nnodstot)*aveerr[bolo])*[1,1], $
                        !Y.CRANGE, $
                        COLOR = datacolor, LINESTYLE = 2
                 OPLOT, (avespec[bolo]+SQRT(nnodstot)*aveerr[bolo])*[1,1], $
                        !Y.CRANGE, $
                        COLOR = datacolor, LINESTYLE = 2
;;                  OPLOT, (avespec[bolo]-$
;;                          SQRT(nnodstot)*(jackerr[bolo]*SQRT(njacks)))*[1,1], !Y.CRANGE, $
;;                         COLOR = jackcolor, LINESTYLE = 2
;;                  OPLOT, (avespec[bolo]+$
;;                          SQRT(nnodstot)*(jackerr[bolo]*SQRT(njacks)))*[1,1], !Y.CRANGE, $
;;                         COLOR = jackcolor, LINESTYLE = 2
                 
                 aveval = MEAN(cal.in1.nodspec[bolo,*])
                 errval = STDDEV(cal.in1.nodspec[bolo,*])
                 OPLOT, aveval*[1,1], !Y.CRANGE, COLOR = contcolor
                 OPLOT, (aveval-errval)*[1,1], !Y.CRANGE, $
                        COLOR = contcolor, LINESTYLE = 2
                 OPLOT, (aveval+errval)*[1,1], !Y.CRANGE, $
                        COLOR = contcolor, LINESTYLE = 2
              ENDFOR
           ENDIF
           
        ENDFOR
        
        DEVICE, /CLOSE_FILE
        SET_PLOT, 'x', /COPY
        !P.NOERASE = 0
        !P.THICK = 0
        !P.CHARTHICK = 0
        !X.THICK = 0
        !Y.THICK = 0
        !P.PSYM = 0
        !P.MULTI = 0   
     ENDFOR
  ENDFOR
ENDFOR


END
