function tau225_tauz_fit_func, X, A
;+
; NAME:
;       tau225_tauz_fit_func
;
; PURPOSE:
;       Routine to return the output of the expected zenith
;       atmospheric power function
;
;       Qz = Q300*(1 - exp(-(tau225_tauz_offset + tau225_tauz_slope * tau225))
;
; CALLING SEQUENCE:
;       result = tau225_tauz_fit_func(X, A)
;
; INPUTS:
;       X = N-element array consisting of the tau225 data
;       A = parameters of fit:
; 	   A[2] * ( 1 - exp(-(A[0] + A[1]*tau225)) )
;
; OUTPUTS: 
;      The function values in an array of length n_elements(X)
;
; MODIFICATION HISTORY:
;      2002/06/23 SG
;-

   ON_ERROR,2                      ;Return to caller if an error occurs

   F = A[2] * ( 1 - exp(-(A[0] + A[1]*X)) )

   RETURN, F

END
