function p_of_r_fit_func, X, A
;+
; NAME:
;       p_of_r_fit_func
;
; PURPOSE:
;       Routine to return the expected IV power as a function of 
;       bolometer resistance:
;
;       P_e = -Q + g ( { Delta [ ln(R/R0) ]^-2 }^alpha - T_bath^alpha )
;
; CALLING SEQUENCE:
;       result = p_of_r_fit_func(X, A)
;
; INPUTS:
;       X = N-element array consisting of the resistance data ohms
;       A = parameters of fit:
; 	    A[5] + A[2] * ( { A[0] [ ln(R/A[1]) ]^-2 }^A[3] - A[4]^A[3] )
;           A[0] = Delta
;           A[1] = R0
;           A[2] = g
;           A[3] = alpha
;           A[4] = T_bath
;           A[5] = Q (optional; set to zero if not included)
;
; OUTPUTS: 
;      The function values in an array of length n_elements(X)
;
; MODIFICATION HISTORY:
;      2002/06/02 SG
;-

   N = N_ELEMENTS(A)
   ON_ERROR,2                      ;Return to caller if an error occurs

   IF N LT 6 THEN A[5] = 0
   IF N LT 5 THEN MESSAGE, 'Argument A must have 5 or 6 elements.'

   F = -A[5] + A[2] * ( ( A[0] * ( ALOG(X/A[1]) )^(-2.) )^A[3] - A[4]^A[3] )
   
   RETURN, F

END

