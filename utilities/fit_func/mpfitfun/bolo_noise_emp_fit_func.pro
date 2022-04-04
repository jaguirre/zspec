function bolo_noise_emp_fit_func, X, A
;+
; NAME:
;       bolo_noise_emp_fit_func
;
; PURPOSE:
;       Routine to return the expected empirical bolometer noise PSD 
;       function, combining the following terms:
;       - 1/f rolled of by bolo time constant
;       - white noise rolled off by bolo time constant
;       - white noise not rolled off by bolo time constant
;       - all noise rolled off by LP butterworth
;       
; CALLING SEQUENCE:
;      result = bolo_noise_emp_fit_func(X, A)
;
; INPUTS:
;       X = N-element array consisting of the frequency array
;       A = parameters of fit:
;       A = sqrt( 
;           ( A[2]^2 * ( 1 + ( f / A[3] )^(-2.*A[4]) ) )
;             / ( 1 + ( 2 !PI f A[1] )^2 ) 
;             + A[5]^2 ) 
;           / (1. + abs( f/A[6] )^8.)
;           * |lpf_2pole_butter|^2
;           + A[0]^2
;           A[0] = white noise w/o rolloffs
;           A[1] = tau = bolometer time constant
;           A[2] = amplitude of white optical noise
;           A[3] = 1/f knee frequency -- where does 1/f noise match
;                  white noise
;           A[4] = exponent of 1/f (Kolmogorov - f^-4/3 instead of f^-1)
;           A[5] = amplitude of non-optical white noise
;           A[6] = tau of butterworth's in lockin lpf
;      If you don't want to include a particular noise, you should
;      set its parinfo.value = 0 and parinfo.fixed = 1.
;
; OUTPUTS: 
;      The function values in an array of length n_elements(X)
;
; MODIFICATION HISTORY:
;      2004/05/20 SG
;      2004/08/18 JS eliminated downsample filter (because it is
;                    always deconvolved if it is applied), made
;                    the tau of 2pole butter's an input parameter
;                    (in case they have been deconvolved from the
;                    timestream), and divided 2pole butter's by 
;                    their gain.
;-

on_error, 2

COMMON ELEC_COMMON

psd = A[2]^2. * ( 1. + abs( X/(A[3]+eps(/double)) )^(-2.*A[4]) ) $
      / ( 1. + ( 2. * !DPI * X * A[1] )^2. ) $
      + A[5]^2.
psd = psd $
      * ( abs( $
               lpf_2pole_butter(X, A[6], elec_comstr.lockin.lpf[0].G0) $
             * lpf_2pole_butter(X, A[6], elec_comstr.lockin.lpf[1].G0) $
             / elec_comstr.lockin.lpf[0].G0 $
             / elec_comstr.lockin.lpf[1].G0 $
             ) )^2.

psd = sqrt(psd + A[0]^2)

return, psd

END
