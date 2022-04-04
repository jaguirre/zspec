; This function returns a 160 element array with the noise equivalent flux
; density for Z-Spec at the CSO for a particular atmosperic opacity and
; observation zenith angle in units of [Jy sec^1/2]

; USEAGE NOTE - THIS FUNCTION HAS **NOT** BEEN FULLY VETTED BY 
; ANYONE OTHER THAN BN, USE WITH CAUTION UNTIL OTHERS HAVE 
; CONFIRMED THAT IT WORKS PROPERLY.
FUNCTION zspec_cso_nefd, tau225, zenith, $
                         ETA = ETA, FORWARD = FORWARD
  ; Telescope Parameters
  IF ~KEYWORD_SET(FORWARD) THEN $
     forward = DOUBLE(0.90)     ; Forward Efficiency
  sigma = DOUBLE(0.025)         ; Surface RMS [mm]
  appeff = DOUBLE(0.75)         ; Aperture Efficiency
  teldia = DOUBLE(10.4)         ; Diameter [m]
  bgtemp = DOUBLE(270)          ; Atmospheric & Ground Temperature [K]

  ; Instrument Parameters
  IF ~KEYWORD_SET(ETA) THEN eta = DOUBLE(0.2); Instrument Coupling
  nep_det = DOUBLE(5e-18)       ; Detector NEP
  nep_exload = DOUBLE(4e-18)    ; NEP from 8e-14 W broadband load at 250GHz

  ; Physical Constants
  c = DOUBLE(299.7925) ; in [mm*GHz]
  h = DOUBLE(6.626076e-25) ; in [J/GHz]
  k = DOUBLE(1.38065e-23) ; in [J/K]

  ; First calculate the photon occupation number distribution for 
  ; telescope spillover and atmospheric emissivity
  freqs = freqid2freq()
  ntherm = 1.D/(EXP(h*freqs/(k*bgtemp)) - 1.D)

  ; Calculate Atmospheric Transmission for given tau & zenith
;  zspec_tau = sky_zspec(tau225)
;  atmtrans = EXP(-zspec_tau/COS(zenith*!DPI/180))
  atmtrans = trans_zspec_fts(tau225/COS(zenith*!DPI/180))

  ; Calculate photon occupation number at detector
  nphot = eta*(1.D - (forward*atmtrans))*ntherm
  ; Calculate total NEP at detector
;  fwhms = freqid2bw()
  fwhms=freqid2squarebw()
  nep_phot = h*freqs*SQRT(2*(fwhms*1d9)*nphot*(nphot+1))
  nep_tot = SQRT(nep_phot^2 + nep_det^2 + nep_exload^2)

  ; Back out total NEP @ detector to top of atmosphere
  ; include chopping, polarization & fwhm vs. linewidth mismatch
  ; include Ruze effect & convert to NEFD [Jy sec^1/2]
  nefd = 2.0*2.0*nep_tot/(fwhms*1d9)/SQRT(2);*SQRT(1.6)
  nefd /= eta
  nefd /= appeff*EXP(-(4.0*!DPI*sigma/(c/freqs))^2)
  nefd /= !DPI*(teldia/2.0)^2
  nefd /= atmtrans
  nefd /= 1d-26
;stop
  RETURN, nefd
END
