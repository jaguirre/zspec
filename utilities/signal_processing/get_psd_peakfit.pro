FUNCTION get_psd_peakfit, psd, peakfreq, $
                          DIAGNOSTIC = DIAGNOSTIC,$
                          FITWIDTH = FITWIDTH

if (peakfreq ge max(psd.freq)) then begin
    
    message,/info,'Searching for chopper frequency beyond Nyquist.'
    message,/info,'Setting amplitude to zero.'
    fitparams = [0., 0, 0, 0]

endif else begin

  ; FITWIDTH = points above and below peak for fitting
  IF KEYWORD_SET(FITWIDTH) THEN FITWIDTH = FITWIDTH ELSE FITWIDTH = 25
  
  searchwidth = 0.1 ; peak should be within +/- 0.1Hz of peakfreq
  nearpeak = WHERE(psd.freq GT peakfreq-searchwidth AND $
                   psd.freq LE peakfreq+searchwidth,nnear)
  IF nnear NE 0 THEN $
     psdmax = MAX(psd.psd[nearpeak],maxind) $
  ELSE BEGIN
     MESSAGE, /INFO, 'No points in psd.freq around given ' + $
              'peak frequency, Stopping.'
     STOP
  ENDELSE
  maxind = nearpeak[maxind]

  fitrange = LINDGEN(2*fitwidth + 1) + maxind - fitwidth
  outofrange = WHERE(fitrange LT 0 OR fitrange GE N_E(psd.freq), nout, $
                     COMPLEMENT = inrange)
  IF nout NE 0 THEN fitrange = fitrange[inrange]
  fitcurve = gaussfit(psd.freq[fitrange],psd.psd[fitrange],$
                      fitparams, NTERMS = 4)
 
  IF KEYWORD_SET(DIAGNOSTIC) THEN BEGIN
     PLOT, psd.freq, psd.psd, XRANGE = [-1,1]*searchwidth + peakfreq, /YLOG
     OPLOT, psd.freq[fitrange], psd.psd[fitrange], COLOR = 2
     OPLOT, psd.freq[fitrange], fitcurve, COLOR = 3
     XYOUTS, peakfreq - searchwidth*(3./4.), fitparams[0], $
             'Gaussian Fit Params:' + $
             '!CPeak Amplitude = ' + STRING(fitparams[0],F='(G0.8)') + $
             '!CPeak Center = ' + STRING(fitparams[1],F='(G0.8)') + $
             '!CPeak Width = ' + STRING(fitparams[2],F='(G0.8)') + $
             '!COffset = ' + STRING(fitparams[3],F='(G0.8)')
  ENDIF

endelse

  RETURN, fitparams

END
