function lpf_1pole_fit_func, X, A
;+
; NAME:
;       lpf_1pole_fit_func
;
; PURPOSE:
;       Routine to return the output of a 1-pole low-pass filter,
;       amplitude only.
;
;       A = A[1] / sqrt( 1 + ( 2 !PI f tau )^2 )
;
; CALLING SEQUENCE:
;       result = lpf_1pole_fit_func(X, A)
;
; INPUTS:
;       X = N-element array consisting of the frequency array
;       A = parameters of fit:
; 	   A[1] / sqrt( 1 + ( 2 !PI f A[0] )^2 )
;          If A[1] is not supplied, it is taken to be 1.
;
; OUTPUTS: 
;      The function values in an array of length n_elements(X)
;
; MODIFICATION HISTORY:
;      2002/06/25 SG
;-

   N = N_ELEMENTS(A)
   ON_ERROR,2                      ;Return to caller if an error occurs

   CASE N OF
1:    F = 1. / sqrt( 1 + ( 2 * !DPI * X * A[0] )^2 )
2:    F = A[1] / sqrt( 1 + ( 2 * !DPI * X * A[0] )^2 )
   ENDCASE

   RETURN, F

END
