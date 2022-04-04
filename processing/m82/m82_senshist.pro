; Make sensitivity plots & histograms for various error estimators
FOR cofix = 0, 1 DO BEGIN
   IF cofix EQ 0 THEN costr = '' ELSE costr = '_cofix'
   psfilename = 'm82_senshist' + costr + '.ps'
   PRINT,psfilename
   !P.MULTI = [0,1,2]
   !P.PSYM = 10
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
   FOR obsset = 1,6 DO BEGIN
      CASE obsset OF            ; Select Observation
         1:BEGIN                ; Observations offset (-9,-3.5)
            marsnight = 16 & marsobs = 1 & night = 16 & sourceobs = [4,6,7]
            raoff = -9 & decoff = -3.5
            datafilename = 'm82-09-35.sav'
         END
         2:BEGIN                ; These observations are of M82 center
            marsnight = 14 & marsobs = 6 & night = 14 & sourceobs = [8,9,10]
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
            marsnight = 14 & marsobs = 6 & night = 14 & sourceobs = [11,12]
            raoff = +18 & decoff = +7
            datafilename = 'm82+18+70.sav'
         END
         5:BEGIN                ; Observations offset (+8,+3)
            marsnight = 14 & marsobs = 6 & night = 14 & sourceobs = [13,14]
            raoff = +8 & decoff = +3
            datafilename = 'm82+08+30.sav'
         END
         6:BEGIN                ; Observations offset (+9,+3.5)
            marsnight = 16 & marsobs = 1 & night = 16 & sourceobs = [8,9,10,11] 
            raoff = +9 & decoff = +3.5
            datafilename = 'm82+09+35.sav'
         END
      ENDCASE
      minbin = 0.0
      maxbin = 5.0
      nbins = 21

      bestmin = 210.
      bestmax = 280.
      whbestsens = WHERE(freqs GE bestmin AND $
                         freqs LE bestmax)
      medsens = FINDGEN(4)
      bestsens = FINDGEN(4)
      FOR errest = 0, 3 DO BEGIN
         CASE errest OF
            0: BEGIN
               newdatafilename = change_suffix(datafilename,'_psd10.sav')
               IF cofix EQ 1 THEN $
                  newdatafilename = change_suffix(newdatafilename,'_cofix.sav')
               RESTORE, !ZSPEC_PIPELINE_ROOT + $
                        '/working_bret/m82/joined_data/' + newdatafilename
               psd10_sens = cal.in1.aveerr*SQRT(inttime)
               psd10_hist = HISTOGRAM(psd10_sens,MAX=maxbin,$
                                      MIN=minbin,NBINS=nbins)
               psd10_sens_simp = psd10_sens
               psd10_noderr = cal.in1.noderr
               FOR bolo = 0, 159 DO BEGIN
                  temp = FINDGEN(nnodstot/10)
                  FOR ng = 0, nnodstot/10 - 1 DO $
                     temp[ng] = $
                     MEDIAN(psd10_noderr[bolo,ng*10:ng*10+9]^2,/EVEN)/10.
                  psd10_sens_simp[bolo] = SQRT(1.0/TOTAL(1.0/temp)*inttime)
               ENDFOR
               psd10_hist_simp = HISTOGRAM(psd10_sens_simp,MAX=maxbin,$
                                           MIN=minbin,NBINS=nbins)
            END
            1: BEGIN
               newdatafilename = change_suffix(datafilename,'_psd05.sav')
               IF cofix EQ 1 THEN $
                  newdatafilename = change_suffix(newdatafilename,'_cofix.sav')
               RESTORE, !ZSPEC_PIPELINE_ROOT + $
                        '/working_bret/m82/joined_data/' + newdatafilename
               psd05_sens = cal.in1.aveerr*SQRT(inttime)
               psd05_hist = HISTOGRAM(psd05_sens,MAX=maxbin,$
                                      MIN=minbin,NBINS=nbins)
            END
            2: BEGIN
               newdatafilename = change_suffix(datafilename,'_nod10.sav')
               IF cofix EQ 1 THEN $
                  newdatafilename = change_suffix(newdatafilename,'_cofix.sav')
               RESTORE, !ZSPEC_PIPELINE_ROOT + $
                        '/working_bret/m82/joined_data/' + newdatafilename
               nod10_sens = cal.in1.aveerr*SQRT(inttime)
               nod10_hist = HISTOGRAM(nod10_sens,MAX=maxbin,$
                                      MIN=minbin,NBINS=nbins)
            END
            3: BEGIN
               newdatafilename = change_suffix(datafilename,'_unw40.sav')
               IF cofix EQ 1 THEN $
                  newdatafilename = change_suffix(newdatafilename,'_cofix.sav')
               RESTORE, !ZSPEC_PIPELINE_ROOT + $
                        '/working_bret/m82/joined_data/' + newdatafilename
               unweighted_sens = cal.in1.aveerr*SQRT(inttime)
               unweighted_hist = HISTOGRAM(unweighted_sens,MAX=maxbin,$
                                           MIN=minbin,NBINS=nbins,$
                                           LOCATIONS=hbins)
            END
         ENDCASE
         medsens[errest] = MEDIAN(cal.in1.aveerr*SQRT(inttime),/EVEN)
         bestsens[errest] = $
            MEDIAN(cal.in1.aveerr[whbestsens]*SQRT(inttime),/EVEN)
      ENDFOR
                                ; First plot is just the sensitivity
      IF N_E(night) EQ 1 THEN BEGIN
         titlehdr = 'Night = 200604' + STRING(night, F='(I0)') + $
                    ', Offset ' + STRING(raoff,decoff,$
                                         F='("(",F+0.1,",",F+0.1,")")') + $
                    ', ' + STRING(N_E(sourceobs),F='(I0)') + ' observations'
      ENDIF ELSE BEGIN
         titlehdr = 'Nights = 200604' + STRING(night[0], F='(I0)') + $
                    ' & ' + STRING(night[1], F='(I0)') + $
                    ', Offsets ' + STRING(raoff[0],decoff[0],$
                                          F='("(",F+0.1,",",F+0.1,")")') + $
                    ' & ' + STRING(raoff[1],decoff[1],$
                                   F='("(",F+0.1,",",F+0.1,")")') + $
                    ', ' + STRING(N_E(sourceobs),F='(I0)') + $
                    ' observations'
      ENDELSE
      miny = MIN([unweighted_sens,$
                  psd05_sens,$
                  psd10_sens,$
                  psd10_sens_simp,$
                  nod10_sens])
      maxy = MAX([unweighted_sens,$
                  psd05_sens,$
                  psd10_sens,$
                  psd10_sens_simp,$
                  nod10_sens])
      xr = [184,309]
      PLOT, freqs, psd10_sens, YRANGE = [0,8], XRANGE = xr, /YSTY, /XSTY, $
            TITLE = titlehdr, XTITLE = 'Frequency [GHz]', $
            YTITLE = 'Sensitivity [Jy sec!E1/2!N]'
      OPLOT, freqs, psd05_sens, COLOR = 2
      OPLOT, freqs, nod10_sens, COLOR = 3
      OPLOT, freqs, unweighted_sens, COLOR = 4
      OPLOT, freqs, psd10_sens_simp, COLOR = 6
      
                                ; Next plot the Histograms
      maxy = MAX([unweighted_hist,$
                  psd05_hist,$
                  psd10_hist,$
                  psd10_hist_simp,$
                  nod10_hist])
      PLOT, hbins, psd10_hist, YRANGE = [0,maxy], $
            YTITLE = '# of channels', $
            XTITLE = 'Sensitivity [Jy sec!E1/2!N]'
      OPLOT, hbins+0.02, psd05_hist, COLOR = 2
      OPLOT, hbins+0.04, nod10_hist, COLOR = 3
      OPLOT, hbins+0.06, unweighted_hist, COLOR = 4
      OPLOT, hbins+0.08, psd10_hist_simp, COLOR = 6

      colors = [0,2,3,4]
      FOR errest = 0, 3 DO BEGIN
         OPLOT, medsens[errest]*[1,1], !Y.CRANGE, COLOR = colors[errest]
         OPLOT, bestsens[errest]*[1,1], !Y.CRANGE, $
                COLOR = colors[errest], LINE = 5
      ENDFOR
      senssort = SORT(bestsens)
                                ; Make Legend in upper right hand corner
      XYOUTS, 3, 0.9*!Y.CRANGE[1], 'psd10 (' + $
              STRING(TOTAL(psd10_hist),F='(I0)') + ') [' + $
              STRING(WHERE(senssort EQ 0),F='(I0)') + ']'
      XYOUTS, 3, 0.8*!Y.CRANGE[1], 'psd05 (' + $
              STRING(TOTAL(psd05_hist),F='(I0)') + ') [' + $
              STRING(WHERE(senssort EQ 1),F='(I0)') + ']', COLOR = 2
      XYOUTS, 3, 0.7*!Y.CRANGE[1], 'nod10 (' + $
              STRING(TOTAL(nod10_hist),F='(I0)') + ') [' + $
              STRING(WHERE(senssort EQ 2),F='(I0)') + ']', COLOR = 3
      XYOUTS, 3, 0.6*!Y.CRANGE[1], 'unweighted (' + $
              STRING(TOTAL(unweighted_hist),F='(I0)') + ') [' + $
              STRING(WHERE(senssort EQ 3),F='(I0)') + ']', COLOR = 4
      XYOUTS, 3, 0.5*!Y.CRANGE[1], 'psd10_naive (' + $
              STRING(TOTAL(psd10_hist_simp),F='(I0)') + ')', COLOR = 6
      
   ENDFOR
   
   DEVICE, /CLOSE_FILE
   SET_PLOT, 'x', /COPY
   !P.MULTI = 0
   !P.PSYM = 0
   !P.THICK = 0
   !P.CHARTHICK = 0
   !X.THICK = 0
   !Y.THICK = 0
   !P.CHARSIZE = 0
   
ENDFOR

END
