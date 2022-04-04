FUNCTION get_psd_peakcenter, psd, peakfreq, $
                             DIAGNOSTIC = DIAGNOSTIC,$
                             FITWIDTH = FITWIDTH
  fitparams = get_psd_peakfit(psd,peakfreq,$
                              DIAGNOSTIC = DIAGNOSTIC,$
                              FITWIDTH = FITWIDTH)
  RETURN, fitparams[1]
END
