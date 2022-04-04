function pwrlawdiff_fit_func, X, A
;+
; NAME:
;       pwrlawdiff_fit_func
;
; PURPOSE:
;       Routine to return the output of a power law difference of the
;       form
;
;       y = g (x1^alpha - x2^alpha) + b
;
; CALLING SEQUENCE:
;       result = pwrlawdiff_fit_func(X, A)
;
; INPUTS:
;       X = 2xN array consisting of the T1 and T2 data
;           X[0,*] = T1
;           X[1,*] = T2
;       A = parameters of power law:
; 	   A[0] * (X[0,*]^A[1] - X[1,*]^A[1]) + A[2]
;          If A[2] is not supplied, it is taken to be 0.
;
; OUTPUTS: 
;      The function values in an array of length n_elements(X[0,*])
;
; MODIFICATION HISTORY:
;      2002/03/20 SG
;-

   N = N_ELEMENTS(A)
   ON_ERROR,2                      ;Return to caller if an error occurs

   CASE N OF
2:    F = A[0]*(X[0,*]^A[1] - X[1,*]^A[1])
3:    F = A[0]*(X[0,*]^A[1] - X[1,*]^A[1]) + A[2]
   ENDCASE

   RETURN, F

END





