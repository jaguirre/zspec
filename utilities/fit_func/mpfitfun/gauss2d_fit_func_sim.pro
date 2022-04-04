; Modified version of gauss2d_fit_func which allows A to be 7xN, where
; N is the number of gaussians to be fit simultaneously.  The
; returned function represents a sum of N gaussians evaluated at X.
; Intended to be called by source2dfit[_sim], which defines the common
; block.
function gauss2d_fit_func_sim, X, A

common cmn_block

   ON_ERROR,2                      ;Return to caller if an error occurs

   f = fltarr(n_e(X[0,*]))

   for i=0,n_e(A[0,*])-1 do begin
       ; Set DC level differently based on position in map
       current_source_area = where(i eq x_source_index)
       f[current_source_area] = f[current_source_area] + A[0,i]  

       xtrans = (X[0,*] - A[4,i]) * cos(A[6,i]) - (X[1,*] - A[5,i]) * sin(A[6,i])
       ytrans = (X[0,*] - A[4,i]) * sin(A[6,i]) + (X[1,*] - A[5,i]) * cos(A[6,i])
       
       f = f + (A[1,i] * exp( - 0.5 * ( (xtrans/A[2,i])^2 + (ytrans/A[3,i])^2 ) ))
       
       dummy=where(finite(f),ct)
       if(ct eq 0) then begin
           print,'Gaussian function went to garbage'
           stop
       endif
   endfor

   return, f
end
