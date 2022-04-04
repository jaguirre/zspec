function bolo_noise_fit_func, X, A
;+
; NAME:
;       bolo_noise_fit_func
;
; PURPOSE:
;       Routine to return approximate expected bolometer noise function.
;
;       A = (a_therm     / sqrt( 1 + ( 2 !PI f tau_eff )^2 ) 
;            + a_johnson * sqrt( 1 + ( 2 !PI f tau_therm )^2 ) 
;                        / sqrt( 1 + ( 2 !PI f tau_eff )^2 )
;            + a_load    * sqrt( 1 + ( 2 !PI f tau_load )^2 )
;                        / sqrt( 1 + (2 !PI f tau_eff )^2 )
;            + a_white) * lpf_2pole_butter
;
; CALLING SEQUENCE:
;       result = bolo_noise_fit_func(X, A)
;
; INPUTS:
;       X = N-element array consisting of the frequency array
;       A = parameters of fit:
;       A = sqrt( 
;              A[3]^2 / (1 + ( 2 !PI f A[0] )^2 ) 
;            + A[4]^2 * ( 1 + ( 2 !PI f A[1] )^2 ) 
;                     / ( 1 + ( 2 !PI f A[0] )^2 )
;            + A[5]^2 * ( 1 + ( 2 !PI f A[2] )^2 )
;                     / sqrt( 1 + (2 !PI f A[0] )^2 )
;            + A[6]^2) * |lpf_2pole_butter|
;           A[0] = tau_eff = electrothermally sped-up time constant
;           A[1] = tau_therm = thermal time constant
;           A[2] = tau_load = load resistor johnson noise time
;                             constant
;                           = tau_eff * ( Z + ZL ) / ( R + ZL )
;           A[3] = amplitude of phonon + shot + wave noise 
;                  (quadrature sum)
;           A[4] = amplitude of johnson noise
;           A[5] = amplitude of load R noise
;           A[6] = amplifier noise
;      If you don't want to include a particular noise, you should
;      set its parinfo.value = 1 and parinfo.fixed = 1
;
; OUTPUTS: 
;      The function values in an array of length n_elements(X)
;
; MODIFICATION HISTORY:
;      2002/06/26 SG
;-

   common ELEC_COMMON

   N = N_ELEMENTS(A)
   ON_ERROR,2                      ;Return to caller if an error occurs

   w = 2 * !DPI * X

   ; have to do it this way because G0 doesn't set normalization:
   ; it affects the entire transfer function
   ; so do full filter, then divide out by DC gain to get
   ; filter normalized to 1
   lpf = abs(lpf_2pole_butter(X, ELEC_COMSTR.lockin.lpf[0].tau, $
                                 ELEC_COMSTR.lockin.lpf[0].G0)) $
         * abs(lpf_2pole_butter(X, ELEC_COMSTR.lockin.lpf[1].tau, $
                                 ELEC_COMSTR.lockin.lpf[1].G0))
   lpf = lpf / ELEC_COMSTR.lockin.lpf[0].G0 / ELEC_COMSTR.lockin.lpf[1].G0


   F = lpf * sqrt( A[3]^2 / ( 1. + ( w * A[0] )^2 ) $ 
                 + A[4]^2 * ( A[0] / ( eps() + A[1] ) )^2 $
                          * ( 1. + ( w * A[1] )^2 ) $
                          / ( 1. + ( w * A[0] )^2 ) $
                 + A[5]^2 * ( 1. + ( w * A[2] )^2 ) $
                          / ( 1. + ( w * A[0] )^2 ) $
                 + A[6]^2 )

   RETURN, F

END
