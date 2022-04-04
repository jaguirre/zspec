function gauss2d_fit_func, X, A
;+
; NAME:
;       gauss2d_fit_func
;
; PURPOSE:
;       Routine to return a 2D gaussian of the form
;
;       z = A[0] + A[1] * exp( -U/2 )
;
;       U = (x'/a)^2 + (y'/b)^2
;
;       x' = (x - x0) cos(theta) - (y - y0) sin(theta)
;       y' = (x - x0) sin(theta) + (y - y0) cos(theta)
;
; CALLING SEQUENCE:
;       result = gauss2d_fit_func(X, A)
;
; INPUTS:
;       X = 2xN array consisting of the x and y coordinates
;           X[0,*] = x
;           X[1,*] = y
;       A = parameters of fit:
;           A[0] and A[1] given above
;           A[2] = a
;           A[3] = b
;           A[4] = x0
;           A[5] = y0
;           A[6] = theta [radians]
;
; OUTPUTS: 
;      The function values in an array of length n_elements(X[0,*])
;
; MODIFICATION HISTORY:
;      2003/01/28 SG
;-

   ON_ERROR,2                      ;Return to caller if an error occurs

   xtrans = (X[0,*] - A[4]) * cos(A[6]) - (X[1,*] - A[5]) * sin(A[6])
   ytrans = (X[0,*] - A[4]) * sin(A[6]) + (X[1,*] - A[5]) * cos(A[6])

   f = A[0] + A[1] * exp( - 0.5 * ( (xtrans/A[2])^2 + (ytrans/A[3])^2 ) )

   return, f

end




