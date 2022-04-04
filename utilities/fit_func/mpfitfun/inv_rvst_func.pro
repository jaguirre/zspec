function inv_rvst_func, X, A
;+
; NAME:
;       inv_rvst_func
;
; PURPOSE:
;       Returns T(R) for NTD, including E-field effect if so desired.
;       The standard NTD R(T), including E-field effect, is
;
;       R = R0 exp( sqrt(Delta/T) - (e E l)/(k T) )
;
;       where E is the E-field.  Now, E = V/d = IR/d.  So
;
;       R = R0 exp( sqrt(Delta/T) - (eV/kT)*(l/d) )
;
;       This can't be solved for R in closed form because it's
;       transcendental, but it can be solved for T in terms of R and
;       I (change variables to x = T^-1/2 and you get a quadratic in
;       x):
;
;       T = Delta {
;                  [ (2 e I R)/(k Delta) (l/d) ]
;                  / [ 1 - (1 - 4 (e I R)/(k Delta) (l/d) ln(R/R0) )^1/2 ]
;                 }^2
;
;       (See SG for derivation).  One can check this is correct in the 
;       limit l -> 0 (no e-field effect).
; 
; CALLING SEQUENCE:
;       result = inv_rvst_func(X, A)
;
; INPUTS:
;       option 1: no e-field effect
;          X = N-element array consisting of the resistance data
;          A = parameters:
; 	       A[0] = R0
;              A[1] = Delta
;       option 2: include e-field effect
;          X = 2xN-element array consisting of the resistance and
;              current data
;              X[0,*] = resistance
;              X[1,*] = current
;          A = parameters:
;              A[0] = R0
;              A[1] = Delta
;              A[2] = l/d (no need to separate the two)
;
; OUTPUTS: 
;      The function values in a 1-D array
;
; MODIFICATION HISTORY:
;      2002/05/31 SG Yes, I did test it!
;-

   N = N_ELEMENTS(A)
   ON_ERROR,2                      ;Return to caller if an error occurs

   e = 1.602176e-19
   kb = 1.380650e-23

   CASE N OF
2:    F = A[1] * ( alog( X/A[0] ) )^(-2.)
3:    BEGIN
         fac = 2 * A[2] * e * X[1,*] * X[0,*] / kb / A[1]
         F = A[1] * fac^2. / (1. - sqrt(1. - 2. * fac * alog(X[0,*]/A[0])))^2.
      END
   ENDCASE

   RETURN, F

END
