; Modified version of gauss2d_fit_func which allows A to be 7xN, where
; N is the number of gaussians to be fit simultaneously.  The
; returned function represents a sum of N gaussians evaluated at X.
; Intended to be called by source2dfit[_sim], which defines the
; appropriate common blocks.
;
; Stole code for gauss2d_fit_func_sim, added the
; wiener-filtering step.
function gauss2d_wf_fit_func_sim, X, A

common cmn_block
common gauss2dfit_wf_cmn

   ON_ERROR,2                      ;Return to caller if an error occurs

   f = fltarr(n_e(X[0,*]))
   map = fltarr(nx,ny)
   for i=0,n_e(A[0,*])-1 do begin
       ; Set DC level differently based on position in map
       current_source_area = where(i eq x_source_index)

       current_dc_values=fltarr(n_e(map[X[0,*],X[1,*]]))
       current_dc_values[current_source_area]=current_dc_values[current_source_area]+A[0,i]
       map[X[0,*],X[1,*]]=map[X[0,*],X[1,*]]+current_dc_values

       xtrans = (X[0,*] - A[4,i]) * cos(A[6,i]) - (X[1,*] - A[5,i]) * sin(A[6,i])
       ytrans = (X[0,*] - A[4,i]) * sin(A[6,i]) + (X[1,*] - A[5,i]) * cos(A[6,i])

       map[X[0,*],X[1,*]] = map[X[0,*],X[1,*]] + (A[1,i] * exp( - 0.5 * ( (xtrans/A[2,i])^2 + (ytrans/A[3,i])^2 ) ))
   endfor

   wf_map = wiener_filter_map(map,wiener_filter,resolution,fwhm)
   f = reform(wf_map[X[0,*],X[1,*]])

   return, f
end
