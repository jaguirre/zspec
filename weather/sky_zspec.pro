FUNCTION sky_zspec,tau
; returns the emissivity of the sky in a 160-element array for each of the
; z-Spec bands based on a given tau at 225 GHz
; Created by MB 7 Jan 06
; Modified by BN 14 Mar 07

  tau_dry_file = !ZSPEC_PIPELINE_ROOT + '/weather/tau_dry.txt'
  tau_2mm_file = !ZSPEC_PIPELINE_ROOT + '/weather/tau_2mm.txt'
  tau_sav_file = !ZSPEC_PIPELINE_ROOT + '/weather/tau_dry_2mm.sav'
  
  pwv=tau2pwv(tau)
; tau_sav_file isn't in the svn archive, so create it if it doesn't exits
; or read from it (much faster than readcol) if is present.
  IF FILE_TEST(tau_sav_file) THEN BEGIN
     RESTORE, tau_sav_file
  ENDIF ELSE BEGIN
     readcol,tau_dry_file,freq_tau,tau_array_dry,format='(F,F)'
     ;tau_array_dry is really 0.001 mm of water
     readcol,tau_2mm_file,freq_tau,tau_array_2mm,format='(F,F)'
     SAVE,freq_tau,tau_array_dry,tau_array_2mm,FILE = tau_sav_file
  ENDELSE
  tau_array_calc = tau_array_dry + $
                   (tau_array_2mm-tau_array_dry) * (pwv-0.001)/(2.0-0.001)
  delta_nu_array=freq_tau[1]-freq_tau[0]

  freq=freqid2freq()
  bw=freqid2squarebw()
  tau_sky=fltarr(n_elements(freq))
  FOR i=0,n_elements(freq) -1 DO BEGIN
     tau_sky[i]= $
        -1.0 * ALOG(1.0 - $
                    MEAN(1. - $
                         EXP(-1.0*$
                             tau_array_calc[WHERE(ABS(freq_tau-freq[i]) LT $
                                                  bw[i]/2)])))

  END
  RETURN,tau_sky
END

pro zspec_sky_test

readcol,!ZSPEC_PIPELINE_ROOT + '/working_bret/weather/' + $
        'tau_0.5mm.txt',freq_tau,tau_array,format='(F,F)'
plot,freq_lookup(findgen(160)),sky_zspec(pwv2tau(0.5)),psym=10,yrange=[0,.4],xrange=[240,260]
oplot,freq_tau,tau_array,color=2

end



