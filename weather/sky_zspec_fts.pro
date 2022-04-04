FUNCTION sky_zspec_fts,tau


; returns the emissivity of the sky in a 160-element array for each of the
; z-Spec channels based on a given tau at 225 GHz, and using the
; measured bandpasses of the instrument (i.e. not square bandpasses)
; Requires save files in /weather/skydata/ directory
; Created MB 3 July 07

  
  pwv=tau2pwv(tau)
  freq=freqid2freq()
  restore, !ZSPEC_PIPELINE_ROOT + '/line_cont_fitting/ftsdata/normspec_nov.sav'
  dnu=nu_trim[1]-nu_trim[0]
  
  restore,!ZSPEC_PIPELINE_ROOT+'/weather/skydata/fts_tau_dry.sav'
  restore,!ZSPEC_PIPELINE_ROOT+'/weather/skydata/fts_tau_2mm.sav'
  
;stop
  
  tau_sky=fltarr(n_elements(freq))
  
  FOR i=0,n_elements(freq) -1 DO BEGIN
      tau_sky[i]=total(dnu*spec_coadd_norm[i,*]*(fts_tau_dry+(fts_tau_2mm-fts_tau_dry)*pwv/2.0))
      
  endfor
  RETURN,tau_sky
END




