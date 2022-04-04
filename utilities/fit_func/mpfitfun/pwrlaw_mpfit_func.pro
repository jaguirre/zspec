function pwrlaw_mpfit_func, X, A
;+
; NAME:
;       pwrlaw_mpfit_func
;
; PURPOSE:
;       Routine to return the output of a power law of the
;       form
;
;       y = g (x1^alpha) + b
;
; CALLING SEQUENCE:
;       result = pwrlaw_mpfit_func(X, A)
;
; INPUTS:
;       X = N array consisting of the T1 data
;
;       A = parameters of power law:
; 	   A[0] * (X[0,*]^A[1]) + A[2]
;          If A[2] is not supplied, it is taken to be 0.
;
; OUTPUTS: 
;      The function values in an array of length n_elements(X[*])
;
; MODIFICATION HISTORY:
;      2007/02/16 BN - created original from pwrlawdiff_fit_func.pro
;-

   N = N_ELEMENTS(A)
   ON_ERROR,2                      ;Return to caller if an error occurs

   CASE N OF
2:    F = A[0]*(X^A[1])
3:    F = A[0]*(X^A[1]) + A[2]
   ENDCASE

   RETURN, F

END





