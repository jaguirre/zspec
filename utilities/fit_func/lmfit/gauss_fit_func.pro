function gauss_fit_func, X, A
;+
; 
; Routine to return the output of a gaussian at values X for parameters A.
; Code is just a copy of IDL built-in procedure GAUSS_FUNCT, which is 
; unfortunately not directly accessible
;
; INPUTS:
;    X = values at which to evaluate the gaussian
;    A = parameters of gaussian:
;	 A(0)*EXP(-Z^2/2) + A(3) + A(4)*X + A(5)*X^2
;	 Z = (X-A(1))/A(2)
;        elements beyond A(2) are optional
;
; OUTPUTS: 
;    values of the specified gaussian at the specified values of X
;    and partial derivatives
;    output dimension: n_elements(A)+1 by n_elements(X)
;
; USAGE:
;    gauss_funct_func(X,A)
;
; MODIFICATION HISTORY:
;    2000/08/10 SG 
;-

   n = n_elements(a)
   ON_ERROR,2                      ;Return to caller if an error occurs
   if a[2] ne 0.0 then begin
       Z = (X-A[1])/A[2]    ;GET Z
       EZ = EXP(-Z^2/2.)   ;GAUSSIAN PART
   endif else begin
       z = 100.
       ez = 0.0
   endelse

   case n of
3:    F = A[0]*EZ
4:    F = A[0]*EZ + A[3]
5:    F = A[0]*EZ + A[3] + A[4]*X
6:    F = A[0]*EZ + A[3] + A[4]*X + A[5]*X^2 ;FUNCTIONS.
   ENDCASE

   PDER = FLTARR(N_ELEMENTS(X),n) ;YES, MAKE ARRAY.
   PDER[*,0] = EZ      ;COMPUTE PARTIALS
   if a[2] ne 0. then PDER[*,1] = A[0] * EZ * Z/A[2]
   PDER[*,2] = PDER[*,1] * Z
   if n gt 3 then PDER[*,3] = 1.
   if n gt 4 then PDER[*,4] = X
   if n gt 5 then PDER[*,5] = X^2

   y = replicate(0D,n_elements(a)+1,n_elements(x))

   y[0,*] = F
   y[1:*,*] = transpose(PDER)

   return, y

END





