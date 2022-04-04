function tauz_fit_func, X, A
;+
; NAME:
;       tauz_fit_func
;
; PURPOSE:
;       Routine to return the output of the expected atmospheric power
;       function
;
;       Q = Q0 + Q300*(1 - exp(-tauz/sin(el)))
;
; CALLING SEQUENCE:
;       result = tauz_fit_func(X, A)
;
; INPUTS:
;       X = N-element array consisting of the elevation data (degrees)
;       A = parameters of fit:
; 	   A[2] + A[1] * ( 1 - exp(-A[0]/sin(X)) )
;          If A[2] is not supplied, it is taken to be 0.
;
; OUTPUTS: 
;      The function values in an array of length n_elements(X)
;
; MODIFICATION HISTORY:
;      2002/05/15 SG
;-

   N = N_ELEMENTS(A)
   ON_ERROR,2                      ;Return to caller if an error occurs

   CASE N OF
2:    F = A[1] * ( 1 - exp(-A[0]/sin(X*!DPI/180.)) )
3:    F = A[2] + A[1] * ( 1 - exp(-A[0]/sin(X*!DPI/180.)) )
   ENDCASE

   RETURN, F

END
