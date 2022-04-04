; Make some plots of error estimators
FOR cofix = 0, 1 DO BEGIN
   IF cofix EQ 0 THEN costr = '' ELSE costr = '_cofix'
   ptname = ['','P1','P2','P3','P4','P3A','P3B']
   FOR obsset = 1,6 DO BEGIN
      
      psfilename = 'm82_' + ptname[obsset] + '_errest' + costr + '.ps'
      PRINT,psfilename
      !P.MULTI = [0,2,5]
      !P.THICK = 3
      !P.CHARTHICK = 3
      !X.THICK = 2
      !Y.THICK = 2
;!P.CHARSIZE = 1.2
      SET_PLOT, 'ps', /COPY
      psfile = !ZSPEC_PIPELINE_ROOT + '/working_bret/plots/in/' + psfilename
      DEVICE, ENCAPSULATED=0, /INCHES, $
              /PORTRAIT, XOFF = 0.25, YOFF = 0.25, XSIZE = 8.0, YSIZE = 10.5, $
;        /LANDSCAPE, XOFF = 0.25, YOFF = 10.75, XSIZE = 10.5, YSIZE = 8.0, $
              FILENAME = psfile, /COLOR
      CASE obsset OF            ; Select Observation
         1:BEGIN                ; Observations offset (-9,-3.5)
         marsnight = 16 & marsobs = 1 & night = 16 & sourceobs = [4,6,7]
         raoff = -9 & decoff = -3.5
         datafilename = 'm82-09-35.sav'
      END
      2:BEGIN                   ; These observations are of M82 center
         marsnight = 14 & marsobs = 6 & night = 14 & sourceobs = [8,9,10]
         raoff = 0 & decoff = 0
         datafilename = 'm82+00+00.sav'
      END
      3:BEGIN                   ; Observations offset (+8,+3) & (+9,+3.5)
         marsnight = [14,16] & marsobs = [6,1] 
         night = [14,16] & sourceobs = [13,14,   8,9,10,11] 
         raoff = [+8,+9] & decoff = [+3,+3.5]
         datafilename = 'm82+0809+3035.sav'
      END
      4:BEGIN                   ; Observations offset (+18,+7)
         marsnight = 14 & marsobs = 6 & night = 14 & sourceobs = [11,12]
         raoff = +18 & decoff = +7
         datafilename = 'm82+18+70.sav'
      END
      5:BEGIN                   ; Observations offset (+8,+3)
         marsnight = 14 & marsobs = 6 & night = 14 & sourceobs = [13,14]
         raoff = +8 & decoff = +3
         datafilename = 'm82+08+30.sav'
      END
      6:BEGIN                   ; Observations offset (+9,+3.5)
         marsnight = 16 & marsobs = 1 & night = 16 & sourceobs = [8,9,10,11] 
         raoff = +9 & decoff = +3.5
         datafilename = 'm82+09+35.sav'
      END
   ENDCASE
      FOR errest = 0, 4 DO BEGIN
         CASE errest OF
            0: BEGIN
               newdatafilename = change_suffix(datafilename,'_psd10.sav')
               RESTORE, !ZSPEC_PIPELINE_ROOT + $
                        '/working_bret/m82/joined_data/' + newdatafilename
               psd10_noderr_nofix = cal.in1.noderr
                                ;psd05_aveerr = cal.in1.aveerr
            END
            1: BEGIN
               newdatafilename = change_suffix(datafilename,'_psd05.sav')
               IF cofix EQ 1 THEN $
                  newdatafilename = change_suffix(newdatafilename,'_cofix.sav')
               RESTORE, !ZSPEC_PIPELINE_ROOT + $
                        '/working_bret/m82/joined_data/' + newdatafilename
                                ;psd05_noderr = cal.in1.noderr
               psd05_aveerr = cal.in1.aveerr
            END
            2: BEGIN
               newdatafilename = change_suffix(datafilename,'_psd10.sav')
               IF cofix EQ 1 THEN $
                  newdatafilename = change_suffix(newdatafilename,'_cofix.sav')
               RESTORE, !ZSPEC_PIPELINE_ROOT + $
                        '/working_bret/m82/joined_data/' + newdatafilename
               psd10_noderr = cal.in1.noderr
               psd10_aveerr = cal.in1.aveerr
            END
            3: BEGIN
               newdatafilename = change_suffix(datafilename,'_nod10.sav')
               IF cofix EQ 1 THEN $
                  newdatafilename = change_suffix(newdatafilename,'_cofix.sav')
               RESTORE, !ZSPEC_PIPELINE_ROOT + $
                        '/working_bret/m82/joined_data/' + newdatafilename
               nod10_noderr = cal.in1.noderr
               nod10_aveerr = cal.in1.aveerr
            END
            4: BEGIN
               newdatafilename = change_suffix(datafilename,'_unw40.sav')
               IF cofix EQ 1 THEN $
                  newdatafilename = change_suffix(newdatafilename,'_cofix.sav')
               RESTORE, !ZSPEC_PIPELINE_ROOT + $
                        '/working_bret/m82/joined_data/' + newdatafilename
               unw40_aveerr = cal.in1.aveerr
            END
         ENDCASE
      ENDFOR
      
      FOR bolo = 0, 159 DO BEGIN
         currsdev = unw40_aveerr[bolo]
         miny = MIN([REFORM(psd10_noderr_nofix[bolo,*]),$
                     REFORM(psd10_noderr[bolo,*]),$
                     REFORM(nod10_noderr[bolo,*]),$
                     SQRT(nnodstot)*psd05_aveerr[bolo],$
                     SQRT(nnodstot)*psd10_aveerr[bolo],$
                     SQRT(nnodstot)*nod10_aveerr[bolo],$
                     SQRT(nnodstot)*currsdev])
         maxy = MAX([REFORM(psd10_noderr_nofix[bolo,*]),$
                     REFORM(psd10_noderr[bolo,*]),$
                     REFORM(nod10_noderr[bolo,*]),$
                     SQRT(nnodstot)*psd05_aveerr[bolo],$
                     SQRT(nnodstot)*psd10_aveerr[bolo],$
                     SQRT(nnodstot)*nod10_aveerr[bolo],$
                     SQRT(nnodstot)*currsdev])
         PLOT, psd10_noderr[bolo,*], PSYM = 10, $
               YRANGE = [miny,maxy], $
               TITLE = 'FreqID # ' + STRING(bolo,F='(I0)') + $
               ', ' + STRING(freqid2freq(bolo),F = '(F0.2)') + ' GHz', $
               XTITLE = 'Nod Number', YTITLE = 'Error Estimators [Jy]'
         OPLOT, psd10_noderr_nofix[bolo,*], PSYM = 2, SYMSIZE = 0.5
         OPLOT, nod10_noderr[bolo,*], PSYM = 10, COLOR = 3
         OPLOT, !X.CRANGE, [1,1]*SQRT(nnodstot)*psd10_aveerr[bolo], $
                LINE = 2
         OPLOT, !X.CRANGE, [1,1]*SQRT(nnodstot)*psd05_aveerr[bolo], $
                LINE = 2, COLOR = 2
         OPLOT, !X.CRANGE, [1,1]*SQRT(nnodstot)*nod10_aveerr[bolo], $
                LINE = 2, COLOR = 3
         OPLOT, !X.CRANGE, [1,1]*SQRT(nnodstot)*currsdev, $
                LINE = 2, COLOR = 4
         FOR i = 0, nnodstot/10 - 1 DO BEGIN
            OPLOT, i*10+[0,9], $
                   [1,1]*SQRT(MEAN(psd10_noderr[bolo,i*10:i*10+9]^2)), $
                   COLOR = 7, LINE = 0
            OPLOT, i*10+[0,9], [1,1] * $
                   SQRT(MEDIAN(psd10_noderr[bolo,i*10:i*10+9]^2,/EVEN)), $
                   COLOR = 6, LINE = 0
         ENDFOR
         
                                ; make legend
         XYOUTS, nnodstot/5., SQRT(nnodstot)*psd10_aveerr[bolo], $
                 'psd10 aveerr', ALIGN = 0.5, CHARSIZE = 0.5
         XYOUTS, 2*nnodstot/5., SQRT(nnodstot)*psd05_aveerr[bolo], $
                 'psd05 aveerr', COLOR = 2, ALIGN = 0.5, CHARSIZE = 0.5
         XYOUTS, 3*nnodstot/5., SQRT(nnodstot)*nod10_aveerr[bolo], $
                 'nod10 aveerr', COLOR = 3, ALIGN = 0.5, CHARSIZE = 0.5
         XYOUTS, 4*nnodstot/5., SQRT(nnodstot)*currsdev, $
                 'unweighted aveerr', COLOR = 4, ALIGN = 0.5, CHARSIZE = 0.5
         XYOUTS, 10, nod10_noderr[bolo,10], $
                 'Nod-to-Nod Fluctuations', COLOR = 3, CHARSIZE = 0.5
         maxpsd = MAX(psd10_noderr[bolo,*],mindex)
         XYOUTS, mindex, maxpsd, 'PSD err est.', CHARSIZE = 0.5
         minpsd = MIN(psd10_noderr_nofix[bolo,*],mindex)
         XYOUTS, mindex, minpsd, 'PSD err est. (no CO fix)', CHARSIZE = 0.5
         XYOUTS, 5, SQRT(MEAN(psd10_noderr[bolo,0:9]^2)), $
                 '10 pt Mean PSD', COLOR = 7, ALIGN = 0.5, CHARSIZE = 0.5
         XYOUTS, 15, SQRT(MEDIAN(psd10_noderr[bolo,10:19]^2,/EVEN)), $
                 '10 pt Median PSD', COLOR = 6, ALIGN = 0.5, CHARSIZE = 0.5
      ENDFOR
      DEVICE, /CLOSE_FILE
      SET_PLOT, 'x', /COPY
      !P.MULTI = 0
      !P.THICK = 0
      !P.CHARTHICK = 0
      !X.THICK = 0
      !Y.THICK = 0
      !P.CHARSIZE = 0
   ENDFOR
ENDFOR

END
