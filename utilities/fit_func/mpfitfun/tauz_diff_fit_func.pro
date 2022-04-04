function tauz_diff_fit_func, X, A
;+
; NAME:
;       tauz_diff_fit_func
;
; PURPOSE:
;       Routine to return the output of the expected atmospheric power
;       function
;
;       Q(el2) - Q(el1) = Q300*( exp(-tauz/sin(el1)) - exp(-tauz/sin(el2)) )
;
; CALLING SEQUENCE:
;       result = tauz_diff_fit_func(X, A)
;
; INPUTS:
;       X = 2xN-element array consisting of the elevation data (degrees)
;           X[0,*] = elevation 1
;           X[1,*] = elevation 2
;           Make sure you get the polarity right!
;       A = parameters of fit:
; 	   A[1] * ( exp(-A[0]/sin(X[0,*])) - exp(-A[0]/sin(X[1,*])) )
;
; OUTPUTS: 
;      The function values in an array of length n_elements(X[0,*])
;
; MODIFICATION HISTORY:
;      2002/05/15 SG
;-

   ON_ERROR,2                      ;Return to caller if an error occurs

   F = A[1] * ( exp(- A[0] / sin(X[0,*]*!DPI/180.) ) $
                - exp(- A[0] / sin(X[1,*]*!DPI/180.) ) )

   RETURN, F

END
