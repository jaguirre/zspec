FUNCTION ngc1068_fitfun, x, p

  ; This function is the Z-Spec continuum model for NGC1068.
  ; For full explanation, see the paper draft in
  ; zspec_svn/papers_in_progress/ngc1068.
  
  ; Based off of hughes94_fitfun as used for M82, but a 
  ; completely different model.
  
  ; Continuum is sum of 2 components, a beamscaled greybody
  ; and a power law from the jet (as from Krips 2006).
  ; Free parameters are A and B.
  
  ; F = A (nu/240)^(B-2) Omega B(T) (1 - e^(- (100microns/lambda)^Beta))
  ;      + F_core (nu/230)^(-alpha)
  
  ; Committed to svn by JRK 6/7/10

  nu = x ; in GHz

; Free parameters
  A = p[0]
  B = p[1]
  
; Physical constants, unit conversions
  h = 6.626068d-34
  c = 299792458.d
  k = 1.3806503d-23
  GHz = 1d9
  um = 1d-6

; NGC1068-specific values
  tdust = 34       ; Temperature of dust blackbody for star-forming arms.
  sr=1.6614000e-08 ; Solid angle of emission area
  beta = 2         ; Power law for optical depth variation with wavelength
  lambda_0 = 100   ; Reference optical depth to 100 microns
 
; Going along with Bret's, all in MKS, hence the 1d16 to get to Jy.
  spec = A * 1d26 * sr * $
              (2.d * h*(nu*GHz)^3/c^2)/(EXP((h*nu*GHz)/(k*tdust)) - 1.d) * $
              (1.d - EXP(-(lambda_0*um/(c/(nu*GHz)))^beta))

; Beam scaling
  spec *= (nu/240.)^(-2.0) ; Point Source -> Beam Filling Source
  spec *= (nu/240.)^B
  
; Add in power law from jet (NGC1068 specific values here too)
  jet=28*1d-3*(nu/230)^(-0.9)
  spec+=jet

  return, spec
END
