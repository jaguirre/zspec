FUNCTION trans_zspec_fts_incl_airmass,tau,airmass

;LE 2007-08-03 
;varied version of MB's trans_zspec_fts - multiplies tau*airmass in last
;                                    step to get transmission which
;                                    accounts for airmass 

; returns the average transmission of the sky for each channel, based
; on the FTS spectra of each channel and a sky model from Pardo,
; Cernicaro et al.
; Created 3 July 2007 MB, uses databases in /weather/skydata/ directory
; see also sky_zspec_fts.pro
;

  pwv=tau2pwv(tau)
  freq=freqid2freq()
  restore, !ZSPEC_PIPELINE_ROOT + '/line_cont_fitting/ftsdata/normspec_nov.sav'
  dnu=nu_trim[1]-nu_trim[0]

  restore,!ZSPEC_PIPELINE_ROOT+'/weather/skydata/fts_tau_dry.sav'
  restore,!ZSPEC_PIPELINE_ROOT+'/weather/skydata/fts_tau_2mm.sav'
  
;stop

  trans_sky=fltarr(n_elements(freq))

  FOR i=0,n_elements(freq) -1 DO BEGIN
      trans_sky[i]=total(dnu*spec_coadd_norm[i,*]*$
                         exp(-1*airmass*(fts_tau_dry+(fts_tau_2mm-fts_tau_dry)*pwv/2.0)))

  endfor
;  stop
RETURN,trans_sky
END





