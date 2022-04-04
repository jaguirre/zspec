; This routine overplots labeled vertical lines to indicate spectral
; lines.  It is similar to printlines but uses the fit data from ZILF
; to identify the lines.  Fitdata is the struture that is saved by
; ZILF with fit data, levels are fractional heights for placing the
; line labels.  This routine will passes several keywords to OPLOT
; and/or XYOUTS as appropriate. extra keywords to OPLOT so that
; the line color and thickness (etc.) can be adjusted.

PRO printlines_zilf, fitdata, levels, $
                     COLOR = COLOR, THICK = THICK, LINE = LINE, $
                     CHARSIZE = CHARSIZE, CHARTHICK = CHARTHICK
; Extract needed pieces
  species = fitdata.x.species
  trans = fitdata.x.transition
  lfreqs = fitdata.x.line_freqs
  
; Get current plot ranges
  xrange = !X.CRANGE
  delx = xrange[1]-xrange[0]
  yrange = !Y.CRANGE
  dely = yrange[1]-yrange[0]

  plevels = yrange[0] + dely*levels
  
  used = 0
  FOR l = 0, N_E(species)-1 DO BEGIN
     IF ((lfreqs[l] GE xrange[0]) AND (lfreqs[l] LE xrange[1])) THEN BEGIN
        OPLOT, lfreqs[[l,l]], yrange, $
               COLOR = COLOR, THICK = THICK, LINE = LINE
        XYOUTS, lfreqs[l]-delx/200., plevels[used MOD N_E(levels)], $
                species[l] + ' ' + trans[l], $
                ALIGNMENT = 0.5, ORIENTATION = 90, $
                COLOR = COLOR, CHARSIZE = CHARSIZE, CHARTHICK = CHARTHICK
        used += 1
     ENDIF
  ENDFOR
END
