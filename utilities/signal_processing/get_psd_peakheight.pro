FUNCTION get_psd_peakheight, psd, peakfreq, $
                             DIAGNOSTIC = DIAGNOSTIC,$
                             FITWIDTH = FITWIDTH
  fitparams = get_psd_peakfit(psd,peakfreq,$
                              DIAGNOSTIC = DIAGNOSTIC,$
                              FITWIDTH = FITWIDTH)
  RETURN, fitparams[0]+fitparams[3]
END
