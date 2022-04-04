FUNCTION get_psd_peakwidth, psd, peakfreq, $
                            DIAGNOSTIC = DIAGNOSTIC,$
                            FITWIDTH = FITWIDTH
  fitparams = get_psd_peakfit(psd,peakfreq,$
                              DIAGNOSTIC = DIAGNOSTIC,$
                              FITWIDTH = FITWIDTH)
  RETURN, fitparams[2]
END
