function pwrlaw_fit_func, X, A
;+
; 
; Routine to return the output of a power law at values X for parameters A.
;
; INPUTS:
;    X = values at which to evaluate the function
;    A = parameters of power law:
;	 A(0)*X^A(1) + A(2)
;        elements beyond A(1) are optional
;
; OUTPUTS: 
;    values of the specified power law at the specified values of X
;    and partial derivatives
;    output dimension: n_elements(A)+1 by n_elements(X)
;
; USAGE:
;    pwrlaw_fit_func(X,A)
;
; MODIFICATION HISTORY:
;    2000/11/14 SG 
;-

   n = n_elements(a)
   ON_ERROR,2                      ;Return to caller if an error occurs

   case n of
2:    F = A[0]*X^A[1]
3:    F = A[0]*X^A[1] + A[2]
   ENDCASE

   PDER = FLTARR(N_ELEMENTS(X),n) ;YES, MAKE ARRAY.
   PDER[*,0] = X^A[1]      ;COMPUTE PARTIALS
   PDER[*,1] = A[0] * A[1] * X^(A[1]-1.0)
   if n gt 2 then PDER[*,2] = 1.

   y = replicate(0D,n_elements(a)+1,n_elements(x))

   y[0,*] = F
   y[1:*,*] = transpose(PDER)

   return, y

END





